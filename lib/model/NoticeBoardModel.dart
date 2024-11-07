class NoticeBoardModel {
  int? status;
  String? message;
  List<Orders_Noticeboard>? orders;

  NoticeBoardModel({this.status, this.message, this.orders});

  NoticeBoardModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['orders'] != null) {
      orders = <Orders_Noticeboard>[];
      json['orders'].forEach((v) {
        orders!.add(new Orders_Noticeboard.fromJson(v));
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

class Orders_Noticeboard {
  String? id;
  String? title;
  String? description;
  String? createdAt;

  Orders_Noticeboard({this.id, this.title, this.description, this.createdAt});

  Orders_Noticeboard.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    return data;
  }
}
