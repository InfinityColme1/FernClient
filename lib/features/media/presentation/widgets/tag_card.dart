import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/domain/services/sibling_direction.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_siblings_usecase.dart';
import 'package:Fern/features/media/domain/usecases/set_tag_nsfw_usecase.dart';
import 'package:Fern/features/media/presentation/widgets/fern_create_dialog.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/duplicate_tag_name.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/delete_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_by_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_source_urls_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/features/media/domain/usecases/update_tag_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/recognition/presentation/recognition_feedback.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/media/presentation/widgets/assign_url_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/tag_relations_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:Fern/features/settings/domain/usecases/store_avatar_usecase.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ficha de la etiqueta elegida en la pantalla de gestión de etiquetas.
///
/// Lleva lo mismo que el diálogo de creación de etiquetas (`FernCreateDialog`)
/// —avatar editable con el nombre debajo, campo del nombre, buscador de la
/// etiqueta padre y botón de confirmación— pero sobre una superficie en vez de en
/// un diálogo, y con los valores que ya tiene la etiqueta: escribir encima de
/// ellos es editarla.
///
/// Y dos cosas que el diálogo no tiene, porque allí la etiqueta todavía no
/// existe ni tiene contenido: el botón que le quita la etiqueta a lo que esté
/// seleccionado en la rejilla y el que borra la etiqueta de la base de datos (los
/// contenidos que la tenían no se borran, sólo la pierden).
///
/// Necesita un `MediaBloc` por encima: es de donde sale la selección de la
/// rejilla y a quien se le pide que deshaga la asignación.
class TagCard extends StatefulWidget {
  final TagEntity tag;

  /// Etiqueta de la que cuelga la que se está editando, si cuelga de alguna. Es
  /// el valor con el que arranca el buscador de etiqueta padre.
  final TagEntity? parent;

  const TagCard({super.key, required this.tag, this.parent});

  @override
  State<TagCard> createState() => _TagCardState();
}

class _TagCardState extends State<TagCard> {
  final _searchTags = getIt<SearchTagsUseCase>();
  final _updateTag = getIt<UpdateTagUseCase>();
  final _deleteTag = getIt<DeleteTagUseCase>();
  final _saveTagSourceUrls = getIt<SaveTagSourceUrlsUseCase>();
  final _setTagNsfw = getIt<SetTagNsfwUseCase>();
  final _saveTagSiblings = getIt<SaveTagSiblingsUseCase>();
  final _storeAvatar = getIt<StoreAvatarUseCase>();

  late final TextEditingController _nameController =
      TextEditingController(text: widget.tag.name);

  late String? _picturePath = widget.tag.picturePath;
  late TagEntity? _parent = widget.parent;

  /// Direcciones de las que sale el contenido de la etiqueta, tal y como se
  /// están editando.
  ///
  /// Se ven y se tocan en la propia ficha, y también desde su diálogo: los dos
  /// caminos escriben aquí, así que abrir el diálogo enseña lo que hay en la
  /// ficha aunque todavía no se haya guardado.
  late List<FernLink> _sourceUrls = [
    for (final url in widget.tag.sourceUrls)
      FernLink(url, isNsfw: widget.tag.marksLink(url)),
  ];

  /// Cuántas veces han cambiado las direcciones **desde fuera de la lista**.
  ///
  /// Es la clave de la lista de enlaces: la lista se queda con las direcciones
  /// que recibe al nacer, así que para que recoja lo que acaba de confirmar el
  /// diálogo hay que hacerla nacer otra vez. Escribir en ella no toca esto: si
  /// lo tocara, la lista se reharía en cada tecla y el campo perdería el foco.
  int _urlsRevision = 0;


  /// La etiqueta está marcada como contenido no apto.
  ///
  /// Se guarda en el momento de tocar el interruptor y no con el botón de
  /// guardar: es una decisión que hace desaparecer contenido de la vista, y
  /// dejarla a medias —marcada en pantalla, sin marcar en la base de datos—
  /// sería la peor forma de contarlo.
  late bool _isNsfw = widget.tag.isNsfw;

