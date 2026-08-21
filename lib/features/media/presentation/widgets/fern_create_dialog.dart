import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/app_exceptions.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/creators_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/creators_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/media/presentation/widgets/assign_url_dialog.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/save_fernie_usecase.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/save_model_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_events.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Las variantes del diálogo de creación. El panel izquierdo es el mismo
/// (avatar editable y nombre); lo que cambia es el formulario de la derecha,
/// y [secondaryLabel] nombra ese segundo bloque en cada caso.
///
/// El fernie no tiene segundo bloque: se crea con nombre y avatar, y a qué se
/// enlaza se decide luego en su ficha. Aquí sólo estorbaría, porque lo normal
/// es crearlo al vuelo mientras se está marcando una región.
enum CreateDialogType {
  tag(icon: Icons.label_outline),
  creator(icon: Icons.person_outline),
  fernie(icon: Icons.face_retouching_natural, iconAsset: icFernie),
  model(icon: Icons.hub_outlined);

  const CreateDialogType({required this.icon, this.iconAsset});

  final IconData icon;

  /// Icono en forma de imagen, para la variante que no tiene glifo propio.
  final String? iconAsset;

  String title(AppLocalizations texts) => switch (this) {
        CreateDialogType.tag => texts.newTagTitle,
        CreateDialogType.creator => texts.newCreatorTitle,
        CreateDialogType.fernie => texts.newFernieTitle,
        CreateDialogType.model => texts.newModelTitle,
      };

  String nameLabel(AppLocalizations texts) => switch (this) {
        CreateDialogType.tag => texts.tagNameLabel,
        CreateDialogType.creator => texts.creatorNameLabel,
        CreateDialogType.fernie => texts.fernieNameLabel,
        CreateDialogType.model => texts.modelNameLabel,
      };

  String secondaryLabel(AppLocalizations texts) => switch (this) {
        CreateDialogType.tag => texts.parentTagLabel,
        CreateDialogType.creator => texts.socialProfilesLabel,
        CreateDialogType.fernie => '',
        CreateDialogType.model => texts.modelFunctionLabel,
      };
}

/// Diálogo para crear una etiqueta o un creador y guardarlo en la base de
/// datos.
///
/// El avatar de la izquierda es editable y alimenta el `picturePath` del
/// modelo; el texto que hay debajo va siguiendo lo que se escribe en el campo
/// del nombre.
///
/// Al confirmar guarda y se cierra devolviendo lo guardado, ya con su
/// identificador: una `TagEntity` en la variante [FernCreateDialog.tag] y una
/// `CreatorEntity` en la variante [FernCreateDialog.creator]. Si se cierra sin
/// crear nada, devuelve `null`. Así quien lo abre puede seguir trabajando con
/// la entidad nueva:
///
/// ```dart
/// final tag = await showFernDialog<TagEntity>(
///   context: context,
///   builder: (_) => const FernCreateDialog.tag(),
/// );
/// ```
///
/// No necesita que nadie le provea un bloc: guarda con los casos de uso, así que
/// se puede abrir desde cualquier pantalla. Lo que crea sí lo avisa a los blocs
/// únicos que lo listan: al `TagsBloc` para que el menú lateral enseñe la
/// etiqueta nueva y al `CreatorsBloc` para que la pantalla de gestión enseñe el
/// creador nuevo.
class FernCreateDialog extends StatefulWidget {
  final CreateDialogType type;

  const FernCreateDialog.tag({super.key}) : type = CreateDialogType.tag;

  const FernCreateDialog.creator({super.key})
      : type = CreateDialogType.creator;

  const FernCreateDialog.fernie({super.key}) : type = CreateDialogType.fernie;

  const FernCreateDialog.model({super.key}) : type = CreateDialogType.model;

  @override
  State<FernCreateDialog> createState() => _FernCreateDialogState();
}

class _FernCreateDialogState extends State<FernCreateDialog> {
  final _searchTags = getIt<SearchTagsUseCase>();
  final _saveTag = getIt<SaveTagUseCase>();
  final _saveCreator = getIt<SaveCreatorUseCase>();
  final _saveFernie = getIt<SaveFernieUseCase>();
  final _saveModel = getIt<SaveModelUseCase>();

  /// Qué pregunta va a responder el modelo. De fábrica, la más simple: los dos
  /// son detección, y quien no sepa cuál quiere casi siempre quiere saber si
  /// algo está o no está.
  ModelFunction _function = ModelFunction.boolean;
  final _avatarStorage = getIt<AvatarStorageService>();

  final TextEditingController _nameController = TextEditingController();

  /// Un campo por enlace de red social. Siempre hay al menos uno.
  final List<TextEditingController> _socialControllers = [
    TextEditingController(),
  ];

  String? _selectedImagePath;
  TagEntity? _parentTag;

  /// Direcciones vinculadas a la etiqueta que se está creando.
  ///
  /// Se quedan aquí hasta que se confirma: la etiqueta todavía no existe, así
  /// que no hay a qué engancharlas. Se guardan con ella de una vez.
  List<String> _sourceUrls = const [];

