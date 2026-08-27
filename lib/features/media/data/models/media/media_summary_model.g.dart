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
    r'dctHash': PropertySchema(
      id: 0,
      name: r'dctHash',
      type: IsarType.long,
    ),
    r'deletedAt': PropertySchema(
      id: 1,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'hasPendingSuggestions': PropertySchema(
      id: 2,
      name: r'hasPendingSuggestions',
      type: IsarType.bool,
    ),
    r'hashedAt': PropertySchema(
      id: 3,
      name: r'hashedAt',
      type: IsarType.dateTime,
    ),
    r'importSource': PropertySchema(
      id: 4,
      name: r'importSource',
      type: IsarType.string,
    ),
    r'isDeleted': PropertySchema(
      id: 5,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'isImported': PropertySchema(
      id: 6,
      name: r'isImported',
      type: IsarType.bool,
    ),
    r'isNsfw': PropertySchema(
      id: 7,
      name: r'isNsfw',
      type: IsarType.bool,
    ),
    r'mediaHeight': PropertySchema(
      id: 8,
      name: r'mediaHeight',
      type: IsarType.long,
    ),
    r'mediaWidth': PropertySchema(
      id: 9,
      name: r'mediaWidth',
      type: IsarType.long,
    ),
    r'path': PropertySchema(
      id: 10,
      name: r'path',
      type: IsarType.string,
    ),
    r'perceptualHash': PropertySchema(
      id: 11,
      name: r'perceptualHash',
      type: IsarType.long,
    ),
    r'recognizedAt': PropertySchema(
      id: 12,
      name: r'recognizedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _mediaSummaryModelEstimateSize,
  serialize: _mediaSummaryModelSerialize,
  deserialize: _mediaSummaryModelDeserialize,
  deserializeProp: _mediaSummaryModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'path': IndexSchema(
      id: 8756705481922369689,
      name: r'path',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'importSource': IndexSchema(
      id: -7892523392039954412,
      name: r'importSource',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'importSource',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'hasPendingSuggestions': IndexSchema(
      id: -1682699791791004983,
      name: r'hasPendingSuggestions',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hasPendingSuggestions',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isNsfw': IndexSchema(
      id: 3014435295683206251,
      name: r'isNsfw',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isNsfw',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'perceptualHash': IndexSchema(
      id: 1103035415456931344,
      name: r'perceptualHash',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'perceptualHash',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
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
  bytesCount += 3 + object.importSource.length * 3;
  bytesCount += 3 + object.path.length * 3;
  return bytesCount;
}

void _mediaSummaryModelSerialize(
  MediaSummaryModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.dctHash);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeBool(offsets[2], object.hasPendingSuggestions);
  writer.writeDateTime(offsets[3], object.hashedAt);
  writer.writeString(offsets[4], object.importSource);
  writer.writeBool(offsets[5], object.isDeleted);
  writer.writeBool(offsets[6], object.isImported);
  writer.writeBool(offsets[7], object.isNsfw);
  writer.writeLong(offsets[8], object.mediaHeight);
  writer.writeLong(offsets[9], object.mediaWidth);
  writer.writeString(offsets[10], object.path);
  writer.writeLong(offsets[11], object.perceptualHash);
  writer.writeDateTime(offsets[12], object.recognizedAt);
}

MediaSummaryModel _mediaSummaryModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MediaSummaryModel();
  object.dctHash = reader.readLongOrNull(offsets[0]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[1]);
  object.hasPendingSuggestions = reader.readBool(offsets[2]);
  object.hashedAt = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.importSource = reader.readString(offsets[4]);
  object.isDeleted = reader.readBool(offsets[5]);
  object.isImported = reader.readBool(offsets[6]);
  object.isNsfw = reader.readBool(offsets[7]);
  object.mediaHeight = reader.readLongOrNull(offsets[8]);
  object.mediaWidth = reader.readLongOrNull(offsets[9]);
  object.path = reader.readString(offsets[10]);
  object.perceptualHash = reader.readLongOrNull(offsets[11]);
  object.recognizedAt = reader.readDateTimeOrNull(offsets[12]);
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
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
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

extension MediaSummaryModelByIndex on IsarCollection<MediaSummaryModel> {
  Future<MediaSummaryModel?> getByPath(String path) {
    return getByIndex(r'path', [path]);
  }

  MediaSummaryModel? getByPathSync(String path) {
    return getByIndexSync(r'path', [path]);
  }

  Future<bool> deleteByPath(String path) {
    return deleteByIndex(r'path', [path]);
  }

  bool deleteByPathSync(String path) {
    return deleteByIndexSync(r'path', [path]);
  }

  Future<List<MediaSummaryModel?>> getAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndex(r'path', values);
  }

  List<MediaSummaryModel?> getAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'path', values);
  }

  Future<int> deleteAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'path', values);
  }

  int deleteAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'path', values);
  }

  Future<Id> putByPath(MediaSummaryModel object) {
    return putByIndex(r'path', object);
  }

  Id putByPathSync(MediaSummaryModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'path', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPath(List<MediaSummaryModel> objects) {
    return putAllByIndex(r'path', objects);
  }

  List<Id> putAllByPathSync(List<MediaSummaryModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'path', objects, saveLinks: saveLinks);
  }
}

