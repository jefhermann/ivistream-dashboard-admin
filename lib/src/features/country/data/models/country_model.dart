class CountryModel {
  String? code;
  String? name;
  String? zone;
  bool? isActive;

  CountryModel({this.code, this.name, this.zone, this.isActive});

  CountryModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    zone = json['zone'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    data['zone'] = zone;
    data['is_active'] = isActive;
    return data;
  }
}
