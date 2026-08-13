import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/delete_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/features/media/domain/usecases/update_tag_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  final _avatarStorage = getIt<AvatarStorageService>();

  late final TextEditingController _nameController =
      TextEditingController(text: widget.tag.name);

  late String? _picturePath = widget.tag.picturePath;
  late TagEntity? _parent = widget.parent;

  /// Lo que hay escrito en el buscador de etiqueta padre.
  ///
  /// Se guarda aparte de [_parent] porque lo que manda al guardar es el campo: si
  /// está vacío, la etiqueta se queda sin padre, aunque tuviera uno al entrar.
  late String _parentQuery = widget.parent?.name ?? '';

  /// Clave del buscador de etiqueta padre. Cambiarla lo hace nacer de nuevo, que
  /// es la forma de vaciarlo desde fuera: el texto escrito lo lleva el propio
  /// campo, y arranca con el valor que se le pasa.
  Key _parentFieldKey = UniqueKey();

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
      final storedPath = await _avatarStorage.store(path);
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

    final parent = _parentQuery.trim().isEmpty ? null : _parent;

    final result = await _updateTag(
      params: UpdateTagParams(
        tag: TagEntity(
          id: widget.tag.id,
          name: name,
          picturePath: _picturePath,
          children: widget.tag.children,
        ),
        parent: parent,
      ),
    );
    if (result is! DataSuccess || !mounted) return;

    getIt<TagsBloc>().add(const LoadTagsEvent());
    context.read<MediaBloc>().add(LoadMediaByTagEvent(widget.tag.id));
  }

  /// Suelta la etiqueta de su padre: deja de estar entre las hijas de aquél.
  ///
  /// Aquí sólo se vacía el buscador de etiqueta padre. El cambio se escribe al
  /// guardar, que es cuando el campo vacío se manda como «sin padre»: es entonces
  /// cuando la etiqueta pasa a verse como raíz en la lista de al lado y en el
  /// menú lateral.
  void _removeParent() {
    setState(() {
      _parent = null;
      _parentQuery = '';
      _parentFieldKey = UniqueKey();
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
      color: AppColors.white,
      child: FernSurface(
        color: AppColors.white,
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FernDialogSidePanel(
                    // Sin nombre se enseña el de la etiqueta en tono apagado: el
                    // campo está vacío, pero la etiqueta sigue llamándose así.
                    title: name.isEmpty ? widget.tag.name : name,
                    titleColor: name.isEmpty ? AppColors.unremarked : null,
                    // Más pequeño que el del diálogo: la ficha comparte el alto de
                    // la pantalla con la rejilla, y el avatar es lo que más ocupa.
                    avatar: FernEditableAvatar(
                      imagePath: _picturePath,
                      fallbackIcon: Icons.label_outline,
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
                      _parentTagField(texts),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
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
                  icon: Icons.delete_outline,
                  backgroundColor: AppColors.terciary,
                  foregroundColor: AppColors.white,
                  onPressed: _isBusy ? null : () => _run(_delete),
                ),
                _removeParentButton(texts),
                _unassignButton(texts),
                FernPillButton(
                  label: texts.actionSave,
                  icon: Icons.check,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black,
                  onPressed: _isBusy ? null : () => _run(_save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Buscador de la etiqueta padre, con la que ya tiene escrita.
  ///
  /// Vaciar el campo es soltarla: la etiqueta se queda como raíz al guardar.
  Widget _parentTagField(AppLocalizations texts) {
    return FernEntitySearchField<TagEntity>(
      key: _parentFieldKey,
      label: texts.parentTagLabel,
      hintText: texts.searchEllipsisHint,
      initialValue: _parentQuery,
      search: _searchParentTags,
      labelOf: (tag) => tag.name,
      onSelected: (tag) => setState(() => _parent = tag),
      // Con `setState` para que el botón de quitar el padre siga al campo: sin
      // nada escrito no hay padre del que soltarse.
      onChanged: (query) => setState(() => _parentQuery = query),
      debounce: searchDebounceDuration,
    );
  }

  /// Suelta la etiqueta de su padre. Sin padre escrito no hay de quién soltarla,
  /// así que queda atenuado.
  Widget _removeParentButton(AppLocalizations texts) {
    return FernPillButton(
      label: texts.actionRemoveParentTag,
      icon: Icons.link_off,
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.black,
      onPressed: _parentQuery.trim().isEmpty ? null : _removeParent,
    );
  }

  /// Le quita la etiqueta a lo que esté seleccionado en la rejilla. Sin nada
  /// seleccionado no hay a quién quitársela, así que queda atenuado.
  Widget _unassignButton(AppLocalizations texts) {
    return BlocSelector<MediaBloc, MediaStates, bool>(
      selector: (state) => state.selectedIds.isNotEmpty,
      builder: (context, hasSelection) => FernPillButton(
        label: texts.actionUnassignTag,
        icon: Icons.label_off_outlined,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.black,
        onPressed: hasSelection
            ? () => context
                .read<MediaBloc>()
                .add(RemoveTagFromSelectedMediaEvent(widget.tag.id))
            : null,
      ),
    );
  }
}
