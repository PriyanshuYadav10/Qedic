import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';

import '../apis/app_exception.dart';
import 'AllListingModel.dart';
import 'ExistingMachineModel.dart';
import '../model/LoginModel.dart';
import '../model/SuccessModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';

class AddVisit extends StatefulWidget {
  @override
  State<AddVisit> createState() => _AddVisitState();
}

class _AddVisitState extends State<AddVisit> {
  String _selecteddate = '';
  TextEditingController cust_name_Controller = TextEditingController();
  bool cust_name_validate = false;
  TextEditingController center_name_Controller = TextEditingController();
  bool center_name_validate = false;

  TextEditingController city_nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  bool city_namevalidate = false;

  TextEditingController contact_numberController = TextEditingController();
  bool contact_numbervalidate = false;

  TextEditingController email_Controller = TextEditingController();
  bool email_validate = false;

  TextEditingController existing_machineController = TextEditingController();
  bool existing_machinevalidate = false;

  TextEditingController existingMachineCompanyController =
      TextEditingController();
  bool existingMachineCompanyvalidate = false;

  TextEditingController existing_machineCapacityController =
      TextEditingController();
  bool existing_machineCapacityvalidate = false;

  TextEditingController other_ModelController = TextEditingController();
  bool other_Modelvalidate = false;

  TextEditingController usg_ageingController = TextEditingController();
  bool usg_ageingvalidate = false;

  TextEditingController qualityController = TextEditingController();
  bool qualityvalidate = false;
  TextEditingController valueController = TextEditingController();
  bool valueValidate = false;

  TextEditingController product_nameController = TextEditingController();
  TextEditingController selected_purpose = TextEditingController();
  TextEditingController oppty_type = TextEditingController();
  TextEditingController productCategoryCtrl = TextEditingController();
  TextEditingController pnditCtrl = TextEditingController();
  TextEditingController quotationSubmitCtrl = TextEditingController();
  TextEditingController modalityCtrl = TextEditingController();
  TextEditingController demoDoneCtrl = TextEditingController();
  TextEditingController statusCtrl = TextEditingController();
  TextEditingController winlossDateCtrl = TextEditingController();
  bool product_namevalidate = false;

  // TextEditingController oppty_typeController = TextEditingController();

  AllListingData? listing_Data;
  List<ExistingMachineData> product_listing_Data = [];
  final List<String> oppt = ["Hot", "Cold", "Warm", "Won", "Loss", "Abandon"];
  final List<String> productCategory = ["Channel", "Direct"];
  final List<String> pndit = ["Yes", "No", "Applied", "NA"];
  final List<String> quotationSubmit = ["Yes", "No", "NA"];
  final List<String> demoDone = ["Yes", "Requested", "NA"];
  final List<String> status = ["Active", "Inactive"];
  final List<String> modality = [
    "USG",
    "X-Ray/CT-Scan",
    "MRI",
    "Refurbished Equipment",
    "Other"
  ];
  String existingMachineCompanyId = "";
  String winLossCompanyId = "";
  String winLossProductId = "";
  String referenceId = "";
  String existingMachineId = "";
  final List<String> purpose = [
    "Customer Meeting",
    "Official Meeting",
    "Service",
    "Application",
  ];

  final List<String> machineAgeing = [
    "10 Years",
    "5 Years",
    "NA",
  ];
  bool oppty_typevalidate = false;

  TextEditingController expected_closure_dateController =
      TextEditingController();
  bool expected_closure_datevalidate = false;
  FocusNode _focus = FocusNode();

  TextEditingController remark_supportController = TextEditingController();
  bool remark_supportvalidate = false;

  TextEditingController support_requiredController = TextEditingController();
  TextEditingController commentsController = TextEditingController();
  bool support_requiredvalidate = false;

  TextEditingController Win_Lost_CompanyController = TextEditingController();
  TextEditingController referenceController = TextEditingController();
  bool Win_Lost_Companyvalidate = false;
  TextEditingController Win_Lost_ProductController = TextEditingController();
  bool Win_Lost_Productvalidate = false;
  @override
  void initState() {
    allListing();
    super.initState();

  }

