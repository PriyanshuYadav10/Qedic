import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../apis/app_exception.dart';
import '../model/ImageUploadModel.dart';
import '../model/LoginModel.dart';
import '../model/SuccessModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import '../visit/VisitListModel.dart';
import 'VisitSelect.dart';

class AddExpenses extends StatefulWidget {
  // Initially password is obscure
  @override
  State<AddExpenses> createState() => _AddExpensesState();
}
// how to check string is only number in dart
// https://stackoverflow.com/questions/55763428/how-to-check-string-is-only-number-in-dart

class _AddExpensesState extends State<AddExpenses> {
  var newstartDate = "Select Date";
  var startdatecalendar = false;
  var newstartDateymd = "Select Date";
  var visit_name_selected = "Select Visit (Optional)";
  var visit_id_selected = "";
  late DateTime StartDate;
  TextEditingController remark_supportController = TextEditingController();

  TextEditingController other_controller = TextEditingController();
  bool other_validate = false;
  TextEditingController HotelExpense_controller = TextEditingController();
  bool hotelExpense_validate = false;
  TextEditingController bus_train_controller = TextEditingController();
  bool bus_train_validate = false;
  TextEditingController tolocation_controller = TextEditingController();
  TextEditingController formlocation_controller = TextEditingController();
  TextEditingController km_controller = TextEditingController();
  TextEditingController mileage_controller = TextEditingController();
  TextEditingController travel_purpose = TextEditingController();
  bool tolocation_validate = false;
  bool fromlocation_validate = false;
  bool km_validate = false;
  bool mileage_validate = false;
  // File? _HotelExpenseImage_file;
  // String _HotelExpenseImage_url = "";
  // File? _BusTrain_file;
  // String _BusTrain_url = "";
  // File? _Other_file;
  // String _Other_url = "";
  final List<String> category = [
    "Customer Meeting",
    "Official Meeting",
    "Service",
    "Application",
  ];

  final List<String> hotel_image_list = [""];
  final List<String> travel_image_list = [""];
  final List<String> other_image_list = [""];
  String Traveltype = "No";
  String routetype = "Outstation";
  int mileageFair = 0;

  @override
  void initState() {
    initializeDateFormatting();
    getmilege();
    Intl.systemLocale =
        'en_En'; // to change the calendar format based on localization
    super.initState();
  }

