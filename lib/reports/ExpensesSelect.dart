import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';

import '../apis/app_exception.dart';
import '../expenses/ExpensesListModel.dart';
import '../model/LoginModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';

class ExpensesSelect extends StatefulWidget {
  String startdate;
  String enddate;
  String slected_id;

  ExpensesSelect({
    Key? key,
    required this.startdate,
    required this.enddate,
    required this.slected_id,
  }) : super(key: key);

  @override
  State<ExpensesSelect> createState() => _ExpensesState();
}

class _ExpensesState extends State<ExpensesSelect> {
  List<Data_Expenses> expenses_listTemp = <Data_Expenses>[];
  List<Data_Expenses> expenses_listoriginal = <Data_Expenses>[];
  List<Data_Expenses> expenses_listselected = <Data_Expenses>[];

  // i vave send a string in methode in need to filter data in visitListData_orignel array

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<Data_Expenses> dummyListData = <Data_Expenses>[];
      for (Data_Expenses item in expenses_listoriginal!) {
        if (item.visitName!.toLowerCase().contains(query.toLowerCase()) ||
            item.routeType!.toLowerCase().contains(query.toLowerCase()) ||
            item.travelPurpose!.toLowerCase().contains(query.toLowerCase()) ||
            item.fromLocation!.toLowerCase().contains(query.toLowerCase()) ||
            item.toLocation!.toLowerCase().contains(query.toLowerCase()) ||
            item.mileageKm!.toLowerCase().contains(query.toLowerCase()) ||
            item.mileageAllowance!
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item.hotelExp!.toLowerCase().contains(query.toLowerCase()) ||
            item.vechileFare!.toLowerCase().contains(query.toLowerCase()) ||
            item.status!.toLowerCase().contains(query.toLowerCase()) ||
            item.adminComment!.toLowerCase().contains(query.toLowerCase()) ||
            item.travelWithMd!.toLowerCase().contains(query.toLowerCase()) ||
            item.remark!.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      ;
      setState(() {
        expenses_listTemp.clear();
        expenses_listTemp.addAll(dummyListData);
      });
    } else {
      setState(() {
        expenses_listTemp!.clear();
        expenses_listTemp!.addAll(expenses_listoriginal!);
      });
    }
    print("sarjeet ${expenses_listTemp!.length}");
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        child: Scaffold(
      backgroundColor: HexColor(HexColor.white),
      appBar: Commons.Appbar_logo(true, context, "ExpensesSelect"),
      body:Column(
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //searchbar
                  Container(
                    margin: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20),
                    height: 50.0,
                    width: MediaQuery.of(context).size.width,
                    child: TextFormField(
                      onChanged: (text) {
                        filterSearchResults(text);
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
                  expenses_listTemp.isEmpty ? _dataNotFound() : Expenses_UI(),
                ],
              ),
            ),
          ),
          if (expenses_listselected.length > 0)
            Expanded(
              flex: 0,
              child: Container(
                margin: const EdgeInsets.only( left: 20.0, right: 20),
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
                    if (expenses_listselected.length > 0) {
                      Navigator.pop(context, expenses_listselected);
                    } else {
                      Commons.flushbar_Messege(context, "Please select Expenses");
                    }
                  },
                ),
              ),
            )
        ],
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
              physics: NeverScrollableScrollPhysics(),
              itemCount: expenses_listTemp.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    if(!expenses_listTemp![index].isSelected!){
                      setState(() {
                        expenses_listTemp![index].isSelected =true;
                        expenses_listselected.add(expenses_listTemp![index]);
                      });

                    }else{
                      setState(() {
                        expenses_listTemp![index].isSelected =false;
                        expenses_listselected.remove(expenses_listTemp![index]);
                      });
                    }
                  },
                  child: Container(
                    margin:
                         EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    padding:  EdgeInsets.all(15),
                    decoration:  BoxDecoration(
                        color: Colors.white,
                        // Set border width

                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0)),
                        border: Border.all(
                            width:expenses_listTemp![index].isSelected! ?3:1 ,
                            color: expenses_listTemp![index].isSelected!
                                ? HexColor(HexColor.primarycolor)
                                : HexColor(HexColor.gray))

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
                                              child: Image.asset(
                                                "images/target.png",
                                                height: 20,
                                                width: 20,
                                                color: HexColor(
                                                    HexColor.primarycolor),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                expenses_listTemp[index]
                                                        .travelPurpose ??
                                                    "",
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
                                                color: HexColor(
                                                    HexColor.primary_s),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                expenses_listTemp[index]
                                                        .routeType ??
                                                    "",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  height: 1,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,

                                        children: [
                                          Container(
                                            child: Image.asset(
                                              "images/commentary.png",
                                              height: 20,
                                              width: 20,
                                              color: HexColor(
                                                  HexColor.primarycolor),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                expenses_listTemp[index].remark ??
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
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,

                                        children: [
                                          SvgPicture.asset(
                                            "images/money.svg",
                                            height: 18,
                                            width: 18,
                                            fit: BoxFit.fill,
                                            color: HexColor(
                                                HexColor.primary_s),
                                          ),

                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                " ₹ ${expenses_listTemp[index].total_amount ??0}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 14,

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
                                                    expenses_listTemp[index]
                                                            .selectDate ??
                                                        ""),
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
                                                color: expenses_listTemp[index]
                                                            .status!
                                                            .toUpperCase() ==
                                                        "PENDING"
                                                    ? HexColor(HexColor.yello1)
                                                        .withOpacity(0.5)
                                                    : expenses_listTemp[index]
                                                                .status!
                                                                .toUpperCase() ==
                                                            "APPROVE"
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
                                                expenses_listTemp[index]
                                                    .status!
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 12,
                                                  color: expenses_listTemp[
                                                                  index]
                                                              .status!
                                                              .toUpperCase() ==
                                                          "PENDING"
                                                      ? HexColor(
                                                          HexColor.yello1)
                                                      : expenses_listTemp[index]
                                                                  .status!
                                                                  .toUpperCase() ==
                                                              "APPROVE"
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
                                      if (expenses_listTemp[index]
                                                  .adminComment !=
                                              null &&
                                          expenses_listTemp[index]
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
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                expenses_listTemp[index]
                                                        .adminComment ??
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
    getExpensess();
    super.initState();
  }

  getExpensess() async {
    LoginModel loginModel = await Commons.getuser_info();

    // context.loaderOverlay.show();
    try {
      var request =
          http.MultipartRequest("POST", Uri.parse(Commons.viewExpenses));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
      request.fields["start_date"] = widget.startdate ?? "";
      request.fields["end_date"] = widget.enddate ?? "";
      request.fields["status"] = "1";
      // request.fields["user_id"] = "5";

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
        ExpensesListModel expensesListModel =
            ExpensesListModel.fromJson(jsonDecode(response));

        if (expensesListModel.status == 1) {
          context.loaderOverlay.hide();

          setState(() {
            expenses_listoriginal = expensesListModel.data ?? <Data_Expenses>[];
            expenses_listTemp.addAll(expenses_listoriginal);
            var temp = widget.slected_id.split(",");
            for (int i = 0; i < temp.length; i++) {
              for (int j = 0; j < expenses_listTemp.length; j++) {
                if (temp[i] == expenses_listTemp[j].id.toString()) {
                  expenses_listTemp[j].isSelected = true;
                  expenses_listselected.add(expenses_listTemp[j]);
                }
              }
            }
          });
        } else {
          context.loaderOverlay.hide();

          Commons.flushbar_Messege(context, expensesListModel.message!);
        }
      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }
}
