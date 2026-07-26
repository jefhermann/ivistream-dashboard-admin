class GenreModel {
  String? id;
  String? name;
  String? slug;
  bool? isActive;

  GenreModel({this.id, this.name, this.slug, this.isActive});

  GenreModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['is_active'] = isActive;
    return data;
  }
}
