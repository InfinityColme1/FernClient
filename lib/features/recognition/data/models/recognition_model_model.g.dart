// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognition_model_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecognitionModelModelCollection on Isar {
  IsarCollection<RecognitionModelModel> get recognitionModelModels =>
      this.collection();
}

const RecognitionModelModelSchema = CollectionSchema(
  name: r'RecognitionModels',
  id: 4961358072048289579,
  properties: {
    r'backbone': PropertySchema(
      id: 0,
      name: r'backbone',
      type: IsarType.string,
    ),
    r'batch': PropertySchema(
      id: 1,
      name: r'batch',
      type: IsarType.long,
    ),
    r'confidenceThreshold': PropertySchema(
      id: 2,
      name: r'confidenceThreshold',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'epochs': PropertySchema(
      id: 4,
      name: r'epochs',
      type: IsarType.long,
    ),
    r'function': PropertySchema(
      id: 5,
      name: r'function',
      type: IsarType.string,
      enumMap: _RecognitionModelModelfunctionEnumValueMap,
    ),
    r'imgsz': PropertySchema(
      id: 6,
      name: r'imgsz',
      type: IsarType.long,
    ),
    r'isImportedWeights': PropertySchema(
      id: 7,
      name: r'isImportedWeights',
      type: IsarType.bool,
    ),
    r'isTraining': PropertySchema(
      id: 8,
      name: r'isTraining',
      type: IsarType.bool,
    ),
    r'lastError': PropertySchema(
      id: 9,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'lastMetrics': PropertySchema(
      id: 10,
      name: r'lastMetrics',
      type: IsarType.string,
    ),
    r'lastTrainedAt': PropertySchema(
      id: 11,
      name: r'lastTrainedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 12,
      name: r'name',
      type: IsarType.string,
    ),
    r'picturePath': PropertySchema(
      id: 13,
      name: r'picturePath',
      type: IsarType.string,
    ),
    r'preset': PropertySchema(
      id: 14,
      name: r'preset',
      type: IsarType.string,
      enumMap: _RecognitionModelModelpresetEnumValueMap,
    ),
    r'weightsPath': PropertySchema(
      id: 15,
      name: r'weightsPath',
      type: IsarType.string,
    )
  },
  estimateSize: _recognitionModelModelEstimateSize,
  serialize: _recognitionModelModelSerialize,
  deserialize: _recognitionModelModelDeserialize,
  deserializeProp: _recognitionModelModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'fernies': LinkSchema(
      id: 6565382752159328486,
      name: r'fernies',
      target: r'ModelFernies',
      single: false,
      linkName: r'model',
    )
  },
  embeddedSchemas: {},
  getId: _recognitionModelModelGetId,
  getLinks: _recognitionModelModelGetLinks,
  attach: _recognitionModelModelAttach,
  version: '3.1.0+1',
);

int _recognitionModelModelEstimateSize(
  RecognitionModelModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.backbone.length * 3;
  bytesCount += 3 + object.function.name.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMetrics;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.picturePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.preset.name.length * 3;
  {
    final value = object.weightsPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _recognitionModelModelSerialize(
  RecognitionModelModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.backbone);
  writer.writeLong(offsets[1], object.batch);
  writer.writeDouble(offsets[2], object.confidenceThreshold);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeLong(offsets[4], object.epochs);
  writer.writeString(offsets[5], object.function.name);
  writer.writeLong(offsets[6], object.imgsz);
  writer.writeBool(offsets[7], object.isImportedWeights);
  writer.writeBool(offsets[8], object.isTraining);
  writer.writeString(offsets[9], object.lastError);
  writer.writeString(offsets[10], object.lastMetrics);
  writer.writeDateTime(offsets[11], object.lastTrainedAt);
  writer.writeString(offsets[12], object.name);
  writer.writeString(offsets[13], object.picturePath);
  writer.writeString(offsets[14], object.preset.name);
  writer.writeString(offsets[15], object.weightsPath);
}

RecognitionModelModel _recognitionModelModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecognitionModelModel();
  object.backbone = reader.readString(offsets[0]);
  object.batch = reader.readLong(offsets[1]);
  object.confidenceThreshold = reader.readDouble(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.epochs = reader.readLong(offsets[4]);
  object.function = _RecognitionModelModelfunctionValueEnumMap[
          reader.readStringOrNull(offsets[5])] ??
      ModelFunction.boolean;
  object.id = id;
  object.imgsz = reader.readLong(offsets[6]);
  object.isImportedWeights = reader.readBool(offsets[7]);
  object.isTraining = reader.readBool(offsets[8]);
  object.lastError = reader.readStringOrNull(offsets[9]);
  object.lastMetrics = reader.readStringOrNull(offsets[10]);
  object.lastTrainedAt = reader.readDateTimeOrNull(offsets[11]);
  object.name = reader.readString(offsets[12]);
  object.picturePath = reader.readStringOrNull(offsets[13]);
  object.preset = _RecognitionModelModelpresetValueEnumMap[
          reader.readStringOrNull(offsets[14])] ??
      TrainingPreset.fast;
  object.weightsPath = reader.readStringOrNull(offsets[15]);
  return object;
}

P _recognitionModelModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (_RecognitionModelModelfunctionValueEnumMap[
              reader.readStringOrNull(offset)] ??
          ModelFunction.boolean) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (_RecognitionModelModelpresetValueEnumMap[
              reader.readStringOrNull(offset)] ??
          TrainingPreset.fast) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RecognitionModelModelfunctionEnumValueMap = {
  r'boolean': r'boolean',
  r'classification': r'classification',
};
const _RecognitionModelModelfunctionValueEnumMap = {
  r'boolean': ModelFunction.boolean,
  r'classification': ModelFunction.classification,
};
const _RecognitionModelModelpresetEnumValueMap = {
  r'fast': r'fast',
  r'balanced': r'balanced',
  r'accurate': r'accurate',
  r'custom': r'custom',
};
const _RecognitionModelModelpresetValueEnumMap = {
  r'fast': TrainingPreset.fast,
  r'balanced': TrainingPreset.balanced,
  r'accurate': TrainingPreset.accurate,
  r'custom': TrainingPreset.custom,
};

Id _recognitionModelModelGetId(RecognitionModelModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recognitionModelModelGetLinks(
    RecognitionModelModel object) {
  return [object.fernies];
}

void _recognitionModelModelAttach(
    IsarCollection<dynamic> col, Id id, RecognitionModelModel object) {
  object.id = id;
  object.fernies
      .attach(col, col.isar.collection<ModelFernieModel>(), r'fernies', id);
}

extension RecognitionModelModelQueryWhereSort
    on QueryBuilder<RecognitionModelModel, RecognitionModelModel, QWhere> {
  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecognitionModelModelQueryWhere on QueryBuilder<RecognitionModelModel,
    RecognitionModelModel, QWhereClause> {
  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RecognitionModelModelQueryFilter on QueryBuilder<
    RecognitionModelModel, RecognitionModelModel, QFilterCondition> {
  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> backboneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backbone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> backboneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backbone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> backboneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backbone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> backboneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backbone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> backboneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'backbone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> backboneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'backbone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      backboneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'backbone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      backboneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'backbone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> backboneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backbone',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> backboneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'backbone',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> batchEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'batch',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> batchGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'batch',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> batchLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'batch',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> batchBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'batch',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> confidenceThresholdEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidenceThreshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> confidenceThresholdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidenceThreshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> confidenceThresholdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidenceThreshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> confidenceThresholdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidenceThreshold',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> epochsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'epochs',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> epochsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'epochs',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> epochsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'epochs',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> epochsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'epochs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> functionEqualTo(
    ModelFunction value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'function',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> functionGreaterThan(
    ModelFunction value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'function',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> functionLessThan(
    ModelFunction value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'function',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> functionBetween(
    ModelFunction lower,
    ModelFunction upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'function',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> functionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'function',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> functionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'function',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      functionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'function',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      functionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'function',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> functionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'function',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> functionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'function',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> imgszEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imgsz',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> imgszGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imgsz',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> imgszLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imgsz',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> imgszBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imgsz',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> isImportedWeightsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isImportedWeights',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> isTrainingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTraining',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMetrics',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMetrics',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMetrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMetrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMetrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMetrics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMetrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMetrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      lastMetricsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMetrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      lastMetricsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMetrics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMetrics',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastMetricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMetrics',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastTrainedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastTrainedAt',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastTrainedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastTrainedAt',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastTrainedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastTrainedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastTrainedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastTrainedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastTrainedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastTrainedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> lastTrainedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastTrainedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'picturePath',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'picturePath',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'picturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'picturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'picturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'picturePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'picturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'picturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      picturePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'picturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      picturePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'picturePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'picturePath',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> picturePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'picturePath',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> presetEqualTo(
    TrainingPreset value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> presetGreaterThan(
    TrainingPreset value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> presetLessThan(
    TrainingPreset value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> presetBetween(
    TrainingPreset lower,
    TrainingPreset upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> presetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'preset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> presetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'preset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      presetContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'preset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      presetMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'preset',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> presetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preset',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> presetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'preset',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weightsPath',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weightsPath',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightsPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weightsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weightsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      weightsPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weightsPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
          QAfterFilterCondition>
      weightsPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weightsPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightsPath',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> weightsPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weightsPath',
        value: '',
      ));
    });
  }
}

extension RecognitionModelModelQueryObject on QueryBuilder<
    RecognitionModelModel, RecognitionModelModel, QFilterCondition> {}

extension RecognitionModelModelQueryLinks on QueryBuilder<RecognitionModelModel,
    RecognitionModelModel, QFilterCondition> {
  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> fernies(FilterQuery<ModelFernieModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'fernies');
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> ferniesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fernies', length, true, length, true);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> ferniesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fernies', 0, true, 0, true);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> ferniesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fernies', 0, false, 999999, true);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> ferniesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fernies', 0, true, length, include);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> ferniesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fernies', length, include, 999999, true);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel,
      QAfterFilterCondition> ferniesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'fernies', lower, includeLower, upper, includeUpper);
    });
  }
}

extension RecognitionModelModelQuerySortBy
    on QueryBuilder<RecognitionModelModel, RecognitionModelModel, QSortBy> {
  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByBackbone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backbone', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByBackboneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backbone', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByBatch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batch', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByBatchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batch', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByConfidenceThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceThreshold', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByConfidenceThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceThreshold', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByEpochs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epochs', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByEpochsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epochs', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByFunction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'function', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByFunctionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'function', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByImgsz() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imgsz', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByImgszDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imgsz', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByIsImportedWeights() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportedWeights', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByIsImportedWeightsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportedWeights', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByIsTraining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTraining', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByIsTrainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTraining', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByLastMetrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMetrics', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByLastMetricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMetrics', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByLastTrainedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTrainedAt', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByLastTrainedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTrainedAt', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByPicturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByPicturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preset', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preset', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByWeightsPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightsPath', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      sortByWeightsPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightsPath', Sort.desc);
    });
  }
}

