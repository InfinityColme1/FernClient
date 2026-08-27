import 'dart:async';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/browser/data/services/browser_import_service.dart';
import 'package:Fern/features/browser/data/services/browser_page_scanner.dart';
import 'package:Fern/features/browser/data/services/browser_session_service.dart';
import 'package:Fern/features/browser/domain/entities/browser_media.dart';
import 'package:Fern/features/browser/domain/services/browser_start_url.dart';
import 'package:Fern/features/browser/presentation/widgets/browser_media_panel.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/media/data/services/import_job_runner.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_events.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// El navegador de dentro de la aplicación. **Es una prueba.**
///
/// Sirve para las dos cosas que la aplicación no puede hacer por su cuenta:
///
/// - **Entrar en una plataforma.** Hay sitios en los que no se puede iniciar
///   sesión desde fuera (captcha, verificación por correo, comprobaciones del
///   navegador). Aquí el usuario entra él mismo, como entraría siempre, y la
///   aplicación se queda con la sesión que deja abierta en lugar de pedirle que
///   la copie a mano de su navegador.
/// - **Ver lo que una página enseña.** Las páginas que se arman en el navegador
///   no traen nada al pedirlas por la red; hay que pintarlas para saber qué
///   tienen. Aquí ya están pintadas, así que se le pregunta a la propia página
///   qué contenido hay en ella.
///
/// Lo que se marque en el catálogo se descarga y aparece en la pantalla de
/// importación bajo la fuente del navegador, que es donde se revisa y se
/// confirma igual que lo que llega de Reddit o de Pixiv.
class BrowserPage extends StatefulWidget {
  /// Por dónde se abre. Lo trae quien manda aquí al usuario a hacer algo
  /// concreto (la pantalla de importación, a iniciar sesión en una plataforma);
  /// sin ella se abre por donde se abre siempre.
  final String? initialUrl;

  const BrowserPage({super.key, this.initialUrl});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  static const _sessions = BrowserSessionService();

  late final BrowserImportService _importer = BrowserImportService(
    downloader: getIt(),
    registry: getIt(),
    settingsRepository: getIt(),
  );

  late final BrowserPageScanner _scanner =
      BrowserPageScanner(resolver: getIt());

  final _preferences = getIt<PreferencesService>();

  /// La página de inicio que el usuario haya elegido en los ajustes. Es a donde
  /// lleva el botón de casa.
  String get _homePage => getIt<SettingsBloc>().state.settings.browserHome;

  /// Por dónde arranca esta vez, de lo más concreto a lo más general: lo que
  /// haya pedido quien abrió la pantalla, dónde se quedó la última vez, y por
  /// último la página de inicio.
  ///
  /// Volver a la pantalla no devuelve al principio: el navegador se deja como
  /// se dejó, igual que cualquier otra pantalla de la aplicación.
  late String _start = browserStartUrl(
    requested: widget.initialUrl,
    lastVisited: _preferences.getLastBrowserUrl(),
    home: _homePage,
  );

  late final _address = TextEditingController(text: _start);

  InAppWebViewController? _webView;

  /// Cuántas veces se ha empezado de cero en esta pantalla.
  ///
  /// Es la identidad de la vista: cambiarla hace que Flutter tire la que hay y
  /// monte una nueva. Es lo único que sirve cuando la que está puesta se ha
  /// quedado en blanco, porque a una vista que no responde no se le puede pedir
  /// que se recargue.
  int _generation = 0;

  /// Si la vista está montada ahora mismo.
  ///
  /// Se desmonta un instante al empezar de cero. Cambiar la identidad sin más
  /// monta la nueva en el mismo fotograma en el que se tira la vieja, y por
  /// debajo eso es crear un motor mientras se está destruyendo el anterior: si
  /// lo que estaba roto era el motor, la nueva nace igual de rota. Desmontarla,
  /// esperar y volver a montarla es lo que de verdad empieza de cero.
  bool _isMounted = true;

  /// Hay una importación en marcha.
  ///
  /// **Es lo que rompía el navegador.** Traerse mil ficheros de golpe descarga,
  /// da de alta y descodifica sin parar durante minutos; con el motor de la
  /// vista web vivo al lado, lo que pasa es lo que se ha visto: la página carga
  /// —su javascript llega a cambiar la dirección— y no se pinta nada. Ahí ya no
  /// hay nada que recargar, porque lo que se ha caído es el motor.
  ///
  /// Así que se aparta antes. Lo que no está montado no se puede romper.
  bool _isImporting = false;