  getmilege() {
    Commons.getmileageFair().then((value) {
      setState(() {
        mileageFair = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SafeArea(
            child: Scaffold(
                appBar: Commons.Appbar_logo(true, context, "Add Expenses"),
                body: LoaderOverlay(
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 20, bottom: 10, left: 10, right: 10),
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                // Set border width
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                // Set rounded corner radius
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1,
                                      color: Colors.grey,
                                      offset: Offset(0, 0))
                                ] // Make rounded corner of border
                                ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Select Date",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: HexColor(HexColor.black),
                                        fontFamily: 'montserrat_medium',
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          newstartDate,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: HexColor(HexColor.gray_line),
                                            fontFamily: 'montserrat_medium',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(left: 10),
                                        child: Icon(
                                          Icons.calendar_month,
                                          size: 20,
                                          color: HexColor(HexColor.gray_line),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            startdatecalendar = true;
                          });
                        },
                      ),
                      if (startdatecalendar)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: SfDateRangePicker(
                            onSelectionChanged: _onSelectionChanged1,
                            selectionMode: DateRangePickerSelectionMode.single,
                            monthCellStyle: DateRangePickerMonthCellStyle(
                                todayTextStyle: TextStyle(
                                    color: HexColor(HexColor.primarycolor)),
                                weekendTextStyle:
                                    TextStyle(color: HexColor(HexColor.yello))),
                            initialDisplayDate: DateTime.now(),
                            maxDate: DateTime.now(),
                            monthFormat: 'MMM',
                            todayHighlightColor: Colors.transparent,
                            selectionColor: HexColor(HexColor.primarycolor),
                          ),
                        ),
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 10, bottom: 10, left: 10, right: 10),
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                // Set border width
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                // Set rounded corner radius
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1,
                                      color: Colors.grey,
                                      offset: Offset(0, 0))
                                ] // Make rounded corner of border
                                ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      visit_name_selected,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: HexColor(HexColor.black),
                                        fontFamily: 'montserrat_medium',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VisitSelect()),
                          );
                          if (result != null) {
                            List<VisitListData>? visitListData = result;
                            setState(() {
                              visit_name_selected = "Select Visit (Optional)";
                              visit_id_selected = "";
                              for (var item in visitListData!) {
                                if (visit_name_selected ==
                                    "Select Visit (Optional)") {
                                  visit_name_selected = item.custName!;
                                  visit_id_selected = item.id.toString();
                                } else {
                                  visit_name_selected =
                                      "$visit_name_selected, ${item.custName!}";
                                  visit_id_selected =
                                      "$visit_id_selected,${item.id!}";
                                }
                              }

                              print("sareet $visit_id_selected");
                            });
                          }
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            FocusScope.of(context).requestFocus(FocusNode());
                            Commons.commonBottomSheet(
                                'Select Purpose of Travel',
                                category.map((e) => e).toList(),
                                travel_purpose,
                                context, (selectedData) {
                              setState(() {
                                travel_purpose.text = selectedData;
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
                                travel_purpose.text.isEmpty
                                    ? "Select Purpose of Travel"
                                    : travel_purpose.text,
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
                        margin: EdgeInsets.only(left: 20, right: 15, top: 5),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Travel with MD",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor(HexColor.black),
                            fontFamily: 'montserrat_medium',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10),
                        child: Row(
                          children: [
                            Radio<String>(
                              activeColor: HexColor(HexColor.primarycolor),
                              value: 'Yes',
                              groupValue: Traveltype,
                              onChanged: (value) {
                                setState(() {
                                  Traveltype = value!;
                                });
                              },
                            ),
                            Text("Yes"),
                            SizedBox(width: 16),
                            Radio<String>(
                              activeColor: HexColor(HexColor.primarycolor),
                              value: 'No',
                              groupValue: Traveltype,
                              onChanged: (value) {
                                setState(() {
                                  Traveltype = value!;
                                });
                              },
                            ),
                            Text("No"),
                          ],
                        ),
                      ),
                      if (Traveltype == "Yes")
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              // Set border width
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              // Set rounded corner radius
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 1,
                                    color: Colors.grey,
                                    offset: Offset(0, 0))
                              ] // Make rounded corner of border
                              ),
                          child: Column(
                            children: [
                              Container(
                                child: TextField(
                                  controller: formlocation_controller,
                                  style: TextStyle(
                                      color: HexColor(HexColor.primary_s)),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        color: HexColor(HexColor.primary_s),
                                      ),
                                      errorText: fromlocation_validate
                                          ? "Enter From Location"
                                          : null,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HexColor(
                                                  HexColor.gray_light))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HexColor(
                                                  HexColor.gray_light))),
                                      filled: true,
                                      hintText: "Enter From Location",
                                      fillColor: HexColor(HexColor.gray_light)),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 15),
                                child: TextField(
                                  controller: tolocation_controller,
                                  style: TextStyle(
                                      color: HexColor(HexColor.primary_s)),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        color: HexColor(HexColor.primary_s),
                                      ),
                                      errorText: tolocation_validate
                                          ? "Enter to Location"
                                          : null,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HexColor(
                                                  HexColor.gray_light))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HexColor(
                                                  HexColor.gray_light))),
                                      filled: true,
                                      hintText: "Enter to Location",
                                      fillColor: HexColor(HexColor.gray_light)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (Traveltype == "No")
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              // Set border width
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              // Set rounded corner radius
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 1,
                                    color: Colors.grey,
                                    offset: Offset(0, 0))
                              ] // Make rounded corner of border
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 15, top: 5),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Select Route Type",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor(HexColor.black),
                                    fontFamily: 'montserrat_medium',
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 5, right: 15, bottom: 10),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      activeColor:
                                          HexColor(HexColor.primarycolor),
                                      value: 'Outstation',
                                      groupValue: routetype,
                                      onChanged: (value) {
                                        setState(() {
                                          routetype = value!;
                                        });
                                      },
                                    ),
                                    Text("Outstation"),
                                    SizedBox(width: 16),
                                    Radio<String>(
                                      activeColor:
                                          HexColor(HexColor.primarycolor),
                                      value: 'Local',
                                      groupValue: routetype,
                                      onChanged: (value) {
                                        setState(() {
                                          routetype = value!;
                                        });
                                      },
                                    ),
                                    Text("Local"),
                                  ],
                                ),
                              ),
                              if (routetype == "Outstation")
                                Container(
                                  child: TextField(
                                    controller: formlocation_controller,
                                    style: TextStyle(
                                        color: HexColor(HexColor.primary_s)),
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                        errorText: fromlocation_validate
                                            ? "Enter From Location"
                                            : null,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        filled: true,
                                        hintText: "Enter From Location",
                                        fillColor:
                                            HexColor(HexColor.gray_light)),
                                  ),
                                ),
                              if (routetype == "Outstation")
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  child: TextField(
                                    controller: tolocation_controller,
                                    style: TextStyle(
                                        color: HexColor(HexColor.primary_s)),
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                        errorText: tolocation_validate
                                            ? "Enter to Location"
                                            : null,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        filled: true,
                                        hintText: "Enter to Location",
                                        fillColor:
                                            HexColor(HexColor.gray_light)),
                                  ),
                                ),
                              if (routetype == "Local")
                                Container(
                                  child: TextField(
                                    controller: formlocation_controller,
                                    style: TextStyle(
                                        color: HexColor(HexColor.primary_s)),
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                        errorText: fromlocation_validate
                                            ? "Enter From Location"
                                            : null,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        filled: true,
                                        hintText: "Enter From Location",
                                        fillColor:
                                            HexColor(HexColor.gray_light)),
                                  ),
                                ),
                              if (routetype == "Local")
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  child: TextField(
                                    controller: tolocation_controller,
                                    style: TextStyle(
                                        color: HexColor(HexColor.primary_s)),
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                        errorText: tolocation_validate
                                            ? "Enter to Location"
                                            : null,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        filled: true,
                                        hintText: "Enter to Location",
                                        fillColor:
                                            HexColor(HexColor.gray_light)),
                                  ),
                                ),
                              if (routetype == "Local")
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  child: TextField(
                                    controller: km_controller,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9]')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isNotEmpty) {
                                          mileage_controller.text =
                                              "${int.parse(value) * mileageFair}";
                                        } else {
                                          mileage_controller.text = "0";
                                        }
                                      });
                                    },
                                    style: TextStyle(
                                        color: HexColor(HexColor.primary_s)),
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.add_road_outlined,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                        errorText: km_validate
                                            ? "Enter Mileage km"
                                            : null,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        filled: true,
                                        hintText: "Enter Mileage km",
                                        fillColor:
                                            HexColor(HexColor.gray_light)),
                                  ),
                                ),
                              if (routetype == "Local")
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  child: TextField(
                                    controller: mileage_controller,
                                    enabled: false,
                                    style: TextStyle(
                                        color: HexColor(HexColor.primary_s)),
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.monetization_on_outlined,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                        errorText: mileage_validate
                                            ? "Enter Mileage Allowance"
                                            : null,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        filled: true,
                                        hintText: "Enter Mileage Allowance",
                                        fillColor:
                                            HexColor(HexColor.gray_light)),
                                  ),
                                ),
                              if (routetype == "Outstation")
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  child: TextField(
                                    controller: HotelExpense_controller,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color: HexColor(HexColor.primary_s)),
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.location_city,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                        errorText: hotelExpense_validate
                                            ? "Enter Hotel Expense"
                                            : null,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        filled: true,
                                        hintText: "Enter Hotel Expense",
                                        fillColor:
                                            HexColor(HexColor.gray_light)),
                                  ),
                                ),
                              if (routetype == "Outstation")
                                Container(
                                    margin: const EdgeInsets.only(
                                        top: 15, bottom: 10),
                                    child: Text(
                                      "Upload Hotel Expense Receipt",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: HexColor(HexColor.gray_text),
                                        fontFamily: 'montserrat_regular',
                                        decoration: TextDecoration.none,
                                      ),
                                      textAlign: TextAlign.start,
                                    )),
                              if (routetype == "Outstation")
                                ImageUI(hotel_image_list, "HotelExpense"),
                              if (routetype == "Outstation")
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  child: TextField(
                                    controller: bus_train_controller,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color: HexColor(HexColor.primary_s)),
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.bus_alert_outlined,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                        errorText: bus_train_validate
                                            ? "Enter Bus/Train Fare"
                                            : null,
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor(
                                                    HexColor.gray_light))),
                                        filled: true,
                                        hintText: "Enter Bus/Train Fare",
                                        fillColor:
                                            HexColor(HexColor.gray_light)),
                                  ),
                                ),
                              if (routetype == "Outstation")
                                Container(
                                    margin: const EdgeInsets.only(
                                        top: 15, bottom: 10),
                                    child: Text(
                                      "Upload Bus/Train Receipt",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: HexColor(HexColor.gray_text),
                                        fontFamily: 'montserrat_regular',
                                        decoration: TextDecoration.none,
                                      ),
                                      textAlign: TextAlign.start,
                                    )),
                              if (routetype == "Outstation")
                                ImageUI(travel_image_list, "BusTrain"),
                              Container(
                                margin: EdgeInsets.only(top: 15),
                                child: TextField(
                                  controller: other_controller,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      color: HexColor(HexColor.primary_s)),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.add_alarm,
                                        color: HexColor(HexColor.primary_s),
                                      ),
                                      errorText: other_validate
                                          ? "Enter Other Expenses"
                                          : null,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HexColor(
                                                  HexColor.gray_light))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HexColor(
                                                  HexColor.gray_light))),
                                      filled: true,
                                      hintText: "Enter Other Expenses",
                                      fillColor: HexColor(HexColor.gray_light)),
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(
                                      top: 15, bottom: 10),
                                  child: Text(
                                    "Upload Other Expenses Receipt",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(HexColor.gray_text),
                                      fontFamily: 'montserrat_regular',
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.start,
                                  )),
                              ImageUI(other_image_list, "Other"),
                            ],
                          ),
                        ),
                      Container(
                        margin: EdgeInsets.only(left: 25, top: 15.0),
                        child: Text(
                          "Remark",
                          style: TextStyle(
                            fontSize: 16,
                            color: HexColor(HexColor.primarycolor),
                            fontFamily: 'lato_bold',
                            decoration: TextDecoration.none,
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 3, left: 20, right: 20),
                        child: TextField(
                          controller: remark_supportController,
                          style: TextStyle(color: HexColor(HexColor.primary_s)),
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.list_alt_sharp,
                                color: HexColor(HexColor.primary_s),
                              ),
                              border: OutlineInputBorder(),
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
                        margin: const EdgeInsets.only(
                            top: 30.0, left: 20.0, bottom: 30, right: 20),
                        height: 50.0,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor(HexColor.primary_s)),
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: HexColor(HexColor.white),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                            onPressed: () {
                              if (_Validation(context)) {
                                _AddExpenses(context);
                              }
                            }),
                      ),
                    ],
                  )),
                ))));
  }

  Widget ImageUI(List<String> image_list, String type) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      height: 70,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: image_list!.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () {
                  camera_gallery_option(context, type, index);
                },
                child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: HexColor(HexColor.primarycolor))),
                    child: image_list[index].isEmpty
                        ? Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 50,
                            color: HexColor(HexColor.primarycolor),
                          )
                        : Image.network(image_list[index])),
              ),
            );
          }),
    );
  }

  bool _Validation(BuildContext _context) {
    bool isvalide = true;
    if (newstartDate == "Select Date") {
      Commons.flushbar_Messege(_context, "Select Date");
      isvalide = false;
    } else if (travel_purpose == "Select Purpose") {
      Commons.flushbar_Messege(_context, "Select Purpose of Travel");
      isvalide = false;
    }
    // if (Traveltype == "No") {
    //   if (routetype == "Local") {
    //     if (km_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter Mileage km");
    //       isvalide = false;
    //     } else if (mileage_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter Mileage Allowance");
    //       isvalide = false;
    //     } else if (other_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter Other Expenses");
    //       isvalide = false;
    //     } else if (other_image_list.length == 1) {
    //       Commons.flushbar_Messege(_context, "Upload Other Expenses Receipt");
    //       isvalide = false;
    //     }
    //   } else {
    //     if (formlocation_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter From Location");
    //       isvalide = false;
    //     } else if (tolocation_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter to Location");
    //       isvalide = false;
    //     } else if (km_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter Mileage km");
    //       isvalide = false;
    //     } else if (mileage_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter Mileage Allowance");
    //       isvalide = false;
    //     } else if (HotelExpense_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter Hotel Expense");
    //       isvalide = false;
    //     } else if (hotel_image_list.length == 1) {
    //       Commons.flushbar_Messege(_context, "Upload Hotel Expense Receipt");
    //       isvalide = false;
    //     } else if (bus_train_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter Bus/Train Fare");
    //       isvalide = false;
    //     } else if (travel_image_list.length == 1) {
    //       Commons.flushbar_Messege(_context, "Upload Bus/Train Receipt");
    //       isvalide = false;
    //     } else if (other_controller.text.isEmpty) {
    //       Commons.flushbar_Messege(_context, "Enter Other Expenses");
    //       isvalide = false;
    //     } else if (other_image_list.length == 1) {
    //       Commons.flushbar_Messege(_context, "Upload Other Expenses Receipt");
    //       isvalide = false;
    //     }
    //   }
    // }
    return isvalide;
  }

  void _onSelectionChanged1(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      startdatecalendar = false;
      StartDate = args.value;
      newstartDate = Commons.Date_format2(StartDate.toString());
      newstartDateymd = Commons.Date_format5(StartDate.toString());
    });
  }

  camera_gallery_option(BuildContext _context, String type, int index) {
    showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: _context,
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(bottom: 0, left: 0, right: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: SizedBox.expand(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: HexColor(HexColor.primary_s).withOpacity(0.2),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          getImage(ImageSource.camera, _context, type, index);
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: HexColor(HexColor.primary_s)
                                    .withOpacity(0.4),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: HexColor(HexColor.primary_s),
                                size: 24,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Text(
                                "Camera",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: HexColor(HexColor.primary_s),
                                  fontFamily: 'lato_bold',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: HexColor(HexColor.primary_s).withOpacity(0.2),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          getImage(ImageSource.gallery, _context, type, index);
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: HexColor(HexColor.primary_s)
                                    .withOpacity(0.4),
                              ),
                              child: Icon(
                                Icons.camera,
                                color: HexColor(HexColor.primary_s),
                                size: 24,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Text(
                                "Gallery",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: HexColor(HexColor.primary_s),
                                  fontFamily: 'lato_bold',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ])),
            ));
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position:
              Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }

  ImageUload(
      XFile imagefile, BuildContext _context, String type, int index) async {
    _context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request =
          http.MultipartRequest("POST", Uri.parse(Commons.uploadImage));
      var stream =
          new http.ByteStream(DelegatingStream.typed(imagefile.openRead()));
      //add text fields
      var length = await imagefile.length();
      var multipartFile = http.MultipartFile("image", stream, length,
          filename: basename(imagefile.path));

      request.files.add(multipartFile);

      //add headers
      var sendresponse = await request.send();

      //Get the response from the server
      var responseData = await sendresponse.stream.toBytes();
      var response = String.fromCharCodes(responseData);

      _context.loaderOverlay.hide();
      print('sarjeet log  ${response}');

      if (response == null ||
          response.contains("A PHP Error was encountered") ||
          response.contains("<div") ||
          response.contains("</html")) {
        Commons.flushbar_Messege(_context, "internal server Error ");
      } else {
        ImageUploadModel imageUploadModel =
            ImageUploadModel.fromJson(jsonDecode(response));

        if (imageUploadModel.status == 1) {
          setState(() {
            if (type == "HotelExpense") {
              print("sarjeet ${imageUploadModel.data!}");

              if (index == 0) {
                hotel_image_list.add(imageUploadModel.data!);
              } else {
                hotel_image_list[index] = imageUploadModel.data!;
              }
              // _HotelExpenseImage_url = imageUploadModel.data!;
            }
            if (type == "BusTrain") {
              if (index == 0) {
                travel_image_list.add(imageUploadModel.data!);
              } else {
                travel_image_list[index] = imageUploadModel.data!;
              }
              // _BusTrain_url = imageUploadModel.data!;
              // _BusTrain_file = imagefile;
            }
            if (type == "Other") {
              if (index == 0) {
                other_image_list.add(imageUploadModel.data!);
              } else {
                other_image_list[index] = imageUploadModel.data!;
              }
              // _Other_url = imageUploadModel.data!;
              // _Other_file = imagefile;
            }
          });
        } else {
          Commons.flushbar_Messege(_context, imageUploadModel.message!);
        }
      }
    } on SocketException {
      _context.loaderOverlay.hide();
      Commons.flushbar_Messege(_context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }

  //get image form to gallery and camera
  Future getImage(ImageSource imageType, BuildContext _context, String type,
      int index) async {
    print('sarjeet image .1');

    // final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final pickedFile = await ImagePicker().pickImage(source: imageType);
    print('sarjeet image .2');
    print('sarjeet image ${pickedFile?.path}');

    if (pickedFile != null) {
      print('sarjeet image .3');

      final tempImage = File(pickedFile.path);
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath =
          dir.absolute.path + "/11${tempImage.path.split("/").last}";
      // File file = createFile("${dir.absolute.path}/test.png");
      // file.writeAsBytesSync(data.buffer.asUint8List());
      XFile? image = await Imagecompresh(tempImage, targetPath);

      ImageUload(image!, _context, type, index);
    } else {
      print('sarjeet No image selected.');
    }
  }

  Future<XFile?> Imagecompresh(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 20,
      rotate: 0,
    );

    print(file.lengthSync());
    print(result?.length());
    return result;
  }

  _AddExpenses(BuildContext _context) async {
    LoginModel loginModel = await Commons.getuser_info();

    _context.loaderOverlay.show();

    String _HotelExpenseImage_url = "";
    for (int i = 1; i < hotel_image_list.length; i++) {
      if (_HotelExpenseImage_url.isEmpty) {
        _HotelExpenseImage_url = hotel_image_list[i];
      } else {
        _HotelExpenseImage_url =
            "$_HotelExpenseImage_url,${hotel_image_list[i]}";
      }
    }

    String vechile_receipt = "";
    for (int i = 1; i < travel_image_list.length; i++) {
      if (vechile_receipt.isEmpty) {
        vechile_receipt = travel_image_list[i];
      } else {
        vechile_receipt = "$vechile_receipt,${travel_image_list[i]}";
      }
    }

    String other_exp_receipt = "";
    for (int i = 1; i < other_image_list.length; i++) {
      if (other_exp_receipt.isEmpty) {
        other_exp_receipt = other_image_list[i];
      } else {
        other_exp_receipt = "$other_exp_receipt,${other_image_list[i]}";
      }
    }

    try {
      //create multipart request for POST or PATCH method
      var request =
          http.MultipartRequest("POST", Uri.parse(Commons.addExpenses));
      // request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
      // request.fields["select_date"] = newstartDateymd;
      // request.fields["visit_id"] = visit_id_selected;
      // request.fields["travel_purpose"] = travel_purpose;
      // request.fields["from_location"] = formlocation_controller.text;
      // request.fields["to_location"] = tolocation_controller.text;
      // request.fields["mileage_km"] = km_controller.text;
      // request.fields["mileage_allowance"] = mileage_controller.text;
      // request.fields["hotel_exp"] = HotelExpense_controller.text;
      // request.fields["hotel_exp_receipt"] = _HotelExpenseImage_url;
      // request.fields["vechile_fare"] = bus_train_controller.text;
      // request.fields["vechile_receipt"] = vechile_receipt;
      // request.fields["other_exp"] = other_controller.text;
      // request.fields["other_exp_receipt"] = other_exp_receipt;
      // request.fields["remark"] = remark_supportController.text;

      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
      request.fields["select_date"] = newstartDateymd;
      request.fields["visit_id"] = visit_id_selected;
      request.fields["travel_purpose"] = travel_purpose.text;
      if (Traveltype.toLowerCase() == "Yes") {
        request.fields["from_location"] = "";
        request.fields["to_location"] = "";
        request.fields["mileage_km"] = "";
        request.fields["mileage_allowance"] = "";
        request.fields["hotel_exp"] = "";
        request.fields["hotel_exp_receipt"] = "";
        request.fields["vechile_fare"] = "";
        request.fields["vechile_receipt"] = "";
        request.fields["other_exp"] = "";
        request.fields["other_exp_receipt"] = "";
      } else {
        if (routetype.toLowerCase() == "local") {
          request.fields["from_location"] = "";
          request.fields["to_location"] = "";
          request.fields["hotel_exp"] = "";
          request.fields["hotel_exp_receipt"] = "";
          request.fields["vechile_fare"] = "";
          request.fields["vechile_receipt"] = "";

          request.fields["from_location"] = formlocation_controller.text;
          request.fields["to_location"] = tolocation_controller.text;
          request.fields["mileage_km"] = km_controller.text;
          request.fields["mileage_allowance"] = mileage_controller.text;
          request.fields["other_exp"] = other_controller.text;
          request.fields["other_exp_receipt"] = other_exp_receipt;
        } else {
          request.fields["from_location"] = formlocation_controller.text;
          request.fields["to_location"] = tolocation_controller.text;
          request.fields["mileage_km"] = km_controller.text;
          request.fields["mileage_allowance"] = mileage_controller.text;
          request.fields["hotel_exp"] = HotelExpense_controller.text;
          request.fields["hotel_exp_receipt"] = _HotelExpenseImage_url;
          request.fields["vechile_fare"] = bus_train_controller.text;
          request.fields["vechile_receipt"] = vechile_receipt;
          request.fields["other_exp"] = other_controller.text;
          request.fields["other_exp_receipt"] = other_exp_receipt;
        }
      }

      request.fields["remark"] = remark_supportController.text;
      request.fields["route_type"] = routetype;
      request.fields["travel_with_md"] = Traveltype;

      print("sarjeet fields ${request.fields}");
      //add headers
      var sendresponse = await request.send();

      //Get the response from the server
      var responseData = await sendresponse.stream.toBytes();
      var response = String.fromCharCodes(responseData);

      _context.loaderOverlay.hide();
      print('sarjeet log  ${response}');

      if (response == null ||
          response.contains("A PHP Error was encountered") ||
          response.contains("<div") ||
          response.contains("</html")) {
        Commons.flushbar_Messege(_context, "internal server Error ");
      } else {
        SuccessModel successModel = SuccessModel.fromJson(jsonDecode(response));

        if (successModel.status == 1) {
          Commons.Fluttertoast_Messege(_context, successModel.message ?? "");
          Navigator.pop(_context);
        } else {
          Commons.flushbar_Messege(_context, successModel.message!);
        }
      }
    } on SocketException {
      _context.loaderOverlay.hide();
      Commons.flushbar_Messege(_context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }
}
