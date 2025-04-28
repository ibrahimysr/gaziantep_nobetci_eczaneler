class PharmacyResponse {
  bool? success;
  List<Result>? result;

  PharmacyResponse({this.success, this.result});

  PharmacyResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? name;
  String? dist;
  String? address;
  String? phone;
  String? loc;

  Result({this.name, this.dist, this.address, this.phone, this.loc, required String district});

  Result.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    dist = json['dist'];
    address = json['address'];
    phone = json['phone'];
    loc = json['loc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['dist'] = dist;
    data['address'] = address;
    data['phone'] = phone;
    data['loc'] = loc;
    return data;
  }
}