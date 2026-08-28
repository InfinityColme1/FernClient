// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_tree_node_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetModelTreeNodeModelCollection on Isar {
  IsarCollection<ModelTreeNodeModel> get modelTreeNodeModels =>
      this.collection();
}

const ModelTreeNodeModelSchema = CollectionSchema(
  name: r'ModelTreeNodes',
  id: -2313660526961212622,
  properties: {
    r'column': PropertySchema(
      id: 0,
      name: r'column',
      type: IsarType.long,
    ),
    r'modelId': PropertySchema(
      id: 1,
      name: r'modelId',
      type: IsarType.long,
    ),
    r'row': PropertySchema(
      id: 2,
      name: r'row',
      type: IsarType.long,
    )
  },
  estimateSize: _modelTreeNodeModelEstimateSize,
  serialize: _modelTreeNodeModelSerialize,
  deserialize: _modelTreeNodeModelDeserialize,
  deserializeProp: _modelTreeNodeModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'modelId': IndexSchema(
      id: -1910745378942518156,
      name: r'modelId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'modelId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'model': LinkSchema(
      id: -5893451694970928682,
      name: r'model',
      target: r'RecognitionModels',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _modelTreeNodeModelGetId,
  getLinks: _modelTreeNodeModelGetLinks,
  attach: _modelTreeNodeModelAttach,
  version: '3.1.0+1',
);

int _modelTreeNodeModelEstimateSize(
  ModelTreeNodeModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _modelTreeNodeModelSerialize(
  ModelTreeNodeModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.column);
  writer.writeLong(offsets[1], object.modelId);
  writer.writeLong(offsets[2], object.row);
}

ModelTreeNodeModel _modelTreeNodeModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ModelTreeNodeModel();
  object.column = reader.readLong(offsets[0]);
  object.id = id;
  object.modelId = reader.readLong(offsets[1]);
  object.row = reader.readLong(offsets[2]);
  return object;
}

P _modelTreeNodeModelDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _modelTreeNodeModelGetId(ModelTreeNodeModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _modelTreeNodeModelGetLinks(
    ModelTreeNodeModel object) {
  return [object.model];
}

void _modelTreeNodeModelAttach(
    IsarCollection<dynamic> col, Id id, ModelTreeNodeModel object) {
  object.id = id;
  object.model
      .attach(col, col.isar.collection<RecognitionModelModel>(), r'model', id);
}

extension ModelTreeNodeModelByIndex on IsarCollection<ModelTreeNodeModel> {
  Future<ModelTreeNodeModel?> getByModelId(int modelId) {
    return getByIndex(r'modelId', [modelId]);
  }

  ModelTreeNodeModel? getByModelIdSync(int modelId) {
    return getByIndexSync(r'modelId', [modelId]);
  }

  Future<bool> deleteByModelId(int modelId) {
    return deleteByIndex(r'modelId', [modelId]);
  }

  bool deleteByModelIdSync(int modelId) {
    return deleteByIndexSync(r'modelId', [modelId]);
  }

  Future<List<ModelTreeNodeModel?>> getAllByModelId(List<int> modelIdValues) {
    final values = modelIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'modelId', values);
  }

  List<ModelTreeNodeModel?> getAllByModelIdSync(List<int> modelIdValues) {
    final values = modelIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'modelId', values);
  }

  Future<int> deleteAllByModelId(List<int> modelIdValues) {
    final values = modelIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'modelId', values);
  }

  int deleteAllByModelIdSync(List<int> modelIdValues) {
    final values = modelIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'modelId', values);
  }

  Future<Id> putByModelId(ModelTreeNodeModel object) {
    return putByIndex(r'modelId', object);
  }

  Id putByModelIdSync(ModelTreeNodeModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'modelId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByModelId(List<ModelTreeNodeModel> objects) {
    return putAllByIndex(r'modelId', objects);
  }

  List<Id> putAllByModelIdSync(List<ModelTreeNodeModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'modelId', objects, saveLinks: saveLinks);
  }
}

extension ModelTreeNodeModelQueryWhereSort
    on QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QWhere> {
  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhere>
      anyModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'modelId'),
      );
    });
  }
}

extension ModelTreeNodeModelQueryWhere
    on QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QWhereClause> {
  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
      modelIdEqualTo(int modelId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'modelId',
        value: [modelId],
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
      modelIdNotEqualTo(int modelId) {
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
      modelIdGreaterThan(
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
      modelIdLessThan(
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterWhereClause>
      modelIdBetween(
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
}

extension ModelTreeNodeModelQueryFilter
    on QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QFilterCondition> {
  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      columnEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'column',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      columnGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'column',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      columnLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'column',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      columnBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'column',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      modelIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modelId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      modelIdGreaterThan(
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      modelIdLessThan(
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      modelIdBetween(
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

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      rowEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'row',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      rowGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'row',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      rowLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'row',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      rowBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'row',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ModelTreeNodeModelQueryObject
    on QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QFilterCondition> {}

extension ModelTreeNodeModelQueryLinks
    on QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QFilterCondition> {
  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      model(FilterQuery<RecognitionModelModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'model');
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterFilterCondition>
      modelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'model', 0, true, 0, true);
    });
  }
}

extension ModelTreeNodeModelQuerySortBy
    on QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QSortBy> {
  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      sortByColumn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'column', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      sortByColumnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'column', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      sortByModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      sortByModelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      sortByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      sortByRowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.desc);
    });
  }
}

extension ModelTreeNodeModelQuerySortThenBy
    on QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QSortThenBy> {
  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      thenByColumn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'column', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      thenByColumnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'column', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      thenByModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      thenByModelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelId', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      thenByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QAfterSortBy>
      thenByRowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.desc);
    });
  }
}

extension ModelTreeNodeModelQueryWhereDistinct
    on QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QDistinct> {
  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QDistinct>
      distinctByColumn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'column');
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QDistinct>
      distinctByModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelId');
    });
  }

  QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QDistinct>
      distinctByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'row');
    });
  }
}

extension ModelTreeNodeModelQueryProperty
    on QueryBuilder<ModelTreeNodeModel, ModelTreeNodeModel, QQueryProperty> {
  QueryBuilder<ModelTreeNodeModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ModelTreeNodeModel, int, QQueryOperations> columnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'column');
    });
  }

  QueryBuilder<ModelTreeNodeModel, int, QQueryOperations> modelIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelId');
    });
  }

  QueryBuilder<ModelTreeNodeModel, int, QQueryOperations> rowProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'row');
    });
  }
}
