import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:qedic/reports/AddReports.dart';

import '../model/LoginModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'ReportListModel.dart';
import 'UpdateReports.dart';

class Reports extends StatefulWidget {
  @override
  State<Reports> createState() => _ExpensesState();
}

class _ExpensesState extends State<Reports> {
  List<Data_report> report_Data = [];
  Future<void> _launchInBrowser(Uri url) async {

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  var downloadurl = 'https://qedichealthcare.com/api/report-export/';
  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        child: Scaffold(
      backgroundColor: HexColor(HexColor.white),
      appBar: Commons.Appbar_logo(true, context, "Reports"),
      body: report_Data.isEmpty ? _dataNotFound() : Expenses_UI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AddReports(),
            ),
          ).then((value) {
            getreport();
          });
        },
        backgroundColor: HexColor(HexColor.primarycolor),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    ));
  }

  Widget _dataNotFound() {
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

  Widget Expenses_UI() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: report_Data.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    if (report_Data[index].status!.toUpperCase() == "0") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => UpdateReports(
                            data_report: report_Data![index],
                          ),
                        ),
                      ).then((value) => {getreport()});
                    }
                  },
                  child: Container(
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
                                              child: Icon(
                                                Icons.person_pin_outlined,
                                                color: HexColor(
                                                    HexColor.primarycolor),
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                report_Data[index].title ?? "",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      HexColor(HexColor.black),
                                                  fontFamily:
                                                      'montserrat_medium',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible:  report_Data[index]
                                                .status ==
                                                '1',
                                            child: InkWell(
                                              onTap: () {
                                                final uriStr = downloadurl +
                                                    report_Data[index]
                                                        .id
                                                        .toString();
                                                print(uriStr);
                                                final uri = Uri.parse(uriStr);
                                                final _launchedd =
                                                    _launchInBrowser(uri);
                                                print(_launchedd);
                                              },
                                              child: Icon(
                                                Icons
                                                    .download_for_offline_rounded,
                                                color: HexColor(
                                                    HexColor.primarycolor),
                                                size: 27,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 0,
                                            child: Container(
                                              child: Icon(
                                                Icons.list_alt_sharp,
                                                color: HexColor(
                                                    HexColor.primarycolor),
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                report_Data[index].remark ?? "",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      HexColor(HexColor.black),
                                                  fontFamily:
                                                      'montserrat_medium',
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
                                                // Commons.Date_format(
                                                //     expenses_list[index]
                                                //         .selectDate ??
                                                //         ""),
                                                report_Data[index].startDate ??
                                                    "",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  height: 1,
                                                  color:
                                                      HexColor(HexColor.black),
                                                  fontFamily:
                                                      'montserrat_regular',
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
                                              margin: const EdgeInsets.only(
                                                  left: 5, top: 5),
                                              child: Text(
                                                // Commons.Date_format(
                                                //     expenses_list[index]
                                                //         .selectDate ??
                                                //         ""),
                                                report_Data[index].endDate ??
                                                    "",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  height: 1,
                                                  color:
                                                      HexColor(HexColor.black),
                                                  fontFamily:
                                                      'montserrat_regular',
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
                                                "images/money.svg",
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
                                                // Commons.Date_format(
                                                //     expenses_list[index]
                                                //         .selectDate ??
                                                //         ""),
                                                "₹ ${report_Data[index].total_amount ?? 0}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  height: 1,
                                                  color:
                                                      HexColor(HexColor.black),
                                                  fontFamily:
                                                      'montserrat_regular',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  left: 5),
                                              width: 90,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(5)),
                                                color: report_Data[index]
                                                            .status!
                                                            .toUpperCase() ==
                                                        "0"
                                                    ? HexColor(HexColor.yello1)
                                                        .withOpacity(0.5)
                                                    : report_Data[index]
                                                                .status!
                                                                .toUpperCase() ==
                                                            "1"
                                                        ? HexColor(HexColor
                                                                .green_txt)
                                                            .withOpacity(0.5)
                                                        : Colors.red
                                                            .withOpacity(0.5),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              child: Text(
                                                report_Data[index].status == '0'
                                                    ? "PENDING"
                                                    : report_Data[index]
                                                                .status ==
                                                            '1'
                                                        ? "APPROVE"
                                                        : "Reject",
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 12,
                                                  color: report_Data[index]
                                                              .status!
                                                              .toUpperCase() ==
                                                          "0"
                                                      ? HexColor(
                                                          HexColor.yello1)
                                                      : report_Data[index]
                                                                  .status!
                                                                  .toUpperCase() ==
                                                              "1"
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
                                      if (report_Data[index].admin_comment !=
                                              null &&
                                          report_Data[index].admin_comment !=
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
                                                report_Data[index]
                                                        .admin_comment ??
                                                    "",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  height: 1,
                                                  color: HexColor(
                                                      HexColor.red_color),
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
        )
      ],
    );
  }

  @override
  void initState() {
    getreport();
    super.initState();
  }

  getreport() async {
    LoginModel loginModel = await Commons.getuser_info();

    context.loaderOverlay.show();
    String url = Commons.getreport + "/${loginModel.data!.id ?? ""}";
    // String url = Commons.getreport + "/32";
    print("sarjeet: ${url}");

    try {
      http.Response response = await http.get(Uri.parse(url));
      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        String responseData = response.body;
        print("sarjeet ${responseData}");

        ReportListModel? reportListModel =
            ReportListModel.fromJson(jsonDecode(responseData));

        if (reportListModel.status == 1) {
          setState(() {
            report_Data = reportListModel.data ?? [];
            print("sarjeet ${report_Data.length}");
          });
        }
      } else {
        // Request failed with an error status code
        print("sarjeet Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      // An error occurred during the request
      print("sarjeet Error: ${e.toString()}");
    }
  }
}
