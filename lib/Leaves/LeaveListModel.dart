class LeaveListModel {
  int? status;
  var message;
  List<Data_leave>? data;

  LeaveListModel({this.status, this.message, this.data});

  LeaveListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data_leave>[];
      json['data'].forEach((v) {
        data!.add(new Data_leave.fromJson(v));
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

class Data_leave {
  var id;
  var userId;
  var userName;
  var leaveData;
  var startDate;
  var endDate;
  var leaveType;
  var description;
  var status;
  var adminComment;

  Data_leave(
      {this.id,
        this.userId,
        this.userName,
        this.leaveData,
        this.startDate,
        this.endDate,
        this.leaveType,
        this.description,
        this.status,
        this.adminComment
      });

  Data_leave.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    leaveData = json['leave_data'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    leaveType = json['leave_type'];
    description = json['description'];
    status = json['status'];
    adminComment = json['admin_comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['leave_data'] = this.leaveData;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['leave_type'] = this.leaveType;
    data['description'] = this.description;
    data['status'] = this.status;
    data['admin_comment'] = this.adminComment;
    return data;
  }
}
