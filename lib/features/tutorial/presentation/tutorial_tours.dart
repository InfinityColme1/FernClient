import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_anchors.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_step.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/widgets.dart' show IconData;

/// Los recorridos guiados que ofrece la aplicación.
///
/// **Uno general y cinco por materia.** El general es el que se ofrece solo la
/// primera vez y cuenta lo justo para no perderse: dónde está cada cosa y por
/// dónde entra el contenido. Los otros cinco están en los ajustes y se leen
/// cuando hacen falta — nadie necesita saber cómo se entrena un modelo el día
/// que abre la aplicación por primera vez, y contárselo entonces es la forma más
/// segura de que no se entere de nada.
///
/// Todos son cortos por la misma razón: un recorrido de veinte pasos no se
/// termina.
enum TutorialTour {
  general(icon: Symbols.explore),
  importing(icon: Symbols.download),
  managers(icon: Symbols.sell),
  fernie(icon: Symbols.face_retouching_natural),
  models(icon: Symbols.hub),
  duplicates(icon: Symbols.copy_all);

  const TutorialTour({required this.icon});

  final IconData icon;

  String title(AppLocalizations texts) => switch (this) {
        TutorialTour.general => texts.tourGeneralTitle,
        TutorialTour.importing => texts.tourImportingTitle,
        TutorialTour.managers => texts.tourManagersTitle,
        TutorialTour.fernie => texts.tourFernieTitle,
        TutorialTour.models => texts.tourModelsTitle,
        TutorialTour.duplicates => texts.tourDuplicatesTitle,
      };

  String description(AppLocalizations texts) => switch (this) {
        TutorialTour.general => texts.tourGeneralDescription,
        TutorialTour.importing => texts.tourImportingDescription,
        TutorialTour.managers => texts.tourManagersDescription,
        TutorialTour.fernie => texts.tourFernieDescription,
        TutorialTour.models => texts.tourModelsDescription,
        TutorialTour.duplicates => texts.tourDuplicatesDescription,
      };

  /// Los pasos, ya en el idioma en curso.
  ///
  /// Se arman al pedirlos en vez de guardarse hechos porque el idioma se puede
  /// cambiar sin salir de la pantalla, y un recorrido a medias en dos idiomas es
  /// peor que no tenerlo.
  List<TutorialStep> steps(AppLocalizations texts) => switch (this) {
        TutorialTour.general => _general(texts),
        TutorialTour.importing => _importing(texts),
        TutorialTour.managers => _managers(texts),
        TutorialTour.fernie => _fernie(texts),
        TutorialTour.models => _models(texts),
        TutorialTour.duplicates => _duplicates(texts),
      };
}

/// El de la primera vez: dónde está cada cosa.
List<TutorialStep> _general(AppLocalizations texts) => [
      TutorialStep(
        title: texts.tutorialWelcomeTitle,
        body: texts.tutorialWelcomeBody,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.sidebar,
        title: texts.tutorialSidebarTitle,
        body: texts.tutorialSidebarBody,
      ),
      TutorialStep(
        anchorId: importRoute,
        title: texts.tutorialImportTitle,
        body: texts.tutorialImportBody,
      ),
      TutorialStep(
        route: mediaRoute,
        anchorId: TutorialAnchorId.content,
        title: texts.tutorialContentTitle,
        body: texts.tutorialContentBody,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.sidebarTags,
        title: texts.tutorialTagsTitle,
        body: texts.tutorialTagsBody,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.create,
        title: texts.tutorialCreateTitle,
        body: texts.tutorialCreateBody,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.search,
        title: texts.tutorialSearchTitle,
        body: texts.tutorialSearchBody,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tutorialSettingsTitle,
        body: texts.tutorialSettingsBody,
      ),
    ];