  /// La etiqueta identifica a una persona.
  ///
  /// Se guarda con el botón de guardar, como el nombre y el avatar: es un campo
  /// de la etiqueta y no una decisión que haga desaparecer contenido. Al
  /// guardarla cambia de lista, y la pantalla se encuentra sin la que estaba
  /// elegida y pasa a la primera, que es lo que ya hace al borrarla.
  late bool _isPerson = widget.tag.isPerson;

  /// A cuántos contenidos afecta la marca, cuando se acaba de tocar.
  /// Las etiquetas relacionadas, tal y como se están editando.
  ///
  /// Se guardan en el momento de tocarlas y no con el botón de guardar: son una
  /// relación entre dos etiquetas, no un campo de ésta, y la otra tiene que
  /// enterarse aunque esta ficha se cierre sin guardar.
  late List<TagEntity> _siblings = widget.tag.siblings;


  /// La etiqueta y todo lo que cuelga de ella, por identificador.
  late final Set<int> _ownBranch = _branchIds(widget.tag);

  /// Hay una escritura en marcha (guardar, borrar o copiar el avatar elegido).
  ///
  /// Mientras la haya, la ficha espera con su indicador y sus botones quedan
  /// desactivados: son operaciones sobre la misma etiqueta, así que no tiene
  /// sentido lanzar dos a la vez.
  bool _isBusy = false;

  /// Lanza [operation] dejando la ficha en espera mientras dure.
  Future<void> _run(Future<void> Function() operation) async {
    if (_isBusy) return;

    setState(() => _isBusy = true);
    try {
      await operation();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Set<int> _branchIds(TagEntity tag) => {
        tag.id,
        for (final child in tag.children) ..._branchIds(child),
      };

  /// Búsqueda del buscador de etiqueta padre.
  ///
  /// Ni la propia etiqueta ni sus descendientes se sugieren: colgar de sí misma o
  /// de una de sus hijas (o de la hija de su hija) sería un círculo, y el árbol de
  /// etiquetas se quedaría sin raíz por la que empezar.
  Future<List<TagEntity>> _searchParentTags(String query) async {
    final result = await _searchTags(params: query);
    if (result is! DataSuccess) return const [];

    final tags = result.data ?? const <TagEntity>[];
    return tags.where((tag) => !_ownBranch.contains(tag.id)).toList();
  }

  /// Elige la imagen del avatar y se queda con la copia que guarda la
  /// aplicación, como en el diálogo de creación: los avatares se cargan siempre
  /// de la carpeta de avatares.
  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image);

    final path = result?.files.single.path;
    if (path == null) return;

    // La copia a la carpeta de avatares sí puede tardar, así que se hace con la
    // ficha en espera. El explorador de ficheros no: allí el tiempo lo pone el
    // usuario.
    await _run(() async {
      final storedPath = await _storeAvatar(params: path);
      if (!mounted) return;

      setState(() => _picturePath = storedPath);
    });
  }

  /// Escribe los datos nuevos de la etiqueta.
  ///
  /// El identificador no cambia, así que los contenidos que la tienen la siguen
  /// teniendo. Manda lo que dice el formulario: con el campo de la etiqueta padre
  /// vacío, la etiqueta se queda **sin padre**, aunque tuviera uno al entrar.
  ///
  /// Al terminar se releen las etiquetas (el nombre y el avatar salen en el menú
  /// lateral y en la lista de al lado) y se vuelve a pedir el contenido de la
  /// etiqueta, que es lo que enseña la rejilla de debajo.
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final result = await _updateTag(
      params: UpdateTagParams(
        tag: TagEntity(
          id: widget.tag.id,
          name: name,
          picturePath: _picturePath,
          children: widget.tag.children,
          isPerson: _isPerson,
        ),
        parent: _parent,
      ),
    );
    if (!mounted) return;

    // El nombre ya lo tiene otra. Se dice y no se guarda nada: el formulario se
    // queda con lo escrito, que es lo que hace falta para corregirlo.
    if (result.exception is DuplicateTagNameException) {
      showFernToast(context, AppLocalizations.of(context).tagNameTaken);
      return;
    }

