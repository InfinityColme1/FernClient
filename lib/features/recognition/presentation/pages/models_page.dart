import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/widgets/fern_create_dialog.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_states.dart';
import 'package:Fern/features/recognition/presentation/widgets/fernie_confirm_dialog.dart';
import 'package:Fern/features/recognition/presentation/widgets/model_card.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Los modelos de reconocimiento, en rejilla.
///
/// Un modelo es un nombre, una cara, una pregunta y un puñado de fernies con los
/// que aprender a responderla. Aquí se crean y se ve de un vistazo cuáles
/// sirven ya para algo; lo que se hace con cada uno está en su pantalla.
class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  final _bloc = getIt<ModelsBloc>();

  @override
  void initState() {
    super.initState();

    // Se relee siempre, no sólo la primera vez: los recuentos que enseña cada
    // tarjeta salen de las regiones de sus fernies, y ésas se marcan en otra
    // pantalla.
    _bloc.add(const LoadModelsEvent());
  }

  Future<void> _create() async {
    await showFernDialog<void, ModelsBloc>(
      context: context,
      builder: (_) => const FernCreateDialog.model(),
    );
  }

  /// Borra un modelo, preguntando antes.
  ///
  /// Se pregunta porque no hay vuelta atrás y porque lo que se pierde no es
  /// obvio: los fernies se quedan donde estaban, lo que desaparece es lo que el
  /// modelo había aprendido de ellos.
  Future<void> _delete(RecognitionModelEntity model) async {
    final texts = AppLocalizations.of(context);

    final confirmed = await showFernDialog<bool, ModelsBloc>(
      context: context,
      builder: (_) => FernieConfirmDialog(
        title: texts.modelDeleteTitle,
        message: texts.modelDeleteMessage,
        confirmLabel: texts.actionDelete,
      ),
    );

    if (confirmed != true || !mounted) return;

    _bloc.add(DeleteModelEvent(model.id));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocProvider<ModelsBloc>.value(
      value: _bloc,
      child: BlocBuilder<ModelsBloc, ModelsState>(
        bloc: _bloc,
        builder: (context, state) {
          return Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, texts),
                const SizedBox(height: AppSpacing.l),
                Expanded(child: _grid(state, texts)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations texts) {
    return Row(
      children: [
        Text(texts.modelsTitle, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        // El árbol se abre desde aquí y no desde el menú lateral: es una vista
        // **de** los modelos, y lo que decide es en qué orden se ejecutan éstos.
        FernPillButton(
          label: texts.treeOpen,
          icon: Icons.account_tree_outlined,
          backgroundColor: context.colors.secondary,
          foregroundColor: context.colors.black,
          onPressed: () => context.push(modelTreePath()),
        ),
        const SizedBox(width: AppSpacing.m),
        FernAddButton(
          label: texts.newModelTitle,
          radius: AppSizes.addButtonRadius,
          onTap: _create,
        ),
      ],
    );
  }

  Widget _grid(ModelsState state, AppLocalizations texts) {
    // Vacío o lleno, la superficie es la misma: así el aviso de que no hay nada
    // sale en el sitio donde va a salir la rejilla, y no arrinconado.
    if (state.models.isEmpty) {
      return FernSurface(
        child: Center(
          // Mientras la primera lectura está en marcha no se dice que no haya
          // ninguno: todavía no se sabe.
          child: state.isBusy
              ? const FernProgressIndicator()
              : FernEmptyState(
                  imageAsset: fernEmptyImage,
                  message: texts.modelsEmpty,
                ),
        ),
      );
    }

    return FernSurface(
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.m),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          // Por ancho máximo y no por número de columnas: la ventana cambia de
          // tamaño y una rejilla de cuatro fijas deja las tarjetas enormes en
          // pantalla ancha y espachurradas en estrecha.
          maxCrossAxisExtent: modelCardWidth,
          mainAxisExtent: modelCardHeight,
          crossAxisSpacing: AppSpacing.m,
          mainAxisSpacing: AppSpacing.m,
        ),
        itemCount: state.models.length,
        itemBuilder: (context, index) {
          final model = state.models[index];

          return ModelCard(
            key: ValueKey(model.id),
            model: model,
            onTap: () => context.push(modelDetailPath(model.id)),
            onDelete: () => _delete(model),
          );
        },
      ),
    );
  }
}
