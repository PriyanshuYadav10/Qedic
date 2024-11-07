import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

// import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';

import '../apis/app_exception.dart';
import '../model/ImageUploadModel.dart';
import '../model/LoginModel.dart';
import '../model/SuccessModel.dart';
import 'AttendenceDataModel.dart';

class AttendanceAcitivity extends StatefulWidget {
  @override
  State<AttendanceAcitivity> createState() => _AttendanceAcitivity();
}

class _AttendanceAcitivity extends State<AttendanceAcitivity> {
  File? imagepath1;
  var currenttime = "";
  var currentdate = "";
  Position? position;
  Timer? timer;
  String latitude = "";
  String longitude = "";
  String address = "";
  String user_id = "";
  String last_attendance_status = "in";
  String punch_in_time = "--:--";
  String punch_out_time = "--:--";
  String working_hrs = "--:--";
  String punch_in_id = "";

  @override
  void initState() {
    getAttandance();
    getCurrentTime();
    locationGet();

    timer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => getCurrentTime());
    timer =
        Timer.periodic(const Duration(seconds: 30), (Timer t) => locationGet());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  getCurrentTime() {
    if (mounted) {
      setState(() {
        currenttime = Commons.time_format(DateTime.now().toString());
        currentdate = Commons.Date_format3(DateTime.now().toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
        child: Scaffold(
          backgroundColor: HexColor(HexColor.gray_activity_background),
          appBar: Commons.Appbar_logo(false, context, "Attendance"),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        currenttime,
                        style: TextStyle(
                          fontSize: 30,
                          color: HexColor(HexColor.black),
                          fontFamily: 'montserrat_medium',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      alignment: Alignment.center,
                      child: Text(
                        currentdate,
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor(HexColor.black),
                          fontFamily: 'montserrat_regular',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    if (last_attendance_status.toLowerCase() == "in")
                      Container(
                          height: 200,
                          width: 200,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 50),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                HexColor(HexColor.primarycolor),
                                HexColor(HexColor.primarycolor)
                              ]),
                              borderRadius: BorderRadius.circular(200)),
                          child: InkWell(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "images/press.png",
                                  color: HexColor(HexColor.white),
                                  width: 40,
                                  height: 40,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Punch In",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: HexColor(HexColor.white),
                                      fontFamily: 'montserrat_medium',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              if(punch_in_time == "--:--"){
                                pickImage("in", ImageSource.camera, context);
                              }
                              else{
                                Commons.flushbar_Messege(context, "You have already Attendace In");
                              }
                            },
                          )),
                    if (last_attendance_status.toLowerCase() == "out")
                      Container(
                          height: 200,
                          width: 200,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 50),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                HexColor(HexColor.primarycolor),
                                HexColor(HexColor.primarycolor)
                              ]),
                              borderRadius: BorderRadius.circular(200)),
                          child: InkWell(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "images/press.png",
                                  color: HexColor(HexColor.white),
                                  width: 40,
                                  height: 40,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Punch Out",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: HexColor(HexColor.white),
                                      fontFamily: 'montserrat_medium',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              pickImage("out", ImageSource.camera, context);
                            },
                          )),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 30, left: 20, right: 20),
                      alignment: Alignment.center,
                      child: Text(
                        "Location : $address",
                        style: TextStyle(
                          fontSize: 12,
                          color: HexColor(HexColor.gray_text),
                          fontFamily: 'montserrat_medium',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Image.asset(
                              "images/time_in.png",
                              color: HexColor(HexColor.black),
                              width: 20,
                              height: 20,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                punch_in_time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HexColor(HexColor.black),
                                  fontFamily: 'montserrat_bold',
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                "Punch In",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: HexColor(HexColor.gray_text),
                                  fontFamily: 'montserrat_medium',
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Image.asset(
                              "images/time_out.png",
                              color: HexColor(HexColor.black),
                              width: 20,
                              height: 20,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                punch_out_time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HexColor(HexColor.black),
                                  fontFamily: 'montserrat_bold',
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                "Punch Out",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: HexColor(HexColor.gray_text),
                                  fontFamily: 'montserrat_medium',
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      if (false)
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Image.asset(
                                "images/time_total.png",
                                color: HexColor(HexColor.black),
                                width: 20,
                                height: 20,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Text(
                                  "$working_hrs Hrs ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: HexColor(HexColor.black),
                                    fontFamily: 'montserrat_bold',
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                  "Working Hrs",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: HexColor(HexColor.gray_text),
                                    fontFamily: 'montserrat_medium',
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  pickImage(String attendanceType, ImageSource imageType,
      BuildContext _context) async {
    await Permission.camera.request().isGranted;
    try {
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath =
          "${dir.absolute.path}/11${tempImage.path.split("/").last}";

      // File file = createFile("${dir.absolute.path}/test.png");
      // file.writeAsBytesSync(data.buffer.asUint8List());
      File? image = await testCompressAndGetFile(tempImage, targetPath);
      setState(() {
        imagepath1 = image;
      });

      ImageUload(attendanceType, image!, _context);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  ImageUload(
    String type,
    File imagefile,
    BuildContext _context,
  ) async {
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
          filename: "image${DateTime.now().millisecondsSinceEpoch}.png");

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
            _Attendance(_context, imageUploadModel.data!, type);
          });
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

  Future<File?> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 40,
      rotate: 0,
    );

    if (kDebugMode) {
      print(file.lengthSync());
      print(result?.lengthSync());
    }

    return result;
  }

  locationGet() async {
    position = await _determinePosition();
    latitude = position?.latitude.toString() ?? "";
    longitude = position?.longitude.toString() ?? "";

    List<Placemark> placemarks = await placemarkFromCoordinates(
        position?.latitude ?? 0.0, position?.longitude ?? 0.0);
    Placemark place = placemarks[0];
    if (mounted) {
      setState(() {
        address =
            '${place.name}, ${place.subLocality}, ${place.locality} ${place.postalCode}';
      });
    }


  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  _Attendance(BuildContext _context, image, type) async {
    LoginModel loginModel = await Commons.getuser_info();

    _context.loaderOverlay.show();

    try {
      //create multipart request for POST or PATCH method
      var request =
          http.MultipartRequest("POST", Uri.parse(Commons.attendance));
      request.fields["user_id"] = "${loginModel.data!.id ?? ""}";


      if (last_attendance_status == "Out") {
        request.fields["id"] = punch_in_id;
        request.fields["punch_out_date"] = DateFormat('yyyy/MM/dd').format(DateTime.now());;
        request.fields["punch_out_time"] = DateFormat('hh:mm a').format(DateTime.now());
        request.fields["out_image"] = image;
        request.fields["out_latitude"] = "$latitude";
        request.fields["out_longitude"] = "$longitude";
      } else {
        request.fields["latitude"] = "$latitude";
        request.fields["longitude"] = "$longitude";
        request.fields["image"] = image;
        request.fields["punch_in_date"] =
            DateFormat('yyyy/MM/dd').format(DateTime.now());
        ;
        request.fields["punch_in_time"] =
            DateFormat('hh:mm a').format(DateTime.now());
      }

      print("sarjeet fields ${request.fields}");
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
        SuccessModel successModel = SuccessModel.fromJson(jsonDecode(response));

        if (successModel.status == 1) {
          Commons.Fluttertoast_Messege(_context, successModel.message ?? "");
          getAttandance();
        } else {
          Commons.flushbar_Messege(_context, successModel.message!);
        }
      }
    } on SocketException {
      _context.loaderOverlay.hide();
      Commons.flushbar_Messege(_context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
  }

  getAttandance() async {
    LoginModel loginModel = await Commons.getuser_info();

    context.loaderOverlay.show();
    String url = Commons.getattendance + "/${loginModel.data!.id ?? ""}";
    print("Request failed with status: ${url}");

    try {
      http.Response response = await http.get(Uri.parse(url));
      context.loaderOverlay.hide();
      if (response.statusCode == 200) {
        String responseData = response.body;
        print("sarjeet ${responseData}");

        AttendenceDataModel? attendenceDataModel =
            AttendenceDataModel.fromJson(jsonDecode(responseData));

        if (attendenceDataModel.status == 1) {
          setState(() {
            punch_in_time = attendenceDataModel!.data!.punchInTime ?? "--:--";
            punch_out_time = attendenceDataModel!.data!.punchOutTime ?? "--:--";
            punch_in_id = "${attendenceDataModel!.data!.id ?? ""}";
            if (attendenceDataModel!.data!.punchOutTime == null) {
              last_attendance_status = "Out";
            }else{
              last_attendance_status = "In";
            }
          });
        } else {
          // Commons.flushbar_Messege(context, attendenceDataModel.message!);
        }
      } else {
        // Request failed with an error status code
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      // An error occurred during the request
      print("Error: $e");
    }
  }
}
