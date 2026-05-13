import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qedic/employee_goal/AddEmployeeGoal.dart';
import 'package:qedic/employee_goal/EmployeeGoalApi.dart';
import 'package:qedic/employee_goal/EmployeeGoalModels.dart';
import 'package:qedic/employee_goal/EmployeeGoalWidgets.dart';
import 'package:qedic/model/LoginModel.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';

class EmployeeGoal extends StatefulWidget {
  const EmployeeGoal({super.key});

  @override
  State<EmployeeGoal> createState() => _EmployeeGoalState();
}

class _EmployeeGoalState extends State<EmployeeGoal> {
  final EmployeeGoalApi _api = EmployeeGoalApi();
  final List<GoalHeader> _headers = [];
  LoginModel? _login;
  int _goalUserId = 0;

  int get _userId => _goalUserId;

  String get _employeeName {
    final name =
        '${_login?.data?.firstName ?? ''} ${_login?.data?.lastName ?? ''}'
            .trim();
    return name.isEmpty ? 'Employee' : name;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final login = await Commons.getuser_info();
      final goalUserId = await _api.resolveGoalUserId(login.data);
      if (!mounted) return;
      setState(() {
        _login = login;
        _goalUserId = goalUserId;
      });
      await _getGoals();
    } catch (e) {
      if (mounted) Commons.flushbar_Messege(context, '$e');
    }
  }

  Future<void> _getGoals() async {
    if (_userId == 0) return;
    context.loaderOverlay.show();
    try {
      final goals = await _api.getGoals(_userId);
      if (mounted) {
        setState(() {
          _headers
            ..clear()
            ..addAll(goals);
        });
      }
    } catch (e) {
      if (mounted) Commons.flushbar_Messege(context, '$e');
    } finally {
      if (mounted) context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: HexColor(HexColor.white),
        appBar: Commons.Appbar_logo(false, context, 'Employee Goal'),
        body: RefreshIndicator(
          color: HexColor(HexColor.primarycolor),
          onRefresh: _getGoals,
          child: _headers.isEmpty ? _dataNotFound() : _goalList(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: HexColor(HexColor.primarycolor),
          onPressed: _addGoal,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _dataNotFound() {
    return ListView(
      children: [
        Container(child: Lottie.asset('images/data_not_found.json')),
        Text(
          'No Goal Found',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: HexColor(HexColor.black),
            fontFamily: 'montserrat_regular',
          ),
        ),
      ],
    );
  }

  Widget _goalList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 85),
      itemCount: _headers.length,
      itemBuilder: (context, index) {
        final header = _headers[index];
        return InkWell(
          onTap: header.signOffApproved
              ? () => _downloadGoalPdf(header)
              : () => _handleHeaderTap(header),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 1,
                  color: Colors.grey,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: EmployeeGoalInfoRow(
                        icon: Icons.flag,
                        iconColor: HexColor(HexColor.primarycolor),
                        text:
                            '${header.reviewYear} ${header.reviewQuarter} Goals',
                      ),
                    ),
                    EmployeeGoalStatusChip(
                      label: header.statusLabel,
                      highlight: header.actionFlags.highlight,
                    ),
                  ],
                ),
                EmployeeGoalInfoRow(
                  icon: Icons.list_alt,
                  iconColor: HexColor(HexColor.primarycolor),
                  text: '${header.goals.length} goals added',
                ),
                Row(
                  children: [
                    Expanded(
                      child: EmployeeGoalInfoRow(
                        icon: Icons.timeline,
                        text: header.displayStage,
                        iconSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: EmployeeGoalInfoRow(
                        icon: Icons.verified,
                        text: header.overallStatus.isEmpty
                            ? header.statusLabel
                            : header.overallStatus,
                        iconSize: 18,
                      ),
                    ),
                  ],
                ),
                if (header.goals.isNotEmpty)
                  EmployeeGoalInfoRow(
                    icon: Icons.check_circle_outline,
                    text: header.goals
                        .take(3)
                        .map((goal) => goal.goalName)
                        .join(', '),
                    iconSize: 18,
                  ),
                if (header.activeState?.lastRejectComment?.isNotEmpty == true)
                  EmployeeGoalInfoRow(
                    icon: Icons.info,
                    iconColor: HexColor(HexColor.red_color),
                    text: header.activeState!.lastRejectComment!,
                    iconSize: 18,
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: EmployeeGoalPrimaryButton(
                        text: header.signOffApproved ? 'Download PDF' : 'Open',
                        icon: header.signOffApproved
                            ? Icons.picture_as_pdf
                            : Icons.open_in_new,
                        onPressed: header.signOffApproved
                            ? () => _downloadGoalPdf(header)
                            : () => _handleHeaderTap(header),
                      ),
                    ),
                    if (header.goalSettingEditable) ...[
                      // const SizedBox(width: 8),
                      // Expanded(
                      //   child: EmployeeGoalPrimaryButton(
                      //     text: 'Edit',
                      //     icon: Icons.edit,
                      //     onPressed: () => _editGoalSetting(header),
                      //   ),
                      // ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: EmployeeGoalPrimaryButton(
                          text: 'Submit',
                          icon: Icons.send,
                          onPressed: () => _submitGoalSetting(header),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addGoal() async {
    GoalHeader? draftHeader;
    for (final header in _headers) {
      if (header.goalSettingEditable) {
        draftHeader = header;
        break;
      }
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEmployeeGoal(
          initialGoals: List<GoalRecord>.from(draftHeader?.goals ?? const []),
          header: draftHeader,
        ),
      ),
    );
    if (!mounted || _userId == 0) return;

    final goalSetResult = result is GoalSetResult
        ? result
        : result is List<GoalRecord>
        ? GoalSetResult(goals: result, action: GoalSetAction.save)
        : result is GoalRecord
        ? GoalSetResult(
            goals: [...?draftHeader?.goals, result],
            action: GoalSetAction.save,
          )
        : null;
    final goals = goalSetResult?.goals;
    if (goals == null) return;

    context.loaderOverlay.show();
    try {
      final goalHeaderId = await _api.saveGoals(
        userId: _userId,
        reviewYear: DateTime.now().year,
        reviewQuarter: kReviewQuarters.first,
        goalHeaderId: draftHeader?.goalHeaderId,
        goals: goals,
      );
      if (goalSetResult!.action == GoalSetAction.submit) {
        await _submitGoalHeaderById(goalHeaderId);
        if (mounted) {
          Commons.Fluttertoast_Messege(context, 'Submitted for approval');
        }
      } else if (mounted) {
        Commons.Fluttertoast_Messege(context, 'Goal saved');
      }
      await _getGoals();
    } catch (e) {
      if (mounted) Commons.flushbar_Messege(context, '$e');
    } finally {
      if (mounted) context.loaderOverlay.hide();
    }
  }

  Future<void> _handleHeaderTap(GoalHeader header) async {
    log(
      'Header tapped: ${header.reviewYear} ${header.reviewQuarter} - Status: ${header.overallStatus}',
    );
    if (header.activeSection == 'completed') {
      Commons.Fluttertoast_Messege(context, 'Goal flow completed');
      return;
    }

    if (isGoalSettingSection(header.activeSection)) {
      if (header.goalSettingEditable) {
        await _editGoalSetting(header);
      } else {
        Commons.Fluttertoast_Messege(context, header.statusLabel);
      }
      return;
    }

    if (!header.currentSectionOpen) {
      Commons.Fluttertoast_Messege(context, header.statusLabel);
      return;
    }

    final goal = header.goals.isNotEmpty ? header.goals.first : null;
    if (goal == null) {
      Commons.Fluttertoast_Messege(context, 'No goals found');
      return;
    }

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeGoalStatusForm(
          api: _api,
          userId: _userId,
          header: header,
          goal: goal,
          employeeName: _employeeName,
        ),
      ),
    );
    if (updated == true) {
      await _getGoals();
    }
  }

  Future<void> _editGoalSetting(GoalHeader header) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEmployeeGoal(
          initialGoals: List<GoalRecord>.from(header.goals),
          header: header,
        ),
      ),
    );
    final goalSetResult = result is GoalSetResult
        ? result
        : result is List<GoalRecord>
        ? GoalSetResult(goals: result, action: GoalSetAction.save)
        : null;
    if (goalSetResult != null) {
      final savedHeaderId = await _saveGoalSet(header, goalSetResult.goals);
      if (goalSetResult.action == GoalSetAction.submit &&
          savedHeaderId != null) {
        await _submitGoalSetting(header);
      }
    }
  }

  Future<int?> _saveGoalSet(GoalHeader header, List<GoalRecord> goals) async {
    context.loaderOverlay.show();
    try {
      final goalHeaderId = await _api.saveGoals(
        userId: _userId,
        reviewYear: header.reviewYear,
        reviewQuarter: header.reviewQuarter,
        goalHeaderId: header.goalHeaderId,
        goals: goals,
      );
      await _getGoals();
      return goalHeaderId;
    } catch (e) {
      if (mounted) Commons.flushbar_Messege(context, '$e');
      return null;
    } finally {
      if (mounted) context.loaderOverlay.hide();
    }
  }

  Future<void> _submitGoalSetting(GoalHeader header) async {
    if (!header.goalSettingEditable) {
      Commons.Fluttertoast_Messege(context, header.statusLabel);
      return;
    }
    context.loaderOverlay.show();
    try {
      await _api.submitGoals(
        userId: _userId,
        goalHeaderId: header.goalHeaderId,
      );
      if (mounted) {
        Commons.Fluttertoast_Messege(context, 'Submitted for approval');
      }
      await _getGoals();
    } catch (e) {
      if (mounted) Commons.flushbar_Messege(context, '$e');
    } finally {
      if (mounted) context.loaderOverlay.hide();
    }
  }

  Future<void> _submitGoalHeaderById(int? goalHeaderId) async {
    final resolvedHeaderId = goalHeaderId ?? await _resolveSavedGoalHeaderId();
    if (resolvedHeaderId == null || resolvedHeaderId == 0) {
      throw Exception('Goal saved, but goal header id was not found');
    }
    await _api.submitGoals(userId: _userId, goalHeaderId: resolvedHeaderId);
  }

  Future<int?> _resolveSavedGoalHeaderId() async {
    final headers = await _api.getGoals(_userId);
    for (final header in headers) {
      if (header.goalSettingEditable) {
        return header.goalHeaderId;
      }
    }
    return headers.isEmpty ? null : headers.first.goalHeaderId;
  }

  Future<void> _downloadGoalPdf(GoalHeader header) async {
    context.loaderOverlay.show();
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                '${header.reviewYear} ${header.reviewQuarter} Goal Review',
              ),
            ),
            _pdfLine('Employee', _employeeName),
            _pdfLine('Status', header.statusLabel),
            _pdfLine('Review Year', '${header.reviewYear}'),
            _pdfLine('Review Quarter', header.reviewQuarter),
            pw.SizedBox(height: 10),
            pw.Header(level: 1, child: pw.Text('Goals')),
            ...header.goals.map(
              (goal) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _pdfLine('Goal', goal.goalName),
                  _pdfLine('Description', goal.goalDescription),
                  _pdfLine('Type', goal.goalType),
                  _pdfLine('Priority', goal.priority),
                  _pdfLine('Target Completion', goal.targetCompletion),
                  pw.SizedBox(height: 8),
                ],
              ),
            ),
            if (header.overallSummary != null) ...[
              pw.Header(level: 1, child: pw.Text('Overall Summary')),
              _pdfLine(
                'Employee Self Evaluation',
                header.overallSummary!.employeeSelfEvaluation,
              ),
              _pdfLine('Final Rating', header.overallSummary!.finalRating),
            ],
            if (header.developmentRows.isNotEmpty) ...[
              pw.Header(level: 1, child: pw.Text('Development Plan')),
              ...header.developmentRows.map(
                (plan) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfLine('Area of Development', plan.areaOfDevelopment),
                    _pdfLine('Action Plan', plan.actionPlan),
                    _pdfLine('Support Needed', plan.supportNeeded),
                    _pdfLine('Target Completion', plan.targetCompletionDate),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ),
            ],
            pw.Header(level: 1, child: pw.Text('Sign-Off')),
            _pdfLine(
              'Employee Name',
              header.signoff?.employeeName ?? _employeeName,
            ),
            _pdfLine(
              'Employee Sign Date',
              header.signoff?.employeeSignDate ?? '',
            ),
            _pdfLine('Manager Name', header.signoff?.managerName ?? ''),
            _pdfLine('HR/Director Name', header.signoff?.hrDirectorName ?? ''),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/employee_goal_${header.goalHeaderId}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());
      if (mounted) {
        Commons.Fluttertoast_Messege(context, 'PDF downloaded: ${file.path}');
      }
    } catch (e) {
      if (mounted) Commons.flushbar_Messege(context, '$e');
    } finally {
      if (mounted) context.loaderOverlay.hide();
    }
  }

  pw.Widget _pdfLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: value.isEmpty ? '-' : value),
          ],
        ),
      ),
    );
  }
}

