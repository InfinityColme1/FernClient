import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/recognition/data/services/weights_importer.dart';

class ImportModelWeightsParams {
  final int modelId;

  /// El `.pt` que ha elegido el usuario, donde lo tenga.
  final String sourcePath;

  const ImportModelWeightsParams({
    required this.modelId,
    required this.sourcePath,
  });
}

/// Le pone a un modelo unos pesos entrenados en otro sitio.
///
/// Es el plan B del doc 02: quien tenga una tarjeta gráfica de verdad puede
/// entrenar fuera —en Colab, en otro equipo— y traerse el `.pt`. Sin esto, un
/// equipo sin GPU no puede reconocer nada por muchos fernies que marque.
class ImportModelWeightsUseCase
    extends UseCase<DataState<ImportedWeights>, ImportModelWeightsParams> {
  final WeightsImporter _importer;

  ImportModelWeightsUseCase(this._importer);

  @override
  Future<DataState<ImportedWeights>> call({
    ImportModelWeightsParams? params,
  }) {
    return _importer.import(
      modelId: params!.modelId,
      sourcePath: params.sourcePath,
    );
  }
}
