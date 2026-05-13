import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:qedic/employee_goal/EmployeeGoalModels.dart';
import 'package:qedic/model/LoginModel.dart';
import 'package:qedic/utility/Commons.dart';

class EmployeeGoalApi {
  Future<Map<String, dynamic>> getMasterData() async {
    return _get(Commons.goalMasterData);
  }

  Future<int> resolveGoalUserId(Data? loginData) async {
    final fallbackId = loginData?.goalModuleUserId ?? 0;
    if (fallbackId == 0) return 0;

    try {
      final json = await _get('${Commons.allListing}/$fallbackId');
      final data = json['data'];
      final referenceUsers = data is Map<String, dynamic>
          ? (data['refrence_user'] as List? ?? [])
          : [];
      final currentEmail = '${loginData?.email ?? ''}'.toLowerCase();

      for (final user in referenceUsers.whereType<Map<String, dynamic>>()) {
        final username = '${user['username'] ?? ''}'.toLowerCase();
        final email = '${user['email'] ?? ''}'.toLowerCase();
        if (username == 'self' ||
            (currentEmail.isNotEmpty && email == currentEmail)) {
          return _toInt(user['id']) ?? fallbackId;
        }
      }
    } catch (_) {
      return fallbackId;
    }

    return fallbackId;
  }

  Future<List<GoalHeader>> getGoals(int userId) async {
    final json = await _get('${Commons.goalList}/$userId');
    final headers = json['data'] is Map<String, dynamic>
        ? (json['data']['headers'] as List? ?? [])
        : [];
    return headers
        .whereType<Map<String, dynamic>>()
        .map((e) => GoalHeader.fromJson(e))
        .toList();
  }

  Future<int?> saveGoals({
    required int userId,
    required int reviewYear,
    required String reviewQuarter,
    required List<GoalRecord> goals,
    int? goalHeaderId,
  }) async {
    final body = {
      'user_id': userId,
      if (goalHeaderId != null) 'goal_header_id': goalHeaderId,
      if (goalHeaderId == null) 'review_year': reviewYear,
      if (goalHeaderId == null) 'review_quarter': reviewQuarter,
      'goals': goals.map((e) => e.toApiJson()).toList(),
    };
    final json = await _post(
      goalHeaderId == null ? Commons.goalSave : Commons.goalEdit,
      body,
    );
    return _extractGoalHeaderId(json) ?? goalHeaderId;
  }

  Future<void> submitGoals({
    required int userId,
    required int goalHeaderId,
  }) async {
    await _post(Commons.goalSubmit, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
    });
  }

  Future<void> saveMidyear({
    required int userId,
    required int goalHeaderId,
    required List<Map<String, dynamic>> rows,
  }) async {
    await _post(Commons.goalMidyearSave, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
      'rows': rows,
    });
  }

  Future<void> submitMidyear({
    required int userId,
    required int goalHeaderId,
  }) async {
    await _post(Commons.goalMidyearSubmit, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
    });
  }

  Future<void> skipMidyear({
    required int userId,
    required int goalHeaderId,
    required String comment,
  }) async {
    await _post(Commons.goalMidyearSkip, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
      'comment': comment,
    });
  }

  Future<void> saveEndyear({
    required int userId,
    required int goalHeaderId,
    required List<Map<String, dynamic>> rows,
  }) async {
    await _post(Commons.goalEndyearSave, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
      'rows': rows,
    });
  }

  Future<void> submitEndyear({
    required int userId,
    required int goalHeaderId,
  }) async {
    await _post(Commons.goalEndyearSubmit, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
    });
  }

  Future<void> saveOverall({
    required int userId,
    required int goalHeaderId,
    required String employeeSelfEvaluation,
    required String finalRating,
  }) async {
    await _post(Commons.goalOverallSave, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
      'employee_self_evaluation': employeeSelfEvaluation,
      'final_rating': finalRating,
    });
  }

  Future<void> submitOverall({
    required int userId,
    required int goalHeaderId,
  }) async {
    await _post(Commons.goalOverallSubmit, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
    });
  }

  Future<void> saveDevelopment({
    required int userId,
    required int goalHeaderId,
    required List<Map<String, dynamic>> rows,
  }) async {
    await _post(Commons.goalDevelopmentSaveSubmit, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
      'action': 'save',
      'rows': rows,
    });
  }

  Future<void> submitDevelopment({
    required int userId,
    required int goalHeaderId,
    required List<Map<String, dynamic>> rows,
  }) async {
    await _post(Commons.goalDevelopmentSaveSubmit, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
      'action': 'submit',
      'rows': rows,
    });
  }

  Future<void> submitEmployeeSignoff({
    required int userId,
    required int goalHeaderId,
    required String signaturePath,
    required String signDate,
  }) async {
    await _post(Commons.goalEmployeeSignoff, {
      'goal_header_id': goalHeaderId,
      'user_id': userId,
      'employee_signature_blob_or_path': signaturePath,
      'employee_sign_date': signDate,
    });
  }

  Future<List<Map<String, dynamic>>> getLogs(int goalHeaderId) async {
    final json = await _get('${Commons.goalLogs}/$goalHeaderId');
    final logs = json['data'] is Map<String, dynamic>
        ? (json['data']['logs'] as List? ?? [])
        : [];
    return logs.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final response = await http.get(Uri.parse(url));
    print(response.request.toString());
    print(response.statusCode.toString());
    print(response.body.toString());
    return _decode(response.statusCode, response.body);
  }

  Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    log(response.request.toString());
    log('test log: ${jsonEncode(body).toString()}');
    log('test log: ${response.request?.url.toString()}');
    log(response.statusCode.toString());
    log(response.body.toString());
    return _decode(response.statusCode, response.body);
  }

  Map<String, dynamic> _decode(int statusCode, String body) {
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception('Request failed with status $statusCode');
    }
    if (body.contains('A PHP Error was encountered') ||
        body.contains('<div') ||
        body.contains('</html')) {
      throw Exception('Internal server error');
    }
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }
    if (json['status'] != 1) {
      throw Exception('${json['message'] ?? 'Request failed'}');
    }
    return json;
  }

  int? _extractGoalHeaderId(Map<String, dynamic> json) {
    final directId = _toInt(
      json['goal_header_id'] ?? json['goalHeaderId'] ?? json['id'],
    );
    if (directId != null) return directId;
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return _extractGoalHeaderId(data);
    }
    return null;
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse('$value');
}
