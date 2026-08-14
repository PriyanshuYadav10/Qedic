import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/LoginModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import '../visit/VisitListModel.dart';
import 'QuotationApi.dart';
import 'QuotationModels.dart';

class GenerateQuotation extends StatefulWidget {
  final VisitListData visitListData;

  const GenerateQuotation({Key? key, required this.visitListData})
      : super(key: key);

  @override
  State<GenerateQuotation> createState() => _GenerateQuotationState();
}

/// One editable term row on the Terms & Conditions step.
class _TermDraft {
  final TextEditingController title;

  /// Plain text — what the user reads and edits. The server stores rich HTML,
  /// which is unreadable in a TextField.
  final TextEditingController content;

  /// The server's original HTML, kept so an untouched term round-trips with its
  /// formatting intact instead of being flattened into `<p>` blocks.
  final String? originalHtml;
  final String originalText;

  bool included = true;

  _TermDraft({
    required String title,
    required String content,
    this.originalHtml,
  })  : title = TextEditingController(text: title),
        content = TextEditingController(text: content),
        originalText = content;

  /// Send back the original HTML when the text is untouched — the PDF keeps its
  /// headings, bullets and bold runs. Edited terms get re-wrapped from plain
  /// text, which necessarily loses that formatting.
  String get contentForApi {
    final current = content.text.trim();
    if (originalHtml != null && current == originalText.trim()) {
      return originalHtml!;
    }
    return _textToHtml(current);
  }

  void dispose() {
    title.dispose();
    content.dispose();
  }
}

class _GenerateQuotationState extends State<GenerateQuotation> {
  static const int _totalSteps = 5;
  static const List<String> _stepLabels = [
    'Customer',
    'Probes',
    'Options',
    'Details',
    'Terms',
  ];

  final QuotationApi _api = QuotationApi();
  final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

  int _step = 0;
  bool _loading = true;
  bool _submitting = false;
  String? _loadError;

  QuotationProduct? _product;
  int? _userId;

  /// The visit/opportunity row this quotation is raised against. It arrives as
  /// a dynamic from the list model, so parse rather than cast.
  int? get _visitId => int.tryParse('${widget.visitListData.id ?? ''}');

  // Step 0 — customer + sales contact
  final _customerName = TextEditingController();
  final _customerAddress = TextEditingController();
  final _customerPhone = TextEditingController();
  final _customerEmail = TextEditingController();
  final _salesName = TextEditingController();
  final _salesDesignation = TextEditingController(text: 'QEDIC Sales-Team');
  final _salesPhone = TextEditingController();
  final _salesEmail = TextEditingController();

  // Steps 1 & 2 — probe / option selection keyed by item id
  final Map<int, SelectedQuotationItem> _selectedProbes = {};
  final Map<int, SelectedQuotationItem> _selectedOptions = {};
  String _probeQuery = '';
  String _optionQuery = '';

  // Step 3 — quotation overrides
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _specifications = TextEditingController();
  final _warranty = TextEditingController();
  final _notes = TextEditingController();
  final _validityDays = TextEditingController(text: '30');

  // Step 4 — terms
  final List<_TermDraft> _terms = [];

  @override
  void initState() {
    super.initState();
    _prefillCustomer();
    _loadEverything();
  }

