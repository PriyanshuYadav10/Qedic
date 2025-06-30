import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

// import 'package:in_app_update/in_app_update.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';

import 'LoginActivity.dart';
import 'apis/app_exception.dart';
import 'model/HomeModel.dart';
import 'model/LoginModel.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    UpdateProfile();
    gethome_data();

    super.initState();
  }

  LoginModel? loginModel;
  String picture = "";
  String namef = "";
  String namel = "";
  String email = "";
  String mobile = "";
  int total_visits = 0;
  int pending_visits = 0;
  int approve_visits = 0;
  double pending_visits_per = 0;
  double approve_visits_per  = 0;
  bool isloader=false;
  UpdateProfile() async {
    loginModel = await Commons.getuser_info();
    setState(() {
      picture = loginModel!.data!.picture ?? "";
      namef = loginModel!.data!.firstName ?? "";
      namel = loginModel!.data!.lastName ?? "";
      email = loginModel!.data!.email ?? "";
      mobile = loginModel!.data!.mobile ?? "";
    });
  }

  final colorList = <Color>[
    HexColor(HexColor.green1),
    HexColor(HexColor.accentcolor),
  ];
  final dataMap = <String, double>{"pending": 0, "approve": 0};


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: HexColor(HexColor.white),
        statusBarIconBrightness: Brightness.dark));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
          child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(
            title: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(left: 10),
                      )),
                  Expanded(
                      flex: 0,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Image(
                            height: 80,
                            width: 80,
                            color: Colors.white,
                            image: AssetImage('images/q_logo.png')),
                      )),
                ],
              ),
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
        backgroundColor: HexColor(HexColor.gray_activity_background),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: HexColor(HexColor.primary_s),
                            boxShadow: [
                              BoxShadow(
                                color: HexColor(HexColor.gray),
                                offset: const Offset(.1, 1.0),
                                blurRadius: 0.1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  "Dashboard",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: HexColor(HexColor.white),
                                    fontFamily: 'lato_bold',
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(
                                  "Hello, ${namef} ${namel}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: HexColor(HexColor.white),
                                    fontFamily: 'lato_bold',
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 151,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          color: HexColor(HexColor.white),
                                          boxShadow: [
                                            BoxShadow(
                                              color: HexColor(HexColor.gray),
                                              offset: const Offset(.1, 1.0),
                                              //(x,y)
                                              blurRadius: 0.1,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 60,
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: HexColor(HexColor.pink),
                                                  shape: BoxShape.circle),
                                              child: SvgPicture.asset(
                                                "images/target.svg",
                                                color: HexColor(HexColor.white),
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 10),
                                              child: Text(
                                                total_visits.toString(),
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: HexColor(HexColor.black),
                                                  fontFamily: 'lato_bold',
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(top: 7),
                                              child: Text(
                                                "Visit",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: HexColor(HexColor.gray),
                                                  fontFamily: 'lato_bold',
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 151,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          color: HexColor(HexColor.white),
                                          boxShadow: [
                                            BoxShadow(
                                              color: HexColor(HexColor.gray),
                                              offset: const Offset(.1, 1.0),
                                              //(x,y)
                                              blurRadius: 0.1,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 60,
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                  color: HexColor(HexColor.green1),
                                                  shape: BoxShape.circle),
                                              child: SvgPicture.asset(
                                                "images/settings.svg",
                                                color: HexColor(HexColor.white),
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 10),
                                              child: Text(
                                                pending_visits.toString(),
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: HexColor(HexColor.black),
                                                  fontFamily: 'lato_bold',
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(top: 7),
                                              child: Text(
                                                "Pending",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: HexColor(HexColor.gray),
                                                  fontFamily: 'lato_bold',
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 151,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          color: HexColor(HexColor.white),
                                          boxShadow: [
                                            BoxShadow(
                                              color: HexColor(HexColor.gray),
                                              offset: const Offset(.1, 1.0),
                                              //(x,y)
                                              blurRadius: 0.1,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 60,
                                              padding: EdgeInsets.all(13),
                                              decoration: BoxDecoration(
                                                  color: HexColor(
                                                      HexColor.accentcolor),
                                                  shape: BoxShape.circle),
                                              child: SvgPicture.asset(
                                                "images/list.svg",
                                                color: HexColor(HexColor.white),
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 10),
                                              child: Text(
                                                approve_visits.toString(),
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: HexColor(HexColor.black),
                                                  fontFamily: 'lato_bold',
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(top: 7),
                                              child: Text(
                                                "Approve",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: HexColor(HexColor.gray),
                                                  fontFamily: 'lato_bold',
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        color: HexColor(HexColor.white),
                        boxShadow: [
                          BoxShadow(
                            color: HexColor(HexColor.gray),
                            offset: const Offset(.1, 1.0),
                            //(x,y)
                            blurRadius: 0.1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20, top: 20),
                            child: Text(
                              "Visit Progress Chart",
                              style: TextStyle(
                                fontSize: 16,
                                color: HexColor(HexColor.black),
                                fontFamily: 'lato_bold',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 20, left: 20),
                                      height: 250,
                                      child: PieChart(
                                        dataMap: dataMap,
                                        animationDuration:
                                            Duration(milliseconds: 800),
                                        chartLegendSpacing: 40,
                                        chartRadius:
                                            MediaQuery.of(context).size.width / 2.2,
                                        colorList: colorList,
                                        initialAngleInDegree: 0,
                                        chartType: ChartType.ring,
                                        ringStrokeWidth: 40,
                                        centerText: "${total_visits}\nTotal Visit",
                                        legendOptions: LegendOptions(
                                          showLegendsInRow: false,
                                          legendPosition: LegendPosition.right,
                                          showLegends: false,
                                          legendTextStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        chartValuesOptions: ChartValuesOptions(
                                          showChartValueBackground: false,
                                          showChartValues: false,
                                          showChartValuesInPercentage: false,
                                          showChartValuesOutside: false,
                                          decimalPlaces: 1,
                                        ),
                                        // gradientList: ---To add gradient colors---
                                        // emptyColorGradient: ---Empty Color gradient---
                                      ),
                                    )),
                                Expanded(
                                    flex: 0,
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 15,
                                                  width: 15,
                                                  margin:
                                                      EdgeInsets.only(right: 10),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          HexColor(HexColor.green1),
                                                      shape: BoxShape.circle),
                                                ),
                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          "${pending_visits_per.toStringAsFixed(1)}%",
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: HexColor(
                                                                HexColor.black),
                                                            fontFamily: 'lato_bold',
                                                            decoration:
                                                                TextDecoration.none,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          "Pending",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: HexColor(
                                                                HexColor.gray),
                                                            fontFamily: 'lato_bold',
                                                            decoration:
                                                                TextDecoration.none,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                EdgeInsets.only(right: 10, top: 20),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 15,
                                                  width: 15,
                                                  margin:
                                                      EdgeInsets.only(right: 10),
                                                  decoration: BoxDecoration(
                                                      color: HexColor(
                                                          HexColor.accentcolor),
                                                      shape: BoxShape.circle),
                                                ),
                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          "${approve_visits_per.toStringAsFixed(1)}%",
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: HexColor(
                                                                HexColor.black),
                                                            fontFamily: 'lato_bold',
                                                            decoration:
                                                                TextDecoration.none,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          "Approve",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: HexColor(
                                                                HexColor.gray),
                                                            fontFamily: 'lato_bold',
                                                            decoration:
                                                                TextDecoration.none,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
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
      )),
    );
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  gethome_data() async {
    setState(() {
      isloader = true;
    });
    LoginModel loginModel = await Commons.getuser_info();
    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.home));
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";

      var sendresponse = await request.send();

      print("sarjeet ${Commons.home}");
      print("sarjeet ${request.fields}");

      //Get the response from the server
      var responseData = await sendresponse.stream.toBytes();
      var response = String.fromCharCodes(responseData);

      // context.loaderOverlay.hide();
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
        HomeModel homeModel = HomeModel.fromJson(jsonDecode(response));
        if (homeModel.status == 1) {
          setState(() {
            total_visits = homeModel.totalVisits!;
            pending_visits = homeModel.pendingVisits!;
            approve_visits = homeModel.approveVisits!;
            Commons.savemileageFair(homeModel.mileageFair!);

             pending_visits_per = (pending_visits / total_visits) * 100;
             approve_visits_per = (approve_visits / total_visits) * 100;

             print("sarjeet pending_visits_per $pending_visits_per");
             print("sarjeet approve_visits_per $approve_visits_per");

            final dataMap1 = <String, double>{
              "pending": pending_visits_per,
              "approve": approve_visits_per
            };

            dataMap.addAll(dataMap1);
          });
        } else {
          Commons.flushbar_Messege(context, homeModel.message!);
        }
      }
    } on SocketException {
      // context.loaderOverlay.hide();
      setState(() {
        isloader = false;
      });
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }
}