extension MediaSummaryModelQueryWhereSort
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QWhere> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhere>
      anyHasPendingSuggestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'hasPendingSuggestions'),
      );
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhere> anyIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isNsfw'),
      );
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhere>
      anyPerceptualHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'perceptualHash'),
      );
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

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      pathEqualTo(String path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path',
        value: [path],
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      pathNotEqualTo(String path) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      importSourceEqualTo(String importSource) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'importSource',
        value: [importSource],
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      importSourceNotEqualTo(String importSource) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'importSource',
              lower: [],
              upper: [importSource],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'importSource',
              lower: [importSource],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'importSource',
              lower: [importSource],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'importSource',
              lower: [],
              upper: [importSource],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      hasPendingSuggestionsEqualTo(bool hasPendingSuggestions) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hasPendingSuggestions',
        value: [hasPendingSuggestions],
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      hasPendingSuggestionsNotEqualTo(bool hasPendingSuggestions) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hasPendingSuggestions',
              lower: [],
              upper: [hasPendingSuggestions],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hasPendingSuggestions',
              lower: [hasPendingSuggestions],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hasPendingSuggestions',
              lower: [hasPendingSuggestions],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hasPendingSuggestions',
              lower: [],
              upper: [hasPendingSuggestions],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      isNsfwEqualTo(bool isNsfw) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isNsfw',
        value: [isNsfw],
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      isNsfwNotEqualTo(bool isNsfw) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [],
              upper: [isNsfw],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [isNsfw],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [isNsfw],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isNsfw',
              lower: [],
              upper: [isNsfw],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      perceptualHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'perceptualHash',
        value: [null],
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      perceptualHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'perceptualHash',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      perceptualHashEqualTo(int? perceptualHash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'perceptualHash',
        value: [perceptualHash],
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      perceptualHashNotEqualTo(int? perceptualHash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'perceptualHash',
              lower: [],
              upper: [perceptualHash],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'perceptualHash',
              lower: [perceptualHash],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'perceptualHash',
              lower: [perceptualHash],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'perceptualHash',
              lower: [],
              upper: [perceptualHash],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      perceptualHashGreaterThan(
    int? perceptualHash, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'perceptualHash',
        lower: [perceptualHash],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      perceptualHashLessThan(
    int? perceptualHash, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'perceptualHash',
        lower: [],
        upper: [perceptualHash],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterWhereClause>
      perceptualHashBetween(
    int? lowerPerceptualHash,
    int? upperPerceptualHash, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'perceptualHash',
        lower: [lowerPerceptualHash],
        includeLower: includeLower,
        upper: [upperPerceptualHash],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MediaSummaryModelQueryFilter
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QFilterCondition> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      dctHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dctHash',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      dctHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dctHash',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      dctHashEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dctHash',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      dctHashGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dctHash',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      dctHashLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dctHash',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      dctHashBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dctHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      deletedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      deletedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      hasPendingSuggestionsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasPendingSuggestions',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      hashedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hashedAt',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      hashedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hashedAt',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      hashedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      hashedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      hashedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      hashedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

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
      importSourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      importSourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      importSourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      importSourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'importSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      importSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      importSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      importSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'importSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      importSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'importSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      importSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'importSource',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      importSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'importSource',
        value: '',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      isImportedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isImported',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      isNsfwEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNsfw',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaHeightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mediaHeight',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaHeightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mediaHeight',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaHeightEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaHeight',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaHeightGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaHeight',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaHeightLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaHeight',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaHeightBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaHeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaWidthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mediaWidth',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaWidthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mediaWidth',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaWidthEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaWidth',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaWidthGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaWidth',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaWidthLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaWidth',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      mediaWidthBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaWidth',
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

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      perceptualHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'perceptualHash',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      perceptualHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'perceptualHash',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      perceptualHashEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'perceptualHash',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      perceptualHashGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'perceptualHash',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      perceptualHashLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'perceptualHash',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      perceptualHashBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'perceptualHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      recognizedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recognizedAt',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      recognizedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recognizedAt',
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      recognizedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recognizedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      recognizedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recognizedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      recognizedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recognizedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterFilterCondition>
      recognizedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recognizedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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
      sortByDctHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dctHash', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByDctHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dctHash', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByHasPendingSuggestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPendingSuggestions', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByHasPendingSuggestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPendingSuggestions', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByHashedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByHashedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashedAt', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByImportSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importSource', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByImportSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importSource', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByIsImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImported', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByIsImportedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImported', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByIsNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByMediaHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaHeight', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByMediaHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaHeight', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByMediaWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaWidth', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByMediaWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaWidth', Sort.desc);
    });
  }

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

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByPerceptualHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'perceptualHash', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByPerceptualHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'perceptualHash', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByRecognizedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recognizedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      sortByRecognizedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recognizedAt', Sort.desc);
    });
  }
}

