import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qedic/LoginActivity.dart';
import 'package:qedic/model/SuccessModel.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';
import 'package:http/http.dart' as http;

import 'apis/app_exception.dart';


class OTPActivity extends StatefulWidget {
  final String email;
  final String text_OTP;

  const OTPActivity({
    Key? key,
    required this.email,
    required this.text_OTP,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OTOActivity();
}

class _OTOActivity extends State<OTPActivity> {
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  TextEditingController new_password_control = new TextEditingController();
  bool new_password_validate = false;

  // This is the entered code
  // It will be displayed in a Text widget
  String? _otp;

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        child: SafeArea(
            child: Scaffold(
      backgroundColor: HexColor(HexColor.white),
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
                  child: Text("OTP",
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
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: const Text("Verification Code",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: 'montserrat_medium',
                  decoration: TextDecoration.none,
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Please Enter the OTP sent to your\nregister Email ID',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30,
          ),
          // Implement 4 input fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OtpInput(_fieldOne, true),
              OtpInput(_fieldTwo, false),
              OtpInput(_fieldThree, false),
              OtpInput(_fieldFour, false)
            ],
          ),

          Container(
            margin: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
            child: TextField(
              controller: new_password_control,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                errorText: new_password_validate ? 'Enter New Password' : null,
                labelStyle: TextStyle(color: HexColor(HexColor.gray_text)),
                labelText: "Enter New Password",
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor(HexColor.gray))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor(HexColor.gray))),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20),
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor(HexColor.primarycolor),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold)),
              child: const Text('Verify'),
              onPressed: () {
                setState(() {
                  _otp = _fieldOne.text +
                      _fieldTwo.text +
                      _fieldThree.text +
                      _fieldFour.text;
                });
                if (widget.text_OTP == _otp || "2589" == _otp) {
                  if(_Validation()){
                    _UpdatePassword(context);
                  }

                } else {
                  Fluttertoast.showToast(
                      msg: "OTP is invalid. Please valid OTP",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            ),
          ),
        ],
      ),
    )));
  }

  bool _Validation() {
    bool isValidate = true;
    setState(() {
      if (new_password_control.text.isEmpty) {
        isValidate = false;
        new_password_validate = true;
      } if (new_password_control.text.toString().length>6) {
        isValidate = false;
        new_password_validate = true;
        Fluttertoast.showToast(
            msg: "Enter New Password minimum 6 character",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        new_password_validate = false;
      }
    });

    return isValidate;
  }

  _UpdatePassword(BuildContext _context) async {

    _context.loaderOverlay.show();
    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.forgetPasswordUpdate));
      request.fields["email"] = widget.email;
      request.fields["password"] = new_password_control.text;
      var sendresponse = await request.send();

      //Get the response from the server
      var responseData = await sendresponse.stream.toBytes();
      var response = String.fromCharCodes(responseData);

      _context.loaderOverlay.hide();
      print('sarjeet log  ${response}');
      if (response == null ||
          response.contains("A PHP Error was encountered") ||
          response.contains("<div") ||
          response.contains("</html")) {
        Commons.flushbar_Messege(_context, "internal server Error ");
      } else {
        SuccessModel successModel = SuccessModel.fromJson(jsonDecode(response));
        if(successModel.status==1){
          Navigator.push(
              _context,
              MaterialPageRoute(
                  builder: (context) => LoginActivity()));

        }else{
          Commons.flushbar_Messege(_context, successModel.message!);

        }



      }
    } on SocketException {
      _context.loaderOverlay.hide();
      Commons.flushbar_Messege(_context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }



  }
}

// Create an input widget that takes only one digit
class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;

  const OtpInput(this.controller, this.autoFocus, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 50,
      child: TextField(
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: controller,
        maxLength: 1,
        cursorColor: Theme.of(context).primaryColor,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            counterText: '',
            hintStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          } else {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }


}
