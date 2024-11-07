class AttendenceDataModel {
  int? status;
  String? message;
  Data? data;

  AttendenceDataModel({this.status, this.message, this.data});

  AttendenceDataModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? userId;
  String? latitude;
  String? longitude;
  String? punchInDate;
  String? punchInTime;
  String? punchOutDate;
  String? punchOutTime;
  String? image;
  String? punchType;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.userId,
        this.latitude,
        this.longitude,
        this.punchInDate,
        this.punchInTime,
        this.punchOutDate,
        this.punchOutTime,
        this.image,
        this.punchType,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    punchInDate = json['punch_in_date'];
    punchInTime = json['punch_in_time'];
    punchOutDate = json['punch_out_date'];
    punchOutTime = json['punch_out_time'];
    image = json['image'];
    punchType = json['punch_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['punch_in_date'] = this.punchInDate;
    data['punch_in_time'] = this.punchInTime;
    data['punch_out_date'] = this.punchOutDate;
    data['punch_out_time'] = this.punchOutTime;
    data['image'] = this.image;
    data['punch_type'] = this.punchType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
