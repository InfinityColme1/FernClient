import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/browser/data/services/browser_import_service.dart';
import 'package:Fern/features/browser/data/services/browser_page_scanner.dart';
import 'package:Fern/features/browser/data/services/browser_session_service.dart';
import 'package:Fern/features/browser/domain/entities/browser_media.dart';
import 'package:Fern/features/browser/presentation/widgets/browser_media_panel.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
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
  late String _start =
      widget.initialUrl ?? _preferences.getLastBrowserUrl() ?? _homePage;

  late final _address = TextEditingController(text: _start);

  InAppWebViewController? _webView;

  /// Dónde está el navegador ahora mismo. Es lo que decide de qué plataforma se
  /// recoge la sesión y de qué página se saca el contenido.
  late Uri? _url = Uri.tryParse(_start);

  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isLoading = false;

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

  /// Apunta dónde ha acabado el navegador y cierra el catálogo de la página
  /// anterior, que ya no habla de lo que se está viendo.
  Future<void> _onNavigated(WebUri? url) async {
    final back = await _webView?.canGoBack() ?? false;
    final forward = await _webView?.canGoForward() ?? false;
    if (!mounted) return;

    // Aquí se ha quedado: es lo que se abrirá la próxima vez que se entre en la
    // pantalla.
    if (url != null) await _preferences.setLastBrowserUrl(url.toString());
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
                color: AppColors.gray,
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

  Widget _browser() {
    return FernSurface(
      radius: AppSizes.radiusSmall,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_start)),
          onWebViewCreated: (controller) => _webView = controller,
          onLoadStart: (_, __) {
            if (mounted) setState(() => _isLoading = true);
          },
          onLoadStop: (controller, url) async {
            if (mounted) setState(() => _isLoading = false);
            // Cada página nueva vuelve a nacer a tamaño completo.
            await _scanner.setZoom(controller, browserZoom);
            await _onNavigated(url);
          },
          // Dentro de una misma página también se navega (las galerías cambian
          // de obra sin recargar), y ahí lo que se estuviera viendo ya es otra
          // cosa.
          onUpdateVisitedHistory: (_, url, __) => _onNavigated(url),
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
