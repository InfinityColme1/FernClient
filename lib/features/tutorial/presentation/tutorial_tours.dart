import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_anchors.dart';
import 'package:Fern/features/tutorial/presentation/tutorial_step.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/widgets.dart' show IconData;

/// Los recorridos guiados que ofrece la aplicación.
///
/// **Uno general y nueve por materia**, y entre todos cubren la aplicación
/// entera: siguiéndolos no queda ningún concepto sin explicar. Ésa es la
/// medida de si esto está bien hecho.
///
/// El general es el que se ofrece solo la primera vez y cuenta lo justo para no
/// perderse: qué es cada cosa y dónde está. Los otros nueve viven en los ajustes
/// y se leen cuando hacen falta — nadie necesita saber cómo se entrena un modelo
/// el día que abre la aplicación por primera vez, y contárselo entonces es la
/// forma más segura de que no se entere de nada.
///
/// El orden en el que se listan **es el orden en el que se aprenden**: traer
/// contenido, mirarlo, ordenarlo, encontrarlo, enseñarle a reconocerlo, y por
/// último lo que se toca de tarde en tarde.
///
/// Cada paso cabe en un cartel de 340 píxeles de ancho, así que la profundidad
/// se consigue **con más pasos y más recorridos**, no con parrafadas: un cartel
/// que no cabe no se lee, y uno que se lee a medias no cuenta nada.
enum TutorialTour {
  general(icon: Symbols.explore),
  importing(icon: Symbols.download),
  library(icon: Symbols.photo_library),
  managers(icon: Symbols.sell),
  searching(icon: Symbols.search),
  fernie(icon: Symbols.face_retouching_natural),
  models(icon: Symbols.hub),
  duplicates(icon: Symbols.copy_all),
  nsfw(icon: Symbols.lock),
  files(icon: Symbols.folder);

  const TutorialTour({required this.icon});

  final IconData icon;

  String title(AppLocalizations texts) => switch (this) {
        TutorialTour.general => texts.tourGeneralTitle,
        TutorialTour.importing => texts.tourImportingTitle,
        TutorialTour.library => texts.tourLibraryTitle,
        TutorialTour.managers => texts.tourManagersTitle,
        TutorialTour.searching => texts.tourSearchingTitle,
        TutorialTour.fernie => texts.tourFernieTitle,
        TutorialTour.models => texts.tourModelsTitle,
        TutorialTour.duplicates => texts.tourDuplicatesTitle,
        TutorialTour.nsfw => texts.tourNsfwTitle,
        TutorialTour.files => texts.tourFilesTitle,
      };

  String description(AppLocalizations texts) => switch (this) {
        TutorialTour.general => texts.tourGeneralDescription,
        TutorialTour.importing => texts.tourImportingDescription,
        TutorialTour.library => texts.tourLibraryDescription,
        TutorialTour.managers => texts.tourManagersDescription,
        TutorialTour.searching => texts.tourSearchingDescription,
        TutorialTour.fernie => texts.tourFernieDescription,
        TutorialTour.models => texts.tourModelsDescription,
        TutorialTour.duplicates => texts.tourDuplicatesDescription,
        TutorialTour.nsfw => texts.tourNsfwDescription,
        TutorialTour.files => texts.tourFilesDescription,
      };

  /// Los pasos, ya en el idioma en curso.
  ///
  /// Se arman al pedirlos en vez de guardarse hechos porque el idioma se puede
  /// cambiar sin salir de la pantalla, y un recorrido a medias en dos idiomas es
  /// peor que no tenerlo.
  List<TutorialStep> steps(AppLocalizations texts) => switch (this) {
        TutorialTour.general => _general(texts),
        TutorialTour.importing => _importing(texts),
        TutorialTour.library => _library(texts),
        TutorialTour.managers => _managers(texts),
        TutorialTour.searching => _searching(texts),
        TutorialTour.fernie => _fernie(texts),
        TutorialTour.models => _models(texts),
        TutorialTour.duplicates => _duplicates(texts),
        TutorialTour.nsfw => _nsfw(texts),
        TutorialTour.files => _files(texts),
      };
}

