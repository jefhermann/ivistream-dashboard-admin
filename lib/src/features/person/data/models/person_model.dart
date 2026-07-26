class PersonModel {
  String? id;
  String? name;
  String? bio;
  String? photoUrl;
  String? role;
  bool? isActive;

  PersonModel({this.id, this.name, this.bio, this.photoUrl, this.role, this.isActive});

  PersonModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    bio = json['bio'];
    photoUrl = json['photo_url'];
    role = json['role'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (bio != null) data['bio'] = bio;
    if (photoUrl != null) data['photo_url'] = photoUrl;
    if (role != null) data['role'] = role;
    if (isActive != null) data['is_active'] = isActive;
    return data;
  }
}
