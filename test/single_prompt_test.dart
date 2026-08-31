// Una pregunta cada vez.
//
// El fallo que esto protege se ve aporreando escape para salir del modo fernie
// con regiones marcadas: salir pregunta si se descarta lo hecho, y preguntar es
// **esperar**. Entre la pulsación y el diálogo montado caben más pulsaciones, y
// cada una abría la suya: salían tres y cuatro preguntas idénticas apiladas y
// había que contestarlas todas.
//
// Mirar si la tecla venía repetida no basta —eso sólo tapa tenerla pulsada, y
// con pulsaciones sueltas y rápidas pasa igual—, así que lo que se comprueba
// aquí es lo único que de verdad hay que saber: si ya hay una puesta.

import 'dart:async';

import 'package:Fern/core/ui/dialogs/single_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SinglePrompt prompts;

  setUp(() => prompts = SinglePrompt());

  test('sin nada abierto, pregunta', () async {
    expect(await prompts.ask(() async => 'contestado'), 'contestado');
  });

  test('y contesta lo que diga quien conteste', () async {
    expect(await prompts.ask<bool>(() async => false), isFalse);
    expect(await prompts.ask<bool>(() async => null), isNull);
  });

  group('con una puesta', () {
    test('la segunda no abre otra', () async {
      final abiertas = Completer<void>();
      var veces = 0;

      Future<bool?> abrir() async {
        veces++;
        await abiertas.future;

        return true;
      }

      final primera = prompts.ask(abrir);
      final segunda = prompts.ask(abrir);

      // La segunda no espera a nada: contesta que no se ha preguntado.
      expect(await segunda, isNull);
      expect(veces, 1);

      abiertas.complete();
      expect(await primera, isTrue);
    });

    // Es el caso del usuario: cuatro escapes seguidos, cuatro preguntas.
    test('ni la cuarta', () async {
      final abiertas = Completer<void>();
      var veces = 0;

      Future<bool?> abrir() async {
        veces++;
        await abiertas.future;

        return true;
      }

      final primera = prompts.ask(abrir);
      for (var i = 0; i < 3; i++) {
        expect(await prompts.ask(abrir), isNull);
      }

      expect(veces, 1);

      abiertas.complete();
      await primera;
    });

    test('lo dice mientras dura', () async {
      final abiertas = Completer<void>();

      expect(prompts.isOpen, isFalse);

      final pregunta = prompts.ask(() => abiertas.future);
      expect(prompts.isOpen, isTrue);

      abiertas.complete();
      await pregunta;

      expect(prompts.isOpen, isFalse);
    });
  });

  group('una vez contestada', () {
    test('se puede volver a preguntar', () async {
      expect(await prompts.ask(() async => 'una'), 'una');
      expect(await prompts.ask(() async => 'otra'), 'otra');
    });

    // Cerrarla sin contestar es lo normal —el aspa, escape, pulsar fuera— y no
    // puede dejar la pantalla sin poder volver a preguntar.
    test('aunque se cerrara sin contestar', () async {
      expect(await prompts.ask<bool>(() async => null), isNull);
      expect(await prompts.ask<bool>(() async => true), isTrue);
    });

    // Una bandera que se queda puesta deja el modo fernie sin salida: escape no
    // haría nada nunca más y no habría forma de entender por qué.
    test('y aunque la pregunta reventara', () async {
      await expectLater(
        prompts.ask<bool>(() async => throw Exception('se rompió')),
        throwsException,
      );

      expect(prompts.isOpen, isFalse);
      expect(await prompts.ask<bool>(() async => true), isTrue);
    });
  });
}