extension MediaSummaryModelQuerySortThenBy
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QSortThenBy> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByDctHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dctHash', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByDctHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dctHash', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByHasPendingSuggestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPendingSuggestions', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByHasPendingSuggestionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPendingSuggestions', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByHashedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByHashedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashedAt', Sort.desc);
    });
  }

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
      thenByImportSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importSource', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByImportSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importSource', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByIsImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImported', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByIsImportedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImported', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByIsNsfwDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNsfw', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByMediaHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaHeight', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByMediaHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaHeight', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByMediaWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaWidth', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByMediaWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaWidth', Sort.desc);
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

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByPerceptualHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'perceptualHash', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByPerceptualHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'perceptualHash', Sort.desc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByRecognizedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recognizedAt', Sort.asc);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QAfterSortBy>
      thenByRecognizedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recognizedAt', Sort.desc);
    });
  }
}

extension MediaSummaryModelQueryWhereDistinct
    on QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct> {
  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByDctHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dctHash');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByHasPendingSuggestions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasPendingSuggestions');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByHashedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashedAt');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByImportSource({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importSource', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByIsImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isImported');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByIsNsfw() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNsfw');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByMediaHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaHeight');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByMediaWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaWidth');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByPerceptualHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'perceptualHash');
    });
  }

  QueryBuilder<MediaSummaryModel, MediaSummaryModel, QDistinct>
      distinctByRecognizedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recognizedAt');
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

  QueryBuilder<MediaSummaryModel, int?, QQueryOperations> dctHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dctHash');
    });
  }

  QueryBuilder<MediaSummaryModel, DateTime?, QQueryOperations>
      deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<MediaSummaryModel, bool, QQueryOperations>
      hasPendingSuggestionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasPendingSuggestions');
    });
  }

  QueryBuilder<MediaSummaryModel, DateTime?, QQueryOperations>
      hashedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashedAt');
    });
  }

  QueryBuilder<MediaSummaryModel, String, QQueryOperations>
      importSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importSource');
    });
  }

  QueryBuilder<MediaSummaryModel, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<MediaSummaryModel, bool, QQueryOperations> isImportedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isImported');
    });
  }

  QueryBuilder<MediaSummaryModel, bool, QQueryOperations> isNsfwProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNsfw');
    });
  }

  QueryBuilder<MediaSummaryModel, int?, QQueryOperations>
      mediaHeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaHeight');
    });
  }

  QueryBuilder<MediaSummaryModel, int?, QQueryOperations> mediaWidthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaWidth');
    });
  }

  QueryBuilder<MediaSummaryModel, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<MediaSummaryModel, int?, QQueryOperations>
      perceptualHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'perceptualHash');
    });
  }

  QueryBuilder<MediaSummaryModel, DateTime?, QQueryOperations>
      recognizedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recognizedAt');
    });
  }
}
