import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/src/multipart_request.dart';

import '../model/ImageUploadModel.dart';


abstract class BaseService {
  Future<dynamic> getResponse(String url);

  Future<dynamic> PostApiResponse(
      BuildContext context, MultipartRequest request );

  Future<ImageUploadModel> PostApiResponseImage(
      BuildContext context, String url, data, filename, File imagepath1);
}
