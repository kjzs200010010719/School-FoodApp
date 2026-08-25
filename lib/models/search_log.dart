class SearchLog {
  const SearchLog({
    required this.keyword,
    required this.filterSummary,
    required this.searchedAt,
  });

  final String keyword;
  final String filterSummary;
  final DateTime searchedAt;

  String get displayTitle => keyword.isEmpty ? '條件搜尋' : keyword;

  String get displaySubtitle {
    if (filterSummary.isEmpty) {
      return '未套用篩選條件';
    }

    return filterSummary;
  }

  String get searchedAtLabel {
    final hour = searchedAt.hour.toString().padLeft(2, '0');
    final minute = searchedAt.minute.toString().padLeft(2, '0');

    return '${searchedAt.month}/${searchedAt.day} $hour:$minute';
  }

  Map<String, Object?> toJson() {
    return {
      'keyword': keyword,
      'filterSummary': filterSummary,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }

  factory SearchLog.fromJson(Map<String, Object?> json) {
    return SearchLog(
      keyword: json['keyword'] as String? ?? '',
      filterSummary: json['filterSummary'] as String? ?? '',
      searchedAt:
          DateTime.tryParse(json['searchedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
