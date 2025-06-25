class HolidayModel {
  int? status;
  var message;
  List<Orders>? orders;

  HolidayModel({this.status, this.message, this.orders});

  HolidayModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(new Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  var id;
  var title;
  var type;
  var holidayFrom;
  var holidayTo;
  var description;

  Orders(
      {this.id,
        this.title,
        this.type,
        this.holidayFrom,
        this.holidayTo,
        this.description});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    holidayFrom = json['holiday_from'];
    holidayTo = json['holiday_to'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type'] = this.type;
    data['holiday_from'] = this.holidayFrom;
    data['holiday_to'] = this.holidayTo;
    data['description'] = this.description;
    return data;
  }
}
