import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';

import 'ForgetPasswordActivity.dart';
import 'HomeActivty.dart';
import 'apis/app_exception.dart';
import 'model/LoginModel.dart';

class LoginActivity extends StatefulWidget {
  // Initially password is obscure
  @override
  State<LoginActivity> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  bool _obscureText = true;
  bool checkedValue = false;
  TextEditingController userid_Controller = TextEditingController();
  TextEditingController paswordController = new TextEditingController();
  TextEditingController forgot_txt_controler = new TextEditingController();
  bool userid_validate = false;
  bool forget_userid_validate = false;
  bool password_validate = false;
  bool password_myFocusNode = false;
  int randomNumber = new Random().nextInt(90) + 10;
  String deviceTokenToSendPushNotification = "";
  String fcmToken = "";

  // GlobalKey<FormBuilderState> dynamicFormKey = GlobalKey<FormBuilderState>();
  Key user_id_key = GlobalKey();
  Key password_key = GlobalKey();
  Key checkbox_key = GlobalKey();
  Key login_button_key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
        child: Scaffold(
          backgroundColor: HexColor(HexColor.white),
          body: ListView(children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(shape: BoxShape.rectangle),
                  child: SvgPicture.asset(
                    "images/loginbackground.svg",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    color: HexColor(HexColor.primary_s),
                  ),
                ),
                Container(
                  height: 150,
                  width: double.infinity,
                  child: Center(
                    child: Container(
                      child: Image(
                          height: 100,
                          width: 150,
                          color: HexColor(HexColor.white),
                          image: AssetImage('images/q_logo.png')),
                    ),
                  ),

                  // ,
                ),
                Container(
                  height: 180,
                  margin: EdgeInsets.only(left: 20, top: 15),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: HexColor(HexColor.black),
                      fontFamily: 'lato_bold',
                      decoration: TextDecoration.none,
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 5),
              child: Text(
                "Please Sign in to Continue",
                style: TextStyle(
                  fontSize: 18,
                  color: HexColor(HexColor.black),
                  fontFamily: 'lato_bold',
                  decoration: TextDecoration.none,
                ),
              ),
              alignment: Alignment.bottomLeft,
            ),
            Container(
              margin: EdgeInsets.only(left: 25, top: 20.0),
              child: Text(
                "User ID",
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor(HexColor.primarycolor),
                  fontFamily: 'lato_bold',
                  decoration: TextDecoration.none,
                ),
              ),
              alignment: Alignment.bottomLeft,
            ),
            Container(
              margin: const EdgeInsets.only(top: 3, left: 20, right: 20),
              child: TextField(
                key: user_id_key,
                controller: userid_Controller,
                style: TextStyle(color: HexColor(HexColor.primary_s)),
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_pin_outlined,
                      color: HexColor(HexColor.primary_s),
                    ),
                    errorText: userid_validate ? "Enter User ID" : null,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor(HexColor.gray_light))),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor(HexColor.gray_light))),
                    filled: true,
                    hintText: "Enter User ID",
                    fillColor: HexColor(HexColor.gray_light)),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 25, top: 20.0),
              child: Text(
                "Password",
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor(HexColor.primarycolor),
                  fontFamily: 'lato_bold',
                  decoration: TextDecoration.none,
                ),
              ),
              alignment: Alignment.bottomLeft,
            ),
            Container(
              margin: const EdgeInsets.only(top: 3.0, left: 20, right: 20),
              child: TextField(
                key: password_key,
                controller: paswordController,
                obscureText: _obscureText,
                obscuringCharacter: '●',
                style: TextStyle(
                  color: HexColor(HexColor.primary_s),
                ),
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.vpn_key_outlined,
                        color: HexColor(HexColor.primary_s)),
                    errorText: password_validate ? "Enter Password" : null,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor(HexColor.gray_light))),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: HexColor(HexColor.gray_light))),
                    filled: true,
                    hintText: "Enter Password",
                    fillColor: HexColor(HexColor.gray_light),
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: IconTheme(
                        data: IconThemeData(
                            color: HexColor(HexColor.primarycolor)),
                        child: Icon(_obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      // child: new Icon(_obscureText
                      //     ? Icons.visibility
                      //     : Icons.visibility_off
                      // ),
                    )),
              ),
            ),
            Stack(children: [
              CheckboxListTile(
                key: checkbox_key,
                checkColor: HexColor(HexColor.white),
                activeColor: HexColor(HexColor.primary_s),
                value: checkedValue,
                onChanged: (newValue) {
                  setState(() {
                    checkedValue = newValue!;
                  });
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ),
              Container(
                margin: const EdgeInsets.only(top: 5.0, left: 45.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      if (checkedValue) {
                        checkedValue = false;
                      } else {
                        checkedValue = true;
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: RichText(
                      text: TextSpan(
                          style: const TextStyle(fontSize: 14),
                          children: <TextSpan>[
                        TextSpan(
                            text: "I accept",
                            style: TextStyle(
                              color: Colors.black,
                            )),
                        TextSpan(
                            text: " Terms & Conditions",
                            style: TextStyle(
                                color: HexColor(HexColor.primary_s),
                                fontWeight: FontWeight.bold)),
                      ])),
                ),
              ),
            ]),
            Container(
              margin: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20),
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                key: login_button_key,
                style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor(HexColor.primary_s)),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HexColor(HexColor.white),
                    fontFamily: 'lato_bold',
                    decoration: TextDecoration.none,
                  ),
                ),
                onPressed: () {
                  if (kDebugMode) {
                    print("sarjeet click");
                  }

                  if (userid_Controller.text.isEmpty ||
                      paswordController.text.isEmpty) {
                    setState(() {
                      userid_Controller.text.isEmpty
                          ? userid_validate = true
                          : userid_validate = false;
                      paswordController.text.isEmpty
                          ? password_validate = true
                          : password_validate = false;
                    });
                  } else if (!checkedValue) {
                    Commons.flushbar_Messege(
                        context, "Please Accept Terms and Conditions");
                  } else {
                    loginAPI();
                  }
                },
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ForgetPasswordActivity();
                }));
              },
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Text("Forgot Password ?",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'montserrat_medium',
                        fontSize: 14,
                        color: HexColor(HexColor.primarycolor),
                        fontStyle: FontStyle.normal,
                        decoration: TextDecoration.none,
                      ))),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void initState() {
    // userid_Controller.text = "devtest@mailinator.com";
    // paswordController.text = "Vivek@123";
    getfcmtoken();
    super.initState();
  }

  getfcmtoken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      fcmToken = value!;
      // fcmTokenAPI(fcmToken);
      if (kDebugMode) {
        print("sarjeet fcm token $fcmToken");
      }
    });
  }

  loginAPI() async {
    context.loaderOverlay.show();
    if (fcmToken == "") {
      getfcmtoken();
    }

    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.loginapi));
      //add text fields
      request.fields["email"] = userid_Controller.text;
      request.fields["password"] = paswordController.text;
      request.fields["fcm_token "] = fcmToken;
      request.fields["device_type"] = Platform.isAndroid ? "Android" : "iOS";

      print("sarjeet ${Commons.loginapi}");
      print("sarjeet ${request.fields}");
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
        LoginModel loginModel = LoginModel.fromJson(jsonDecode(response));
        if (loginModel.status == 1) {
          Commons.saveuser_info(response);
          Commons.saveloginstatus(true);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeActivity();
          }));
        } else {
          Commons.flushbar_Messege(context, loginModel.message!);
        }
      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }
}
