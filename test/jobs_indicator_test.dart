// El indicador de trabajos en segundo plano.
//
// Lo que hay que sostener es que **esté siempre y apagado** mientras no haya
// nada que contar —aparecer y desaparecer movía los botones de al lado justo
// cuando se iba a pulsar uno—, que se encienda en cuanto lo hay, que diga de qué
// va cada trabajo, y que un fallo se siga viendo cuando ya no queda nada
// corriendo.
//
// Tres cuidados propios de este widget:
//
// - La cola y el bloc se montan dentro de cada prueba y no en un `setUp`: quien
//   se suscribe a un `Stream` lo hace en la zona asíncrona desde la que llama, y
//   `pump` sólo vacía la del cuerpo de la prueba. Montándolos fuera, lo que
//   emite la cola no llega nunca a la interfaz.
// - Se cierran en el `tearDown` y no dentro de la prueba: esperar a que un bloc
//   cierre desde dentro deja la zona asíncrona esperando por siempre.
// - Ningún trabajo se queda en marcha al acabar: la barra de progreso sin total
//   conocido se anima sin fin y dejaría un temporizador vivo.

import 'dart:async';

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/jobs/presentation/blocs/jobs_bloc.dart';
import 'package:Fern/features/jobs/presentation/widgets/jobs_indicator.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

JobQueue? openQueue;
JobsBloc? openBloc;

/// Monta la cola y su bloc, y los deja apuntados para cerrarlos al terminar.
JobQueue newQueue() {
  final queue = JobQueue();
  openQueue = queue;
  openBloc = JobsBloc(queue: queue);

  return queue;
}

Future<void> pumpIndicator(WidgetTester tester) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<JobsBloc>.value(
      value: openBloc!,
      child: const Scaffold(
        body: Align(alignment: Alignment.topRight, child: JobsIndicator()),
      ),
    ),
  ));
}

/// Deja que lo que ha emitido la cola llegue al bloc y de ahí a la pantalla.
Future<void> settleQueue(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  tearDown(() async {
    await openBloc?.close();
    await openQueue?.dispose();
    openBloc = null;
    openQueue = null;
  });

  /// Si el boton se puede pulsar.
  bool canOpen(WidgetTester tester) =>
      tester.widget<IconButton>(find.byType(IconButton)).onPressed != null;

  testWidgets('sin nada en marcha esta, pero apagado', (tester) async {
    newQueue();

    await pumpIndicator(tester);

    // Ocupa su sitio para que los botones de al lado no bailen, y en gris dice
    // que no hay nada corriendo, que es informacion.
    expect(find.byType(IconButton), findsOneWidget);
    expect(canOpen(tester), isFalse);
  });

  testWidgets('apagado no abre nada', (tester) async {
    newQueue();

    await pumpIndicator(tester);
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    final texts = await AppLocalizations.delegate.load(const Locale('en'));

    // Un panel que solo dice «no hay nada» es un clic tirado.
    expect(find.text(texts.jobsTitle), findsNothing);
  });

  testWidgets('aparece mientras hay algo corriendo y dice por dónde va',
      (tester) async {
    final queue = newQueue();
    final gate = Completer<void>();

    queue.register(JobType.training, (context) async {
      context.report(2, total: 8);
      await Future.any([gate.future, context.token.whenCancelled]);
      context.token.throwIfCancelled();
    });

    await pumpIndicator(tester);
    expect(canOpen(tester), isFalse);

    final id = queue.enqueue(
      type: JobType.training,
      total: 8,
      payload: const {Job.nameKey: 'Figuras de prueba'},
    );
    await settleQueue(tester);

    expect(canOpen(tester), isTrue);

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final texts = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(texts.jobsTitle), findsOneWidget);
    expect(find.text(texts.jobProgress(2, 8)), findsOneWidget);

    // De que modelo: se pueden encolar varios, y «Entrenando modelo» tres veces
    // seguidas no distingue cual se esta parando al pulsar el aspa.
    expect(
      find.text(texts.jobTrainingModel('Figuras de prueba')),
      findsOneWidget,
    );

    // El aspa de la fila para ese trabajo.
    await tester.tap(find.widgetWithIcon(IconButton, Icons.close));
    await settleQueue(tester);

    expect(
      queue.jobs.firstWhere((job) => job.id == id).status,
      JobStatus.cancelled,
    );

    gate.complete();
    await settleQueue(tester);
  });

  testWidgets('un fallo se sigue viendo cuando ya no queda nada corriendo',
      (tester) async {
    final queue = newQueue();

    queue.register(JobType.duplicateScan, (context) async {
      throw StateError('se ha roto');
    });

    await pumpIndicator(tester);

    queue.enqueue(type: JobType.duplicateScan);
    await settleQueue(tester);
    await settleQueue(tester);

    expect(canOpen(tester), isTrue);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
