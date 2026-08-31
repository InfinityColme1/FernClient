// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_tag_log_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMediaTagLogModelCollection on Isar {
  IsarCollection<MediaTagLogModel> get mediaTagLogModels => this.collection();
}

const MediaTagLogModelSchema = CollectionSchema(
  name: r'MediaTagLogs',
  id: 2794511107446976599,
  properties: {
    r'at': PropertySchema(
      id: 0,
      name: r'at',
      type: IsarType.dateTime,
    ),
    r'creatorId': PropertySchema(
      id: 1,
      name: r'creatorId',
      type: IsarType.long,
    ),
    r'detail': PropertySchema(
      id: 2,
      name: r'detail',
      type: IsarType.string,
    ),
    r'label': PropertySchema(
      id: 3,
      name: r'label',
      type: IsarType.string,
    ),
    r'mediaId': PropertySchema(
      id: 4,
      name: r'mediaId',
      type: IsarType.long,
    ),
    r'reason': PropertySchema(
      id: 5,
      name: r'reason',
      type: IsarType.string,
      enumMap: _MediaTagLogModelreasonEnumValueMap,
    ),
    r'tagId': PropertySchema(
      id: 6,
      name: r'tagId',
      type: IsarType.long,
    )
  },
  estimateSize: _mediaTagLogModelEstimateSize,
  serialize: _mediaTagLogModelSerialize,
  deserialize: _mediaTagLogModelDeserialize,
  deserializeProp: _mediaTagLogModelDeserializeProp,
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
  links: {},
  embeddedSchemas: {},
  getId: _mediaTagLogModelGetId,
  getLinks: _mediaTagLogModelGetLinks,
  attach: _mediaTagLogModelAttach,
  version: '3.1.0+1',
);

int _mediaTagLogModelEstimateSize(
  MediaTagLogModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.detail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 + object.reason.name.length * 3;
  return bytesCount;
}

void _mediaTagLogModelSerialize(
  MediaTagLogModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.at);
  writer.writeLong(offsets[1], object.creatorId);
  writer.writeString(offsets[2], object.detail);
  writer.writeString(offsets[3], object.label);
  writer.writeLong(offsets[4], object.mediaId);
  writer.writeString(offsets[5], object.reason.name);
  writer.writeLong(offsets[6], object.tagId);
}

MediaTagLogModel _mediaTagLogModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MediaTagLogModel();
  object.at = reader.readDateTime(offsets[0]);
  object.creatorId = reader.readLongOrNull(offsets[1]);
  object.detail = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.label = reader.readString(offsets[3]);
  object.mediaId = reader.readLong(offsets[4]);
  object.reason = _MediaTagLogModelreasonValueEnumMap[
          reader.readStringOrNull(offsets[5])] ??
      TagLogReason.manual;
  object.tagId = reader.readLongOrNull(offsets[6]);
  return object;
}

P _mediaTagLogModelDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (_MediaTagLogModelreasonValueEnumMap[
              reader.readStringOrNull(offset)] ??
          TagLogReason.manual) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MediaTagLogModelreasonEnumValueMap = {
  r'manual': r'manual',
  r'sourceUrl': r'sourceUrl',
  r'platform': r'platform',
  r'ancestor': r'ancestor',
  r'sibling': r'sibling',
  r'recognition': r'recognition',
  r'fernie': r'fernie',
};
const _MediaTagLogModelreasonValueEnumMap = {
  r'manual': TagLogReason.manual,
  r'sourceUrl': TagLogReason.sourceUrl,
  r'platform': TagLogReason.platform,
  r'ancestor': TagLogReason.ancestor,
  r'sibling': TagLogReason.sibling,
  r'recognition': TagLogReason.recognition,
  r'fernie': TagLogReason.fernie,
};

Id _mediaTagLogModelGetId(MediaTagLogModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mediaTagLogModelGetLinks(MediaTagLogModel object) {
  return [];
}

void _mediaTagLogModelAttach(
    IsarCollection<dynamic> col, Id id, MediaTagLogModel object) {
  object.id = id;
}

extension MediaTagLogModelQueryWhereSort
    on QueryBuilder<MediaTagLogModel, MediaTagLogModel, QWhere> {
  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhere> anyMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'mediaId'),
      );
    });
  }
}

extension MediaTagLogModelQueryWhere
    on QueryBuilder<MediaTagLogModel, MediaTagLogModel, QWhereClause> {
  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause>
      mediaIdEqualTo(int mediaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mediaId',
        value: [mediaId],
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterWhereClause>
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

extension MediaTagLogModelQueryFilter
    on QueryBuilder<MediaTagLogModel, MediaTagLogModel, QFilterCondition> {
  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      atEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'at',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      atGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'at',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      atLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'at',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      atBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'at',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      creatorIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'creatorId',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      creatorIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'creatorId',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      creatorIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      creatorIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creatorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      creatorIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creatorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      creatorIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creatorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'detail',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'detail',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'detail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'detail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detail',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      detailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'detail',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      mediaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
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

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonEqualTo(
    TagLogReason value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonGreaterThan(
    TagLogReason value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonLessThan(
    TagLogReason value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonBetween(
    TagLogReason lower,
    TagLogReason upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      tagIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tagId',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      tagIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tagId',
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      tagIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      tagIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      tagIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagId',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterFilterCondition>
      tagIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MediaTagLogModelQueryObject
    on QueryBuilder<MediaTagLogModel, MediaTagLogModel, QFilterCondition> {}

extension MediaTagLogModelQueryLinks
    on QueryBuilder<MediaTagLogModel, MediaTagLogModel, QFilterCondition> {}

extension MediaTagLogModelQuerySortBy
    on QueryBuilder<MediaTagLogModel, MediaTagLogModel, QSortBy> {
  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy> sortByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByCreatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorId', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByCreatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorId', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detail', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detail', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy> sortByTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      sortByTagIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.desc);
    });
  }
}

extension MediaTagLogModelQuerySortThenBy
    on QueryBuilder<MediaTagLogModel, MediaTagLogModel, QSortThenBy> {
  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy> thenByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'at', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByCreatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorId', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByCreatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorId', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detail', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detail', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy> thenByTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.asc);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QAfterSortBy>
      thenByTagIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagId', Sort.desc);
    });
  }
}

extension MediaTagLogModelQueryWhereDistinct
    on QueryBuilder<MediaTagLogModel, MediaTagLogModel, QDistinct> {
  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QDistinct> distinctByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'at');
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QDistinct>
      distinctByCreatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creatorId');
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QDistinct> distinctByDetail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QDistinct>
      distinctByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaId');
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QDistinct> distinctByReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaTagLogModel, MediaTagLogModel, QDistinct>
      distinctByTagId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagId');
    });
  }
}

extension MediaTagLogModelQueryProperty
    on QueryBuilder<MediaTagLogModel, MediaTagLogModel, QQueryProperty> {
  QueryBuilder<MediaTagLogModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MediaTagLogModel, DateTime, QQueryOperations> atProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'at');
    });
  }

  QueryBuilder<MediaTagLogModel, int?, QQueryOperations> creatorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creatorId');
    });
  }

  QueryBuilder<MediaTagLogModel, String?, QQueryOperations> detailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detail');
    });
  }

  QueryBuilder<MediaTagLogModel, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<MediaTagLogModel, int, QQueryOperations> mediaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaId');
    });
  }

  QueryBuilder<MediaTagLogModel, TagLogReason, QQueryOperations>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<MediaTagLogModel, int?, QQueryOperations> tagIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagId');
    });
  }
}
