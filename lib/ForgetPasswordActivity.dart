 import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';
 import 'package:http/http.dart' as http;

import 'OTPActivity.dart';
import 'apis/app_exception.dart';
import 'model/SendOTPModel.dart';


class ForgetPasswordActivity extends StatefulWidget {
  // Initially password is obscure
  @override
  State<ForgetPasswordActivity> createState() => _ForgetPasswordActivityState();
}

class _ForgetPasswordActivityState extends State<ForgetPasswordActivity> {
  bool checkedValue = false;
  TextEditingController email_Controller = new TextEditingController();
  bool email_validate = false;

  String text_OTP = "";

  @override
  void initState() {
    // email_Controller.text = "arvind@mailinator.com";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
          child: SafeArea(
        child: Scaffold(
            backgroundColor: HexColor(HexColor.gray_activity_background),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: AppBar(
                title: Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Container(
                        child: Text("Forgot Password",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              color: HexColor(HexColor.white),
                              fontFamily: 'montserrat_medium',
                              decoration: TextDecoration.none,
                            )),
                      ),
                    )
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
            ),
            body: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin:
                        new EdgeInsets.only(top: 20.0, left: 20, right: 20),
                        child: Text(
                            "Enter your Email. We will send you an email  to reset your password.",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: 'montserrat_regular',
                              fontSize: 14,
                              color: HexColor(HexColor.gray_text),
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                            ))),

                    Container(
                      margin:
                          const EdgeInsets.only(top: 70.0, left: 20, right: 20),
                      child: TextField(
                        controller: email_Controller,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          errorText: email_validate
                              ? 'Enter Email'
                              : null,
                          labelStyle:
                              TextStyle(color: HexColor(HexColor.gray_text)),
                          labelText: "Enter Email",
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: HexColor(HexColor.gray))),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: HexColor(HexColor.gray))),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 50.0, left: 20.0, right: 20),
                      height: 50.0,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor(HexColor.primarycolor),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        child: const Text('Done'),
                        onPressed: () {
                          send_otp();


                        },
                      ),
                    ),
                  ]),
            )),
      )),
    );
  }

  send_otp() async {

    context.loaderOverlay.show();
    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.sendOtp));
      request.fields["email"] = email_Controller.text;
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
        SendOTPModel sendOTPModel = SendOTPModel.fromJson(jsonDecode(response));
        if(sendOTPModel.status==1){
          Commons.flushbar_Messege(context, sendOTPModel.message!);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OTPActivity(email:email_Controller.text,text_OTP:sendOTPModel.data!.otp??"")));

        }else{
          Commons.flushbar_Messege(context, sendOTPModel.message!);

        }



      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }



  }
}
