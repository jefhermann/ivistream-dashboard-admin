class PersonModel {
  String? id;
  String? name;
  String? bio;
  String? photoUrl;
  String? role;

  PersonModel({this.id, this.name, this.bio, this.photoUrl, this.role});

  PersonModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    bio = json['bio'];
    photoUrl = json['photo_url'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['bio'] = bio;
    data['photo_url'] = photoUrl;
    data['role'] = role;
    return data;
  }
}
