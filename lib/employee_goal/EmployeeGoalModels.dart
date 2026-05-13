class GoalRecord {
  GoalRecord({
    this.id,
    this.goalHeaderId,
    this.seqNo,
    required this.goalName,
    required this.goalDescription,
    required this.goalType,
    required this.targetCompletion,
    required this.priority,
  });

  factory GoalRecord.fromJson(Map<String, dynamic> json) {
    return GoalRecord(
      id: _toInt(json['id']),
      goalHeaderId: _toInt(json['goal_header_id']),
      seqNo: _toInt(json['seq_no']),
      goalName: '${json['goal_name'] ?? ''}',
      goalDescription: '${json['goal_description'] ?? ''}',
      goalType: _title('${json['goal_type'] ?? ''}'),
      targetCompletion: '${json['target_completion'] ?? ''}',
      priority: _title('${json['priority'] ?? ''}'),
    );
  }

  final int? id;
  final int? goalHeaderId;
  final int? seqNo;
  final String goalName;
  final String goalDescription;
  final String goalType;
  final String targetCompletion;
  final String priority;

  Map<String, dynamic> toApiJson() {
    return {
      if (id != null) 'id': id,
      'goal_name': goalName,
      'goal_description': goalDescription,
      'goal_type': goalType.toLowerCase(),
      'target_completion': targetCompletion,
      'priority': priority.toLowerCase(),
    };
  }

  GoalRecord copyWith({
    int? id,
    int? goalHeaderId,
    int? seqNo,
    String? goalName,
    String? goalDescription,
    String? goalType,
    String? targetCompletion,
    String? priority,
  }) {
    return GoalRecord(
      id: id ?? this.id,
      goalHeaderId: goalHeaderId ?? this.goalHeaderId,
      seqNo: seqNo ?? this.seqNo,
      goalName: goalName ?? this.goalName,
      goalDescription: goalDescription ?? this.goalDescription,
      goalType: goalType ?? this.goalType,
      targetCompletion: targetCompletion ?? this.targetCompletion,
      priority: priority ?? this.priority,
    );
  }
}

class GoalHeader {
  GoalHeader({
    required this.goalHeaderId,
    required this.reviewYear,
    required this.reviewQuarter,
    required this.currentSection,
    required this.currentSectionLabel,
    required this.overallStatus,
    required this.goals,
    required this.midyearRows,
    required this.endyearRows,
    this.overallSummary,
    required this.developmentRows,
    this.signoff,
    required this.actionFlags,
    required this.approvalLogs,
    required this.workflow,
  });

  factory GoalHeader.fromJson(Map<String, dynamic> json) {
    return GoalHeader(
      goalHeaderId: _toInt(json['goal_header_id'] ?? json['id']) ?? 0,
      reviewYear: _toInt(json['review_year']) ?? DateTime.now().year,
      reviewQuarter: '${json['review_quarter'] ?? ''}',
      currentSection: '${json['current_section'] ?? 'goal_setting'}',
      currentSectionLabel: '${json['current_section_label'] ?? 'Goal Setting'}',
      overallStatus: '${json['overall_status'] ?? ''}',
      goals: _list(json['goals']).map((e) => GoalRecord.fromJson(e)).toList(),
      midyearRows: _list(
        json['midyear_rows'],
      ).map((e) => MidYearReview.fromJson(e)).toList(),
      endyearRows: _list(
        json['endyear_rows'],
      ).map((e) => EndYearEvaluation.fromJson(e)).toList(),
      overallSummary: json['overall_summary'] is Map<String, dynamic>
          ? OverallPerformanceSummary.fromJson(json['overall_summary'])
          : null,
      developmentRows: _list(
        json['development_rows'],
      ).map((e) => DevelopmentPlan.fromJson(e)).toList(),
      signoff: json['signoff'] is Map<String, dynamic>
          ? SignOffDetails.fromJson(json['signoff'])
          : null,
      actionFlags: GoalActionFlags.fromJson(
        json['action_flags'] is Map<String, dynamic>
            ? json['action_flags']
            : const {},
      ),
      approvalLogs: _list(
        json['approval_logs'],
      ).map((e) => GoalApprovalLog.fromJson(e)).toList(),
      workflow: GoalWorkflow.fromJson(
        json['workflow'] is Map<String, dynamic> ? json['workflow'] : json,
      ),
    );
  }

