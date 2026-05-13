import 'package:flutter/material.dart';
import 'package:qedic/employee_goal/EmployeeGoalModels.dart';
import 'package:qedic/employee_goal/EmployeeGoalWidgets.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';

enum GoalSetAction { save, submit }

class GoalSetResult {
  const GoalSetResult({required this.goals, required this.action});

  final List<GoalRecord> goals;
  final GoalSetAction action;
}

class AddEmployeeGoal extends StatefulWidget {
  const AddEmployeeGoal({
    super.key,
    this.goal,
    this.initialGoals = const [],
    this.header,
  });

  final GoalRecord? goal;
  final List<GoalRecord> initialGoals;
  final GoalHeader? header;

  @override
  State<AddEmployeeGoal> createState() => _AddEmployeeGoalState();
}

class _AddEmployeeGoalState extends State<AddEmployeeGoal> {
  static const int _minimumGoals = 5;

  final _formKey = GlobalKey<FormState>();
  final _desc = TextEditingController();
  final List<GoalRecord> _goals = [];
  String _goalName = kGoalNameOptions.first;
  String _type = 'Individual';
  final _target = TextEditingController();
  String _priority = 'High';
  int? _editingIndex;
  bool _logsExpanded = false;
  bool _workflowExpanded = false;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    if (goal != null) {
      _goalName = goal.goalName;
      _desc.text = goal.goalDescription;
      _type = goal.goalType;
      _target.text = goal.targetCompletion;
      _priority = goal.priority;
    } else {
      _goals.addAll(widget.initialGoals);
    }
  }

  @override
  void dispose() {
    _desc.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(HexColor.white),
      appBar: Commons.Appbar_logo(
        true,
        context,
        _isEditing ? 'Edit Goal' : 'Add Goals',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (!_isEditing) ...[
              _goalProgressCard(),
              const SizedBox(height: 10),
              if (_goals.isNotEmpty) ...[
                ..._goals.asMap().entries.map(
                  (entry) => _goalSummaryCard(entry.key, entry.value),
                ),
                const SizedBox(height: 5),
              ],
            ],
            EmployeeGoalFieldCard(
              child: DropdownButtonFormField<String>(
                initialValue: _goalName,
                isExpanded: true,
                items: kGoalNameOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _goalName = v ?? _goalName),
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            EmployeeGoalFieldCard(
              child: TextFormField(
                controller: _desc,
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter Goal Description'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Goal Description',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            EmployeeGoalFieldCard(
              child: DropdownButtonFormField<String>(
                initialValue: _type,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'Individual',
                    child: Text('Individual'),
                  ),
                  DropdownMenuItem(value: 'Team', child: Text('Team')),
                ],
                onChanged: (v) => setState(() => _type = v ?? _type),
                decoration: const InputDecoration(
                  labelText: 'Goal Type',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            EmployeeGoalFieldCard(
              child: TextFormField(
                controller: _target,
                readOnly: true,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Select Target Completion'
                    : null,
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    _target.text = Commons.Date_format5(picked.toString());
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Target Completion',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
            const SizedBox(height: 10),
            EmployeeGoalFieldCard(
              child: DropdownButtonFormField<String>(
                initialValue: _priority,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'High', child: Text('High')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                ],
                onChanged: (v) => setState(() => _priority = v ?? _priority),
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            EmployeeGoalPrimaryButton(
              text: _primaryButtonText,
              icon: _editingIndex == null && !_isEditing
                  ? Icons.add
                  : Icons.check,
              onPressed: _isEditing ? _saveEditedGoal : _addOrUpdateGoal,
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 10),
              EmployeeGoalPrimaryButton(
                text: 'Save Goal',
                icon: Icons.save,
                onPressed: _goals.length >= _minimumGoals
                    ? () => _finishGoalSet(GoalSetAction.save)
                    : null,
              ),
              const SizedBox(height: 10),
              EmployeeGoalPrimaryButton(
                text: 'Submit Goal',
                icon: Icons.send,
                onPressed: _goals.length >= _minimumGoals
                    ? () => _finishGoalSet(GoalSetAction.submit)
                    : null,
              ),
              SizedBox(height: 10),
              if (widget.header != null) ...[
                _approvalLogsPanel(widget.header!),
                const SizedBox(height: 10),
                _workflowPanel(widget.header!),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _goalProgressCard() {
    final remaining = (_minimumGoals - _goals.length).clamp(0, _minimumGoals);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HexColor(HexColor.primary_s).withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: HexColor(HexColor.primary_s).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag, color: HexColor(HexColor.primary_s), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              remaining == 0
                  ? 'Minimum 5 goals added. You can save the goal set now.'
                  : 'Add at least 5 goals before saving. $remaining more required.',
              style: TextStyle(
                fontSize: 13,
                color: HexColor(HexColor.black),
                fontFamily: 'montserrat_medium',
              ),
            ),
          ),
          Text(
            '${_goals.length}/$_minimumGoals',
            style: TextStyle(
              fontSize: 14,
              color: HexColor(HexColor.primary_s),
              fontFamily: 'montserrat_bold',
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalSummaryCard(int index, GoalRecord goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(blurRadius: 1, color: Colors.grey, offset: Offset(0, 0)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: HexColor(HexColor.primarycolor),
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.goalName,
                  style: TextStyle(
                    fontSize: 13,
                    color: HexColor(HexColor.black),
                    fontFamily: 'montserrat_bold',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${goal.goalType} | ${goal.priority} | ${goal.targetCompletion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: HexColor(HexColor.black).withValues(alpha: 0.7),
                    fontFamily: 'montserrat_regular',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.edit, color: HexColor(HexColor.primary_s)),
            onPressed: () => _editGoalAt(index),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.delete_outline,
              color: HexColor(HexColor.red_color),
            ),
            onPressed: () => setState(() => _goals.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _approvalLogsPanel(GoalHeader header) {
    final logs = header.approvalLogs;
    return _collapsibleInfoPanel(
      title: 'Approval Logs',
      icon: Icons.history,
      expanded: _logsExpanded,
      onToggle: () => setState(() => _logsExpanded = !_logsExpanded),
      collapsedText: logs.isEmpty
          ? 'No approval logs available'
          : '${logs.length} log${logs.length == 1 ? '' : 's'} available',
      child: logs.isEmpty
          ? _emptyInfoText('No approval logs available')
          : Column(
              children: logs
                  .map(
                    (log) => _infoRow(
                      icon: _approvalLogIcon(log.action),
                      title:
                          '${_titleText(log.action)} by ${_titleText(log.actionRole)}',
                      subtitle: [
                        if (log.section.isNotEmpty) _titleText(log.section),
                        _statusTransition(log),
                        if ((log.comments ?? '').isNotEmpty) log.comments!,
                        if (log.actionAt.isNotEmpty) log.actionAt,
                      ].where((value) => value.isNotEmpty).join('\n'),
                      iconColor: _approvalLogColor(log.action),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _workflowPanel(GoalHeader header) {
    final workflow = header.workflow;
    final states = workflow.sectionState.entries.toList();
    final activeLabel = workflow.labelForSection(header.activeSection);
    return _collapsibleInfoPanel(
      title: 'Workflow',
      icon: Icons.account_tree,
      expanded: _workflowExpanded,
      onToggle: () => setState(() => _workflowExpanded = !_workflowExpanded),
      collapsedText: workflow.nextSectionLabel.isEmpty
          ? header.statusLabel
          : '$activeLabel active',
      child: Column(
        children: [
          _infoRow(
            icon: Icons.flag,
            title: activeLabel,
            subtitle: workflow.nextSectionLabel.isEmpty
                ? 'Current section'
                : 'Next: ${workflow.nextSectionLabel}',
          ),
          ...states.map(
            (entry) =>
                _workflowStateRow(section: entry.key, state: entry.value),
          ),
        ],
      ),
    );
  }

  Widget _workflowStateRow({
    required String section,
    required SectionState state,
  }) {
    final comment = state.lastRejectComment ?? state.managerLastComment;
    return _infoRow(
      icon: state.editable ? Icons.edit : Icons.lock_outline,
      title: _titleText(section),
      subtitle: [
        'Employee: ${_titleText(state.employeeStatus)}',
        'Manager: ${_titleText(state.managerStatus)}',
        'Super Admin: ${_titleText(state.superAdminStatus)}',
        'Editable: ${state.editable ? 'Yes' : 'No'}',
        if ((comment ?? '').isNotEmpty) 'Comment: $comment',
      ].join('\n'),
      iconColor: state.editable
          ? HexColor(HexColor.primary_s)
          : HexColor(HexColor.gray_text),
    );
  }

  Widget _collapsibleInfoPanel({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onToggle,
    required String collapsedText,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HexColor(HexColor.gray_activity_background),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: HexColor(HexColor.primary_s).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              children: [
                Icon(icon, size: 20, color: HexColor(HexColor.primary_s)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: HexColor(HexColor.black),
                      fontFamily: 'montserrat_bold',
                    ),
                  ),
                ),
                Text(
                  expanded ? 'Read less' : 'Read more',
                  style: TextStyle(
                    fontSize: 12,
                    color: HexColor(HexColor.primary_s),
                    fontFamily: 'montserrat_bold',
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: HexColor(HexColor.primary_s),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  collapsedText,
                  style: TextStyle(
                    fontSize: 12,
                    color: HexColor(HexColor.gray_text),
                    fontFamily: 'montserrat_regular',
                  ),
                ),
              ),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor ?? HexColor(HexColor.primary_s),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: HexColor(HexColor.black),
                    fontFamily: 'montserrat_bold',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: HexColor(HexColor.black).withValues(alpha: 0.72),
                    fontFamily: 'montserrat_regular',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyInfoText(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: HexColor(HexColor.gray_text),
          fontFamily: 'montserrat_regular',
        ),
      ),
    );
  }

  IconData _approvalLogIcon(String action) {
    switch (action.toLowerCase()) {
      case 'reject':
        return Icons.cancel_outlined;
      case 'approve':
        return Icons.verified;
      case 'resubmit':
        return Icons.restart_alt;
      case 'submit':
        return Icons.send;
      case 'save':
        return Icons.save;
      case 'edit':
        return Icons.edit;
      default:
        return Icons.history;
    }
  }

  Color _approvalLogColor(String action) {
    switch (action.toLowerCase()) {
      case 'reject':
        return HexColor(HexColor.red_color);
      case 'approve':
      case 'resubmit':
        return HexColor(HexColor.green_txt);
      case 'submit':
        return HexColor(HexColor.primary_s);
      case 'save':
      case 'edit':
        return HexColor(HexColor.green_txt);
      default:
        return HexColor(HexColor.gray_text);
    }
  }

  String _statusTransition(GoalApprovalLog log) {
    if ((log.fromStatus ?? '').isEmpty && log.toStatus.isEmpty) return '';
    if ((log.fromStatus ?? '').isEmpty) {
      return 'Status: ${_titleText(log.toStatus)}';
    }
    if (log.toStatus.isEmpty) {
      return 'From: ${_titleText(log.fromStatus!)}';
    }
    return '${_titleText(log.fromStatus!)} -> ${_titleText(log.toStatus)}';
  }

  String _titleText(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  GoalRecord _currentGoal() {
    final editingGoal = _editingIndex == null
        ? widget.goal
        : _goals[_editingIndex!];
    return GoalRecord(
      id: editingGoal?.id,
      goalHeaderId: editingGoal?.goalHeaderId,
      seqNo: editingGoal?.seqNo,
      goalName: _goalName,
      goalDescription: _desc.text.trim(),
      goalType: _type,
      targetCompletion: _target.text.trim(),
      priority: _priority,
    );
  }

  void _saveEditedGoal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop(context, _currentGoal());
  }

  String get _primaryButtonText {
    if (_isEditing) return 'Save';
    return _editingIndex == null ? 'Add Goal' : 'Update Goal';
  }

  void _addOrUpdateGoal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final editingIndex = _editingIndex;
    setState(() {
      if (editingIndex == null) {
        _goals.add(_currentGoal());
      } else {
        _goals[editingIndex] = _currentGoal();
      }
      _clearForm();
    });
    Commons.Fluttertoast_Messege(
      context,
      editingIndex == null ? 'Goal added' : 'Goal updated',
    );
  }

  void _editGoalAt(int index) {
    final goal = _goals[index];
    setState(() {
      _editingIndex = index;
      _goalName = kGoalNameOptions.contains(goal.goalName)
          ? goal.goalName
          : kGoalNameOptions.first;
      _desc.text = goal.goalDescription;
      _type = kGoalTypes.contains(goal.goalType) ? goal.goalType : 'Individual';
      _target.text = goal.targetCompletion;
      _priority = kPriorityLevels.contains(goal.priority)
          ? goal.priority
          : 'High';
    });
  }

  void _clearForm() {
    _editingIndex = null;
    _goalName = kGoalNameOptions.first;
    _desc.clear();
    _type = 'Individual';
    _target.clear();
    _priority = 'High';
  }

  void _finishGoalSet(GoalSetAction action) {
    if (_goals.length < _minimumGoals) {
      Commons.Fluttertoast_Messege(context, 'Minimum 5 goals are required.');
      return;
    }
    Navigator.pop(
      context,
      GoalSetResult(
        goals: List<GoalRecord>.unmodifiable(_goals),
        action: action,
      ),
    );
  }
}
