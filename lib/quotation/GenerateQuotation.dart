import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController content;
  bool included = true;

  _TermDraft({required String title, required String content})
      : title = TextEditingController(text: title),
        content = TextEditingController(text: content);

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
                content: t.content ?? '',
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
      await _api.createQuotation(
        userId: _userId ?? 0,
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
      _showSubmittedDialog();
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
        'content': _textToHtml(included[i].content.text),
        'sort_order': i + 1,
      };
    });
  }

  Future<bool?> _confirmSubmit() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Quotation?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow('Customer', _customerName.text.trim()),
            _summaryRow('Product', _product?.name ?? '-'),
            _summaryRow('Probes', '${_selectedProbes.length}'),
            _summaryRow('Options', '${_selectedOptions.length}'),
            _summaryRow('Terms', '${_terms.where((t) => t.included).length}'),
            const Divider(height: 20),
            _summaryRow('Total', _currency.format(_grandTotal), bold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor(HexColor.primary_s),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showSubmittedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Submitted for Approval'),
        content: const Text(
          'Quotation has been submitted. It will be reviewed by your Manager '
          'and then by Super Admin. You can download the PDF once both have '
          'approved.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
              _htmlToText(term.content.text),
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

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Term'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleDraft,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentDraft,
                  maxLines: 10,
                  minLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor(HexColor.primary_s),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
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
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        inputFormatters: formatters,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: Colors.white,
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

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: HexColor(HexColor.gray_text),
              fontFamily: 'montserrat_regular',
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontFamily:
                    bold ? 'montserrat_bold' : 'montserrat_medium',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The API stores rich text, but the app edits plain text — strip tags coming
/// in and wrap paragraphs going back out.
String _htmlToText(String? html) {
  if (html == null || html.trim().isEmpty) return '';
  return html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|li|ul|ol|h[1-6])>', caseSensitive: false),
          '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
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
