// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTagModelCollection on Isar {
  IsarCollection<TagModel> get tagModels => this.collection();
}

const TagModelSchema = CollectionSchema(
  name: r'Tags',
  id: -8090000258435900783,
  properties: {
    r'name': PropertySchema(
      id: 0,
      name: r'name',
      type: IsarType.string,
    ),
    r'picturePath': PropertySchema(
      id: 1,
      name: r'picturePath',
      type: IsarType.string,
    )
  },
  estimateSize: _tagModelEstimateSize,
  serialize: _tagModelSerialize,
  deserialize: _tagModelDeserialize,
  deserializeProp: _tagModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'children': LinkSchema(
      id: 8686594794335574746,
      name: r'children',
      target: r'Tags',
      single: false,
    ),
    r'personas': LinkSchema(
      id: -1060093785552034191,
      name: r'personas',
      target: r'Personas',
      single: false,
      linkName: r'tags',
    ),
    r'media': LinkSchema(
      id: -1344520078378820521,
      name: r'media',
      target: r'Media',
      single: false,
      linkName: r'tags',
    )
  },
  embeddedSchemas: {},
  getId: _tagModelGetId,
  getLinks: _tagModelGetLinks,
  attach: _tagModelAttach,
  version: '3.1.0+1',
);

int _tagModelEstimateSize(
  TagModel object,
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

void _tagModelSerialize(
  TagModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
  writer.writeString(offsets[1], object.picturePath);
}

TagModel _tagModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TagModel();
  object.id = id;
  object.name = reader.readString(offsets[0]);
  object.picturePath = reader.readStringOrNull(offsets[1]);
  return object;
}

P _tagModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tagModelGetId(TagModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tagModelGetLinks(TagModel object) {
  return [object.children, object.personas, object.media];
}

void _tagModelAttach(IsarCollection<dynamic> col, Id id, TagModel object) {
  object.id = id;
  object.children.attach(col, col.isar.collection<TagModel>(), r'children', id);
  object.personas
      .attach(col, col.isar.collection<PersonaModel>(), r'personas', id);
  object.media.attach(col, col.isar.collection<MediaModel>(), r'media', id);
}

extension TagModelQueryWhereSort on QueryBuilder<TagModel, TagModel, QWhere> {
  QueryBuilder<TagModel, TagModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TagModelQueryWhere on QueryBuilder<TagModel, TagModel, QWhereClause> {
  QueryBuilder<TagModel, TagModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<TagModel, TagModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterWhereClause> idBetween(
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

extension TagModelQueryFilter
    on QueryBuilder<TagModel, TagModel, QFilterCondition> {
  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameContains(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> picturePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'picturePath',
      ));
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition>
      picturePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'picturePath',
      ));
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> picturePathEqualTo(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition>
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> picturePathLessThan(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> picturePathBetween(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> picturePathStartsWith(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> picturePathEndsWith(
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

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> picturePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'picturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> picturePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'picturePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> picturePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'picturePath',
        value: '',
      ));
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition>
      picturePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'picturePath',
        value: '',
      ));
    });
  }
}

extension TagModelQueryObject
    on QueryBuilder<TagModel, TagModel, QFilterCondition> {}

extension TagModelQueryLinks
    on QueryBuilder<TagModel, TagModel, QFilterCondition> {
  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> children(
      FilterQuery<TagModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'children');
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> childrenLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', length, true, length, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> childrenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', 0, true, 0, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> childrenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', 0, false, 999999, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition>
      childrenLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', 0, true, length, include);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition>
      childrenLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', length, include, 999999, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> childrenLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'children', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> personas(
      FilterQuery<PersonaModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'personas');
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> personasLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'personas', length, true, length, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> personasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'personas', 0, true, 0, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> personasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'personas', 0, false, 999999, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition>
      personasLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'personas', 0, true, length, include);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition>
      personasLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'personas', length, include, 999999, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> personasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'personas', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> media(
      FilterQuery<MediaModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'media');
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> mediaLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'media', length, true, length, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> mediaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'media', 0, true, 0, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> mediaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'media', 0, false, 999999, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> mediaLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'media', 0, true, length, include);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition>
      mediaLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'media', length, include, 999999, true);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterFilterCondition> mediaLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'media', lower, includeLower, upper, includeUpper);
    });
  }
}

extension TagModelQuerySortBy on QueryBuilder<TagModel, TagModel, QSortBy> {
  QueryBuilder<TagModel, TagModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterSortBy> sortByPicturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.asc);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterSortBy> sortByPicturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.desc);
    });
  }
}

extension TagModelQuerySortThenBy
    on QueryBuilder<TagModel, TagModel, QSortThenBy> {
  QueryBuilder<TagModel, TagModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterSortBy> thenByPicturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.asc);
    });
  }

  QueryBuilder<TagModel, TagModel, QAfterSortBy> thenByPicturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.desc);
    });
  }
}

extension TagModelQueryWhereDistinct
    on QueryBuilder<TagModel, TagModel, QDistinct> {
  QueryBuilder<TagModel, TagModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TagModel, TagModel, QDistinct> distinctByPicturePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'picturePath', caseSensitive: caseSensitive);
    });
  }
}

extension TagModelQueryProperty
    on QueryBuilder<TagModel, TagModel, QQueryProperty> {
  QueryBuilder<TagModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TagModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<TagModel, String?, QQueryOperations> picturePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'picturePath');
    });
  }
}
