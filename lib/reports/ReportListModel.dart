class ReportListModel {
  int? status;
  var message;
  List<Data_report>? data;

  ReportListModel({this.status, this.message, this.data});

  ReportListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != String) {
      data = <Data_report>[];
      json['data'].forEach((v) {
        data!.add(new Data_report.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != String) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data_report {
  var id;
  var userId;
  var title;
  var remark;
  var startDate;
  var total_amount;
  var endDate;
  var admin_comment;
  var status;
  var createdAt;
  var updatedAt;
  List<SubmitExpenses>? submitExpenses;

  Data_report(
      {this.id,
        this.userId,
        this.title,
        this.remark,
        this.startDate,
        this.endDate,
        this.createdAt,
        this.admin_comment,
        this.status,
        this.updatedAt,
        this.submitExpenses});

  Data_report.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    remark = json['remark'];
    startDate = json['start_date'];
    total_amount = json['total_amount'];
    endDate = json['end_date'];
    admin_comment = json['admin_comment'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['submit_expenses'] != String) {
      submitExpenses = <SubmitExpenses>[];
      json['submit_expenses'].forEach((v) {
        submitExpenses!.add(new SubmitExpenses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['remark'] = this.remark;
    data['start_date'] = this.startDate;
    data['total_amount'] = this.total_amount;
    data['end_date'] = this.endDate;
    data['admin_comment'] = this.admin_comment;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.submitExpenses != String) {
      data['submit_expenses'] =
          this.submitExpenses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubmitExpenses {
  int? id;
  var submissionExpensesId;
  var expensesId;
  var userId;
  var createdAt;
  var updatedAt;
  List<Expenses>? expenses;

  SubmitExpenses(
      {this.id,
        this.submissionExpensesId,
        this.expensesId,
        this.userId,
        this.createdAt,
        this.updatedAt,
        this.expenses});

  SubmitExpenses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    submissionExpensesId = json['submission_expenses_id'];
    expensesId = json['expenses_id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['expenses'] != String) {
      expenses = <Expenses>[];
      json['expenses'].forEach((v) {
        expenses!.add(new Expenses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['submission_expenses_id'] = this.submissionExpensesId;
    data['expenses_id'] = this.expensesId;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.expenses != String) {
      data['expenses'] = this.expenses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Expenses {
  int? id;
  var userId;
  var visitId;
  var selectDate;
  var travelPurpose;
  var fromLocation;
  var toLocation;
  var mileageKm;
  var mileageAllowance;
  var hotelExp;
  var hotelExpReceipt;
  var vechileFare;
  var vechileReceipt;
  var otherExp;
  var otherExpReceipt;
  var remark;
  var routeType;
  var travelWithMd;
  var adminComment;
  var accountStatus;
  var adminStatus;
  var status;
  var date;
  var isEditable;
  var isDeleteable;
  var createdAt;
  var updatedAt;

  Expenses(
      {this.id,
        this.userId,
        this.visitId,
        this.selectDate,
        this.travelPurpose,
        this.fromLocation,
        this.toLocation,
        this.mileageKm,
        this.mileageAllowance,
        this.hotelExp,
        this.hotelExpReceipt,
        this.vechileFare,
        this.vechileReceipt,
        this.otherExp,
        this.otherExpReceipt,
        this.remark,
        this.routeType,
        this.travelWithMd,
        this.adminComment,
        this.accountStatus,
        this.adminStatus,
        this.status,
        this.date,
        this.isEditable,
        this.isDeleteable,
        this.createdAt,
        this.updatedAt});

  Expenses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    visitId = json['visit_id'];
    selectDate = json['select_date'];
    travelPurpose = json['travel_purpose'];
    fromLocation = json['from_location'];
    toLocation = json['to_location'];
    mileageKm = json['mileage_km'];
    mileageAllowance = json['mileage_allowance'];
    hotelExp = json['hotel_exp'];
    hotelExpReceipt = json['hotel_exp_receipt'];
    vechileFare = json['vechile_fare'];
    vechileReceipt = json['vechile_receipt'];
    otherExp = json['other_exp'];
    otherExpReceipt = json['other_exp_receipt'];
    remark = json['remark'];
    routeType = json['route_type'];
    travelWithMd = json['travel_with_md'];
    adminComment = json['admin_comment'];
    accountStatus = json['account_status'];
    adminStatus = json['admin_status'];
    status = json['status'];
    date = json['date'];
    isEditable = json['is_editable'];
    isDeleteable = json['is_deleteable'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['visit_id'] = this.visitId;
    data['select_date'] = this.selectDate;
    data['travel_purpose'] = this.travelPurpose;
    data['from_location'] = this.fromLocation;
    data['to_location'] = this.toLocation;
    data['mileage_km'] = this.mileageKm;
    data['mileage_allowance'] = this.mileageAllowance;
    data['hotel_exp'] = this.hotelExp;
    data['hotel_exp_receipt'] = this.hotelExpReceipt;
    data['vechile_fare'] = this.vechileFare;
    data['vechile_receipt'] = this.vechileReceipt;
    data['other_exp'] = this.otherExp;
    data['other_exp_receipt'] = this.otherExpReceipt;
    data['remark'] = this.remark;
    data['route_type'] = this.routeType;
    data['travel_with_md'] = this.travelWithMd;
    data['admin_comment'] = this.adminComment;
    data['account_status'] = this.accountStatus;
    data['admin_status'] = this.adminStatus;
    data['status'] = this.status;
    data['date'] = this.date;
    data['is_editable'] = this.isEditable;
    data['is_deleteable'] = this.isDeleteable;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
