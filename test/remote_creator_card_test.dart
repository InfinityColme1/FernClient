// La tarjeta de un creador remoto.
//
// Es la celda con la que se elige de quien traerse contenido, y lo unico que
// tiene que hacer bien es **parecer que se puede pulsar** y decir las tres cosas
// que deciden si merece la pena: quien es, cuanto ha publicado desde la ultima
// vez, y si ya se le tiene dado de alta aqui.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/remote_creator.dart';
import 'package:Fern/features/media/presentation/widgets/remote_creator_card.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

Future<void> _pump(
  WidgetTester tester,
  RemoteCreator creator, {
  bool isSelected = false,
  VoidCallback? onTap,
  VoidCallback? onSelectionToggled,
}) async {
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: remoteCreatorCardWidth,
          height: remoteCreatorCardHeight,
          child: RemoteCreatorCard(
            creator: creator,
            isSelected: isSelected,
            onTap: onTap,
            onSelectionToggled: onSelectionToggled,
          ),
        ),
      ),
    ),
  ));
}

const _creator = RemoteCreator(
  id: 'algo-1',
  name: 'Marinette',
  service: 'algo',
  newPosts: 3,
);

void main() {
  testWidgets('cabe en su celda, sin desbordarse', (tester) async {
    // Es lo que se salia por encima del borde de la superficie: una tarjeta mas
    // alta que su hueco.
    await _pump(tester, _creator);

    expect(tester.takeException(), isNull);
  });

  testWidgets('con todo puesto tambien cabe', (tester) async {
    await _pump(
      tester,
      const RemoteCreator(
        id: 'algo-1',
        name: 'Un nombre bastante largo de los que hay',
        service: 'unaplataforma',
        newPosts: 128,
        knownCreatorId: 7,
      ),
      onSelectionToggled: () {},
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('y con la fecha en lugar de la cuenta, igual', (tester) async {
    // La fecha es mas larga que la cuenta, asi que es su propio caso peor: la
    // otra prueba no lo cubre porque las dos nunca se ensenan a la vez.
    await _pump(
      tester,
      RemoteCreator(
        id: 'algo-1',
        name: 'Un nombre bastante largo de los que hay',
        service: 'unaplataforma',
        lastImport: DateTime(2026, 12, 31),
        knownCreatorId: 7,
      ),
      onSelectionToggled: () {},
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('el raton encima la hace crecer', (tester) async {
    await _pump(tester, _creator, onTap: () {});

    double scaleOf() => tester
        .widget<AnimatedScale>(find.byType(AnimatedScale))
        .scale;

    expect(scaleOf(), 1.0);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    await mouse.moveTo(tester.getCenter(find.byType(RemoteCreatorCard)));
    await tester.pump();

    // Sin esto no parecia que se pudiera pulsar.
    expect(scaleOf(), greaterThan(1.0));
  });

  testWidgets('pulsarla pide traerse lo suyo', (tester) async {
    var taps = 0;
    await _pump(tester, _creator, onTap: () => taps++);

    await tester.tap(find.byType(RemoteCreatorCard));

    expect(taps, 1);
  });

  testWidgets('dice cuantas nuevas tiene', (tester) async {
    await _pump(tester, _creator);

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.text(texts.remoteCreatorNewPosts(3)), findsOneWidget);
  });

  testWidgets('sin la cuenta ensena cuando se importo, no un cero', (tester) async {
    // Un cero significa «no ha publicado nada», que es lo contrario de «no lo
    // se». Y contar cuesta una peticion por creador, asi que con cincuenta
    // marcados casi nunca llega: lo que se ensena mientras tanto sale de esta
    // maquina y esta desde el primer momento.
    await _pump(
      tester,
      RemoteCreator(
        id: 'a',
        name: 'Sin contar',
        lastImport: DateTime(2026, 8, 12),
      ),
    );

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.text(texts.remoteCreatorNewPosts(0)), findsNothing);
    expect(
      find.text(texts.remoteCreatorLastImport(
        DateFormat.yMMMd('es').format(DateTime(2026, 8, 12)),
      )),
      findsOneWidget,
    );
  });

  testWidgets('y avisa si ha publicado desde entonces', (tester) async {
    // Sin ninguna peticion: la fecha de aqui sale del disco y la suya viene en el
    // mismo listado que trajo la tarjeta.
    await _pump(
      tester,
      RemoteCreator(
        id: 'a',
        name: 'Con novedades',
        lastImport: DateTime(2026, 8, 12),
        updatedAt: DateTime.utc(2026, 8, 20),
      ),
    );

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    expect(
      find.text(texts.remoteCreatorNewsSince(
        DateFormat.yMMMd('es').format(DateTime(2026, 8, 12)),
      )),
      findsOneWidget,
    );
  });

  testWidgets('y no avisa si no ha publicado nada', (tester) async {
    await _pump(
      tester,
      RemoteCreator(
        id: 'a',
        name: 'Sin novedades',
        lastImport: DateTime(2026, 8, 20),
        updatedAt: DateTime.utc(2026, 8, 12),
      ),
    );

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    expect(
      find.text(texts.remoteCreatorLastImport(
        DateFormat.yMMMd('es').format(DateTime(2026, 8, 20)),
      )),
      findsOneWidget,
    );
  });

  testWidgets('y del que nunca se ha importado lo dice', (tester) async {
    // No es la ausencia de un dato: es el dato, y ademas el que mas dice de una
    // lista de creadores marcados — ese es el que esta sin estrenar.
    await _pump(tester, const RemoteCreator(id: 'a', name: 'Sin estrenar'));

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.text(texts.remoteCreatorNeverImported), findsOneWidget);
  });

  testWidgets('el que ya se tiene sale marcado', (tester) async {
    await _pump(
      tester,
      const RemoteCreator(id: 'a', name: 'Ya lo tienes', knownCreatorId: 3),
    );

    final texts = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.text(texts.remoteCreatorKnown), findsOneWidget);
  });
}
