import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:image_picker/image_picker.dart';

import '../apis/app_exception.dart';
import '../model/LoginModel.dart';
import '../model/SuccessModel.dart';
import '../utility/Commons.dart';
import '../utility/HexColor.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

import 'model/ImageUploadModel.dart';

class UpdateProfile extends StatefulWidget {
  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController fname_Controller = TextEditingController();
  bool fname_validate = false;
  TextEditingController lname_Controller = TextEditingController();
  bool lname_validate = false;

  TextEditingController mname_Controller = TextEditingController();
  bool mname_validate = false;
  TextEditingController fathername_Controller = TextEditingController();
  bool fathername_validate = false;
  TextEditingController blood_group = TextEditingController();

  final List<String> blood_list = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];


  @override
  void initState() {
    _updateProfile();
    super.initState();
  }

  Widget _bloodgroupSelect(context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          FocusScope.of(context).requestFocus(FocusNode());
          Commons.commonBottomSheet('Select Blood Group', blood_list.map((e) => e).toList(), blood_group, context,(selectedData){
            setState(() {
              blood_group.text = selectedData;
              print(selectedData);
            });
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.only(
            left: 15, right: 15, bottom: 10, top: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: HexColor(HexColor.gray_text),
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              blood_group.text.isEmpty ? "Select Blood Group" : blood_group.text,
              style: TextStyle(
                fontSize: 14,
                color: HexColor(HexColor.black),
                fontFamily: 'montserrat_regular',
                decoration: TextDecoration.none,
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded,size: 30,color: HexColor(HexColor.gray_text),),
          ],
        ),
      ),
    );
  }

  LoginModel? loginModel;
  String picture = "";
  File? _imagefile;

  _updateProfile() async {
    loginModel = await Commons.getuser_info();
    setState(() {
      picture = loginModel!.data!.picture ?? "";
      fname_Controller.text = loginModel!.data!.firstName ?? "";
      lname_Controller.text = loginModel!.data!.lastName ?? "";
      mname_Controller.text = loginModel!.data!.motherName ?? "";
      fathername_Controller.text = loginModel!.data!.fatherName ?? "";
      blood_group.text = loginModel!.data!.bloodGroup ?? "";
    });
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
                        child: Text("Update Profile",
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
                    InkWell(
                      onTap: () {
                        camera_gallery_option(context);
                      },
                      child: Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(top: 15),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _imagefile == null
                              ? Image.network(picture).image
                              : FileImage(_imagefile!),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25, top: 20.0),
                      child: Text(
                        "Frist Name",
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
                      margin:
                          const EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: fname_Controller,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person_pin_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText:
                                fname_validate ? "Enter Frist Name" : null,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Frist Name",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25, top: 20.0),
                      child: Text(
                        "Last Name",
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
                      margin: EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: lname_Controller,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person_pin_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText:
                                lname_validate ? "Enter Last Name" : null,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Last Name",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25, top: 15.0),
                      child: Text(
                        "Mother's Name",
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
                      margin: EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: mname_Controller,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.supervised_user_circle_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText:
                                mname_validate ? "Enter Mother's Name" : null,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Mother's Name",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25, top: 15.0),
                      child: Text(
                        "Father's Name",
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
                      margin: EdgeInsets.only(top: 3, left: 20, right: 20),
                      child: TextField(
                        controller: fathername_Controller,
                        style: TextStyle(color: HexColor(HexColor.primary_s)),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.supervised_user_circle_outlined,
                              color: HexColor(HexColor.primary_s),
                            ),
                            errorText:
                                fname_validate ? "Enter Father's Name" : null,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HexColor(HexColor.gray_light))),
                            filled: true,
                            hintText: "Enter Father's Name",
                            fillColor: HexColor(HexColor.gray_light)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25, top: 15.0),
                      child: Text(
                        "Select Blood Group",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.primarycolor),
                          fontFamily: 'lato_bold',
                          decoration: TextDecoration.none,
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                    ),
                    _bloodgroupSelect(context),
                    Container(
                      margin: EdgeInsets.only(
                          top: 50.0, left: 20.0, bottom: 30, right: 20),
                      height: 50.0,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor(HexColor.primarycolor),
                            textStyle: TextStyle(fontWeight: FontWeight.bold)),
                        child: Text('Submit'),
                        onPressed: () {
                          if (validation(context)) {
                            UpdateProfile(context);
                          }
                        },
                      ),
                    ),
                  ]),
            )),
      )),
    );
  }

  bool validation(BuildContext context) {
    bool isvalide = true;
    if (fname_Controller.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Frist Name");
      isvalide = false;
      setState(() {
        fname_validate = true;
      });
    } else if (lname_Controller.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Last Name");
      isvalide = false;
      setState(() {
        lname_validate = true;
      });
    } else if (mname_Controller.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Mother's Name");
      isvalide = false;
      setState(() {
        mname_validate = true;
      });
    } else if (fathername_Controller.text.isEmpty) {
      Commons.flushbar_Messege(context, "Please Enter Father's Name");
      isvalide = false;
      setState(() {
        fathername_validate = true;
      });
    }
    return isvalide;
  }

  UpdateProfile(BuildContext context) async {
    LoginModel loginModel = await Commons.getuser_info();

    context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request =
          http.MultipartRequest("POST", Uri.parse(Commons.updateProfile));
      //add text fields
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";
      request.fields["first_name"] = fname_Controller.text;
      request.fields["last_name"] = lname_Controller.text;
      request.fields["mother_name"] = mname_Controller.text;
      request.fields["father_name"] = fathername_Controller.text;
      request.fields["blood_group"] = blood_group.text ?? "";
      request.fields["picture"] = picture ?? "";

      print("sarjeet ${Commons.updateProfile}");
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
        LoginModel loginModel = LoginModel.fromJson(jsonDecode(response));

        if (loginModel.status == 1) {
          Commons.saveuser_info(response);

          Commons.Fluttertoast_Messege(context, loginModel.message ?? "");
          Navigator.pop(context);
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
  camera_gallery_option(BuildContext _context) {
    showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: _context,
      pageBuilder: (context, anim1, anim2) {
        return Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(bottom: 0, left: 0, right: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: SizedBox.expand(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                            color: HexColor(HexColor.primary_s).withOpacity(0.2),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              getImage(ImageSource.camera, _context);
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                    color: HexColor(HexColor.primary_s)
                                        .withOpacity(0.4),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: HexColor(HexColor.primary_s),
                                    size: 24,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 15),
                                  child: Text(
                                    "Camera",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(HexColor.primary_s),
                                      fontFamily: 'lato_bold',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                            color: HexColor(HexColor.primary_s).withOpacity(0.2),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              getImage(ImageSource.gallery, _context);
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                    color: HexColor(HexColor.primary_s)
                                        .withOpacity(0.4),
                                  ),
                                  child: Icon(
                                    Icons.camera,
                                    color: HexColor(HexColor.primary_s),
                                    size: 24,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 15),
                                  child: Text(
                                    "Gallery",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: HexColor(HexColor.primary_s),
                                      fontFamily: 'lato_bold',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ])),
            ));
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position:
          Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }

  ImageUload(File imagefile, BuildContext _context) async {
    _context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request =
          http.MultipartRequest("POST", Uri.parse(Commons.uploadImage));
      var stream =
          new http.ByteStream(DelegatingStream.typed(imagefile.openRead()));
      //add text fields
      var length = await imagefile.length();
      var multipartFile = http.MultipartFile("image", stream, length,
          filename: basename(imagefile.path));

      request.files.add(multipartFile);

      //add headers
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
        ImageUploadModel imageUploadModel =
            ImageUploadModel.fromJson(jsonDecode(response));

        if (imageUploadModel.status == 1) {
          setState(() {
            _imagefile = imagefile;

          });
          picture = imageUploadModel.data! ?? "";
        } else {
          Commons.flushbar_Messege(_context, imageUploadModel.message!);
        }
      }
    } on SocketException {
      _context.loaderOverlay.hide();
      Commons.flushbar_Messege(_context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }
  //get image form to gallery and camera
  Future getImage(ImageSource imageType,BuildContext _context) async {

    // final pickedFile = await picker.getImage(source: ImageSource.gallery);
    final pickedFile = await ImagePicker().pickImage(source: imageType);


      if (pickedFile != null) {

        final tempImage = File(pickedFile.path);
        final dir = await path_provider.getTemporaryDirectory();
        final targetPath =
            dir.absolute.path + "/11${tempImage.path.split("/").last}";
        // File file = createFile("${dir.absolute.path}/test.png");
        // file.writeAsBytesSync(data.buffer.asUint8List());
        File? image = await Imagecompresh(tempImage, targetPath);

        ImageUload(image!, _context);
      } else {
        print('No image selected.');
      }

  }

  Future<File?> Imagecompresh(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 20,
      rotate: 0,
    );

    print(file.lengthSync());
    print(result?.lengthSync());
    return result;
  }



}
