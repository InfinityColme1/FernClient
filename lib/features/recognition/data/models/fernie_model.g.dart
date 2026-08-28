// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fernie_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFernieModelCollection on Isar {
  IsarCollection<FernieModel> get fernieModels => this.collection();
}

const FernieModelSchema = CollectionSchema(
  name: r'Fernies',
  id: -1766303986567492096,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'linkedCreatorId': PropertySchema(
      id: 1,
      name: r'linkedCreatorId',
      type: IsarType.long,
    ),
    r'linkedTagId': PropertySchema(
      id: 2,
      name: r'linkedTagId',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'picturePath': PropertySchema(
      id: 4,
      name: r'picturePath',
      type: IsarType.string,
    )
  },
  estimateSize: _fernieModelEstimateSize,
  serialize: _fernieModelSerialize,
  deserialize: _fernieModelDeserialize,
  deserializeProp: _fernieModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'regions': LinkSchema(
      id: -5585476709812927004,
      name: r'regions',
      target: r'FernieRegions',
      single: false,
      linkName: r'fernie',
    )
  },
  embeddedSchemas: {},
  getId: _fernieModelGetId,
  getLinks: _fernieModelGetLinks,
  attach: _fernieModelAttach,
  version: '3.1.0+1',
);

int _fernieModelEstimateSize(
  FernieModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.picturePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _fernieModelSerialize(
  FernieModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.linkedCreatorId);
  writer.writeLong(offsets[2], object.linkedTagId);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.picturePath);
}

FernieModel _fernieModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FernieModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.linkedCreatorId = reader.readLongOrNull(offsets[1]);
  object.linkedTagId = reader.readLongOrNull(offsets[2]);
  object.name = reader.readString(offsets[3]);
  object.picturePath = reader.readStringOrNull(offsets[4]);
  return object;
}

P _fernieModelDeserializeProp<P>(
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
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fernieModelGetId(FernieModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fernieModelGetLinks(FernieModel object) {
  return [object.regions];
}

void _fernieModelAttach(
    IsarCollection<dynamic> col, Id id, FernieModel object) {
  object.id = id;
  object.regions
      .attach(col, col.isar.collection<FernieRegionModel>(), r'regions', id);
}

extension FernieModelQueryWhereSort
    on QueryBuilder<FernieModel, FernieModel, QWhere> {
  QueryBuilder<FernieModel, FernieModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FernieModelQueryWhere
    on QueryBuilder<FernieModel, FernieModel, QWhereClause> {
  QueryBuilder<FernieModel, FernieModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<FernieModel, FernieModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterWhereClause> idBetween(
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

extension FernieModelQueryFilter
    on QueryBuilder<FernieModel, FernieModel, QFilterCondition> {
  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedCreatorIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedCreatorId',
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedCreatorIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedCreatorId',
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedCreatorIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedCreatorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedCreatorIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedCreatorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedCreatorIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedCreatorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedCreatorIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedCreatorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedTagIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedTagId',
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedTagIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedTagId',
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedTagIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedTagId',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedTagIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedTagId',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedTagIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedTagId',
        value: value,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      linkedTagIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedTagId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'picturePath',
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'picturePath',
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathEqualTo(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathGreaterThan(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathLessThan(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathBetween(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathStartsWith(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathEndsWith(
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

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'picturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'picturePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'picturePath',
        value: '',
      ));
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      picturePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'picturePath',
        value: '',
      ));
    });
  }
}

extension FernieModelQueryObject
    on QueryBuilder<FernieModel, FernieModel, QFilterCondition> {}

extension FernieModelQueryLinks
    on QueryBuilder<FernieModel, FernieModel, QFilterCondition> {
  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition> regions(
      FilterQuery<FernieRegionModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'regions');
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      regionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'regions', length, true, length, true);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      regionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'regions', 0, true, 0, true);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      regionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'regions', 0, false, 999999, true);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      regionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'regions', 0, true, length, include);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      regionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'regions', length, include, 999999, true);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterFilterCondition>
      regionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'regions', lower, includeLower, upper, includeUpper);
    });
  }
}

extension FernieModelQuerySortBy
    on QueryBuilder<FernieModel, FernieModel, QSortBy> {
  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> sortByLinkedCreatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedCreatorId', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy>
      sortByLinkedCreatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedCreatorId', Sort.desc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> sortByLinkedTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTagId', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> sortByLinkedTagIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTagId', Sort.desc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> sortByPicturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> sortByPicturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.desc);
    });
  }
}

extension FernieModelQuerySortThenBy
    on QueryBuilder<FernieModel, FernieModel, QSortThenBy> {
  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByLinkedCreatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedCreatorId', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy>
      thenByLinkedCreatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedCreatorId', Sort.desc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByLinkedTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTagId', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByLinkedTagIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTagId', Sort.desc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByPicturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.asc);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QAfterSortBy> thenByPicturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.desc);
    });
  }
}

extension FernieModelQueryWhereDistinct
    on QueryBuilder<FernieModel, FernieModel, QDistinct> {
  QueryBuilder<FernieModel, FernieModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FernieModel, FernieModel, QDistinct>
      distinctByLinkedCreatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedCreatorId');
    });
  }

  QueryBuilder<FernieModel, FernieModel, QDistinct> distinctByLinkedTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedTagId');
    });
  }

  QueryBuilder<FernieModel, FernieModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FernieModel, FernieModel, QDistinct> distinctByPicturePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'picturePath', caseSensitive: caseSensitive);
    });
  }
}

extension FernieModelQueryProperty
    on QueryBuilder<FernieModel, FernieModel, QQueryProperty> {
  QueryBuilder<FernieModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FernieModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FernieModel, int?, QQueryOperations> linkedCreatorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedCreatorId');
    });
  }

  QueryBuilder<FernieModel, int?, QQueryOperations> linkedTagIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedTagId');
    });
  }

  QueryBuilder<FernieModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<FernieModel, String?, QQueryOperations> picturePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'picturePath');
    });
  }
}
