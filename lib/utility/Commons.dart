import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/LoginModel.dart';
import 'HexColor.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Commons {
  /*test*/
  // static String baseUrl = "";

  /*live*/
  static String baseUrl = "https://qedichealthcare.com/api/";

  static String loginapi = "${baseUrl}login";
  static String holidayList = "${baseUrl}holidayList";
  static String home = "${baseUrl}home";
  static String updatePassword = "${baseUrl}updatePassword";
  static String viewVisit = "${baseUrl}viewVisit";
  static String applyLeave = "${baseUrl}applyLeave";
  static String updateLeave = "${baseUrl}updateLeave";
  static String addVisit = "${baseUrl}addVisit";
  static String updateVisit = "${baseUrl}updateVisit";
  static String updateProfile = "${baseUrl}updateProfile";
  static String uploadImage = "${baseUrl}uploadImage";
  static String noticeBoard = "${baseUrl}noticeBoard";
  static String getLeave = "${baseUrl}getLeave";
  static String addExpenses = "${baseUrl}addExpenses";
  static String viewExpenses = "${baseUrl}viewExpenses";
  static String updateExpenses = "${baseUrl}updateExpenses";
  static String sendOtp = "${baseUrl}sendOtp";
  static String forgetPasswordUpdate = "${baseUrl}forgetPasswordUpdate";
  static String report = "${baseUrl}report/store";
  static String editreport = "${baseUrl}edit/report";
  static String getreport = "${baseUrl}get/reports";
  static String attendance = "${baseUrl}attendance";
  static String getattendance = "${baseUrl}get/attendance";
  static String allListing = "${baseUrl}list-option";
  static String productsListing = "${baseUrl}products";

  static flushbar_Messege(BuildContext context, String text) {
    Flushbar(
      backgroundColor: HexColor(HexColor.red_color),
      positionOffset: 20,
      reverseAnimationCurve: Curves.easeInOut,
      icon: Icon(
        Icons.error,
        size: 28,
        color: HexColor(HexColor.white),
      ),
      message: text,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
  static Fluttertoast_Messege(BuildContext context, String text_message) {
    Fluttertoast.showToast(
        msg: text_message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  static Future<int> getmileageFair() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('mileageFair') ?? 0;
  }

  static void savemileageFair(int mileage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('mileageFair', mileage);
  }

  static Future<bool> getloginstatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('status') ?? false;
  }

  static void saveloginstatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('status', status);
  }

  static Future<LoginModel> getuser_info() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(" sarjeet ${jsonDecode(prefs.getString('userinfo')??"")}");

    LoginModel loginModel =
        LoginModel.fromJson(jsonDecode(prefs.getString('userinfo') ?? ''));
    return loginModel;
  }

  static void saveuser_info(String userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userinfo', userInfo);
  }

  static String Date_format2(String date) {
    var inputFormat = DateFormat('yyyy-MM-dd');
    String datet = "";
    String day = "";
    try {
      day = DateFormat("EEE, dd MMM").format(inputFormat.parse(date));
      datet = day;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return datet;
  }
  static String Date_format(String date) {
    var inputFormat = DateFormat('yyyy-MM-dd');
    String datet = "";
    String day = "";
    try {
      day = DateFormat("EEE, dd MMM yyyy").format(inputFormat.parse(date));
      datet = day;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return datet;
  }
  static String Date_format5(String date) {
    String datet = "";
    String day = "";
    try {
      day = DateFormat("yyyy-MM-dd").format(DateTime.parse(date));
      datet = day;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return datet;
  }
  static String Date_format3(String date) {
    String datet = "";
    String day = "";
    String weekday = "";
    String month = "";
    try {
      day = DateFormat("dd").format(DateTime.parse(date));
      weekday = DateFormat("EEE").format(DateTime.parse(date)).toUpperCase();
      month = DateFormat("MMM").format(DateTime.parse(date)).toUpperCase();
      datet = "$weekday, $day $month";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return datet;
  }
  // 10:41 AM
  static String time_format(String time) {
    String timeUpdate = "";
    try {
      var outputFormat = DateFormat('hh:mm a');
      timeUpdate = outputFormat.format(DateTime.parse(time));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return timeUpdate;
  }

  static PreferredSize Appbar_logo(
      bool backbutton, BuildContext context, String file_name) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        title: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Stack(
                children: [
                  if (backbutton)
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  if (!backbutton)
                  Container(
                    height: 50,
                    child:
                    Container(
                      child:  Image(
                          height: 80,
                          width: 80,
                          color: Colors.white,
                          image: AssetImage('images/q_logo.png')),
                    ),
                    // ,
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 10),
                    child: Container(
                      child: Text(file_name,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 18,
                            color: HexColor(HexColor.white),
                            fontFamily: 'montserrat_bold',
                            decoration: TextDecoration.none,
                          )),
                    ),
                  ),

                ],
              ),
            ),
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
    );
  }

  static ShowSuccessMassageDailong(
      BuildContext context, Function CallBackMathod, String massage) {
    showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            child: Container(
              height: 320,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(bottom: 0, left: 0, right: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: SizedBox.expand(
                  child: Column(children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                      color: HexColor(HexColor.primarycolor),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(7),
                          topLeft: Radius.circular(7)),
                    ),
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10.0),
                    child: const Text("Success",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'montserrat_medium',
                          decoration: TextDecoration.none,
                        ))),
                Container(
                  margin: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                  child: const Image(
                    height: 100,
                    width: 100,
                    alignment: Alignment.center,
                    image: AssetImage(
                      'images/vmx_logo.png',
                    ),
                  ),
                ),
                Container(
                    margin:
                        const EdgeInsets.only(top: 10.0, left: 20, right: 20),
                    child: Center(
                      child: Text(massage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor(HexColor.primarycolor),
                            fontFamily: 'montserrat_regular',
                            decoration: TextDecoration.none,
                          )),
                    )),
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                            child: Container(
                                margin:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: HexColor(HexColor.primarycolor),
                                    foregroundColor: HexColor(HexColor.white),
                                    shadowColor: HexColor(HexColor.gray),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32.0)),
                                    minimumSize: Size(100, 40), //////// HERE
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    CallBackMathod();
                                  },
                                  child: Text('OK'),
                                ))),
                      ],
                    ),
                  ),
                )
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

  static commonBottomSheet(title, data, dataCtrl,context,Function onDataSelected) async {
    double itemHeight = 50.0; // Set your desired height for each item
    double maxHeight = MediaQuery.of(context).size.height * 0.75; // Set the maximum height for the bottom sheet

    int itemCount = data.length;
    double calculatedHeight = itemHeight * itemCount;

    double sheetHeight =
    calculatedHeight > maxHeight ? maxHeight : calculatedHeight;
    print(sheetHeight);
    showModalBottomSheet(
      context: context,
        builder: (BuildContext context) {
        return SizedBox(
          height: sheetHeight + 50,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: HexColor(HexColor.black),
                      fontFamily: 'montserrat_regular',
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                          dataCtrl.text = data[index].toString();
                          onDataSelected(data[index].toString());
                          Navigator.of(context).pop();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        // Remove fixed height and width properties
                        decoration: BoxDecoration(
                          color: HexColor(HexColor.white),
                          borderRadius: BorderRadius.circular(0),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 2.5)
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 4),
                          child: Text(
                            data[index].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: HexColor(HexColor.black),
                              fontFamily: 'montserrat_regular',
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
      ),
    );
  }

}