  /// Hay una escritura en marcha: la de guardar o la de copiar el avatar
  /// elegido. El botón de confirmar pasa a ser el indicador de espera y no admite
  /// una segunda pulsación: sería crear la misma etiqueta (o el mismo creador)
  /// dos veces.
  bool _isBusy = false;

  /// Lanza [operation] dejando el diálogo en espera mientras dure.
  Future<void> _run(Future<void> Function() operation) async {
    if (_isBusy) return;

    setState(() => _isBusy = true);
    try {
      await operation();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Elige la imagen del avatar y se queda con la copia que guarda la
  /// aplicación: los avatares se cargan siempre de la carpeta de avatares, no
  /// de donde el usuario tuviera la imagen.
  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image);

    final path = result?.files.single.path;
    if (path == null) return;

    // La copia a la carpeta de avatares puede tardar, así que se hace con el
    // diálogo en espera. El explorador de ficheros no: allí el tiempo lo pone el
    // usuario.
    await _run(() async {
      final storedPath = await _avatarStorage.store(path);
      if (!mounted) return;

      setState(() => _selectedImagePath = storedPath);
    });
  }

  Future<List<TagEntity>> _searchParentTags(String query) async {
    final result = await _searchTags(params: query);
    if (result is! DataSuccess) return const [];

    return result.data ?? const [];
  }

  /// Abre el diálogo de las direcciones de la etiqueta, encima de este.
  ///
  /// Al cerrarlo se vuelve aquí con lo escrito tal y como estaba: el diálogo de
  /// creación no se ha ido a ninguna parte, sólo tenía otro delante. Si se cierra
  /// sin confirmar no llega nada y las direcciones se quedan como estuvieran.
  Future<void> _assignUrls() async {
    final urls = await showFernDialog<List<String>, TagsBloc>(
      context: context,
      builder: (_) => AssignUrlDialog(
        urls: _sourceUrls,
        name: _nameController.text.trim(),
      ),
    );
    if (urls == null || !mounted) return;

    setState(() => _sourceUrls = urls);
  }

  void _addSocialField() {
    setState(() => _socialControllers.add(TextEditingController()));
  }

  /// Enlaces escritos, sin los campos que se han quedado vacíos.
  List<String> get _socialProfiles => _socialControllers
      .map((controller) => controller.text.trim())
      .where((link) => link.isNotEmpty)
      .toList();

  /// Guarda en la base de datos y, si sale bien, cierra el diálogo devolviendo
  /// lo guardado. Si falla, el diálogo se queda abierto para no perder lo
  /// escrito.
  Future<void> _confirm() => _run(_save);

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // El navegador se toma antes de la espera: al volver, este widget puede
    // haber desaparecido junto con su contexto.
    final navigator = Navigator.of(context);

