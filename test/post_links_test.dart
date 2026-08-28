// Qué se hace con los enlaces que trae una publicación.
//
// Es la parte con más criterio de toda la importación: de un enlace hay que
// decidir, sin abrirlo, si lleva a algo que la aplicación puede traerse, a un
// sitio donde tiene que entrar el usuario, o a una página que no da nada. Y
// cuando hay varios a la vez, quien decide es el usuario.

import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un usuario de mentira, que contesta lo que se le diga y apunta cuántas veces
/// le han preguntado.
class _Answers implements ImportDecisionHandler {
  final LinkChoice answer;

  /// Las publicaciones que se han aparcado como tarea, en orden.
  final parked = <LinkReviewRequest>[];

  int asked = 0;

  /// Cuantas veces se ha ensenado el resumen del final, y con cuantas
  /// publicaciones.
  int summaries = 0;
  List<PendingLinkPost> shown = const [];

  _Answers(this.answer);

  @override
  void parkLinks(LinkReviewRequest request) {
    asked++;
    parked.add(request);
  }

  @override
  Future<void> showPendingLinks(List<PendingLinkPost> posts) async {
    summaries++;
    shown = posts;
  }
}

/// Una publicacion cualquiera con estos enlaces.
LinkReviewRequest _request(List<PostLink> links) => LinkReviewRequest(
      postTitle: 'Una',
      links: links,
      source: ImportSource.pawchive,
      namePrefix: 'pawchive_1_link',
    );