    if (result is! DataSuccess) return;

    getIt<TagsBloc>().add(const LoadTagsEvent());
    context.read<MediaBloc>().add(LoadMediaByTagEvent(widget.tag.id));
  }

  /// Marca o desmarca la etiqueta, y dice a cuánto afecta.
  ///
  /// Con el bloqueo cerrado, marcarla hace que la ficha y su contenido
  /// desaparezcan de la pantalla en cuanto se relea: por eso el número se
  /// enseña aquí y ahora, que es el único momento en el que se puede leer.
  Future<void> _setNsfw(bool value) async {
    final texts = AppLocalizations.of(context);

    final result = await _setTagNsfw(
      params: SetTagNsfwParams(tagId: widget.tag.id, isNsfw: value),
    );

    if (result is! DataSuccess<int> || !mounted) return;

    setState(() => _isNsfw = value);

    // Cuánto contenido acaba de esconderse, dicho al pulsar y no como texto fijo
    // en la ficha: es la respuesta a lo que se acaba de hacer, y sólo hace falta
    // ese momento. Con el filtro puesto, además, ese contenido desaparece de la
    // rejilla de abajo, y sin decir cuánto era parecería que se ha perdido.
    showFernToast(
      context,
      texts.tagNsfwAffected(result.data ?? 0),
      icon: value ? Symbols.visibility_off : Symbols.visibility,
    );

    getIt<TagsBloc>().add(const LoadTagsEvent());
    getIt<MediaBloc>().add(const ReloadCurrentMediaEvent());
  }

  /// Escribe las direcciones de la etiqueta y se queda con las normalizadas.
  ///
  /// Son las que se van a comparar al importar, así que la ficha enseña lo que de
  /// verdad hay guardado y no lo que se escribió.
  Future<void> _saveUrls(List<FernLink> urls) async {
    final result = await _saveTagSourceUrls(
      params: SaveTagSourceUrlsParams(
        tagId: widget.tag.id,
        urls: [for (final link in urls) link.url],
        nsfwUrls: [
          for (final link in urls)
            if (link.isNsfw) link.url,
        ],
      ),
    );

    final tag = result.data;
    if (result is! DataSuccess || tag == null || !mounted) return;

    setState(() {
      _sourceUrls = [
        for (final url in tag.sourceUrls)
          FernLink(url, isNsfw: tag.marksLink(url)),
      ];
    });
  }

  /// Abre el diálogo de las direcciones de la etiqueta y guarda lo que se
  /// confirme.
  ///
  /// Aquí la etiqueta ya existe, así que se escribe en el momento y no espera al
  /// botón de guardar de la ficha: el diálogo tiene el suyo, y lo que se confirma
  /// en él queda confirmado. Al cerrarlo sin confirmar no llega nada y las
  /// direcciones se quedan como estaban.
  Future<void> _assignUrls() async {
    final urls = await showFernDialog<List<FernLink>, MediaBloc>(
      context: context,
      builder: (_) => AssignUrlDialog(
        urls: _sourceUrls,
        name: widget.tag.name,
        canMarkNsfw: getIt<NsfwModeService>().isConfigured,
        hidesMarked: getIt<NsfwVisibility>().hidesMarkedLinks,
      ),
    );
    if (urls == null || !mounted) return;

    await _run(() async {
      await _saveUrls(urls);
      if (!mounted) return;

      // La lista de la ficha se quedó con las direcciones que recibió al nacer,
      // así que para que recoja lo que acaba de confirmar el diálogo hay que
      // hacerla nacer otra vez.
      setState(() => _urlsRevision++);
    });
  }


  /// Borra la etiqueta de la base de datos.
  ///
  /// Los contenidos que la tenían no se borran: la pierden y se quedan con las
  /// demás. Al releer las etiquetas, la pantalla se encuentra sin la que estaba
  /// elegida y pasa a la primera de la lista, así que la rejilla se rehace sola.
  Future<void> _delete() async {
    final result = await _deleteTag(params: widget.tag.id);
    if (result is! DataSuccess) return;

    getIt<TagsBloc>().add(const LoadTagsEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final name = _nameController.text.trim();

    // El fondo claro de los diálogos: la ficha es la superficie de la pantalla, y
    // lo que lleva dentro es un formulario como el del diálogo de creación.
    //
    // Mientras se está escribiendo en la base de datos, el indicador de espera se
    // pone sobre toda la ficha: lo que hay en ella es justo lo que va a cambiar.
    return FernBusyOverlay(
      isBusy: _isBusy,
      color: context.colors.white,
      child: FernSurface(
        color: context.colors.white,
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En la esquina superior derecha, como en el diálogo de creación: es
            // la misma acción y se busca en el mismo sitio.
            // Arriba a la derecha, junto a las direcciones: son las dos
            // acciones que no editan la etiqueta. Reconocer estaba abajo con las
            // demás, pero eran cuatro píldoras contadas y la quinta pasaba la
            // fila a dos líneas, con lo que la ficha ya no cabía en la pantalla.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _personButton(texts),
                _nsfwButton(texts),
                _relationsButton(texts),
                _recognizeButton(texts),
                _assignUrlsButton(texts),
              ],
            ),
            // Con el alto que le den: la ficha lo tiene fijo (lo pone la
            // pantalla) y este bloque es el que se queda con lo que sobre.
            Expanded(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FernDialogSidePanel(
                    // Sin nombre se enseña el de la etiqueta en tono apagado: el
                    // campo está vacío, pero la etiqueta sigue llamándose así.
                    title: name.isEmpty ? widget.tag.name : name,
                    titleColor: name.isEmpty ? context.colors.unremarked : null,
                    // Más pequeño que el del diálogo: la ficha comparte el alto de
                    // la pantalla con la rejilla, y el avatar es lo que más ocupa.
                    avatar: FernEditableAvatar(
                      imagePath: _picturePath,
                      fallbackIcon: Symbols.label,
                      radius: AppSizes.avatarXLarge,
                      iconSize: AppSizes.iconHuge,
                      onTap: _pickImage,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FernLabeledTextField(
                        label: texts.tagNameLabel,
                        hintText: texts.enterNameHint,
                        controller: _nameController,
                        // El título de la izquierda sigue al nombre en cada
                        // pulsación, como en el diálogo de creación.
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      // De quién cuelga y con quién va, en una línea: el detalle
                      // se ve y se cambia en su árbol. Los dos buscadores y la
                      // lista de relacionadas ocupaban tanto aquí que la rejilla
                      // de contenido de debajo se salía de la pantalla.
                      _relationsSummary(texts),
                      const SizedBox(height: AppSpacing.m),
                      Expanded(child: _sourceUrlsField(texts)),
                    ],
                  ),
                ),
              ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            // Los botones se reparten en varias líneas si no caben: son cuatro y
            // sus textos crecen bastante según el idioma.
            //
            // Los cuatro son el mismo botón, así que miden lo mismo y forman una
            // fila pareja; lo que los distingue es el color: el rosa borra, el
            // lavanda fuerte guarda y los claros son los dos cambios que no tocan a
            // la etiqueta en sí. Por eso guardar lleva icono: aquí no es el botón de
            // confirmación de un diálogo, es uno más de la fila.
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.s,
              children: [
                FernPillButton(
                  label: texts.actionDeleteTag,
                  icon: Symbols.delete,
                  backgroundColor: context.colors.error,
                  foregroundColor: Colors.white,
                  onPressed: _isBusy ? null : () => _run(_delete),
                ),
                _unassignButton(texts),
                FernPillButton(
                  label: texts.actionSave,
                  icon: Symbols.check,
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.black,
                  // Con el padre en error no se guarda: guardar a medias —el
                  // nombre sí, el padre no— es lo que hacía que el fallo pasara
                  // desapercibido.
                  onPressed: _isBusy
                      ? null
                      : () => _run(_save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Abre el diálogo que vincula direcciones con la etiqueta.
  ///
  /// Cambia de icono cuando ya hay alguna: es la única señal de que la etiqueta
  /// etiqueta sola, porque las direcciones no se ven en el formulario.
  /// El interruptor de NSFW, hecho un icono más de la fila de arriba.
  ///
  /// Era un bloque con título, descripción y recuento, y ocupaba tanto que la
  /// rejilla de contenido de debajo se salía de la pantalla. Aquí no añade una
  /// sola línea de alto: reaprovecha la fila que ya estaba, y lo que hay que
  /// saber —cuánto contenido afecta— se dice al pulsarlo, que es cuando importa,
  /// y no permanentemente.
  ///
  /// Sólo con contraseña puesta. Sin ella, marcar no escondería nada (ver
  /// `NsfwVisibility`) y el botón prometería algo que no va a pasar.
  Widget _nsfwButton(AppLocalizations texts) {
    if (!getIt<NsfwModeService>().isConfigured) return const SizedBox.shrink();

    return IconButton(
      icon: Icon(
        _isNsfw ? Symbols.visibility_off : Symbols.visibility_off,
        size: AppSizes.iconCardAction,
        // Encendido, con el color con el que la aplicación marca lo que hay que
        // mirar dos veces. Apagado se queda como los demás iconos de la fila.
        color: _isNsfw ? context.colors.terciary : null,
      ),
      tooltip: _isNsfw ? texts.tagNsfwOnTooltip : texts.tagNsfwOffTooltip,
      onPressed: _isBusy ? null : () => _run(() => _setNsfw(!_isNsfw)),
    );
  }

  /// El interruptor de «esta etiqueta es una persona».
  ///
  /// Es lo que hace usable la separación el primer día: todo lo que ya hay en la
  /// base está mezclado, y sin esto habría que borrar cada persona y volver a
  /// crearla —perdiendo de paso su contenido, sus direcciones y sus relaciones—.
  ///
  /// Sale siempre, también sin contraseña puesta: no esconde nada, sólo dice en
  /// qué lista se gestiona.
  Widget _personButton(AppLocalizations texts) {
    return IconButton(
      icon: Icon(
        Symbols.face,
        size: AppSizes.iconCardAction,
        color: _isPerson ? context.colors.terciary : null,
      ),
      tooltip: texts.tagIsPerson,
      onPressed:
          _isBusy ? null : () => setState(() => _isPerson = !_isPerson),
    );
  }

  Widget _assignUrlsButton(AppLocalizations texts) {
    return IconButton(
      icon: Icon(
        _sourceUrls.isEmpty ? Symbols.add_link : Symbols.link,
        size: AppSizes.iconCardAction,
      ),
      tooltip: texts.assignUrlsTooltip,
      onPressed: _isBusy ? null : _assignUrls,
    );
  }

  /// Las direcciones vinculadas con la etiqueta, a la vista.
  ///
  /// Es la misma lista que los enlaces de redes sociales de la ficha del
  /// creador. Antes no se veían: la ficha sólo tenía el botón que abría el
  /// diálogo, y ni siquiera llegaban hasta aquí, así que guardar el nombre de la
  /// etiqueta las borraba.
  ///
  /// Con el hueco que quede y no con un alto propio: la ficha lo tiene fijo (lo
  /// pone la pantalla), así que este bloque es el que se estira o se encoge y lo
  /// que no quepa se desplaza aquí dentro. Con un máximo, la ficha crecería
  /// dirección a dirección y no todas las etiquetas tendrían la misma.
  ///
  /// Se guarda en cuanto se termina cada dirección, no con el botón de guardar
  /// de la ficha: las direcciones tienen su propia escritura
  /// (`SaveTagSourceUrlsUseCase`), igual que las hermanas y la marca NSFW, y
  /// `updateTag` ya no las toca.
  Widget _sourceUrlsField(AppLocalizations texts) {
    return FernLinkListField(
      // Se rehace cuando el diálogo trae direcciones nuevas, no al escribir.
      key: ValueKey(_urlsRevision),
      links: _sourceUrls,
      onChanged: (urls) => setState(() => _sourceUrls = urls),
      canMarkNsfw: getIt<NsfwModeService>().isConfigured,
      hidesMarked: getIt<NsfwVisibility>().hidesMarkedLinks,
      markNsfwTooltip: texts.markLinkNsfwTooltip,
      unmarkNsfwTooltip: texts.unmarkLinkNsfwTooltip,
      // Sin el indicador de espera de la ficha: es una escritura corta y se
      // dispara al salir de cada campo, así que tapar la ficha entera cada vez
      // parpadearía. Y sin pasar por `_run`, que descarta lo que llegue mientras
      // haya otra escritura en marcha —y aquí eso sería perder la dirección.
      onCommitted: _saveUrls,
      label: texts.sourceUrlsLabel,
      emptyMessage: texts.noSourceUrls,
      hintText: texts.sourceUrlHint,
      addLabel: texts.addSourceUrl,
      openTooltip: texts.openSourceUrlTooltip,
      editTooltip: texts.editSourceUrlTooltip,
      removeTooltip: texts.removeSourceUrlTooltip,
      doneTooltip: texts.doneEditingSourceUrlTooltip,
      fills: true,
    );
  }

  /// Buscador de la etiqueta padre, con la que ya tiene escrita.
  ///
  /// Vaciar el campo es soltarla: la etiqueta se queda como raíz al guardar.
  /// De quién cuelga y con cuántas va, en una línea.
  ///
  /// Sólo el resumen: la forma que tienen las relaciones se ve en su árbol, y
  /// repetirla aquí devolvería a la ficha el sitio que se le acaba de quitar.
  Widget _relationsSummary(AppLocalizations texts) {
    final parent = _parent;

    return Row(
      children: [
        Icon(
          Symbols.account_tree,
          size: AppSizes.iconSmall,
          color: context.colors.unremarked,
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            [
              if (parent == null)
                texts.tagRelationsNoParent
              else
                texts.tagRelationsParentIs(parent.name),
              if (_siblings.isNotEmpty)
                texts.tagRelationsSiblingCount(_siblings.length),
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.gray),
          ),
        ),
      ],
    );
  }

  /// Abre el árbol de relaciones.
  Widget _relationsButton(AppLocalizations texts) {
    return IconButton(
      icon: const Icon(
        Symbols.account_tree,
        size: AppSizes.iconCardAction,
      ),
      tooltip: texts.tagRelationsTooltip,
      onPressed: _isBusy ? null : _editRelations,
    );
  }

  /// Enseña el árbol y aplica lo que se decida en él.
  ///
  /// **Se guarda todo al cerrar la ventana**, la madre incluida. Antes la madre
  /// se quedaba pendiente del botón de guardar de la ficha: se movía la etiqueta
  /// en el árbol, se cerraba, y el árbol seguía igual hasta pulsar guardar aquí
  /// — que no es lo que espera quien acaba de moverla.
  ///
  /// Se guarda [widget.tag] y no lo que haya en el formulario: esta ventana es
  /// de la jerarquía, así que un nombre o un avatar a medio escribir siguen
  /// pendientes, como estaban.
  Future<void> _editRelations() async {
    final result = await showFernDialog<TagRelations, Never>(
      context: context,
      builder: (_) => TagRelationsDialog(
        tag: widget.tag,
        parent: _parent,
        siblings: _siblings,
        searchParents: _searchParentTags,
        searchSiblings: _searchSiblings,
        createTag: () => showFernDialog<TagEntity, Never>(
          context: context,
          builder: (_) => const FernCreateDialog.tag(),
        ),
      ),
    );

    if (result == null || !mounted) return;

    final parentChanged = result.parent?.id != _parent?.id;
    setState(() => _parent = result.parent);

    // Quiénes son y qué dirección tiene cada una: cambiar sólo la dirección es
    // un cambio, y comparando nada más las listas se habría perdido.
    final before = {
      for (final one in _siblings)
        one.id: siblingDirectionBetween(tag: widget.tag, sibling: one),
    };
    final after = {
      for (final one in result.siblings) one.id: result.directionOf(one.id),
    };
    final siblingsChanged = !mapEquals(before, after);

    if (!parentChanged && !siblingsChanged) return;

    await _run(() async {
      if (parentChanged) await _saveParent(result.parent);
      if (siblingsChanged) await _saveSiblings(result.siblings, after);
    });
  }

  /// Guarda de quién cuelga la etiqueta.
  ///
  /// Va aparte de [_save] porque no guarda el formulario: sólo mueve la etiqueta
  /// de sitio en el árbol, con todo lo demás como estaba.
  Future<void> _saveParent(TagEntity? parent) async {
    final result = await _updateTag(
      params: UpdateTagParams(tag: widget.tag, parent: parent),
    );

    if (result is! DataSuccess || !mounted) return;

    // El árbol cambia en el menú lateral y en la lista de al lado.
    getIt<TagsBloc>().add(const LoadTagsEvent());
  }



  /// Las candidatas a hermana: ni ella misma, ni su rama, ni las que ya lo son.
  ///
  /// Su rama fuera porque madres e hijas ya están relacionadas por la jerarquía:
  /// añadirlas además como hermanas no cambiaría nada y haría dudar de si son
  /// dos cosas distintas.
  Future<List<TagEntity>> _searchSiblings(String query) async {
    final result = await _searchTags(params: query);
    if (result is! DataSuccess) return const [];

    final already = {for (final sibling in _siblings) sibling.id};

    return [
      for (final tag in result.data ?? const <TagEntity>[])
        if (!_ownBranch.contains(tag.id) && !already.contains(tag.id)) tag,
    ];
  }



  /// Guarda la lista y rehace el campo de búsqueda para que se vacíe.
  Future<void> _saveSiblings(
    List<TagEntity> siblings,
    Map<int, SiblingDirection> directions,
  ) async {
    final result = await _saveTagSiblings(
      params: SaveTagSiblingsParams(
        tagId: widget.tag.id,
        siblings: directions,
      ),
    );

    if (result is! DataSuccess<TagEntity> || !mounted) return;

    setState(() {
      _siblings = result.data?.siblings ?? siblings;
    });

    // El menú lateral no cambia —las hermanas no salen ahí— pero la ficha de la
    // otra etiqueta sí: acaba de ganar o perder una relación.
    getIt<TagsBloc>().add(const LoadTagsEvent());
  }




  /// Manda a reconocer todo el contenido de esta etiqueta.
  ///
  /// Es el cuarto punto de entrada del D16, y el único que no parte de una
  /// selección: aquí la lista sale de la base de datos. Va por el mismo sitio
  /// que los otros tres, que es quien mira si hay con qué reconocer y lo
  /// cuenta.
  Widget _recognizeButton(AppLocalizations texts) {
    return IconButton(
      icon: const Icon(
        Symbols.auto_awesome,
        size: AppSizes.iconCardAction,
      ),
      tooltip: texts.recognizeTagTooltip,
      onPressed: _isBusy ? null : _recognizeAll,
    );
  }

  Future<void> _recognizeAll() async {
    final found = await getIt<GetMediaByTagUseCase>()(params: widget.tag.id);
    if (!mounted) return;

    await requestRecognition(
      context,
      found is DataSuccess ? [for (final one in found.data ?? const []) one.id] : const [],
      name: widget.tag.name,
    );
  }

  /// Le quita la etiqueta a lo que esté seleccionado en la rejilla. Sin nada
  /// seleccionado no hay a quién quitársela, así que queda atenuado.
  Widget _unassignButton(AppLocalizations texts) {
    return BlocSelector<MediaBloc, MediaStates, bool>(
      selector: (state) => state.selectedIds.isNotEmpty,
      builder: (context, hasSelection) => FernPillButton(
        label: texts.actionUnassignTag,
        icon: Symbols.label_off,
        backgroundColor: context.colors.secondary,
        foregroundColor: context.colors.black,
        onPressed: hasSelection
            ? () => context
                .read<MediaBloc>()
                .add(RemoveTagFromSelectedMediaEvent(widget.tag.id))
            : null,
      ),
    );
  }
}
