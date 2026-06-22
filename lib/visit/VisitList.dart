import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:qedic/visit/UpdateVisit.dart';
import '../apis/app_exception.dart';
import '../quotation/GenerateQuotation.dart';
import '../model/LoginModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import 'AddVisit.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import 'VisitListModel.dart';

class VisitList extends StatefulWidget {
  @override
  State<VisitList> createState() => _VisitListState();
}

class _VisitListState extends State<VisitList> {
  List<VisitListData> visitListData = <VisitListData>[];

  static const List<String> _modalityOptions = [
    'USG',
    'X-Ray/CT-Scan',
    'MRI',
    'Refurbished Equipment',
    'Other',
  ];
  static const List<String> _statusOptions = ['Active', 'Inactive'];
  static const List<String> _opptyTypeOptions = [
    'Hot',
    'Warm',
    'Cold',
    'Won',
    'Lost',
    'Abandoned',
  ];
  static const List<String> _forecastOptions = ['Yes', 'No'];

  String? _filterModality;
  String? _filterStatus;
  String? _filterOpptyType;
  String? _filterForecast;
  String _filterKeyword = '';
  final TextEditingController _keywordController = TextEditingController();

  bool get _hasActiveFilter =>
      (_filterModality?.isNotEmpty ?? false) ||
      (_filterStatus?.isNotEmpty ?? false) ||
      (_filterOpptyType?.isNotEmpty ?? false) ||
      (_filterForecast?.isNotEmpty ?? false) ||
      _filterKeyword.isNotEmpty;

  bool _matchesIgnoreCase(dynamic value, String target) {
    if (value == null) return false;
    final v = value.toString().toLowerCase().trim();
    final t = target.toLowerCase().trim();
    if (v == t) return true;
    if (t == 'lost' && v == 'loss') return true;
    if (t == 'loss' && v == 'lost') return true;
    return false;
  }

  bool _forecastMatches(dynamic raw, String want) {
    final v = (raw ?? '').toString().toLowerCase().trim();
    final isYes = v == '1' || v == 'yes' || v == 'true';
    return want == 'Yes' ? isYes : !isYes;
  }

  List<VisitListData> _filteredOpportunities() {
    if (!_hasActiveFilter) return visitListData;
    final kw = _filterKeyword.toLowerCase().trim();
    return visitListData.where((item) {
      if ((_filterModality?.isNotEmpty ?? false) &&
          !_matchesIgnoreCase(item.modality, _filterModality!)) {
        return false;
      }
      if ((_filterStatus?.isNotEmpty ?? false) &&
          !_matchesIgnoreCase(item.opportunityStatus, _filterStatus!)) {
        return false;
      }
      if ((_filterOpptyType?.isNotEmpty ?? false) &&
          !_matchesIgnoreCase(item.opptyType, _filterOpptyType!)) {
        return false;
      }
      if ((_filterForecast?.isNotEmpty ?? false) &&
          !_forecastMatches(item.forcast, _filterForecast!)) {
        return false;
      }
      if (kw.isNotEmpty) {
        final haystack = [
          item.custName,
          item.centerName,
          item.cityName,
          item.productName,
          item.contactNumber,
          item.opportunityId,
          item.email,
          item.address,
          item.district,
          item.opptyType,
          item.modality,
        ].map((e) => (e ?? '').toString().toLowerCase()).join(' ');
        if (!haystack.contains(kw)) return false;
      }
      return true;
    }).toList();
  }

  void _resetFilters() {
    _filterModality = null;
    _filterStatus = null;
    _filterOpptyType = null;
    _filterForecast = null;
    _filterKeyword = '';
    _keywordController.clear();
  }

  Color _opptyAccent(String? type) {
    final t = (type ?? '').toLowerCase().trim();
    if (t == 'hot') return const Color(0xFFEF4444);
    if (t == 'warm') return const Color(0xFFF59E0B);
    if (t == 'cold') return const Color(0xFF3B82F6);
    if (t == 'won') return const Color(0xFF10B981);
    if (t == 'lost' || t == 'loss') return const Color(0xFF6B7280);
    if (t == 'abandoned') return const Color(0xFF9CA3AF);
    return HexColor(HexColor.primary_s);
  }

  IconData _opptyIcon(String? type) {
    final t = (type ?? '').toLowerCase().trim();
    if (t == 'hot') return Icons.local_fire_department_rounded;
    if (t == 'warm') return Icons.wb_sunny_rounded;
    if (t == 'cold') return Icons.ac_unit_rounded;
    if (t == 'won') return Icons.emoji_events_rounded;
    if (t == 'lost' || t == 'loss') return Icons.cancel_rounded;
    if (t == 'abandoned') return Icons.do_not_disturb_on_rounded;
    return Icons.bolt_rounded;
  }