class EmployeeGoalStatusForm extends StatefulWidget {
  const EmployeeGoalStatusForm({
    super.key,
    required this.api,
    required this.userId,
    required this.header,
    required this.goal,
    required this.employeeName,
  });

  final EmployeeGoalApi api;
  final int userId;
  final GoalHeader header;
  final GoalRecord goal;
  final String employeeName;

  @override
  State<EmployeeGoalStatusForm> createState() => _EmployeeGoalStatusFormState();
}

class _EmployeeGoalStatusFormState extends State<EmployeeGoalStatusForm> {
  final _formKey = GlobalKey<FormState>();
  final _progressSummary = TextEditingController();
  final _challenges = TextEditingController();
  final _adjustmentMade = TextEditingController();
  final _managerComments = TextEditingController();
  final _evidenceComments = TextEditingController();
  final _employeeSelfEvaluation = TextEditingController();
  final _managerAppraisalSummary = TextEditingController();
  final _areaOfDevelopment = TextEditingController();
  final _actionPlan = TextEditingController();
  final _supportNeeded = TextEditingController();
  final _targetCompletionDate = TextEditingController();
  final _employeeName = TextEditingController();
  final _managerName = TextEditingController();
  final _hrDirectorName = TextEditingController();
  final List<Offset?> _signaturePoints = [];
  Size _signatureSize = Size.zero;
  String _achievementLevel = kAchievementLevels.first;
  String _employeeSelfRating = kPerformanceRatings.first;
  String _managerRating = kPerformanceRatings.first;
  String _finalRating = kFinalRatings.first;

