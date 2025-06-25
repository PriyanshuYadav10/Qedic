class AllListingModel {
  int? status;
  var message;
  AllListingData? data;

  AllListingModel({this.status, this.message, this.data});

  AllListingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? new AllListingData.fromJson(json['data']) : null;
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

class AllListingData {
  List<RefrenceUser>? refrenceUser;
  List<MachineComapny>? machineComapny;
  List<String>? productPithed;

  AllListingData({this.refrenceUser, this.machineComapny, this.productPithed});

  AllListingData.fromJson(Map<String, dynamic> json) {
    if (json['refrence_user'] != null) {
      refrenceUser = <RefrenceUser>[];
      json['refrence_user'].forEach((v) {
        refrenceUser!.add(new RefrenceUser.fromJson(v));
      });
    }
    if (json['machine_comapny'] != null) {
      machineComapny = <MachineComapny>[];
      json['machine_comapny'].forEach((v) {
        machineComapny!.add(new MachineComapny.fromJson(v));
      });
    }
    productPithed = json['product_pithed'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.refrenceUser != null) {
      data['refrence_user'] =
          this.refrenceUser!.map((v) => v.toJson()).toList();
    }
    if (this.machineComapny != null) {
      data['machine_comapny'] =
          this.machineComapny!.map((v) => v.toJson()).toList();
    }
    data['product_pithed'] = this.productPithed;
    return data;
  }
}

class RefrenceUser {
  var id;
  var roleId;
  var type;
  var username;
  var firstName;
  var lastName;
  var email;
  var password;
  var fatherName;
  var motherName;
  var gender;
  var dob;
  var qualification;
  var percentage;
  var bloodGroup;
  var mobile;
  var designation;
  var dateOfJoining;
  var address;
  var salary;
  var aadhar;
  var aadharBack;
  var pancard;
  var referenceBy;
  var newsletter;
  var shop;
  var langCode;
  var picture;
  var deviceType;
  var fcmToken;
  var rememberToken;
  var status;
  var otp;
  var deleteStatus;
  var createdAt;
  var updatedAt;

  RefrenceUser(
      {this.id,
      this.roleId,
      this.type,
      this.username,
      this.firstName,
      this.lastName,
      this.email,
      this.password,
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
      this.aadharBack,
      this.pancard,
      this.referenceBy,
      this.newsletter,
      this.shop,
      this.langCode,
      this.picture,
      this.deviceType,
      this.fcmToken,
      this.rememberToken,
      this.status,
      this.otp,
      this.deleteStatus,
      this.createdAt,
      this.updatedAt});

  RefrenceUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roleId = json['role_id'];
    type = json['type'];
    username = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    password = json['password'];
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
    aadharBack = json['aadhar_back'];
    pancard = json['pancard'];
    referenceBy = json['reference_by'];
    newsletter = json['newsletter'];
    shop = json['shop'];
    langCode = json['lang_code'];
    picture = json['picture'];
    deviceType = json['device_type'];
    fcmToken = json['fcm_token'];
    rememberToken = json['remember_token'];
    status = json['status'];
    otp = json['otp'];
    deleteStatus = json['delete_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role_id'] = this.roleId;
    data['type'] = this.type;
    data['username'] = this.username;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['password'] = this.password;
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
    data['aadhar_back'] = this.aadharBack;
    data['pancard'] = this.pancard;
    data['reference_by'] = this.referenceBy;
    data['newsletter'] = this.newsletter;
    data['shop'] = this.shop;
    data['lang_code'] = this.langCode;
    data['picture'] = this.picture;
    data['device_type'] = this.deviceType;
    data['fcm_token'] = this.fcmToken;
    data['remember_token'] = this.rememberToken;
    data['status'] = this.status;
    data['otp'] = this.otp;
    data['delete_status'] = this.deleteStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class MachineComapny {
  int? id;
  var name;
  var status;
  var createdAt;
  var updatedAt;

  MachineComapny(
      {this.id, this.name, this.status, this.createdAt, this.updatedAt});

  MachineComapny.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
