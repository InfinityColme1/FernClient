// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognition_result_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecognitionResultModelCollection on Isar {
  IsarCollection<RecognitionResultModel> get recognitionResultModels =>
      this.collection();
}

const RecognitionResultModelSchema = CollectionSchema(
  name: r'RecognitionResults',
  id: 3732533037868903375,
  properties: {
    r'confidence': PropertySchema(
      id: 0,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fernieId': PropertySchema(
      id: 2,
      name: r'fernieId',
      type: IsarType.long,
    ),
    r'frameMs': PropertySchema(
      id: 3,
      name: r'frameMs',
      type: IsarType.long,
    ),
    r'h': PropertySchema(
      id: 4,
      name: r'h',
      type: IsarType.double,
    ),
    r'mediaId': PropertySchema(
      id: 5,
      name: r'mediaId',
      type: IsarType.long,
    ),
    r'modelId': PropertySchema(
      id: 6,
      name: r'modelId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 7,
      name: r'status',
      type: IsarType.string,
      enumMap: _RecognitionResultModelstatusEnumValueMap,
    ),
    r'w': PropertySchema(
      id: 8,
      name: r'w',
      type: IsarType.double,
    ),
    r'x': PropertySchema(
      id: 9,
      name: r'x',
      type: IsarType.double,
    ),
    r'y': PropertySchema(
      id: 10,
      name: r'y',
      type: IsarType.double,
    )
  },
  estimateSize: _recognitionResultModelEstimateSize,
  serialize: _recognitionResultModelSerialize,
  deserialize: _recognitionResultModelDeserialize,
  deserializeProp: _recognitionResultModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'mediaId': IndexSchema(
      id: -8001372983137409759,
      name: r'mediaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'mediaId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'modelId': IndexSchema(
      id: -1910745378942518156,
      name: r'modelId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'modelId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _recognitionResultModelGetId,
  getLinks: _recognitionResultModelGetLinks,
  attach: _recognitionResultModelAttach,
  version: '3.1.0+1',
);

int _recognitionResultModelEstimateSize(
  RecognitionResultModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _recognitionResultModelSerialize(
  RecognitionResultModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.confidence);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.fernieId);
  writer.writeLong(offsets[3], object.frameMs);
  writer.writeDouble(offsets[4], object.h);
  writer.writeLong(offsets[5], object.mediaId);
  writer.writeLong(offsets[6], object.modelId);
  writer.writeString(offsets[7], object.status.name);
  writer.writeDouble(offsets[8], object.w);
  writer.writeDouble(offsets[9], object.x);
  writer.writeDouble(offsets[10], object.y);
}

RecognitionResultModel _recognitionResultModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecognitionResultModel();
  object.confidence = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.fernieId = reader.readLong(offsets[2]);
  object.frameMs = reader.readLongOrNull(offsets[3]);
  object.h = reader.readDoubleOrNull(offsets[4]);
  object.id = id;
  object.mediaId = reader.readLong(offsets[5]);
  object.modelId = reader.readLong(offsets[6]);
  object.status = _RecognitionResultModelstatusValueEnumMap[
          reader.readStringOrNull(offsets[7])] ??
      SuggestionStatus.suggested;
  object.w = reader.readDoubleOrNull(offsets[8]);
  object.x = reader.readDoubleOrNull(offsets[9]);
  object.y = reader.readDoubleOrNull(offsets[10]);
  return object;
}

P _recognitionResultModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (_RecognitionResultModelstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          SuggestionStatus.suggested) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RecognitionResultModelstatusEnumValueMap = {
  r'suggested': r'suggested',
  r'accepted': r'accepted',
  r'rejected': r'rejected',
};
const _RecognitionResultModelstatusValueEnumMap = {
  r'suggested': SuggestionStatus.suggested,
  r'accepted': SuggestionStatus.accepted,
  r'rejected': SuggestionStatus.rejected,
};

Id _recognitionResultModelGetId(RecognitionResultModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recognitionResultModelGetLinks(
    RecognitionResultModel object) {
  return [];
}

void _recognitionResultModelAttach(
    IsarCollection<dynamic> col, Id id, RecognitionResultModel object) {
  object.id = id;
}

extension RecognitionResultModelQueryWhereSort
    on QueryBuilder<RecognitionResultModel, RecognitionResultModel, QWhere> {
  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterWhere>
      anyMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'mediaId'),
      );
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterWhere>
      anyModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'modelId'),
      );
    });
  }
}

