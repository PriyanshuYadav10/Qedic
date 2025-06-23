class LoginModel {
  int? status;
  String? message;
  Data? data;

  LoginModel({this.status, this.message, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
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
  String? firstName;
  String? lastName;
  String? username;
  var roleId;
  String? userType;
  String? email;
  String? fatherName;
  String? motherName;
  String? gender;
  String? dob;
  String? qualification;
  String? percentage;
  String? bloodGroup;
  String? mobile;
  String? designation;
  String? dateOfJoining;
  String? address;
  String? salary;
  String? aadhar;
  String? pancard;
  String? referenceBy;
  var newsletter;
  String? shop;
  String? langCode;
  String? deviceType;
  String? picture;

  Data(
      {this.id,
        this.firstName,
        this.lastName,
        this.username,
        this.roleId,
        this.userType,
        this.email,
        this.fatherName,
        this.motherName,
        this.gender,
        this.dob,
        this.qualification,
        this.percentage,
        this.bloodGroup,
        this.mobile,
        this.designation,
        this.dateOfJoining,
        this.address,
        this.salary,
        this.aadhar,
        this.pancard,
        this.referenceBy,
        this.newsletter,
        this.shop,
        this.langCode,
        this.deviceType,
        this.picture});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    username = json['username'];
    roleId = json['role_id'];
    userType = json['user_type'];
    email = json['email'];
    fatherName = json['father_name'];
    motherName = json['mother_name'];
    gender = json['gender'];
    dob = json['dob'];
    qualification = json['qualification'];
    percentage = json['percentage'];
    bloodGroup = json['blood_group'];
    mobile = json['mobile'];
    designation = json['designation'];
    dateOfJoining = json['date_of_joining'];
    address = json['address'];
    salary = json['salary'];
    aadhar = json['aadhar'];
    pancard = json['pancard'];
    referenceBy = json['reference_by'];
    newsletter = json['newsletter'];
    shop = json['shop'];
    langCode = json['lang_code'];
    deviceType = json['device_type'];
    picture = json['picture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['username'] = this.username;
    data['role_id'] = this.roleId;
    data['user_type'] = this.userType;
    data['email'] = this.email;
    data['father_name'] = this.fatherName;
    data['mother_name'] = this.motherName;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['qualification'] = this.qualification;
    data['percentage'] = this.percentage;
    data['blood_group'] = this.bloodGroup;
    data['mobile'] = this.mobile;
    data['designation'] = this.designation;
    data['date_of_joining'] = this.dateOfJoining;
    data['address'] = this.address;
    data['salary'] = this.salary;
    data['aadhar'] = this.aadhar;
    data['pancard'] = this.pancard;
    data['reference_by'] = this.referenceBy;
    data['newsletter'] = this.newsletter;
    data['shop'] = this.shop;
    data['lang_code'] = this.langCode;
    data['device_type'] = this.deviceType;
    data['picture'] = this.picture;
    return data;
  }
}