  @override
  void dispose() {
    for (final c in [
      _customerName,
      _customerAddress,
      _customerPhone,
      _customerEmail,
      _salesName,
      _salesDesignation,
      _salesPhone,
      _salesEmail,
      _title,
      _description,
      _specifications,
      _warranty,
      _notes,
      _validityDays,
    ]) {
      c.dispose();
    }
    for (final t in _terms) {
      t.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------- loading

  void _prefillCustomer() {
    final v = widget.visitListData;
    _customerName.text = '${v.custName ?? ''}'.trim();
    _customerAddress.text = [
      '${v.address ?? ''}'.trim(),
      '${v.cityName ?? ''}'.trim(),
      '${v.district ?? ''}'.trim(),
    ].where((e) => e.isNotEmpty).join(', ');
    _customerPhone.text = '${v.contactNumber ?? ''}'.trim();
    _customerEmail.text = '${v.email ?? ''}'.trim();
  }

  Future<void> _loadEverything() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      await _loadSalesContact();
      final productName = '${widget.visitListData.productName ?? ''}'.trim();
      if (productName.isEmpty) {
        throw QuotationApiException(
          'This opportunity has no product linked to it.',
        );
      }
      final response = await _api.getQuotationProduct(productName);
      if (!mounted) return;
      _applyProduct(response);
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e is QuotationApiException ? e.message : '$e';
      });
    }
  }

  Future<void> _loadSalesContact() async {
    try {
      final LoginModel login = await Commons.getuser_info();
      final data = login.data;
      if (data == null) return;
      _userId = data.id;
      final name = [
        '${data.firstName ?? ''}'.trim(),
        '${data.lastName ?? ''}'.trim(),
      ].where((e) => e.isNotEmpty).join(' ');
      _salesName.text = name;
      final designation = '${data.designation ?? ''}'.trim();
      if (designation.isNotEmpty) _salesDesignation.text = designation;
      _salesPhone.text = '${data.mobile ?? ''}'.trim();
      _salesEmail.text = '${data.email ?? ''}'.trim();
    } catch (_) {
      // Sales contact stays editable when the cached profile can't be read.
    }
  }

  void _applyProduct(QuotationProductResponse response) {
    final product = response.product;
    _product = product;
    _title.text = product.displayTitle;
    _description.text =
        _htmlToText(product.description ?? product.shortDescription);
    _specifications.text = _htmlToText(product.specifications);
    _warranty.text = _htmlToText(product.warranty);

    for (final t in _terms) {
      t.dispose();
        }
        _terms
      ..clear()
      ..addAll(
        ([...response.termsAndConditions]
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
            .map(
              (t) => _TermDraft(
                title: t.title ?? '',
                content: _htmlToText(t.content),
                originalHtml: t.content,
              ),
            ),
      );
  }

  // ------------------------------------------------------------- navigation

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_validateCurrentStep()) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  bool _validateCurrentStep() {
    switch (_step) {
      case 0:
        if (_customerName.text.trim().isEmpty) {
          return _fail('Please enter the customer name');
        }
        return true;
      case 1:
        if (_selectedProbes.isEmpty) {
          return _fail('Please select at least one probe');
        }
        return true;
      case 2:
        return true; // options are optional
      case 3:
        if (_title.text.trim().isEmpty) {
          return _fail('Please enter a quotation title');
        }
        final days = int.tryParse(_validityDays.text.trim());
        if (days == null || days <= 0) {
          return _fail('Please enter a valid validity in days');
        }
        return true;
      case 4:
        if (_terms.where((t) => t.included).isEmpty) {
          return _fail('Please include at least one term');
        }
        for (final t in _terms.where((t) => t.included)) {
          if (t.title.text.trim().isEmpty || t.content.text.trim().isEmpty) {
            return _fail('Every included term needs a title and content');
          }
        }
        return true;
    }
    return true;
  }

  bool _fail(String message) {
    Commons.flushbar_Messege(context, message);
    return false;
  }

  // ----------------------------------------------------------------- submit

  Future<void> _submit() async {
    final product = _product;
    if (product?.id == null) {
      _fail('Product could not be resolved. Please reload.');
      return;
    }
    final confirmed = await _confirmSubmit();
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      final created = await _api.createQuotation(
        userId: _userId ?? 0,
        visitId: _visitId,
        productId: product!.id!,
        customer: {
          'name': _customerName.text.trim(),
          'address': _customerAddress.text.trim(),
          'phone': _customerPhone.text.trim(),
          'email': _customerEmail.text.trim(),
        },
        salesContact: {
          'name': _salesName.text.trim(),
          'designation': _salesDesignation.text.trim(),
          'phone': _salesPhone.text.trim(),
          'email': _salesEmail.text.trim(),
        },
        selectedProbes: _selectedProbes.values.toList(),
        selectedOptions: _selectedOptions.values.toList(),
        quotationOverrides: {
          'title': _title.text.trim(),
          'description': _textToHtml(_description.text),
          'specifications': _textToHtml(_specifications.text),
          'warranty': _textToHtml(_warranty.text),
          'notes': _textToHtml(_notes.text),
          'validity_days': int.tryParse(_validityDays.text.trim()) ?? 30,
        },
        termsAndConditions: _includedTermsPayload(),
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      _showSubmittedDialog(created);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      Commons.flushbar_Messege(
        context,
        e is QuotationApiException ? e.message : 'Something went wrong',
      );
    }
  }

  List<Map<String, dynamic>> _includedTermsPayload() {
    final included = _terms.where((t) => t.included).toList();
    return List.generate(included.length, (i) {
      return {
        'title': included[i].title.text.trim(),
        'content': included[i].contentForApi,
        'sort_order': i + 1,
      };
    });
  }

  Future<bool?> _confirmSubmit() {
    final termCount = _terms.where((t) => t.included).length;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => _QuotationDialog(
        icon: Icons.fact_check_outlined,
        accent: HexColor(HexColor.primary_s),
        title: 'Submit Quotation?',
        subtitle:
            'It goes to your Manager and then Super Admin for approval.',
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogCard([
              _summaryRow('Customer', _customerName.text.trim()),
              _summaryRow('Product', _product?.name ?? '-'),
              _summaryRow('Probes', '${_selectedProbes.length}'),
              _summaryRow('Options', '${_selectedOptions.length}'),
              _summaryRow('Terms', '$termCount'),
            ]),
            const SizedBox(height: 12),
            _totalStrip('Estimated Total', _grandTotal),
          ],
        ),
        actions: [
          Expanded(
            child: _dialogButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _dialogButton(
              label: 'Submit',
              primary: true,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmittedDialog(CreatedQuotation created) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _QuotationDialog(
        icon: Icons.check_circle_rounded,
        accent: HexColor(HexColor.green_txt),
        title: 'Quotation Generated',
        subtitle: 'Open the PDF now, or find it later on the opportunity.',
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogCard([
              if (created.quotationNo != null)
                _summaryRow('Quotation No', created.quotationNo!),
              if (created.quotationDate != null)
                _summaryRow('Date', _dateOnly(created.quotationDate!)),
              if (created.validUntil != null)
                _summaryRow('Valid Until', _dateOnly(created.validUntil!)),
            ]),
            const SizedBox(height: 12),
            _totalStrip('Total', created.totalAmount),
          ],
        ),
        actions: [
          Expanded(
            child: _dialogButton(
              label: 'View',
              icon: Icons.visibility_outlined,
              onPressed: () => _openUrl(created.openUrl),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _dialogButton(
              label: 'Download',
              icon: Icons.download_rounded,
              primary: true,
              onPressed: () => _openUrl(created.downloadUrl ?? created.pdfUrl),
            ),
          ),
        ],
        footer: TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            Navigator.of(context).pop(true);
          },
          style: TextButton.styleFrom(
            foregroundColor: HexColor(HexColor.gray_text),
          ),
          child: const Text(
            'Done',
            style: TextStyle(fontSize: 13, fontFamily: 'montserrat_medium'),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) {
      _fail('No document link was returned for this quotation');
      return;
    }
    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) _fail('Could not open the quotation PDF');
    } catch (_) {
      if (mounted) _fail('Could not open the quotation PDF');
    }
  }

  // ------------------------------------------------------------------ maths

  double get _grandTotal {
    double total = _product?.totalPrice ?? 0;
    for (final p in _selectedProbes.values) {
      total += p.lineTotal;
    }
    for (final o in _selectedOptions.values) {
      total += o.lineTotal;
    }
    return total;
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(HexColor.gray_activity_background),
      appBar: AppBar(
        backgroundColor: HexColor(HexColor.primary_s),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _back,
        ),
        title: const Text(
          'Generate Quotation',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildError()
              : Column(
                  children: [
                    _buildHeader(),
                    _buildStepIndicator(),
                    Expanded(child: _buildStepContent()),
                    _buildTotalBar(),
                    _buildNavButtons(),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 42, color: HexColor(HexColor.red_color)),
            const SizedBox(height: 12),
            Text(
              _loadError ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: HexColor(HexColor.gray_text),
                fontFamily: 'montserrat_regular',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor(HexColor.primary_s),
                foregroundColor: Colors.white,
              ),
              onPressed: _loadEverything,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final v = widget.visitListData;
    final product = _product;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${v.custName ?? '-'}',
            style: const TextStyle(
                fontSize: 14, fontFamily: 'montserrat_medium'),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  product == null
                      ? '${v.productName ?? '-'}'
                      : '${product.displayTitle}'
                          '${product.modelCode == null ? '' : ' • ${product.modelCode}'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'montserrat_medium',
                    color: HexColor(HexColor.primary_s),
                  ),
                ),
              ),
              Text(
                '${v.opptyType ?? '-'}',
                style: TextStyle(
                  fontSize: 11,
                  color: HexColor(HexColor.gray_text),
                  fontFamily: 'montserrat_regular',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(15, 4, 15, 10),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (i) {
              final active = i == _step;
              final done = i < _step;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (active || done)
                            ? HexColor(HexColor.primary_s)
                            : HexColor(HexColor.gray_light),
                      ),
                      child: done
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : HexColor(HexColor.gray_text),
                                fontSize: 11,
                              ),
                            ),
                    ),
                    if (i < _totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: done
                              ? HexColor(HexColor.primary_s)
                              : HexColor(HexColor.gray_light),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Step ${_step + 1} of $_totalSteps — ${_stepLabels[_step]}',
              style: TextStyle(
                fontSize: 12,
                color: HexColor(HexColor.gray_text),
                fontFamily: 'montserrat_medium',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildContactStep();
      case 1:
        return _buildItemStep(
          title: 'Select Probes',
          items: _product?.probes ?? const [],
          selection: _selectedProbes,
          query: _probeQuery,
          onQuery: (v) => setState(() => _probeQuery = v),
          emptyMessage: 'No probes configured for this product',
        );
      case 2:
        return _buildItemStep(
          title: 'Select Options',
          items: _product?.options ?? const [],
          selection: _selectedOptions,
          query: _optionQuery,
          onQuery: (v) => setState(() => _optionQuery = v),
          emptyMessage: 'No options configured for this product',
        );
      case 3:
        return _buildDetailsStep();
      case 4:
        return _buildTermsStep();
    }
    return const SizedBox.shrink();
  }

  // ------------------------------------------------------------ step 0: who

  Widget _buildContactStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 20),
      children: [
        _sectionTitle('Customer Details'),
        _field('Customer Name', _customerName),
        _field('Address', _customerAddress, maxLines: 3),
        _field('Phone', _customerPhone, keyboard: TextInputType.phone),
        _field('Email', _customerEmail, keyboard: TextInputType.emailAddress),
        const SizedBox(height: 8),
        _sectionTitle('Sales Contact'),
        _field('Name', _salesName),
        _field('Designation', _salesDesignation),
        _field('Phone', _salesPhone, keyboard: TextInputType.phone),
        _field('Email', _salesEmail, keyboard: TextInputType.emailAddress),
      ],
    );
  }

  // ------------------------------------------------- steps 1 & 2: line items

  Widget _buildItemStep({
    required String title,
    required List<QuotationItem> items,
    required Map<int, SelectedQuotationItem> selection,
    required String query,
    required ValueChanged<String> onQuery,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: HexColor(HexColor.gray_text),
              fontFamily: 'montserrat_regular',
            ),
          ),
        ),
      );
    }

    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where((i) {
            return (i.name ?? '').toLowerCase().contains(q) ||
                (i.description ?? '').toLowerCase().contains(q) ||
                (i.modelCode ?? '').toLowerCase().contains(q);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 8),
          child: Row(
            children: [
              Expanded(child: _sectionTitle(title, padded: false)),
              Text(
                '${selection.length} selected',
                style: TextStyle(
                  fontSize: 12,
                  color: HexColor(HexColor.primary_s),
                  fontFamily: 'montserrat_medium',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            onChanged: onQuery,
            decoration: InputDecoration(
              hintText: 'Search…',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No matches',
                    style: TextStyle(
                      fontSize: 13,
                      color: HexColor(HexColor.gray_text),
                      fontFamily: 'montserrat_regular',
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      _itemTile(filtered[i], selection),
                ),
        ),
      ],
    );
  }

  Widget _itemTile(QuotationItem item, Map<int, SelectedQuotationItem> selection) {
    final id = item.id;
    final selected = id != null && selection.containsKey(id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected
              ? HexColor(HexColor.primary_s)
              : HexColor(HexColor.gray_light),
        ),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: selected,
            onChanged: id == null
                ? null
                : (v) {
                    setState(() {
                      if (v == true) {
                        selection[id] = SelectedQuotationItem(item: item);
                      } else {
                        selection.remove(id);
                      }
                    });
                  },
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: HexColor(HexColor.primary_s),
            dense: true,
            title: Text(
              item.name ?? '-',
              style: const TextStyle(
                  fontSize: 13, fontFamily: 'montserrat_medium'),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description != null)
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 11,
                      color: HexColor(HexColor.gray_text),
                      fontFamily: 'montserrat_regular',
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  _currency.format(item.totalPrice),
                  style: TextStyle(
                    fontSize: 12,
                    color: HexColor(HexColor.primary_s),
                    fontFamily: 'montserrat_medium',
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 12, 10),
              child: Row(
                children: [
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 12,
                      color: HexColor(HexColor.gray_text),
                      fontFamily: 'montserrat_regular',
                    ),
                  ),
                  const Spacer(),
                  _qtyButton(
                    Icons.remove_rounded,
                    () => _changeQty(selection, id, -1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${selection[id]!.quantity}',
                      style: const TextStyle(
                          fontSize: 14, fontFamily: 'montserrat_medium'),
                    ),
                  ),
                  _qtyButton(
                    Icons.add_rounded,
                    () => _changeQty(selection, id, 1),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _currency.format(selection[id]!.lineTotal),
                    style: const TextStyle(
                        fontSize: 12, fontFamily: 'montserrat_medium'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _changeQty(
    Map<int, SelectedQuotationItem> selection,
    int id,
    int delta,
  ) {
    final entry = selection[id];
    if (entry == null) return;
    final next = entry.quantity + delta;
    if (next < 1) return;
    setState(() => entry.quantity = next);
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HexColor(HexColor.gray_light),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: HexColor(HexColor.black)),
      ),
    );
  }

  // -------------------------------------------------------- step 3: details

  Widget _buildDetailsStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 20),
      children: [
        _sectionTitle('Quotation Details'),
        _field('Title', _title, maxLines: 2),
        _field('Description', _description, maxLines: 4),
        _field('Specifications', _specifications, maxLines: 5),
        _field('Warranty', _warranty, maxLines: 3),
        _field('Notes', _notes, maxLines: 3),
        _field(
          'Validity (days)',
          _validityDays,
          keyboard: TextInputType.number,
          formatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  // ---------------------------------------------------------- step 4: terms

  Widget _buildTermsStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionTitle('Terms & Conditions', padded: false),
            ),
            TextButton.icon(
              onPressed: _addTerm,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: HexColor(HexColor.primary_s),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_terms.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No standard terms returned. Add your own using the button above.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: HexColor(HexColor.gray_text),
                fontFamily: 'montserrat_regular',
              ),
            ),
          ),
        ...List.generate(_terms.length, (i) => _termCard(i)),
      ],
    );
  }

  Widget _termCard(int index) {
    final term = _terms[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: term.included
              ? HexColor(HexColor.primary_s)
              : HexColor(HexColor.gray_light),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: term.included,
                activeColor: HexColor(HexColor.primary_s),
                onChanged: (v) =>
                    setState(() => term.included = v ?? false),
              ),
              Expanded(
                child: Text(
                  term.title.text.trim().isEmpty
                      ? 'Untitled term'
                      : term.title.text.trim(),
                  style: const TextStyle(
                      fontSize: 13, fontFamily: 'montserrat_medium'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 18, color: HexColor(HexColor.gray_text)),
                onPressed: () => _editTerm(index),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 18, color: HexColor(HexColor.red_color)),
                onPressed: () => _removeTerm(index),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              term.content.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: HexColor(HexColor.gray_text),
                fontFamily: 'montserrat_regular',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTerm() {
    setState(() => _terms.add(_TermDraft(title: '', content: '')));
    _editTerm(_terms.length - 1);
  }

  void _removeTerm(int index) {
    setState(() {
      _terms.removeAt(index).dispose();
    });
  }

  Future<void> _editTerm(int index) async {
    final term = _terms[index];
    final titleDraft = TextEditingController(text: term.title.text);
    final contentDraft = TextEditingController(text: term.content.text);

    final isNew = term.title.text.trim().isEmpty &&
        term.content.text.trim().isEmpty;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => _QuotationDialog(
        icon: Icons.edit_note_rounded,
        accent: HexColor(HexColor.primary_s),
        title: isNew ? 'Add Term' : 'Edit Term',
        subtitle: 'Plain text. Formatting is applied when the PDF is built.',
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Title', titleDraft, fillColor: HexColor(HexColor.gray_light)),
            _field(
              'Content',
              contentDraft,
              maxLines: 8,
              minLines: 5,
              fillColor: HexColor(HexColor.gray_light),
            ),
          ],
        ),
        actions: [
          Expanded(
            child: _dialogButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _dialogButton(
              label: 'Save',
              primary: true,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ),
        ],
      ),
    );

    if (saved == true) {
      setState(() {
        term.title.text = titleDraft.text;
        term.content.text = contentDraft.text;
      });
    }
    titleDraft.dispose();
    contentDraft.dispose();
  }

  // ------------------------------------------------------------ footer bits

  Widget _buildTotalBar() {
    final product = _product;
    if (product == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Estimated Total',
            style: TextStyle(
              fontSize: 12,
              color: HexColor(HexColor.gray_text),
              fontFamily: 'montserrat_regular',
            ),
          ),
          const Spacer(),
          Text(
            _currency.format(_grandTotal),
            style: TextStyle(
              fontSize: 16,
              color: HexColor(HexColor.primary_s),
              fontFamily: 'montserrat_bold',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    final isLast = _step == _totalSteps - 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : _back,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_step == 0 ? 'Cancel' : 'Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitting ? null : _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor(HexColor.primary_s),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(isLast ? 'Submit' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- small bits

  Widget _sectionTitle(String text, {bool padded = true}) {
    return Padding(
      padding: EdgeInsets.only(bottom: padded ? 10 : 0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontFamily: 'montserrat_bold',
          color: HexColor(HexColor.primarycolor),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    int? minLines,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    Color? fillColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: keyboard,
        inputFormatters: formatters,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: fillColor ?? Colors.white,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: HexColor(HexColor.gray_light)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: HexColor(HexColor.gray_light)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: HexColor(HexColor.primary_s)),
          ),
        ),
      ),
    );
  }

  /// A fixed-width label keeps long values (customer names, quotation numbers)
  /// wrapping on the right instead of crushing the label.
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: HexColor(HexColor.gray_text),
                fontFamily: 'montserrat_regular',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.3,
                fontFamily: 'montserrat_medium',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogCard(List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: HexColor(HexColor.gray_activity_background),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HexColor(HexColor.gray_light)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }

  Widget _totalStrip(String label, double amount) {
    final accent = HexColor(HexColor.primary_s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: HexColor(HexColor.gray_text),
              fontFamily: 'montserrat_medium',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _currency.format(amount),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 17,
                color: accent,
                fontFamily: 'montserrat_bold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared shell for this screen's dialogs: icon header, scrollable body, and a
/// button row that never gets pushed off-screen by the keyboard.
class _QuotationDialog extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final Widget? footer;

  const _QuotationDialog({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    required this.actions,
    this.subtitle,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          // Subtracting the keyboard inset is what stops a focused text field
          // from pushing the action row past the bottom of the screen.
          maxHeight: media.size.height - media.viewInsets.bottom - 96,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 21, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            color: HexColor(HexColor.black),
                            fontFamily: 'montserrat_bold',
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              color: HexColor(HexColor.gray_text),
                              fontFamily: 'montserrat_regular',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
                child: body,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, footer == null ? 20 : 6),
              child: Row(children: actions),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Center(child: footer),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _dialogButton({
  required String label,
  required VoidCallback onPressed,
  IconData? icon,
  bool primary = false,
}) {
  final accent = HexColor(HexColor.primary_s);
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );
  const padding = EdgeInsets.symmetric(vertical: 13);
  final text = Text(
    label,
    style: const TextStyle(fontSize: 13, fontFamily: 'montserrat_medium'),
  );

  if (primary) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: padding,
      shape: shape,
    );
    return icon == null
        ? ElevatedButton(style: style, onPressed: onPressed, child: text)
        : ElevatedButton.icon(
            style: style,
            onPressed: onPressed,
            icon: Icon(icon, size: 17),
            label: text,
          );
  }

  final style = OutlinedButton.styleFrom(
    foregroundColor: accent,
    side: BorderSide(color: accent),
    padding: padding,
    shape: shape,
  );
  return icon == null
      ? OutlinedButton(style: style, onPressed: onPressed, child: text)
      : OutlinedButton.icon(
          style: style,
          onPressed: onPressed,
          icon: Icon(icon, size: 17),
          label: text,
        );
}