  final int goalHeaderId;
  final int reviewYear;
  final String reviewQuarter;
  final String currentSection;
  final String currentSectionLabel;
  final String overallStatus;
  final List<GoalRecord> goals;
  final List<MidYearReview> midyearRows;
  final List<EndYearEvaluation> endyearRows;
  final OverallPerformanceSummary? overallSummary;
  final List<DevelopmentPlan> developmentRows;
  final SignOffDetails? signoff;
  final GoalActionFlags actionFlags;
  final List<GoalApprovalLog> approvalLogs;
  GoalWorkflow workflow;

  String get displayStage =>
      workflow.labelForSection(activeSection, fallback: currentSectionLabel);

  SectionState? get currentState => workflow.stateFor(workflow.currentSection);

  String get activeSection {
    if (actionFlags.actionRequiredSections.isNotEmpty) {
      return canonicalGoalSection(
        actionFlags.actionRequiredSections.first.section,
      );
    }
    return workflow.activeSection;
  }

  SectionState? get activeState => workflow.stateFor(activeSection);

  bool get isLocked {
    final status = overallStatus.toLowerCase().trim();
    return status == 'frozen' || status == 'locked' || status == 'completed';
  }

  bool get currentSectionOpen {
    final section = activeSection;
    if (section == 'completed' || isLocked) return false;
    final state = activeState;
    if (state == null) return false;
    if (section == 'goal_setting') {
      return (state.editable ||
              state.employeeStatus == 'draft' ||
              state.employeeStatus == 'resubmit_required') &&
          state.employeeStatus != 'submitted';
    }
    return (state.editable ||
            state.employeeStatus == 'pending' ||
            state.employeeStatus == 'draft' ||
            state.employeeStatus == 'resubmit_required') &&
        (state.employeeStatus == 'pending' ||
            state.employeeStatus == 'draft' ||
            state.employeeStatus == 'resubmit_required') &&
        state.managerStatus != 'pending';
  }

  bool get goalSettingEditable =>
      isGoalSettingSection(activeSection) &&
      currentSectionOpen &&
      !isLocked &&
      activeState?.employeeStatus != 'submitted';

  bool get signOffApproved {
    final state = workflow.stateFor('sign_off');
    if (state == null) return false;
    return overallStatus.toLowerCase().trim() == 'frozen';
  }

  bool get waitingForApproval {
    final state = activeState;
    return state != null &&
        state.employeeStatus == 'submitted' &&
        state.managerStatus == 'pending';
  }

  String get statusLabel {
    final state = activeState;
    if (activeSection == 'completed') return 'Completed';
    if (isGoalSettingSection(activeSection) &&
        state?.employeeStatus == 'submitted' &&
        state?.managerStatus == 'pending') {
      return 'Pending Approval';
    }
    if (waitingForApproval) return 'Pending Approval';
    if (state?.employeeStatus == 'pending') return displayStage;
    if (state?.employeeStatus == 'draft') return '$displayStage Draft';
    if (state?.employeeStatus == 'resubmit_required') {
      return '$displayStage Resubmit Required';
    }
    return '${displayStage.isEmpty ? activeSection : displayStage} ${_title(state?.employeeStatus ?? overallStatus)}'
        .trim();
  }
}

class GoalActionFlags {
  GoalActionFlags({
    required this.highlight,
    required this.actionRequired,
    required this.actionRequiredSections,
    this.actionType,
  });

  factory GoalActionFlags.fromJson(Map<String, dynamic> json) {
    return GoalActionFlags(
      highlight: json['highlight'] == true,
      actionRequired: json['action_required'] == true,
      actionType: json['action_type']?.toString(),
      actionRequiredSections: _list(
        json['action_required_sections'],
      ).map((e) => GoalActionRequiredSection.fromJson(e)).toList(),
    );
  }