/// El de la primera vez: qué es cada cosa y dónde está.
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
      // Sin ancla: el visor se abre por encima del marco de la aplicación, así
      // que el tutorial no puede llevar hasta él ni señalarlo. Se cuenta desde
      // fuera, que es de donde se abre.
      TutorialStep(
        title: texts.tutorialViewerTitle,
        body: texts.tutorialViewerBody,
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
        anchorId: TutorialAnchorId.jobs,
        title: texts.tutorialJobsTitle,
        body: texts.tutorialJobsBody,
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
        anchorId: TutorialAnchorId.settings,
        title: texts.tourImporting2Title,
        body: texts.tourImporting2Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourImporting3Title,
        body: texts.tourImporting3Body,
      ),
      TutorialStep(
        title: texts.tourImporting4Title,
        body: texts.tourImporting4Body,
      ),
      TutorialStep(
        title: texts.tourImporting5Title,
        body: texts.tourImporting5Body,
      ),
      TutorialStep(
        title: texts.tourImporting6Title,
        body: texts.tourImporting6Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenHeader,
        title: texts.tourImporting7Title,
        body: texts.tourImporting7Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenHeader,
        title: texts.tourImporting8Title,
        body: texts.tourImporting8Body,
      ),
      TutorialStep(
        anchorId: mediaRoute,
        title: texts.tourImporting9Title,
        body: texts.tourImporting9Body,
      ),
    ];

/// La biblioteca y el visor: mirar lo que se tiene y trabajar con ello.
List<TutorialStep> _library(AppLocalizations texts) => [
      TutorialStep(
        route: mediaRoute,
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourLibrary1Title,
        body: texts.tourLibrary1Body,
      ),
      TutorialStep(
        title: texts.tourLibrary2Title,
        body: texts.tourLibrary2Body,
      ),
      TutorialStep(
        title: texts.tourLibrary3Title,
        body: texts.tourLibrary3Body,
      ),
      TutorialStep(
        anchorId: deletedRoute,
        title: texts.tourLibrary4Title,
        body: texts.tourLibrary4Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenHeader,
        title: texts.tourLibrary5Title,
        body: texts.tourLibrary5Body,
      ),
      // Los cuatro siguientes pasan dentro del visor, que se abre por encima de
      // este velo: se cuentan sin señalar a nada.
      TutorialStep(
        title: texts.tourLibrary6Title,
        body: texts.tourLibrary6Body,
      ),
      TutorialStep(
        title: texts.tourLibrary7Title,
        body: texts.tourLibrary7Body,
      ),
      TutorialStep(
        anchorId: favoritesRoute,
        title: texts.tourLibrary8Title,
        body: texts.tourLibrary8Body,
      ),
      TutorialStep(
        title: texts.tourLibrary9Title,
        body: texts.tourLibrary9Body,
      ),
    ];

/// Etiquetas, personas y creadores: todo lo que sirve para ordenar.
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
        anchorId: TutorialAnchorId.screenCard,
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
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourManagers5Title,
        body: texts.tourManagers5Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourManagers6Title,
        body: texts.tourManagers6Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourManagers7Title,
        body: texts.tourManagers7Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenCard,
        title: texts.tourManagers8Title,
        body: texts.tourManagers8Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourManagers9Title,
        body: texts.tourManagers9Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.sidebarTags,
        title: texts.tourManagers10Title,
        body: texts.tourManagers10Body,
      ),
      TutorialStep(
        title: texts.tourManagers11Title,
        body: texts.tourManagers11Body,
      ),
    ];

/// Buscar y filtrar: cómo se encuentra algo entre miles.
List<TutorialStep> _searching(AppLocalizations texts) => [
      TutorialStep(
        route: mediaRoute,
        anchorId: TutorialAnchorId.search,
        title: texts.tourSearching1Title,
        body: texts.tourSearching1Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.search,
        title: texts.tourSearching2Title,
        body: texts.tourSearching2Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.search,
        title: texts.tourSearching3Title,
        body: texts.tourSearching3Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.search,
        title: texts.tourSearching4Title,
        body: texts.tourSearching4Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.search,
        title: texts.tourSearching5Title,
        body: texts.tourSearching5Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.sidebarTags,
        title: texts.tourSearching6Title,
        body: texts.tourSearching6Body,
      ),
      TutorialStep(
        route: tagManagerRoute,
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourSearching7Title,
        body: texts.tourSearching7Body,
      ),
    ];