/// The API stores rich text, but the app edits plain text — strip tags coming
/// in and wrap paragraphs going back out.
String _htmlToText(String? html) {
  if (html == null || html.trim().isEmpty) return '';

  final stripped = html
      .replaceAll(
          RegExp(r'<(script|style)[^>]*>.*?</\1>',
              caseSensitive: false, dotAll: true),
          '')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      // List items read as a wall of text without their markers.
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ')
      .replaceAll(
          RegExp(r'</(p|div|li|ul|ol|tr|h[1-6])>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '');

  return _decodeHtmlEntities(stripped)
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n')
      .map((line) => line.trimRight())
      .join('\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

const Map<String, String> _namedHtmlEntities = {
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'ndash': '–',
  'mdash': '—',
  'lsquo': '‘',
  'rsquo': '’',
  'ldquo': '“',
  'rdquo': '”',
  'bull': '•',
  'middot': '·',
  'hellip': '…',
  'times': '×',
  'deg': '°',
  'trade': '™',
  'copy': '©',
  'reg': '®',
  'rarr': '→',
  'check': '✓',
};

/// Decodes named and numeric entities in a single pass, so an escaped sequence
/// like `&amp;lt;` yields `&lt;` rather than being decoded twice into `<`.
String _decodeHtmlEntities(String input) {
  return input.replaceAllMapped(
    RegExp(r'&(#[xX]?[0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]*);'),
    (match) {
      final entity = match.group(1)!;
      if (entity.startsWith('#')) {
        final isHex = entity.length > 1 && (entity[1] == 'x' || entity[1] == 'X');
        final digits = isHex ? entity.substring(2) : entity.substring(1);
        final code = int.tryParse(digits, radix: isHex ? 16 : 10);
        if (code != null && code > 0 && code <= 0x10FFFF) {
          return String.fromCharCode(code);
        }
        return match.group(0)!;
      }
      return _namedHtmlEntities[entity.toLowerCase()] ?? match.group(0)!;
    },
  );
}

/// The API returns full ISO timestamps; the UI only ever wants the date.
String _dateOnly(String value) {
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(value));
  } catch (_) {
    return value;
  }
}

String _textToHtml(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '';
  if (RegExp(r'<[a-z][^>]*>', caseSensitive: false).hasMatch(trimmed)) {
    return trimmed;
  }
  return trimmed
      .split(RegExp(r'\n{2,}'))
      .map((p) => '<p>${_escapeHtml(p).replaceAll('\n', '<br />')}</p>')
      .join();
}

String _escapeHtml(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
