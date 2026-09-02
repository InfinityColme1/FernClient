import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'dart:async';

import 'package:Fern/features/media/domain/services/recent_picks.dart';
import 'package:Fern/features/media/presentation/widgets/creator_tags.dart';
import 'package:Fern/features/media/domain/usecases/search_creators_usecase.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/media_bloc.dart';
import '../blocs/media_events.dart';
import 'fern_create_dialog.dart';

/// Diálogo para asignar un creador al contenido.
///
/// Lo que se escribe en el buscador se consulta en la base de datos y se
/// sugieren como mucho [searchSuggestionsLimit] creadores. El elegido se
/// enseña en el panel izquierdo en tono apagado: hasta que no se pulse
/// "Confirm" no se relaciona con el contenido.
class AssignCreatorDialog extends StatefulWidget {
  final MediaEntity media;

  /// Creador ya elegido y sin confirmar. Sirve para reabrir el diálogo sin
  /// perder lo elegido, por ejemplo al volver de crear un creador.
  final CreatorEntity? pendingCreator;

  const AssignCreatorDialog({
    super.key,
    required this.media,
    this.pendingCreator,
  });

  @override
  State<AssignCreatorDialog> createState() => _AssignCreatorDialogState();
}

class _AssignCreatorDialogState extends State<AssignCreatorDialog> {
  final _searchCreators = getIt<SearchCreatorsUseCase>();
  final _recents = getIt<RecentPicks>();

  /// Creador elegido y todavía sin confirmar.
  late CreatorEntity? _pendingCreator = widget.pendingCreator;

  Future<List<CreatorEntity>> _search(String query) async {
    final result = await _searchCreators(params: query);
    if (result is! DataSuccess) return const [];

    return result.data ?? const [];
  }

  /// Deja el creador elegido en el panel, con lo que el creador trae consigo.
  ///
  /// **Las etiquetas se proponen aquí y no al guardar**, por lo mismo que las
  /// madres y las hermanas al elegir una etiqueta: guardar desde el panel
  /// escribe la lista tal cual se deja, así que lo que este diálogo no proponga
  /// no se pone nunca. Y proponer es proponer: se ven en el panel y se quitan
  /// como cualquier otra antes de guardar.
  ///
  /// Se manda **sólo lo que hay que sumar**: el panel lo junta con lo que tenga
  /// en ese momento. Mandando el contenido entero se devolvía la foto de cuando
  /// se abrió el diálogo, y con ella se perdía todo lo que se hubiera tocado
  /// mientras.
  Future<void> _confirm(BuildContext context) async {
    final creator = _pendingCreator;
    if (creator == null) {
      context.pop();
      return;
    }

    // Al confirmar y no al elegir: mientras el diálogo esté abierto todavía no
    // se le ha puesto a nadie, y cerrarlo sin confirmar no es haberlo usado.
    unawaited(_recents.pushCreator(creator.id));

    final bloc = context.read<MediaBloc>();
    final brings = await tagsOfCreator(creator);

    if (!context.mounted) return;

    bloc.add(MediaCreatorAssignedEvent(creator, brings: brings));

    context.pop();
  }



  /// Cede el sitio al diálogo de creación y, al cerrarse éste, vuelve aquí: si
  /// se ha creado un creador llega ya elegido, y si no se mantiene el que
  /// hubiera.
  Future<void> _openCreateCreatorDialog(BuildContext context) async {
    final bloc = context.read<MediaBloc>();
    final media = widget.media;
    final pending = _pendingCreator;

    // Este diálogo desaparece al abrir el de creación, así que para volver hace
    // falta el contexto del navegador, que sigue en pie.
    final navigatorContext = Navigator.of(context).context;

    final created = await replaceFernDialog<CreatorEntity, MediaBloc>(
      context: context,
      bloc: bloc,
      // Con el contenido que se está viendo delante, igual que al crear una
      // etiqueta desde aquí: el creador se da de alta mirando algo suyo, y
      // ofrecerlo como avatar ahorra ir a buscarlo al explorador.
      builder: (_) => FernCreateDialog.creator(currentMediaPath: media.path),
    );

    if (!navigatorContext.mounted) return;

    showFernDialog(
      context: navigatorContext,
      bloc: bloc,
      builder: (_) => AssignCreatorDialog(
        media: media,
        pendingCreator: created ?? pending,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final creator = _pendingCreator ?? widget.media.creator;
    final isPending = _pendingCreator != null;

    return FernDialog(
      onClose: () => context.pop(),
      leftContent: FernDialogSidePanel(
        title: creator.name,
        titleColor: isPending ? context.colors.unremarked : null,
        avatar: FernAvatar(
          imagePath: creator.picturePath,
          fallbackIcon: Symbols.person,
          radius: AppSizes.avatarHuge,
          backgroundColor:
              isPending ? context.colors.lightgray : context.colors.secondary,
          iconColor: isPending ? context.colors.gray : context.colors.primary,
        ),
      ),
      rightContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FernEntitySearchField<CreatorEntity>(
            label: texts.searchCreatorLabel,
            hintText: texts.creatorSearchHint,
            search: _search,
            recents: _recents.creators,
            labelOf: (creator) => creator.name,
            // Los marcados se distinguen al autocompletar, como las etiquetas:
            // elegir uno sin saberlo es esconder contenido sin querer.
            trailingOf: (creator) =>
                creator.isNsfw ? const NsfwTagMark() : null,
            onSelected: (creator) =>
                setState(() => _pendingCreator = creator),
            debounce: searchDebounceDuration,
          ),
          const SizedBox(height: AppSpacing.xl),
          FernAddButton(
            // Aquí el botón va suelto bajo un buscador, no en una fila de
            // avatares: se queda con el círculo pequeño.
            radius: AppSizes.addButtonRadius,
            label: texts.createCreator,
            onTap: () => _openCreateCreatorDialog(context),
          ),
        ],
      ),
      actionButton: FernConfirmButton(
        onPressed: () => unawaited(_confirm(context)),
      ),
    );
  }
}