    switch (widget.type) {
      case CreateDialogType.tag:
        final result = await _saveTag(
          params: SaveTagParams(
            tag: TagEntity(
              id: unsavedId,
              name: name,
              picturePath: _selectedImagePath,
              children: const [],
              sourceUrls: _sourceUrls,
            ),
            parent: _parentTag,
          ),
        );

        final tag = result.data;
        if (!mounted || result is! DataSuccess || tag == null) return;

        // La etiqueta nueva tiene que salir en el menú lateral sin tener que
        // reiniciar: es el único sitio donde se crean, así que el aviso va aquí.
        getIt<TagsBloc>().add(const LoadTagsEvent());

        navigator.pop(tag);

      case CreateDialogType.creator:
        final links = _socialProfiles;

        final result = await _saveCreator(
          params: CreatorEntity(
            id: unsavedId,
            name: name,
            picturePath: _selectedImagePath,
            socialProfiles: links.isEmpty ? null : links,
          ),
        );
        if (!mounted) return;

        // Con el nombre cogido no se ha creado nada: el diálogo se queda abierto
        // con todo lo escrito, que lo único que hay que cambiar es el nombre.
        if (result.exception is DuplicateCreatorNameException) {
          showFernToast(
            context,
            AppLocalizations.of(context).creatorNameTaken,
            icon: Icons.error_outline,
          );
          return;
        }

        final creator = result.data;
        if (result is! DataSuccess || creator == null) return;

        // El creador nuevo tiene que salir en la pantalla de gestión sin tener
        // que reiniciar, igual que la etiqueta en el menú lateral.
        getIt<CreatorsBloc>().add(const LoadCreatorsEvent());

        navigator.pop(creator);

      case CreateDialogType.fernie:
        final result = await _saveFernie(
          params: FernieEntity(id: unsavedId, name: name, picturePath: _selectedImagePath),
        );

        final fernie = result.data;
        if (!mounted || result is! DataSuccess || fernie == null) return;

        // El fernie nuevo tiene que salir en su pantalla y en el buscador del
        // menú de asignación sin tener que reiniciar.
        getIt<FerniesBloc>().add(const LoadFerniesEvent());

        navigator.pop(fernie);

      case CreateDialogType.model:
        final result = await _saveModel(
          params: RecognitionModelEntity(
            id: unsavedId,
            name: name,
            picturePath: _selectedImagePath,
            function: _function,
            createdAt: DateTime.now(),
          ),
        );

        final model = result.data;
        if (!mounted || result is! DataSuccess || model == null) return;

        // El modelo nuevo tiene que salir en su rejilla sin tener que reiniciar.
        getIt<ModelsBloc>().add(const LoadModelsEvent());

        navigator.pop(model);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _socialControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final name = _nameController.text.trim();

    return FernDialog(
      onClose: () => context.pop(),
      // Sólo las etiquetas se vinculan con direcciones: un creador se relaciona
      // con el contenido de otra manera.
      trailingAction: widget.type == CreateDialogType.tag
          ? _assignUrlsButton(texts)
          : null,
      leftContent: FernDialogSidePanel(
        // Mientras no haya nombre se enseña el título de la variante, en tono
        // apagado para que se lea como un hueco por rellenar.
        title: name.isEmpty ? widget.type.title(texts) : name,
        titleColor: name.isEmpty ? context.colors.unremarked : null,
        avatar: FernEditableAvatar(
          imagePath: _selectedImagePath,
          fallbackIcon: widget.type.icon,
          fallbackAsset: widget.type.iconAsset,
          radius: AppSizes.avatarHuge,
          iconSize: AppSizes.iconHuge,
          onTap: _pickImage,
        ),
      ),
      rightContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FernLabeledTextField(
            label: widget.type.nameLabel(texts),
            hintText: texts.enterNameHint,
            controller: _nameController,
            // El panel de la izquierda sigue al nombre en cada pulsación.
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          switch (widget.type) {
            CreateDialogType.tag => _parentTagField(),
            CreateDialogType.creator => _socialProfilesField(),
            // Un fernie nace sin nada más: sin regiones, que se le marcan desde
            // el visor, y sin enlace, que se le pone en su ficha.
            CreateDialogType.fernie => _fernieHint(texts),
            CreateDialogType.model => _functionField(texts),
          },
        ],
      ),
      actionButton: FernConfirmButton(
        icon: null,
        isBusy: _isBusy,
        onPressed: _confirm,
      ),
    );
  }

  /// Abre el diálogo que vincula direcciones con la etiqueta.
  ///
  /// Se marca cuando ya hay alguna escrita: es la única señal de que la etiqueta
  /// va a etiquetar sola, porque las direcciones no se ven en este formulario.
  Widget _assignUrlsButton(AppLocalizations texts) {
    final hasUrls = _sourceUrls.isNotEmpty;

    return IconButton(
      icon: Icon(
        hasUrls ? Icons.link : Icons.add_link,
        size: AppSizes.iconExtraLarge,
      ),
      tooltip: texts.assignUrlsTooltip,
      onPressed: _isBusy ? null : _assignUrls,
    );
  }

  /// Qué pregunta va a responder el modelo.
  ///
  /// Se elige al crearlo porque cambia con qué se entrena, no sólo cómo se lee
  /// la salida; y se puede cambiar luego en su ficha, avisando de que hay que
  /// volver a entrenar.
  Widget _functionField(AppLocalizations texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.type.secondaryLabel(texts),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.s),
        for (final function in ModelFunction.values)
          FernRadioTile<ModelFunction>(
            value: function,
            groupValue: _function,
            label: switch (function) {
              ModelFunction.boolean => texts.modelFunctionBoolean,
              ModelFunction.classification => texts.modelFunctionClassification,
            },
            description: switch (function) {
              ModelFunction.boolean => texts.modelFunctionBooleanDescription,
              ModelFunction.classification =>
                texts.modelFunctionClassificationDescription,
            },
            onChanged: _isBusy
                ? null
                : (value) => setState(() => _function = value),
          ),
      ],
    );
  }

  /// Lo que le falta a un fernie recién creado.
  ///
  /// Se dice porque el diálogo se queda muy vacío y, sin explicación, un fernie
  /// sin regiones parece algo a medio hacer en lugar de un contenedor esperando
  /// a que le marquen contenido.
  Widget _fernieHint(AppLocalizations texts) {
    return Text(
      texts.fernieNoRegions,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: context.colors.unremarked),
    );
  }

  /// Buscador de la etiqueta padre, para armar la jerarquía de etiquetas.
  Widget _parentTagField() {
    final texts = AppLocalizations.of(context);

    return FernEntitySearchField<TagEntity>(
      label: widget.type.secondaryLabel(texts),
      hintText: texts.searchEllipsisHint,
      search: _searchParentTags,
      labelOf: (tag) => tag.name,
      onSelected: (tag) => setState(() => _parentTag = tag),
      debounce: searchDebounceDuration,
    );
  }

  /// Enlaces de redes sociales: un campo por enlace, desplazables, y debajo un
  /// botón pequeño para añadir uno más.
  Widget _socialProfilesField() {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.type.secondaryLabel(texts),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: createDialogSocialFieldsMaxHeight,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _socialControllers.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (_, index) => TextField(
              controller: _socialControllers[index],
              keyboardType: TextInputType.url,
              decoration: InputDecoration(hintText: texts.profileLinkHint),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        FernAddButton.compact(
          label: texts.addProfile,
          onTap: _addSocialField,
        ),
      ],
    );
  }
}
