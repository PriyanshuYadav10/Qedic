import 'package:flutter/material.dart';

import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import '../visit/VisitListModel.dart';

class GenerateQuotation extends StatefulWidget {
  final VisitListData visitListData;

  const GenerateQuotation({Key? key, required this.visitListData})
      : super(key: key);

  @override
  State<GenerateQuotation> createState() => _GenerateQuotationState();
}

class _GenerateQuotationState extends State<GenerateQuotation> {
  int _step = 0;
  static const int _totalSteps = 5;

  // TODO: replace placeholder catalogs with backend APIs
  final List<String> _probeOptions = const [
    'Convex C5-2',
    'Linear L12-3',
    'Endocavity E8-4',
    'Phased Array P4-2',
    'Volume 4D V6-2',
  ];

  final List<String> _configurationOptions = const [
    'Basic Software Package',
    'Advanced Imaging Suite',
    'Cardiology Package',
    'OB/GYN Package',
    'Workstation Add-on',
  ];

  final List<String> _extraOptionalItems = const [
    'Extended Warranty - 2 Years',
    'Onsite Training',
    'Battery Backup',
    'Portable Trolley',
  ];

  final List<String> _optionalItems = const [
    'Carry Case',
    'Cable Set',
    'Spare Probe Cover Box',
    'AMC - 1 Year',
  ];

  final List<String> _standardTerms = const [
    'Payment: 50% advance, 50% on delivery',
    'Delivery: 4-6 weeks from PO',
    'Warranty: 1 year standard',
    'GST as applicable',
    'Validity: 30 days',
  ];

  final Set<String> _selectedProbes = {};
  final Set<String> _selectedConfigurations = {};
  final Set<String> _selectedExtraOptional = {};
  final Set<String> _selectedOptional = {};
  final Set<String> _selectedStandardTerms = {};
  final TextEditingController _additionalTermsCtrl = TextEditingController();

  @override
  void dispose() {
    _additionalTermsCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  bool _validateCurrentStep() {
    switch (_step) {
      case 0:
        if (_selectedProbes.isEmpty) {
          Commons.flushbar_Messege(context, 'Please select at least one probe');
          return false;
        }
        return true;
      case 1:
        if (_selectedConfigurations.isEmpty) {
          Commons.flushbar_Messege(
              context, 'Please select at least one configuration');
          return false;
        }
        return true;
      case 2:
      case 3:
        return true; // optional steps
      case 4:
        if (_selectedStandardTerms.isEmpty) {
          Commons.flushbar_Messege(
              context, 'Please select at least one standard term');
          return false;
        }
        return true;
    }
    return true;
  }

  void _submit() {
    // TODO: POST quotation draft to backend; backend sets status
    // 'Pending Manager Approval'. PDF download becomes available only after
    // Manager + Super Admin both approve.
    showDialog<void>(
      context: context,
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
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepLabels = const [
      'Probes',
      'Configuration',
      'Extra Optional',
      'Optional',
      'Terms & Conditions',
    ];
    return Scaffold(
      backgroundColor: HexColor(HexColor.white),
      appBar: AppBar(
        backgroundColor: HexColor(HexColor.primary_s),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _back,
        ),
        title: Text(
          'Generate Quotation',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(stepLabels),
          Expanded(child: _buildStepContent()),
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final v = widget.visitListData;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: HexColor(HexColor.gray_light),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer: ${v.custName ?? '-'}',
            style: const TextStyle(
                fontSize: 13, fontFamily: 'montserrat_medium'),
          ),
          const SizedBox(height: 4),
          Text(
            'Product: ${v.productName ?? '-'}',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'montserrat_medium',
              color: HexColor(HexColor.primary_s),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Oppty Type: ${v.opptyType ?? '-'}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final active = i == _step;
          final done = i < _step;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (active || done)
                        ? HexColor(HexColor.primary_s)
                        : HexColor(HexColor.gray_light),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: (active || done)
                          ? Colors.white
                          : HexColor(HexColor.gray_text),
                      fontSize: 12,
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
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildChecklist(
          title: 'Select Probes',
          options: _probeOptions,
          selected: _selectedProbes,
        );
      case 1:
        return _buildChecklist(
          title: 'Select Configuration',
          options: _configurationOptions,
          selected: _selectedConfigurations,
        );
      case 2:
        return _buildChecklist(
          title: 'Extra Optional Item',
          options: _extraOptionalItems,
          selected: _selectedExtraOptional,
        );
      case 3:
        return _buildChecklist(
          title: 'Optional Item',
          options: _optionalItems,
          selected: _selectedOptional,
        );
      case 4:
        return _buildTermsStep();
    }
    return const SizedBox.shrink();
  }

  Widget _buildChecklist({
    required String title,
    required List<String> options,
    required Set<String> selected,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'lato_bold',
              color: HexColor(HexColor.primarycolor),
            ),
          ),
        ),
        ...options.map((opt) {
          return CheckboxListTile(
            value: selected.contains(opt),
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  selected.add(opt);
                } else {
                  selected.remove(opt);
                }
              });
            },
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: HexColor(HexColor.primary_s),
          );
        }),
      ],
    );
  }

  Widget _buildTermsStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            'Standard Terms & Conditions',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'lato_bold',
              color: HexColor(HexColor.primarycolor),
            ),
          ),
        ),
        ..._standardTerms.map((t) {
          return CheckboxListTile(
            value: _selectedStandardTerms.contains(t),
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  _selectedStandardTerms.add(t);
                } else {
                  _selectedStandardTerms.remove(t);
                }
              });
            },
            title: Text(t, style: const TextStyle(fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: HexColor(HexColor.primary_s),
          );
        }),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            'Additional Terms & Conditions',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'lato_bold',
              color: HexColor(HexColor.primarycolor),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: _additionalTermsCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Type any additional terms here…',
              filled: true,
              fillColor: HexColor(HexColor.gray_light),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
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
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_step == 0 ? 'Cancel' : 'Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor(HexColor.primary_s),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(isLast ? 'Submit' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
