import '../../../common/common.dart';

class AdminInfoModel {
  UserModel? user;

  AdminInfoModel({this.user});

  AdminInfoModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
