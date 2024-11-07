import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import '../apis/app_exception.dart';
import '../model/ImageUploadModel.dart';
import '../model/LoginModel.dart';
import '../utility/Commons.dart';
import 'BaseService.dart';

class NetworkService extends BaseService {
  @override
  Future getResponse(String url) async {
    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(url));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  static Future<LoginModel> LoginAPI(
      BuildContext context, String jsondata, String url) async {
    context.loaderOverlay.show();
    print('sarjeet log  ${url}');
    print('sarjeet log  ${jsondata}');
    final response = await http.post(Uri.parse(url), body: jsondata);
    print('sarjeet log  ${response.body}');
    print('statusCode on  ${response.statusCode}');
    if (response == null ||
        response.body.contains("A PHP Error was encountered") ||
        response.body.contains("<div") ||
        response.body.contains("</html")) {}

    if (response.statusCode == 200) {
      context.loaderOverlay.hide();
      return LoginModel.fromJson(jsonDecode(response.body));
    } else {
      context.loaderOverlay.hide();
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  @override
  // Future PostApiResponse(BuildContext context, MultipartRequest request ) async {
  //   print('sarjeet log  ${url}');
  //   print('sarjeet log  ${data}');
  //   context.loaderOverlay.show();
  //   dynamic responseJson;
  //   try {
  //     final response = await http
  //         .post(Uri.parse(url), body: data)
  //         .timeout(const Duration(seconds: 60));
  //     context.loaderOverlay.hide();
  //     print('sarjeet log  ${response.body}');
  //     if (response == null ||
  //         response.body.contains("A PHP Error was encountered") ||
  //         response.body.contains("<div") ||
  //         response.body.contains("</html")) {
  //       print('sarjeet log  internal${url}');
  //       print('sarjeet log internal ${data}');
  //       Commons.flushbar_Messege(context, "internal server Error ");
  //     } else {
  //       // dynamic responseJson = jsonDecode(response.body);
  //       // SuccessModel successModel = SuccessModel.fromJson(responseJson.body);
  //       // if (successModel.status == Commons.AUTHFAILURECODE) {
  //       //   Commons.Fluttertoast_Messege(context, successModel.message ?? "");
  //       //   Commons.saveuser_info("");
  //       //   Commons.saveloginstatus(false);
  //       //   Navigator.pushReplacement(context,
  //       //       MaterialPageRoute(builder: (context) => LoginActivity()));
  //       // }
  //       // else {
  //       responseJson = returnResponse(response);
  //       // }
  //     }
  //   } catch(e){
  //     print("sarjeet 1 ${e}");
  //
  //   }on SocketException {
  //     context.loaderOverlay.hide();
  //     Commons.flushbar_Messege(context, "No Internet Connection");
  //     throw FetchDataException('No Internet Connection');
  //   }
  //   return responseJson;
  // }

  @override
  Future<ImageUploadModel> PostApiResponseImage(
      BuildContext context, String url, data, filename, File imagepath1) async {
    print('sarjeet log  ${url}');
    print('sarjeet log  ${data}');

    context.loaderOverlay.show();
    dynamic responseJson;
    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(url));
      //add text fields
      request.fields["all_data"] = data;
      var stream =
          new http.ByteStream(DelegatingStream.typed(imagepath1.openRead()));

      var length = await imagepath1.length();
      var multipartFile = http.MultipartFile(filename, stream, length,
          filename: basename(imagepath1.path));

      request.files.add(multipartFile);

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
        print('sarjeet log  internal${url}');
        print('sarjeet log internal ${data}');

        Commons.flushbar_Messege(context, "internal server Error ");
      } else {
        responseJson = response;
        // }
      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }
    return ImageUploadModel.fromJson(jsonDecode(responseJson));
  }

  @visibleForTesting
  dynamic returnResponse(http.Response response) {
    print('statusCode on  ${response.statusCode}');
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);

        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while communication with server' +
                ' with status code : ${response.statusCode}');
    }
  }

  @override
  Future PostApiResponse(BuildContext context, http.MultipartRequest request) {
    // TODO: implement PostApiResponse
    throw UnimplementedError();
  }
}
