import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';

import 'apis/app_exception.dart';
import 'model/LoginModel.dart';
import 'model/SuccessModel.dart';
import 'package:http/http.dart' as http;


class ChangePasswordActivity extends StatefulWidget {
  // Initially password is obscure
  @override
  State<ChangePasswordActivity> createState() => _ChangePasswordActivityState();
}

class _ChangePasswordActivityState extends State<ChangePasswordActivity> {
  bool _obscureText = true;
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  bool isvalide_old = false;
  bool isvalide_new = false;
  bool isvalide_confirm = false;

  TextEditingController oldpaswordController = new TextEditingController();
  TextEditingController newpaswordController = new TextEditingController();
  TextEditingController confirmpaswordController = new TextEditingController();

  validation() {
    if (oldpaswordController.text.isEmpty ||
        newpaswordController.text.isEmpty ||
        confirmpaswordController.text.isEmpty) {
      setState(() {
        oldpaswordController.text.isEmpty
            ? isvalide_old = true
            : isvalide_old = false;
        newpaswordController.text.isEmpty
            ? isvalide_new = true
            : isvalide_new = false;
        confirmpaswordController.text.isEmpty
            ? isvalide_confirm = true
            : isvalide_confirm = false;
      });
    } else if (newpaswordController.text != confirmpaswordController.text) {
      setState(() {
        isvalide_confirm = true;
      });
    } else {
      setState(() {
        isvalide_confirm = false;
        isvalide_new = false;
        isvalide_old = false;
      });
      ChangePassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SafeArea(
            child: Scaffold(
                appBar: Commons.Appbar_logo(true, context, "Change Password"),
                body: LoaderOverlay(
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 150,
                        width: double.infinity,
                        child: Center(
                          child: Container(
                            child:  Image(
                                height: 100,
                                width: 200,
                                color: HexColor(HexColor.primary_s),
                                image: AssetImage('images/q_logo.png')),
                          ),
                        ),

                        // ,
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 10.0, left: 20, right: 20),
                        child: TextField(
                          controller: oldpaswordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.vpn_key_outlined,
                                  color: HexColor(HexColor.primarycolor)),
                              errorText:
                                  isvalide_old ?'Enter Old Password' : null,
                              labelStyle: TextStyle(
                                  color: HexColor(HexColor.gray_text)),
                              labelText: "Old Password",
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HexColor(HexColor.gray))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HexColor(HexColor.gray))),
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
                      Container(
                        margin: const EdgeInsets.only(
                            top: 20.0, left: 20, right: 20),
                        child: TextField(
                          controller: newpaswordController,
                          obscureText: _obscureText1,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.vpn_key_outlined,
                                  color: HexColor(HexColor.primarycolor)),
                              errorText:
                                  isvalide_new ? 'Enter New Password' : null,
                              labelStyle: TextStyle(
                                  color: HexColor(HexColor.gray_text)),
                              labelText: "New Password",
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HexColor(HexColor.gray))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HexColor(HexColor.gray))),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _obscureText1 = !_obscureText1;
                                  });
                                },
                                child: IconTheme(
                                  data: IconThemeData(
                                      color: HexColor(HexColor.primarycolor)),
                                  child: Icon(_obscureText1
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
                      Container(
                        margin: const EdgeInsets.only(
                            top: 20.0, left: 20, right: 20),
                        child: TextField(
                          controller: confirmpaswordController,
                          obscureText: _obscureText2,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.vpn_key_outlined,
                                  color: HexColor(HexColor.primarycolor)),
                              errorText: isvalide_confirm
                                  ? 'Confirm Password Invalid'
                                  : null,
                              labelStyle: TextStyle(
                                  color: HexColor(HexColor.gray_text)),
                              labelText: "Confirm Password",
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HexColor(HexColor.gray))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HexColor(HexColor.gray))),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _obscureText2 = !_obscureText2;
                                  });
                                },
                                child: IconTheme(
                                  data: IconThemeData(
                                      color: HexColor(HexColor.primarycolor)),
                                  child: Icon(_obscureText2
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
                      Container(
                        margin: const EdgeInsets.only(
                            top: 50.0, left: 20.0, right: 20),
                        height: 50.0,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: HexColor(HexColor.primarycolor),
                              textStyle:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          child: Text('SUBMIT'),
                          onPressed: () {
                            validation();
                          },
                        ),
                      ),
                    ],
                  )),
                ))));
  }

  ChangePassword() async {
    LoginModel loginModel = await Commons.getuser_info();

    context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.updatePassword));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ??""}";
      request.fields["old_password"] = oldpaswordController.text;
      request.fields["new_password"] = newpaswordController.text;
      request.fields["conf_password"] = confirmpaswordController.text;


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
        SuccessModel successModel = SuccessModel.fromJson(jsonDecode(response));


        if(successModel.status=="1"){
          Commons.Fluttertoast_Messege(context, successModel.message ?? "");

          Navigator.pop(context, true);

        }else{
          Commons.flushbar_Messege(context, successModel.message!);

        }



      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }



  }
}
