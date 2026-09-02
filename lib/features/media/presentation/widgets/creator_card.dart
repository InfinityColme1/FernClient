import 'dart:async';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/app_exceptions.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/usecases/delete_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_media_by_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_source_urls_usecase.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/get_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_tags_usecase.dart';
import 'package:Fern/features/media/presentation/widgets/assign_creator_tags_dialog.dart';
import 'package:Fern/features/media/domain/usecases/set_creator_nsfw_usecase.dart';
import 'package:Fern/features/media/domain/usecases/update_creator_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/creators_bloc.dart';
import 'package:Fern/features/recognition/presentation/recognition_feedback.dart';
import 'package:Fern/features/media/presentation/blocs/creators_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/assign_url_dialog.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:Fern/features/media/presentation/widgets/avatar_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ficha del creador elegido en la pantalla de gestión de creadores.
///
/// Es la hermana de `TagCard`: avatar editable con el nombre debajo, campo del
/// nombre y la misma fila de botones (borrar, quitárselo a lo seleccionado en la
/// rejilla y guardar), sobre una superficie en vez de en un diálogo y con los
/// valores que ya tiene el creador: escribir encima de ellos es editarlo.
///
/// Lo que cambia respecto a la de etiquetas es el segundo bloque del formulario:
/// un creador no cuelga de otro, así que en lugar del buscador de etiqueta padre
/// se enseñan sus enlaces de redes sociales (los que se le pusieron al crearlo) y
/// pulsando uno se abre en el navegador del sistema.
///
/// Necesita un `MediaBloc` por encima: es de donde sale la selección de la
/// rejilla y a quien se le pide que deshaga la asignación.
class CreatorCard extends StatefulWidget {
  final CreatorEntity creator;

  const CreatorCard({super.key, required this.creator});

  @override
  State<CreatorCard> createState() => _CreatorCardState();
}

class _CreatorCardState extends State<CreatorCard> {
  final _updateCreator = getIt<UpdateCreatorUseCase>();
  final _deleteCreator = getIt<DeleteCreatorUseCase>();
  final _saveCreatorSourceUrls = getIt<SaveCreatorSourceUrlsUseCase>();
  final _saveCreatorTags = getIt<SaveCreatorTagsUseCase>();
  final _getCreator = getIt<GetCreatorUseCase>();
  final _setCreatorNsfw = getIt<SetCreatorNsfwUseCase>();

  late final TextEditingController _nameController =
      TextEditingController(text: widget.creator.name);

  late String? _picturePath = widget.creator.picturePath;

  /// Los enlaces de redes sociales, tal y como se están editando.
  ///
  /// Se escriben con el resto del formulario, al guardar: como el nombre, no
  /// como las direcciones vinculadas (que tienen su propio diálogo y se guardan
  /// solas). La lista de enlaces avisa en cada cambio y esto se queda con lo
  /// último.
  late List<FernLink> _socialProfiles = [
    for (final link in widget.creator.socialProfiles ?? const <String>[])
      FernLink(link, isNsfw: widget.creator.nsfwSocialProfiles.contains(link)),
  ];

  /// Direcciones de las que sale el contenido del creador.
  ///
  /// Se guardan desde su propio diálogo, así que aquí sólo se llevan para saber
  /// con cuáles abrirlo y para no perderlas al guardar el formulario.
  late List<FernLink> _sourceUrls = [
    for (final url in widget.creator.sourceUrls)
      FernLink(url, isNsfw: widget.creator.nsfwSourceUrls.contains(url)),
  ];

  /// Las etiquetas que el creador trae consigo.
  ///
  /// Como las direcciones: se guardan desde su propio diálogo, así que aquí sólo
  /// se llevan para saber con cuáles abrirlo y para que el botón sepa si ya hay
  /// alguna.
  ///
  /// Se piden aparte porque la lista de creadores no las trae: cargarlas allí
  /// sería una consulta por fila para pintar algo que la lista no enseña. Hasta
  /// que llegan, el botón sale como si no hubiera ninguna —que es lo cierto
  /// mientras no se sepa— y se corrige solo al llegar.
  List<TagEntity> _tags = const [];

