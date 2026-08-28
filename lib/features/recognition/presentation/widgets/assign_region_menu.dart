import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/utils/debouncer.dart';
import 'package:Fern/features/media/presentation/widgets/fern_create_dialog.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/get_fernies_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/search_fernies_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernies_bloc.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Lo que va dentro del menú contextual que se abre al soltar una región: buscar
/// un fernie, elegirlo de la lista o crear uno nuevo al vuelo.
///
/// Arranca enseñando todos los fernies que hay, sin escribir nada: lo normal es
/// tener unos pocos y querer el mismo de la vez anterior, así que obligar a
/// escribir para ver algo sería un paso de más en un gesto que se repite mucho.
class AssignRegionMenu extends StatefulWidget {
  /// El fernie elegido. Quien lo recibe asigna la región y cierra el menú.
  final ValueChanged<FernieEntity> onSelected;

  const AssignRegionMenu({super.key, required this.onSelected});

  @override
  State<AssignRegionMenu> createState() => _AssignRegionMenuState();
}

class _AssignRegionMenuState extends State<AssignRegionMenu> {
  final _getFernies = getIt<GetFerniesUseCase>();
  final _searchFernies = getIt<SearchFerniesUseCase>();

  late final Debouncer _debouncer = Debouncer(searchDebounceDuration);

  List<FernieEntity> _results = const [];
  bool _isSearching = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final result = await _getFernies();
    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _results = result is DataSuccess
          ? result.data ?? const <FernieEntity>[]
          : const <FernieEntity>[];
    });
  }

  void _onQueryChanged(String query) {
    // Vaciar el buscador devuelve la lista entera, no una lista vacía: es la
    // forma de volver atrás sin cerrar el menú.
    if (query.trim().isEmpty) {
      _debouncer.cancel();
      _loadAll();
      return;
    }

    _debouncer.run(() => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);

    final result = await _searchFernies(params: query);
    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _results = result is DataSuccess
          ? result.data ?? const <FernieEntity>[]
          : const <FernieEntity>[];
    });
  }

  /// Crea un fernie sin salir del gesto y le asigna la región recién marcada.
  ///
  /// Es el caso normal la primera vez que se marca a alguien: el fernie todavía
  /// no existe, y mandar al usuario a otra pantalla a crearlo le haría perder el
  /// rectángulo que acaba de dibujar.
  Future<void> _create() async {
    // Se nombra el bloc aunque no se provea ninguno: Dart no infiere sólo una
    // parte de los tipos, y aquí hace falta nombrar el del resultado.
    final fernie = await showFernDialog<FernieEntity, FerniesBloc>(
      context: context,
      builder: (_) => const FernCreateDialog.fernie(),
    );
    if (fernie == null || !mounted) return;

    widget.onSelected(fernie);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: FernSearchInput(
            label: texts.assignRegionTitle,
            hintText: texts.searchFernieHint,
            isSearching: _isSearching,
            suggestions: const [],
            onChanged: _onQueryChanged,
          ),
        ),
        Flexible(child: _results.isEmpty ? _empty(texts) : _list()),
        const Divider(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: FernAddButton.inline(
            label: texts.createFernie,
            onTap: _create,
          ),
        ),
      ],
    );
  }

  Widget _empty(AppLocalizations texts) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      child: Text(
        texts.noFerniesYet,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: context.colors.unremarked),
      ),
    );
  }

  Widget _list() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final fernie = _results[index];

        return InkWell(
          onTap: () => widget.onSelected(fernie),
          mouseCursor: WidgetStateMouseCursor.clickable,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.s,
            ),
            child: Row(
              children: [
                FernAvatar(
                  imagePath: fernie.picturePath,
                  fallbackIcon: Symbols.face_retouching_natural,
                  radius: AppSizes.avatarMedium,
                  iconSize: AppSizes.iconMedium,
                  backgroundColor: context.colors.secondary,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Text(
                    fernie.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
