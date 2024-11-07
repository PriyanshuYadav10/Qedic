class HomeModel {
  int? status;
  String? message;
  int? totalVisits;
  int? pendingVisits;
  int? approveVisits;
  int? totalExpenses;
  int? pendingExpenses;
  int? approveExpenses;
  int? mileageFair;

  HomeModel(
      {this.status,
        this.message,
        this.totalVisits,
        this.pendingVisits,
        this.approveVisits,
        this.totalExpenses,
        this.pendingExpenses,
        this.approveExpenses,
        this.mileageFair});

  HomeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    totalVisits = json['total_visits'];
    pendingVisits = json['pending_visits'];
    approveVisits = json['approve_visits'];
    totalExpenses = json['total_expenses'];
    pendingExpenses = json['pending_expenses'];
    approveExpenses = json['approve_expenses'];
    mileageFair = json['mileage_fair'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total_visits'] = this.totalVisits;
    data['pending_visits'] = this.pendingVisits;
    data['approve_visits'] = this.approveVisits;
    data['total_expenses'] = this.totalExpenses;
    data['pending_expenses'] = this.pendingExpenses;
    data['approve_expenses'] = this.approveExpenses;
    data['mileage_fair'] = this.mileageFair;
    return data;
  }
}