  /// El usuario ha dicho que lo quiere igual.
  ///
  /// Apartarlo es una precaución, no una prohibición: quien quiera navegar
  /// mientras importa puede, sabiendo lo que hay.
  ///
  /// **Dura lo que dura la visita.** Se olvida al terminar la importación y
  /// también al salir de la pantalla: volver a entrar vuelve a apartarlo, que es
  /// lo que protege al motor. Si se quedara puesto, un rato después nadie
  /// recordaría haberlo desbloqueado y el navegador se rompería igual.
  bool _keepDespiteImport = false;

  StreamSubscription<List<Job>>? _jobs;

  /// Ya se ha intentado recuperar sola una vista atascada.
  ///
  /// Una vez: si empezar de cero no la arregla, insistir tampoco, y lo honesto
  /// es decir lo que queda por hacer en vez de dar vueltas.
  bool _hasRetried = false;

  /// Vigila que una carga llegue a terminar.
  ///
  /// El fallo que se persigue se ve así: la página **carga** —la dirección
  /// cambia sola a la que pone el sitio, así que su javascript ha corrido— y no
  /// se pinta nada. Si eso pasa, nadie se entera: la barra se queda dando
  /// vueltas para siempre. Con esto, a los quince segundos se dice lo que
  /// ocurre y lo único que lo arregla.
  Timer? _watchdog;

  /// Dónde está el navegador ahora mismo. Es lo que decide de qué plataforma se
  /// recoge la sesión y de qué página se saca el contenido.
  late Uri? _url = Uri.tryParse(_start);

  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isLoading = false;

  /// El navegador ha llegado a enseñar una página en esta visita.
  ///
  /// Con algo delante, una carga que se cae es una página que no ha ido; con la
  /// pantalla en blanco, es el fallo que se está persiguiendo.
  bool _hasPageShown = false;

  /// Ya se ha vuelto a la página de inicio una vez por un fallo de carga.
  ///
  /// Sin esto, una página de inicio que no cargue deja la pantalla dando
  /// vueltas, que es peor que quedarse en blanco.
  bool _hasRecovered = false;

  /// Lo encontrado en la página que se está viendo. Mientras haya algo, el
  /// catálogo está abierto. Se vacía al cambiar de página: es de esa página y de
  /// ninguna otra.
  List<BrowserMedia> _found = const [];

  /// Lo que el usuario ha marcado del catálogo, por su dirección. De partida se
  /// marca todo: lo normal es querérselo traer, y quitar lo que sobra es menos
  /// trabajo que señalar uno a uno.
  Set<String> _selected = {};

  /// Lo último que ha pasado, para contárselo al usuario. Es una pantalla en la
  /// que casi todo ocurre por debajo (una cookie que se guarda, unos ficheros
  /// que se descargan) y sin esto no se vería nada.
  String? _status;

  /// Hay algo en marcha (recogiendo la sesión, buscando o descargando): mientras
  /// dure, los botones no admiten otra cosa.
  bool _isBusy = false;

  /// Si se vuelve a mandar aquí al usuario mientras la pantalla sigue montada
  /// (que es lo que pasa al pulsar dos veces seguidas en "iniciar sesión"), lo
  /// que llega es una dirección nueva y hay que ir a ella: la de arranque ya se
  /// usó.
  @override
  void initState() {
    super.initState();

    _isImporting = _hasImport(getIt<JobQueue>().activeJobs);
    _jobs = getIt<JobQueue>().changes.listen(_onJobs);
  }

  /// Si hay una importación que, según el ajuste, obliga a apartar la vista.
  ///
  /// Lo de «grande» sale del tope con el que se lanzó, que es lo único que se
  /// sabe antes de empezar: traerse diez no rompe nada, traerse todo sí.
  bool _hasImport(List<Job> jobs) {
    final policy = getIt<SettingsBloc>().state.settings.browserAside;
    if (policy == BrowserAsidePolicy.never) return false;

    return jobs.any((job) {
      if (job.type != JobType.mediaImport || !job.status.isActive) return false;
      if (policy == BrowserAsidePolicy.always) return true;

      return _isLarge(job);
    });
  }

