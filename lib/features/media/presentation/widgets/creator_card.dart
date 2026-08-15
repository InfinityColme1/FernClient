import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/usecases/delete_creator_usecase.dart';
import 'package:Fern/features/media/domain/usecases/save_creator_source_urls_usecase.dart';
import 'package:Fern/features/media/domain/usecases/update_creator_usecase.dart';
import 'package:Fern/features/media/presentation/blocs/creators_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/creators_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/assign_url_dialog.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final _avatarStorage = getIt<AvatarStorageService>();

  late final TextEditingController _nameController =
      TextEditingController(text: widget.creator.name);

  late String? _picturePath = widget.creator.picturePath;

  /// Un campo por enlace de red social, con los que ya tiene el creador.
  ///
  /// Se editan aquí y se escriben con el resto del formulario, al guardar: como
  /// el nombre, no como las direcciones vinculadas (que tienen su propio
  /// diálogo y se guardan solas).
  late final List<TextEditingController> _socialControllers = [
    for (final link in widget.creator.socialProfiles ?? const <String>[])
      TextEditingController(text: link),
  ];

  /// Los enlaces que se están editando, por posición. Los demás se ven como
  /// enlaces pulsables: en la ficha se entra a editar enlace a enlace, que lo
  /// normal es venir a tocar uno y no la lista entera.
  final Set<int> _editingProfiles = {};

  /// Direcciones de las que sale el contenido del creador.
  ///
  /// Se guardan desde su propio diálogo, así que aquí sólo se llevan para saber
  /// con cuáles abrirlo y para no perderlas al guardar el formulario.
  late List<String> _sourceUrls = widget.creator.sourceUrls;

  /// El creador desconocido no se borra: es el respaldo al que van a parar los
  /// contenidos cuando se borra otro, así que sin él no habría dónde dejarlos.
  bool get _isUnknown => widget.creator.name == unknownCreator.name;

  /// Hay una escritura en marcha (guardar, borrar o copiar el avatar elegido).
  ///
  /// Mientras la haya, la ficha espera con su indicador y sus botones quedan
  /// desactivados: son operaciones sobre el mismo creador, así que no tiene
  /// sentido lanzar dos a la vez.
  bool _isBusy = false;

  /// Enlaces escritos, sin los campos que se han quedado vacíos: dejar uno en
  /// blanco es otra forma de quitarlo.
  List<String> get _socialProfileLinks => _socialControllers
      .map((controller) => controller.text.trim())
      .where((link) => link.isNotEmpty)
      .toList();

  /// Añade un enlace más, ya en modo edición: nace vacío, así que no hay nada
  /// que pulsar hasta que se escriba.
  void _addProfile() {
    setState(() {
      _socialControllers.add(TextEditingController());
      _editingProfiles.add(_socialControllers.length - 1);
    });
  }

  /// Quita el enlace de la posición [index].
  ///
  /// Las posiciones que estaban en edición se recolocan: los índices por debajo
  /// del que se va se quedan como están y los de encima bajan uno, o se estaría
  /// editando un enlace distinto del que se abrió.
  void _removeProfile(int index) {
    setState(() {
      _socialControllers.removeAt(index).dispose();

      final editing = _editingProfiles
          .where((position) => position != index)
          .map((position) => position > index ? position - 1 : position)
          .toSet();

      _editingProfiles
        ..clear()
        ..addAll(editing);
    });
  }

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

  /// Escribe los datos nuevos del creador.
  ///
  /// El identificador no cambia, así que los contenidos que lo tienen lo siguen
  /// teniendo. Al terminar se releen los creadores (el nombre y el avatar salen
  /// en la lista de al lado) y se vuelve a pedir su contenido, que es lo que
  /// enseña la rejilla de debajo.
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Sin ninguno se manda `null` y no una lista vacía: es como se guardan los
    // creadores que se crean sin enlaces.
    final links = _socialProfileLinks;

    final result = await _updateCreator(
      params: CreatorEntity(
        id: widget.creator.id,
        name: name,
        picturePath: _picturePath,
        socialProfiles: links.isEmpty ? null : links,
        sourceUrls: _sourceUrls,
      ),
    );
    if (result is! DataSuccess || !mounted) return;

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
    final urls = await showFernDialog<List<String>, MediaBloc>(
      context: context,
      builder: (_) => AssignUrlDialog(
        urls: _sourceUrls,
        name: widget.creator.name,
        target: AssignUrlTarget.creator,
      ),
    );
    if (urls == null || !mounted) return;

    await _run(() async {
      final result = await _saveCreatorSourceUrls(
        params: SaveCreatorSourceUrlsParams(
          creatorId: widget.creator.id,
          urls: urls,
        ),
      );

      final creator = result.data;
      if (result is! DataSuccess || creator == null || !mounted) return;

      // Se recogen ya normalizadas: son las que se van a comparar al importar, y
      // así el diálogo se vuelve a abrir con lo que de verdad hay guardado.
      setState(() => _sourceUrls = creator.sourceUrls);
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

  /// Abre el enlace en el navegador del sistema.
  ///
  /// Los enlaces se guardan tal y como los escribió el usuario, así que muchos
  /// llegan sin protocolo (`instagram.com/alguien`): sin él, `Uri` no sabría a
  /// qué aplicación dárselo.
  Future<void> _openProfile(String link) async {
    final value = link.trim();
    if (value.isEmpty) return;

    final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            // En la esquina superior derecha, como en la ficha de etiqueta: es la
            // misma acción y se busca en el mismo sitio.
            Align(
              alignment: Alignment.topRight,
              child: _assignUrlsButton(texts),
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
                    titleColor: name.isEmpty ? AppColors.unremarked : null,
                    // Más pequeño que el del diálogo: la ficha comparte el alto de
                    // la pantalla con la rejilla, y el avatar es lo que más ocupa.
                    avatar: FernEditableAvatar(
                      imagePath: _picturePath,
                      fallbackIcon: Icons.person_outline,
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
                  icon: Icons.delete_outline,
                  backgroundColor: AppColors.terciary,
                  foregroundColor: AppColors.white,
                  onPressed: _isBusy || _isUnknown ? null : () => _run(_delete),
                ),
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

  /// Abre el diálogo que vincula direcciones con el creador.
  ///
  /// Cambia de icono cuando ya hay alguna: es la única señal de que el creador se
  /// asigna solo, porque las direcciones no se ven en el formulario.
  Widget _assignUrlsButton(AppLocalizations texts) {
    return IconButton(
      icon: Icon(
        _sourceUrls.isEmpty ? Icons.add_link : Icons.link,
        size: AppSizes.iconExtraLarge,
      ),
      tooltip: texts.assignUrlsCreatorTooltip,
      onPressed: _isBusy ? null : _assignUrls,
    );
  }

  /// Los enlaces de redes sociales del creador: pulsar uno lo abre en el
  /// navegador del sistema y el botón de al lado lo pasa a editar.
  ///
  /// Debajo, el mismo botón discreto que en el diálogo de creación para añadir
  /// uno más. Lo que se escriba se guarda con el resto del formulario, al pulsar
  /// "Guardar": hasta entonces la ficha no ha tocado nada.
  ///
  /// Sin ninguno se dice y ya está, en tono apagado como el resto de huecos por
  /// rellenar.
  Widget _socialProfilesField(AppLocalizations texts) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts.socialProfilesLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        // Con el hueco que quede y no con un alto propio: la ficha lo tiene
        // fijo, así que este bloque es el que se estira o se encoge y lo que no
        // quepa se desplaza aquí dentro. Con un máximo, la ficha crecería enlace
        // a enlace y no todos los creadores tendrían la misma.
        Expanded(
          child: _socialControllers.isEmpty
              ? Text(
                  texts.noSocialProfiles,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.unremarked,
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _socialControllers.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (_, index) => _profileRow(texts, index),
                ),
        ),
        const SizedBox(height: AppSpacing.xs),
        FernInlineAddButton(
          label: texts.addProfile,
          onTap: _addProfile,
        ),
      ],
    );
  }

  /// Un enlace de la lista, en una de sus dos formas.
  ///
  /// Editándose es el mismo campo que en el diálogo de creación, con el botón
  /// que lo da por bueno y el que lo quita. En reposo es el enlace pulsable, y
  /// el botón de al lado es el que lleva a la otra forma: así el enlace se abre
  /// de una pulsación, que es lo que se viene a hacer casi siempre.
  Widget _profileRow(AppLocalizations texts, int index) {
    final controller = _socialControllers[index];

    if (_editingProfiles.contains(index)) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              autofocus: true,
              decoration: InputDecoration(hintText: texts.profileLinkHint),
            ),
          ),
          _rowButton(
            icon: Icons.check,
            tooltip: texts.doneEditingProfileTooltip,
            // Sólo se sale del modo edición: lo escrito se queda en el campo y
            // se guarda con el resto de la ficha.
            onPressed: () => setState(() => _editingProfiles.remove(index)),
          ),
          _rowButton(
            icon: Icons.close,
            tooltip: texts.removeProfileTooltip,
            onPressed: () => _removeProfile(index),
          ),
        ],
      );
    }

    final link = controller.text.trim();

    return SizedBox(
      height: creatorProfileRowHeight,
      child: Row(
      children: [
        Expanded(
          // A mano y no con una píldora del catálogo: los enlaces son largos y
          // aquí lo que hay es una columna estrecha, así que el texto tiene que
          // poder recortarse.
          child: InkWell(
            onTap: () => _openProfile(link),
            mouseCursor: WidgetStateMouseCursor.clickable,
            child: Tooltip(
              message: texts.openProfileTooltip,
              child: Row(
                children: [
                  const Icon(Icons.open_in_new, size: AppSizes.iconCompact),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _rowButton(
          icon: Icons.edit_outlined,
          tooltip: texts.editProfileTooltip,
          onPressed: () => setState(() => _editingProfiles.add(index)),
        ),
      ],
      ),
    );
  }

  /// Los botones que acompañan a un enlace, sin el hueco que un `IconButton`
  /// reserva por defecto: son varios en una lista que tiene que caber en la
  /// ficha.
  Widget _rowButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: AppSizes.iconCompact),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: creatorProfileRowHeight,
        height: creatorProfileRowHeight,
      ),
      onPressed: onPressed,
    );
  }

  /// Le quita el creador a lo que esté seleccionado en la rejilla (pasa al
  /// desconocido). Sin nada seleccionado no hay a quién quitárselo, así que queda
  /// atenuado.
  Widget _unassignButton(AppLocalizations texts) {
    return BlocSelector<MediaBloc, MediaStates, bool>(
      selector: (state) => state.selectedIds.isNotEmpty,
      builder: (context, hasSelection) => FernPillButton(
        label: texts.actionUnassignCreator,
        icon: Icons.person_remove_outlined,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.black,
        onPressed: hasSelection && !_isUnknown
            ? () => context
                .read<MediaBloc>()
                .add(RemoveCreatorFromSelectedMediaEvent(widget.creator.id))
            : null,
      ),
    );
  }
}
