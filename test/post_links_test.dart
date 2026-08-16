// Qué se hace con los enlaces que trae una publicación.
//
// Es la parte con más criterio de toda la importación: de un enlace hay que
// decidir, sin abrirlo, si lleva a algo que la aplicación puede traerse, a un
// sitio donde tiene que entrar el usuario, o a una página que no da nada. Y
// cuando hay varios a la vez, quien decide es el usuario.

import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un usuario de mentira, que contesta lo que se le diga y apunta cuántas veces
/// le han preguntado.
class _Answers implements ImportDecisionHandler {
  final LinkChoice answer;

  int asked = 0;
  int notices = 0;

  _Answers(this.answer);

  @override
  Future<LinkChoice> chooseLinks(String postTitle, List<PostLink> links) async {
    asked++;
    return answer;
  }

  @override
  Future<void> noticeRepository(String postTitle, List<PostLink> links) async {
    notices++;
  }
}

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

    test('los sitios de descargas son cosa del usuario', () {
      for (final url in [
        'https://mega.nz/folder/abc',
        'https://pixeldrain.com/l/abc',
        'https://gofile.io/d/abc',
        'https://drive.google.com/drive/folders/abc',
      ]) {
        expect(classifyPostLink(url).kind, PostLinkKind.repository, reason: url);
      }
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

      final choice = await decisions.chooseLinks('Una', unLink);

      expect(answers.asked, 0);
      expect(choice.accepts(unLink.first), isTrue);
    });

    test('con varios se pregunta', () async {
      final answers = _Answers(const LinkChoice(kind: LinkChoiceKind.all));
      final decisions = ImportDecisions()..handler = answers;

      await decisions.chooseLinks('Una', dosLinks);

      expect(answers.asked, 1);
    });

    test('una selección sólo deja pasar lo marcado', () async {
      final decisions = ImportDecisions()
        ..handler = _Answers(LinkChoice(
          kind: LinkChoiceKind.selection,
          selected: {dosLinks.last.url},
        ));

      final choice = await decisions.chooseLinks('Una', dosLinks);

      expect(choice.accepts(dosLinks.first), isFalse);
      expect(choice.accepts(dosLinks.last), isTrue);
    });

    test('lo que vale para todo no se vuelve a preguntar', () async {
      final answers = _Answers(
        const LinkChoice(kind: LinkChoiceKind.all, applyToAll: true),
      );
      final decisions = ImportDecisions()..handler = answers;

      await decisions.chooseLinks('Una', dosLinks);
      await decisions.chooseLinks('Otra', dosLinks);
      await decisions.chooseLinks('Y otra', dosLinks);

      expect(answers.asked, 1);
    });

    test('y se olvida al empezar otra importación', () async {
      final answers = _Answers(
        const LinkChoice(kind: LinkChoiceKind.all, applyToAll: true),
      );
      final decisions = ImportDecisions()..handler = answers;

      await decisions.chooseLinks('Una', dosLinks);
      decisions.reset();
      await decisions.chooseLinks('Otra', dosLinks);

      expect(answers.asked, 2);
    });

    test('sin nadie a quien preguntar no se trae nada', () async {
      final decisions = ImportDecisions();

      final choice = await decisions.chooseLinks('Una', dosLinks);

      expect(choice.accepts(dosLinks.first), isFalse);
    });

    test('el aviso de los repositorios no espera respuesta', () {
      final answers = _Answers(const LinkChoice.ignore());
      final decisions = ImportDecisions()..handler = answers;

      decisions.noticeRepository('Una', [
        const PostLink(
          url: 'https://mega.nz/folder/abc',
          kind: PostLinkKind.repository,
        ),
      ]);

      expect(answers.notices, 1);
    });
  });
}