  String get _section => legacyGoalSection(widget.header.activeSection);

  @override
  void initState() {
    super.initState();
    _employeeName.text = widget.employeeName;
    _hydrateExistingData();
  }

  void _hydrateExistingData() {
    MidYearReview? mid;
    for (final row in widget.header.midyearRows) {
      if (row.goalId == widget.goal.id) {
        mid = row;
        break;
      }
    }
    if (mid != null) {
      _progressSummary.text = mid.progressSummary;
      _challenges.text = mid.challenges;
      _adjustmentMade.text = mid.adjustmentMade;
      _managerComments.text = mid.managerComments ?? '';
    }

    EndYearEvaluation? end;
    for (final row in widget.header.endyearRows) {
      if (row.goalId == widget.goal.id) {
        end = row;
        break;
      }
    }
    if (end != null) {
      _achievementLevel = end.achievementLevel.isEmpty
          ? _achievementLevel
          : end.achievementLevel;
      _evidenceComments.text = end.evidenceComments;
      _employeeSelfRating = end.employeeSelfRating.isEmpty
          ? _employeeSelfRating
          : end.employeeSelfRating;
      _managerRating = end.managerRating ?? _managerRating;
    }

    final summary = widget.header.overallSummary;
    if (summary != null) {
      _employeeSelfEvaluation.text = summary.employeeSelfEvaluation;
      _managerAppraisalSummary.text = summary.managerAppraisalSummary ?? '';
      _finalRating = summary.finalRating.isEmpty
          ? _finalRating
          : summary.finalRating;
    }

    if (widget.header.developmentRows.isNotEmpty) {
      final plan = widget.header.developmentRows.first;
      _areaOfDevelopment.text = plan.areaOfDevelopment;
      _actionPlan.text = plan.actionPlan;
      _supportNeeded.text = plan.supportNeeded;
      _targetCompletionDate.text = plan.targetCompletionDate;
    }

    final signoff = widget.header.signoff;
    if (signoff != null) {
      _employeeName.text = signoff.employeeName ?? widget.employeeName;
      _managerName.text = signoff.managerName ?? '';
      _hrDirectorName.text = signoff.hrDirectorName ?? '';
    }
  }

