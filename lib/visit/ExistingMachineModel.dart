class ExistingMachineModel {
  int? status;
  String? message;
  List<ExistingMachineData>? data;

  ExistingMachineModel({this.status, this.message, this.data});

  ExistingMachineModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ExistingMachineData>[];
      json['data'].forEach((v) {
        data!.add(new ExistingMachineData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ExistingMachineData {
  int? id;
  String? companyMachineId;
  String? name;
  String? status;
  String? createdAt;
  String? updatedAt;

  ExistingMachineData(
      {this.id,
        this.companyMachineId,
        this.name,
        this.status,
        this.createdAt,
        this.updatedAt});

  ExistingMachineData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyMachineId = json['company_machine_id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['company_machine_id'] = this.companyMachineId;
    data['name'] = this.name;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
