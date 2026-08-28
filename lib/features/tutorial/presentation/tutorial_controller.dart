import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_step.dart';
import 'package:flutter/foundation.dart';

/// Quién lleva el tutorial: por qué paso va y si se está enseñando.
///
/// Va aparte del velo que lo pinta porque no lo arranca sólo el velo: lo arranca
/// la primera vez que se abre la aplicación, y también el botón de los ajustes,
/// que está en otro sitio del árbol. Con el estado aquí, los dos hacen lo mismo:
/// pedirlo.
///
/// **Lo de «ya se ha ofrecido» se guarda en cuanto se contesta**, se acepte o no.
/// Ofrecer un tutorial dos veces es insistir, y quien lo rechazó lo hizo a
/// propósito; para volver a verlo está el botón de los ajustes.
class TutorialController extends ChangeNotifier {
  final PreferencesService _preferences;

  TutorialController(this._preferences);

  List<TutorialStep> _steps = const [];
  int _index = 0;

  bool get isRunning => _steps.isNotEmpty;

  /// El paso en el que va, o `null` si no se está enseñando.
  TutorialStep? get step => isRunning ? _steps[_index] : null;

  /// Por cuál va, empezando en 1, y cuántos son. Para el «3 de 8».
  int get position => _index + 1;
  int get total => _steps.length;

  bool get isFirst => _index == 0;
  bool get isLast => isRunning && _index == _steps.length - 1;

  /// Si todavía no se ha ofrecido nunca. Es lo que decide si al abrir la
  /// aplicación sale la invitación.
  bool get isUnoffered => !_preferences.hasBeenOfferedTutorial();

  /// Da por ofrecido el tutorial, se haya aceptado o no.
  Future<void> markOffered() => _preferences.setTutorialOffered();

  void start(List<TutorialStep> steps) {
    if (steps.isEmpty) return;

    _steps = steps;
    _index = 0;
    notifyListeners();
  }

  void next() {
    if (!isRunning) return;
    if (isLast) return finish();

    _index++;
    notifyListeners();
  }

  void back() {
    if (!isRunning || isFirst) return;

    _index--;
    notifyListeners();
  }

  /// Termina, tanto si se ha llegado al final como si se ha saltado. No se
  /// distingue una cosa de otra a propósito: el tutorial no es un trámite que
  /// haya que aprobar.
  void finish() {
    if (!isRunning) return;

    _steps = const [];
    _index = 0;
    notifyListeners();
  }
}
