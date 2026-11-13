class PaginationModel {
  final int limit;
  final int offset;
  final int count;
  final int total;

  PaginationModel({
    required this.limit,
    required this.offset,
    required this.count,
    required this.total,
  });

  bool get hasMore => (offset + count) < total;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'limit': limit,
        'offset': offset,
        'count': count,
        'total': total,
      };

  PaginationModel copyWith({
    int? limit,
    int? offset,
    int? count,
    int? total,
  }) {
    return PaginationModel(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      count: count ?? this.count,
      total: total ?? this.total,
    );
  }
}