void main() {
  group('de qué es cada enlace', () {
    test('lo que acaba en un fichero es contenido', () {
      expect(
        classifyPostLink('https://cdn.test/una.jpg').kind,
        PostLinkKind.media,
      );
      expect(
        classifyPostLink('https://cdn.test/un-video.mp4').kind,
        PostLinkKind.media,
      );
    });

    test('lo que acaba en un comprimido hay que abrirlo', () {
      expect(
        classifyPostLink('https://cdn.test/entrega.zip').kind,
        PostLinkKind.archive,
      );
    });

    test('una carpeta de un sitio de descargas es cosa del usuario', () {
      // Ahi hay que entrar y elegir: son varios ficheros detras de una espera,
      // un captcha o un listado.
      for (final url in [
        'https://mega.nz/folder/abc',
        'https://pixeldrain.com/l/abc',
        'https://gofile.io/d/abc',
        'https://drive.google.com/drive/folders/abc',
        'https://www.mediafire.com/folder/abc',
        'https://bunkr.si/a/abc',
      ]) {
        expect(
          classifyPostLink(url).kind,
          PostLinkKind.repositoryFolder,
          reason: url,
        );
      }
    });

    test('un fichero suelto no es una carpeta', () {
      for (final url in [
        'https://mega.nz/file/abc#clave',
        'https://www.mediafire.com/file/abc/foto.png/file',
        'https://cyberdrop.me/f/abc',
      ]) {
        expect(
          classifyPostLink(url).kind,
          PostLinkKind.repositoryFile,
          reason: url,
        );
      }
    });

    test('lo que se puede pedir directo se baja como cualquier otra cosa', () {
      // Es lo que hace que un enlace a un solo contenido no pare nada ni
      // pregunte nada: se deduce su direccion de fichero y se descarga.
      final drive = classifyPostLink(
        'https://drive.google.com/file/d/ABC123/view?usp=sharing',
      );
      expect(drive.kind, PostLinkKind.repositoryFile);
      expect(drive.isDownloadable, isTrue);
      expect(drive.needsUser, isFalse);
      expect(drive.downloadUrl, contains('id=ABC123'));

      final pixeldrain = classifyPostLink('https://pixeldrain.com/u/XYZ');
      expect(pixeldrain.isDownloadable, isTrue);
      expect(pixeldrain.downloadUrl, 'https://pixeldrain.com/api/file/XYZ?download');

      final dropbox =
          classifyPostLink('https://www.dropbox.com/s/abc/foto.png?dl=0');
      expect(dropbox.downloadUrl, contains('dl=1'));
    });

    test('lo que no se puede pedir directo sigue necesitando al usuario', () {
      // Mega cifra en el navegador: ni con la direccion se puede bajar de aqui.
      final mega = classifyPostLink('https://mega.nz/file/abc#clave');

      expect(mega.isDownloadable, isFalse);
      expect(mega.needsUser, isTrue);
      expect(mega.downloadUrl, mega.url);
    });

    test('una forma que no se reconoce se da por carpeta', () {
      // Lo prudente: ensenarsela al usuario en vez de bajar a ciegas algo que no
      // se sabe que es.
      expect(
        classifyPostLink('https://gofile.io/algo/raro').kind,
        PostLinkKind.repositoryFolder,
      );
    });

    test('todo lo demás se pasa por alto', () {
      // Plataformas de pago, la publicación original, redes sociales: no dan el
      // contenido, así que no hay nada que intentar.
      for (final url in [
        'https://www.fanbox.cc/@alguien',
        'https://www.patreon.com/posts/123',
        'https://x.com/alguien/status/1',
        'https://algo.desconocido.test/pagina',
      ]) {
        expect(classifyPostLink(url).kind, PostLinkKind.other, reason: url);
      }
    });

    test('se sacan del cuerpo sin repetirse y en su orden', () {
      final links = linksInPost('''
        <a href="https://cdn.test/una.jpg">uno</a>
        <a href='https://cdn.test/dos.zip'>dos</a>
        <a href="https://cdn.test/una.jpg">otra vez la primera</a>
      ''');

      expect(links.map((link) => link.url), [
        'https://cdn.test/una.jpg',
        'https://cdn.test/dos.zip',
      ]);
    });
  });

  group('cuándo se pregunta al usuario', () {
    final unLink = [
      const PostLink(url: 'https://cdn.test/una.jpg', kind: PostLinkKind.media),
    ];
    final dosLinks = [
      ...unLink,
      const PostLink(url: 'https://cdn.test/dos.zip', kind: PostLinkKind.archive),
    ];

    test('con un solo enlace no se pregunta: se trae', () async {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      final choice = await decisions.chooseLinks(_request(unLink));

      expect(answers.asked, 0);
      expect(choice.accepts(unLink.first), isTrue);
    });

    test('con varios se aparca, y la importacion sigue', () async {
      final answers = _Answers(const LinkChoice(kind: LinkChoiceKind.all));
      final decisions = ImportDecisions()..handler = answers;

      final choice = await decisions.chooseLinks(_request(dosLinks));

      // Lo que importa: **no se espera a nadie**. Antes esto se quedaba parado
      // delante de un dialogo, y ese dialogo se perdia en cuanto alguien se iba
      // al navegador a mirar uno de los enlaces.
      expect(answers.parked, hasLength(1));
      expect(choice.accepts(dosLinks.first), isFalse,
          reason: 'de esta, nada por ahora: ya se decidira');
    });

    test('lo aparcado lleva de donde salio', () async {
      // La respuesta llega a destiempo, cuando la importacion ya ha terminado:
      // si no llevara la fuente y el nombre, no habria a quien preguntarselo.
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      await decisions.chooseLinks(_request(dosLinks));

      expect(answers.parked.single.source, ImportSource.pawchive);
      expect(answers.parked.single.namePrefix, 'pawchive_1_link');
      expect(answers.parked.single.links, dosLinks);
    });

    test('una seleccion solo deja pasar lo marcado', () {
      final choice = LinkChoice(
        kind: LinkChoiceKind.selection,
        selected: {dosLinks.last.url},
      );

      expect(choice.accepts(dosLinks.first), isFalse);
      expect(choice.accepts(dosLinks.last), isTrue);
    });

    test('lo que vale para todo deja de aparcar', () async {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      await decisions.chooseLinks(_request(dosLinks));

      // Es lo que contesta el usuario al abrir la tarea marcando la casilla.
      decisions.applyToEverything(
        const LinkChoice(kind: LinkChoiceKind.all, applyToAll: true),
      );

      final after = await decisions.chooseLinks(_request(dosLinks));

      expect(answers.parked, hasLength(1), reason: 'no se aparca otra vez');
      expect(after.accepts(dosLinks.first), isTrue);
    });

    test('y se olvida al empezar otra importación', () async {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      decisions.applyToEverything(
        const LinkChoice(kind: LinkChoiceKind.all, applyToAll: true),
      );
      decisions.reset();

      await decisions.chooseLinks(_request(dosLinks));

      expect(answers.parked, hasLength(1),
          reason: 'lo respondido valia para aquella, no para siempre');
    });

    test('sin nadie a quien preguntar no se trae nada', () async {
      final decisions = ImportDecisions();

      final choice = await decisions.chooseLinks(_request(dosLinks));

      expect(choice.accepts(dosLinks.first), isFalse);
    });

  });

  group('lo que queda pendiente', () {
    const carpeta = PostLink(
      url: 'https://mega.nz/folder/abc',
      kind: PostLinkKind.repositoryFolder,
    );

    test('apuntarlo no ensena nada', () async {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      decisions.notePendingLinks('Una', [carpeta]);
      decisions.notePendingLinks('Otra', [carpeta]);

      // Antes cada publicacion abria su propio aviso segun iba llegando, sin
      // esperar a que se cerrara el anterior.
      expect(answers.summaries, 0);
      expect(decisions.pendingCount, 2);
    });

    test('se ensena una sola vez, al final, con todo dentro', () async {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      decisions.notePendingLinks('Una', [carpeta]);
      decisions.notePendingLinks('Otra', [carpeta]);
      await decisions.flushPendingLinks();

      expect(answers.summaries, 1);
      expect(answers.shown, hasLength(2));
    });

    test('lo que se puede bajar solo no queda pendiente de nadie', () async {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      decisions.notePendingLinks('Una', [
        classifyPostLink('https://pixeldrain.com/u/XYZ'),
        classifyPostLink('https://cdn.test/una.jpg'),
      ]);
      await decisions.flushPendingLinks();

      expect(answers.summaries, 0, reason: 'no hay nada que contar');
    });

    test('sin nada pendiente no se ensena nada', () async {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      await decisions.flushPendingLinks();

      expect(answers.summaries, 0);
    });

    test('ensenarlo lo olvida: no se cuenta dos veces', () async {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      decisions.notePendingLinks('Una', [carpeta]);
      await decisions.flushPendingLinks();
      await decisions.flushPendingLinks();

      expect(answers.summaries, 1);
    });

    test('empezar otra importacion no arrastra lo de la anterior', () async {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      decisions.notePendingLinks('Una', [carpeta]);
      decisions.reset();
      await decisions.flushPendingLinks();

      expect(answers.summaries, 0);
    });
  });
}
