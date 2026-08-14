import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utility/Commons.dart';
import 'QuotationModels.dart';

class QuotationApiException implements Exception {
  /// Trimmed to something a flushbar can actually render — see [_shortMessage].
  final String message;

  QuotationApiException(String message) : message = _shortMessage(message);

  @override
  String toString() => message;
}

/// Server errors can be enormous: Laravel appends the whole failing query to
/// database exceptions, and our insert carries full HTML terms, so the raw
/// message runs to thousands of characters and overflows any flushbar.
String _shortMessage(String raw) {
  var text = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (text.isEmpty) return 'Request failed';

  final sqlStart = text.indexOf(' (SQL: ');
  if (sqlStart > 0) text = text.substring(0, sqlStart);

  const maxLength = 200;
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength).trimRight()}…';
}

/// `dart:developer`'s log() only reaches the VM service, so it never shows up
/// in logcat. debugPrint goes to stdout like the rest of the app, and chunking
/// keeps Android from truncating long bodies at its ~4 KB per-entry limit.
void _log(String label, String value) {
  const chunkSize = 800;
  if (value.length <= chunkSize) {
    debugPrint('QUOTATION $label: $value');
    return;
  }
  debugPrint('QUOTATION $label (${value.length} chars):');
  for (var i = 0; i < value.length; i += chunkSize) {
    final end = (i + chunkSize) < value.length ? i + chunkSize : value.length;
    debugPrint('QUOTATION $label [$i] ${value.substring(i, end)}');
  }
}

class QuotationApi {
  /// GET quotation-products/{productName}
  ///
  /// The path segment is the machine name as stored on the visit
  /// (e.g. `HS40`, `LC2`).
  Future<QuotationProductResponse> getQuotationProduct(
    String productName,
  ) async {
    final url =
        '${Commons.quotationProducts}/${Uri.encodeComponent(productName)}';
    final json = await _get(url);
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw QuotationApiException('Quotation product not available');
    }
    return QuotationProductResponse.fromJson(data);
  }

  /// POST quotations
  Future<CreatedQuotation> createQuotation({
    required int userId,
    required int productId,
    int? visitId,
    required Map<String, dynamic> customer,
    required Map<String, dynamic> salesContact,
    required List<SelectedQuotationItem> selectedProbes,
    required List<SelectedQuotationItem> selectedOptions,
    required Map<String, dynamic> quotationOverrides,
    required List<Map<String, dynamic>> termsAndConditions,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      if (visitId != null) 'visit_id': visitId,
      'product_id': productId,
      'customer': customer,
      'sales_contact': salesContact,
      'selected_probes': selectedProbes
          .map((e) => {'probe_id': e.item.id, 'quantity': e.quantity})
          .toList(),
      'selected_options': selectedOptions
          .map((e) => {'option_id': e.item.id, 'quantity': e.quantity})
          .toList(),
      'quotation_overrides': quotationOverrides,
      'terms_and_conditions': termsAndConditions,
    };
    final json = await _post(Commons.quotations, body);
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw QuotationApiException('Quotation was not returned by the server');
    }
    return CreatedQuotation.fromJson(data);
  }

  Future<Map<String, dynamic>> _get(String url) async {
    _log('GET url', url);
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );
    _log('GET status', '${response.statusCode}');
    if (response.statusCode != 200) {
      _log('GET response', response.body);
    }
    return _decode(response.statusCode, response.body);
  }

  Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final encoded = jsonEncode(body);
    _log('POST url', url);
    _log('POST body', encoded);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: encoded,
    );
    _log('POST status', '${response.statusCode}');
    _log('POST response', response.body);
    return _decode(response.statusCode, response.body);
  }

  Map<String, dynamic> _decode(int statusCode, String body) {
    dynamic json;
    try {
      json = jsonDecode(body);
    } catch (_) {
      json = null;
    }

    if (json is Map<String, dynamic>) {
      // Laravel validation failures come back as {message, errors:{field:[..]}}
      // instead of the usual {status, message, data} envelope.
      final errors = json['errors'];
      if (errors is Map) {
        final messages = errors.values
            .whereType<List>()
            .expand((e) => e)
            .map((e) => '$e')
            .toList();
        throw QuotationApiException(
          messages.isEmpty
              ? '${json['message'] ?? 'Request failed'}'
              : messages.join('\n'),
        );
      }
      if (statusCode >= 200 && statusCode < 300 && json['status'] != 1) {
        throw QuotationApiException('${json['message'] ?? 'Request failed'}');
      }
    }

    if (statusCode < 200 || statusCode >= 300) {
      if (json is Map<String, dynamic> && json['message'] != null) {
        throw QuotationApiException('${json['message']}');
      }
      throw QuotationApiException('Request failed with status $statusCode');
    }

    if (json is! Map<String, dynamic>) {
      throw QuotationApiException('Internal server error');
    }
    return json;
  }
}
