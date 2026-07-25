import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class CreateContentModel {
  final String producerId;
  final String title;
  final String type;
  final String? description;
  final String? access;
  final String? maturity;
  final int? releaseYear;
  final int? rentalDurationHours;
  final String? country;
  final List<String>? directors;
  final List<String>? actors;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> genreIds;
  final Map<String, dynamic>? metadata;
  final ImageUpload? poster;
  final ImageUpload? banner;
  final bool isGlobal;

  const CreateContentModel({
    required this.producerId,
    required this.title,
    required this.type,
    this.description,
    this.access,
    this.maturity,
    this.releaseYear,
    this.rentalDurationHours = 72,
    this.country = "CI",
    this.startDate,
    this.endDate,
    this.genreIds = const [],
    this.metadata,
    this.poster,
    this.banner, this.directors, this.actors, this.isGlobal = false,
  });

  FormData toFormData() {
    final map = <String, dynamic>{
      'producerId': producerId,
      'title': title,
      'type': type,
    };

    if (description != null && description!.isNotEmpty) {
      map['description'] = description;
    }
    if (access != null) map['access'] = access;
    if (maturity != null) map['maturity'] = maturity;
    if (releaseYear != null) map['releaseYear'] = releaseYear.toString();
    if (rentalDurationHours != null) {
      map['rentalDurationHours'] = rentalDurationHours.toString();
    }
    if (country != null && country!.isNotEmpty) map['country'] = country;
    if (startDate != null) {
      map['start_date'] = startDate!.toUtc().toIso8601String();
    }
    if (endDate != null) {
      map['end_date'] = endDate!.toUtc().toIso8601String();
    }
    if (genreIds.isNotEmpty) map['genreIds'] = genreIds;
    if (metadata != null && metadata!.isNotEmpty) map['metadata'] = jsonEncode(metadata);

    if (poster != null) map['poster'] = poster!.toMultipartFile();
    if (banner != null) map['banner'] = banner!.toMultipartFile();

    if (directors != null && directors!.isNotEmpty) map['directors'] = directors!.toList();

    if (actors != null && actors!.isNotEmpty) map['actors'] = actors;

    if (isGlobal) map['isGlobal'] = isGlobal;

    return FormData.fromMap(map);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'producerId': producerId,
      'title': title,
      'type': type,
    };

    if (description != null && description!.isNotEmpty) {
      map['description'] = description;
    }
    if (access != null) map['access'] = access;
    if (maturity != null) map['maturity'] = maturity;
    if (releaseYear != null) map['releaseYear'] = releaseYear;
    if (rentalDurationHours != null) {
      map['rentalDurationHours'] = rentalDurationHours;
    }
    if (country != null && country!.isNotEmpty) map['country'] = country;
    if (startDate != null) {
      map['start_date'] = startDate!.toUtc().toIso8601String();
    }
    if (endDate != null) {
      map['end_date'] = endDate!.toUtc().toIso8601String();
    }
    if (genreIds.isNotEmpty) map['genreIds'] = genreIds;
    if (metadata != null && metadata!.isNotEmpty) map['metadata'] = metadata;

    if (directors != null && directors!.isNotEmpty) map['directors'] = directors!.toList();

    if (actors != null && actors!.isNotEmpty) map['actors'] = actors;

    return map;
  }

}

class ImageUpload {
  final Uint8List bytes;
  final String filename;

  const ImageUpload({required this.bytes, required this.filename});

  MultipartFile toMultipartFile() => MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: _mediaType(),
      );

  DioMediaType _mediaType() {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return DioMediaType('image', 'png');
      case 'webp':
        return DioMediaType('image', 'webp');
      default:
        return DioMediaType('image', 'jpeg');
    }
  }
}
