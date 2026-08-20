// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fernie_region_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFernieRegionModelCollection on Isar {
  IsarCollection<FernieRegionModel> get fernieRegionModels => this.collection();
}

const FernieRegionModelSchema = CollectionSchema(
  name: r'FernieRegions',
  id: -356528545423995810,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'frameMs': PropertySchema(
      id: 1,
      name: r'frameMs',
      type: IsarType.long,
    ),
    r'h': PropertySchema(
      id: 2,
      name: r'h',
      type: IsarType.double,
    ),
    r'mediaId': PropertySchema(
      id: 3,
      name: r'mediaId',
      type: IsarType.long,
    ),
    r'w': PropertySchema(
      id: 4,
      name: r'w',
      type: IsarType.double,
    ),
    r'x': PropertySchema(
      id: 5,
      name: r'x',
      type: IsarType.double,
    ),
    r'y': PropertySchema(
      id: 6,
      name: r'y',
      type: IsarType.double,
    )
  },
  estimateSize: _fernieRegionModelEstimateSize,
  serialize: _fernieRegionModelSerialize,
  deserialize: _fernieRegionModelDeserialize,
  deserializeProp: _fernieRegionModelDeserializeProp,
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
    )
  },
  links: {
    r'fernie': LinkSchema(
      id: -863077951559117883,
      name: r'fernie',
      target: r'Fernies',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _fernieRegionModelGetId,
  getLinks: _fernieRegionModelGetLinks,
  attach: _fernieRegionModelAttach,
  version: '3.1.0+1',
);

int _fernieRegionModelEstimateSize(
  FernieRegionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _fernieRegionModelSerialize(
  FernieRegionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.frameMs);
  writer.writeDouble(offsets[2], object.h);
  writer.writeLong(offsets[3], object.mediaId);
  writer.writeDouble(offsets[4], object.w);
  writer.writeDouble(offsets[5], object.x);
  writer.writeDouble(offsets[6], object.y);
}

FernieRegionModel _fernieRegionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FernieRegionModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.frameMs = reader.readLongOrNull(offsets[1]);
  object.h = reader.readDouble(offsets[2]);
  object.id = id;
  object.mediaId = reader.readLong(offsets[3]);
  object.w = reader.readDouble(offsets[4]);
  object.x = reader.readDouble(offsets[5]);
  object.y = reader.readDouble(offsets[6]);
  return object;
}

P _fernieRegionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fernieRegionModelGetId(FernieRegionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fernieRegionModelGetLinks(
    FernieRegionModel object) {
  return [object.fernie];
}

void _fernieRegionModelAttach(
    IsarCollection<dynamic> col, Id id, FernieRegionModel object) {
  object.id = id;
  object.fernie.attach(col, col.isar.collection<FernieModel>(), r'fernie', id);
}

extension FernieRegionModelQueryWhereSort
    on QueryBuilder<FernieRegionModel, FernieRegionModel, QWhere> {
  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhere> anyMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'mediaId'),
      );
    });
  }
}

extension FernieRegionModelQueryWhere
    on QueryBuilder<FernieRegionModel, FernieRegionModel, QWhereClause> {
  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
      mediaIdEqualTo(int mediaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mediaId',
        value: [mediaId],
      ));
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
      mediaIdNotEqualTo(int mediaId) {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
      mediaIdGreaterThan(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
      mediaIdLessThan(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterWhereClause>
      mediaIdBetween(
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
}

extension FernieRegionModelQueryFilter
    on QueryBuilder<FernieRegionModel, FernieRegionModel, QFilterCondition> {
  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      frameMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'frameMs',
      ));
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      frameMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'frameMs',
      ));
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      frameMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frameMs',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      frameMsGreaterThan(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      frameMsLessThan(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      frameMsBetween(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      hEqualTo(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      hGreaterThan(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      hLessThan(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      hBetween(
    double lower,
    double upper, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      mediaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaId',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      mediaIdGreaterThan(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      mediaIdLessThan(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      mediaIdBetween(
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      wEqualTo(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      wGreaterThan(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      wLessThan(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      wBetween(
    double lower,
    double upper, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      xEqualTo(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      xGreaterThan(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      xLessThan(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      xBetween(
    double lower,
    double upper, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      yEqualTo(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      yGreaterThan(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      yLessThan(
    double value, {
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

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      yBetween(
    double lower,
    double upper, {
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

extension FernieRegionModelQueryObject
    on QueryBuilder<FernieRegionModel, FernieRegionModel, QFilterCondition> {}

extension FernieRegionModelQueryLinks
    on QueryBuilder<FernieRegionModel, FernieRegionModel, QFilterCondition> {
  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      fernie(FilterQuery<FernieModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'fernie');
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterFilterCondition>
      fernieIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fernie', 0, true, 0, true);
    });
  }
}

extension FernieRegionModelQuerySortBy
    on QueryBuilder<FernieRegionModel, FernieRegionModel, QSortBy> {
  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByFrameMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameMs', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByFrameMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameMs', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy> sortByH() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'h', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByHDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'h', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy> sortByW() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'w', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByWDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'w', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy> sortByX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy> sortByY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'y', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      sortByYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'y', Sort.desc);
    });
  }
}

extension FernieRegionModelQuerySortThenBy
    on QueryBuilder<FernieRegionModel, FernieRegionModel, QSortThenBy> {
  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByFrameMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameMs', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByFrameMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frameMs', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy> thenByH() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'h', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByHDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'h', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy> thenByW() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'w', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByWDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'w', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy> thenByX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x', Sort.desc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy> thenByY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'y', Sort.asc);
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QAfterSortBy>
      thenByYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'y', Sort.desc);
    });
  }
}

extension FernieRegionModelQueryWhereDistinct
    on QueryBuilder<FernieRegionModel, FernieRegionModel, QDistinct> {
  QueryBuilder<FernieRegionModel, FernieRegionModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QDistinct>
      distinctByFrameMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frameMs');
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QDistinct> distinctByH() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'h');
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QDistinct>
      distinctByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaId');
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QDistinct> distinctByW() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'w');
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QDistinct> distinctByX() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'x');
    });
  }

  QueryBuilder<FernieRegionModel, FernieRegionModel, QDistinct> distinctByY() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'y');
    });
  }
}

extension FernieRegionModelQueryProperty
    on QueryBuilder<FernieRegionModel, FernieRegionModel, QQueryProperty> {
  QueryBuilder<FernieRegionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FernieRegionModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FernieRegionModel, int?, QQueryOperations> frameMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frameMs');
    });
  }

  QueryBuilder<FernieRegionModel, double, QQueryOperations> hProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'h');
    });
  }

  QueryBuilder<FernieRegionModel, int, QQueryOperations> mediaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaId');
    });
  }

  QueryBuilder<FernieRegionModel, double, QQueryOperations> wProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'w');
    });
  }

  QueryBuilder<FernieRegionModel, double, QQueryOperations> xProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'x');
    });
  }

  QueryBuilder<FernieRegionModel, double, QQueryOperations> yProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'y');
    });
  }
}