  /// El creador está marcado como contenido no apto.
  ///
  /// Se guarda al tocar el interruptor y no con el botón de guardar: es una
  /// decisión que hace desaparecer contenido, y dejarla a medias —marcada en
  /// pantalla, sin marcar en la base— sería la peor forma de contarlo.
  late bool _isNsfw = widget.creator.isNsfw;

  @override
  void initState() {
    super.initState();
    unawaited(_loadTags());
  }

  @override
  void didUpdateWidget(CreatorCard old) {
    super.didUpdateWidget(old);

    // Al cambiar de fila la ficha es la misma con otro creador dentro: sin esto
    // se quedaría enseñando las etiquetas del anterior.
    if (old.creator.id != widget.creator.id) {
      setState(() => _tags = const []);
      unawaited(_loadTags());
    }
  }

  Future<void> _loadTags() async {
    final result = await _getCreator(params: widget.creator.id);

    final creator = result.data;
    if (result is! DataSuccess || creator == null || !mounted) return;

    setState(() => _tags = creator.tags);
  }

  /// El creador desconocido no se borra: es el respaldo al que van a parar los
  /// contenidos cuando se borra otro, así que sin él no habría dónde dejarlos.
  bool get _isUnknown => widget.creator.name == unknownCreator.name;

  /// Hay una escritura en marcha (guardar, borrar o copiar el avatar elegido).
  ///
  /// Mientras la haya, la ficha espera con su indicador y sus botones quedan
  /// desactivados: son operaciones sobre el mismo creador, así que no tiene
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

  /// Elige el avatar: de dónde sale la imagen, cuál, y qué trozo de ella.
  ///
  /// El explorador de ficheros era la única respuesta a la primera pregunta, y
  /// obligaba a buscar por el disco una imagen que la aplicación ya tiene
  /// guardada y sabe enseñar.
  Future<void> _pickImage() async {
    final choice = await chooseAvatarImage(context);
    if (choice == null || !mounted) return;

    // Guardar sí puede tardar, así que se hace con la ficha en espera. Elegir
    // no: allí el tiempo lo pone el usuario.
    await _run(() async {
      final storedPath = await storeChosenAvatar(choice, replacing: _picturePath);
      if (!mounted) return;

      setState(() => _picturePath = storedPath);
    });
  }

  /// Escribe los datos nuevos del creador.
  ///
  /// El identificador no cambia, así que los contenidos que lo tienen lo siguen
  /// teniendo. Al terminar se releen los creadores (el nombre y el avatar salen
  /// en la lista de al lado) y se vuelve a pedir su contenido, que es lo que
  /// enseña la rejilla de debajo.
  ///
  /// El nombre no puede ser el de otro creador: si lo es no se guarda nada y se
  /// avisa, como en el diálogo de creación.
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Sin ninguno se manda `null` y no una lista vacía: es como se guardan los
    // creadores que se crean sin enlaces.
    final links = [for (final link in _socialProfiles) link.url];

    final result = await _updateCreator(
      params: CreatorEntity(
        id: widget.creator.id,
        name: name,
        picturePath: _picturePath,
        socialProfiles: links.isEmpty ? null : links,
        nsfwSocialProfiles: [
          for (final link in _socialProfiles)
            if (link.isNsfw) link.url,
        ],
        sourceUrls: [for (final link in _sourceUrls) link.url],
        nsfwSourceUrls: [
          for (final link in _sourceUrls)
            if (link.isNsfw) link.url,
        ],
      ),
    );
    if (!mounted) return;

    // Con el nombre cogido por otro creador no se ha guardado nada: se avisa y
    // la ficha se queda como estaba, para poder cambiarlo sin perder el resto.
    if (result.exception is DuplicateCreatorNameException) {
      showFernToast(
        context,
        AppLocalizations.of(context).creatorNameTaken,
        icon: Symbols.error,
      );
      return;
    }

    if (result is! DataSuccess) return;

