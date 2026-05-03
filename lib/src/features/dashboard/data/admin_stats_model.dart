class AdminStatsModel {
  final int totalUsers;
  final int activeUsers;
  final int totalProducers;
  final int totalContents;
  final int publishedContents;
  final int totalViews;
  final int totalWatchMinutes;
  final int activeSubscriptions;
  final int totalRentals;

  AdminStatsModel({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalProducers,
    required this.totalContents,
    required this.publishedContents,
    required this.totalViews,
    required this.totalWatchMinutes,
    required this.activeSubscriptions,
    required this.totalRentals,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      totalProducers: json['total_producers'] ?? 0,
      totalContents: json['total_contents'] ?? 0,
      publishedContents: json['published_contents'] ?? 0,
      totalViews: json['total_views'] ?? 0,
      totalWatchMinutes: json['total_watch_minutes'] ?? 0,
      activeSubscriptions: json['active_subscriptions'] ?? 0,
      totalRentals: json['total_rentals'] ?? 0,
    );
  }

  factory AdminStatsModel.empty() {
    return AdminStatsModel(
      totalUsers: 0,
      activeUsers: 0,
      totalProducers: 0,
      totalContents: 0,
      publishedContents: 0,
      totalViews: 0,
      totalWatchMinutes: 0,
      activeSubscriptions: 0,
      totalRentals: 0,
    );
  }
}

class RecentUserModel {
  final String id;
  final String email;
  final String fullName;
  final String? trialStatus;
  final String createdAt;

  RecentUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.trialStatus,
    required this.createdAt,
  });

  factory RecentUserModel.fromJson(Map<String, dynamic> json) {
    return RecentUserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      trialStatus: json['trial_status'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class RecentContentModel {
  final String id;
  final String title;
  final String type;
  final String? status;
  final String? posterUrl;
  final String createdAt;

  RecentContentModel({
    required this.id,
    required this.title,
    required this.type,
    this.status,
    this.posterUrl,
    required this.createdAt,
  });

  factory RecentContentModel.fromJson(Map<String, dynamic> json) {
    return RecentContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      status: json['status'],
      posterUrl: json['poster_url'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
