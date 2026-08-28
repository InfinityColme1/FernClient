// El resumen de lo que una importacion no pudo traerse sola.
//
// Antes cada publicacion con un enlace a Mega o a Drive abria su propio aviso
// segun iba llegando, sin esperar a que se cerrara el anterior: una importacion
// de doscientas publicaciones montaba doscientos dialogos uno encima de otro, y
// cerrarlos era el trabajo. Aqui estan todas juntas, en uno.

import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/media/presentation/widgets/pending_links_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _carpeta = PostLink(
  url: 'https://mega.nz/folder/abc',
  kind: PostLinkKind.repositoryFolder,
);

const _fichero = PostLink(
  url: 'https://mega.nz/file/xyz',
  kind: PostLinkKind.repositoryFile,
);

Future<void> _open(WidgetTester tester, List<PendingLinkPost> posts) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: PendingLinksDialog(posts: posts)),
  ));
}

void main() {
  testWidgets('las publicaciones salen todas, en uno solo', (tester) async {
    await _open(tester, const [
      PendingLinkPost(title: 'Primera', links: [_carpeta]),
      PendingLinkPost(title: 'Segunda', links: [_carpeta]),
      PendingLinkPost(title: 'Tercera', links: [_fichero]),
    ]);

    expect(find.text('Primera'), findsOneWidget);
    expect(find.text('Segunda'), findsOneWidget);
    expect(find.text('Tercera'), findsOneWidget);
  });

  testWidgets('se distingue una carpeta de un fichero suelto', (tester) async {
    await _open(tester, const [
      PendingLinkPost(title: 'Con las dos', links: [_carpeta, _fichero]),
    ]);

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    // No es lo mismo de hacer: una carpeta hay que mirarla y elegir, y un
    // fichero suelto es entrar y bajarlo.
    expect(find.text(texts.pendingLinksFolder), findsOneWidget);
    expect(find.text(texts.pendingLinksFile), findsOneWidget);
  });

  testWidgets('una publicacion sin titulo se nombra igual', (tester) async {
    await _open(tester, const [
      PendingLinkPost(title: '', links: [_carpeta]),
    ]);

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.text(texts.linkChoiceUntitledPost), findsOneWidget);
  });

  testWidgets('cada enlace se puede abrir', (tester) async {
    await _open(tester, const [
      PendingLinkPost(title: 'Primera', links: [_carpeta, _fichero]),
    ]);

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.byTooltip(texts.linkChoiceOpen), findsNWidgets(2));
  });

  testWidgets('el titulo dice cuantas son', (tester) async {
    await _open(tester, const [
      PendingLinkPost(title: 'Primera', links: [_carpeta]),
      PendingLinkPost(title: 'Segunda', links: [_carpeta]),
    ]);

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.text(texts.pendingLinksTitle(2)), findsOneWidget);
  });
}