  String _initialsFor(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
  }

  bool _isForecastYes(dynamic raw) {
    final v = (raw ?? '').toString().toLowerCase().trim();
    return v == '1' || v == 'yes' || v == 'true';
  }

  void _handleFormReturn(dynamic result) {
    final wasOpportunity =
        result is Map && result['isOpportunity'] == true;
    setState(() {
      visitListData.clear();
      if (wasOpportunity) {
        visitOppt = true;
        _resetFilters();
        _filterStatus = 'Active';
        getVisitListAPI('oppo');
      } else {
        visitOppt = false;
        _resetFilters();
        getVisitListAPI('visit');
      }
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        child: Scaffold(
      backgroundColor: HexColor(HexColor.white),
      appBar: _buildAppBar(),
      body: visitListUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AddVisit(),
            ),
          ).then(_handleFormReturn);
        },
        backgroundColor: HexColor(HexColor.primarycolor),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    ));
  }

  bool visitOppt = false;
  Widget visitListUI() {
    final List<VisitListData> displayList =
        visitOppt ? _filteredOpportunities() : visitListData;
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildSegmentedTabs(),
          if (visitOppt && _hasActiveFilter)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: HexColor(HexColor.primary_s).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: HexColor(HexColor.primary_s).withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt_rounded,
                      size: 16, color: HexColor(HexColor.primary_s)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing ${displayList.length} of ${visitListData.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: HexColor(HexColor.primary_s),
                        fontFamily: 'montserrat_medium',
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(_resetFilters),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded,
                              size: 14,
                              color: HexColor(HexColor.primary_s)),
                          const SizedBox(width: 2),
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 12,
                              color: HexColor(HexColor.primary_s),
                              fontFamily: 'montserrat_medium',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: displayList.isEmpty
                ? dataNotFound()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                    itemCount: displayList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = displayList[index];
                      return visitOppt
                          ? _buildOpportunityCard(item)
                          : _buildVisitCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget dataNotFound() {
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
            visitOppt ? "No opportunities yet" : "No visits yet",
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
              visitOppt
                  ? "Tap + to log a new visit and mark it as an opportunity."
                  : "Tap + to log your first visit.",
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

  Widget _buildSegmentedTabs() {
    Widget tab({
      required String label,
      required IconData icon,
      required bool active,
      required VoidCallback onTap,
    }) {
      final primary = HexColor(HexColor.primary_s);
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: active ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: active ? Colors.white : HexColor(HexColor.gray_text),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: active ? Colors.white : HexColor(HexColor.gray_text),
                    fontFamily: 'montserrat_medium',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EF)),
      ),
      child: Row(
        children: [
          tab(
            label: 'Visits',
            icon: Icons.location_on_rounded,
            active: !visitOppt,
            onTap: () {
              setState(() {
                visitOppt = false;
                _resetFilters();
                getVisitListAPI('visit');
              });
            },
          ),
          const SizedBox(width: 4),
          tab(
            label: 'Opportunities',
            icon: Icons.trending_up_rounded,
            active: visitOppt,
            onTap: () {
              setState(() {
                visitOppt = true;
                _resetFilters();
                _filterStatus = 'Active';
                getVisitListAPI('oppo');
              });
            },
          ),
        ],
      ),
    );
  }

  bool _isTappable(VisitListData item) =>
      item.status == "Pending" || item.isEditable == "0";

  Widget _buildOpportunityCard(VisitListData item) {
    final accent = _opptyAccent(item.opptyType?.toString());
    final isPending = item.status == "Pending";
    final hasComment =
        item.adminComment != null && item.adminComment.toString().isNotEmpty;
    final showQuote = _matchesIgnoreCase(item.opptyType, 'Hot') ||
        _matchesIgnoreCase(item.opptyType, 'Warm');
    final forecastYes = _isForecastYes(item.forcast);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (_isTappable(item)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UpdateVisit(visitListData: item),
            ),
          ).then(_handleFormReturn);
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
                        child: Text(
                          _initialsFor(item.custName?.toString()),
                          style: TextStyle(
                            fontSize: 14,
                            color: accent,
                            fontFamily: 'montserrat_bold',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (item.custName ?? '').toString().isEmpty
                                  ? '—'
                                  : item.custName.toString(),
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
                              (item.centerName ?? '').toString(),
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
                      _opptyChip(item.opptyType?.toString(), accent),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            size: 14,
                            color: HexColor(HexColor.gray_text)),
                        const SizedBox(width: 6),
                        Text(
                          'OPP',
                          style: TextStyle(
                            fontSize: 11,
                            color: HexColor(HexColor.gray_text),
                            fontFamily: 'montserrat_medium',
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '#${item.opportunityId ?? ""}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: HexColor(HexColor.black),
                              fontFamily: 'montserrat_medium',
                            ),
                          ),
                        ),
                        Icon(Icons.calendar_today_rounded,
                            size: 13,
                            color: HexColor(HexColor.gray_text)),
                        const SizedBox(width: 4),
                        Text(
                          (item.date ?? '').toString(),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: HexColor(HexColor.gray_text),
                            fontFamily: 'montserrat_regular',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    icon: Icons.medical_services_outlined,
                    label: 'Product',
                    value: item.productName?.toString(),
                  ),
                  _infoRow(
                    icon: Icons.currency_rupee_rounded,
                    label: 'Value',
                    value: item.productValue?.toString(),
                  ),
                  _infoRow(
                    icon: Icons.phone_rounded,
                    label: 'Contact',
                    value: item.contactNumber?.toString(),
                  ),
                  _infoRow(
                    icon: forecastYes
                        ? Icons.event_available_rounded
                        : Icons.event_busy_rounded,
                    label: 'Forecast',
                    value: forecastYes ? 'Yes' : 'No',
                    valueColor: forecastYes
                        ? HexColor(HexColor.green_txt)
                        : HexColor(HexColor.gray_text),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _opportunityStatusPill(
                          item.opportunityStatus?.toString() ?? ''),
                      const Spacer(),
                      if (!_isTappable(item))
                        Icon(Icons.lock_outline_rounded,
                            size: 14,
                            color: HexColor(HexColor.gray_text)),
                    ],
                  ),
                  if (hasComment) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: HexColor(HexColor.red_color).withOpacity(0.08),
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
                  if (showQuote) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor(HexColor.primary_s),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  GenerateQuotation(visitListData: item),
                            ),
                          );
                        },
                        icon: const Icon(Icons.description_outlined,
                            size: 16),
                        label: const Text(
                          'Generate Quotation',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'montserrat_medium',
                          ),
                        ),
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

  Widget _buildVisitCard(VisitListData item) {
    final isPending = item.status == "Pending";
    final hasComment =
        item.adminComment != null && item.adminComment.toString().isNotEmpty;
    final primary = HexColor(HexColor.primary_s);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (_isTappable(item)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UpdateVisit(visitListData: item),
            ),
          ).then(_handleFormReturn);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _initialsFor(item.custName?.toString()),
                    style: TextStyle(
                      fontSize: 14,
                      color: primary,
                      fontFamily: 'montserrat_bold',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item.custName ?? '').toString().isEmpty
                            ? '—'
                            : item.custName.toString(),
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
                        (item.centerName ?? '').toString(),
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
                _statusPill(item.status?.toString() ?? '', isPending),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(
              icon: Icons.flag_outlined,
              label: 'Purpose',
              value: item.purpose?.toString(),
            ),
            _infoRow(
              icon: Icons.location_city_rounded,
              label: 'City',
              value: item.cityName?.toString(),
            ),
            _infoRow(
              icon: Icons.phone_rounded,
              label: 'Contact',
              value: item.contactNumber?.toString(),
            ),
            _infoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: item.date?.toString(),
            ),
            if (hasComment) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HexColor(HexColor.red_color).withOpacity(0.08),
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
                        size: 14, color: HexColor(HexColor.red_color)),
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
    );
  }

  Widget _opptyChip(String? type, Color accent) {
    final label = (type ?? '').toString();
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_opptyIcon(type), size: 12, color: accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: accent,
              fontFamily: 'montserrat_medium',
            ),
          ),
        ],
      ),
    );
  }

  Widget _opportunityStatusPill(String status) {
    final s = status.toLowerCase().trim();
    final isActive = s == 'active';
    final isInactive = s == 'inactive';
    final color = isActive
        ? HexColor(HexColor.green_txt)
        : isInactive
            ? HexColor(HexColor.gray_text)
            : HexColor(HexColor.yello1);
    final label = status.isEmpty ? 'Unknown' : status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: color,
              fontFamily: 'montserrat_medium',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status, bool isPending) {
    final color = isPending
        ? HexColor(HexColor.yello1)
        : HexColor(HexColor.green_txt);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.isEmpty ? '—' : status,
            style: TextStyle(
              fontSize: 11.5,
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
    Color? valueColor,
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
                color: valueColor ?? HexColor(HexColor.black),
                fontFamily: 'montserrat_medium',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    getVisitListAPI('visit');
    super.initState();
  }

  Future<void> _openAdvanceSearch() async {
    String? localModality = _filterModality;
    String? localStatus = _filterStatus;
    String? localOpptyType = _filterOpptyType;
    String? localForecast = _filterForecast;
    _keywordController.text = _filterKeyword;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              Widget buildDropdown({
                required String label,
                required String? value,
                required List<String> options,
                required ValueChanged<String?> onChanged,
              }) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'montserrat_medium',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: HexColor(HexColor.gray_text)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: value,
                            hint: Text('Select $label',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: HexColor(HexColor.gray_text),
                                )),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Any',
                                    style: TextStyle(fontSize: 13)),
                              ),
                              ...options.map((o) => DropdownMenuItem<String?>(
                                    value: o,
                                    child: Text(o,
                                        style: const TextStyle(fontSize: 13)),
                                  )),
                            ],
                            onChanged: onChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Advance Search',
                            style: TextStyle(
                              fontSize: 16,
                              color: HexColor(HexColor.primarycolor),
                              fontFamily: 'montserrat_bold',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(sheetContext).pop(),
                          ),
                        ],
                      ),
                    ),
                    buildDropdown(
                      label: 'Modality',
                      value: localModality,
                      options: _modalityOptions,
                      onChanged: (v) => setSheetState(() => localModality = v),
                    ),
                    buildDropdown(
                      label: 'Status',
                      value: localStatus,
                      options: _statusOptions,
                      onChanged: (v) => setSheetState(() => localStatus = v),
                    ),
                    buildDropdown(
                      label: 'Opportunity Type',
                      value: localOpptyType,
                      options: _opptyTypeOptions,
                      onChanged: (v) =>
                          setSheetState(() => localOpptyType = v),
                    ),
                    buildDropdown(
                      label: 'Forecast',
                      value: localForecast,
                      options: _forecastOptions,
                      onChanged: (v) => setSheetState(() => localForecast = v),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keyword Search',
                            style: TextStyle(
                              fontSize: 13,
                              color: HexColor(HexColor.primarycolor),
                              fontFamily: 'montserrat_medium',
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _keywordController,
                            decoration: InputDecoration(
                              hintText:
                                  'Search by customer, center, city, product…',
                              prefixIcon: const Icon(Icons.search),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  localModality = null;
                                  localStatus = null;
                                  localOpptyType = null;
                                  localForecast = null;
                                  _keywordController.clear();
                                });
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    HexColor(HexColor.primarycolor),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _filterModality = localModality;
                                  _filterStatus = localStatus;
                                  _filterOpptyType = localOpptyType;
                                  _filterForecast = localForecast;
                                  _filterKeyword =
                                      _keywordController.text.trim();
                                });
                                Navigator.of(sheetContext).pop();
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final showDownload = visitOppt && visitListData.isNotEmpty;
    final showSearch = visitOppt;
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        title: Container(
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          height: 50,
          child: Image(
            height: 80,
            width: 80,
            color: Colors.white,
            image: AssetImage('images/q_logo.png'),
          ),
        ),
        centerTitle: true,
        backgroundColor: HexColor(HexColor.primary_s),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: !showSearch && !showDownload
            ? null
            : [
                if (showSearch)
                  IconButton(
                    tooltip: 'Advance Search',
                    onPressed: _openAdvanceSearch,
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.search, color: Colors.white),
                        if (_hasActiveFilter)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (showDownload)
                  PopupMenuButton<String>(
                  tooltip: 'Download',
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'excel') {
                      _downloadOpportunities('excel');
                    } else if (value == 'pdf') {
                      _downloadOpportunities('pdf');
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'excel',
                      child: Row(
                        children: [
                          Icon(Icons.grid_on, color: Colors.green),
                          SizedBox(width: 10),
                          Text('Download as Excel'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Download as PDF'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: HexColor(HexColor.primary_s),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
      ),
    );
  }

  static const List<String> _opportunityHeaders = [
    'Opportunity ID',
    'Customer Name',
    'Center Name',
    'City',
    'Contact Number',
    'Product Name',
    'Opportunity Type',
    'Product Value',
    'Forecast',
    'Status',
    'Date',
    'Admin Comment',
  ];

  List<String> _opportunityRow(VisitListData item) {
    return [
      item.opportunityId?.toString() ?? '',
      item.custName?.toString() ?? '',
      item.centerName?.toString() ?? '',
      item.cityName?.toString() ?? '',
      item.contactNumber?.toString() ?? '',
      item.productName?.toString() ?? '',
      item.opptyType?.toString() ?? '',
      item.productValue?.toString() ?? '',
      item.forcast?.toString() ?? '',
      item.status?.toString() ?? '',
      item.date?.toString() ?? '',
      item.adminComment?.toString() ?? '',
    ];
  }

  Future<bool> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final storage = await Permission.storage.request();
    if (storage.isGranted || storage.isLimited) return true;

    final manage = await Permission.manageExternalStorage.request();
    return manage.isGranted || manage.isLimited;
  }

  Future<Directory> _resolveDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) return downloads;
      final external = await getExternalStorageDirectory();
      if (external != null) return external;
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<void> _downloadOpportunities(String format) async {
    final rows = _filteredOpportunities();
    if (rows.isEmpty) {
      Commons.flushbar_Messege(context, 'No opportunities to download');
      return;
    }

    final granted = await _ensureStoragePermission();
    if (!granted) {
      Commons.flushbar_Messege(context, 'Storage permission required');
      return;
    }

    context.loaderOverlay.show();
    try {
      final dir = await _resolveDownloadsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      late File outFile;

      if (format == 'excel') {
        outFile = File('${dir.path}/opportunities_$timestamp.xlsx');
        final bytes = _buildOpportunityExcelBytes(rows);
        await outFile.writeAsBytes(bytes, flush: true);
      } else {
        outFile = File('${dir.path}/opportunities_$timestamp.pdf');
        final bytes = await _buildOpportunityPdfBytes(rows);
        await outFile.writeAsBytes(bytes, flush: true);
      }

      if (!mounted) return;
      context.loaderOverlay.hide();
      Commons.Fluttertoast_Messege(
        context,
        'Saved to: ${outFile.path}',
      );
    } catch (e) {
      if (mounted) context.loaderOverlay.hide();
      if (mounted) {
        Commons.flushbar_Messege(context, 'Download failed: $e');
      }
    }
  }

  List<int> _buildOpportunityExcelBytes(List<VisitListData> rows) {
    final excel = ex.Excel.createExcel();
    final sheetName = 'Opportunities';
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    sheet.appendRow(
      _opportunityHeaders.map((h) => ex.TextCellValue(h)).toList(),
    );

    for (final item in rows) {
      sheet.appendRow(
        _opportunityRow(item).map((c) => ex.TextCellValue(c)).toList(),
      );
    }

    final defaultSheets = excel.sheets.keys
        .where((name) => name != sheetName)
        .toList();
    for (final name in defaultSheets) {
      excel.delete(name);
    }

    final saved = excel.save();
    return saved ?? <int>[];
  }

  Future<Uint8List> _buildOpportunityPdfBytes(List<VisitListData> rows) async {
    final pdf = pw.Document();
    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 9,
      color: PdfColors.white,
    );
    final cellStyle = const pw.TextStyle(fontSize: 8);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Opportunities',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Generated: ${DateTime.now()}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: headerStyle,
            cellStyle: cellStyle,
            headerDecoration: pw.BoxDecoration(color: PdfColors.blueGrey700),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 3,
            ),
            headers: _opportunityHeaders,
            data: rows.map(_opportunityRow).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  //creat methode retune String capitliase
  // String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  getVisitListAPI(visitOpptType) async {
    LoginModel loginModel = await Commons.getuser_info();

    context.loaderOverlay.show();

    try {
      visitListData.clear();
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.viewVisit));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
      request.fields["visit"] = visitOpptType;

      print("sarjeet ${Commons.viewVisit}");
      print("sarjeet ${request.fields}");
      //add headers
      
      var sendresponse = await request.send();

      //Get the response from the server
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
        VisitListModel visitListModel =
            VisitListModel.fromJson(jsonDecode(response));

        // Commons.flushbar_Messege(context, visitListModel.message ?? "");

        if (visitListModel.status == 1) {
          setState(() {
            visitListData = visitListModel.data ?? <VisitListData>[];
            // print("sarjeetw ${visitListData[7].centerName} ");
          });
        } else {
          Commons.flushbar_Messege(context, visitListModel.message!);
        }
      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }
}
