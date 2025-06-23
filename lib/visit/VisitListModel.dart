class VisitListModel {
  int? status;
  var message;
  List<VisitListData>? data;

  VisitListModel({this.status, this.message, this.data});

  VisitListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <VisitListData>[];
      json['data'].forEach((v) {
        data!.add(new VisitListData.fromJson(v));
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

class VisitListData {
  var id;
  var userId;
  var purpose;
  var custName;
  var centerName;
  var cityName;
  var contactNumber;
  var email;
  var existingMachine;
  var usgAgeing;
  var quality;
  var productName;
  var opptyType;
  var expectedClosureDate;
  var remarkSupport;
  var supportRequired;
  var winLossProduct;
  var winLossCompany;
  var adminComment;
  var accountantStatus;
  var status;
  var date;
  var address;
  var district;
  var existingMachineCompany;
  var machineModel;
  var isOpportunity;
  var opportunityId;
  var opportunityDate;
  var modality;
  var productValue;
  var productCategory;
  var pndt;
  var quatationSubmit;
  var demoDone;
  var winLossDate;
  var opportunityStatus;
  var reffrenceUserId;
  var comment;
  var forcast;
  var isEditable;
  var isDeleteable;
  bool isSelected = false;
  var createdAt;
  var updatedAt;
  var uname;

  VisitListData(
      {this.id,
      this.userId,
      this.purpose,
      this.custName,
      this.centerName,
      this.cityName,
      this.contactNumber,
      this.email,
      this.existingMachine,
      this.modality,
      this.usgAgeing,
      this.quality,
      this.productName,
      this.opptyType,
      this.expectedClosureDate,
      this.remarkSupport,
      this.supportRequired,
      this.winLossProduct,
      this.winLossCompany,
      this.adminComment,
      this.accountantStatus,
      this.status,
      this.date,
      this.address,
      this.district,
      this.existingMachineCompany,
      this.machineModel,
      this.isOpportunity,
      this.opportunityId,
      this.opportunityDate,
      this.productValue,
      this.productCategory,
      this.pndt,
      this.quatationSubmit,
      this.demoDone,
      this.winLossDate,
      this.opportunityStatus,
      this.reffrenceUserId,
      this.comment,
      this.forcast,
      this.isEditable,
      this.isDeleteable,
      this.createdAt,
      this.updatedAt,
      this.uname});

  VisitListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    purpose = json['purpose'];
    custName = json['cust_name'];
    centerName = json['center_name'];
    cityName = json['city_name'];
    contactNumber = json['contact_number'];
    email = json['email'];
    existingMachine = json['existing_machine'];
    usgAgeing = json['usg_ageing'];
    modality = json['modality'];
    quality = json['quality'];
    productName = json['product_name'];
    opptyType = json['oppty_type'];
    expectedClosureDate = json['expected_closure_date'];
    remarkSupport = json['remark_support'];
    supportRequired = json['support_required'];
    winLossProduct = json['win_loss_product'];
    winLossCompany = json['win_loss_company'];
    adminComment = json['admin_comment'];
    accountantStatus = json['accountant_status'];
    status = json['status'];
    date = json['date'];
    address = json['address'];
    district = json['district'];
    existingMachineCompany = json['existing_machine_company'];
    machineModel = json['machine_model'];
    isOpportunity = json['is_opportunity'];
    opportunityId = json['opportunity_id'];
    opportunityDate = json['opportunity_date'];
    productValue = json['product_value'];
    productCategory = json['product_category'];
    pndt = json['pndt'];
    quatationSubmit = json['quatation_submit'];
    demoDone = json['demo_done'];
    winLossDate = json['win_loss_date'];
    opportunityStatus = json['opportunity_status'];
    reffrenceUserId = json['reffrence_user_id'];
    comment = json['comment'];
    forcast = json['forcast'];
    isEditable = json['is_editable'];
    isDeleteable = json['is_deleteable'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    uname = json['uname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['purpose'] = this.purpose;
    data['cust_name'] = this.custName;
    data['center_name'] = this.centerName;
    data['city_name'] = this.cityName;
    data['contact_number'] = this.contactNumber;
    data['email'] = this.email;
    data['existing_machine'] = this.existingMachine;
    data['usg_ageing'] = this.usgAgeing;
    data['quality'] = this.quality;
    data['modality'] = this.modality;
    data['product_name'] = this.productName;
    data['oppty_type'] = this.opptyType;
    data['expected_closure_date'] = this.expectedClosureDate;
    data['remark_support'] = this.remarkSupport;
    data['support_required'] = this.supportRequired;
    data['win_loss_product'] = this.winLossProduct;
    data['win_loss_company'] = this.winLossCompany;
    data['admin_comment'] = this.adminComment;
    data['accountant_status'] = this.accountantStatus;
    data['status'] = this.status;
    data['date'] = this.date;
    data['address'] = this.address;
    data['district'] = this.district;
    data['existing_machine_company'] = this.existingMachineCompany;
    data['machine_model'] = this.machineModel;
    data['is_opportunity'] = this.isOpportunity;
    data['opportunity_id'] = this.opportunityId;
    data['opportunity_date'] = this.opportunityDate;
    data['product_value'] = this.productValue;
    data['product_category'] = this.productCategory;
    data['pndt'] = this.pndt;
    data['quatation_submit'] = this.quatationSubmit;
    data['demo_done'] = this.demoDone;
    data['win_loss_date'] = this.winLossDate;
    data['opportunity_status'] = this.opportunityStatus;
    data['reffrence_user_id'] = this.reffrenceUserId;
    data['comment'] = this.comment;
    data['forcast'] = this.forcast;
    data['is_editable'] = this.isEditable;
    data['is_deleteable'] = this.isDeleteable;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['uname'] = this.uname;
    return data;
  }
}
