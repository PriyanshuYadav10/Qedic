import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qedic/utility/HexColor.dart';

import '../apis/app_exception.dart';
import '../expenses/ExpensesListModel.dart';
import '../model/LoginModel.dart';
import '../model/SuccessModel.dart';
import '../utility/Commons.dart';
import 'ExpensesSelect.dart';

class AddReports extends StatefulWidget {
  @override
  _AddReportsState createState() => _AddReportsState();
}

class _AddReportsState extends State<AddReports> {
  TextEditingController title_Controller = TextEditingController();
  TextEditingController startdate_Controller = TextEditingController();
  TextEditingController endtdate_Controller = TextEditingController();
  TextEditingController remarks_Controller = TextEditingController();
  String _selecteStartdate = "";
  String _selectedEnddate = "";
  String expenses_name_selected = "";
  String expenses_id_selected = "";
  List<Data_Expenses> Selected_data_Expenses = <Data_Expenses>[];

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
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Container(
                            child: Text("Reports",
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
                          margin: EdgeInsets.only(left: 25, top: 20.0),
                          child: Text(
                            "Title",
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
                          margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                          child: TextField(
                            controller: title_Controller,
                            style: TextStyle(color: HexColor(HexColor.primary_s)),
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person_pin_outlined,
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
                                hintText: "Enter Title",
                                fillColor: HexColor(HexColor.gray_light)),
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
                            controller: remarks_Controller,
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
                          margin: EdgeInsets.only(left: 25, top: 15.0),
                          child: Text(
                            "Start Date",
                            style: TextStyle(
                              fontSize: 16,
                              color: HexColor(HexColor.primarycolor),
                              fontFamily: 'lato_bold',
                              decoration: TextDecoration.none,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                        ),
                        InkWell(
                          onTap: () {
                            _selectDate("start");
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 3, left: 20, right: 20),
                            child: TextField(
                              enabled: false,
                              controller: startdate_Controller,
                              style: TextStyle(color: HexColor(HexColor.primary_s)),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
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
                                  hintText: "Start Date",
                                  fillColor: HexColor(HexColor.gray_light)),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 25, top: 15.0),
                          child: Text(
                            "End Date",
                            style: TextStyle(
                              fontSize: 16,
                              color: HexColor(HexColor.primarycolor),
                              fontFamily: 'lato_bold',
                              decoration: TextDecoration.none,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                        ),
                        InkWell(
                          onTap: () {
                            _selectDate("end");
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 3, left: 20, right: 20),
                            child: TextField(
                              enabled: false,
                              controller: endtdate_Controller,
                              style: TextStyle(color: HexColor(HexColor.primary_s)),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
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
                                  hintText: "End Date",
                                  fillColor: HexColor(HexColor.gray_light)),
                            ),
                          ),
                        ),
                        InkWell(
                          child: Container(
                        margin:
                            const EdgeInsets.only(top: 20, left: 10, right: 10),
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
                                    "Select Expenses",
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
                        if (_selecteStartdate.isEmpty) {
                          Commons.flushbar_Messege(
                              context, "Please Select Start Date");
                        } else if (_selectedEnddate.isEmpty) {
                          Commons.flushbar_Messege(
                              context, "Please Select End Date");
                        } else {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExpensesSelect(
                                      startdate: _selecteStartdate,
                                      enddate: _selectedEnddate,
                                  slected_id: expenses_id_selected,
                                    )),
                          );
                          if (result != null) {
                            List<Data_Expenses>? data_Expenses = result;
                            setState(() {
                              Selected_data_Expenses.clear();
                              Selected_data_Expenses.addAll(data_Expenses!);
                              expenses_id_selected = "";
                              for (var item in data_Expenses!) {
                                if (expenses_id_selected.isEmpty) {
                                  expenses_id_selected = item.id!;
                                } else {
                                  expenses_id_selected =
                                      expenses_id_selected + "," + item.id!;
                                }
                              }
                              print("sarjeet $expenses_id_selected");
                            });
                          }
                        }
                      },
                        ),
                        Expenses_UI(),
                        Container(
                          margin: EdgeInsets.only(
                              top: 50.0, left: 20.0, bottom: 30, right: 20),
                          height: 50.0,
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor(HexColor.primarycolor),
                                textStyle: TextStyle(fontWeight: FontWeight.bold)),
                            child: Text('Submit'),
                            onPressed: () {
                          if (validation()) {
                            _Addreport(context);
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
    if (title_Controller.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Title");
      return false;
    } else if (remarks_Controller.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Remarks");
      return false;
    } else if (_selecteStartdate.isEmpty) {
      Commons.flushbar_Messege(context, "Please Select Start Date");
      return false;
    } else if (_selectedEnddate.isEmpty) {
      Commons.flushbar_Messege(context, "Please Select End Date");
      return false;
    } else if (expenses_id_selected.isEmpty) {
      Commons.flushbar_Messege(context, "Please Select Expenses");
      return false;
    } else {
      return true;
    }
  }

  Widget Expenses_UI() {
    return Stack(
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: Selected_data_Expenses.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      // Set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(10.0)), // Set rounded corner radius
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            child: Image.asset("images/target.png",height: 20,width: 20,color: HexColor(HexColor.primarycolor),),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              Selected_data_Expenses[index]
                                                  .travelPurpose ??
                                                  "",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: HexColor(HexColor.black),
                                                fontFamily: 'montserrat_medium',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            child: SvgPicture.asset(
                                              "images/home_address.svg",
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.fill,
                                              color:
                                              HexColor(HexColor.primary_s),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              Selected_data_Expenses[index].routeType ??
                                                  "",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1,
                                                color: HexColor(HexColor.black),
                                                fontFamily: 'montserrat_medium',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: [
                                        Container(
                                          child: Image.asset("images/commentary.png",height: 20,width: 20,color: HexColor(HexColor.primarycolor),),

                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              Selected_data_Expenses[index].remark ??
                                                  "",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 14,
                                                height: 1,
                                                color: HexColor(HexColor.black),
                                                fontFamily: 'montserrat_medium',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 5),
                                            child: SvgPicture.asset(
                                              "images/calender.svg",
                                              height: 18,
                                              width: 18,
                                              fit: BoxFit.fill,
                                              color: HexColor(
                                                  HexColor.primary_s),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: 5, top: 5),
                                            child: Text(
                                              Commons.Date_format(
                                                  Selected_data_Expenses[index]
                                                      .selectDate ??
                                                      ""),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 12,
                                                height: 1,
                                                color: HexColor(HexColor.black),
                                                fontFamily:
                                                'montserrat_regular',
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            margin:
                                            const EdgeInsets.only(left: 5),
                                            width: 90,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                              const BorderRadius.all(
                                                  Radius.circular(5)),
                                              color:Selected_data_Expenses[index].status!.toUpperCase() == "PENDING"
                                                  ? HexColor(HexColor.yello1)
                                                  .withOpacity(0.5)
                                                  : Selected_data_Expenses[index].status!.toUpperCase() == "APPROVE"
                                                  ? HexColor(HexColor
                                                  .green_txt)
                                                  .withOpacity(0.5)
                                                  : Colors.red
                                                  .withOpacity(0.5),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            child: Text(
                                              Selected_data_Expenses[index].status!.toUpperCase() ,
                                              style: TextStyle(
                                                decoration: TextDecoration.none,
                                                fontSize: 12,
                                                color: Selected_data_Expenses[index].status!.toUpperCase() == "PENDING"
                                                    ? HexColor(HexColor.yello1)
                                                    : Selected_data_Expenses[index].status!.toUpperCase() == "APPROVE"
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontFamily:
                                                'montserrat_regular',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (Selected_data_Expenses[index].adminComment !=
                                        null &&
                                        Selected_data_Expenses[index].adminComment !=
                                            "")
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: SvgPicture.asset(
                                              "images/comment.svg",
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.fill,
                                              color: HexColor(
                                                  HexColor.primary_s),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              Selected_data_Expenses[index]
                                                  .adminComment ??
                                                  "",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                height: 1,
                                                color: HexColor(HexColor.red_color),
                                                fontFamily:
                                                'montserrat_medium',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
            })
      ],
    );
  }

  void _selectDate(String type) async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
    ).then((date) {
      setState(() {
        if (type == "start") {
          startdate_Controller.text = Commons.Date_format(date.toString());
          _selecteStartdate = Commons.Date_format5(date.toString());
        } else if (type == "end") {
          endtdate_Controller.text = Commons.Date_format(date.toString());
          _selectedEnddate = Commons.Date_format5(date.toString());
        }
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
    String? helpText,
    String? cancelText,
    String? confirmText,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
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

  _Addreport(BuildContext _context) async {
    LoginModel loginModel = await Commons.getuser_info();
    _context.loaderOverlay.show();
    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.report));
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
      request.fields["title"] = title_Controller.text;
      request.fields["remark"] = remarks_Controller.text;
      request.fields["start_date"] = _selecteStartdate;
      request.fields["end_date"] = _selectedEnddate;
      request.fields["exp_ids"] = expenses_id_selected;

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
