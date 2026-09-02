// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCreatorModelCollection on Isar {
  IsarCollection<CreatorModel> get creatorModels => this.collection();
}

const CreatorModelSchema = CollectionSchema(
  name: r'Creators',
  id: -6964830080466276249,
  properties: {
    r'isNsfw': PropertySchema(
      id: 0,
      name: r'isNsfw',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'nsfwSocialProfiles': PropertySchema(
      id: 2,
      name: r'nsfwSocialProfiles',
      type: IsarType.stringList,
    ),
    r'nsfwSourceUrls': PropertySchema(
      id: 3,
      name: r'nsfwSourceUrls',
      type: IsarType.stringList,
    ),
    r'picturePath': PropertySchema(
      id: 4,
      name: r'picturePath',
      type: IsarType.string,
    ),
    r'socialProfiles': PropertySchema(
      id: 5,
      name: r'socialProfiles',
      type: IsarType.stringList,
    ),
    r'sourceUrls': PropertySchema(
      id: 6,
      name: r'sourceUrls',
      type: IsarType.stringList,
    )
  },
  estimateSize: _creatorModelEstimateSize,
  serialize: _creatorModelSerialize,
  deserialize: _creatorModelDeserialize,
  deserializeProp: _creatorModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'tags': LinkSchema(
      id: -7646058287218928682,
      name: r'tags',
      target: r'Tags',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _creatorModelGetId,
  getLinks: _creatorModelGetLinks,
  attach: _creatorModelAttach,
  version: '3.1.0+1',
);

int _creatorModelEstimateSize(
  CreatorModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.nsfwSocialProfiles.length * 3;
  {
    for (var i = 0; i < object.nsfwSocialProfiles.length; i++) {
      final value = object.nsfwSocialProfiles[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.nsfwSourceUrls.length * 3;
  {
    for (var i = 0; i < object.nsfwSourceUrls.length; i++) {
      final value = object.nsfwSourceUrls[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.picturePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.socialProfiles;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.sourceUrls.length * 3;
  {
    for (var i = 0; i < object.sourceUrls.length; i++) {
      final value = object.sourceUrls[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _creatorModelSerialize(
  CreatorModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isNsfw);
  writer.writeString(offsets[1], object.name);
  writer.writeStringList(offsets[2], object.nsfwSocialProfiles);
  writer.writeStringList(offsets[3], object.nsfwSourceUrls);
  writer.writeString(offsets[4], object.picturePath);
  writer.writeStringList(offsets[5], object.socialProfiles);
  writer.writeStringList(offsets[6], object.sourceUrls);
}

CreatorModel _creatorModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CreatorModel(
    id: id,
    isNsfw: reader.readBoolOrNull(offsets[0]) ?? false,
    name: reader.readString(offsets[1]),
    nsfwSocialProfiles: reader.readStringList(offsets[2]) ?? const [],
    nsfwSourceUrls: reader.readStringList(offsets[3]) ?? const [],
    picturePath: reader.readStringOrNull(offsets[4]),
    socialProfiles: reader.readStringList(offsets[5]),
    sourceUrls: reader.readStringList(offsets[6]) ?? const [],
  );
  return object;
}

P _creatorModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? const []) as P;
    case 3:
      return (reader.readStringList(offset) ?? const []) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? const []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _creatorModelGetId(CreatorModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _creatorModelGetLinks(CreatorModel object) {
  return [object.tags];
}

void _creatorModelAttach(
    IsarCollection<dynamic> col, Id id, CreatorModel object) {
  object.id = id;
  object.tags.attach(col, col.isar.collection<TagModel>(), r'tags', id);
}

extension CreatorModelQueryWhereSort
    on QueryBuilder<CreatorModel, CreatorModel, QWhere> {
  QueryBuilder<CreatorModel, CreatorModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CreatorModelQueryWhere
    on QueryBuilder<CreatorModel, CreatorModel, QWhereClause> {
  QueryBuilder<CreatorModel, CreatorModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterWhereClause> idBetween(
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

extension CreatorModelQueryFilter
    on QueryBuilder<CreatorModel, CreatorModel, QFilterCondition> {
  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> isNsfwEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNsfw',
        value: value,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nameStartsWith(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> nameContains(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nsfwSocialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nsfwSocialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nsfwSocialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nsfwSocialProfiles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nsfwSocialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nsfwSocialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nsfwSocialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nsfwSocialProfiles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nsfwSocialProfiles',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nsfwSocialProfiles',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSocialProfiles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSocialProfiles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSocialProfiles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSocialProfiles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSocialProfiles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSocialProfilesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSocialProfiles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nsfwSourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nsfwSourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nsfwSourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nsfwSourceUrls',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nsfwSourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nsfwSourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nsfwSourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nsfwSourceUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nsfwSourceUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nsfwSourceUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSourceUrls',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSourceUrls',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSourceUrls',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSourceUrls',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSourceUrls',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      nsfwSourceUrlsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nsfwSourceUrls',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      picturePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'picturePath',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      picturePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'picturePath',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
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

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      picturePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'picturePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      picturePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'picturePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      picturePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'picturePath',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      picturePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'picturePath',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'socialProfiles',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'socialProfiles',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'socialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'socialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'socialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'socialProfiles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'socialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'socialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'socialProfiles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'socialProfiles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'socialProfiles',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'socialProfiles',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'socialProfiles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'socialProfiles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'socialProfiles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'socialProfiles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'socialProfiles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      socialProfilesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'socialProfiles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceUrls',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sourceUrls',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sourceUrls',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sourceUrls',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sourceUrls',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sourceUrls',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      sourceUrlsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sourceUrls',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension CreatorModelQueryObject
    on QueryBuilder<CreatorModel, CreatorModel, QFilterCondition> {}

extension CreatorModelQueryLinks
    on QueryBuilder<CreatorModel, CreatorModel, QFilterCondition> {
  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition> tags(
      FilterQuery<TagModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'tags');
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'tags', lower, includeLower, upper, includeUpper);
    });
  }
}

extension CreatorModelQuerySortBy
    on QueryBuilder<CreatorModel, CreatorModel, QSortBy> {
  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> sortByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.asc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> sortByIsNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.desc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> sortByPicturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.asc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy>
      sortByPicturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.desc);
    });
  }
}

extension CreatorModelQuerySortThenBy
    on QueryBuilder<CreatorModel, CreatorModel, QSortThenBy> {
  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> thenByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.asc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> thenByIsNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.desc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy> thenByPicturePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.asc);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QAfterSortBy>
      thenByPicturePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'picturePath', Sort.desc);
    });
  }
}

extension CreatorModelQueryWhereDistinct
    on QueryBuilder<CreatorModel, CreatorModel, QDistinct> {
  QueryBuilder<CreatorModel, CreatorModel, QDistinct> distinctByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNsfw');
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QDistinct>
      distinctByNsfwSocialProfiles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nsfwSocialProfiles');
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QDistinct>
      distinctByNsfwSourceUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nsfwSourceUrls');
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QDistinct> distinctByPicturePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'picturePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QDistinct>
      distinctBySocialProfiles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'socialProfiles');
    });
  }

  QueryBuilder<CreatorModel, CreatorModel, QDistinct> distinctBySourceUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceUrls');
    });
  }
}

extension CreatorModelQueryProperty
    on QueryBuilder<CreatorModel, CreatorModel, QQueryProperty> {
  QueryBuilder<CreatorModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CreatorModel, bool, QQueryOperations> isNsfwProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNsfw');
    });
  }

  QueryBuilder<CreatorModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<CreatorModel, List<String>, QQueryOperations>
      nsfwSocialProfilesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nsfwSocialProfiles');
    });
  }

  QueryBuilder<CreatorModel, List<String>, QQueryOperations>
      nsfwSourceUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nsfwSourceUrls');
    });
  }

  QueryBuilder<CreatorModel, String?, QQueryOperations> picturePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'picturePath');
    });
  }

  QueryBuilder<CreatorModel, List<String>?, QQueryOperations>
      socialProfilesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'socialProfiles');
    });
  }

  QueryBuilder<CreatorModel, List<String>, QQueryOperations>
      sourceUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceUrls');
    });
  }
}
