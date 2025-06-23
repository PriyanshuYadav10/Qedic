class ExpensesListModel {
  int? status;
  var message;
  List<Data_Expenses>? data;

  ExpensesListModel({this.status, this.message, this.data});

  ExpensesListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data_Expenses>[];
      json['data'].forEach((v) {
        data!.add(new Data_Expenses.fromJson(v));
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

  class Data_Expenses {
  var id;
  var userId;
  var visitId;
  var visitName;
  var selectDate;
  var travelPurpose;
  var fromLocation;
  var toLocation;
  var mileageKm;
  var mileageAllowance;
  var hotelExpReceipt;
  var hotelExp;
  var vechileFare;
  var vechileReceipt;
  var otherExp;
  var otherExpReceipt;
  var accountStatus;
  var status;
  var isEditable;
  var adminComment;
  var travelWithMd;
  var routeType;
  var remark;
  bool isSelected = false;
  var total_amount;

  Data_Expenses(
      {this.id,
        this.userId,
        this.visitId,
        this.visitName,
        this.selectDate,
        this.travelPurpose,
        this.fromLocation,
        this.toLocation,
        this.mileageKm,
        this.mileageAllowance,
        this.hotelExpReceipt,
        this.hotelExp,
        this.vechileFare,
        this.vechileReceipt,
        this.otherExp,
        this.otherExpReceipt,
        this.accountStatus,
        this.status,
        this.isEditable,
        this.adminComment,
        this.travelWithMd,
        this.routeType,
        this.remark,
        this.total_amount
      });

  Data_Expenses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    visitId = json['visit_id'];
    visitName = json['visit_name'];
    selectDate = json['select_date'];
    travelPurpose = json['travel_purpose'];
    fromLocation = json['from_location'];
    toLocation = json['to_location'];
    mileageKm = json['mileage_km'];
    mileageAllowance = json['mileage_allowance'];
    hotelExpReceipt = json['hotel_exp_receipt'];
    hotelExp = json['hotel_exp'];
    vechileFare = json['vechile_fare'];
    vechileReceipt = json['vechile_receipt'];
    otherExp = json['other_exp'];
    otherExpReceipt = json['other_exp_receipt'];
    accountStatus = json['account_status'];
    status = json['status'];
    isEditable = json['isEditable'];
    adminComment = json['admin_comment'];
    travelWithMd = json['travel_with_md'];
    routeType = json['route_type'];
    remark = json['remark'];
    total_amount = json['total_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['visit_id'] = this.visitId;
    data['visit_name'] = this.visitName;
    data['select_date'] = this.selectDate;
    data['travel_purpose'] = this.travelPurpose;
    data['from_location'] = this.fromLocation;
    data['to_location'] = this.toLocation;
    data['mileage_km'] = this.mileageKm;
    data['mileage_allowance'] = this.mileageAllowance;
    data['hotel_exp_receipt'] = this.hotelExpReceipt;
    data['hotel_exp'] = this.hotelExp;
    data['vechile_fare'] = this.vechileFare;
    data['vechile_receipt'] = this.vechileReceipt;
    data['other_exp'] = this.otherExp;
    data['other_exp_receipt'] = this.otherExpReceipt;
    data['account_status'] = this.accountStatus;
    data['status'] = this.status;
    data['isEditable'] = this.isEditable;
    data['admin_comment'] = this.adminComment;
    data['travel_with_md'] = this.travelWithMd;
    data['route_type'] = this.routeType;
    data['remark'] = this.remark;
    data['total_amount'] = this.total_amount;
    return data;
  }
}
