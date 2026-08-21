// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_tree_edge_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetModelTreeEdgeModelCollection on Isar {
  IsarCollection<ModelTreeEdgeModel> get modelTreeEdgeModels =>
      this.collection();
}

const ModelTreeEdgeModelSchema = CollectionSchema(
  name: r'ModelTreeEdges',
  id: 4632773451549118149,
  properties: {
    r'childNodeId': PropertySchema(
      id: 0,
      name: r'childNodeId',
      type: IsarType.long,
    ),
    r'conditionFernieId': PropertySchema(
      id: 1,
      name: r'conditionFernieId',
      type: IsarType.long,
    ),
    r'parentNodeId': PropertySchema(
      id: 2,
      name: r'parentNodeId',
      type: IsarType.long,
    )
  },
  estimateSize: _modelTreeEdgeModelEstimateSize,
  serialize: _modelTreeEdgeModelSerialize,
  deserialize: _modelTreeEdgeModelDeserialize,
  deserializeProp: _modelTreeEdgeModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'parentNodeId': IndexSchema(
      id: -4715502685623316917,
      name: r'parentNodeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'parentNodeId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'childNodeId': IndexSchema(
      id: -3015301043478646048,
      name: r'childNodeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'childNodeId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _modelTreeEdgeModelGetId,
  getLinks: _modelTreeEdgeModelGetLinks,
  attach: _modelTreeEdgeModelAttach,
  version: '3.1.0+1',
);

int _modelTreeEdgeModelEstimateSize(
  ModelTreeEdgeModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _modelTreeEdgeModelSerialize(
  ModelTreeEdgeModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.childNodeId);
  writer.writeLong(offsets[1], object.conditionFernieId);
  writer.writeLong(offsets[2], object.parentNodeId);
}

ModelTreeEdgeModel _modelTreeEdgeModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ModelTreeEdgeModel();
  object.childNodeId = reader.readLong(offsets[0]);
  object.conditionFernieId = reader.readLongOrNull(offsets[1]);
  object.id = id;
  object.parentNodeId = reader.readLong(offsets[2]);
  return object;
}

P _modelTreeEdgeModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _modelTreeEdgeModelGetId(ModelTreeEdgeModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _modelTreeEdgeModelGetLinks(
    ModelTreeEdgeModel object) {
  return [];
}

void _modelTreeEdgeModelAttach(
    IsarCollection<dynamic> col, Id id, ModelTreeEdgeModel object) {
  object.id = id;
}

extension ModelTreeEdgeModelQueryWhereSort
    on QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QWhere> {
  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhere>
      anyParentNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'parentNodeId'),
      );
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhere>
      anyChildNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'childNodeId'),
      );
    });
  }
}

extension ModelTreeEdgeModelQueryWhere
    on QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QWhereClause> {
  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
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

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
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

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      parentNodeIdEqualTo(int parentNodeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'parentNodeId',
        value: [parentNodeId],
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      parentNodeIdNotEqualTo(int parentNodeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentNodeId',
              lower: [],
              upper: [parentNodeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentNodeId',
              lower: [parentNodeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentNodeId',
              lower: [parentNodeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentNodeId',
              lower: [],
              upper: [parentNodeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      parentNodeIdGreaterThan(
    int parentNodeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentNodeId',
        lower: [parentNodeId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      parentNodeIdLessThan(
    int parentNodeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentNodeId',
        lower: [],
        upper: [parentNodeId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      parentNodeIdBetween(
    int lowerParentNodeId,
    int upperParentNodeId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentNodeId',
        lower: [lowerParentNodeId],
        includeLower: includeLower,
        upper: [upperParentNodeId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      childNodeIdEqualTo(int childNodeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'childNodeId',
        value: [childNodeId],
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      childNodeIdNotEqualTo(int childNodeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'childNodeId',
              lower: [],
              upper: [childNodeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'childNodeId',
              lower: [childNodeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'childNodeId',
              lower: [childNodeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'childNodeId',
              lower: [],
              upper: [childNodeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      childNodeIdGreaterThan(
    int childNodeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'childNodeId',
        lower: [childNodeId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      childNodeIdLessThan(
    int childNodeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'childNodeId',
        lower: [],
        upper: [childNodeId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterWhereClause>
      childNodeIdBetween(
    int lowerChildNodeId,
    int upperChildNodeId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'childNodeId',
        lower: [lowerChildNodeId],
        includeLower: includeLower,
        upper: [upperChildNodeId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ModelTreeEdgeModelQueryFilter
    on QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QFilterCondition> {
  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      childNodeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'childNodeId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      childNodeIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'childNodeId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      childNodeIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'childNodeId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      childNodeIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'childNodeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      conditionFernieIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'conditionFernieId',
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      conditionFernieIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'conditionFernieId',
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      conditionFernieIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conditionFernieId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      conditionFernieIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conditionFernieId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      conditionFernieIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conditionFernieId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      conditionFernieIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conditionFernieId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
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

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
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

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
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

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      parentNodeIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentNodeId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      parentNodeIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentNodeId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      parentNodeIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentNodeId',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterFilterCondition>
      parentNodeIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentNodeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ModelTreeEdgeModelQueryObject
    on QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QFilterCondition> {}

extension ModelTreeEdgeModelQueryLinks
    on QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QFilterCondition> {}

extension ModelTreeEdgeModelQuerySortBy
    on QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QSortBy> {
  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      sortByChildNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childNodeId', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      sortByChildNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childNodeId', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      sortByConditionFernieId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionFernieId', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      sortByConditionFernieIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionFernieId', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      sortByParentNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentNodeId', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      sortByParentNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentNodeId', Sort.desc);
    });
  }
}

extension ModelTreeEdgeModelQuerySortThenBy
    on QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QSortThenBy> {
  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      thenByChildNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childNodeId', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      thenByChildNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childNodeId', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      thenByConditionFernieId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionFernieId', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      thenByConditionFernieIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conditionFernieId', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      thenByParentNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentNodeId', Sort.asc);
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QAfterSortBy>
      thenByParentNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentNodeId', Sort.desc);
    });
  }
}

extension ModelTreeEdgeModelQueryWhereDistinct
    on QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QDistinct> {
  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QDistinct>
      distinctByChildNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'childNodeId');
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QDistinct>
      distinctByConditionFernieId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conditionFernieId');
    });
  }

  QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QDistinct>
      distinctByParentNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentNodeId');
    });
  }
}

extension ModelTreeEdgeModelQueryProperty
    on QueryBuilder<ModelTreeEdgeModel, ModelTreeEdgeModel, QQueryProperty> {
  QueryBuilder<ModelTreeEdgeModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ModelTreeEdgeModel, int, QQueryOperations>
      childNodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'childNodeId');
    });
  }

  QueryBuilder<ModelTreeEdgeModel, int?, QQueryOperations>
      conditionFernieIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conditionFernieId');
    });
  }

  QueryBuilder<ModelTreeEdgeModel, int, QQueryOperations>
      parentNodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentNodeId');
    });
  }
}