extension RecognitionResultModelQueryWhere on QueryBuilder<
    RecognitionResultModel, RecognitionResultModel, QWhereClause> {
  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> mediaIdEqualTo(int mediaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mediaId',
        value: [mediaId],
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> mediaIdNotEqualTo(int mediaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mediaId',
              lower: [],
              upper: [mediaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mediaId',
              lower: [mediaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mediaId',
              lower: [mediaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mediaId',
              lower: [],
              upper: [mediaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> mediaIdGreaterThan(
    int mediaId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'mediaId',
        lower: [mediaId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> mediaIdLessThan(
    int mediaId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'mediaId',
        lower: [],
        upper: [mediaId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> mediaIdBetween(
    int lowerMediaId,
    int upperMediaId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'mediaId',
        lower: [lowerMediaId],
        includeLower: includeLower,
        upper: [upperMediaId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> modelIdEqualTo(int modelId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'modelId',
        value: [modelId],
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> modelIdNotEqualTo(int modelId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'modelId',
              lower: [],
              upper: [modelId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'modelId',
              lower: [modelId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'modelId',
              lower: [modelId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'modelId',
              lower: [],
              upper: [modelId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> modelIdGreaterThan(
    int modelId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'modelId',
        lower: [modelId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> modelIdLessThan(
    int modelId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'modelId',
        lower: [],
        upper: [modelId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> modelIdBetween(
    int lowerModelId,
    int upperModelId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'modelId',
        lower: [lowerModelId],
        includeLower: includeLower,
        upper: [upperModelId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> statusEqualTo(SuggestionStatus status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterWhereClause> statusNotEqualTo(SuggestionStatus status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }
}

extension RecognitionResultModelQueryFilter on QueryBuilder<
    RecognitionResultModel, RecognitionResultModel, QFilterCondition> {
  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> confidenceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> confidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> confidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> confidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
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

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
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

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
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

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> fernieIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fernieId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> fernieIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fernieId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> fernieIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fernieId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> fernieIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fernieId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> frameMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'frameMs',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> frameMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'frameMs',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> frameMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frameMs',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> frameMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frameMs',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> frameMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frameMs',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> frameMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frameMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> hIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'h',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> hIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'h',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> hEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'h',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> hGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'h',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> hLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'h',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> hBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'h',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
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

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
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

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
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

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> mediaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> mediaIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> mediaIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> mediaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> modelIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> modelIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modelId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> modelIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modelId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> modelIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modelId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> statusEqualTo(
    SuggestionStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> statusGreaterThan(
    SuggestionStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> statusLessThan(
    SuggestionStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> statusBetween(
    SuggestionStatus lower,
    SuggestionStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> wIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'w',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> wIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'w',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> wEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'w',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> wGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'w',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> wLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'w',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> wBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'w',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> xIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'x',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> xIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'x',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> xEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'x',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> xGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'x',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> xLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'x',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> xBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'x',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> yIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'y',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> yIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'y',
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> yEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'y',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> yGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'y',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> yLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'y',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel,
      QAfterFilterCondition> yBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'y',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension RecognitionResultModelQueryObject on QueryBuilder<
    RecognitionResultModel, RecognitionResultModel, QFilterCondition> {}

extension RecognitionResultModelQueryLinks on QueryBuilder<
    RecognitionResultModel, RecognitionResultModel, QFilterCondition> {}

extension RecognitionResultModelQuerySortBy
    on QueryBuilder<RecognitionResultModel, RecognitionResultModel, QSortBy> {
  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByFernieId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fernieId', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByFernieIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fernieId', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByFrameMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameMs', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByFrameMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameMs', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByH() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'h', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByHDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'h', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByModelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByW() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'w', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByWDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'w', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'y', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      sortByYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'y', Sort.desc);
    });
  }
}

extension RecognitionResultModelQuerySortThenBy on QueryBuilder<
    RecognitionResultModel, RecognitionResultModel, QSortThenBy> {
  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByFernieId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fernieId', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByFernieIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fernieId', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByFrameMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameMs', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByFrameMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameMs', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByH() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'h', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByHDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'h', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByModelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByW() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'w', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByWDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'w', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x', Sort.desc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'y', Sort.asc);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QAfterSortBy>
      thenByYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'y', Sort.desc);
    });
  }
}

extension RecognitionResultModelQueryWhereDistinct
    on QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct> {
  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByFernieId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fernieId');
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByFrameMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frameMs');
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByH() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'h');
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaId');
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelId');
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByW() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'w');
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByX() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'x');
    });
  }

  QueryBuilder<RecognitionResultModel, RecognitionResultModel, QDistinct>
      distinctByY() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'y');
    });
  }
}

extension RecognitionResultModelQueryProperty on QueryBuilder<
    RecognitionResultModel, RecognitionResultModel, QQueryProperty> {
  QueryBuilder<RecognitionResultModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecognitionResultModel, double, QQueryOperations>
      confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<RecognitionResultModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RecognitionResultModel, int, QQueryOperations>
      fernieIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fernieId');
    });
  }

  QueryBuilder<RecognitionResultModel, int?, QQueryOperations>
      frameMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frameMs');
    });
  }

  QueryBuilder<RecognitionResultModel, double?, QQueryOperations> hProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'h');
    });
  }

  QueryBuilder<RecognitionResultModel, int, QQueryOperations>
      mediaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaId');
    });
  }

  QueryBuilder<RecognitionResultModel, int, QQueryOperations>
      modelIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelId');
    });
  }

  QueryBuilder<RecognitionResultModel, SuggestionStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<RecognitionResultModel, double?, QQueryOperations> wProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'w');
    });
  }

  QueryBuilder<RecognitionResultModel, double?, QQueryOperations> xProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'x');
    });
  }

  QueryBuilder<RecognitionResultModel, double?, QQueryOperations> yProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'y');
    });
  }
}