  final bool highlight;
  final bool actionRequired;
  final String? actionType;
  final List<GoalActionRequiredSection> actionRequiredSections;
}

class GoalActionRequiredSection {
  GoalActionRequiredSection({
    required this.section,
    required this.sectionLabel,
  });

  factory GoalActionRequiredSection.fromJson(Map<String, dynamic> json) {
    return GoalActionRequiredSection(
      section: '${json['section'] ?? ''}',
      sectionLabel: '${json['section_label'] ?? ''}',
    );
  }

  final String section;
  final String sectionLabel;
}

class GoalApprovalLog {
  GoalApprovalLog({
    required this.section,
    required this.actionRole,
    required this.action,
    required this.fromStatus,
    required this.toStatus,
    required this.comments,
    required this.actionAt,
  });

  factory GoalApprovalLog.fromJson(Map<String, dynamic> json) {
    return GoalApprovalLog(
      section: '${json['section'] ?? ''}',
      actionRole: '${json['action_role'] ?? ''}',
      action: '${json['action'] ?? ''}',
      fromStatus: json['from_status']?.toString(),
      toStatus: '${json['to_status'] ?? ''}',
      comments: json['comments']?.toString(),
      actionAt: '${json['action_at'] ?? ''}',
    );
  }

  final String section;
  final String actionRole;
  final String action;
  final String? fromStatus;
  final String toStatus;
  final String? comments;
  final String actionAt;
}

class GoalWorkflow {
  GoalWorkflow({
    required this.goalHeaderId,
    required this.currentSection,
    required this.currentSectionLabel,
    required this.nextSection,
    required this.nextSectionLabel,
    required this.sectionState,
    required this.uiFlags,
  });

  factory GoalWorkflow.fromJson(Map<String, dynamic> json) {
    final states = <String, SectionState>{};
    if (json['section_state'] is Map<String, dynamic>) {
      (json['section_state'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          states[key] = SectionState.fromJson(value);
        }
      });
    }
    return GoalWorkflow(
      goalHeaderId: _toInt(json['goal_header_id']) ?? 0,
      currentSection: '${json['current_section'] ?? 'goal_setting'}',
      currentSectionLabel: '${json['current_section_label'] ?? ''}',
      nextSection: '${json['next_section'] ?? ''}',
      nextSectionLabel: '${json['next_section_label'] ?? ''}',
      sectionState: states,
      uiFlags: GoalUiFlags.fromJson(
        json['ui_flags'] is Map<String, dynamic> ? json['ui_flags'] : const {},
      ),
    );
  }

  final int goalHeaderId;
  final String currentSection;
  final String currentSectionLabel;
  final String nextSection;
  final String nextSectionLabel;
  final Map<String, SectionState> sectionState;
  final GoalUiFlags uiFlags;

  String get activeSection {
    return uiFlags.activeSection ?? canonicalGoalSection(currentSection);
  }

  String labelForSection(String section, {String fallback = ''}) {
    final canonical = canonicalGoalSection(section);
    if (canonical == canonicalGoalSection(currentSection) &&
        currentSectionLabel.isNotEmpty) {
      return currentSectionLabel;
    }
    if (canonical == canonicalGoalSection(nextSection) &&
        nextSectionLabel.isNotEmpty) {
      return nextSectionLabel;
    }
    return kGoalSectionLabels[canonical] ?? fallback;
  }

  SectionState? stateFor(String section) {
    return sectionState[section] ??
        sectionState[canonicalGoalSection(section)] ??
        sectionState[legacyGoalSection(section)];
  }
}

class GoalUiFlags {
  GoalUiFlags({required this.visibleSections, required this.hasFlags});

