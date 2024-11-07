import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import '../apis/app_exception.dart';
import '../model/LoginModel.dart';
import '../model/SuccessModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

import 'package:loader_overlay/loader_overlay.dart';


class NewLeaves extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewLeaves();
}

class _NewLeaves extends State<NewLeaves> {
  var OneDay = true;
  var startdatecalendar = false;
  var enddatecalendar = false;
  late DateTime StartDate;
  late DateTime EndDate;

  String leave_type = "Casual";
  String day_type = "Half Day";
  List<String> leavetype_list = [
    "Casual",
    "Sick",
    "Earned",
    "Maternity",
    "Paternity",
    "Other",
  ];
  List<bool> leavecheck = [true, false, false, false, false, false];

  List<String> daytypelist = ["Half Day", "Full Day", "Multiple Days"];
  List<bool> daycheck = [true, false, false];
  int leavelastindex = 0;
  int dayslastindex = 0;
  var leave_days;

  DateTime initialDate = DateTime.now().add(const Duration(days: 1));
  var newstartDate = "Select Date";
  var newendDate = "Select Date";

  var selected_start_date = "Select Date";
  var newendDateymd = "Select Date";

  TextEditingController description_Controller = new TextEditingController();

  @override
  void initState() {
    initializeDateFormatting();
    Intl.systemLocale = 'en_En'; // to change the calendar format based on localization
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
        child: Scaffold(
          appBar: Commons.Appbar_logo(true, context, "Apply Leave"),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: daytypelist.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return InkWell(
                                        child: Stack(
                                          children: [
                                            Container(
                                                alignment: Alignment.center,
                                                height: 40,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: daycheck[index]
                                                            ? HexColor(HexColor
                                                                .primarycolor)
                                                            : HexColor(HexColor
                                                                .primarycolor)),
                                                    color: daycheck[index]
                                                        ? HexColor(
                                                            HexColor.primarycolor)
                                                        : HexColor(
                                                            HexColor.gray_activity_background),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(12))),
                                                padding: const EdgeInsets.all(10),
                                                margin: const EdgeInsets.only(
                                                  left: 20,
                                                ),
                                                child: InkWell(
                                                  child: Text(daytypelist[index],
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: daycheck[index]
                                                            ? HexColor(
                                                                HexColor.white)
                                                            : HexColor(HexColor
                                                                .primarycolor),
                                                        decoration:
                                                            TextDecoration.none,
                                                        fontFamily: 'montserrat_regular',
                                                      )),
                                                    onTap: () {
                                                      setState(() {
                                                        if (dayslastindex != -1) {
                                                          daycheck[dayslastindex] = false;
                                                        }
                                                        daycheck[index] = true;
                                                        day_type = daytypelist[index];
                                                        newstartDate = "Select Date";
                                                        newendDate = "Select Date";
                                                        startdatecalendar = false;
                                                        enddatecalendar = false;
                                                        if (day_type == "Multiple Days") {
                                                          OneDay = false;
                                                        } else {
                                                          OneDay = true;
                                                        }
                                                        dayslastindex = index;
                                                      });
                                                    }
                                                )),
                                          ],
                                        ),
                                        );
                                  })),
                        ),
                      ],
                    ),
                  ),
                  if (OneDay)
                    InkWell(
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 20, bottom: 10, left: 10, right: 10),
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            color: HexColor(HexColor.gray_text).withOpacity(.1),
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
                          enddatecalendar = false;
                        });
                      },
                    ),
                  if (!OneDay)
                    InkWell(
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 20, bottom: 10, left: 10, right: 10),
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: HexColor(HexColor.gray_text).withOpacity(.1),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "From",
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
                          enddatecalendar = false;
                          newendDate="Select Date";
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
                            todayTextStyle:
                            TextStyle(color: HexColor(HexColor.primarycolor)),
                            weekendTextStyle: TextStyle(
                                color: HexColor(HexColor.yello))),
                        initialDisplayDate: DateTime.now(),
                        minDate: DateTime.now(),
                        monthFormat: 'MMM',
                        todayHighlightColor: Colors.transparent,
                        selectionColor: HexColor(HexColor.primarycolor),
                      ),
                    ),
                  if (!OneDay)
                    InkWell(
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom: 10, left: 10, right: 10),
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            color: HexColor(HexColor.gray_text).withOpacity(.1),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "To",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: HexColor(HexColor.black),
                                      fontFamily: 'montserrat_medium',
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        newendDate,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: HexColor(HexColor.gray_line),
                                          fontFamily: 'montserrat_medium',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(left: 10),
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
                        if (newstartDate == "Select Date") {
                          Fluttertoast.showToast(
                              msg: "Select Start Date first",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          setState(() {
                            startdatecalendar = false;
                            enddatecalendar = true;
                          });
                        }
                      },
                    ),
                  if (enddatecalendar)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: SfDateRangePicker(
                        onSelectionChanged: _onSelectionChanged2,
                        selectionMode: DateRangePickerSelectionMode.single,
                        monthCellStyle: DateRangePickerMonthCellStyle(
                            todayTextStyle:
                                TextStyle(color: HexColor(HexColor.primarycolor)),
                            weekendTextStyle: TextStyle(
                                color: HexColor(HexColor.yello))),
                        initialDisplayDate: StartDate.add(const Duration(days: 1)),
                        minDate: StartDate.add(const Duration(days:1)),
                        monthFormat: 'MMM',
                        todayHighlightColor: Colors.transparent,
                        selectionColor: HexColor(HexColor.primarycolor),
                      ),
                    ),
                  Container(
                      margin:
                          const EdgeInsets.only(bottom: 10, left: 25, right: 25),
                      child: Divider(
                        color: HexColor(HexColor.gray_line),
                      )),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Column(
                      children: [
                        if (true)
                          Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            alignment: Alignment.topLeft,
                            height: 40,
                            child: Text(
                              "Leave Type",
                              style: TextStyle(
                                fontSize: 18,
                                color: HexColor(HexColor.black),
                                fontFamily: 'montserrat_medium',
                              ),
                            ),
                          ),
                        Container(
                            alignment: Alignment.topLeft,
                            height: 40,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: leavetype_list.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Stack(
                                    children: [
                                      Container(
                                          alignment: Alignment.center,
                                          height: 40,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: leavecheck[index]
                                                      ? HexColor(HexColor
                                                          .primarycolor)
                                                      : HexColor(HexColor
                                                          .primarycolor)),
                                              color: leavecheck[index]
                                                  ? HexColor(
                                                      HexColor.primarycolor)
                                                  : HexColor(HexColor.gray_activity_background),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12))),
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: InkWell(
                                            child: Text(leavetype_list[index],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: leavecheck[index]
                                                      ? HexColor(HexColor.white)
                                                      : HexColor(HexColor
                                                          .primarycolor),
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontFamily: 'montserrat_regular',
                                                )),
                                              onTap: () {
                                                print("indexdata $index");
                                                setState(() {
                                                  if (leavelastindex != -1) {
                                                    leavecheck[leavelastindex] = false;
                                                  }
                                                  leavecheck[index] = true;
                                                  leave_type = leavetype_list[index];
                                                  leavelastindex = index;
                                                });
                                              }
                                          )),
                                    ],
                                  );
                                })),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   "Description   :",
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     color: HexColor(HexColor.black),
                        //     fontFamily: 'montserrat_medium',
                        //   ),
                        // ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: TextField(
                            controller: description_Controller,
                            // textInputAction: TextInputAction.done,
                            textAlign: TextAlign.justify,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                        color: HexColor(HexColor.black))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                        color: HexColor(HexColor.primarycolor))),
                                labelText: 'Description',
                                labelStyle: TextStyle(
                                    color: HexColor(HexColor.gray_text)),
                                hintText: 'Enter description for leave',
                                hintStyle: TextStyle(
                                    color: HexColor(HexColor.gray_text))),
                            cursorColor: HexColor(HexColor.primarycolor),
                            minLines: 5,
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20),
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
                        if (newstartDate == "Select Date") {
                          Fluttertoast.showToast(
                              msg: "Select start date",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                        else if (day_type == "Multiple Days" &&
                            newendDate == "Select Date") {
                          Fluttertoast.showToast(
                              msg: "Select end date",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else if (description_Controller.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Enter description",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                           RequestLeaveAPI();
                        }
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSelectionChanged1(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      startdatecalendar = false;
      StartDate = args.value;
        newstartDate = Commons.Date_format2(StartDate.toString());
      selected_start_date = Commons.Date_format5(StartDate.toString());
    });
  }

  void _onSelectionChanged2(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      enddatecalendar = false;
      EndDate = args.value;
      newendDate = Commons.Date_format2(EndDate.toString());
      newendDateymd = Commons.Date_format5(EndDate.toString());
    });
  }



  RequestLeaveAPI() async {
    LoginModel loginModel = await Commons.getuser_info();

     context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.applyLeave));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ??""}";
      request.fields["start_date"] = selected_start_date;
      request.fields["leave_type"] = leave_type;
      request.fields["description"] = description_Controller.text;
      request.fields["leave_data"] = day_type;
      if(day_type == "Multiple Days"){
        request.fields["end_date"] = newendDateymd;
        request.fields["type"] = "Multiple";
      }else{
        request.fields["type"] = "Single";
      }

      // request.fields["user_id"] = "5";

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


}