  bool isCheck = false;
  bool foreCast = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
          child: SafeArea(
        child: Scaffold(
            backgroundColor: HexColor(HexColor.gray_activity_background),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: AppBar(
                title: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Container(
                        child: Text("New Visit",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              color: HexColor(HexColor.white),
                              fontFamily: 'montserrat_medium',
                              decoration: TextDecoration.none,
                            )),
                      ),
                    )
                  ],
                ),
                centerTitle: true,
                backgroundColor: HexColor(HexColor.primary_s),
                elevation: 0,
                automaticallyImplyLeading: false,
                systemOverlayStyle: SystemUiOverlayStyle(
                  // Status bar color
                  statusBarColor: HexColor(HexColor.primary_s),
                  // Status bar brightness (optional)
                  statusBarIconBrightness: Brightness.light,
                  // For Android (dark icons)
                  statusBarBrightness: Brightness.light, // For iOS (dark icons)
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Purpose",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Commons.commonBottomSheet(
                              'Select Purpose',
                              purpose.map((e) => e).toList(),
                              selected_purpose,
                              context, (selectedData) {
                            setState(() {
                              selected_purpose.text = selectedData;
                              print(selectedData);
                            });
                          });
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 5),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: HexColor(HexColor.gray_text),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selected_purpose.text.isEmpty
                                  ? "Select Purpose"
                                  : selected_purpose.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor(HexColor.black),
                                fontFamily: 'montserrat_regular',
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 30,
                              color: HexColor(HexColor.gray_text),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 20.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Customer Name",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        focusNode: _focus,
                        controller: cust_name_Controller,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person_pin_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText: cust_name_Controller.text.isEmpty &&
                                    cust_name_validate
                                ? "Enter Customer Name"
                                : null,
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Customer Name",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 20.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Center Name",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: center_name_Controller,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.add_business_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText: center_name_Controller.text.isEmpty &&
                                    center_name_validate
                                ? "Enter Center Name"
                                : null,
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Center Name",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Address",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: addressController,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Address",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "District",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: districtController,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter District",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "City",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: city_nameController,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText: city_nameController.text.isEmpty &&
                                    city_namevalidate
                                ? "Enter City"
                                : null,
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter City",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Contact Number",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: contact_numberController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        maxLength: 10,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.add_ic_call_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText: contact_numberController.text.isEmpty &&
                                    contact_numbervalidate
                                ? "Enter Contact Number"
                                : null,
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Contact Number",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Email ID",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: email_Controller,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.attach_email_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText:
                                email_Controller.text.isEmpty && email_validate
                                    ? "Enter Email ID"
                                    : null,
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Email ID",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Existing Machine Company",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                            FocusScope.of(context).requestFocus(FocusNode());
                          Commons.commonBottomSheet(
                              'Existing Machine Company',
                              listing_Data?.machineComapny
                                  ?.map((e) => e.name)
                                  .toList(),
                              existingMachineCompanyController,
                              context, (selectedData) {
                            setState(() {
                              for (var company
                                  in listing_Data!.machineComapny!) {
                                if (company.name.toString() == selectedData) {
                                  existingMachineCompanyId =
                                      company.id.toString();
                                  break;
                                }
                              }
                              existingMachineCompanyController.text =
                                  selectedData;
                              print('Selected ID: $existingMachineCompanyId');
                              if (existingMachineCompanyId != '') {
                                existingMachineId = '';
                                existing_machineController.clear();
                                productListing(existingMachineCompanyId);
                              }
                              // Update UI with selected data
                              print(selectedData);
                            });
                          });
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 0, top: 5),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: HexColor(HexColor.gray_text),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              existingMachineCompanyController.text.isEmpty
                                  ? "Enter Existing Machine Company"
                                  : existingMachineCompanyController.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor(HexColor.black),
                                fontFamily: 'montserrat_regular',
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 30,
                              color: HexColor(HexColor.gray_text),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Existing Machine Model",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (product_listing_Data.isNotEmpty) {
                            Commons.commonBottomSheet(
                                'Existing Machine Model',
                                product_listing_Data
                                    .map((e) => e.name)
                                    .toList(),
                                existing_machineController,
                                context, (selectedData) {
                              setState(() {
                                for (var company in product_listing_Data!) {
                                  if (company.name.toString() == selectedData) {
                                    existingMachineId = company.id.toString();
                                    break;
                                  }
                                }
                                // Update UI with selected data
                                print(selectedData);
                                existing_machineController.text = selectedData;
                              });
                            });
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 0, top: 5),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: HexColor(HexColor.gray_text),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              existing_machineController.text.isEmpty
                                  ? "Enter Existing Machine Model"
                                  : existing_machineController.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor(HexColor.black),
                                fontFamily: 'montserrat_regular',
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 30,
                              color: HexColor(HexColor.gray_text),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: existing_machineController.text == 'Other',
                      child: Container(
                        margin: const EdgeInsets.only(left: 25, top: 15.0),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Other Model",
                          style: TextStyle(
                            fontSize: 16,
                            color: HexColor(HexColor.primarycolor),
                            fontFamily: 'lato_bold',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: existing_machineController.text == 'Other',
                      child: Container(
                        margin:
                            const EdgeInsets.only(top: 3, left: 20, right: 20),
                        child: TextField(
                          controller: other_ModelController,
                          style: TextStyle(color: HexColor(HexColor.primary_s)),
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.move_down_outlined,
                                color: HexColor(HexColor.primary_s),
                              ),
                              errorText: other_ModelController.text.isEmpty &&
                                      other_Modelvalidate
                                  ? "Other Model"
                                  : null,
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HexColor(HexColor.gray_light))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HexColor(HexColor.gray_light))),
                              filled: true,
                              hintText: "Other Model",
                              fillColor: HexColor(HexColor.gray_light)),
                        ),
                      ),
                    ),
                    // Container(
                    //   margin: const EdgeInsets.only(left: 25, top: 15.0),
                    //   alignment: Alignment.bottomLeft,
                    //   child: Text(
                    //     "Existing Machine Capacity",
                    //     style: TextStyle(
                    //       fontSize: 16,
                    //       color: HexColor(HexColor.primarycolor),
                    //       fontFamily: 'lato_bold',
                    //       decoration: TextDecoration.none,
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   margin: const EdgeInsets.only(top: 3, left: 20, right: 20),
                    //   child: TextField(
                    //     controller: existing_machineCapacityController,
                    //     style: TextStyle(color: HexColor(HexColor.primary_s)),
                    //     decoration: InputDecoration(
                    //         prefixIcon: Icon(
                    //           Icons.reduce_capacity_rounded,
                    //           color: HexColor(HexColor.primary_s),
                    //         ),
                    //         errorText: existing_machineCapacityController.text.isEmpty && existing_machineCapacityvalidate
                    //             ? "Enter Existing Machine Capacity"
                    //             : null,
                    //         border: const OutlineInputBorder(),
                    //         enabledBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //                 color: HexColor(HexColor.gray_light))),
                    //         focusedBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //                 color: HexColor(HexColor.gray_light))),
                    //         filled: true,
                    //         hintText: "Existing Machine Capacity",
                    //         fillColor: HexColor(HexColor.gray_light)),
                    //   ),
                    // ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Existing Machine Ageing",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       Commons.commonBottomSheet(
                    //           'Existing Machine Ageing',
                    //           machineAgeing.map((e) => e).toList(),
                    //           usg_ageingController,
                    //           context, (selectedData) {
                    //         setState(() {
                    //           usg_ageingController.text = selectedData;
                    //           print(selectedData);
                    //         });
                    //       });
                    //     });
                    //   },
                    //   child: Container(
                    //     margin: const EdgeInsets.only(
                    //         left: 15, right: 15, bottom: 0, top: 5),
                    //     padding: const EdgeInsets.all(15),
                    //     decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(15),
                    //         border: Border.all(
                    //           color: HexColor(HexColor.gray_text),
                    //         )),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Text(
                    //           usg_ageingController.text.isEmpty
                    //               ? "Existing Machine Ageing"
                    //               : usg_ageingController.text,
                    //           style: TextStyle(
                    //             fontSize: 14,
                    //             color: HexColor(HexColor.black),
                    //             fontFamily: 'montserrat_regular',
                    //             decoration: TextDecoration.none,
                    //           ),
                    //         ),
                    //         Icon(
                    //           Icons.arrow_drop_down_rounded,
                    //           size: 30,
                    //           color: HexColor(HexColor.gray_text),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: usg_ageingController,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.model_training_rounded,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText: usg_ageingController.text.isEmpty &&
                                    other_Modelvalidate
                                ? "Existing Machine Ageing"
                                : null,
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Existing Machine Ageing",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Remark",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: remark_supportController,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.list_alt_sharp,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText: remark_supportController.text.isEmpty &&
                                    remark_supportvalidate
                                ? "Enter Remark"
                                : null,
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Remark",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Support Required",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: support_requiredController,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.list_alt_sharp,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText:
                                support_requiredController.text.isEmpty &&
                                        support_requiredvalidate
                                    ? "Enter Support Required"
                                    : null,
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Support Required",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    CheckboxListTile(
                      title: Text("Is Opportunity",
                          style:
                              TextStyle(color: HexColor(HexColor.primary_s))),
                      value: isCheck,
                      onChanged: (newValue) {
                        setState(() {
                          isCheck = newValue!;
                          product_nameController.clear();
                          qualityController.clear();
                          valueController.clear();
                          oppty_type.clear();
                          productCategoryCtrl.clear();
                          pnditCtrl.clear();
                          quotationSubmitCtrl.clear();
                          demoDoneCtrl.clear();
                          expected_closure_dateController.clear();
                          winLossCompanyId = '';
                          winLossProductId = '';
                          Win_Lost_CompanyController.clear();
                          referenceId = '';
                          Win_Lost_ProductController.clear();
                          winlossDateCtrl.clear();
                          statusCtrl.clear();
                          referenceController.clear();
                          commentsController.clear();
                          foreCast = false;
                        });
                      },
                      activeColor: HexColor(HexColor.primarycolor),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    Visibility(
                      visible: isCheck,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 25, top: 15.0),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Product Pitched",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.primarycolor),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Commons.commonBottomSheet(
                                    'Enter Product',
                                    listing_Data?.productPithed
                                        ?.map((e) => e)
                                        .toList(),
                                    product_nameController,
                                    context, (selectedData) {
                                  setState(() {
                                    product_nameController.text = selectedData;
                                    print(selectedData);
                                  });
                                });
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 0, top: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: HexColor(HexColor.gray_text),
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product_nameController.text.isEmpty
                                        ? "Enter Product"
                                        : product_nameController.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(HexColor.black),
                                      fontFamily: 'montserrat_regular',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 30,
                                    color: HexColor(HexColor.gray_text),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 25, top: 15.0),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Quantity",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.primarycolor),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 3, left: 20, right: 20),
                            child: TextField(
                              controller: qualityController,
                              style: TextStyle(
                                  color: HexColor(HexColor.primary_s)),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.queue_play_next,
                                    color: HexColor(HexColor.primary_s),
                                  ),
                                  errorText: qualityController.text.isEmpty &&
                                          qualityvalidate
                                      ? "Enter quantity"
                                      : null,
                                  border: const OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              HexColor(HexColor.gray_light))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              HexColor(HexColor.gray_light))),
                                  filled: true,
                                  hintText: "Enter quantity",
                                  fillColor: HexColor(HexColor.gray_light)),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 25, top: 15.0),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Value(INR)",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.primarycolor),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 3, left: 20, right: 20),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: valueController,
                              style: TextStyle(
                                  color: HexColor(HexColor.primary_s)),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.currency_rupee_rounded,
                                    color: HexColor(HexColor.primary_s),
                                  ),
                                  errorText: valueController.text.isEmpty &&
                                          valueValidate
                                      ? "Value(INR)"
                                      : null,
                                  border: const OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              HexColor(HexColor.gray_light))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              HexColor(HexColor.gray_light))),
                                  filled: true,
                                  hintText: "Value(INR)",
                                  fillColor: HexColor(HexColor.gray_light)),
                            ),
                          ),
                          
                    Container(
                      margin: const EdgeInsets.only(left: 25, top: 15.0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Modality",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Commons.commonBottomSheet(
                              'Modality',
                              modality.map((e) => e).toList(),
                              modalityCtrl,
                              context, (selectedData) {
                            setState(() {
                              modalityCtrl.text = selectedData;
                              print(selectedData);
                            });
                          });
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 0, top: 5),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: HexColor(HexColor.gray_text),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              modalityCtrl.text.isEmpty
                                  ? "Modality"
                                  : modalityCtrl.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: HexColor(HexColor.black),
                                fontFamily: 'montserrat_regular',
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 30,
                              color: HexColor(HexColor.gray_text),
                            ),
                          ],
                        ),
                      ),
                    ),
                          Container(
                            margin: const EdgeInsets.only(left: 25, top: 15.0),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Oppty Type",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.primarycolor),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Commons.commonBottomSheet(
                                    'Select Oppty Type',
                                    oppt.map((e) => e).toList(),
                                    oppty_type,
                                    context, (selectedData) {
                                  setState(() {
                                    oppty_type.text = selectedData;
                                    print(selectedData);
                                  });
                                });
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 0, top: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: HexColor(HexColor.gray_text),
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    oppty_type.text.isEmpty
                                        ? "Select Oppty Type"
                                        : oppty_type.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(HexColor.black),
                                      fontFamily: 'montserrat_regular',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 30,
                                    color: HexColor(HexColor.gray_text),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 25, top: 15.0),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Product Category",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.primarycolor),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Commons.commonBottomSheet(
                                    'Product Category',
                                    productCategory.map((e) => e).toList(),
                                    productCategoryCtrl,
                                    context, (selectedData) {
                                  setState(() {
                                    productCategoryCtrl.text = selectedData;
                                    print(selectedData);
                                  });
                                });
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 0, top: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: HexColor(HexColor.gray_text),
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    productCategoryCtrl.text.isEmpty
                                        ? "Product Category"
                                        : productCategoryCtrl.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(HexColor.black),
                                      fontFamily: 'montserrat_regular',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 30,
                                    color: HexColor(HexColor.gray_text),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 25, top: 15.0),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "PNDT",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.primarycolor),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Commons.commonBottomSheet(
                                    'PNDIT',
                                    pndit.map((e) => e).toList(),
                                    pnditCtrl,
                                    context, (selectedData) {
                                  setState(() {
                                    pnditCtrl.text = selectedData;
                                    print(selectedData);
                                  });
                                });
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 0, top: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: HexColor(HexColor.gray_text),
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    pnditCtrl.text.isEmpty
                                        ? "PNDT"
                                        : pnditCtrl.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(HexColor.black),
                                      fontFamily: 'montserrat_regular',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 30,
                                    color: HexColor(HexColor.gray_text),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: oppty_type.text == 'Hot' ||
                                oppty_type.text == 'Warm' ||
                                oppty_type.text == 'Cold',
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 25, top: 15.0),
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Quotation Submitted",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: HexColor(HexColor.primarycolor),
                                  fontFamily: 'lato_bold',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: oppty_type.text == 'Hot' ||
                                oppty_type.text == 'Warm' ||
                                oppty_type.text == 'Cold',
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  Commons.commonBottomSheet(
                                      'Quotation Submitted',
                                      quotationSubmit.map((e) => e).toList(),
                                      quotationSubmitCtrl,
                                      context, (selectedData) {
                                    setState(() {
                                      quotationSubmitCtrl.text = selectedData;
                                      print(selectedData);
                                    });
                                  });
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, bottom: 0, top: 5),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: HexColor(HexColor.gray_text),
                                    )),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      quotationSubmitCtrl.text.isEmpty
                                          ? "Quotation Submitted"
                                          : quotationSubmitCtrl.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: HexColor(HexColor.black),
                                        fontFamily: 'montserrat_regular',
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      size: 30,
                                      color: HexColor(HexColor.gray_text),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 25, top: 15.0),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Demo Done",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.primarycolor),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Commons.commonBottomSheet(
                                    'Demo Done',
                                    demoDone.map((e) => e).toList(),
                                    demoDoneCtrl,
                                    context, (selectedData) {
                                  setState(() {
                                    demoDoneCtrl.text = selectedData;
                                    print(selectedData);
                                  });
                                });
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 0, top: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: HexColor(HexColor.gray_text),
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    demoDoneCtrl.text.isEmpty
                                        ? "Demo Done"
                                        : demoDoneCtrl.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(HexColor.black),
                                      fontFamily: 'montserrat_regular',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 30,
                                    color: HexColor(HexColor.gray_text),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: oppty_type.text == 'Hot' ||
                                oppty_type.text == 'Warm',
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 25, top: 15.0),
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Expected Closure Date",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: HexColor(HexColor.primarycolor),
                                  fontFamily: 'lato_bold',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: oppty_type.text == 'Hot' ||
                                oppty_type.text == 'Warm',
                            child: InkWell(
                              onTap: () {
                                _selectDate();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                    top: 3, left: 20, right: 20),
                                child: TextField(
                                  enabled: false,
                                  controller: expected_closure_dateController,
                                  style: TextStyle(
                                      color: HexColor(HexColor.primary_s)),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.contact_mail_outlined,
                                        color: HexColor(HexColor.primary_s),
                                      ),
                                      errorText: expected_closure_dateController
                                                  .text.isEmpty &&
                                              expected_closure_datevalidate
                                          ? "Enter Expected Closure Date"
                                          : null,
                                      border: const OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HexColor(
                                                  HexColor.gray_light))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HexColor(
                                                  HexColor.gray_light))),
                                      filled: true,
                                      hintText: "Enter Expected Closure Date",
                                      fillColor: HexColor(HexColor.gray_light)),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: oppty_type.text == 'Won' ||
                                oppty_type.text == 'Loss',
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 25, top: 15.0),
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "Win/Loss Company",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: HexColor(HexColor.primarycolor),
                                      fontFamily: 'lato_bold',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      Commons.commonBottomSheet(
                                          'Win/Loss Company',
                                          listing_Data?.machineComapny
                                              ?.map((e) => e.name)
                                              .toList(),
                                          Win_Lost_CompanyController,
                                          context, (selectedData) {
                                        setState(() {
                                          for (var company in listing_Data!
                                              .machineComapny!) {
                                            if (company.name.toString() ==
                                                selectedData) {
                                              winLossCompanyId =
                                                  company.id.toString();
                                              break;
                                            }
                                          }
                                          Win_Lost_CompanyController.text =
                                              selectedData;
                                          print(
                                              'Selected ID: $winLossCompanyId');
                                          if (winLossCompanyId != '') {
                                            winLossProductId = '';
                                            Win_Lost_ProductController.clear();
                                            productListing(winLossCompanyId);
                                          }
                                          // Update UI with selected data
                                          print(selectedData);
                                        });
                                      });
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 15, right: 15, bottom: 0, top: 5),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: HexColor(HexColor.gray_text),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          Win_Lost_CompanyController
                                                  .text.isEmpty
                                              ? "Enter Win/Loss Company"
                                              : Win_Lost_CompanyController.text,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: HexColor(HexColor.black),
                                            fontFamily: 'montserrat_regular',
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down_rounded,
                                          size: 30,
                                          color: HexColor(HexColor.gray_text),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 25, top: 15.0),
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "Win/Loss Product",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: HexColor(HexColor.primarycolor),
                                      fontFamily: 'lato_bold',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      if (product_listing_Data.isNotEmpty) {
                                        Commons.commonBottomSheet(
                                            'Win/Loss Product',
                                            product_listing_Data
                                                .map((e) => e.name)
                                                .toList(),
                                            Win_Lost_ProductController,
                                            context, (selectedData) {
                                          setState(() {
                                            for (var company
                                                in product_listing_Data!) {
                                              if (company.name.toString() ==
                                                  selectedData) {
                                                winLossProductId =
                                                    company.id.toString();
                                                break;
                                              }
                                            }
                                            // Update UI with selected data
                                            print(selectedData);
                                            Win_Lost_ProductController.text =
                                                selectedData;
                                          });
                                        });
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 15, right: 15, bottom: 0, top: 5),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: HexColor(HexColor.gray_text),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          Win_Lost_ProductController
                                                  .text.isEmpty
                                              ? "Enter Win/Loss Product"
                                              : Win_Lost_ProductController.text,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: HexColor(HexColor.black),
                                            fontFamily: 'montserrat_regular',
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down_rounded,
                                          size: 30,
                                          color: HexColor(HexColor.gray_text),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 25, top: 15.0),
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "Enter Win/Loss Date",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: HexColor(HexColor.primarycolor),
                                      fontFamily: 'lato_bold',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    winLossDate();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        top: 3, left: 20, right: 20),
                                    child: TextField(
                                      enabled: false,
                                      controller: winlossDateCtrl,
                                      style: TextStyle(
                                          color: HexColor(HexColor.primary_s)),
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.contact_mail_outlined,
                                            color: HexColor(HexColor.primary_s),
                                          ),
                                          border: const OutlineInputBorder(),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: HexColor(
                                                      HexColor.gray_light))),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: HexColor(
                                                      HexColor.gray_light))),
                                          filled: true,
                                          hintText: "Enter Win/Loss Date",
                                          fillColor:
                                              HexColor(HexColor.gray_light)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Container(
                          //   margin: const EdgeInsets.only(left: 25, top: 15.0),
                          //   alignment: Alignment.bottomLeft,
                          //   child: Text(
                          //     "Status",
                          //     style: TextStyle(
                          //       fontSize: 16,
                          //       color: HexColor(HexColor.primarycolor),
                          //       fontFamily: 'lato_bold',
                          //       decoration: TextDecoration.none,
                          //     ),
                          //   ),
                          // ),
                          // GestureDetector(
                          //   onTap: () {
                          //     setState(() {
                          //       Commons.commonBottomSheet(
                          //           'Status',
                          //           status.map((e) => e).toList(),
                          //           statusCtrl,
                          //           context, (selectedData) {
                          //         setState(() {
                          //           statusCtrl.text = selectedData;
                          //           print(selectedData);
                          //         });
                          //       });
                          //     });
                          //   },
                          //   child: Container(
                          //     margin: const EdgeInsets.only(
                          //         left: 15, right: 15, bottom: 0, top: 5),
                          //     padding: const EdgeInsets.all(15),
                          //     decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(15),
                          //         border: Border.all(
                          //           color: HexColor(HexColor.gray_text),
                          //         )),
                          //     child: Row(
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         Text(
                          //           statusCtrl.text.isEmpty
                          //               ? "Status"
                          //               : statusCtrl.text,
                          //           style: TextStyle(
                          //             fontSize: 14,
                          //             color: HexColor(HexColor.black),
                          //             fontFamily: 'montserrat_regular',
                          //             decoration: TextDecoration.none,
                          //           ),
                          //         ),
                          //         Icon(
                          //           Icons.arrow_drop_down_rounded,
                          //           size: 30,
                          //           color: HexColor(HexColor.gray_text),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          Container(
                            margin: const EdgeInsets.only(left: 25, top: 15.0),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Reference",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.primarycolor),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Commons.commonBottomSheet(
                                    'Reference',
                                    listing_Data?.refrenceUser
                                        ?.map((e) => e.firstName)
                                        .toList(),
                                    referenceController,
                                    context, (selectedData) {
                                  setState(() {
                                    for (var company
                                        in listing_Data!.refrenceUser!) {
                                      if (company.firstName.toString() ==
                                          selectedData) {
                                        referenceId = company.id.toString();
                                        break;
                                      }
                                    }
                                    referenceController.text = selectedData;
                                    // Update UI with selected data
                                    print(selectedData);
                                    print(referenceId);
                                  });
                                });
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 0, top: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: HexColor(HexColor.gray_text),
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    referenceController.text.isEmpty
                                        ? "Enter Reference"
                                        : referenceController.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(HexColor.black),
                                      fontFamily: 'montserrat_regular',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 30,
                                    color: HexColor(HexColor.gray_text),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 25, top: 15.0),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Comments",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.primarycolor),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 3, left: 20, right: 20),
                            child: TextField(
                              controller: commentsController,
                              style: TextStyle(
                                  color: HexColor(HexColor.primary_s)),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.list_alt_sharp,
                                    color: HexColor(HexColor.primary_s),
                                  ),
                                  border: const OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              HexColor(HexColor.gray_light))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              HexColor(HexColor.gray_light))),
                                  filled: true,
                                  hintText: "Enter Comments",
                                  fillColor: HexColor(HexColor.gray_light)),
                            ),
                          ),
                          CheckboxListTile(
                            title: Text("Forecast",
                                style: TextStyle(
                                    color: HexColor(HexColor.primary_s))),
                            value: foreCast,
                            onChanged: (newValue) {
                              setState(() {
                                foreCast = newValue!;
                              });
                            },
                            activeColor: HexColor(HexColor.primarycolor),
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 50.0, left: 20.0, bottom: 30, right: 20),
                      height: 50.0,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor(HexColor.primarycolor),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        child: const Text('Submit'),
                        onPressed: () {
                          if (validation()) {
                            AddVisit();
                          }
                        },
                      ),
                    ),
                  ]),
            )),
      )),
    );
  }

  bool validation() {
    bool isvalide = true;
    if (selected_purpose.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter purpose");
      isvalide = false;
    } else if (cust_name_Controller.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Customer Name");
      isvalide = false;
      setState(() {
        cust_name_validate = true;
      });
    } else if (center_name_Controller.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Center Name");
      isvalide = false;
      setState(() {
        center_name_validate = true;
      });
    } else if (city_nameController.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter City Name");
      isvalide = false;
      setState(() {
        city_namevalidate = true;
      });
    } else if (contact_numberController.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Contact Number");
      isvalide = false;
      setState(() {
        contact_numbervalidate = true;
      });
    } else if (existingMachineCompanyController.text.isEmpty) {
      Commons.flushbar_Messege(
          context, "Please Enter Existing Machine Company");
      isvalide = false;
      setState(() {
        existingMachineCompanyvalidate = true;
      });
    } else if (existing_machineController.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Existing Machine Model");
      isvalide = false;
      setState(() {
        existing_machinevalidate = true;
      });
    } else if (usg_ageingController.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Machine Ageing");
      isvalide = false;
      setState(() {
        usg_ageingvalidate = true;
      });
    }
    if (isCheck == true) {
      if (product_nameController.text.isEmpty) {
        Commons.flushbar_Messege(context, "Please Enter Product");
        isvalide = false;
        setState(() {
          product_namevalidate = true;
        });
      } else if (oppty_type.text.isEmpty) {
        Commons.flushbar_Messege(context, "Please Enter oppty Type");
        isvalide = false;
        setState(() {
          oppty_typevalidate = true;
        });
      } else if (productCategoryCtrl.text.isEmpty) {
        Commons.flushbar_Messege(context, "Please Enter Product Category");
        isvalide = false;
      } else if (pnditCtrl.text.isEmpty) {
        Commons.flushbar_Messege(context, "Please Enter pndt");
        isvalide = false;
      } else if (quotationSubmitCtrl.text.isEmpty && (oppty_type.text == 'Hot' ||
                                oppty_type.text == 'Warm' ||
                                oppty_type.text == 'Cold')) {
        Commons.flushbar_Messege(context, "Please Enter Quotation Submitted");
        isvalide = false;
      } else if (demoDoneCtrl.text.isEmpty) {
        Commons.flushbar_Messege(context, "Please Enter Demo Done Or Not");
        isvalide = false;
      } else if (Win_Lost_CompanyController.text.isEmpty && (oppty_type.text == 'Won' ||
                                oppty_type.text == 'Loss')) {
        Commons.flushbar_Messege(context, "Please Enter Win/Loss Company");
        isvalide = false;
        setState(() {
          Win_Lost_Companyvalidate = true;
        });
      } else if (Win_Lost_ProductController.text.isEmpty&&( oppty_type.text == 'Won' ||
                                oppty_type.text == 'Loss')) {
        Commons.flushbar_Messege(context, "Please Enter Win/Loss Product");
        isvalide = false;
        setState(() {
          Win_Lost_Productvalidate = true;
        });
      // } else if (statusCtrl.text.isEmpty) {
      //   Commons.flushbar_Messege(context, "Please Enter Status");
      //   isvalide = false;
      } else if (referenceController.text.isEmpty) {
        Commons.flushbar_Messege(context, "Please Enter Reference");
        isvalide = false;
      }
    }
    // if (selected_purpose == "Customer Meeting" ||
    //     selected_purpose == "Official Meeting") {
    //   print('object');
    //   if (email_Controller.text.isEmpty) {
    //     Commons.flushbar_Messege(context, "Please Enter Email Id");
    //     isvalide = false;
    //     setState(() {
    //       email_validate = true;
    //     });
    //   } else if (oppty_type.text.isEmpty) {
    //     Commons.flushbar_Messege(context, "Slect Oppty Type");
    //     isvalide = false;
    //     setState(() {
    //       oppty_typevalidate = true;
    //     });
    //   } else if (expected_closure_dateController.text.isEmpty) {
    //     Commons.flushbar_Messege(context, "Enter Expected Closure Date");
    //     isvalide = false;
    //     setState(() {
    //       expected_closure_datevalidate = true;
    //     });
    //   }
    // }
    // else if (remark_supportController.text.isEmpty) {
    //   Commons.flushbar_Messege(context, "Enter Remark Support");
    //   isvalide = false;
    //   setState(() {
    //     remark_supportvalidate = true;
    //   });
    // } else if (support_requiredController.text.isEmpty) {
    //   Commons.flushbar_Messege(context, "Enter Support Required");
    //   isvalide = false;
    //   setState(() {
    //     support_requiredvalidate = true;
    //   });
    // } else if (Win_Lost_CompanyController.text.isEmpty) {
    //   Commons.flushbar_Messege(context, "Enter Win/Lost Company");
    //   isvalide = false;
    //   setState(() {
    //     Win_Lost_Companyvalidate = true;
    //   });
    // } else if (Win_Lost_ProductController.text.isEmpty) {
    //   Commons.flushbar_Messege(context, "Enter Win/Lost Product");
    //   isvalide = false;
    //   setState(() {
    //     Win_Lost_Productvalidate = true;
    //   });
    // }
    return isvalide;
  }

  void _selectDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((date) {
      setState(() {
        expected_closure_dateController.text =
            Commons.Date_format(date.toString());
        _selecteddate = Commons.Date_format5(date.toString());
      });
    });
  }

  void winLossDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((date) {
      setState(() {
        winlossDateCtrl.text = Commons.Date_format(date.toString());
        _selecteddate = Commons.Date_format5(date.toString());
      });
    });
  }

  Future<DateTime?> showDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    SelectableDayPredicate? selectableDayPredicate,
    var helpText,
    var cancelText,
    var confirmText,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    var errorFormatText,
    var errorInvalidText,
    var fieldHintText,
    var fieldLabelText,
    TextInputType? keyboardType,
    Offset? anchorPoint,
  }) async {
    assert(context != null);
    assert(initialDate != null);
    assert(firstDate != null);
    assert(lastDate != null);
    initialDate = DateUtils.dateOnly(initialDate);
    firstDate = DateUtils.dateOnly(firstDate);
    lastDate = DateUtils.dateOnly(lastDate);
    assert(
      !lastDate.isBefore(firstDate),
      'lastDate $lastDate must be on or after firstDate $firstDate.',
    );
    assert(
      !initialDate.isBefore(firstDate),
      'initialDate $initialDate must be on or after firstDate $firstDate.',
    );
    assert(
      !initialDate.isAfter(lastDate),
      'initialDate $initialDate must be on or before lastDate $lastDate.',
    );
    assert(
      selectableDayPredicate == null || selectableDayPredicate(initialDate),
      'Provided initialDate $initialDate must satisfy provided selectableDayPredicate.',
    );
    assert(initialEntryMode != null);
    assert(useRootNavigator != null);
    assert(initialDatePickerMode != null);
    assert(debugCheckHasMaterialLocalizations(context));

    Widget dialog = DatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialEntryMode: initialEntryMode,
      selectableDayPredicate: selectableDayPredicate,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      initialCalendarMode: initialDatePickerMode,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      fieldHintText: fieldHintText,
      fieldLabelText: fieldLabelText,
      keyboardType: keyboardType,
    );

    if (textDirection != null) {
      dialog = Directionality(
        textDirection: textDirection,
        child: dialog,
      );
    }

    if (locale != null) {
      dialog = Localizations.override(
        context: context,
        locale: locale,
        child: dialog,
      );
    }
    return showDialog<DateTime>(
      context: context,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (BuildContext context) {
        return builder == null ? dialog : builder(context, dialog);
      },
      anchorPoint: anchorPoint,
    );
  }

  AddVisit() async {
    LoginModel loginModel = await Commons.getuser_info();

    context.loaderOverlay.show();
    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.addVisit));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
      request.fields["cust_name"] = cust_name_Controller.text;
      request.fields["city_name"] = city_nameController.text;
      request.fields["center_name"] = center_name_Controller.text;
      request.fields["contact_number"] = contact_numberController.text;
      request.fields["email"] = email_Controller.text;
      request.fields["existing_machine"] = existingMachineId.toString();
      // request.fields["existing_machine_capacity"] = existing_machineCapacityController.text;
      request.fields["is_opportunity"] = isCheck == false ? '0' : '1';
      request.fields["usg_ageing"] = usg_ageingController.text;
      request.fields["product_name"] = product_nameController.text;
      request.fields["oppty_type"] = oppty_type.text;
      request.fields["expected_closure_date"] = _selecteddate;
      request.fields["remark_support"] = remark_supportController.text;
      request.fields["support_required"] = support_requiredController.text;
      request.fields["quality"] = qualityController.text;
      request.fields["win_loss_product"] = winLossProductId.toString();
      request.fields["win_loss_company"] = winLossCompanyId.toString();
      request.fields["purpose"] = selected_purpose.text;
      request.fields["address"] = addressController.text;
      request.fields["district"] = districtController.text;
      request.fields["existing_machine_company"] =
          existingMachineCompanyId.toString();
      request.fields["machine_model"] = other_ModelController.text;
      request.fields["product_value"] = valueController.text;
      request.fields["product_category"] = productCategoryCtrl.text;
      request.fields["pndt"] = pnditCtrl.text;
      request.fields["quatation_submit"] = quotationSubmitCtrl.text;
      request.fields["demo_done"] = demoDoneCtrl.text;
      request.fields["win_loss_date"] = winlossDateCtrl.text;
      request.fields["opportunity_status"] = statusCtrl.text;
      request.fields["reffrence_user_id"] = referenceId.toString();
      request.fields["comment"] = commentsController.text;
      request.fields["modality"] = modalityCtrl.text;
      request.fields["forcast"] = foreCast == false ? '0' : '1';

      print("sarjeet ${Commons.addVisit}");
      print("sarjeet ${request.fields}");
      //add headers
      var sendresponse = await request.send();

      //Get the response from the server
      var responseData = await sendresponse.stream.toBytes();
      var response = String.fromCharCodes(responseData);

      context.loaderOverlay.hide();
      print('sarjeet log  ${response}');

      if (response == null ||
          response.contains("A PHP Error was encountered") ||
          response.contains("<div") ||
          response.contains("</html")) {
        Commons.flushbar_Messege(context, "internal server Error ");
      } else {
        SuccessModel successModel = SuccessModel.fromJson(jsonDecode(response));

        if (successModel.status == 1) {
          Commons.Fluttertoast_Messege(context, successModel.message ?? "");
          Navigator.pop(context);
        } else {
          Commons.flushbar_Messege(context, successModel.message!);
        }
      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }

  allListing() async {
    LoginModel loginModel = await Commons.getuser_info();

    String url = Commons.allListing + "/${loginModel.data!.id ?? ""}";
    print("Request failed with status: ${url}");

    try {
      http.Response response = await http.get(Uri.parse(url));
      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        String responseData = response.body;
        print("sarjeet ${responseData}");

        AllListingModel? listingData =
            AllListingModel.fromJson(jsonDecode(responseData));

        if (listingData.status == 1) {
          setState(() {
            listing_Data = listingData.data ?? AllListingData();
          });
        } else {
          // Commons.flushbar_Messege(context, attendenceDataModel.message!);
        }
      } else {
        // Request failed with an error status code
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      // An error occurred during the request
      print("Error: $e");
    }
  }

  productListing(CompanyId) async {
    String url = Commons.productsListing + "/${CompanyId ?? ""}";
    print("Request failed with status: ${url}");
    context.loaderOverlay.show();
    try {
      http.Response response = await http.get(Uri.parse(url));
      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        String responseData = response.body;
        print(existingMachineId);
        print(existing_machineController.text);
        print("sarjeet ${responseData}");
        ExistingMachineModel? productListingData =
            ExistingMachineModel.fromJson(jsonDecode(responseData));

        if (productListingData.status == 1) {
          setState(() {
            product_listing_Data = productListingData.data ?? [];
          });
        } else {
          // Commons.flushbar_Messege(context, attendenceDataModel.message!);
        }
      } else {
        // Request failed with an error status code
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      // An error occurred during the request
      print("Error: $e");
    }
  }
}
