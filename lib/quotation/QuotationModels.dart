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

/// A probe/option picked by the user, with its quantity.
class SelectedQuotationItem {
  final QuotationItem item;
  int quantity;

  SelectedQuotationItem({required this.item, this.quantity = 1});

  double get lineTotal => item.totalPrice * quantity;
}
