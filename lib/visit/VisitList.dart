import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qedic/visit/UpdateVisit.dart';
import '../apis/app_exception.dart';
import '../model/LoginModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import 'AddVisit.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import 'VisitListModel.dart';

class VisitList extends StatefulWidget {
  @override
  State<VisitList> createState() => _VisitListState();
}

class _VisitListState extends State<VisitList> {
  List<VisitListData> visitListData = <VisitListData>[];

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        child: Scaffold(
      backgroundColor: HexColor(HexColor.white),
      appBar: Commons.Appbar_logo(false, context, ""),
      body: visitListData!.isEmpty ? dataNotFound() : visitListUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AddVisit(),
            ),
          ).then((value) {
            visitOppt = false;
            getVisitListAPI('visit');
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

  bool visitOppt = false;
  Widget visitListUI() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    visitOppt = false;
                    getVisitListAPI('visit');
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: visitOppt
                          ? HexColor(HexColor.gray_glash)
                          : HexColor(HexColor.primary_s),
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(
                    'Visit',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          HexColor(visitOppt ? HexColor.black : HexColor.white),
                      fontFamily: 'montserrat_medium',
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    visitOppt = true;
                    getVisitListAPI('oppo');
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: visitOppt
                          ? HexColor(HexColor.primary_s)
                          : HexColor(HexColor.gray_glash),
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(
                    'opportunity',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          HexColor(visitOppt ? HexColor.white : HexColor.black),
                      fontFamily: 'montserrat_medium',
                    ),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
                itemCount: visitListData.length,
                itemBuilder: (BuildContext context, int index) {
                  print("sarjeet index ${visitListData[index].centerName}");
                  return visitOppt
                      ? InkWell(
                          onTap: () {
                            if (visitListData![index].status == "Pending" ||
                                visitListData![index].isEditable == "0") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      UpdateVisit(
                                          visitListData: visitListData![index]),
                                ),
                              ).then((value) => {
                                    setState(() {
                                      visitListData!.clear();
                                      visitOppt = false;
                                      getVisitListAPI('visit');
                                    })
                                  });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                // Set border width
                                borderRadius: BorderRadius.all(Radius.circular(
                                    10.0)), // Set rounded corner radius
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1,
                                      color: Colors.grey,
                                      offset: Offset(0, 0))
                                ] //Make rounded corner of border
                                ),
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                                                      child: SvgPicture.asset(
                                                        "images/ic_visit.svg",
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
                                                          left: 5),
                                                      child: Text(
                                                        visitListData![index]
                                                            .opportunityId
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: HexColor(
                                                              HexColor.black),
                                                          fontFamily:
                                                              'montserrat_medium',
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
                                                        margin: EdgeInsets.only(
                                                            top: 5),
                                                        child: Icon(
                                                          Icons
                                                              .production_quantity_limits_rounded,
                                                          size: 18,
                                                          color: HexColor(
                                                              HexColor
                                                                  .primary_s),
                                                        )),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5),
                                                      child: Text(
                                                        visitListData![index]
                                                                .productName ??
                                                            '',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: HexColor(
                                                              HexColor.black),
                                                          fontFamily:
                                                              'montserrat_medium',
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
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: SvgPicture.asset(
                                                        "images/ecological.svg",
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
                                                        visitListData![index]
                                                            .centerName!,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          height: 1,
                                                          color: HexColor(
                                                              HexColor.black),
                                                          fontFamily:
                                                              'montserrat_medium',
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
                                                        margin: EdgeInsets.only(
                                                            top: 5),
                                                        child: Icon(
                                                          Icons
                                                              .merge_type_rounded,
                                                          size: 18,
                                                          color: HexColor(
                                                              HexColor
                                                                  .primary_s),
                                                        )),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5, top: 5),
                                                      child: Text(
                                                        visitListData![index]
                                                            .opptyType
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          height: 1,
                                                          color: HexColor(
                                                              HexColor.black),
                                                          fontFamily:
                                                              'montserrat_medium',
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
                                                  Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: SvgPicture.asset(
                                                      "images/add_contact.svg",
                                                      height: 18,
                                                      width: 18,
                                                      fit: BoxFit.fill,
                                                      color: HexColor(
                                                          HexColor.primary_s),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, top: 5),
                                                    child: Text(
                                                      visitListData![index]
                                                          .contactNumber!,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 1,
                                                        color: HexColor(
                                                            HexColor.black),
                                                        fontFamily:
                                                            'montserrat_medium',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: SvgPicture.asset(
                                                      "images/contacts_person.svg",
                                                      height: 18,
                                                      width: 18,
                                                      fit: BoxFit.fill,
                                                      color: HexColor(
                                                          HexColor.primary_s),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, top: 5),
                                                    child: Text(
                                                      visitListData![index]
                                                          .custName!,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 1,
                                                        color: HexColor(
                                                            HexColor.black),
                                                        fontFamily:
                                                            'montserrat_medium',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: SvgPicture.asset(
                                                      "images/money.svg",
                                                      height: 18,
                                                      width: 18,
                                                      fit: BoxFit.fill,
                                                      color: HexColor(
                                                          HexColor.primary_s),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, top: 5),
                                                    child: Text(
                                                      visitListData![index]
                                                          .productValue
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 1,
                                                        color: HexColor(
                                                            HexColor.black),
                                                        fontFamily:
                                                            'montserrat_medium',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: SvgPicture.asset(
                                                      "images/noticeboard.svg",
                                                      height: 18,
                                                      width: 18,
                                                      fit: BoxFit.fill,
                                                      color: HexColor(
                                                          HexColor.primary_s),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, top: 5),
                                                    child: Text(
                                                      visitListData![index]
                                                          .forcast
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 1,
                                                        color: HexColor(
                                                            HexColor.black),
                                                        fontFamily:
                                                            'montserrat_medium',
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
                                                      margin: EdgeInsets.only(
                                                          top: 5),
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
                                                        visitListData![index]
                                                            .date!,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          height: 1,
                                                          color: HexColor(
                                                              HexColor.black),
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
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      width: 90,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    5)),
                                                        color: visitListData![
                                                                        index]
                                                                    .status ==
                                                                "Pending"
                                                            ? HexColor(HexColor
                                                                    .yello1)
                                                                .withOpacity(
                                                                    0.5)
                                                            : HexColor(HexColor
                                                                    .green_txt)
                                                                .withOpacity(
                                                                    0.5),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                      child: Text(
                                                        visitListData![index]
                                                            .status!,
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontSize: 12,
                                                          color: visitListData![
                                                                          index]
                                                                      .status ==
                                                                  "Pending"
                                                              ? HexColor(
                                                                  HexColor
                                                                      .yello1)
                                                              : Colors.green,
                                                          fontFamily:
                                                              'montserrat_regular',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (visitListData![index]
                                                          .adminComment !=
                                                      null &&
                                                  visitListData![index]
                                                          .adminComment !=
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
                                                      margin: EdgeInsets.only(
                                                          left: 5),
                                                      child: Text(
                                                        visitListData![index]
                                                                .adminComment ??
                                                            "",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          height: 1,
                                                          color: HexColor(
                                                              HexColor
                                                                  .red_color),
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
                        )
                      : InkWell(
                          onTap: () {
                            if (visitListData![index].status == "Pending" ||
                                visitListData![index].isEditable == "0") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      UpdateVisit(
                                          visitListData: visitListData![index]),
                                ),
                              ).then((value) => {
                                    setState(() {
                                      visitListData!.clear();
                                      visitOppt = false;
                                      getVisitListAPI('oppo');
                                    })
                                  });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                // Set border width
                                borderRadius: BorderRadius.all(Radius.circular(
                                    10.0)), // Set rounded corner radius
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1,
                                      color: Colors.grey,
                                      offset: Offset(0, 0))
                                ] //Make rounded corner of border
                                ),
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                                                      child: SvgPicture.asset(
                                                        "images/ic_visit.svg",
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
                                                          left: 5),
                                                      child: Text(
                                                        visitListData![index]
                                                            .centerName!,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: HexColor(
                                                              HexColor.black),
                                                          fontFamily:
                                                              'montserrat_medium',
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
                                                        "images/target.svg",
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
                                                          left: 5),
                                                      child: Text(
                                                        visitListData![index]
                                                                .purpose ??
                                                            '',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: HexColor(
                                                              HexColor.black),
                                                          fontFamily:
                                                              'montserrat_medium',
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
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: SvgPicture.asset(
                                                        "images/ecological.svg",
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
                                                        visitListData![index]
                                                            .cityName!,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          height: 1,
                                                          color: HexColor(
                                                              HexColor.black),
                                                          fontFamily:
                                                              'montserrat_medium',
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
                                                  Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: SvgPicture.asset(
                                                      "images/add_contact.svg",
                                                      height: 18,
                                                      width: 18,
                                                      fit: BoxFit.fill,
                                                      color: HexColor(
                                                          HexColor.primary_s),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, top: 5),
                                                    child: Text(
                                                      visitListData![index]
                                                          .contactNumber!,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 1,
                                                        color: HexColor(
                                                            HexColor.black),
                                                        fontFamily:
                                                            'montserrat_medium',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: SvgPicture.asset(
                                                      "images/contacts_person.svg",
                                                      height: 18,
                                                      width: 18,
                                                      fit: BoxFit.fill,
                                                      color: HexColor(
                                                          HexColor.primary_s),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, top: 5),
                                                    child: Text(
                                                      visitListData![index]
                                                          .custName!,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        height: 1,
                                                        color: HexColor(
                                                            HexColor.black),
                                                        fontFamily:
                                                            'montserrat_medium',
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
                                                      margin: EdgeInsets.only(
                                                          top: 5),
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
                                                        visitListData![index]
                                                            .date!,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          height: 1,
                                                          color: HexColor(
                                                              HexColor.black),
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
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      width: 90,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    5)),
                                                        color: visitListData![
                                                                        index]
                                                                    .status ==
                                                                "Pending"
                                                            ? HexColor(HexColor
                                                                    .yello1)
                                                                .withOpacity(
                                                                    0.5)
                                                            : HexColor(HexColor
                                                                    .green_txt)
                                                                .withOpacity(
                                                                    0.5),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                      child: Text(
                                                        visitListData![index]
                                                            .status!,
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontSize: 12,
                                                          color: visitListData![
                                                                          index]
                                                                      .status ==
                                                                  "Pending"
                                                              ? HexColor(
                                                                  HexColor
                                                                      .yello1)
                                                              : Colors.green,
                                                          fontFamily:
                                                              'montserrat_regular',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (visitListData![index]
                                                          .adminComment !=
                                                      null &&
                                                  visitListData![index]
                                                          .adminComment !=
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
                                                      margin: EdgeInsets.only(
                                                          left: 5),
                                                      child: Text(
                                                        visitListData![index]
                                                                .adminComment ??
                                                            "",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          height: 1,
                                                          color: HexColor(
                                                              HexColor
                                                                  .red_color),
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
          ),
        ],
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

  @override
  void initState() {
    getVisitListAPI('visit');
    super.initState();
  }

  //creat methode retune String capitliase
  // String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  getVisitListAPI(visitOpptType) async {
    LoginModel loginModel = await Commons.getuser_info();

    context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.viewVisit));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
      request.fields["$visitOpptType"] = visitOpptType;

      print("sarjeet ${Commons.viewVisit}");
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
        VisitListModel visitListModel =
            VisitListModel.fromJson(jsonDecode(response));

        // Commons.flushbar_Messege(context, visitListModel.message ?? "");

        if (visitListModel.status == 1) {
          setState(() {
            visitListData = visitListModel.data ?? <VisitListData>[];
            // print("sarjeetw ${visitListData[7].centerName} ");
          });
        } else {
          Commons.flushbar_Messege(context, visitListModel.message!);
        }
      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }
}