  bool _isLarge(Job job) {
    final limit = job.payload[ImportJobRunner.limitKey];
    if (limit is! int) return true;

    // «Todo» y «desde la última vez» no son una cuenta: pueden traer miles.
    if (limit == unlimitedImportLimit || limit == untilLastImportLimit) {
      return true;
    }

    return limit >= browserAsideLargeImport;
  }

  /// Aparta la vista mientras dure una importación, y la trae de vuelta al
  /// terminar.
  void _onJobs(List<Job> jobs) {
    final importing = _hasImport(jobs);
    if (importing == _isImporting || !mounted) return;

    setState(() {
      _isImporting = importing;

      // Al terminar se olvida lo que el usuario dijera para esta: la siguiente
      // vuelve a apartarlo, que es lo que le conviene.
      if (!importing) _keepDespiteImport = false;
    });
  }

  /// Si ahora mismo hay vista web montada.
  bool get _showsWebView =>
      _isMounted && (!_isImporting || _keepDespiteImport);

  @override
  void didUpdateWidget(BrowserPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final url = widget.initialUrl;
    if (url == null || url == oldWidget.initialUrl) return;

    _start = url;
    _address.text = url;
    _webView?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  @override
  void dispose() {
    _jobs?.cancel();
    _stopWatching();
    // La vista se va con la pantalla: un motor que sobreviviera a su pantalla
    // es justo lo que deja al siguiente naciendo sobre algo a medio morir.
    _webView?.dispose();
    _address.dispose();
    super.dispose();
  }

  /// Va a lo que haya escrito en la barra de direcciones.
  ///
  /// Lo escrito no tiene por qué ser una dirección entera: quien escribe
  /// `pixiv.net` quiere ir a `https://pixiv.net`.
  void _go() {
    final typed = _address.text.trim();
    if (typed.isEmpty) return;

    final url = typed.contains('://') ? typed : 'https://$typed';

    _webView?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  /// Recoge la sesión de la plataforma en la que esté el navegador y la guarda
  /// en los ajustes de su fuente.
  ///
  /// No vale cualquier sitio: sólo las plataformas de las que la aplicación sabe
  /// importar, que son las que tienen un ajuste donde guardarla.
  Future<void> _captureSession() async {
    final texts = AppLocalizations.of(context);

    final source = _sessions.sourceOf(_url);
    if (source == null) {
      setState(() => _status = texts.browserNoSession);
      return;
    }

    setState(() => _isBusy = true);

    final value = await _sessions.sessionOf(source);
    if (!mounted) return;

    if (value == null) {
      setState(() {
        _isBusy = false;
        _status = texts.browserSessionMissing(source.source.label ?? '');
      });
      return;
    }

    final bloc = getIt<SettingsBloc>();
    bloc.add(RemoteSessionCapturedEvent(source.apply(bloc.state.settings, value)));

    setState(() {
      _isBusy = false;
      _status = texts.browserSessionSaved(source.source.label ?? '');
    });
  }

  /// Busca contenido en la página tal y como se está viendo y abre el catálogo
  /// con lo que haya salido.
  Future<void> _findMedia() async {
    final texts = AppLocalizations.of(context);

    final controller = _webView;
    if (controller == null) return;

    setState(() {
      _isBusy = true;
      _found = const [];
      _selected = {};
    });

    final found = await _scanner.scan(controller);
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      _found = found;
      _selected = {for (final each in found) each.url};
      _status = found.isEmpty ? texts.browserNothingFound : null;
    });
  }

  /// Señala en la página el contenido de la fila por la que pasa el ratón.
  Future<void> _highlight(BrowserMedia? media) async {
    final controller = _webView;
    if (controller == null) return;

    await _scanner.highlight(
      controller,
      mark: media?.mark,
      color: browserHighlightColor,
    );
  }

  /// Cierra el catálogo y deja la página como estaba.
  void _closePanel() {
    _highlight(null);
    setState(() {
      _found = const [];
      _selected = {};
    });
  }

