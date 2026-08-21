// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_fernie_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetModelFernieModelCollection on Isar {
  IsarCollection<ModelFernieModel> get modelFernieModels => this.collection();
}

const ModelFernieModelSchema = CollectionSchema(
  name: r'ModelFernies',
  id: -7751032087742207810,
  properties: {
    r'classIndex': PropertySchema(
      id: 0,
      name: r'classIndex',
      type: IsarType.long,
    ),
    r'testPercent': PropertySchema(
      id: 1,
      name: r'testPercent',
      type: IsarType.long,
    ),
    r'trainPercent': PropertySchema(
      id: 2,
      name: r'trainPercent',
      type: IsarType.long,
    ),
    r'valPercent': PropertySchema(
      id: 3,
      name: r'valPercent',
      type: IsarType.long,
    )
  },
  estimateSize: _modelFernieModelEstimateSize,
  serialize: _modelFernieModelSerialize,
  deserialize: _modelFernieModelDeserialize,
  deserializeProp: _modelFernieModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'model': LinkSchema(
      id: -9061013994709067464,
      name: r'model',
      target: r'RecognitionModels',
      single: true,
    ),
    r'fernie': LinkSchema(
      id: 3251808365853517371,
      name: r'fernie',
      target: r'Fernies',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _modelFernieModelGetId,
  getLinks: _modelFernieModelGetLinks,
  attach: _modelFernieModelAttach,
  version: '3.1.0+1',
);

int _modelFernieModelEstimateSize(
  ModelFernieModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _modelFernieModelSerialize(
  ModelFernieModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.classIndex);
  writer.writeLong(offsets[1], object.testPercent);
  writer.writeLong(offsets[2], object.trainPercent);
  writer.writeLong(offsets[3], object.valPercent);
}

ModelFernieModel _modelFernieModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ModelFernieModel();
  object.classIndex = reader.readLong(offsets[0]);
  object.id = id;
  object.testPercent = reader.readLong(offsets[1]);
  object.trainPercent = reader.readLong(offsets[2]);
  object.valPercent = reader.readLong(offsets[3]);
  return object;
}

P _modelFernieModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _modelFernieModelGetId(ModelFernieModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _modelFernieModelGetLinks(ModelFernieModel object) {
  return [object.model, object.fernie];
}

void _modelFernieModelAttach(
    IsarCollection<dynamic> col, Id id, ModelFernieModel object) {
  object.id = id;
  object.model
      .attach(col, col.isar.collection<RecognitionModelModel>(), r'model', id);
  object.fernie.attach(col, col.isar.collection<FernieModel>(), r'fernie', id);
}

extension ModelFernieModelQueryWhereSort
    on QueryBuilder<ModelFernieModel, ModelFernieModel, QWhere> {
  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ModelFernieModelQueryWhere
    on QueryBuilder<ModelFernieModel, ModelFernieModel, QWhereClause> {
  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterWhereClause>
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

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterWhereClause> idBetween(
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

extension ModelFernieModelQueryFilter
    on QueryBuilder<ModelFernieModel, ModelFernieModel, QFilterCondition> {
  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      classIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      classIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'classIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      classIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'classIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      classIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'classIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      testPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      testPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'testPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      testPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'testPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      testPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'testPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      trainPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trainPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      trainPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trainPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      trainPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trainPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      trainPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trainPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      valPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'valPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      valPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'valPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      valPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'valPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      valPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'valPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ModelFernieModelQueryObject
    on QueryBuilder<ModelFernieModel, ModelFernieModel, QFilterCondition> {}

extension ModelFernieModelQueryLinks
    on QueryBuilder<ModelFernieModel, ModelFernieModel, QFilterCondition> {
  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition> model(
      FilterQuery<RecognitionModelModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'model');
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      modelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'model', 0, true, 0, true);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      fernie(FilterQuery<FernieModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'fernie');
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterFilterCondition>
      fernieIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fernie', 0, true, 0, true);
    });
  }
}

extension ModelFernieModelQuerySortBy
    on QueryBuilder<ModelFernieModel, ModelFernieModel, QSortBy> {
  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      sortByClassIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classIndex', Sort.asc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      sortByClassIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classIndex', Sort.desc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      sortByTestPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testPercent', Sort.asc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      sortByTestPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testPercent', Sort.desc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      sortByTrainPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainPercent', Sort.asc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      sortByTrainPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainPercent', Sort.desc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      sortByValPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valPercent', Sort.asc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      sortByValPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valPercent', Sort.desc);
    });
  }
}

extension ModelFernieModelQuerySortThenBy
    on QueryBuilder<ModelFernieModel, ModelFernieModel, QSortThenBy> {
  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      thenByClassIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classIndex', Sort.asc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      thenByClassIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classIndex', Sort.desc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      thenByTestPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testPercent', Sort.asc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      thenByTestPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testPercent', Sort.desc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      thenByTrainPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainPercent', Sort.asc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      thenByTrainPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainPercent', Sort.desc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      thenByValPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valPercent', Sort.asc);
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QAfterSortBy>
      thenByValPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valPercent', Sort.desc);
    });
  }
}

extension ModelFernieModelQueryWhereDistinct
    on QueryBuilder<ModelFernieModel, ModelFernieModel, QDistinct> {
  QueryBuilder<ModelFernieModel, ModelFernieModel, QDistinct>
      distinctByClassIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classIndex');
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QDistinct>
      distinctByTestPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'testPercent');
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QDistinct>
      distinctByTrainPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trainPercent');
    });
  }

  QueryBuilder<ModelFernieModel, ModelFernieModel, QDistinct>
      distinctByValPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valPercent');
    });
  }
}

extension ModelFernieModelQueryProperty
    on QueryBuilder<ModelFernieModel, ModelFernieModel, QQueryProperty> {
  QueryBuilder<ModelFernieModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ModelFernieModel, int, QQueryOperations> classIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classIndex');
    });
  }

  QueryBuilder<ModelFernieModel, int, QQueryOperations> testPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'testPercent');
    });
  }

  QueryBuilder<ModelFernieModel, int, QQueryOperations> trainPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trainPercent');
    });
  }

  QueryBuilder<ModelFernieModel, int, QQueryOperations> valPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valPercent');
    });
  }
}