/// Los fernies: qué son, de dónde salen sus ejemplos y cómo se marcan.
List<TutorialStep> _fernie(AppLocalizations texts) => [
      TutorialStep(
        route: fernieManagerRoute,
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourFernie1Title,
        body: texts.tourFernie1Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenCard,
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
        title: texts.tourFernie5Title,
        body: texts.tourFernie5Body,
      ),
      TutorialStep(
        title: texts.tourFernie6Title,
        body: texts.tourFernie6Body,
      ),
      TutorialStep(
        title: texts.tourFernie7Title,
        body: texts.tourFernie7Body,
      ),
      TutorialStep(
        title: texts.tourFernie8Title,
        body: texts.tourFernie8Body,
      ),
      TutorialStep(
        anchorId: modelsRoute,
        title: texts.tourFernie9Title,
        body: texts.tourFernie9Body,
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
        anchorId: TutorialAnchorId.settings,
        title: texts.tourModels2Title,
        body: texts.tourModels2Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenHeader,
        title: texts.tourModels3Title,
        body: texts.tourModels3Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.jobs,
        title: texts.tourModels4Title,
        body: texts.tourModels4Body,
      ),
      TutorialStep(
        title: texts.tourModels5Title,
        body: texts.tourModels5Body,
      ),
      TutorialStep(
        title: texts.tourModels6Title,
        body: texts.tourModels6Body,
      ),
      // El árbol es una vista **de** los modelos y por eso no está en el menú:
      // se llega desde su pantalla. El recorrido va solo, que es lo único que
      // puede hacer con la aplicación bloqueada por el velo.
      TutorialStep(
        route: modelTreePath(),
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourModels7Title,
        body: texts.tourModels7Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenList,
        title: texts.tourModels8Title,
        body: texts.tourModels8Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourModels9Title,
        body: texts.tourModels9Body,
      ),
      TutorialStep(
        route: modelsRoute,
        anchorId: TutorialAnchorId.screenBody,
        title: texts.tourModels10Title,
        body: texts.tourModels10Body,
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
        title: texts.tourDuplicates4Title,
        body: texts.tourDuplicates4Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourDuplicates5Title,
        body: texts.tourDuplicates5Body,
      ),
      TutorialStep(
        title: texts.tourDuplicates6Title,
        body: texts.tourDuplicates6Body,
      ),
    ];

/// El bloqueo de contenido: qué esconde y cómo se abre.
///
/// Se cuenta desde la biblioteca porque es donde se nota: los ajustes son un
/// diálogo que se pinta por encima de este velo, así que el recorrido no puede
/// llevar hasta ellos. Señala al botón que los abre, que es lo que hace falta
/// saber.
List<TutorialStep> _nsfw(AppLocalizations texts) => [
      TutorialStep(
        route: mediaRoute,
        anchorId: TutorialAnchorId.content,
        title: texts.tourNsfw1Title,
        body: texts.tourNsfw1Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourNsfw2Title,
        body: texts.tourNsfw2Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourNsfw3Title,
        body: texts.tourNsfw3Body,
      ),
      TutorialStep(
        route: tagManagerRoute,
        anchorId: TutorialAnchorId.screenCard,
        title: texts.tourNsfw4Title,
        body: texts.tourNsfw4Body,
      ),
      TutorialStep(
        title: texts.tourNsfw5Title,
        body: texts.tourNsfw5Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourNsfw6Title,
        body: texts.tourNsfw6Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.screenCard,
        title: texts.tourNsfw7Title,
        body: texts.tourNsfw7Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourNsfw8Title,
        body: texts.tourNsfw8Body,
      ),
    ];

/// Los ficheros y el mantenimiento: dónde vive todo y cómo se limpia.
List<TutorialStep> _files(AppLocalizations texts) => [
      TutorialStep(
        route: mediaRoute,
        anchorId: TutorialAnchorId.settings,
        title: texts.tourFiles1Title,
        body: texts.tourFiles1Body,
      ),
      TutorialStep(
        anchorId: importRoute,
        title: texts.tourFiles2Title,
        body: texts.tourFiles2Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourFiles3Title,
        body: texts.tourFiles3Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourFiles4Title,
        body: texts.tourFiles4Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourFiles5Title,
        body: texts.tourFiles5Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourFiles6Title,
        body: texts.tourFiles6Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.settings,
        title: texts.tourFiles7Title,
        body: texts.tourFiles7Body,
      ),
      TutorialStep(
        anchorId: TutorialAnchorId.jobs,
        title: texts.tourFiles8Title,
        body: texts.tourFiles8Body,
      ),
    ];
