// El proceso de Python con el que se entrena y se reconoce.
//
// Dos piezas que se pueden probar sin descargar nada ni lanzar ningún proceso.
//
// Las rutas: son lo único de todo el sidecar que mira el sistema operativo, así
// que si están mal el entorno no arranca en un sistema y sí en otro, que es el
// fallo más caro de encontrar.
//
// El cliente: se le enchufa un canal de mentira y se comprueba que empareja cada
// respuesta con su petición, que el progreso llega por el camino, que un error
// del sidecar sale como excepción con su código, y que si el proceso se muere no
// deja a nadie esperando para siempre.

import 'dart:async';
import 'dart:convert';

import 'package:Fern/features/recognition/data/services/sidecar_client.dart';
import 'package:Fern/features/recognition/data/services/sidecar_paths.dart';
import 'package:Fern/features/recognition/data/services/sidecar_process.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Un sidecar de mentira: se le ve lo que se le manda y contesta lo que se le
/// diga.
class _FakeChannel implements SidecarChannel {
  final StreamController<String> _lines = StreamController<String>.broadcast();
  final Completer<void> _exited = Completer<void>();
  final List<Map<String, dynamic>> sent = [];

  @override
  Stream<String> get lines => _lines.stream;

  @override
  void send(String line) {
    sent.add(jsonDecode(line) as Map<String, dynamic>);
  }

  @override
  Future<void> get exited => _exited.future;

  @override
  Future<void> kill() async => die();

  /// La última petición que ha recibido.
  Map<String, dynamic> get last => sent.last;

  void reply(String id, Map<String, dynamic> result) {
    _lines.add(jsonEncode({'id': id, 'ok': true, 'result': result}));
  }

  void fail(String id, String code, String message) {
    _lines.add(jsonEncode({
      'id': id,
      'ok': false,
      'error': {'code': code, 'message': message},
    }));
  }

  void progress(String id, Map<String, dynamic> data) {
    _lines.add(jsonEncode({'id': id, 'event': 'progress', 'data': data}));
  }

  void write(String raw) => _lines.add(raw);

  void die() {
    if (!_exited.isCompleted) _exited.complete();
    if (!_lines.isClosed) _lines.close();
  }
}

SidecarPaths pathsFor(SidecarPlatform platform, {String architecture = 'x86_64'}) {
  return SidecarPaths(
    runtimeDirectory: p.join('C:', 'fern', 'recognition', 'runtime'),
    platform: platform,
    architecture: architecture,
  );
}

