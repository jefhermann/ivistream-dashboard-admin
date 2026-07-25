import '../../../country/country.dart';
import '../../../person/person.dart';
import '../../../producers/producers.dart';

class AdminContentModel {
  final String? id;
  final String? title;
  final String? slug;
  final String? type; // movie, series, documentary, short
  final String? status; // draft, processing, published, archived
  final String? access; // free, premium
  final String? maturity;
  final int? releaseYear;
  final String? posterUrl;
  final String? bannerUrl;
  final String? description;
  final String? producerId;
  final String? genreIds;
  final int? rentalDurationHours;
  final Map<String, dynamic>? metadata;
  final String? createdAt;
  final String? publishedAt;
  final CountryModel? country;

  // Joined
  final AdminProducerModel? producers;
  final List<ContentGenreModel>? genres;
  final List<ContentVideoModel>? videos;
  final List<SeasonModel>? seasons;
  final List<PersonModel>? persons;

  AdminContentModel({
    this.id,
    required this.title,
    required this.slug,
    required this.type,
    required this.status,
    required this.access,
    this.maturity,
    this.releaseYear,
    this.producerId,
    this.posterUrl,
    this.bannerUrl,
    this.description,
    this.rentalDurationHours,
    this.metadata,
    this.createdAt,
    this.publishedAt,
    this.genreIds,
    this.producers,
    this.genres,
    this.videos,
    this.seasons, this.persons, this.country,
  });

  factory AdminContentModel.fromJson(Map<String, dynamic> json) {
    return AdminContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      type: json['type'] ?? 'movie',
      status: json['status'] ?? 'draft',
      access: json['access'] ?? 'free',
      maturity: json['maturity'],
      releaseYear: json['release_year'],
      posterUrl: json['poster_url'],
      bannerUrl: json['banner_url'],
      description: json['description'],
      rentalDurationHours: json['rental_duration_hours'],
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : null,
      createdAt: json['created_at'] ?? '',
      publishedAt: json['published_at'],
      producers: json['producers'] != null ? AdminProducerModel.fromJson(json['producers']) : null,
      genres: json['genres'] != null ? (json['genres'] as List).map((g) => ContentGenreModel.fromJson(g)).toList() : null,
      videos: json['content_videos'] != null ? (json['content_videos'] as List).map((v) => ContentVideoModel.fromJson(v)).toList() : null,
      seasons: json['seasons'] != null ? (json['seasons'] as List).map((s) => SeasonModel.fromJson(s)).toList() : null,
      persons: json['persons'] != null ? (json['persons'] as List).map((p) => PersonModel.fromJson(p)).toList() : null,
      genreIds: json['genreIds'],
      country: json['origin_country'] != null ? CountryModel.fromJson(json['origin_country']) : null,
    );
  }


  List<PersonModel> get directors => persons?.where((p) => p.role == 'director').toList() ?? [];
  List<PersonModel> get actors => persons?.where((p) => p.role == 'actor').toList() ?? [];

  String get producerName => producers?.name ?? 'Inconnu';

  String get typeLabel {
    switch (type) {
      case 'movie':
        return 'Film';
      case 'series':
        return 'Série';
      case 'documentary':
        return 'Documentaire';
      case 'short':
        return 'Court-métrage';
      default:
        return type ?? 'Inconnu';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'draft':
        return 'Brouillon';
      case 'processing':
        return 'En cours';
      case 'published':
        return 'Publié';
      case 'archived':
        return 'Archivé';
      default:
        return status ?? 'Inconnu';
    }
  }

  String get accessLabel => access == 'premium' ? 'Premium' : 'Gratuit';

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (slug != null) 'slug': slug,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (access != null) 'access': access,
      if (maturity != null) 'maturity': maturity,
      if (releaseYear != null) 'release_year': releaseYear,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (bannerUrl != null) 'banner_url': bannerUrl,
      if (description != null) 'description': description,
      if (rentalDurationHours != null) 'rental_duration_hours': rentalDurationHours,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (publishedAt != null) 'published_at': publishedAt,
      if (genreIds != null) 'genreIds': genreIds,
      if (producerId != null) 'producerId': producerId,
      if (producers != null) 'producerId': producers?.id,
      if (genres != null) 'genres': genres?.map((g) => g.id).toList(),
      if (videos != null) 'videos': videos?.map((v) => v.id).toList(),
      if (seasons != null) 'seasons': seasons?.map((s) => s.id).toList(),
      if (persons != null) 'persons': persons?.map((p) => p.id).toList(),
    };
  }
}

class ContentGenreModel {
  String? id;
  String? name;
  String? slug;

  ContentGenreModel({this.id, this.name, this.slug});

  ContentGenreModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    return data;
  }
}


class ContentVideoModel {
  final String id;
  final String role; // main, trailer, preview, recap
  final int position;
  final Map<String, dynamic>? video;

  ContentVideoModel({
    required this.id,
    required this.role,
    required this.position,
    this.video,
  });

  factory ContentVideoModel.fromJson(Map<String, dynamic> json) {
    return ContentVideoModel(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      position: json['position'] ?? 0,
      video: json['videos'] is Map<String, dynamic> ? json['videos'] : null,
    );
  }

  String get videoTitle => video?['title'] ?? 'Sans titre';

  int get durationSeconds => video?['duration_seconds'] ?? 0;

  String get videoStatus => video?['status'] ?? '';

  String get resolution => video?['resolution'] ?? '';

  String get roleLabel {
    switch (role) {
      case 'main':
        return 'Principal';
      case 'trailer':
        return 'Bande-annonce';
      case 'preview':
        return 'Aperçu';
      case 'recap':
        return 'Résumé';
      default:
        return role;
    }
  }

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m}m${s.toString().padLeft(2, '0')}s';
  }
}

class SeasonModel {
  final String? id;
  final int? number;
  final String? title;
  final List<EpisodeModel>? episodes;

  SeasonModel({this.id, this.number, this.title, this.episodes});

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      id: json['id'] ?? '',
      number: json['number'] ?? 0,
      title: json['title'],
      episodes: json['episodes'] != null ? (json['episodes'] as List).map((e) => EpisodeModel.fromJson(e)).toList() : null,
    );
  }

  String get displayTitle => title ?? 'Saison $number';

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (title != null) 'title': title,
      if (episodes != null) 'episodes': episodes?.map((e) => e.id).toList(),
    };
  }
}

class EpisodeModel {
  final String? id;
  final int? number;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? videoId;
  final Map<String, dynamic>? video;

  EpisodeModel({
    this.id,
    this.number,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.videoId,
    this.video,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'] ?? '',
      number: json['number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      videoId: json['video_id'],
      video: json['videos'] is Map<String, dynamic> ? json['videos'] : null,
    );
  }

  int get durationSeconds => video?['duration_seconds'] ?? 0;

  String get videoStatus => video?['status'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (videoId != null) 'video_id': videoId,
      if (video != null) 'videos': video
    };
  }
}
