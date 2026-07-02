// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_summary_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMediaSummaryModelCollection on Isar {
  IsarCollection<MediaSummaryModel> get mediaSummaryModels => this.collection();
}

const MediaSummaryModelSchema = CollectionSchema(
  name: r'MediaSummaries',
  id: 7435934146651842754,
  properties: {
    r'path': PropertySchema(
      id: 0,
      name: r'path',
      type: IsarType.string,
    )
  },
  estimateSize: _mediaSummaryModelEstimateSize,
  serialize: _mediaSummaryModelSerialize,
  deserialize: _mediaSummaryModelDeserialize,
  deserializeProp: _mediaSummaryModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'details': LinkSchema(
      id: 8075308143167905518,
      name: r'details',
      target: r'Media',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _mediaSummaryModelGetId,
  getLinks: _mediaSummaryModelGetLinks,
  attach: _mediaSummaryModelAttach,
  version: '3.1.0+1',
);

int _mediaSummaryModelEstimateSize(
  MediaSummaryModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.path.length * 3;
  return bytesCount;
}

void _mediaSummaryModelSerialize(
  MediaSummaryModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.path);
}

MediaSummaryModel _mediaSummaryModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MediaSummaryModel();
  object.id = id;
  object.path = reader.readString(offsets[0]);
  return object;
}

P _mediaSummaryModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mediaSummaryModelGetId(MediaSummaryModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mediaSummaryModelGetLinks(
    MediaSummaryModel object) {
  return [object.details];
}

void _mediaSummaryModelAttach(
    IsarCollection<dynamic> col, Id id, MediaSummaryModel object) {
  object.id = id;
  object.details.attach(col, col.isar.collection<MediaModel>(), r'details', id);
}

extension MediaSummaryModelQueryWhereSort
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QWhere> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MediaSummaryModelQueryWhere
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QWhereClause> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
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

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
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

extension MediaSummaryModelQueryFilter
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QFilterCondition> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
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

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
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

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
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

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'path',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }
}

extension MediaSummaryModelQueryObject
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QFilterCondition> {}

extension MediaSummaryModelQueryLinks
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QFilterCondition> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      details(FilterQuery<MediaModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'details');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      detailsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'details', 0, true, 0, true);
    });
  }
}

extension MediaSummaryModelQuerySortBy
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QSortBy> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }
}

extension MediaSummaryModelQuerySortThenBy
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QSortThenBy> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }
}

extension MediaSummaryModelQueryWhereDistinct
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }
}

extension MediaSummaryModelQueryProperty
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QQueryProperty> {
  QueryBuilder<MediaSummaryModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MediaSummaryModel, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }
}
