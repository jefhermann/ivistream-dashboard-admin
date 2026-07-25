import '../common.dart';

class DataResponse<T> {
  final T? item;
  final List<T>? items;
  final String? message;
  final int? statusCode;
  final bool? hasError;
  final PaginationModel? pagination;

  DataResponse._({this.item, this.items, this.message, this.statusCode, this.hasError, this.pagination});

  factory DataResponse.failure(String message) {
    return DataResponse._(message: message, hasError: true, item: null, items: null);
  }

  factory DataResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) parser) {
    final error = json['hasError'] as bool? ?? false;
    final statusCode = json['code'] as int? ?? 0;
    final message = error == true ? json['message'] as String? : null;
    final pagination = json['pagination'] != null ? PaginationModel.fromJson(json['pagination']) : null;

    T? parsedItem;
    List<T>? parsedItems;

    if ((json["items"] != null || json["item"] != null) && error == false) {
      dynamic decodedObject = json["items"] ?? json["item"];

      if (decodedObject is Map<String, dynamic>) {
        parsedItem = parser(decodedObject);
      } else if (decodedObject is List<dynamic>) {
        parsedItems = decodedObject.map<T>((x) => parser(x)).toList();
      }
    }

    return DataResponse._(item: parsedItem, items: parsedItems, message: message, hasError: error, statusCode: statusCode, pagination: pagination);
  }

  factory DataResponse.set({T? item, List<T>? items, String? message, int? statusCode, bool? error}) {
    return DataResponse._(item: item, items: items, message: message, hasError: error, statusCode: statusCode);
  }
}
