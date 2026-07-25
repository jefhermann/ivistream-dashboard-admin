class RevenueOverviewModel {
  final double totalGross;
  final double totalProducer;
  final double totalPlatform;
  final Map<String, RevenueSourceModel> bySource;
  final List<MonthlyRevenueModel> monthly;
  final int pendingPayoutsCount;
  final double pendingPayoutsAmount;
  final String currency;

  RevenueOverviewModel({
    required this.totalGross,
    required this.totalProducer,
    required this.totalPlatform,
    required this.bySource,
    required this.monthly,
    required this.pendingPayoutsCount,
    required this.pendingPayoutsAmount,
    required this.currency,
  });

  factory RevenueOverviewModel.fromJson(Map<String, dynamic> json) {
    final bySourceMap = <String, RevenueSourceModel>{};
    if (json['by_source'] is Map) {
      (json['by_source'] as Map).forEach((key, value) {
        bySourceMap[key.toString()] = RevenueSourceModel.fromJson(value);
      });
    }

    return RevenueOverviewModel(
      totalGross: (json['total_gross'] ?? 0).toDouble(),
      totalProducer: (json['total_producer'] ?? 0).toDouble(),
      totalPlatform: (json['total_platform'] ?? 0).toDouble(),
      bySource: bySourceMap,
      monthly: (json['monthly'] as List? ?? []).map((m) => MonthlyRevenueModel.fromJson(m)).toList(),
      pendingPayoutsCount: json['pending_payouts_count'] ?? 0,
      pendingPayoutsAmount: (json['pending_payouts_amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
    );
  }

  factory RevenueOverviewModel.empty() {
    return RevenueOverviewModel(
      totalGross: 0, totalProducer: 0, totalPlatform: 0,
      bySource: {}, monthly: [], pendingPayoutsCount: 0,
      pendingPayoutsAmount: 0, currency: 'XOF',
    );
  }
}

class RevenueSourceModel {
  final double gross;
  final double producer;
  final double platform;

  RevenueSourceModel({required this.gross, required this.producer, required this.platform});

  factory RevenueSourceModel.fromJson(Map<String, dynamic> json) {
    return RevenueSourceModel(
      gross: (json['gross'] ?? 0).toDouble(),
      producer: (json['producer'] ?? 0).toDouble(),
      platform: (json['platform'] ?? 0).toDouble(),
    );
  }
}

class MonthlyRevenueModel {
  final String month;
  final double gross;
  final double subscription;
  final double rental;
  final double advertising;

  MonthlyRevenueModel({required this.month, required this.gross, required this.subscription, required this.rental, required this.advertising});

  factory MonthlyRevenueModel.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueModel(
      month: json['month'] ?? '',
      gross: (json['gross'] ?? 0).toDouble(),
      subscription: (json['subscription'] ?? 0).toDouble(),
      rental: (json['rental'] ?? 0).toDouble(),
      advertising: (json['advertising'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'gross': gross,
      'subscription': subscription,
      'rental': rental,
      'advertising': advertising,
    };
  }
}

class ProducerRevenueModel {
  final String producerId;
  final String producerName;
  final String? producerLogo;
  final double totalGross;
  final double totalProducer;
  final double totalPlatform;

  ProducerRevenueModel({
    required this.producerId, required this.producerName, this.producerLogo,
    required this.totalGross, required this.totalProducer, required this.totalPlatform,
  });

  factory ProducerRevenueModel.fromJson(Map<String, dynamic> json) {
    return ProducerRevenueModel(
      producerId: json['producer_id'] ?? '',
      producerName: json['producer_name'] ?? 'Inconnu',
      producerLogo: json['producer_logo'],
      totalGross: (json['total_gross'] ?? 0).toDouble(),
      totalProducer: (json['total_producer'] ?? 0).toDouble(),
      totalPlatform: (json['total_platform'] ?? 0).toDouble(),
    );
  }
}

class PayoutModel {
  final String id;
  final String producerId;
  final String periodStart;
  final String periodEnd;
  final String source; // subscription, rental, advertising
  final int totalWatchMinutes;
  final int totalRentals;
  final double grossRevenue;
  final double platformSharePct;
  final double producerAmount;
  final double platformAmount;
  final String currency;
  final String status; // pending, calculated, approved, paid, disputed
  final String? approvedBy;
  final String? paidAt;
  final String? paymentRef;
  final String createdAt;
  final Map<String, dynamic>? producer;
  final List<PayoutDetailModel>? details;

  PayoutModel({
    required this.id, required this.producerId, required this.periodStart,
    required this.periodEnd, required this.source, required this.totalWatchMinutes,
    required this.totalRentals, required this.grossRevenue,
    required this.platformSharePct, required this.producerAmount,
    required this.platformAmount, required this.currency,
    required this.status, this.approvedBy, this.paidAt,
    this.paymentRef, required this.createdAt, this.producer, this.details,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: json['id'] ?? '',
      producerId: json['producer_id'] ?? '',
      periodStart: json['period_start'] ?? '',
      periodEnd: json['period_end'] ?? '',
      source: json['source'] ?? '',
      totalWatchMinutes: json['total_watch_minutes'] ?? 0,
      totalRentals: json['total_rentals'] ?? 0,
      grossRevenue: (json['gross_revenue'] ?? 0).toDouble(),
      platformSharePct: (json['platform_share_pct'] ?? 0).toDouble(),
      producerAmount: (json['producer_amount'] ?? 0).toDouble(),
      platformAmount: (json['platform_amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      status: json['status'] ?? 'pending',
      approvedBy: json['approved_by'],
      paidAt: json['paid_at'],
      paymentRef: json['payment_ref'],
      createdAt: json['created_at'] ?? '',
      producer: json['producers'] is Map<String, dynamic> ? json['producers'] : null,
      details: json['details'] != null
          ? (json['details'] as List).map((d) => PayoutDetailModel.fromJson(d)).toList()
          : null,
    );
  }

  String get producerName => producer?['name'] ?? 'Inconnu';

  String get sourceLabel {
    switch (source) {
      case 'subscription': return 'Abonnement';
      case 'rental': return 'Location';
      case 'advertising': return 'Publicité';
      default: return source;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'En attente';
      case 'calculated': return 'Calculé';
      case 'approved': return 'Approuvé';
      case 'paid': return 'Payé';
      case 'disputed': return 'Contesté';
      default: return status;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producer_id': producerId,
      'period_start': periodStart,
      'period_end': periodEnd,
      'source': source,
      'total_watch_minutes': totalWatchMinutes,
      'total_rentals': totalRentals,
      'gross_revenue': grossRevenue,
      'platform_share_pct': platformSharePct,
      'producer_amount': producerAmount,
      'platform_amount': platformAmount,
      'currency': currency,
      'status': status,
      'approved_by': approvedBy,
      'paid_at': paidAt,
      'payment_ref': paymentRef,
      'created_at': createdAt,
      'producers': producer,
      'details': details?.map((d) => d.toJson()).toList(),
    };
  }
}

class PayoutDetailModel {
  final String id;
  final String payoutId;
  final String contentId;
  final int watchMinutes;
  final int rentalCount;
  final int adImpressions;
  final double revenueShare;
  final Map<String, dynamic>? content;

  PayoutDetailModel({
    required this.id, required this.payoutId, required this.contentId,
    required this.watchMinutes, required this.rentalCount,
    required this.adImpressions, required this.revenueShare, this.content,
  });

  factory PayoutDetailModel.fromJson(Map<String, dynamic> json) {
    return PayoutDetailModel(
      id: json['id'] ?? '',
      payoutId: json['payout_id'] ?? '',
      contentId: json['content_id'] ?? '',
      watchMinutes: json['watch_minutes'] ?? 0,
      rentalCount: json['rental_count'] ?? 0,
      adImpressions: json['ad_impressions'] ?? 0,
      revenueShare: (json['revenue_share'] ?? 0).toDouble(),
      content: json['contents'] is Map<String, dynamic> ? json['contents'] : null,
    );
  }

  String get contentTitle => content?['title'] ?? 'Inconnu';
  String get contentType => content?['type'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payout_id': payoutId,
      'content_id': contentId,
      'watch_minutes': watchMinutes,
      'rental_count': rentalCount,
      'ad_impressions': adImpressions,
      'revenue_share': revenueShare,
      'contents': content,
    };
  }
}