extension RecognitionModelModelQuerySortThenBy
    on QueryBuilder<RecognitionModelModel, RecognitionModelModel, QSortThenBy> {
  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByBackbone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backbone', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByBackboneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backbone', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByBatch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batch', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByBatchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'batch', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByConfidenceThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceThreshold', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByConfidenceThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceThreshold', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByEpochs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epochs', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByEpochsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epochs', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByFunction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'function', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByFunctionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'function', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByImgsz() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imgsz', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByImgszDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imgsz', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByIsImportedWeights() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportedWeights', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByIsImportedWeightsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportedWeights', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByIsTraining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTraining', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByIsTrainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTraining', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByLastMetrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMetrics', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByLastMetricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMetrics', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByLastTrainedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTrainedAt', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByLastTrainedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTrainedAt', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByPicturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByPicturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preset', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preset', Sort.desc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByWeightsPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightsPath', Sort.asc);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QAfterSortBy>
      thenByWeightsPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightsPath', Sort.desc);
    });
  }
}

extension RecognitionModelModelQueryWhereDistinct
    on QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct> {
  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByBackbone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backbone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByBatch() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'batch');
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByConfidenceThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidenceThreshold');
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByEpochs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'epochs');
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByFunction({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'function', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByImgsz() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imgsz');
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByIsImportedWeights() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isImportedWeights');
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByIsTraining() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTraining');
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByLastMetrics({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMetrics', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByLastTrainedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastTrainedAt');
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByPicturePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'picturePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByPreset({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preset', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecognitionModelModel, RecognitionModelModel, QDistinct>
      distinctByWeightsPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightsPath', caseSensitive: caseSensitive);
    });
  }
}

