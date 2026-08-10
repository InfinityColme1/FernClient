import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/search_tags_usecase.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Las dos variantes del diálogo de creación. El panel izquierdo es el mismo
/// (avatar editable y nombre); lo que cambia es el formulario de la derecha,
/// y [secondaryLabel] nombra ese segundo bloque en cada caso.
enum CreateDialogType {
  tag(
    title: "New Tag",
    nameLabel: "Tag Name",
    secondaryLabel: "Parent tag (Optional)",
    icon: Icons.label_outline,
  ),
  creator(
    title: "New Creator",
    nameLabel: "Creator Name",
    secondaryLabel: "Social profiles",
    icon: Icons.person_outline,
  );

  const CreateDialogType({
    required this.title,
    required this.nameLabel,
    required this.secondaryLabel,
    required this.icon,
  });

  final String title;
  final String nameLabel;
  final String secondaryLabel;
  final IconData icon;
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
/// No depende de ningún bloc: guarda con los casos de uso, así que se puede
/// abrir desde cualquier pantalla.
class FernCreateDialog extends StatefulWidget {
  final CreateDialogType type;

  const FernCreateDialog.tag({super.key}) : type = CreateDialogType.tag;

  const FernCreateDialog.creator({super.key})
      : type = CreateDialogType.creator;

  @override
  State<FernCreateDialog> createState() => _FernCreateDialogState();
}

class _FernCreateDialogState extends State<FernCreateDialog> {
  final _searchTags = getIt<SearchTagsUseCase>();
  final _saveTag = getIt<SaveTagUseCase>();
  final _saveCreator = getIt<SaveCreatorUseCase>();

  final TextEditingController _nameController = TextEditingController();

  /// Un campo por enlace de red social. Siempre hay al menos uno.
  final List<TextEditingController> _socialControllers = [
    TextEditingController(),
  ];

  String? _selectedImagePath;
  TagEntity? _parentTag;

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (!mounted) return;

    final path = result?.files.single.path;
    if (path != null) {
      setState(() => _selectedImagePath = path);
    }
  }

  Future<List<TagEntity>> _searchParentTags(String query) async {
    final result = await _searchTags(params: query);
    if (result is! DataSuccess) return const [];

    return result.data ?? const [];
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
  Future<void> _confirm() async {
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
            ),
            parent: _parentTag,
          ),
        );

        final tag = result.data;
        if (!mounted || result is! DataSuccess || tag == null) return;

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

        final creator = result.data;
        if (!mounted || result is! DataSuccess || creator == null) return;

        navigator.pop(creator);
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
    final name = _nameController.text.trim();

    return FernDialog(
      onClose: () => context.pop(),
      leftContent: FernDialogSidePanel(
        // Mientras no haya nombre se enseña el título de la variante, en tono
        // apagado para que se lea como un hueco por rellenar.
        title: name.isEmpty ? widget.type.title : name,
        titleColor: name.isEmpty ? AppColors.unremarked : null,
        avatar: FernEditableAvatar(
          imagePath: _selectedImagePath,
          fallbackIcon: widget.type.icon,
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
            label: widget.type.nameLabel,
            hintText: "Enter name",
            controller: _nameController,
            // El panel de la izquierda sigue al nombre en cada pulsación.
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          switch (widget.type) {
            CreateDialogType.tag => _parentTagField(),
            CreateDialogType.creator => _socialProfilesField(),
          },
        ],
      ),
      actionButton: FernConfirmButton(icon: null, onPressed: _confirm),
    );
  }

  /// Buscador de la etiqueta padre, para armar la jerarquía de etiquetas.
  Widget _parentTagField() {
    return FernEntitySearchField<TagEntity>(
      label: widget.type.secondaryLabel,
      hintText: "Search...",
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.type.secondaryLabel,
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
              decoration: const InputDecoration(hintText: "Profile link"),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        FernInlineAddButton(
          label: "Add profile",
          onTap: _addSocialField,
        ),
      ],
    );
  }
}
