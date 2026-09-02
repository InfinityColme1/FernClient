import 'dart:async';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/services/recent_picks.dart';
import 'package:Fern/features/media/domain/usecases/search_creators_usecase.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../blocs/media_bloc.dart';
import '../blocs/media_events.dart';
import 'fern_create_dialog.dart';

/// Le pone el mismo creador a toda la selección.
///
/// Cien imágenes del mismo artista se abrían de una en una para escribir cien
/// veces el mismo nombre. Es el mismo diálogo que el de un contenido suelto
/// —buscar, elegir, confirmar— con la selección en lugar de la imagen.
///
/// **Pisa el creador que hubiera**, y a propósito: quien marca cien contenidos y
/// elige un creador está diciendo de quién son. Lo automático, que sí respeta lo
/// que ya está puesto, va por otro camino.
///
/// Con el creador entran sus etiquetas, como al ponerlo de uno en uno: eso lo
/// resuelve el repositorio, y por eso este diálogo no tiene que saber nada de
/// ellas.
class AssignCreatorToSelectionDialog extends StatefulWidget {
  /// Cuántos contenidos van a recibirlo. Se enseña porque es lo único que
  /// distingue esto de asignarle el creador a uno: sin el número, confirmar es
  /// a ciegas.
  final int count;

  /// Creador ya elegido y sin confirmar. Sirve para reabrir el diálogo sin
  /// perder lo elegido, al volver de crear un creador.
  final CreatorEntity? pendingCreator;

  const AssignCreatorToSelectionDialog({
    super.key,
    required this.count,
    this.pendingCreator,
  });

  @override
  State<AssignCreatorToSelectionDialog> createState() =>
      _AssignCreatorToSelectionDialogState();
}

class _AssignCreatorToSelectionDialogState
    extends State<AssignCreatorToSelectionDialog> {
  final _searchCreators = getIt<SearchCreatorsUseCase>();
  final _recents = getIt<RecentPicks>();

  late CreatorEntity? _pendingCreator = widget.pendingCreator;

  Future<List<CreatorEntity>> _search(String query) async {
    final result = await _searchCreators(params: query);
    if (result is! DataSuccess) return const [];

    return result.data ?? const [];
  }

  void _confirm(BuildContext context) {
    final creator = _pendingCreator;
    if (creator != null) {
      unawaited(_recents.pushCreator(creator.id));
      context
          .read<MediaBloc>()
          .add(SetSelectedMediaCreatorEvent(creator.id));
    }

    context.pop();
  }

  /// Cede el sitio al diálogo de creación y vuelve aquí al cerrarse: marcando
  /// una tanda es justo cuando se descubre que el artista todavía no existe.
  ///
  /// Sin imagen de referencia, al revés que desde el visor: aquí hay cien
  /// contenidos delante y elegir cuál de ellos le pone la cara al creador es
  /// una decisión que este diálogo no puede tomar por nadie.
  Future<void> _openCreateCreatorDialog(BuildContext context) async {
    final bloc = context.read<MediaBloc>();
    final count = widget.count;
    final pending = _pendingCreator;

    // Este diálogo desaparece al abrir el de creación, así que para volver hace
    // falta el contexto del navegador, que sigue en pie.
    final navigatorContext = Navigator.of(context).context;

    final created = await replaceFernDialog<CreatorEntity, MediaBloc>(
      context: context,
      bloc: bloc,
      builder: (_) => const FernCreateDialog.creator(),
    );

    if (!navigatorContext.mounted) return;

    showFernDialog(
      context: navigatorContext,
      bloc: bloc,
      builder: (_) => AssignCreatorToSelectionDialog(
        count: count,
        pendingCreator: created ?? pending,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final creator = _pendingCreator;

    return FernDialog(
      onClose: () => context.pop(),
      leftContent: FernDialogSidePanel(
        // Sin nadie elegido, el título dice a cuántos va: es lo que se está
        // haciendo mientras no haya creador que enseñar.
        title: creator?.name ?? texts.selectedCount(widget.count),
        titleColor: creator == null ? context.colors.unremarked : null,
        avatar: FernAvatar(
          imagePath: creator?.picturePath,
          fallbackIcon: Symbols.person,
          radius: AppSizes.avatarHuge,
          backgroundColor: creator == null
              ? context.colors.lightgray
              : context.colors.secondary,
          iconColor:
              creator == null ? context.colors.gray : context.colors.primary,
        ),
      ),
      rightContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.assignCreatorToSelectionHint(widget.count),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.gray),
          ),
          const SizedBox(height: AppSpacing.l),
          FernEntitySearchField<CreatorEntity>(
            label: texts.searchCreatorLabel,
            hintText: texts.creatorSearchHint,
            search: _search,
            recents: _recents.creators,
            labelOf: (creator) => creator.name,
            // Los marcados se distinguen al autocompletar, como las etiquetas:
            // elegir uno sin saberlo esconde contenido sin querer, y aquí de
            // golpe toda la selección.
            trailingOf: (creator) =>
                creator.isNsfw ? const NsfwTagMark() : null,
            onSelected: (creator) => setState(() => _pendingCreator = creator),
            debounce: searchDebounceDuration,
          ),
          const SizedBox(height: AppSpacing.xl),
          FernAddButton(
            radius: AppSizes.addButtonRadius,
            label: texts.createCreator,
            onTap: () => _openCreateCreatorDialog(context),
          ),
        ],
      ),
      actionButton: FernConfirmButton(onPressed: () => _confirm(context)),
    );
  }
}
