import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qedic/Leaves/updateleave.dart';
import 'package:flutter_svg/svg.dart';

import '../apis/app_exception.dart';
import '../model/LoginModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import 'LeaveListModel.dart';
import 'NewLeaves.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class AllLeaves extends StatefulWidget {
  const AllLeaves({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AllLeaves();
}

class _AllLeaves extends State<AllLeaves> {
  List<Data_leave> leaveList = <Data_leave>[];
  bool dataLeaveisEmpty = false;

  Widget dataNotFound() {
    return Column(
      children: [
        Container(
            child: Lottie.asset('images/data_not_found.json')),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: Commons.Appbar_logo(true, context, "Leave"),
        body: Stack(
          children: [

            leaveList.isEmpty? dataNotFound():
            ListView.builder(
                  itemCount: leaveList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        if(leaveList[index].status!.toUpperCase() == "PENDING"){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>UpdateLeave(data_leave: leaveList![index],),
                            ),
                          ).then((value) => {_getLiaveList()});
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            // Set border width
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)), // Set rounded corner radius
                            boxShadow: [BoxShadow(blurRadius: 1,color: Colors.grey,offset: Offset(0,0))] // Make rounded corner of border
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex:1,
                                                        child:     Container(
                                                        alignment: Alignment.topLeft,
                                                        child: Text(
                                                          leaveList[index].leaveData ?? " ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: HexColor(HexColor.yello),
                                                            fontFamily: 'montserrat_medium',
                                                          ),
                                                        ),
                                                      ),),
                                                      Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                                left: 5),
                                                        width: 90,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.rectangle,
                                                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                          color: leaveList[index].status?.toUpperCase() == "PENDING" ? HexColor(HexColor.yello1).withOpacity(0.5): leaveList[index].status?.toUpperCase() == "APPROVED" ? HexColor(HexColor.green_txt).withOpacity(0.5) : Colors.red.withOpacity(0.5),
                                                        ),
                                                        padding: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 8,
                                                            vertical: 3),
                                                        child: Text(
                                                          leaveList[index]
                                                                  .status ??
                                                              "",
                                                          style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            fontSize: 12,
                                                            color: leaveList[index].status?.toUpperCase() == "PENDING" ? HexColor(HexColor.accentcolor)
                                                                : leaveList[index]
                                                                            .status
                                                                            ?.toUpperCase() ==
                                                                        "APPROVED"
                                                                    ? Colors.green
                                                                    : Colors.red,
                                                            fontFamily:
                                                                'montserrat_regular',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if ((leaveList[index].leaveData ?? " ") != "Multiple Days")
                                            Container(
                                              margin: const EdgeInsets.symmetric(
                                                  vertical: 7),
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                Commons.Date_format(leaveList[index].startDate ?? " "),
                                                style: const TextStyle(
                                                  decoration: TextDecoration.none,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontFamily: 'montserrat_medium',
                                                ),
                                              ),
                                            ),
                                          if ((leaveList[index].leaveData ??
                                                  " ") ==
                                              "Multiple Days")
                                            Container(
                                              margin: const EdgeInsets.symmetric(
                                                  vertical: 7),
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "${Commons.Date_format(leaveList[index].startDate ?? " ")} to ${Commons.Date_format(leaveList[index].endDate ?? " ")} ",
                                                style: const TextStyle(
                                                  decoration: TextDecoration.none,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontFamily: 'montserrat_medium',
                                                ),
                                              ),
                                            ),

                                          Container(

                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              leaveList[index].description ?? " ",
                                              style: const TextStyle(
                                                decoration: TextDecoration.none,
                                                fontSize: 13,
                                                color: Colors.grey,
                                                fontFamily: 'montserrat_regular',
                                              ),
                                            ),
                                          ),
                                          if (leaveList[index].adminComment !=
                                              null &&
                                              leaveList[index].adminComment !=
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
                                                    leaveList[index]
                                                        .adminComment ??
                                                        "",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      height: 1,
                                                      color:
                                                      HexColor(HexColor.red_color),
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
                      ),
                    );
                  }),

          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => NewLeaves(),
              ),
            ).then((value) {
              _getLiaveList();
            });
          },
          backgroundColor: HexColor(HexColor.primarycolor),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      _getLiaveList();
    });
    super.initState();
  }



  @override
  void dispose() {
    super.dispose();
  }

  _getLiaveList() async {
    LoginModel loginModel = await Commons.getuser_info();

    // context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.getLeave));
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
        LeaveListModel leaveListModel = LeaveListModel.fromJson(jsonDecode(response));

        // Commons.flushbar_Messege(context, visitListModel.message ?? "");

        if (leaveListModel.status == 1) {
          setState(() {
            leaveList = leaveListModel.data ?? <Data_leave>[];
          });

        } else {
          Commons.flushbar_Messege(context, leaveListModel.message!);
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
