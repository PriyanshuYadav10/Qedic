import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:qedic/expenses/UpdateExpenses.dart';

import '../apis/app_exception.dart';
import '../model/LoginModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import 'AddExpenses.dart';
import 'ExpensesListModel.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Data_Expenses> expenses_list = <Data_Expenses>[];

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: Commons.Appbar_logo(false, context, "Expenses"),
        body: expenses_list.isEmpty ? _dataNotFound() : _expensesUI(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AddExpenses(),
              ),
            ).then((value) {
              getExpensess();
            });
          },
          backgroundColor: HexColor(HexColor.primarycolor),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _dataNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 220,
            child: Lottie.asset('images/data_not_found.json'),
          ),
          const SizedBox(height: 8),
          Text(
            "No expenses yet",
            style: TextStyle(
              fontSize: 16,
              color: HexColor(HexColor.black),
              fontFamily: 'montserrat_medium',
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Tap + to log your travel expense.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: HexColor(HexColor.gray_text),
                fontFamily: 'montserrat_regular',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusAccent(String? status) {
    final s = (status ?? '').toUpperCase().trim();
    if (s == 'PENDING') return HexColor(HexColor.yello1);
    if (s == 'APPROVE' || s == 'APPROVED') return HexColor(HexColor.green_txt);
    return HexColor(HexColor.red_color);
  }

  IconData _statusIcon(String? status) {
    final s = (status ?? '').toUpperCase().trim();
    if (s == 'PENDING') return Icons.hourglass_top_rounded;
    if (s == 'APPROVE' || s == 'APPROVED') return Icons.check_circle_rounded;
    return Icons.cancel_rounded;
  }

  num _totalAmount() {
    num total = 0;
    for (final e in expenses_list) {
      final v = num.tryParse(e.total_amount?.toString() ?? '');
      if (v != null) total += v;
    }
    return total;
  }

  int _statusCount(List<String> states) {
    return expenses_list.where((e) {
      final s = (e.status ?? '').toString().toUpperCase().trim();
      return states.contains(s);
    }).length;
  }

  Widget _summaryHeader() {
    final primary = HexColor(HexColor.primary_s);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Expense',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white70,
                    fontFamily: 'montserrat_regular',
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹ ${_totalAmount().toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'montserrat_bold',
                  ),
                ),
              ],
            ),
          ),
          _summaryChip(
              label: 'Pending', count: _statusCount(['PENDING'])),
          const SizedBox(width: 6),
          _summaryChip(
              label: 'Approved',
              count: _statusCount(['APPROVE', 'APPROVED'])),
        ],
      ),
    );
  }

  Widget _summaryChip({required String label, required int count}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontFamily: 'montserrat_bold',
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white70,
              fontFamily: 'montserrat_regular',
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expensesUI() {
    return Column(
      children: [
        _summaryHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 90),
            itemCount: expenses_list.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildExpenseCard(expenses_list[index]);
            },
          ),
        ),
      ],
    );
  }

  bool _isTappable(Data_Expenses item) {
    final s = (item.status ?? '').toString().toUpperCase();
    return s == "PENDING" || item.isEditable == "0";
  }

  Widget _buildExpenseCard(Data_Expenses item) {
    final accent = _statusAccent(item.status?.toString());
    final hasComment =
        item.adminComment != null && item.adminComment.toString().isNotEmpty;
    final statusLabel = (item.status ?? '').toString().toUpperCase();
    final amount = item.total_amount?.toString() ?? '0';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (_isTappable(item)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UpdateExpenses(data_expenses: item),
            ),
          ).then((_) => getExpensess());
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.directions_car_filled_rounded,
                          size: 20,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (item.travelPurpose ?? '').toString().isEmpty
                                  ? '—'
                                  : item.travelPurpose.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5,
                                color: HexColor(HexColor.black),
                                fontFamily: 'montserrat_bold',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (item.routeType ?? '').toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor(HexColor.gray_text),
                                fontFamily: 'montserrat_regular',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _statusPill(statusLabel, accent),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.currency_rupee_rounded,
                            size: 16, color: accent),
                        const SizedBox(width: 4),
                        Text(
                          amount,
                          style: TextStyle(
                            fontSize: 18,
                            color: accent,
                            fontFamily: 'montserrat_bold',
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today_rounded,
                            size: 13,
                            color: HexColor(HexColor.gray_text)),
                        const SizedBox(width: 4),
                        Text(
                          Commons.Date_format(
                              (item.selectDate ?? '').toString()),
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor(HexColor.gray_text),
                            fontFamily: 'montserrat_medium',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((item.visitName ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _infoRow(
                      icon: Icons.event_note_rounded,
                      label: 'Visit',
                      value: item.visitName?.toString(),
                    ),
                  ],
                  if ((item.fromLocation ?? '').toString().isNotEmpty ||
                      (item.toLocation ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _routeRow(
                      from: item.fromLocation?.toString() ?? '',
                      to: item.toLocation?.toString() ?? '',
                    ),
                  ],
                  if ((item.remark ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _infoRow(
                      icon: Icons.notes_rounded,
                      label: 'Remark',
                      value: item.remark?.toString(),
                    ),
                  ],
                  if (hasComment) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            HexColor(HexColor.red_color).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: HexColor(HexColor.red_color),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 14,
                              color: HexColor(HexColor.red_color)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.adminComment.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: HexColor(HexColor.red_color),
                                fontFamily: 'montserrat_medium',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String status, Color color) {
    final label = status.isEmpty ? '—' : status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontFamily: 'montserrat_medium',
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String? value,
  }) {
    final v = (value ?? '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: HexColor(HexColor.gray_text)),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: HexColor(HexColor.gray_text),
                fontFamily: 'montserrat_regular',
              ),
            ),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '—' : v,
              style: TextStyle(
                fontSize: 12.5,
                color: HexColor(HexColor.black),
                fontFamily: 'montserrat_medium',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeRow({required String from, required String to}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.alt_route_rounded,
              size: 15, color: HexColor(HexColor.gray_text)),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(
              'Route',
              style: TextStyle(
                fontSize: 11.5,
                color: HexColor(HexColor.gray_text),
                fontFamily: 'montserrat_regular',
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    from.isEmpty ? '—' : from,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: HexColor(HexColor.black),
                      fontFamily: 'montserrat_medium',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 12, color: HexColor(HexColor.gray_text)),
                ),
                Flexible(
                  child: Text(
                    to.isEmpty ? '—' : to,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: HexColor(HexColor.black),
                      fontFamily: 'montserrat_medium',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    getExpensess();
    super.initState();
  }

  getExpensess() async {
    LoginModel loginModel = await Commons.getuser_info();

    context.loaderOverlay.show();

    try {
      var request =
          http.MultipartRequest("POST", Uri.parse(Commons.viewExpenses));
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";

      print("sarjeet ${Commons.viewExpenses}");
      print("sarjeet ${request.fields}");

      var sendresponse = await request.send();

      var responseData = await sendresponse.stream.toBytes();
      var response = String.fromCharCodes(responseData);

      context.loaderOverlay.hide();
      print('sarjeet log  ${response}');

      if (response == null ||
          response.contains("A PHP Error was encountered") ||
          response.contains("<div") ||
          response.contains("</html")) {
        Commons.flushbar_Messege(context, "internal server Error ");
      } else {
        ExpensesListModel expensesListModel =
            ExpensesListModel.fromJson(jsonDecode(response));

        if (expensesListModel.status == 1) {
          setState(() {
            expenses_list = expensesListModel.data ?? <Data_Expenses>[];
          });
        } else {
          Commons.flushbar_Messege(context, expensesListModel.message!);
        }
      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }
}