  /// Se trae lo marcado y lo deja pendiente de revisar en la pantalla de
  /// importación.
  Future<void> _import() async {
    final texts = AppLocalizations.of(context);

    final page = _url?.toString();
    if (page == null || _selected.isEmpty) return;

    final urls = [
      for (final each in _found)
        if (_selected.contains(each.url)) each.url,
    ];

    setState(() => _isBusy = true);
    await _highlight(null);

    final result = await _importer.importAll(
      urls,
      pageUrl: page,
      onProgress: (done, total) {
        if (!mounted) return;
        setState(() => _status = texts.browserImporting(done, total));
      },
    );
    if (!mounted) return;

    // La pantalla de importación se deja apuntando a donde ha quedado lo que se
    // acaba de traer: el mensaje dice dónde buscarlo, y llegar allí y no verlo
    // porque el desplegable seguía en otra fuente sería contarlo a medias.
    if (result.imported > 0) {
      getIt<MediaBloc>().add(ImportSourceChangedEvent(result.source));
    }

    setState(() {
      _isBusy = false;
      _found = const [];
      _selected = {};
      _status = _importSummary(texts, result);
    });
  }

  /// Cómo ha ido la importación, dicho entero.
  ///
  /// Se cuentan las tres cosas que pueden pasarle a un contenido, porque las
  /// tres dejan la pantalla igual y no significan lo mismo: lo que ha entrado
  /// (y dónde ha quedado, que es lo que hay que ir a mirar), lo que ya estaba y
  /// lo que no se ha podido traer.
  String _importSummary(AppLocalizations texts, BrowserImportResult result) {
    final parts = [
      if (result.imported > 0)
        texts.browserImportedInto(
          result.imported,
          result.source.label ?? texts.sourceBrowser,
        ),
      if (result.known > 0) texts.browserImportKnown(result.known),
      if (result.failed > 0) texts.browserImportFailed(result.failed),
    ];

    return parts.isEmpty ? texts.browserImportNothing : parts.join(' · ');
  }

  /// Vuelve a la página de inicio, la que el usuario haya puesto en los
  /// ajustes.
  void _goHome() {
    _webView?.loadUrl(urlRequest: URLRequest(url: WebUri(_homePage)));
  }

  /// Una carga se ha caído.
  ///
  /// Se dice siempre —es una pantalla en la que todo pasa por debajo y sin esto
  /// no se ve nada— y, si no había ninguna página delante, se vuelve a la de
  /// inicio en vez de dejar el vacío.
  void _onLoadFailed({
    required String description,
    required bool isMainFrame,
  }) {
    if (!mounted) return;

    final texts = AppLocalizations.of(context);
    final recovery = browserRecoveryFor(
      hasPageShown: _hasPageShown,
      alreadyRecovered: _hasRecovered,
      isMainFrame: isMainFrame,
    );

    setState(() {
      _isLoading = false;
      _status = recovery == BrowserRecovery.goHome
          ? texts.browserLoadFailedHome(description)
          : texts.browserLoadFailed(description);
      if (recovery == BrowserRecovery.goHome) _hasRecovered = true;
    });

    if (recovery == BrowserRecovery.goHome) _goHome();
  }

