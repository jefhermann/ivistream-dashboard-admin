class ContentPayoutDetailModel {
  final String id;
  final int watchMinutes;
  final int rentalCount;
  final int adImpressions;
  final double revenueShare;
  final PayoutDetailContent? content;
  final PayoutDetailParent? payout;

  ContentPayoutDetailModel({
    required this.id,
    required this.watchMinutes,
    required this.rentalCount,
    required this.adImpressions,
    required this.revenueShare,
    this.content,
    this.payout,
  });

  factory ContentPayoutDetailModel.fromJson(Map<String, dynamic> json) {
    return ContentPayoutDetailModel(
      id: json['id'] ?? '',
      watchMinutes: json['watch_minutes'] ?? 0,
      rentalCount: json['rental_count'] ?? 0,
      adImpressions: json['ad_impressions'] ?? 0,
      revenueShare: (json['revenue_share'] ?? 0).toDouble(),
      content: json['contents'] != null
          ? PayoutDetailContent.fromJson(json['contents'])
          : null,
      payout: json['producer_payouts'] != null
          ? PayoutDetailParent.fromJson(json['producer_payouts'])
          : null,
    );
  }
}

class PayoutDetailContent {
  final String id;
  final String title;
  final String type;
  final String? posterUrl;

  PayoutDetailContent({
    required this.id,
    required this.title,
    required this.type,
    this.posterUrl,
  });

  factory PayoutDetailContent.fromJson(Map<String, dynamic> json) {
    return PayoutDetailContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      posterUrl: json['poster_url'],
    );
  }
}

class PayoutDetailParent {
  final String id;
  final String periodStart;
  final String periodEnd;
  final String source;
  final String status;
  final String currency;
  final String? paidAt;

  PayoutDetailParent({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.source,
    required this.status,
    required this.currency,
    this.paidAt,
  });

  factory PayoutDetailParent.fromJson(Map<String, dynamic> json) {
    return PayoutDetailParent(
      id: json['id'] ?? '',
      periodStart: json['period_start'] ?? '',
      periodEnd: json['period_end'] ?? '',
      source: json['source'] ?? '',
      status: json['status'] ?? '',
      currency: json['currency'] ?? 'XOF',
      paidAt: json['paid_at'],
    );
  }
}

class ContentPayoutSummary {
  final double totalRevenue;
  final int totalWatchMinutes;
  final int totalRentals;
  final List<ContentPayoutDetailModel> details;

  ContentPayoutSummary({
    required this.totalRevenue,
    required this.totalWatchMinutes,
    required this.totalRentals,
    required this.details,
  });

  factory ContentPayoutSummary.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] ?? {};
    final detailsList = (json['details'] as List?)
        ?.map((d) => ContentPayoutDetailModel.fromJson(d))
        .toList() ?? [];

    return ContentPayoutSummary(
      totalRevenue: (totals['total_revenue'] ?? 0).toDouble(),
      totalWatchMinutes: totals['total_watch_minutes'] ?? 0,
      totalRentals: totals['total_rentals'] ?? 0,
      details: detailsList,
    );
  }
}