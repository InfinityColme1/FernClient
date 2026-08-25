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

  // El panel rehecho con la forma de un gestor de descargas: se distingue una
  // fila de otra de un vistazo, el estado va pegado a su nombre y cada tarea se
  // para o se quita por su cuenta, sin arrastrar a las demás.
  group('el panel como gestor de descargas', () {
    /// Abre el panel.
    Future<void> openPanel(WidgetTester tester) async {
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('cada fila lleva el icono de su clase', (tester) async {
      final queue = newQueue();
      final gate = Completer<void>();

      for (final type in [JobType.training, JobType.hashing]) {
        queue.register(type, (context) async {
          await Future.any([gate.future, context.token.whenCancelled]);
          context.token.throwIfCancelled();
        });
      }

      await pumpIndicator(tester);

      queue.enqueue(type: JobType.training, total: 4);
      queue.enqueue(type: JobType.hashing, total: 4);
      await settleQueue(tester);
      await openPanel(tester);

      // Sin esto son dos líneas de texto parecidas y hay que leerlas enteras
      // para saber cuál se está parando.
      expect(find.byIcon(JobType.training.icon), findsOneWidget);
      expect(find.byIcon(JobType.hashing.icon), findsOneWidget);

      gate.complete();
      await settleQueue(tester);
      await settleQueue(tester);
    });

    testWidgets('el estado va pegado a su nombre, no descolgado abajo',
        (tester) async {
      final queue = newQueue();

      queue.register(JobType.duplicateScan, (context) async {
        throw StateError('se ha roto');
      });

      await pumpIndicator(tester);

      queue.enqueue(type: JobType.duplicateScan);
      await settleQueue(tester);
      await settleQueue(tester);
      await openPanel(tester);

      final texts = await AppLocalizations.delegate.load(const Locale('en'));

      final title = tester.getTopLeft(find.text(texts.jobDuplicateScan));
      final status = tester.getTopLeft(find.text(texts.jobFailed));

      // Debajo, y a un renglón: el «terminada» caía tan abajo que parecía de la
      // fila siguiente.
      expect(status.dy, greaterThan(title.dy));
      expect(status.dy - title.dy, lessThan(24));
      // Y alineado con él, no centrado ni sangrado.
      expect(status.dx, title.dx);
    });

    testWidgets('una tarea terminada se quita sola, sin llevarse las demás',
        (tester) async {
      final queue = newQueue();

      queue.register(JobType.duplicateScan, (context) async {
        throw StateError('se ha roto');
      });
      queue.register(JobType.hashing, (context) async {
        throw StateError('esta también');
      });

      await pumpIndicator(tester);

      final first = queue.enqueue(type: JobType.duplicateScan);
      final second = queue.enqueue(type: JobType.hashing);
      await settleQueue(tester);
      await settleQueue(tester);
      await openPanel(tester);

      expect(find.byIcon(Icons.clear), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.clear).first);
      await settleQueue(tester);

      // Antes sólo estaba «vaciar terminadas»: para hacer desaparecer un fallo
      // ya visto había que borrar también los que no se habían mirado.
      expect(queue.jobs.any((job) => job.id == first), isFalse);
      expect(queue.jobs.any((job) => job.id == second), isTrue);
    });

    testWidgets('la que sigue viva se para, no se quita', (tester) async {
      final queue = newQueue();
      final gate = Completer<void>();

      queue.register(JobType.training, (context) async {
        await Future.any([gate.future, context.token.whenCancelled]);
        context.token.throwIfCancelled();
      });

      await pumpIndicator(tester);

      queue.enqueue(type: JobType.training, total: 4);
      await settleQueue(tester);
      await openPanel(tester);

      // Quitar de la lista algo que sigue corriendo lo dejaría trabajando sin
      // que nadie pudiera pararlo ya.
      expect(find.byIcon(Icons.clear), findsNothing);
      expect(find.widgetWithIcon(IconButton, Icons.close), findsOneWidget);

      gate.complete();
      await settleQueue(tester);
      await settleQueue(tester);
    });
  });
}