  factory GoalUiFlags.fromJson(Map<String, dynamic> json) {
    bool flag(List<String> keys) {
      for (final key in keys) {
        if (json.containsKey(key)) return json[key] == true;
      }
      return false;
    }

    final visibleSections = <String, bool>{
      'goal_setting': flag(['show_goal_setting_screen']),
      'mid_year_review': flag([
        'show_mid_year_review_screen',
        'show_midyear_screen',
      ]),
      'end_year_evaluation': flag([
        'show_end_year_evaluation_screen',
        'show_endyear_screen',
      ]),
      'overall_summary': flag([
        'show_overall_summary_screen',
        'show_overall_screen',
      ]),
      'development_plan': flag([
        'show_development_plan_screen',
        'show_development_screen',
      ]),
      'sign_off': flag(['show_sign_off_screen', 'show_signoff_screen']),
    };

    return GoalUiFlags(
      visibleSections: visibleSections,
      hasFlags: json.isNotEmpty,
    );
  }

  final Map<String, bool> visibleSections;
  final bool hasFlags;

  String? get activeSection {
    if (!hasFlags) return null;
    for (final section in kGoalSectionOrder) {
      final visible = visibleSections[section] == true;
      if (!visible) return section;
    }
    return kGoalSectionOrder.last;
  }

  bool isVisible(String section) =>
      visibleSections[canonicalGoalSection(section)] == true;
}

class SectionState {
  SectionState({
    required this.employeeStatus,
    required this.managerStatus,
    required this.superAdminStatus,
    required this.editable,
    this.managerLastComment,
    this.superAdminLastComment,
    this.lastRejectComment,
  });

  factory SectionState.fromJson(Map<String, dynamic> json) {
    return SectionState(
      employeeStatus: '${json['employee_status'] ?? ''}',
      managerStatus: '${json['manager_status'] ?? ''}',
      superAdminStatus: '${json['super_admin_status'] ?? ''}',
      editable: json['editable'] == true,
      managerLastComment: json['manager_last_comment']?.toString(),
      superAdminLastComment: json['super_admin_last_comment']?.toString(),
      lastRejectComment: json['last_reject_comment']?.toString(),
    );
  }

  final String employeeStatus;
  final String managerStatus;
  final String superAdminStatus;
  final bool editable;
  final String? managerLastComment;
  final String? superAdminLastComment;
  final String? lastRejectComment;
}

class MidYearReview {
  MidYearReview({
    required this.goalId,
    required this.progressSummary,
    required this.challenges,
    required this.adjustmentMade,
    this.managerComments,
  });

  factory MidYearReview.fromJson(Map<String, dynamic> json) {
    return MidYearReview(
      goalId: _toInt(json['goal_id']),
      progressSummary: '${json['progress_summary'] ?? ''}',
      challenges: '${json['challenges'] ?? ''}',
      adjustmentMade: '${json['adjustments_made'] ?? ''}',
      managerComments: json['manager_comment']?.toString(),
    );
  }

  final int? goalId;
  final String progressSummary;
  final String challenges;
  final String adjustmentMade;
  final String? managerComments;
}

class EndYearEvaluation {
  EndYearEvaluation({
    required this.goalId,
    required this.achievementLevel,
    required this.evidenceComments,
    required this.employeeSelfRating,
    this.managerRating,
  });

  factory EndYearEvaluation.fromJson(Map<String, dynamic> json) {
    return EndYearEvaluation(
      goalId: _toInt(json['goal_id']),
      achievementLevel: '${json['achievement_level'] ?? ''}',
      evidenceComments: '${json['evidence_comment'] ?? ''}',
      employeeSelfRating: '${json['employee_self_rating'] ?? ''}',
      managerRating: json['manager_rating']?.toString(),
    );
  }

  final int? goalId;
  final String achievementLevel;
  final String evidenceComments;
  final String employeeSelfRating;
  final String? managerRating;
}

class OverallPerformanceSummary {
  OverallPerformanceSummary({
    required this.employeeSelfEvaluation,
    this.managerAppraisalSummary,
    required this.finalRating,
  });

  factory OverallPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return OverallPerformanceSummary(
      employeeSelfEvaluation: '${json['employee_self_evaluation'] ?? ''}',
      managerAppraisalSummary: json['manager_appraisal_summary']?.toString(),
      finalRating: '${json['final_rating'] ?? ''}',
    );
  }

  final String employeeSelfEvaluation;
  final String? managerAppraisalSummary;
  final String finalRating;
}

