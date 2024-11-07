import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import 'apis/app_exception.dart';
import 'model/LoginModel.dart';
import 'model/NoticeBoardModel.dart';

class NotificationActivity extends StatefulWidget {
  // Initially password is obscure
  @override
  State<NotificationActivity> createState() => _NotificationActivityState();
}

class _NotificationActivityState extends State<NotificationActivity> {


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

  List<Orders_Noticeboard> noticeboard = <Orders_Noticeboard>[];

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarColor: HexColor(HexColor.white),
    //     statusBarIconBrightness: Brightness.dark));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
        child: Scaffold(
          appBar: Commons.Appbar_logo(true, context, "Noticeboard"),
          backgroundColor: HexColor(HexColor.gray_activity_background),
          body: noticeboard.length == 0
              ? dataNotFound()
              : Container(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: noticeboard.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        child: Container(
                            color: Colors.white,
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.only(
                                                        top: 15,
                                                        left: 10),
                                                child: Text(
                                                  noticeboard![index].title??"",
                                                  textAlign:
                                                      TextAlign.start,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: HexColor(
                                                        HexColor
                                                            .gray_text),
                                                    fontFamily:
                                                        'montserrat_bold',
                                                    decoration:
                                                        TextDecoration
                                                            .none,
                                                  ),
                                                )),
                                          ),


                                        ],
                                      ),
                                      Container(
                                          padding: const EdgeInsets.only(
                                              right: 10,
                                              left: 10,
                                              bottom: 5,
                                              top: 5),
                                          child: Text(
                                              noticeboard![index].description??"",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: HexColor(
                                                  HexColor.gray_text),
                                              fontFamily:
                                                  'montserrat_regular',
                                              decoration:
                                                  TextDecoration.none,
                                            ),
                                          )),
                                      Container(
                                          padding: const EdgeInsets.only(
                                              right: 10,
                                              left: 10,
                                              bottom: 15),
                                          child: Text(
                                              noticeboard![index].createdAt??"",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: HexColor(
                                                  HexColor.gray_text),
                                              fontFamily:
                                                  'montserrat_medium',
                                              decoration:
                                                  TextDecoration.none,
                                            ),
                                          ))
                                    ],
                                  ),
                                )
                              ],
                            )),
                        onTap: () {});
                  })),
        ),
      ),
    );
  }

  @override
  void initState() {
    _getNoticeBoard();
    super.initState();
  }

  //creat methode retune String capitliase
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  _getNoticeBoard() async {
    LoginModel loginModel = await Commons.getuser_info();

    // context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.noticeBoard));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ??""}";
      // request.fields["user_id"] = "";

      print("sarjeet ${Commons.noticeBoard}");
      print("sarjeet ${request.fields}");
      //add headers
      var sendresponse = await request.send();

      //Get the response from the server
      var responseData = await sendresponse.stream.toBytes();
      var response = String.fromCharCodes(responseData);

      // context.loaderOverlay.hide();
      print('sarjeet log  ${response}');

      if (response == null ||
          response.contains("A PHP Error was encountered") ||
          response.contains("<div") ||
          response.contains("</html")) {
        Commons.flushbar_Messege(context, "internal server Error ");
      } else {
        NoticeBoardModel noticeBoardModel = NoticeBoardModel.fromJson(jsonDecode(response));

        // Commons.flushbar_Messege(context, visitListModel.message ?? "");

        if (noticeBoardModel.status == 1) {
          setState(() {
            noticeboard = noticeBoardModel.orders ?? <Orders_Noticeboard>[];
          });

        } else {
          Commons.flushbar_Messege(context, noticeBoardModel.message!);
        }
      }
    }
    on SocketException {
      // context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }
}