    getIt<CreatorsBloc>().add(const LoadCreatorsEvent());
    context.read<MediaBloc>().add(LoadMediaByCreatorEvent(widget.creator.id));
  }

  /// Abre el diálogo de las direcciones del creador y guarda lo que se confirme.
  ///
  /// Aquí el creador ya existe, así que se escribe en el momento y no espera al
  /// botón de guardar de la ficha: el diálogo tiene el suyo, y lo que se confirma
  /// en él queda confirmado. Al cerrarlo sin confirmar no llega nada y las
  /// direcciones se quedan como estaban.
  Future<void> _assignUrls() async {
    final urls = await showFernDialog<List<FernLink>, MediaBloc>(
      context: context,
      builder: (_) => AssignUrlDialog(
        urls: _sourceUrls,
        name: widget.creator.name,
        target: AssignUrlTarget.creator,
        canMarkNsfw: getIt<NsfwModeService>().isConfigured,
        hidesMarked: getIt<NsfwVisibility>().hidesMarkedLinks,
      ),
    );
    if (urls == null || !mounted) return;

    await _run(() async {
      final result = await _saveCreatorSourceUrls(
        params: SaveCreatorSourceUrlsParams(
          creatorId: widget.creator.id,
          urls: [for (final link in urls) link.url],
          nsfwUrls: [
            for (final link in urls)
              if (link.isNsfw) link.url,
          ],
        ),
      );

      final creator = result.data;
      if (result is! DataSuccess || creator == null || !mounted) return;

      // Se recogen ya normalizadas: son las que se van a comparar al importar, y
      // así el diálogo se vuelve a abrir con lo que de verdad hay guardado.
      setState(() {
        _sourceUrls = [
          for (final url in creator.sourceUrls)
            FernLink(url, isNsfw: creator.nsfwSourceUrls.contains(url)),
        ];
      });
    });
  }

  /// Borra el creador de la base de datos.
  ///
  /// Los contenidos que lo tenían no se borran: pasan al creador desconocido. Al
  /// releer los creadores, la pantalla se encuentra sin el que estaba elegido y
  /// pasa al primero de la lista, así que la rejilla se rehace sola.
  Future<void> _delete() async {
    final result = await _deleteCreator(params: widget.creator.id);
    if (result is! DataSuccess) return;

    getIt<CreatorsBloc>().add(const LoadCreatorsEvent());
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
            // Arriba a la derecha, como en la ficha de etiqueta: son las dos
            // acciones que no editan al creador. Reconocer estaba abajo con las
            // demás, pero eran cuatro píldoras contadas y la quinta pasaba la
            // fila a dos líneas, con lo que la ficha ya no cabía en la pantalla.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _nsfwButton(texts),
                _recognizeButton(texts),
                _creatorTagsButton(texts),
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
                    // Sin nombre se enseña el del creador en tono apagado: el
                    // campo está vacío, pero el creador sigue llamándose así.
                    title: name.isEmpty ? widget.creator.name : name,
                    titleColor: name.isEmpty ? context.colors.unremarked : null,
                    // Más pequeño que el del diálogo: la ficha comparte el alto de
                    // la pantalla con la rejilla, y el avatar es lo que más ocupa.
                    avatar: FernEditableAvatar(
                      imagePath: _picturePath,
                      fallbackIcon: Symbols.person,
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
                        label: texts.creatorNameLabel,
                        hintText: texts.enterNameHint,
                        controller: _nameController,
                        // El título de la izquierda sigue al nombre en cada
                        // pulsación, como en el diálogo de creación.
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Expanded(child: _socialProfilesField(texts)),
                    ],
                  ),
                ),
              ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            // Los botones se reparten en varias líneas si no caben: sus textos
            // crecen bastante según el idioma.
            //
            // Los tres son el mismo botón, así que miden lo mismo y forman una
            // fila pareja; lo que los distingue es el color: el rosa borra, el
            // lavanda fuerte guarda y el claro es el cambio que no toca al creador
            // en sí. Por eso guardar lleva icono: aquí no es el botón de
            // confirmación de un diálogo, es uno más de la fila.
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.s,
              children: [
                FernPillButton(
                  label: texts.actionDeleteCreator,
                  icon: Symbols.delete,
                  backgroundColor: context.colors.error,
                  foregroundColor: Colors.white,
                  onPressed: _isBusy || _isUnknown ? null : () => _run(_delete),
                ),
                _unassignButton(texts),
                FernPillButton(
                  label: texts.actionSave,
                  icon: Symbols.check,
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.black,
                  onPressed: _isBusy ? null : () => _run(_save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Abre el diálogo de las etiquetas que el creador trae consigo.
  ///
  /// Como el de las direcciones: el creador ya existe, así que lo que se
  /// confirma se escribe en el momento y no espera al botón de guardar de la
  /// ficha. Cerrarlo sin confirmar deja las etiquetas como estaban.
  ///
  /// **No reetiqueta nada de lo que ya hay.** Lo que se deja aquí vale para lo
  /// siguiente que se le ponga este creador: relacionar una etiqueta con un
  /// creador de cuatrocientos contenidos no puede etiquetar cuatrocientos
  /// contenidos sin decir nada.
  Future<void> _assignTags() async {
    final tags = await showFernDialog<List<TagEntity>, MediaBloc>(
      context: context,
      builder: (_) => AssignCreatorTagsDialog(
        tags: _tags,
        name: widget.creator.name,
      ),
    );
    if (tags == null || !mounted) return;

    await _run(() async {
      final result = await _saveCreatorTags(
        params: SaveCreatorTagsParams(
          creatorId: widget.creator.id,
          tagIds: [for (final tag in tags) tag.id],
        ),
      );

      final creator = result.data;
      if (result is! DataSuccess || creator == null || !mounted) return;

      setState(() => _tags = creator.tags);
    });
  }

  /// El botón que las abre.
  ///
  /// Cambia de icono cuando ya hay alguna, como el de las direcciones: es la
  /// única señal de que este creador etiqueta solo, porque sus etiquetas no
  /// salen en el formulario.
  Widget _creatorTagsButton(AppLocalizations texts) {
    return IconButton(
      icon: Icon(
        _tags.isEmpty ? Symbols.new_label : Symbols.label,
        size: AppSizes.iconCardAction,
      ),
      tooltip: texts.creatorTagsTooltip,
      onPressed: _isBusy ? null : _assignTags,
    );
  }

  /// Abre el diálogo que vincula direcciones con el creador.
  ///
  /// Cambia de icono cuando ya hay alguna: es la única señal de que el creador se
  /// asigna solo, porque las direcciones no se ven en el formulario.
  Widget _assignUrlsButton(AppLocalizations texts) {
    return IconButton(
      icon: Icon(
        _sourceUrls.isEmpty ? Symbols.add_link : Symbols.link,
        size: AppSizes.iconCardAction,
      ),
      tooltip: texts.assignUrlsCreatorTooltip,
      onPressed: _isBusy ? null : _assignUrls,
    );
  }

  /// Marca o desmarca al creador, y dice a cuánto afecta.
  ///
  /// Con el bloqueo cerrado, marcarlo hace que la ficha y su contenido
  /// desaparezcan de la pantalla en cuanto se relea: por eso el número se
  /// enseña aquí y ahora, que es el único momento en el que se puede leer.
  Future<void> _setNsfw(bool value) async {
    final texts = AppLocalizations.of(context);

    final result = await _setCreatorNsfw(
      params: SetCreatorNsfwParams(
        creatorId: widget.creator.id,
        isNsfw: value,
      ),
    );

    if (result is! DataSuccess<int> || !mounted) return;

    setState(() => _isNsfw = value);

    showFernToast(
      context,
      texts.creatorNsfwAffected(result.data ?? 0),
      icon: value ? Symbols.visibility_off : Symbols.visibility,
    );

    getIt<CreatorsBloc>().add(const LoadCreatorsEvent());
    getIt<MediaBloc>().add(const ReloadCurrentMediaEvent());
  }

  /// El interruptor de NSFW, hecho un icono más de la fila de arriba, como en la
  /// ficha de etiqueta.
  ///
  /// Sólo con contraseña puesta: sin ella, marcar no escondería nada y el botón
  /// prometería algo que no va a pasar.
  ///
  /// Y nunca para el desconocido: es el respaldo al que van a parar los
  /// contenidos que se quedan sin creador, así que esconderlo escondería media
  /// biblioteca de una pulsación.
  Widget _nsfwButton(AppLocalizations texts) {
    if (_isUnknown || !getIt<NsfwModeService>().isConfigured) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Icon(
        Symbols.visibility_off,
        size: AppSizes.iconCardAction,
        color: _isNsfw ? context.colors.terciary : null,
      ),
      tooltip: _isNsfw ? texts.creatorNsfwOnTooltip : texts.creatorNsfwOffTooltip,
      onPressed: _isBusy ? null : () => _run(() => _setNsfw(!_isNsfw)),
    );
  }

  /// Los enlaces de redes sociales del creador.
  ///
  /// La lista es la del catálogo, la misma que las direcciones vinculadas de la
  /// etiqueta: pulsar un enlace lo abre en el navegador, el botón de al lado lo
  /// pasa a editar y el aspa lo quita. Lo que se escriba se guarda con el resto
  /// del formulario, al pulsar «Guardar»: hasta entonces la ficha no ha tocado
  /// nada.
  ///
  /// Con el hueco que quede y no con un alto propio: la ficha lo tiene fijo, así
  /// que este bloque es el que se estira o se encoge y lo que no quepa se
  /// desplaza aquí dentro. Con un máximo, la ficha crecería enlace a enlace y no
  /// todos los creadores tendrían la misma.
  Widget _socialProfilesField(AppLocalizations texts) {
    return FernLinkListField(
      links: [
        for (final link in widget.creator.socialProfiles ?? const <String>[])
          FernLink(
            link,
            isNsfw: widget.creator.nsfwSocialProfiles.contains(link),
          ),
      ],
      onChanged: (links) => _socialProfiles = links,
      canMarkNsfw: getIt<NsfwModeService>().isConfigured,
      hidesMarked: getIt<NsfwVisibility>().hidesMarkedLinks,
      markNsfwTooltip: texts.markLinkNsfwTooltip,
      unmarkNsfwTooltip: texts.unmarkLinkNsfwTooltip,
      label: texts.socialProfilesLabel,
      emptyMessage: texts.noSocialProfiles,
      hintText: texts.profileLinkHint,
      addLabel: texts.addProfile,
      openTooltip: texts.openProfileTooltip,
      editTooltip: texts.editProfileTooltip,
      removeTooltip: texts.removeProfileTooltip,
      doneTooltip: texts.doneEditingProfileTooltip,
      fills: true,
    );
  }

  /// Le quita el creador a lo que esté seleccionado en la rejilla (pasa al
  /// desconocido). Sin nada seleccionado no hay a quién quitárselo, así que queda
  /// atenuado.
  /// Manda a reconocer todo el contenido de este creador.
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
      tooltip: texts.recognizeCreatorTooltip,
      onPressed: _isBusy ? null : _recognizeAll,
    );
  }

  Future<void> _recognizeAll() async {
    final found =
        await getIt<GetMediaByCreatorUseCase>()(params: widget.creator.id);
    if (!mounted) return;

    await requestRecognition(
      context,
      found is DataSuccess
          ? [for (final one in found.data ?? const []) one.id]
          : const [],
      name: widget.creator.name,
    );
  }

  Widget _unassignButton(AppLocalizations texts) {
    return BlocSelector<MediaBloc, MediaStates, bool>(
      selector: (state) => state.selectedIds.isNotEmpty,
      builder: (context, hasSelection) => FernPillButton(
        label: texts.actionUnassignCreator,
        icon: Symbols.person_remove,
        backgroundColor: context.colors.secondary,
        foregroundColor: context.colors.black,
        onPressed: hasSelection && !_isUnknown
            ? () => context
                .read<MediaBloc>()
                .add(RemoveCreatorFromSelectedMediaEvent(widget.creator.id))
            : null,
      ),
    );
  }
}
