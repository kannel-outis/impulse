import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:impulse/app/impulse_exception.dart';

class RequestHelper {
  const RequestHelper._();
  static Future<Either<AppException, Map<String, dynamic>>> get(Uri url) async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return Right(json.decode(response.body));
      }
      throw const AppException("something went wrong");
    } on AppException catch (e) {
      return Left(AppException(e.toString()));
    }
  }

  static Future<Either<AppException, Map<String, dynamic>>> post(
      Uri url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(url, body: json.encode(body));
      return Right(json.decode(response.body));
    } catch (e) {
      return Left(AppException(e.toString()));
    }
  }

  static Future<Either<AppException, List<Map<String, dynamic>>>> getList(
      Uri url) async {
    List<Map<String, dynamic>> results = [];
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        log(response.body);
        final decodedBody = response.body as List;
        for (final entity in decodedBody) {
          results.add(entity);
        }

        return Right(results);
      }
      throw const AppException("something went wrong");
    } on AppException catch (e) {
      return Left(AppException(e.toString()));
    }
  }

  // static Future<AppException?> postListBody(List<Map<String, dynamic>> list, Uri url)async{

  // }
}
