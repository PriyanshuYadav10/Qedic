int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse('$value');
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

String? _toStr(dynamic value) {
  if (value == null) return null;
  final text = '$value'.trim();
  return text.isEmpty ? null : text;
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}

/// GET quotation-products/{name}
class QuotationProductResponse {
  final QuotationProduct product;
  final List<QuotationTerm> termsAndConditions;

  QuotationProductResponse({
    required this.product,
    required this.termsAndConditions,
  });

  factory QuotationProductResponse.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    return QuotationProductResponse(
      product: QuotationProduct.fromJson(
        product is Map<String, dynamic> ? product : const {},
      ),
      termsAndConditions: _asMapList(json['terms_and_conditions'])
          .map(QuotationTerm.fromJson)
          .toList(),
    );
  }
}

class QuotationProduct {
  final int? id;
  final String? name;
  final String? modelCode;
  final String? cisCode;
  final String? shortDescription;
  final String? description;
  final String? specifications;
  final String? warranty;
  final String? primaryImageUrl;
  final double basePrice;
  final double gstPercentage;
  final double gstPrice;
  final double totalPrice;
  final String? companyName;
  final List<QuotationItem> probes;
  final List<QuotationItem> options;
  final List<QuotationSpecSection> specSections;

  QuotationProduct({
    this.id,
    this.name,
    this.modelCode,
    this.cisCode,
    this.shortDescription,
    this.description,
    this.specifications,
    this.warranty,
    this.primaryImageUrl,
    this.basePrice = 0,
    this.gstPercentage = 0,
    this.gstPrice = 0,
    this.totalPrice = 0,
    this.companyName,
    this.probes = const [],
    this.options = const [],
    this.specSections = const [],
  });

  factory QuotationProduct.fromJson(Map<String, dynamic> json) {
    final company = json['company'];
    return QuotationProduct(
      id: _toInt(json['id']),
      name: _toStr(json['name']),
      modelCode: _toStr(json['model_code']),
      cisCode: _toStr(json['cis_code']),
      shortDescription: _toStr(json['short_description']),
      description: _toStr(json['description']),
      specifications: _toStr(json['specifications']),
      warranty: _toStr(json['warranty']),
      primaryImageUrl: _toStr(json['primary_image_url']),
      basePrice: _toDouble(json['base_price']),
      gstPercentage: _toDouble(json['gst_percentage']),
      gstPrice: _toDouble(json['gst_price']),
      totalPrice: _toDouble(json['total_price']),
      companyName:
          company is Map<String, dynamic> ? _toStr(company['name']) : null,
      probes: _asMapList(json['probes']).map(QuotationItem.fromJson).toList(),
      options: _asMapList(json['options']).map(QuotationItem.fromJson).toList(),
      specSections: _asMapList(json['spec_sections'])
          .map(QuotationSpecSection.fromJson)
          .toList(),
    );
  }

  /// Title used as the default `quotation_overrides.title`.
  String get displayTitle {
    final parts = [companyName, name].where((e) => e != null && e.isNotEmpty);
    return parts.isEmpty ? '' : parts.join(' ');
  }
}

/// A probe or an option — both share the same payload shape.
class QuotationItem {
  final int? id;
  final String? name;
  final String? modelCode;
  final String? cisCode;
  final String? type;
  final String? description;
  final double basePrice;
  final double gstPercentage;
  final double gstPrice;
  final double totalPrice;

  QuotationItem({
    this.id,
    this.name,
    this.modelCode,
    this.cisCode,
    this.type,
    this.description,
    this.basePrice = 0,
    this.gstPercentage = 0,
    this.gstPrice = 0,
    this.totalPrice = 0,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      id: _toInt(json['id']),
      name: _toStr(json['name']),
      modelCode: _toStr(json['model_code']),
      cisCode: _toStr(json['cis_code']),
      type: _toStr(json['type']),
      description: _toStr(json['description']),
      basePrice: _toDouble(json['base_price']),
      gstPercentage: _toDouble(json['gst_percentage']),
      gstPrice: _toDouble(json['gst_price']),
      totalPrice: _toDouble(json['total_price']),
    );
  }
}