  /// Apunta dónde ha acabado el navegador y cierra el catálogo de la página
  /// anterior, que ya no habla de lo que se está viendo.
  Future<void> _onNavigated(WebUri? url) async {
    final back = await _webView?.canGoBack() ?? false;
    final forward = await _webView?.canGoForward() ?? false;
    if (!mounted) return;

    // Aquí se ha quedado: es lo que se abrirá la próxima vez que se entre en la
    // pantalla. Sólo si es una página: por en medio de una navegación pasan
    // `about:blank` y cosas así, y guardar una de ésas es arrancar en blanco la
    // próxima vez.
    if (url != null && isBrowsableUrl(url.toString())) {
      await _preferences.setLastBrowserUrl(url.toString());
    }
    if (!mounted) return;

    setState(() {
      _url = url == null ? _url : Uri.tryParse(url.toString());
      if (url != null) _address.text = url.toString();
      _canGoBack = back;
      _canGoForward = forward;
      _found = const [];
      _selected = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _toolbar(texts),
          if (_status != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              _status!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.colors.gray,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            // El catálogo se abre por encima de la página, pegado al borde
            // derecho: la página sigue a la vista porque es donde se señala lo
            // que la lista va nombrando.
            child: Stack(
              children: [
                Positioned.fill(child: _browser()),
                if (_found.isNotEmpty)
                  Positioned(
                    top: AppSpacing.m,
                    right: AppSpacing.m,
                    width: AppSizes.menuWidth * 1.6,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
                      ),
                      child: BrowserMediaPanel(
                        media: _found,
                        selected: _selected,
                        isBusy: _isBusy,
                        onToggle: (url) => setState(() {
                          _selected.contains(url)
                              ? _selected.remove(url)
                              : _selected.add(url);
                        }),
                        onToggleAll: () => setState(() {
                          _selected = _selected.length == _found.length
                              ? {}
                              : {for (final each in _found) each.url};
                        }),
                        onHover: _highlight,
                        onClose: _closePanel,
                        onImport: _import,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Lo que se ve mientras el navegador está apartado por una importación.
  Widget _asideForImport(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return FernSurface(
      radius: AppSizes.radiusSmall,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.dialogMaxWidth / 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.downloading_outlined,
                size: AppSizes.iconExtraLarge,
                color: context.colors.gray,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                texts.browserAsideImporting,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                texts.browserAsideImportingWhy,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.colors.gray),
              ),
              const SizedBox(height: AppSpacing.l),
              FernPillButton(
                label: texts.browserAsideAnyway,
                icon: Icons.public,
                backgroundColor: context.colors.secondary,
                foregroundColor: context.colors.black,
                onPressed: () => setState(() => _keepDespiteImport = true),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                texts.browserAsideOnce,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: context.colors.gray),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empieza de cero: tira la vista y monta otra.
  ///
  /// El fallo de «se queda en blanco» sigue sin identificarse, y con la vista
  /// muerta no hay a quién pedirle una recarga: recargar es una orden que se le
  /// da a la misma vista que no responde. Esto no le pide nada — la sustituye
  /// por una nueva, vacía su caché y vuelve a arrancar por donde arrancaría al
  /// abrir la pantalla.
  ///
  /// La sesión **no se toca**: vive en las cookies del motor, no en la vista, y
  /// perderla obligaría a entrar otra vez en cada plataforma. Lo que se quiere
  /// arreglar es una pantalla en blanco, no cerrar la sesión de nadie.
  /// Arma el vigilante de la carga en curso.
  void _watch() {
    _watchdog?.cancel();
    _watchdog = Timer(browserBlankTimeout, _onStuck);
  }

  void _stopWatching() {
    _watchdog?.cancel();
    _watchdog = null;
  }

  /// La carga no ha terminado en lo que tarda cualquier página.
  ///
  /// No se toca nada: se dice. Reiniciar por nuestra cuenta a un usuario que
  /// puede estar esperando a que cargue algo pesado sería peor, y si lo que
  /// falla es el motor, reiniciar la vista tampoco lo arregla — eso ya lo ha
  /// probado quien haya llegado hasta aquí.
  void _onStuck() {
    if (!mounted) return;

    final texts = AppLocalizations.of(context);

    // Con algo ya delante, esto es una página lenta y no un motor caído.
    if (_hasPageShown) {
      setState(() {
        _isLoading = false;
        _status = texts.browserSlow;
      });

      return;
    }

    // La primera vez se intenta arreglar solo: es lo que el usuario haría, y
    // hacérselo pulsar cuando ya sabemos que hace falta es hacerle trabajo.
    if (!_hasRetried) {
      _hasRetried = true;
      unawaited(_reset());

      return;
    }

    // Y si empezar de cero tampoco lo ha arreglado, lo que queda no se puede
    // hacer desde dentro.
    setState(() {
      _isLoading = false;
      _status = texts.browserEngineStuck;
    });
  }

  Future<void> _reset() async {
    final texts = AppLocalizations.of(context);

    // Lo que hubiera a medias deja de valer: la vista que lo estaba enseñando
    // se va.
    _closePanel();

    try {
      await _webView?.clearCache();
    } on Object catch (error) {
      // Una vista que no responde tampoco va a vaciar su caché, y eso no puede
      // impedir lo importante, que es montar otra.
      debugPrint('No se pudo vaciar la caché del navegador: $error');
    }

    if (!mounted) return;

    final start = browserStartUrl(
      requested: null,
      lastVisited: _preferences.getLastBrowserUrl(),
      home: _homePage,
    );

    _stopWatching();

    // Primero se va, y **de verdad**: la vista se desmonta y el motor que tenía
    // debajo se destruye. Sin esto, montar la nueva en el mismo fotograma la
    // hace nacer sobre un motor a medio morir, que es exactamente lo que se
    // estaba intentando dejar atrás.
    setState(() {
      _isMounted = false;
      _webView?.dispose();
      _webView = null;
      _found = const [];
      _selected = {};
      _isLoading = false;
      _status = texts.browserResetting;
    });

    await Future<void>.delayed(browserResetPause);
    if (!mounted) return;

    setState(() {
      _isMounted = true;
      _generation++;
      _start = start;
      _address.text = start;
      _url = Uri.tryParse(start);
      _canGoBack = false;
      _canGoForward = false;
      _isLoading = true;
      _hasPageShown = false;
      // Y se vuelve a tener derecho a una recuperación automática: la anterior
      // era de la vista que se acaba de tirar.
      _hasRecovered = false;
      _status = texts.browserResetDone;
    });

    _watch();
  }

  Widget _browser() {
    // Mientras se destruye la anterior no hay vista que enseñar. Un hueco vacío
    // y no la de antes: lo que se está haciendo es quitarla de en medio.
    if (!_isMounted) {
      return const FernSurface(
        radius: AppSizes.radiusSmall,
        child: Center(child: FernProgressIndicator()),
      );
    }

    if (!_showsWebView) return _asideForImport(context);

    return FernSurface(
      radius: AppSizes.radiusSmall,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: InAppWebView(
          // La identidad de la vista: al cambiarla, Flutter tira ésta y monta
          // una nueva desde cero. Ver [_reset].
          key: ValueKey(_generation),
          initialUrlRequest: URLRequest(url: WebUri(_start)),
          onWebViewCreated: (controller) => _webView = controller,
          onLoadStart: (_, __) {
            _watch();
            if (mounted) setState(() => _isLoading = true);
          },
          onLoadStop: (controller, url) async {
            _stopWatching();

            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasPageShown = true;
              });
            }
            // Cada página nueva vuelve a nacer a tamaño completo.
            await _scanner.setZoom(controller, browserZoom);
            await _onNavigated(url);
          },
          // Dentro de una misma página también se navega (las galerías cambian
          // de obra sin recargar), y ahí lo que se estuviera viendo ya es otra
          // cosa.
          onUpdateVisitedHistory: (_, url, __) => _onNavigated(url),
          // El fallo de «se queda en blanco» no estaba identificado porque no se
          // escuchaba nada de lo que la vista puede contar. Ahora se cuenta, y
          // si además no había nada delante se vuelve a un sitio conocido.
          onReceivedError: (_, request, error) => _onLoadFailed(
            description: error.description,
            isMainFrame: request.isForMainFrame ?? true,
          ),
          onReceivedHttpError: (_, request, response) => _onLoadFailed(
            description: 'HTTP ${response.statusCode ?? 0}',
            isMainFrame: request.isForMainFrame ?? true,
          ),
        ),
      ),
    );
  }

  Widget _toolbar(AppLocalizations texts) {
    return Row(
      children: [
        IconButton(
          tooltip: texts.browserBack,
          onPressed: _canGoBack ? () => _webView?.goBack() : null,
          icon: const Icon(Icons.arrow_back),
        ),
        IconButton(
          tooltip: texts.browserForward,
          onPressed: _canGoForward ? () => _webView?.goForward() : null,
          icon: const Icon(Icons.arrow_forward),
        ),
        IconButton(
          tooltip: texts.browserReload,
          onPressed: () => _webView?.reload(),
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: texts.browserReset,
          onPressed: _isBusy ? null : _reset,
          icon: const Icon(Icons.restart_alt),
        ),
        IconButton(
          tooltip: texts.browserHome,
          onPressed: _goHome,
          icon: const Icon(Icons.home_outlined),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: TextField(
            controller: _address,
            onSubmitted: (_) => _go(),
            decoration: InputDecoration(
              hintText: texts.browserAddressHint,
              isDense: true,
              prefixIcon: const Icon(Icons.public, size: AppSizes.iconMedium),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        IconButton(
          tooltip: texts.browserSaveSessionHint,
          onPressed: _isBusy ? null : _captureSession,
          icon: const Icon(Icons.key_outlined),
        ),
        IconButton(
          tooltip: texts.browserFindMediaHint,
          onPressed: _isBusy ? null : _findMedia,
          icon: const Icon(Icons.image_search_outlined),
        ),
      ],
    );
  }
}
