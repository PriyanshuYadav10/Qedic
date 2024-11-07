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
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../visit/VisitListModel.dart';

class VisitSelect extends StatefulWidget {
  @override
  State<VisitSelect> createState() => _VisitSelectState();
}

class _VisitSelectState extends State<VisitSelect> {
  List<VisitListData> visitListDataTemp = <VisitListData>[];
  List<VisitListData> visitListData_orignel = <VisitListData>[];
  List<VisitListData> selected_visitListData = <VisitListData>[];

// i vave send a string in methode in need to filter data in visitListData_orignel array
  void filterSearchResults(String query) {

    if (query.isNotEmpty) {
      List<VisitListData> dummyListData = <VisitListData>[];
     for(VisitListData item in visitListData_orignel!) {
        print("sarjeet item  ${item.custName}");
        if (item.custName!.toLowerCase().contains(query.toLowerCase()) ||
            item.centerName!.toLowerCase().contains(query.toLowerCase()) ||
            item.cityName!.toLowerCase().contains(query.toLowerCase()) ||
            item.contactNumber!.toLowerCase().contains(query.toLowerCase()) ||
            item.email!.toLowerCase().contains(query.toLowerCase()) ||
            item.existingMachine!.toLowerCase().contains(query.toLowerCase()) ||
            item.usgAgeing!.toLowerCase().contains(query.toLowerCase()) ||
            item.quality!.toLowerCase().contains(query.toLowerCase()) ||
            item.productName!.toLowerCase().contains(query.toLowerCase()) ||
            item.opptyType!.toLowerCase().contains(query.toLowerCase()) ||
            item.expectedClosureDate!.toLowerCase().contains(query.toLowerCase()) ||
            item.remarkSupport!.toLowerCase().contains(query.toLowerCase()) ||
            item.supportRequired!.toLowerCase().contains(query.toLowerCase()) ||
            item.date!.toLowerCase().contains(query.toLowerCase()) ||
            item.status!.toLowerCase().contains(query.toLowerCase()) ||
            item.isEditable!.toLowerCase().contains(query.toLowerCase())) {

          dummyListData.add(item);

        }
      };
      setState(() {
        visitListDataTemp.clear();
        visitListDataTemp.addAll(dummyListData);
      });

    } else {
      setState(() {
        visitListDataTemp!.clear();
        visitListDataTemp!.addAll(visitListData_orignel!);
      });
    }
    print("sarjeet ${visitListDataTemp!.length}");
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        child: Scaffold(
      backgroundColor: HexColor(HexColor.white),
      appBar: Commons.Appbar_logo(false, context, "Visit"),
      body:
      Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                //searchbar
                Container(
                  margin: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20),
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,

                  child: TextFormField(
                    onChanged: (text) {
                      filterSearchResults(text) ;
                    },
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: HexColor(HexColor.gray),
                        fontFamily: 'montserrat_regular',
                        decoration: TextDecoration.none,
                      ),
                      suffixIcon: Icon(
                        Icons.search,
                        color: HexColor(HexColor.gray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: HexColor(HexColor.gray),
                          width: 2.0,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: HexColor(HexColor.gray),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                ),
                visitListDataTemp!.isEmpty ? dataNotFound() : visitListUI(),
              ],
            ),
          ),
          if (selected_visitListData.length > 0)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20),
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor(HexColor.primary_s)),
                  child: Text (
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: HexColor(HexColor.white),
                      fontFamily: 'lato_bold',
                      decoration: TextDecoration.none,
                    ),
                  ),
                  onPressed: () {
                    if (selected_visitListData.length > 0) {
                      Navigator.pop(context, selected_visitListData);
                    } else {
                      Commons.flushbar_Messege(context, "Please select visit");
                    }
                  },
                ),
              ),
            )
        ],
      ),
    ));
  }

  Widget visitListUI() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: visitListDataTemp!.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                if(!visitListDataTemp![index].isSelected!){
                  setState(() {
                    visitListDataTemp![index].isSelected =true;
                    selected_visitListData.add(visitListDataTemp![index]);
                  });

                }else{
                  setState(() {
                    visitListDataTemp![index].isSelected =false;
                    selected_visitListData.remove(visitListDataTemp![index]);
                  });
                }


              },
              child: Container(
                margin:  EdgeInsets.only(left: 15, right: 15,top: 5,bottom: index==visitListDataTemp!.length-1? 60:5),
                padding: const EdgeInsets.all(15),
                decoration:  BoxDecoration(
                    color: Colors.white,
                    // Set border width
                    border: visitListDataTemp![index].isSelected ?Border.all(
                      width: 2,
                      color: HexColor(HexColor.primarycolor), //                   <--- border width here
                    ):null,
                    borderRadius: BorderRadius.all(

                        Radius.circular(10.0)), // Set rounded corner radius
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 1,
                          color: visitListDataTemp![index].isSelected ? HexColor(HexColor.primarycolor): HexColor(HexColor.gray),
                          offset: Offset(0, 0))
                    ] //Make rounded corner of border
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 0,
                                        child: Container(
                                          child: SvgPicture.asset(
                                            "images/ic_visit.svg",
                                            height: 18,
                                            width: 18,
                                            fit: BoxFit.fill,
                                            color: HexColor(HexColor.primary_s),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text(
                                            visitListDataTemp![index]
                                                .productName!,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 0,
                                        child: Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: SvgPicture.asset(
                                            "images/ecological.svg",
                                            height: 18,
                                            width: 18,
                                            fit: BoxFit.fill,
                                            color: HexColor(HexColor.primary_s),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          margin:
                                              EdgeInsets.only(left: 5, top: 5),
                                          child: Text(
                                            visitListDataTemp![index].cityName!,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: SvgPicture.asset(
                                          "images/add_contact.svg",
                                          height: 18,
                                          width: 18,
                                          fit: BoxFit.fill,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: 5, top: 5),
                                        child: Text(
                                          visitListDataTemp![index].contactNumber!,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: SvgPicture.asset(
                                          "images/contacts_person.svg",
                                          height: 18,
                                          width: 18,
                                          fit: BoxFit.fill,
                                          color: HexColor(HexColor.primary_s),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: 5, top: 5),
                                        child: Text(
                                          visitListDataTemp![index].custName!,
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
                                      Expanded(
                                        flex: 0,
                                        child: Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: SvgPicture.asset(
                                            "images/calender.svg",
                                            height: 18,
                                            width: 18,
                                            fit: BoxFit.fill,
                                            color: HexColor(HexColor.primary_s),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          margin:
                                              EdgeInsets.only(left: 5, top: 5),
                                          child: Text(
                                            visitListDataTemp![index].date!,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 1,
                                              color: HexColor(HexColor.black),
                                              fontFamily: 'montserrat_regular',
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
                                            color: visitListDataTemp![index]
                                                        .status ==
                                                    "Pending"
                                                ? HexColor(HexColor.yello1)
                                                    .withOpacity(0.5)
                                                : HexColor(HexColor.green_txt)
                                                    .withOpacity(0.5),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          child: Text(
                                            visitListDataTemp![index].status!,
                                            style: TextStyle(
                                              decoration: TextDecoration.none,
                                              fontSize: 12,
                                              color: visitListDataTemp![index]
                                                          .status ==
                                                      "Pending"
                                                  ? HexColor(HexColor.yello1)
                                                  : Colors.green,
                                              fontFamily: 'montserrat_regular',
                                            ),
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
    getVisitListAPI();
    super.initState();
  }

  //creat methode retune String capitliase
  // String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  getVisitListAPI() async {
    LoginModel loginModel = await Commons.getuser_info();

    context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.viewVisit));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
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
        VisitListModel visitListModel =
            VisitListModel.fromJson(jsonDecode(response));

        // Commons.flushbar_Messege(context, visitListModel.message ?? "");

        if (visitListModel.status == 1) {
          setState(() {
            visitListData_orignel = visitListModel.data ?? <VisitListData>[];
            visitListDataTemp.addAll(visitListData_orignel);
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
