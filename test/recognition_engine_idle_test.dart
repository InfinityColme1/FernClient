// El sidecar se cierra solo cuando nadie lo usa. La cuestion es que cuenta como
// «nadie lo usa».
//
// Contando desde que se mando la peticion, un entrenamiento —que es **una sola
// peticion que dura horas**— mataba al sidecar a los diez minutos, y el
// entrenamiento se caia con «se paro mientras se le hablaba». Es exactamente lo
// que paso la primera vez que se probo de verdad, y son horas de maquina tiradas
// sin nada que las explique.
//
// Inactividad es que no haya nada que hacer, no que lo que hay tarde.

import 'dart:async';
import 'dart:convert';

import 'package:Fern/features/recognition/data/services/recognition_engine.dart';
import 'package:Fern/features/recognition/data/services/sidecar_client.dart';
import 'package:Fern/features/recognition/data/services/sidecar_paths.dart';
import 'package:Fern/features/recognition/data/services/sidecar_process.dart';
import 'package:Fern/features/recognition/data/services/sidecar_provisioner.dart';
import 'package:Fern/features/recognition/data/services/uv_bootstrap.dart';
import 'package:Fern/features/settings/data/services/recognition_storage_service.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un sidecar de mentira: apunta lo que se le manda y contesta cuando se le
/// dice, no antes.
class _FakeChannel implements SidecarChannel {
  final _lines = StreamController<String>.broadcast();
  final _exited = Completer<void>();

  final sent = <Map<String, dynamic>>[];
  var isDead = false;

  @override
  Stream<String> get lines => _lines.stream;

  @override
  Future<void> get exited => _exited.future;

  @override
  void send(String line) {
    final message = jsonDecode(line) as Map<String, dynamic>;
    sent.add(message);

    // El sidecar de verdad contesta al adios y se va. Sin esto, cerrarlo se
    // queda esperando cinco segundos a un muerto en cada prueba.
    if (message['method'] == 'shutdown') {
      scheduleMicrotask(() => answerTo(message['id'], const {}));
    }
  }

  @override
  Future<void> kill() async {
    if (isDead) return;

    isDead = true;
    if (!_exited.isCompleted) _exited.complete();
    await _lines.close();
  }

  /// Espera a que hayan salido [count] peticiones.
  ///
  /// Mandar una pasa por arrancar el sidecar, que es asincrono: contestar antes
  /// de que haya salido es contestar a nadie.
  Future<void> waitForRequests(int count) async {
    while (sent.length < count) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  /// Contesta a la ultima peticion que se mando.
  void answer(Map<String, dynamic> result) {
    _lines.add(jsonEncode({'id': sent.last['id'], 'ok': true, 'result': result}));
  }

  /// Contesta a una peticion concreta, que no tiene por que ser la ultima.
  void answerTo(Object? id, Map<String, dynamic> result) {
    _lines.add(jsonEncode({'id': id, 'ok': true, 'result': result}));
  }

  /// Contesta con un error.
  void fail(String code, String message) {
    _lines.add(jsonEncode({
      'id': sent.last['id'],
      'ok': false,
      'error': {'code': code, 'message': message},
    }));
  }

  /// Manda un avance, como una epoca de un entrenamiento.
  void progress(Map<String, dynamic> data) {
    _lines.add(jsonEncode({
      'id': sent.last['id'],
      'event': 'progress',
      'data': data,
    }));
  }
}

/// Un provisionador que dice que todo esta puesto, sin tocar el disco.
class _ReadyProvisioner extends SidecarProvisioner {
  _ReadyProvisioner(SidecarPaths paths)
      : super(paths: paths, bootstrap: UvBootstrap(paths: paths));

  @override
  bool get isReady => true;

  @override
  Future<void> writeScript({bool force = false}) async {}
}

class _FakeSettings implements SettingsRepository {
  @override
  AppSettingsEntity getSettings() => const AppSettingsEntity(
        avatarsPath: r'C:\fern\avatars',
        recognitionPath: r'C:\fern\recognition',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

void main() {
  late _FakeChannel channel;
  late RecognitionEngine engine;

  setUp(() {
    channel = _FakeChannel();

    engine = RecognitionEngine(
      storage: RecognitionStorageService(settingsRepository: _FakeSettings()),
      provisionerFactory: _ReadyProvisioner.new,
      launch: (_, _) async => channel,
      // Cortito, para no tener que esperar diez minutos a que se vea el fallo.
      idleTimeout: const Duration(milliseconds: 60),
    );
  });

  tearDown(() => engine.dispose());

  /// Deja pasar de sobra el tiempo de inactividad.
  Future<void> waitOutTheIdleTimer() =>
      Future<void>.delayed(const Duration(milliseconds: 200));

  test('con un entrenamiento en marcha, el sidecar no se cierra', () async {
    final training = engine.train(const {'epochs': 50});

    await waitOutTheIdleTimer();

    // Un entrenamiento es una sola peticion que dura horas. Cerrarlo aqui es
    // tirar todo lo que llevara aprendido.
    expect(channel.isDead, isFalse);

    channel.answer(const {'weights': 'C:/runs/best.pt'});
    await training;
  });

  test('el sidecar se cierra cuando por fin no hay nada que hacer', () async {
    final training = engine.train(const {});
    await channel.waitForRequests(1);
    channel.answer(const {'weights': 'C:/runs/best.pt'});
    await training;

    await waitOutTheIdleTimer();

    // Mantener torch cargado sin motivo se come la memoria.
    expect(channel.isDead, isTrue);
  });

  test('con el entrenamiento fallando tampoco se queda abierto', () async {
    final training = engine.train(const {});
    await channel.waitForRequests(1);

    channel.fail('OUT_OF_MEMORY', 'sin memoria');

    await expectLater(training, throwsA(isA<SidecarException>()));
    await waitOutTheIdleTimer();

    // Que se caiga no es razon para dejar el proceso vivo: la cuenta de lo que
    // hay en marcha tiene que bajar igual.
    expect(channel.isDead, isTrue);
  });

  test('los avances por el camino no lo cierran ni lo mantienen de mas',
      () async {
    final epochs = <int>[];
    final training = engine.train(
      const {},
      onProgress: (data) => epochs.add(data['epoch'] as int),
    );

    await channel.waitForRequests(1);
    channel.progress(const {'epoch': 1});
    await Future<void>.delayed(const Duration(milliseconds: 100));
    channel.progress(const {'epoch': 2});

    expect(channel.isDead, isFalse);

    channel.answer(const {});
    await training;

    expect(epochs, [1, 2]);
  });

  test('dos peticiones a la vez: no se cierra hasta que acaban las dos',
      () async {
    final first = engine.train(const {});
    await channel.waitForRequests(1);
    final firstId = channel.sent.last['id'];

    final second = engine.inspect('C:/pesos.pt');
    await channel.waitForRequests(2);

    // Contestar sólo a la primera no basta.
    channel.answerTo(firstId, const {});
    await first;
    await waitOutTheIdleTimer();

    expect(channel.isDead, isFalse);

    channel.answer(const {'classes': ['perro']});
    await second;
    await waitOutTheIdleTimer();

    expect(channel.isDead, isTrue);
  });
}
