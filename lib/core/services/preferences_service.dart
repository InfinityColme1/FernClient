import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media_deletion_kind.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);


  /// Lo alto que suena el visor, de 0 a 1.
  ///
  /// Lo que este fuera de rango se ignora y vale el de fabrica: es una
  /// preferencia que puede venir de una version anterior o de un fichero tocado
  /// a mano, y un volumen de 7 dejaria el visor gritando sin manera de saber por
  /// que.
  double getViewerVolume() {
    final saved = _prefs.getDouble(viewerVolumePreferenceKey);
    if (saved == null || saved < 0 || saved > 1) return viewerDefaultVolume;

    return saved;
  }

  Future<bool> setViewerVolume(double value) async {
    return await _prefs.setDouble(
      viewerVolumePreferenceKey,
      value.clamp(0.0, 1.0),
    );
  }


  /// Si el tutorial ya se ha ofrecido alguna vez.
  ///
  /// Sin nada guardado es que no, que es lo que pasa la primera vez que se abre
  /// la aplicacion — el unico momento en el que se ofrece solo.
  bool hasBeenOfferedTutorial() =>
      _prefs.getBool(tutorialOfferedPreferenceKey) ?? false;

  Future<bool> setTutorialOffered() async {
    return await _prefs.setBool(tutorialOfferedPreferenceKey, true);
  }


  Future<bool> setRootPath(String path) async {
    return await _prefs.setString(rootPathPreferenceKey, path);
  }


  String? getRootPath() {
    return _prefs.getString(rootPathPreferenceKey);
  }


  Future<bool> clearRootPath() async {
    return await _prefs.remove(rootPathPreferenceKey);
  }


  /// En qué orden se pinta la biblioteca.
  MediaSortOrder getMediaSortOrder() =>
      MediaSortOrder.fromId(_prefs.getString(mediaSortOrderPreferenceKey));

  Future<bool> setMediaSortOrder(MediaSortOrder order) async {
    return await _prefs.setString(mediaSortOrderPreferenceKey, order.id);
  }

  /// En qué orden se pinta lo pendiente de revisar.
  ///
  /// Aparte del de la biblioteca porque las dos pantallas se miran para cosas
  /// distintas: una tanda recién traída se repasa agrupada por tipo o por
  /// nombre, y la biblioteca se mira por lo último que llegó.
  ///
  /// El azar no se ofrece ahí y tampoco se acepta aquí: barajar una tanda que
  /// se está revisando de arriba abajo es perder el sitio.
  MediaSortOrder getImportSortOrder() {
    final saved = MediaSortOrder.fromId(
      _prefs.getString(importSortOrderPreferenceKey),
    );

    return saved == MediaSortOrder.random ? MediaSortOrder.newestFirst : saved;
  }

  Future<bool> setImportSortOrder(MediaSortOrder order) async {
    return await _prefs.setString(importSortOrderPreferenceKey, order.id);
  }


  /// Con cuánto se importa: el último tope que se eligió.
  ///
  /// Lo que no esté entre las opciones se ignora y vale el de fábrica: es una
  /// preferencia que se lee para poner un desplegable, y un valor que no está
  /// en la lista lo dejaría sin nada seleccionado.
  int getImportLimit() {
    final saved = _prefs.getInt(importLimitPreferenceKey);

    return importLimitOptions.contains(saved) ? saved! : defaultImportLimit;
  }

  Future<bool> setImportLimit(int limit) async {
    return await _prefs.setInt(importLimitPreferenceKey, limit);
  }


  /// Anota que se acaba de terminar un escaneo de contenido repetido.
  ///
  /// La sella el escaneo al acabar bien, venga del botón o de la aplicación:
  /// buscar repetidos a mano y que la aplicación lo repita sola al día siguiente
  /// es trabajo tirado, y quien lo acaba de hacer no distingue un escaneo de
  /// otro.
  Future<bool> setLastDuplicateScan(DateTime at) async {
    return await _prefs.setString(
      lastDuplicateScanPreferenceKey,
      at.toIso8601String(),
    );
  }


  /// Cuándo terminó el último escaneo de repetidos, o `null` si nunca se hizo.
  DateTime? getLastDuplicateScan() {
    final value = _prefs.getString(lastDuplicateScanPreferenceKey);
    if (value == null) return null;

    return DateTime.tryParse(value);
  }


  /// Olvida cuándo se escaneó por última vez, para que vuelva a tocar.
  ///
  /// La llama el borrado de huellas: dejar la marca puesta con la biblioteca sin
  /// una sola huella deja la búsqueda automática dormida todo el periodo, y la
  /// pantalla diciendo que se escaneó hace un momento.
  Future<bool> clearLastDuplicateScan() async {
    return await _prefs.remove(lastDuplicateScanPreferenceKey);
  }


  /// Anota de qué fuente se está importando.
  ///
  /// La pantalla de importación arranca por aquí. Sin esto volvía siempre a la
  /// del equipo local: quien acababa de traerse cien cosas de Reddit y pasaba un
  /// momento por la biblioteca, al volver se encontraba otra pantalla y tenía
  /// que buscar su fuente otra vez.
  Future<bool> setLastImportSource(ImportSource source) async {
    return await _prefs.setString(lastImportSourcePreferenceKey, source.id);
  }


  /// De qué fuente se estuvo importando, o `null` si nunca.
  ///
  /// Se comprueba antes de traducir: `fromId` cae en el equipo local ante
  /// cualquier cosa que no reconozca, y aquí hace falta distinguir «no se ha
  /// importado nunca» de «se importó del equipo».
  ImportSource? getLastImportSource() {
    final value = _prefs.getString(lastImportSourcePreferenceKey);
    if (value == null) return null;

    final known = ImportSource.values.any((source) => source.id == value);

    return known ? ImportSource.fromId(value) : null;
  }


  String _lastImportKey(ImportSource source, [String? collection]) =>
      '$lastImportPreferenceKeyPrefix${source.id}'
      '${collection == null ? '' : '_$collection'}';


  /// Anota que se acaba de terminar un escaneo de [source].
  ///
  /// Se sella al terminar, haya traído contenido o no: lo que dice es cuándo se
  /// miró por última vez, que es lo que hace falta para saber si lo que se está
  /// viendo está al día.
  ///
  /// [collection] es lo mismo que en [setLastImportMarker]: cada listado se
  /// recorre por su cuenta, así que cada uno se miró por última vez cuando se
  /// miró él, y no cuando se miró la fuente entera.
  Future<bool> setLastImport(
    ImportSource source,
    DateTime at, {
    String? collection,
  }) async {
    return await _prefs.setString(
      _lastImportKey(source, collection),
      at.toIso8601String(),
    );
  }


  /// Cuándo se importó por última vez de [source], o `null` si nunca.
  DateTime? getLastImport(ImportSource source, {String? collection}) {
    final value = _prefs.getString(_lastImportKey(source, collection));
    if (value == null) return null;

    return DateTime.tryParse(value);
  }


  /// Cuándo se miró por última vez cada listado de [source].
  ///
  /// El compañero de [importMarkers], y por el mismo motivo: los creadores que
  /// alguien sigue son los que son y cambian, así que no se pueden preguntar de
  /// uno en uno por una lista que no se conoce de antemano.
  ///
  /// Sale de aquí y no de la fuente porque es **lo que sabe esta máquina**: se
  /// lee al instante y no cuesta ni una petición, que es justo lo que hace falta
  /// para poder decir algo en cuanto la lista aparece.
  Map<String, DateTime> importDates(ImportSource source) {
    final prefix = _lastImportKey(source);

    return {
      for (final key in _prefs.getKeys())
        if (key.startsWith('${prefix}_'))
          if (_prefs.getString(key) case final value?)
            if (DateTime.tryParse(value) case final at?)
              key.substring(prefix.length + 1): at,
    };
  }


  String _deleteFilesKey(MediaDeletionKind kind) => switch (kind) {
        MediaDeletionKind.trash => deleteTrashFilesPreferenceKey,
        MediaDeletionKind.discard => deleteDiscardedFilesPreferenceKey,
      };


  /// Si el próximo borrado de [kind] se lleva también los ficheros del disco.
  ///
  /// Es cómo quedó la casilla del aviso la última vez; mientras no se haya
  /// borrado nada de esa manera, lo que dice [MediaDeletionKind.deletesFiles].
  bool getDeleteFiles(MediaDeletionKind kind) {
    return _prefs.getBool(_deleteFilesKey(kind)) ?? kind.deletesFiles;
  }


  /// Recuerda cómo ha quedado la casilla del aviso, que es con lo que sale la
  /// próxima vez.
  Future<bool> setDeleteFiles(MediaDeletionKind kind, bool deleteFiles) async {
    return await _prefs.setBool(_deleteFilesKey(kind), deleteFiles);
  }


  String _lastImportMarkerKey(ImportSource source, String? collection) =>
      '$lastImportMarkerPreferenceKeyPrefix${source.id}'
      '${collection == null ? '' : '_$collection'}';


  /// Guarda por dónde se quedó la última importación de [source]: el
  /// identificador de lo más nuevo que tenía la fuente en ese momento.
  ///
  /// Es lo que hace posible traerse "lo guardado desde la última vez" sin que la
  /// fuente diga cuándo se guardó cada cosa: al recorrerla de lo más nuevo a lo
  /// más antiguo, llegar a esta marca es llegar a donde se dejó.
  ///
  /// [collection] es para las fuentes que no tienen un solo listado sino
  /// varios (Pixiv tiene dos, el de marcadores públicos y el de privados): cada
  /// uno se recorre por su cuenta y por tanto se queda por su sitio, así que
  /// cada uno lleva su marca. Se omite en las fuentes de un solo listado.
  Future<bool> setLastImportMarker(
    ImportSource source,
    String marker, {
    String? collection,
  }) async {
    return await _prefs.setString(
      _lastImportMarkerKey(source, collection),
      marker,
    );
  }


  /// Por dónde se quedó la última importación de [source], o `null` si de esa
  /// fuente no se ha llegado a importar nada todavía.
  String? getLastImportMarker(ImportSource source, {String? collection}) {
    return _prefs.getString(_lastImportMarkerKey(source, collection));
  }


  /// Olvida por dónde iban las importaciones: cuándo se miró cada fuente y por
  /// dónde se quedó cada listado.
  ///
  /// Lo llama quien vacía la base de datos. Estas marcas no dicen nada por sí
  /// solas: dicen «de aquí para atrás ya está traído», y con la base de datos
  /// vacía eso es mentira. Dejarlas puestas haría que la siguiente importación
  /// «desde la última vez» no trajera nada y pareciera que la fuente está rota.
  ///
  /// Lo demás no se toca: la carpeta de la biblioteca, el tema o las
  /// credenciales no son la base de datos.
  Future<void> forgetImportProgress() async {
    final stale = [
      for (final key in _prefs.getKeys())
        if (key.startsWith(lastImportPreferenceKeyPrefix) ||
            key.startsWith(lastImportMarkerPreferenceKeyPrefix))
          key,
    ];

    for (final key in stale) {
      await _prefs.remove(key);
    }
  }


  /// Todas las marcas guardadas de [source], por listado.
  ///
  /// Hace falta cuando los listados no se saben de antemano: los creadores que
  /// alguien sigue son los que son, y cambian.
  Map<String, String> importMarkers(ImportSource source) {
    final prefix = _lastImportMarkerKey(source, null);

    return {
      for (final key in _prefs.getKeys())
        if (key.startsWith('${prefix}_'))
          if (_prefs.getString(key) case final marker?)
            key.substring(prefix.length + 1): marker,
    };
  }


  /// Guarda en qué página se ha quedado el navegador de la aplicación.
  ///
  /// No es un ajuste sino dónde se estaba: salir a otra pantalla y volver tiene
  /// que dejar el navegador como se dejó, igual que cualquier otra pantalla
  /// vuelve como estaba.
  Future<bool> setLastBrowserUrl(String url) {
    return _prefs.setString(browserLastUrlPreferenceKey, url);
  }


  /// La página en la que se dejó el navegador, o `null` si todavía no se ha
  /// abierto ninguna.
  String? getLastBrowserUrl() => _prefs.getString(browserLastUrlPreferenceKey);


  /// Las últimas etiquetas asignadas a un contenido, de la más reciente a la más
  /// antigua.
  ///
  /// Sirven para ofrecerlas nada más pulsar el campo, antes de escribir nada:
  /// etiquetar una tanda es poner las mismas tres una y otra vez, y escribirlas
  /// enteras cada vez es el trabajo que esto ahorra.
  List<int> recentTagIds() => _recent(recentTagsPreferenceKey);

  List<int> recentCreatorIds() => _recent(recentCreatorsPreferenceKey);

  /// Los últimos fernies a los que se les marchó una región.
  ///
  /// El menú que sale al marcar los pone arriba del todo: marcar es un gesto que
  /// se repite mucho y casi siempre sobre el mismo, y la lista salía por orden
  /// de creación —con el recién creado arriba—, que es justo el orden que deja
  /// de valer en cuanto se han creado tres.
  List<int> recentFernieIds() => _recent(recentFerniesPreferenceKey);

  Future<void> pushRecentTag(int id) =>
      _pushRecent(recentTagsPreferenceKey, id);

  Future<void> pushRecentCreator(int id) =>
      _pushRecent(recentCreatorsPreferenceKey, id);

  /// Si la casilla de «no volver a importar» quedó marcada.
  ///
  /// Apagada de fábrica: descartar algo es lo normal y no querer volver a verlo
  /// nunca más es la excepción, así que la que se repite sin pensar tiene que
  /// ser la que no bloquea.
  bool getBlocksImportOnDiscard() =>
      _prefs.getBool(blocksImportOnDiscardPreferenceKey) ?? false;

  Future<bool> setBlocksImportOnDiscard(bool value) =>
      _prefs.setBool(blocksImportOnDiscardPreferenceKey, value);

  Future<void> pushRecentFernie(int id) =>
      _pushRecent(recentFerniesPreferenceKey, id);

  /// Las ramas de etiquetas que están plegadas en el menú y en la lista.
  ///
  /// Se guardan las plegadas: sin nada guardado el árbol sale entero, que es lo
  /// que hacía antes de poder plegarlo.
  Set<int> collapsedTagIds() => {
        for (final each
            in _prefs.getStringList(collapsedTagsPreferenceKey) ??
                const <String>[])
          if (int.tryParse(each) case final id?) id,
      };

  Future<void> setCollapsedTagIds(Set<int> ids) => _prefs.setStringList(
        collapsedTagsPreferenceKey,
        [for (final id in ids) '$id'],
      );

  List<int> _recent(String key) => [
        for (final each in _prefs.getStringList(key) ?? const <String>[])
          if (int.tryParse(each) case final id?) id,
      ];

  /// Pone [id] el primero y quita el que sobre por el final.
  ///
  /// Si ya estaba, sube: lo que interesa es el orden de uso, no el de la primera
  /// vez que se usó.
  Future<void> _pushRecent(String key, int id) async {
    final kept = [
      id,
      for (final each in _recent(key))
        if (each != id) each,
    ];

    await _prefs.setStringList(
      key,
      [
        for (final each in kept.take(recentPicksStored)) '$each',
      ],
    );
  }
}