  @override
  void dispose() {
    _progressSummary.dispose();
    _challenges.dispose();
    _adjustmentMade.dispose();
    _managerComments.dispose();
    _evidenceComments.dispose();
    _employeeSelfEvaluation.dispose();
    _managerAppraisalSummary.dispose();
    _areaOfDevelopment.dispose();
    _actionPlan.dispose();
    _supportNeeded.dispose();
    _targetCompletionDate.dispose();
    _employeeName.dispose();
    _managerName.dispose();
    _hrDirectorName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: HexColor(HexColor.white),
        appBar: Commons.Appbar_logo(true, context, widget.header.displayStage),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              EmployeeGoalInfoRow(
                icon: Icons.flag,
                iconColor: HexColor(HexColor.primarycolor),
                text: widget.goal.goalName,
              ),
              const SizedBox(height: 8),
              ..._fieldsForSection(),
              const SizedBox(height: 15),
              if (_hasSaveAction) ...[
                EmployeeGoalPrimaryButton(
                  text: 'Save',
                  icon: Icons.save,
                  onPressed: _saveDraft,
                ),
                const SizedBox(height: 10),
              ],
              EmployeeGoalPrimaryButton(
                text: _section == 'section7' ? 'Submit Sign Off' : 'Submit',
                icon: Icons.check,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasSaveAction =>
      _section == 'section3' ||
      _section == 'section4' ||
      _section == 'section5' ||
      _section == 'section6';

  List<Widget> _fieldsForSection() {
    switch (_section) {
      case 'section3':
        return [
          _textField('Progress Summary', _progressSummary, maxLines: 3),
          _textField('Challenges', _challenges, maxLines: 3),
          _textField('Adjustment Made', _adjustmentMade, maxLines: 3),
          _textField('Manager Comments', _managerComments, maxLines: 3),
        ];
      case 'section4':
        return [
          _dropdown(
            'Achievement Level',
            _achievementLevel,
            kAchievementLevels,
            (v) => setState(() => _achievementLevel = v),
          ),
          _textField('Evidence/Comments', _evidenceComments, maxLines: 3),
          _dropdown(
            'Employee Self-Rating',
            _employeeSelfRating,
            kPerformanceRatings,
            (v) => setState(() => _employeeSelfRating = v),
          ),
          _dropdown(
            'Manager Rating',
            _managerRating,
            kPerformanceRatings,
            (v) => setState(() => _managerRating = v),
          ),
        ];
      case 'section5':
        return [
          _sectionText(
            'Employee Self-Evaluation:',
            'Summary of overall performance, learnings, and areas for development.',
          ),
          _textField('Summary', _employeeSelfEvaluation, maxLines: 4),
          _sectionText(
            'Manager\'s Appraisal Summary:',
            'Overview of performance, goal attainment, strengths, and areas for improvement.',
          ),
          _textField('Overview', _managerAppraisalSummary, maxLines: 4),
          _dropdown(
            'Final Rating',
            _finalRating,
            kFinalRatings,
            (v) => setState(() => _finalRating = v),
          ),
        ];
      case 'section6':
        return [
          _textField('Area of Development', _areaOfDevelopment, maxLines: 2),
          _textField('Action Plan', _actionPlan, maxLines: 3),
          _textField('Support Needed', _supportNeeded, maxLines: 3),
          _dateField('Target Completion Date', _targetCompletionDate),
        ];
      case 'section7':
        return [
          _readOnlyTextField('Employee Name', _employeeName),
          _signatureField(),
        ];
      default:
        return [
          Text(
            'This section is waiting for approval.',
            style: TextStyle(
              fontSize: 14,
              color: HexColor(HexColor.gray_text),
              fontFamily: 'montserrat_regular',
            ),
          ),
        ];
    }
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: EmployeeGoalFieldCard(
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter $label' : null,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _readOnlyTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: EmployeeGoalFieldCard(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter $label' : null,
          style: TextStyle(
            color: HexColor(HexColor.black),
            fontFamily: 'montserrat_medium',
          ),
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            suffixIcon: Icon(
              Icons.lock_outline,
              color: HexColor(HexColor.gray),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signatureField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(blurRadius: 1, color: Colors.grey, offset: Offset(0, 0)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Employee Signature',
                    style: TextStyle(
                      fontSize: 13,
                      color: HexColor(HexColor.black),
                      fontFamily: 'montserrat_medium',
                    ),
                  ),
                ),
                if (_signaturePoints.isNotEmpty)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.refresh,
                      color: HexColor(HexColor.primary_s),
                    ),
                    onPressed: () => setState(_signaturePoints.clear),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const height = 170.0;
                _signatureSize = Size(width, height);
                return GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _signaturePoints.add(
                        _clampSignaturePoint(details.localPosition),
                      );
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _signaturePoints.add(
                        _clampSignaturePoint(details.localPosition),
                      );
                    });
                  },
                  onPanEnd: (_) {
                    setState(() => _signaturePoints.add(null));
                  },
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: HexColor(HexColor.gray_activity_background),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                        color: HexColor(
                          HexColor.primary_s,
                        ).withValues(alpha: 0.35),
                      ),
                    ),
                    child: CustomPaint(
                      painter: _SignaturePainter(
                        points: _signaturePoints,
                        color: HexColor(HexColor.black),
                      ),
                      child: _signaturePoints.isEmpty
                          ? Center(
                              child: Text(
                                'Draw signature here',
                                style: TextStyle(
                                  color: HexColor(HexColor.gray_text),
                                  fontFamily: 'montserrat_regular',
                                ),
                              ),
                            )
                          : const SizedBox.expand(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    final selected = items.contains(value) ? value : items.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: EmployeeGoalFieldCard(
        child: DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: EmployeeGoalFieldCard(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Select $label' : null,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 5),
            );
            if (picked != null) {
              controller.text = Commons.Date_format5(picked.toString());
            }
          },
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            suffixIcon: Icon(
              Icons.calendar_today,
              color: HexColor(HexColor.primary_s),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionText(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: HexColor(HexColor.black),
              fontFamily: 'montserrat_medium',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: HexColor(HexColor.gray_text),
              fontFamily: 'montserrat_regular',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_section == 'section7' && !_hasSignature) {
      Commons.Fluttertoast_Messege(context, 'Please draw your signature');
      return;
    }

    context.loaderOverlay.show();
    try {
      await _saveCurrentSection();
      switch (_section) {
        case 'section3':
          await widget.api.submitMidyear(
            userId: widget.userId,
            goalHeaderId: widget.header.goalHeaderId,
          );
          break;
        case 'section4':
          await widget.api.submitEndyear(
            userId: widget.userId,
            goalHeaderId: widget.header.goalHeaderId,
          );
          break;
        case 'section5':
          await widget.api.submitOverall(
            userId: widget.userId,
            goalHeaderId: widget.header.goalHeaderId,
          );
          break;
        case 'section6':
          await widget.api.submitDevelopment(
            userId: widget.userId,
            goalHeaderId: widget.header.goalHeaderId,
            rows: [
              {
                'area_for_development': _areaOfDevelopment.text.trim(),
                'action_plan': _actionPlan.text.trim(),
                'support_needed': _supportNeeded.text.trim(),
                'target_completion_date': _targetCompletionDate.text.trim(),
              },
            ],
          );
          break;
        case 'section7':
          await widget.api.submitEmployeeSignoff(
            userId: widget.userId,
            goalHeaderId: widget.header.goalHeaderId,
            signaturePath: _buildSignatureBlob(),
            signDate: Commons.Date_format5(DateTime.now().toString()),
          );
          break;
      }
      if (mounted) {
        Commons.Fluttertoast_Messege(context, 'Submitted for approval');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) Commons.flushbar_Messege(context, '$e');
    } finally {
      if (mounted) context.loaderOverlay.hide();
    }
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;

    context.loaderOverlay.show();
    try {
      await _saveCurrentSection();
      if (mounted) {
        Commons.Fluttertoast_Messege(context, 'Saved');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) Commons.flushbar_Messege(context, '$e');
    } finally {
      if (mounted) context.loaderOverlay.hide();
    }
  }

  Future<void> _saveCurrentSection() async {
    switch (_section) {
      case 'section3':
        await widget.api.saveMidyear(
          userId: widget.userId,
          goalHeaderId: widget.header.goalHeaderId,
          rows: [
            {
              'goal_id': widget.goal.id,
              'progress_summary': _progressSummary.text.trim(),
              'challenges': _challenges.text.trim(),
              'adjustments_made': _adjustmentMade.text.trim(),
            },
          ],
        );
        break;
      case 'section4':
        await widget.api.saveEndyear(
          userId: widget.userId,
          goalHeaderId: widget.header.goalHeaderId,
          rows: [
            {
              'goal_id': widget.goal.id,
              'achievement_level': _achievementLevel,
              'evidence_comment': _evidenceComments.text.trim(),
              'employee_self_rating': _employeeSelfRating,
            },
          ],
        );
        break;
      case 'section5':
        await widget.api.saveOverall(
          userId: widget.userId,
          goalHeaderId: widget.header.goalHeaderId,
          employeeSelfEvaluation: _employeeSelfEvaluation.text.trim(),
          finalRating: _finalRating,
        );
        break;
      case 'section6':
        await widget.api.saveDevelopment(
          userId: widget.userId,
          goalHeaderId: widget.header.goalHeaderId,
          rows: [
            {
              'area_for_development': _areaOfDevelopment.text.trim(),
              'action_plan': _actionPlan.text.trim(),
              'support_needed': _supportNeeded.text.trim(),
              'target_completion_date': _targetCompletionDate.text.trim(),
            },
          ],
        );
        break;
    }
  }

  bool get _hasSignature =>
      _signaturePoints.whereType<Offset>().length >= 2 &&
      _signatureSize.width > 0 &&
      _signatureSize.height > 0;

  Offset _clampSignaturePoint(Offset point) {
    return Offset(
      point.dx.clamp(0.0, _signatureSize.width),
      point.dy.clamp(0.0, _signatureSize.height),
    );
  }

  String _buildSignatureBlob() {
    final width = _signatureSize.width <= 0 ? 320.0 : _signatureSize.width;
    final height = _signatureSize.height <= 0 ? 170.0 : _signatureSize.height;
    final paths = <String>[];
    final current = <Offset>[];

    void flushPath() {
      if (current.length < 2) {
        current.clear();
        return;
      }
      final points = current
          .map(
            (point) =>
                '${point.dx.toStringAsFixed(1)},${point.dy.toStringAsFixed(1)}',
          )
          .join(' ');
      paths.add(
        '<polyline points="$points" fill="none" stroke="#000000" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />',
      );
      current.clear();
    }

    for (final point in _signaturePoints) {
      if (point == null) {
        flushPath();
      } else {
        current.add(point);
      }
    }
    flushPath();

    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="${width.toStringAsFixed(0)}" height="${height.toStringAsFixed(0)}" viewBox="0 0 ${width.toStringAsFixed(0)} ${height.toStringAsFixed(0)}">${paths.join()}</svg>';
    return 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({required this.points, required this.color});

  final List<Offset?> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (current != null && next != null) {
        canvas.drawLine(current, next, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