class QuotationSpecSection {
  final int? id;
  final String? title;
  final String? content;
  final int sortOrder;

  QuotationSpecSection({this.id, this.title, this.content, this.sortOrder = 0});

  factory QuotationSpecSection.fromJson(Map<String, dynamic> json) {
    return QuotationSpecSection(
      id: _toInt(json['id']),
      title: _toStr(json['title']),
      content: _toStr(json['content']),
      sortOrder: _toInt(json['sort_order']) ?? 0,
    );
  }
}

class QuotationTerm {
  final int? id;
  final String? title;
  final String? content;
  final int sortOrder;

  QuotationTerm({this.id, this.title, this.content, this.sortOrder = 0});

  factory QuotationTerm.fromJson(Map<String, dynamic> json) {
    return QuotationTerm(
      id: _toInt(json['id']),
      title: _toStr(json['title']),
      content: _toStr(json['content']),
      sortOrder: _toInt(json['sort_order']) ?? 0,
    );
  }
}

/// POST quotations — the quotation the server created, also returned by
/// GET quotations/{id}.
class CreatedQuotation {
  final int? id;
  final String? quotationNo;
  final int? userId;
  final int? visitId;
  final int? productId;
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;
  final String? customerEmail;
  final String? salesName;
  final String? salesDesignation;
  final String? salesPhone;
  final String? salesEmail;
  final String? title;
  final String? description;
  final String? specifications;
  final String? warranty;
  final String? notes;
  final int? validityDays;
  final String? quotationDate;
  final String? validUntil;
  final double subtotal;
  final double gstAmount;
  final double totalAmount;
  final String? pdfPath;
  final List<QuotationLine> items;
  final List<QuotationTerm> terms;
  final String? viewUrl;
  final String? pdfUrl;
  final String? downloadUrl;
  final String? detailUrl;

  CreatedQuotation({
    this.id,
    this.quotationNo,
    this.userId,
    this.visitId,
    this.productId,
    this.customerName,
    this.customerAddress,
    this.customerPhone,
    this.customerEmail,
    this.salesName,
    this.salesDesignation,
    this.salesPhone,
    this.salesEmail,
    this.title,
    this.description,
    this.specifications,
    this.warranty,
    this.notes,
    this.validityDays,
    this.quotationDate,
    this.validUntil,
    this.subtotal = 0,
    this.gstAmount = 0,
    this.totalAmount = 0,
    this.pdfPath,
    this.items = const [],
    this.terms = const [],
    this.viewUrl,
    this.pdfUrl,
    this.downloadUrl,
    this.detailUrl,
  });

  factory CreatedQuotation.fromJson(Map<String, dynamic> json) {
    return CreatedQuotation(
      id: _toInt(json['id']),
      quotationNo: _toStr(json['quotation_no']),
      userId: _toInt(json['user_id']),
      visitId: _toInt(json['visit_id']),
      productId: _toInt(json['product_id']),
      customerName: _toStr(json['customer_name']),
      customerAddress: _toStr(json['customer_address']),
      customerPhone: _toStr(json['customer_phone']),
      customerEmail: _toStr(json['customer_email']),
      salesName: _toStr(json['sales_name']),
      salesDesignation: _toStr(json['sales_designation']),
      salesPhone: _toStr(json['sales_phone']),
      salesEmail: _toStr(json['sales_email']),
      title: _toStr(json['title']),
      description: _toStr(json['description']),
      specifications: _toStr(json['specifications']),
      warranty: _toStr(json['warranty']),
      notes: _toStr(json['notes']),
      validityDays: _toInt(json['validity_days']),
      quotationDate: _toStr(json['quotation_date']),
      validUntil: _toStr(json['valid_until']),
      subtotal: _toDouble(json['subtotal']),
      gstAmount: _toDouble(json['gst_amount']),
      totalAmount: _toDouble(json['total_amount']),
      pdfPath: _toStr(json['pdf_path']),
      items: _asMapList(json['items']).map(QuotationLine.fromJson).toList(),
      terms: _asMapList(json['terms']).map(QuotationTerm.fromJson).toList(),
      viewUrl: _toStr(json['view_url']),
      pdfUrl: _toStr(json['pdf_url']),
      downloadUrl: _toStr(json['download_url']),
      detailUrl: _toStr(json['detail_url']),
    );
  }

