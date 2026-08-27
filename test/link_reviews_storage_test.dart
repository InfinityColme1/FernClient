// Que las preguntas aparcadas sobrevivan a cerrar la aplicacion.
//
// Aparcar una es decir «esto lo miro otro dia», y otro dia suele ser despues de
// cerrar. Perderlas al cerrar convertiria aparcar en tirar — y con ellas se van
// los enlaces de esa publicacion, que ya no se pueden recuperar porque la
// importacion de la que salieron no se va a repetir.

import 'package:Fern/features/media/data/services/link_reviews_storage.dart';
import 'package:Fern/features/media/data/services/pending_link_reviews.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

LinkReview _review({
  String jobId = 'job-1',
  String title = 'Una publicacion',
  List<PostLink> links = const [
    PostLink(url: 'https://cdn.test/una.jpg', kind: PostLinkKind.media),
    PostLink(
      url: 'https://pixeldrain.com/u/XYZ',
      kind: PostLinkKind.repositoryFile,
      directUrl: 'https://pixeldrain.com/api/file/XYZ?download',
    ),
  ],
}) {
  return LinkReview(
    jobId: jobId,
    postTitle: title,
    links: links,
    source: ImportSource.pawchive,
    namePrefix: 'pawchive_7_link',
    sourceUrls: const ['https://pawchive.pw/algo/7'],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LinkReviewsStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LinkReviewsStorage(
      preferences: await SharedPreferences.getInstance(),
    );
  });

  test('sin nada guardado no hay nada que recuperar', () {
    expect(storage.read(), isEmpty);
  });

  test('lo guardado vuelve entero', () async {
    await storage.write([_review()]);

    final back = storage.read().single;

    expect(back.postTitle, 'Una publicacion');
    expect(back.source, ImportSource.pawchive);
    expect(back.namePrefix, 'pawchive_7_link');
    expect(back.sourceUrls, ['https://pawchive.pw/algo/7']);
    expect(back.links, hasLength(2));
  });

  test('los enlaces vuelven con su clase y su direccion directa', () async {
    // Sin la direccion directa, un enlace que Fern sabia bajar solo pasaria a
    // necesitar al usuario despues de reiniciar.
    await storage.write([_review()]);

    final links = storage.read().single.links;

    expect(links.first.kind, PostLinkKind.media);
    expect(links.last.kind, PostLinkKind.repositoryFile);
    expect(links.last.isDownloadable, isTrue);
    expect(links.last.downloadUrl, contains('api/file/XYZ'));
  });

  test('el identificador de tarea no se guarda', () async {
    // No significa nada fuera de aquella sesion: la tarea se vuelve a crear al
    // arrancar y con ella un identificador nuevo.
    await storage.write([_review(jobId: 'job-de-antes')]);

    expect(storage.read().single.jobId, isEmpty);
  });

  test('guardar una lista vacia borra lo que hubiera', () async {
    await storage.write([_review()]);
    await storage.write([]);

    expect(storage.read(), isEmpty);
  });

  test('una entrada rota no impide leer las demas', () async {
    SharedPreferences.setMockInitialValues({
      'pending_link_reviews': ['esto no es json', '{"title":"sin enlaces"}'],
    });

    final other = LinkReviewsStorage(
      preferences: await SharedPreferences.getInstance(),
    );

    // Entre perder una pregunta y no arrancar, lo primero.
    expect(other.read(), isEmpty);
  });

  test('la tienda guarda sola al cambiar', () async {
    final saved = <List<LinkReview>>[];
    final reviews = PendingLinkReviews()
      ..persist = (all) async => saved.add(all);

    reviews.add(_review());
    reviews.remove('job-1');

    expect(saved, hasLength(2));
    expect(saved.first, hasLength(1));
    expect(saved.last, isEmpty);
  });

  test('y sin nadie que guarde sigue funcionando', () {
    final reviews = PendingLinkReviews()..add(_review());

    expect(reviews.has('job-1'), isTrue);
  });
}