extension RecognitionModelModelQueryProperty on QueryBuilder<
    RecognitionModelModel, RecognitionModelModel, QQueryProperty> {
  QueryBuilder<RecognitionModelModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecognitionModelModel, String, QQueryOperations>
      backboneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backbone');
    });
  }

  QueryBuilder<RecognitionModelModel, int, QQueryOperations> batchProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'batch');
    });
  }

  QueryBuilder<RecognitionModelModel, double, QQueryOperations>
      confidenceThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidenceThreshold');
    });
  }

  QueryBuilder<RecognitionModelModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RecognitionModelModel, int, QQueryOperations> epochsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'epochs');
    });
  }

  QueryBuilder<RecognitionModelModel, ModelFunction, QQueryOperations>
      functionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'function');
    });
  }

  QueryBuilder<RecognitionModelModel, int, QQueryOperations> imgszProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imgsz');
    });
  }

  QueryBuilder<RecognitionModelModel, bool, QQueryOperations>
      isImportedWeightsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isImportedWeights');
    });
  }

  QueryBuilder<RecognitionModelModel, bool, QQueryOperations>
      isTrainingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTraining');
    });
  }

  QueryBuilder<RecognitionModelModel, String?, QQueryOperations>
      lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<RecognitionModelModel, String?, QQueryOperations>
      lastMetricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMetrics');
    });
  }

  QueryBuilder<RecognitionModelModel, DateTime?, QQueryOperations>
      lastTrainedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastTrainedAt');
    });
  }

  QueryBuilder<RecognitionModelModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<RecognitionModelModel, String?, QQueryOperations>
      picturePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'picturePath');
    });
  }

  QueryBuilder<RecognitionModelModel, TrainingPreset, QQueryOperations>
      presetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preset');
    });
  }

  QueryBuilder<RecognitionModelModel, String?, QQueryOperations>
      weightsPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightsPath');
    });
  }
}
