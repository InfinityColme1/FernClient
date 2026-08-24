// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duplicate_group_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDuplicateGroupModelCollection on Isar {
  IsarCollection<DuplicateGroupModel> get duplicateGroupModels =>
      this.collection();
}

const DuplicateGroupModelSchema = CollectionSchema(
  name: r'DuplicateGroups',
  id: -3546694383201439419,
  properties: {
    r'foundAt': PropertySchema(
      id: 0,
      name: r'foundAt',
      type: IsarType.dateTime,
    ),
    r'isDismissed': PropertySchema(
      id: 1,
      name: r'isDismissed',
      type: IsarType.bool,
    ),
    r'isResolved': PropertySchema(
      id: 2,
      name: r'isResolved',
      type: IsarType.bool,
    ),
    r'maxDistance': PropertySchema(
      id: 3,
      name: r'maxDistance',
      type: IsarType.long,
    ),
    r'mediaIds': PropertySchema(
      id: 4,
      name: r'mediaIds',
      type: IsarType.longList,
    ),
    r'signature': PropertySchema(
      id: 5,
      name: r'signature',
      type: IsarType.string,
    )
  },
  estimateSize: _duplicateGroupModelEstimateSize,
  serialize: _duplicateGroupModelSerialize,
  deserialize: _duplicateGroupModelDeserialize,
  deserializeProp: _duplicateGroupModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'signature': IndexSchema(
      id: 4701578645143940109,
      name: r'signature',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'signature',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _duplicateGroupModelGetId,
  getLinks: _duplicateGroupModelGetLinks,
  attach: _duplicateGroupModelAttach,
  version: '3.1.0+1',
);

int _duplicateGroupModelEstimateSize(
  DuplicateGroupModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mediaIds.length * 8;
  bytesCount += 3 + object.signature.length * 3;
  return bytesCount;
}

void _duplicateGroupModelSerialize(
  DuplicateGroupModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.foundAt);
  writer.writeBool(offsets[1], object.isDismissed);
  writer.writeBool(offsets[2], object.isResolved);
  writer.writeLong(offsets[3], object.maxDistance);
  writer.writeLongList(offsets[4], object.mediaIds);
  writer.writeString(offsets[5], object.signature);
}

DuplicateGroupModel _duplicateGroupModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DuplicateGroupModel();
  object.foundAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.isDismissed = reader.readBool(offsets[1]);
  object.isResolved = reader.readBool(offsets[2]);
  object.maxDistance = reader.readLong(offsets[3]);
  object.mediaIds = reader.readLongList(offsets[4]) ?? [];
  object.signature = reader.readString(offsets[5]);
  return object;
}

P _duplicateGroupModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLongList(offset) ?? []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _duplicateGroupModelGetId(DuplicateGroupModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _duplicateGroupModelGetLinks(
    DuplicateGroupModel object) {
  return [];
}

void _duplicateGroupModelAttach(
    IsarCollection<dynamic> col, Id id, DuplicateGroupModel object) {
  object.id = id;
}

extension DuplicateGroupModelQueryWhereSort
    on QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QWhere> {
  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DuplicateGroupModelQueryWhere
    on QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QWhereClause> {
  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterWhereClause>
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

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterWhereClause>
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

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterWhereClause>
      signatureEqualTo(String signature) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'signature',
        value: [signature],
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterWhereClause>
      signatureNotEqualTo(String signature) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'signature',
              lower: [],
              upper: [signature],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'signature',
              lower: [signature],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'signature',
              lower: [signature],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'signature',
              lower: [],
              upper: [signature],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DuplicateGroupModelQueryFilter on QueryBuilder<DuplicateGroupModel,
    DuplicateGroupModel, QFilterCondition> {
  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      foundAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foundAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      foundAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foundAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      foundAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foundAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      foundAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foundAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
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

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
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

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
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

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      isDismissedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDismissed',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      isResolvedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isResolved',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      maxDistanceEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxDistance',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      maxDistanceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxDistance',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      maxDistanceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxDistance',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      maxDistanceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxDistance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaIds',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaIds',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaIds',
        value: value,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      mediaIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterFilterCondition>
      signatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signature',
        value: '',
      ));
    });
  }
}

extension DuplicateGroupModelQueryObject on QueryBuilder<DuplicateGroupModel,
    DuplicateGroupModel, QFilterCondition> {}

extension DuplicateGroupModelQueryLinks on QueryBuilder<DuplicateGroupModel,
    DuplicateGroupModel, QFilterCondition> {}

extension DuplicateGroupModelQuerySortBy
    on QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QSortBy> {
  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortByFoundAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foundAt', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortByFoundAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foundAt', Sort.desc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortByIsDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDismissed', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortByIsDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDismissed', Sort.desc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortByMaxDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDistance', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortByMaxDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDistance', Sort.desc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      sortBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }
}

extension DuplicateGroupModelQuerySortThenBy
    on QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QSortThenBy> {
  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenByFoundAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foundAt', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenByFoundAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foundAt', Sort.desc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenByIsDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDismissed', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenByIsDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDismissed', Sort.desc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenByMaxDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDistance', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenByMaxDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxDistance', Sort.desc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QAfterSortBy>
      thenBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }
}

extension DuplicateGroupModelQueryWhereDistinct
    on QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QDistinct> {
  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QDistinct>
      distinctByFoundAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foundAt');
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QDistinct>
      distinctByIsDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDismissed');
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QDistinct>
      distinctByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isResolved');
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QDistinct>
      distinctByMaxDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxDistance');
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QDistinct>
      distinctByMediaIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaIds');
    });
  }

  QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QDistinct>
      distinctBySignature({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signature', caseSensitive: caseSensitive);
    });
  }
}

extension DuplicateGroupModelQueryProperty
    on QueryBuilder<DuplicateGroupModel, DuplicateGroupModel, QQueryProperty> {
  QueryBuilder<DuplicateGroupModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DuplicateGroupModel, DateTime, QQueryOperations>
      foundAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foundAt');
    });
  }

  QueryBuilder<DuplicateGroupModel, bool, QQueryOperations>
      isDismissedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDismissed');
    });
  }

  QueryBuilder<DuplicateGroupModel, bool, QQueryOperations>
      isResolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isResolved');
    });
  }

  QueryBuilder<DuplicateGroupModel, int, QQueryOperations>
      maxDistanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxDistance');
    });
  }

  QueryBuilder<DuplicateGroupModel, List<int>, QQueryOperations>
      mediaIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaIds');
    });
  }

  QueryBuilder<DuplicateGroupModel, String, QQueryOperations>
      signatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signature');
    });
  }
}
