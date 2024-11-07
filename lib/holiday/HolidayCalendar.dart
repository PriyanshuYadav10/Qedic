import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../apis/app_exception.dart';
import '../utility/HexColor.dart';
import 'HolidayModel.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:qedic/services/BaseService.dart';
import 'package:qedic/services/NetworkSevice.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';

class HolidayCalendar extends StatefulWidget {
  HolidayCalendar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HolidayCalendar();
}

class _HolidayCalendar extends State<HolidayCalendar> {
  List<Orders> holidaylistdata = <Orders>[];

  @override
  void initState() {
    getHolidayList();
    super.initState();
  }

  bool isloader = false;
  getHolidayList() async {
    setState(() {
      isloader = true;
    });
    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("GET", Uri.parse(Commons.holidayList));

      var sendresponse = await request.send();

      //Get the response from the server
      var responseData = await sendresponse.stream.toBytes();
      var response = String.fromCharCodes(responseData);

      setState(() {
        isloader = false;
      });
      print('sarjeet log  ${response}');
      if (response == null ||
          response.contains("A PHP Error was encountered") ||
          response.contains("<div") ||
          response.contains("</html")) {
        Commons.flushbar_Messege(context, "internal server Error ");
      } else {
        HolidayModel holidayModel = HolidayModel.fromJson(jsonDecode(response));
        if (holidayModel.status == 1) {
          setState(() {
            holidaylistdata = holidayModel.orders!;
          });
        } else {
          Commons.flushbar_Messege(context, holidayModel.message!);
        }
      }
    } on SocketException {
      setState(() {
        isloader = false;
      });
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
        child: Scaffold(
          backgroundColor: HexColor(HexColor.gray_activity_background),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: AppBar(
              title: Stack(
                children: <Widget>[
                  InkWell(
                    child: Icon(
                      Icons.arrow_back,
                      color: HexColor(HexColor.white),
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          "Holiday Calendar",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'montserrat_bold',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              centerTitle: true,
              backgroundColor: HexColor(HexColor.primary_s),
              elevation: 2,
              automaticallyImplyLeading: false,
            ),
          ),
          body: Stack(
            children: [
              holidaylistdata.isEmpty ?dataNotFound():Container(
                margin:  EdgeInsets.only(top: 10),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: holidaylistdata.length,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: SvgPicture.asset(
                                    "images/festival.svg",
                                    height: 20,
                                    width: 20,
                                    fit: BoxFit.fill,
                                    color: HexColor(HexColor.primary_s),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text(
                                    holidaylistdata[index].title ?? "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1,
                                      color: HexColor(HexColor.black),
                                      fontFamily: 'montserrat_medium',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: SvgPicture.asset(
                                    "images/calender.svg",
                                    height: 20,
                                    width: 20,
                                    fit: BoxFit.fill,
                                    color: HexColor(HexColor.primary_s),
                                  ),
                                ),

                                  Container(
                                    margin: EdgeInsets.only(left: 5, top: 5),
                                    child: Text(
                                      holidaylistdata[index].holidayFrom ==
                                              holidaylistdata[index].holidayTo
                                          ? holidaylistdata[index].holidayFrom ?? ""
                                          : "${holidaylistdata[index].holidayFrom} - ${holidaylistdata[index].holidayTo}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1,
                                        color: HexColor(HexColor.black),
                                        fontFamily: 'montserrat_regular',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              ),

              if (isloader)
                Container(
                  alignment: Alignment.center,
                  color: Colors.white.withOpacity(0.95),
                  height: double.infinity,
                  width: double.infinity,
                  child:  Center(
                    child: Lottie.asset('images/loader.json', width: 50),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget dataNotFound() {
    return Column(
      children: [
        Container(child: Lottie.asset('images/data_not_found.json')),
        Container(
          child: Text(
            "No Data Found",
            style: TextStyle(
              fontSize: 16,
              color: HexColor(HexColor.black),
              fontFamily: 'montserrat_regular',
            ),
          ),
        ),
      ],
    );
  }


// HolidayListAPI() async {
//   var jsondata = jsonEncode(<String, String>{
//     'uniquecode': uniquecode,
//     'role': role,
//     'token': auth_token,
//     'device': await Commons_file.getDevice_info(),
//   });
//
//   HolidayModel holidayModel =
//       await APICommon.holidayListAPI(context, jsondata);
//   if (holidayModel.status == Commons_file.SUCCESSCODE) {
//     setState(() {
//       dataHolidayisEmpty = false;
//       holidaylistdata = holidayModel.data!;
//     });
//   } else {
//     Fluttertoast.showToast(
//         msg: "${holidayModel.message}",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0);
//     setState(() {
//       holidaylistdata.clear();
//       dataHolidayisEmpty = true;
//     });
//   }
// }
}
