import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:qedic/expenses/UpdateExpenses.dart';

import '../apis/app_exception.dart';
import '../model/LoginModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import 'AddExpenses.dart';
import 'ExpensesListModel.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Data_Expenses> expenses_list = <Data_Expenses>[];

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        child: Scaffold(
      backgroundColor: HexColor(HexColor.white),
      appBar: Commons.Appbar_logo(false, context, "Expenses"),
      body: expenses_list.isEmpty?_dataNotFound():Expenses_UI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AddExpenses(),
            ),
          ).then((value) {
            getExpensess();
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
              itemCount: expenses_list.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: (){
                    if(expenses_list[index].status!.toUpperCase() == "PENDING"||expenses_list[index].isEditable == "0"){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>UpdateExpenses(data_expenses: expenses_list![index],),
                        ),
                      ).then((value) => {getExpensess()});
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
                                              child: Image.asset("images/target.png",height: 20,width: 20,color: HexColor(HexColor.primarycolor),),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                expenses_list[index]
                                                        .travelPurpose ??
                                                    "",
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
                                                color:
                                                    HexColor(HexColor.primary_s),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                expenses_list[index].routeType ??
                                                    "",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,

                                        children: [
                                          Image.asset("images/commentary.png",height: 20,width: 20,color: HexColor(HexColor.primarycolor),),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                expenses_list[index].remark ??
                                                    "",
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
                                                " ₹ ${expenses_list[index].total_amount ??0}",
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
                                                    expenses_list[index]
                                                            .selectDate ??
                                                        ""),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  height: 1,
                                                  color: HexColor(HexColor.black),
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
                                                  const EdgeInsets.only(left: 5),
                                              width: 90,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(5)),
                                                color:expenses_list[index].status!.toUpperCase() == "PENDING"
                                                    ? HexColor(HexColor.yello1)
                                                        .withOpacity(0.5)
                                                    : expenses_list[index].status!.toUpperCase() == "APPROVE"
                                                        ? HexColor(HexColor
                                                                .green_txt)
                                                            .withOpacity(0.5)
                                                        : Colors.red
                                                            .withOpacity(0.5),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              child: Text(
                                                expenses_list[index].status!.toUpperCase() ,
                                                style: TextStyle(
                                                  decoration: TextDecoration.none,
                                                  fontSize: 12,
                                                  color: expenses_list[index].status!.toUpperCase() == "PENDING"
                                                      ? HexColor(HexColor.yello1)
                                                      : expenses_list[index].status!.toUpperCase() == "APPROVE"
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
                                      if (expenses_list[index].adminComment !=
                                              null &&
                                          expenses_list[index].adminComment !=
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
                                                expenses_list[index]
                                                        .adminComment ??
                                                    "",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  height: 1,
                                                  color: HexColor(HexColor.red_color),
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

    context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.viewExpenses));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
      // request.fields["user_id"] = "5";

      print("sarjeet ${Commons.viewExpenses}");
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
        ExpensesListModel expensesListModel =
            ExpensesListModel.fromJson(jsonDecode(response));

        if (expensesListModel.status == 1) {
          setState(() {
            expenses_list = expensesListModel.data ?? <Data_Expenses>[];
          });
        } else {
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
