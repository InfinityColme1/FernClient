// Lo que mide cada contenido, guardado.
//
// La rejilla necesita las proporciones de cada celda para colocarla, y
// averiguarlas obliga a cargar el fichero entero en memoria para leerle la
// cabecera. Con mil trescientos contenidos eso son mil trescientas lecturas
// completas de disco **cada vez que se abre la pantalla**, y es lo que hacia que
// desplazarse deprisa fuera a tirones.
//
// Guardarlo lo convierte en ninguna. Aqui se comprueban las dos mitades: que la
// celda no vaya al fichero cuando ya lo sabe, y que lo que descubre se guarde en
// tandas y una sola vez.

import 'package:Fern/core/services/media_size_store.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/presentation/widgets/media_item.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('la celda', () {
    setUp(() => MediaSizeStore.instance.reset());
    tearDown(() => MediaSizeStore.instance.reset());

    /// Pinta una celda de un fichero **que no existe**: si la celda tuviera que
    /// abrirlo para colocarse, no podria colocarse.
    Future<double> ratioOf(WidgetTester tester, MediaSummaryEntity media) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(width: 400, child: MediaItem(media: media)),
        ),
      ));
      await tester.pump();

      return tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio;
    }

    testWidgets('se coloca con lo guardado, sin abrir el fichero',
        (tester) async {
      final ratio = await ratioOf(
        tester,
        const MediaSummaryEntity(
          id: 1,
          path: 'C:/no/existe.jpg',
          width: 800,
          height: 400,
        ),
      );

      expect(ratio, 2.0);
    });

    testWidgets('sin saber lo que mide se coloca con la medida de reserva',
        (tester) async {
      final ratio = await ratioOf(
        tester,
        const MediaSummaryEntity(id: 1, path: 'C:/no/existe.jpg'),
      );

      // Y no se queda sin colocar: una celda sin alto rompe la rejilla entera.
      expect(ratio, greaterThan(0));
    });

    testWidgets('un tamano a medias no se cree', (tester) async {
      final ratio = await ratioOf(
        tester,
        const MediaSummaryEntity(id: 1, path: 'C:/no/existe.jpg', width: 800),
      );

      expect(ratio, isNot(0));
    });
  });

  group('lo que la rejilla descubre', () {
    setUp(() => MediaSizeStore.instance.reset());
    tearDown(() => MediaSizeStore.instance.reset());

    test('se guarda en tandas, no de una en una', () async {
      final written = <Map<int, MediaSize>>[];
      MediaSizeStore.instance.writer = (sizes) async => written.add(sizes);

      for (var id = 1; id <= 5; id++) {
        MediaSizeStore.instance.remember(id, width: 100, height: 50);
      }

      // Al desplazarse se descubren decenas por segundo: una transaccion por
      // cada una seria peor que el problema que resuelve.
      expect(written, isEmpty);
      expect(MediaSizeStore.instance.pendingCount, 5);

      await MediaSizeStore.instance.flush();

      expect(written, hasLength(1));
      expect(written.single, hasLength(5));
    });

    test('el mismo contenido dos veces cuenta una', () async {
      final written = <Map<int, MediaSize>>[];
      MediaSizeStore.instance.writer = (sizes) async => written.add(sizes);

      MediaSizeStore.instance.remember(1, width: 100, height: 50);
      MediaSizeStore.instance.remember(1, width: 100, height: 50);
      await MediaSizeStore.instance.flush();

      expect(written.single, hasLength(1));
    });

    test('una medida imposible no se guarda', () async {
      final written = <Map<int, MediaSize>>[];
      MediaSizeStore.instance.writer = (sizes) async => written.add(sizes);

      MediaSizeStore.instance.remember(1, width: 0, height: 50);
      MediaSizeStore.instance.remember(2, width: 100, height: -1);
      await MediaSizeStore.instance.flush();

      expect(written, isEmpty);
    });

    test('guardar dos veces seguidas no repite la tanda', () async {
      final written = <Map<int, MediaSize>>[];
      MediaSizeStore.instance.writer = (sizes) async => written.add(sizes);

      MediaSizeStore.instance.remember(1, width: 100, height: 50);
      await MediaSizeStore.instance.flush();
      await MediaSizeStore.instance.flush();

      expect(written, hasLength(1));
    });

    test('que la escritura falle no deja nada roto', () async {
      MediaSizeStore.instance.writer = (_) async => throw StateError('sin disco');

      MediaSizeStore.instance.remember(1, width: 100, height: 50);

      // Lo unico que se pierde es haberlo guardado: la proxima vez que se pinte
      // esa celda se vuelve a descubrir.
      await MediaSizeStore.instance.flush();

      expect(MediaSizeStore.instance.pendingCount, 0);
    });

    test('sin nadie que escriba no se rompe nada', () async {
      MediaSizeStore.instance.remember(1, width: 100, height: 50);

      await MediaSizeStore.instance.flush();

      expect(MediaSizeStore.instance.pendingCount, 0);
    });
  });
}