class DevelopmentPlan {
  DevelopmentPlan({
    required this.areaOfDevelopment,
    required this.actionPlan,
    required this.supportNeeded,
    required this.targetCompletionDate,
  });

  factory DevelopmentPlan.fromJson(Map<String, dynamic> json) {
    return DevelopmentPlan(
      areaOfDevelopment: '${json['area_for_development'] ?? ''}',
      actionPlan: '${json['action_plan'] ?? ''}',
      supportNeeded: '${json['support_needed'] ?? ''}',
      targetCompletionDate: '${json['target_completion_date'] ?? ''}',
    );
  }

  final String areaOfDevelopment;
  final String actionPlan;
  final String supportNeeded;
  final String targetCompletionDate;
}

class SignOffDetails {
  SignOffDetails({
    this.employeeName,
    this.managerName,
    this.hrDirectorName,
    this.employeeSignDate,
  });

  factory SignOffDetails.fromJson(Map<String, dynamic> json) {
    return SignOffDetails(
      employeeName: json['employee_name']?.toString(),
      managerName: json['manager_name']?.toString(),
      hrDirectorName: json['hr_director_name']?.toString(),
      employeeSignDate: json['employee_sign_date']?.toString(),
    );
  }

  final String? employeeName;
  final String? managerName;
  final String? hrDirectorName;
  final String? employeeSignDate;
}

const List<String> kGoalNameOptions = [
  'Achieve Sales Target',
  'Increase Product Mix Sales',
  'Convert Competition IB',
  'Develop Leadership Skill',
  'Develop Overall Interpersonal Skill',
  'Complete minimum 5 Online Service Training',
  'Improve Product Knowledge',
  'Negotiation Skill',
  'Territory Management',
  'End-To-End Ownership',
];

const List<String> kGoalTypes = ['Individual', 'Team'];
const List<String> kPriorityLevels = ['High', 'Medium', 'Low'];
const List<String> kReviewQuarters = ['Q2', 'Q3', 'Q4'];
const List<String> kAchievementLevels = [
  'exceeded',
  'met',
  'partially_met',
  'not_met',
];
const List<String> kPerformanceRatings = ['1', '2', '3', '4', '5'];
const List<String> kFinalRatings = [
  'exceeds_expectations',
  'meets_expectations',
  'partially_meets_expectations',
  'does_not_meet_expectations',
];

const List<String> kGoalSectionOrder = [
  'goal_setting',
  'mid_year_review',
  'end_year_evaluation',
  'overall_summary',
  'development_plan',
  'sign_off',
];

const Map<String, String> kGoalSectionLabels = {
  'goal_setting': 'Goal Setting',
  'mid_year_review': 'Mid-Year Review',
  'end_year_evaluation': 'End-Year Evaluation',
  'overall_summary': 'Overall Summary',
  'development_plan': 'Development Plan',
  'sign_off': 'Sign-Off',
};

String canonicalGoalSection(String section) {
  switch (section) {
    case 'section2':
      return 'goal_setting';
    case 'section3':
      return 'mid_year_review';
    case 'section4':
      return 'end_year_evaluation';
    case 'section5':
      return 'overall_summary';
    case 'section6':
      return 'development_plan';
    case 'section7':
      return 'sign_off';
    default:
      return section;
  }
}

String legacyGoalSection(String section) {
  switch (section) {
    case 'goal_setting':
      return 'section2';
    case 'mid_year_review':
      return 'section3';
    case 'end_year_evaluation':
      return 'section4';
    case 'overall_summary':
      return 'section5';
    case 'development_plan':
      return 'section6';
    case 'sign_off':
      return 'section7';
    default:
      return section;
  }
}

bool isGoalSettingSection(String section) =>
    canonicalGoalSection(section) == 'goal_setting';

int? _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse('${value ?? ''}');
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return <Map<String, dynamic>>[];
}

String _title(String value) {
  if (value.isEmpty) return value;
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
      .join(' ');
}