  /// Best URL for opening the PDF inline.
  String? get openUrl => viewUrl ?? pdfUrl ?? downloadUrl;
}

/// One priced row on a created quotation — the product itself, a probe, or an
/// option, distinguished by [sourceType].
class QuotationLine {
  final int? id;
  final int? quotationId;
  final String? sourceType;
  final int? sourceId;
  final String? name;
  final String? modelCode;
  final String? cisCode;
  final String? description;
  final int quantity;
  final double unitBasePrice;
  final double unitGstPercentage;
  final double unitGstAmount;
  final double unitTotalPrice;
  final double lineSubtotal;
  final double lineGstAmount;
  final double lineTotalAmount;
  final int sortOrder;

  QuotationLine({
    this.id,
    this.quotationId,
    this.sourceType,
    this.sourceId,
    this.name,
    this.modelCode,
    this.cisCode,
    this.description,
    this.quantity = 1,
    this.unitBasePrice = 0,
    this.unitGstPercentage = 0,
    this.unitGstAmount = 0,
    this.unitTotalPrice = 0,
    this.lineSubtotal = 0,
    this.lineGstAmount = 0,
    this.lineTotalAmount = 0,
    this.sortOrder = 0,
  });

  factory QuotationLine.fromJson(Map<String, dynamic> json) {
    return QuotationLine(
      id: _toInt(json['id']),
      quotationId: _toInt(json['quotation_id']),
      sourceType: _toStr(json['source_type']),
      sourceId: _toInt(json['source_id']),
      name: _toStr(json['name']),
      modelCode: _toStr(json['model_code']),
      cisCode: _toStr(json['cis_code']),
      description: _toStr(json['description']),
      quantity: _toInt(json['quantity']) ?? 1,
      unitBasePrice: _toDouble(json['unit_base_price']),
      unitGstPercentage: _toDouble(json['unit_gst_percentage']),
      unitGstAmount: _toDouble(json['unit_gst_amount']),
      unitTotalPrice: _toDouble(json['unit_total_price']),
      lineSubtotal: _toDouble(json['line_subtotal']),
      lineGstAmount: _toDouble(json['line_gst_amount']),
      lineTotalAmount: _toDouble(json['line_total_amount']),
      sortOrder: _toInt(json['sort_order']) ?? 0,
    );
  }
}

/// The compact quotation record the visit list returns under `quotations[]`.
class QuotationSummary {
  final int? quotationId;
  final String? quotationNo;
  final int? productId;
  final String? quotationDate;
  final String? validUntil;
  final double totalAmount;
  final String? viewUrl;
  final String? pdfUrl;
  final String? downloadUrl;
  final String? detailUrl;

  QuotationSummary({
    this.quotationId,
    this.quotationNo,
    this.productId,
    this.quotationDate,
    this.validUntil,
    this.totalAmount = 0,
    this.viewUrl,
    this.pdfUrl,
    this.downloadUrl,
    this.detailUrl,
  });

  factory QuotationSummary.fromJson(Map<String, dynamic> json) {
    return QuotationSummary(
      quotationId: _toInt(json['quotation_id']),
      quotationNo: _toStr(json['quotation_no']),
      productId: _toInt(json['product_id']),
      quotationDate: _toStr(json['quotation_date']),
      validUntil: _toStr(json['valid_until']),
      totalAmount: _toDouble(json['total_amount']),
      viewUrl: _toStr(json['view_url']),
      pdfUrl: _toStr(json['pdf_url']),
      downloadUrl: _toStr(json['download_url']),
      detailUrl: _toStr(json['detail_url']),
    );
  }

  static List<QuotationSummary> listFrom(dynamic value) =>
      _asMapList(value).map(QuotationSummary.fromJson).toList();

  String? get openUrl => viewUrl ?? pdfUrl ?? downloadUrl;
}

/// A probe/option picked by the user, with its quantity.
class SelectedQuotationItem {
  final QuotationItem item;
  int quantity;

  SelectedQuotationItem({required this.item, this.quantity = 1});

  double get lineTotal => item.totalPrice * quantity;
}