void main() {
  group('las rutas del entorno', () {
    test('el Python del entorno está donde lo pone cada sistema', () {
      final windows = pathsFor(SidecarPlatform.windows);
      final linux = pathsFor(SidecarPlatform.linux);
      final macos = pathsFor(SidecarPlatform.macos, architecture: 'arm64');

      expect(windows.venvPython, endsWith(p.join('venv', 'Scripts', 'python.exe')));
      expect(linux.venvPython, endsWith(p.join('venv', 'bin', 'python')));
      expect(macos.venvPython, endsWith(p.join('venv', 'bin', 'python')));
    });

    test('el binario de uv lleva extensión sólo en Windows', () {
      expect(pathsFor(SidecarPlatform.windows).uvExecutable, endsWith('uv.exe'));
      expect(pathsFor(SidecarPlatform.linux).uvExecutable, endsWith('uv'));
      expect(pathsFor(SidecarPlatform.macos).uvExecutable, endsWith('uv'));
    });

    test('cada sistema y arquitectura pide su artefacto', () {
      expect(
        pathsFor(SidecarPlatform.windows).uvAssetName,
        'uv-x86_64-pc-windows-msvc.zip',
      );
      expect(
        pathsFor(SidecarPlatform.macos, architecture: 'arm64').uvAssetName,
        'uv-aarch64-apple-darwin.tar.gz',
      );
      expect(
        pathsFor(SidecarPlatform.macos).uvAssetName,
        'uv-x86_64-apple-darwin.tar.gz',
      );
      expect(
        pathsFor(SidecarPlatform.linux, architecture: 'arm64').uvAssetName,
        'uv-aarch64-unknown-linux-gnu.tar.gz',
      );
    });

    test('sólo el de Windows viene en zip', () {
      expect(pathsFor(SidecarPlatform.windows).uvAssetIsZip, isTrue);
      expect(pathsFor(SidecarPlatform.linux).uvAssetIsZip, isFalse);
      expect(pathsFor(SidecarPlatform.macos).uvAssetIsZip, isFalse);
    });

    test('todo cuelga de la carpeta de runtime y nada de fuera', () {
      final paths = pathsFor(SidecarPlatform.linux);

      for (final route in [
        paths.uvExecutable,
        paths.pythonInstallDirectory,
        paths.venvDirectory,
        paths.venvPython,
        paths.sidecarScript,
        paths.cacheDirectory,
      ]) {
        expect(
          p.isWithin(paths.runtimeDirectory, route),
          isTrue,
          reason: '$route se sale de la carpeta del entorno',
        );
      }
    });

    test('un sistema que no se soporta se reconoce como tal', () {
      expect(SidecarPlatform.fromName('android'), isNull);
      expect(SidecarPlatform.fromName('windows'), SidecarPlatform.windows);
    });
  });

  group('el cliente', () {
    test('empareja la respuesta con su petición', () async {
      final channel = _FakeChannel();
      final client = SidecarClient(channel);

      final answer = client.call('ping');
      await Future<void>.delayed(Duration.zero);

      expect(channel.last['method'], 'ping');
      channel.reply(channel.last['id'] as String, {'pong': true});

      expect(await answer, {'pong': true});
    });

    test('dos peticiones a la vez no se cruzan', () async {
      final channel = _FakeChannel();
      final client = SidecarClient(channel);

      final first = client.call('env_info');
      final second = client.call('ping');
      await Future<void>.delayed(Duration.zero);

      final firstId = channel.sent[0]['id'] as String;
      final secondId = channel.sent[1]['id'] as String;

      // Se contestan al revés, que es lo que puede pasar de verdad.
      channel.reply(secondId, {'pong': true});
      channel.reply(firstId, {'python': '3.12.4'});

      expect(await second, {'pong': true});
      expect(await first, {'python': '3.12.4'});
    });

    test('el progreso llega antes que la respuesta', () async {
      final channel = _FakeChannel();
      final client = SidecarClient(channel);
      final epochs = <int>[];

      final training = client.call(
        'train',
        timeout: Duration.zero,
        onProgress: (data) => epochs.add(data['epoch'] as int),
      );
      await Future<void>.delayed(Duration.zero);

      final id = channel.last['id'] as String;
      channel.progress(id, {'epoch': 1, 'epochs': 3});
      channel.progress(id, {'epoch': 2, 'epochs': 3});
      await Future<void>.delayed(Duration.zero);

      channel.reply(id, {'weights': 'best.pt'});

      expect(await training, {'weights': 'best.pt'});
      expect(epochs, [1, 2]);
    });

    test('un fallo del sidecar sale con su código', () async {
      final channel = _FakeChannel();
      final client = SidecarClient(channel);

      final answer = client.call('train', timeout: Duration.zero);
      await Future<void>.delayed(Duration.zero);

      channel.fail(
        channel.last['id'] as String,
        'OUT_OF_MEMORY',
        'CUDA out of memory',
      );

      await expectLater(
        answer,
        throwsA(
          isA<SidecarException>()
              .having((error) => error.isOutOfMemory, 'isOutOfMemory', isTrue),
        ),
      );
    });

    test('si el proceso se muere no deja a nadie esperando', () async {
      final channel = _FakeChannel();
      final client = SidecarClient(channel);

      final answer = client.call('train', timeout: Duration.zero);
      await Future<void>.delayed(Duration.zero);

      channel.die();

      await expectLater(
        answer,
        throwsA(
          isA<SidecarException>()
              .having((error) => error.isNotReady, 'isNotReady', isTrue),
        ),
      );
      expect(client.isRunning, isFalse);
    });

    test('una línea que no es nuestra no molesta', () async {
      final channel = _FakeChannel();
      final client = SidecarClient(channel);

      final answer = client.call('ping');
      await Future<void>.delayed(Duration.zero);

      // Las librerías de Python escriben avisos por su cuenta; no son
      // respuestas y no pueden romper nada.
      channel.write('UserWarning: something happened');
      channel.write('{"id": "otro", "ok": true, "result": {}}');
      await Future<void>.delayed(Duration.zero);

      channel.reply(channel.last['id'] as String, {'pong': true});

      expect(await answer, {'pong': true});
    });

    test('sin respuesta a tiempo se corta en lugar de colgarse', () async {
      final channel = _FakeChannel();
      final client = SidecarClient(channel);

      await expectLater(
        client.call('ping', timeout: const Duration(milliseconds: 20)),
        throwsA(isA<SidecarException>()),
      );
    });

    test('cancelar se manda como su propia petición', () async {
      final channel = _FakeChannel();
      final client = SidecarClient(channel);

      final training = client.call('train', timeout: Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final trainingId = channel.last['id'] as String;

      final cancelling = client.cancel(trainingId);
      await Future<void>.delayed(Duration.zero);

      // Va por otra petición porque el sidecar está ocupado con la primera.
      expect(channel.last['method'], 'cancel');
      expect(channel.last['params'], {'target': trainingId});

      channel.reply(channel.last['id'] as String, {'cancelled': true});
      await cancelling;

      channel.fail(trainingId, 'CANCELLED', 'Training cancelled');

      await expectLater(
        training,
        throwsA(
          isA<SidecarException>()
              .having((error) => error.isCancelled, 'isCancelled', isTrue),
        ),
      );
    });
  });
}
