import 'dart:io';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/model_repository.dart';
import 'package:Fern/features/recognition/domain/services/model_slug.dart';
import 'package:path/path.dart' as p;

/// Qué sabe reconocer un fichero de pesos.
///
/// Va por parámetro porque leerlo es cosa del sidecar, y así esto se prueba sin
/// levantar Python.
typedef WeightsInspector = Future<List<String>> Function(String path);

/// Dónde vive todo lo del reconocimiento.
typedef RecognitionRoot = Future<String> Function();

/// Lo que salió de traerse unos pesos de fuera.
class ImportedWeights {
  final RecognitionModelEntity model;

  /// Las clases que el fichero dice reconocer, en su orden.
  ///
  /// Se enseñan sin más: emparejarlas con los fernies del modelo es cosa del
  /// usuario, porque sólo él sabe si el «marinette» de ese `.pt` es el mismo
  /// fernie que el suyo.
  final List<String> classes;

  const ImportedWeights({required this.model, required this.classes});
}

/// Trae a un modelo unos pesos entrenados en otro sitio.
///
/// Es el plan B del doc 02: quien no tenga tarjeta gráfica puede entrenar fuera
/// y traerse el `.pt`. Lo que hace falta para que eso no sea un apaño frágil es
/// **copiar el fichero dentro** de la carpeta de reconocimiento: apuntar a un
/// `.pt` en Descargas deja el modelo roto la primera vez que alguien limpie esa
/// carpeta, y sin manera de saber por qué.
class WeightsImporter {
  final ModelRepository _models;
  final WeightsInspector _inspect;
  final RecognitionRoot _root;

  WeightsImporter({
    required ModelRepository models,
    required WeightsInspector inspect,
    required RecognitionRoot root,
  })  : _models = models,
        _inspect = inspect,
        _root = root;

  /// La carpeta donde se guardan los pesos traídos de fuera.
  static const importedFolder = 'imported';

  Future<DataState<ImportedWeights>> import({
    required int modelId,
    required String sourcePath,
  }) async {
    final source = File(sourcePath);

    if (!await source.exists()) {
      return DataException(Exception('WEIGHTS_NOT_FOUND: $sourcePath'));
    }

    final current = await _models.getModel(modelId);
    if (current is! DataSuccess || current.data == null) {
      return DataException(Exception('MODEL_NOT_FOUND: $modelId'));
    }

    final model = current.data!;

    // Se pregunta **antes** de copiar: si el fichero no es unos pesos que se
    // puedan cargar, no tiene sentido dejarlo dentro y luego tener que limpiar.
    final List<String> classes;

    try {
      classes = await _inspect(sourcePath);
    } on Object catch (error) {
      return DataException(Exception('$error'));
    }

    final String destination;

    try {
      destination = await _copy(source, modelId: modelId, name: model.name);
    } on FileSystemException catch (error) {
      return DataException(Exception('WEIGHTS_COPY_FAILED: ${error.message}'));
    }

    final saved = await _models.saveModel(model.copyWith(
      weightsPath: destination,
      isImportedWeights: true,
      lastTrainedAt: DateTime.now(),
      // Las métricas y el fallo del último entrenamiento eran de **otros**
      // pesos: dejarlos puestos diría que este `.pt` acierta un 0,83 sin que
      // nadie lo haya medido. El error se limpia solo, que es como funciona
      // `copyWith`.
      clearMetrics: true,
    ));

    if (saved is! DataSuccess || saved.data == null) {
      return DataException(saved.exception ?? Exception('WEIGHTS_SAVE_FAILED'));
    }

    return DataSuccess(
      ImportedWeights(model: saved.data!, classes: classes),
    );
  }

  /// Copia el `.pt` dentro de la carpeta de reconocimiento.
  ///
  /// El nombre lleva el identificador del modelo delante para que dos modelos
  /// con pesos que se llaman igual —`best.pt` los llama todo el mundo— no se
  /// pisen el uno al otro.
  Future<String> _copy(
    File source, {
    required int modelId,
    required String name,
  }) async {
    final folder = Directory(p.join(await _root(), importedFolder));
    await folder.create(recursive: true);

    final destination = p.join(
      folder.path,
      '$modelId-${modelSlug(name)}${p.extension(source.path)}',
    );

    // Reimportar sobre el mismo modelo reemplaza: quedarse las dos versiones
    // sólo llena el disco de ficheros que nadie va a distinguir.
    await source.copy(destination);

    return destination;
  }
}