/// Traer contenido, revisarlo y darlo por definitivo.
List<TutorialStep> _importing(AppLocalizations texts) => [
      TutorialStep(
        route: importRoute,
        anchorId: TutorialAnchorId.screenHeader,
        title: texts.tourImporting1Title,
        body: texts.tourImporting1Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourImporting2Title,
        body: texts.tourImporting2Body,
      ),
      TutorialStep(
        title: texts.tourImporting3Title,
        body: texts.tourImporting3Body,
      ),
      TutorialStep(
        title: texts.tourImporting4Title,
        body: texts.tourImporting4Body,
      ),
      TutorialStep(
        anchorId: mediaRoute,
        title: texts.tourImporting5Title,
        body: texts.tourImporting5Body,
      ),
    ];

/// Creadores y etiquetas: las dos formas de ordenar lo que se tiene.
List<TutorialStep> _managers(AppLocalizations texts) => [
      TutorialStep(
        route: creatorManagerRoute,
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourManagers1Title,
        body: texts.tourManagers1Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenCard,
        title: texts.tourManagers2Title,
        body: texts.tourManagers2Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourManagers3Title,
        body: texts.tourManagers3Body,
      ),
      TutorialStep(
        route: tagManagerRoute,
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourManagers4Title,
        body: texts.tourManagers4Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.sidebarTags,
        title: texts.tourManagers5Title,
        body: texts.tourManagers5Body,
      ),
    ];

/// Los fernies: qué son y de dónde salen sus ejemplos.
List<TutorialStep> _fernie(AppLocalizations texts) => [
      TutorialStep(
        route: fernieManagerRoute,
        title: texts.tourFernie1Title,
        body: texts.tourFernie1Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourFernie2Title,
        body: texts.tourFernie2Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourFernie3Title,
        body: texts.tourFernie3Body,
      ),
      // Sin ancla: esto pasa dentro del visor, que se abre por encima del marco
      // de la aplicación y por tanto por encima de este velo.
      TutorialStep(
        title: texts.tourFernie4Title,
        body: texts.tourFernie4Body,
      ),
      TutorialStep(
        anchorId: modelsRoute,
        title: texts.tourFernie5Title,
        body: texts.tourFernie5Body,
      ),
    ];

/// Los modelos: lo que de verdad reconoce.
List<TutorialStep> _models(AppLocalizations texts) => [
      TutorialStep(
        route: modelsRoute,
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourModels1Title,
        body: texts.tourModels1Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenHeader,
        title: texts.tourModels2Title,
        body: texts.tourModels2Body,
      ),
      TutorialStep(
        title: texts.tourModels3Title,
        body: texts.tourModels3Body,
      ),
      TutorialStep(
        title: texts.tourModels4Title,
        body: texts.tourModels4Body,
      ),
      TutorialStep(
        title: texts.tourModels5Title,
        body: texts.tourModels5Body,
      ),
      // El arbol es una vista **de** los modelos y por eso no esta en el menu:
      // se llega desde su pantalla. El recorrido va solo, que es lo unico que
      // puede hacer con la aplicacion bloqueada por el velo.
      TutorialStep(
        route: modelTreePath(),
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourModels6Title,
        body: texts.tourModels6Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourModels7Title,
        body: texts.tourModels7Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourModels8Title,
        body: texts.tourModels8Body,
      ),
    ];

/// El contenido repetido: encontrarlo y decidir qué copia se queda.
List<TutorialStep> _duplicates(AppLocalizations texts) => [
      TutorialStep(
        route: repeatedMediaRoute,
        anchorId: TutorialAnchorId.screenHeader,
        title: texts.tourDuplicates1Title,
        body: texts.tourDuplicates1Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourDuplicates2Title,
        body: texts.tourDuplicates2Body,
      ),
      TutorialStep(
        title: texts.tourDuplicates3Title,
        body: texts.tourDuplicates3Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourDuplicates4Title,
        body: texts.tourDuplicates4Body,
      ),
      TutorialStep(
        title: texts.tourDuplicates5Title,
        body: texts.tourDuplicates5Body,
      ),
    ];
