class CountryModel {
  String? code;
  String? name;
  String? zone;

  CountryModel({this.code, this.name, this.zone});

  CountryModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    zone = json['zone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    data['zone'] = zone;
    return data;
  }
}
