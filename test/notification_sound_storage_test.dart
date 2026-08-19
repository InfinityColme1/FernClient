// Las copias de los sonidos que elige el usuario.
//
// La aplicación guarda su propia copia para que mover o borrar el original no
// deje el aviso mudo. La contrapartida es que hay que tirar esas copias cuando
// dejan de hacer falta: probar cinco audios no puede dejar cinco ficheros en la
// carpeta para siempre.
//
// Y sólo se borra lo nuestro: si `store` no pudo copiar y se guardó la ruta
// original, ésa apunta a un fichero del usuario y no se toca.

import 'dart:io';

import 'package:Fern/features/notifications/data/services/notification_sound_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temp;
  late Directory sounds;
  late NotificationSoundService service;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('fern_sounds_test');
    sounds = Directory(p.join(temp.path, 'sounds'));
    await sounds.create(recursive: true);

    service = NotificationSoundService(soundsPath: sounds.path);
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<File> sourceFile(String name) async {
    final file = File(p.join(temp.path, name));
    await file.writeAsString('audio de mentira');

    return file;
  }

  test('elegir un audio deja una copia en la carpeta de sonidos', () async {
    final source = await sourceFile('campana.wav');

    final stored = await service.store(source.path);

    expect(p.dirname(stored), sounds.path);
    expect(File(stored).existsSync(), isTrue);
    // El original se queda donde estaba: es del usuario.
    expect(source.existsSync(), isTrue);
  });

  test('volver al sonido de fábrica borra la copia', () async {
    final source = await sourceFile('campana.wav');
    final stored = await service.store(source.path);

    await service.remove(stored);

    expect(File(stored).existsSync(), isFalse);
    expect(source.existsSync(), isTrue);
  });

  test('no se borra un fichero que no sea nuestro', () async {
    final source = await sourceFile('del-usuario.wav');

    await service.remove(source.path);

    expect(source.existsSync(), isTrue);
  });

  test('borrar lo que ya no está no es un error', () async {
    await service.remove(p.join(sounds.path, 'no-existe.wav'));
    await service.remove(null);
    await service.remove('');
  });

  test('dos audios con el mismo nombre no se pisan', () async {
    final first = await sourceFile('aviso.wav');
    final storedFirst = await service.store(first.path);

    final other = Directory(p.join(temp.path, 'otra'));
    await other.create();
    final second = File(p.join(other.path, 'aviso.wav'));
    await second.writeAsString('otro audio');
    final storedSecond = await service.store(second.path);

    expect(storedFirst, isNot(storedSecond));
    expect(File(storedFirst).existsSync(), isTrue);
    expect(File(storedSecond).existsSync(), isTrue);
  });

  test('elegir un audio que ya está en la carpeta no lo duplica', () async {
    final source = await sourceFile('campana.wav');
    final stored = await service.store(source.path);

    // Volver a elegir la copia devuelve la misma ruta: es la razón de que al
    // borrarla haya que comprobar antes que no la esté usando otro aviso.
    expect(await service.store(stored), stored);
  });
}
