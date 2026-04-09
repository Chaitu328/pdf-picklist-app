import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../main.dart';
import 'api_url.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseURL,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'authorization': "Bearer ${box.read("user_token")}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  // GET Raw Request (returns Response directly)
  Future<Response?> getRaw(String endpoint) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
            "Content-Type": "application/json",
          },
        ),
      );
      return response;
    } catch (e) {
      print("GET Raw error: $e");
      return null;
    }
  }

  // GET Request
  Future<T?> get<T>(
      String endpoint,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
            "Content-Type": "application/json",
          },
        ),
      );
      return fromJson(response.data);
    } catch (e) {
      print("GET error: $e");
      return null;
    }
  }

  Future<List<T>?> getList<T>(
      String endpoint,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
            "Content-Type": "application/json",
          },
        ),
      );
      final data = response.data;

      if (data is List) {
        return data.map((item) => fromJson(item)).toList();
      } else {
        throw Exception('Expected a list but got: ${data.runtimeType}');
      }
    } catch (e) {
      print("GET error: $e");
      return null;
    }
  }

  // POST Request
  Future<T?> post<T>(
      String endpoint,
      dynamic data,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return fromJson(response.data);
    } catch (e) {
      print("POST error: $e");
      return null;
    }
  }

  Future<Response?> postRaw(String endpoint, Map<String, dynamic> data) async {
    try {
      debugPrint("Bearer token : ${box.read("user_token")}");
      final response = await _dio.post(
        endpoint,
        data: jsonEncode(data),
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
            "Content-Type": "application/json",
          },
        ),
      );
      return response;
    } catch (e) {
      print("POST error: $e");
      return null;
    }
  }

  Future<Response?> postDynamic(
      String endPoint,
      List<Map<String, dynamic>> data,
      ) async {
    try {
      final response = await _dio.post(
        endPoint,
        data: jsonEncode(data),
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
            "Content-Type": "application/json",
          },
        ),
      );
      return response;
    } catch (e) {
      print("Error posting attendance: $e");
      return null;
    }
  }

  Future<Response?> postForm(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
            "Content-Type": "multipart/form-data",
          },
        ),
      );
      return response;
    } catch (e) {
      print("POST error: $e");
      return null;
    }
  }

  Future<Response?> putForm(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
            "Content-Type": "multipart/form-data",
          },
        ),
      );
      return response;
    } catch (e) {
      print("PUT Form error: $e");
      return null;
    }
  }

  // DELETE Request
  Future<bool> delete(String endpoint) async {
    try {
      await _dio.delete(endpoint);
      return true;
    } catch (e) {
      print("DELETE error: $e");
      return false;
    }
  }

  Future<Response?> patchApi(String endpoint) async {
    try {
      final response = await _dio.patch(
        endpoint,
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
          },
        ),
      );
      return response;
    } catch (e) {
      print("POST error: $e");
      return null;
    }
  }

  Future<Response?> putRaw(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
            "Content-Type": "application/json",
          },
        ),
      );
      return response;
    } catch (e,stackTrace) {
      print("Put error: $e \n StackTrace: $stackTrace");
      return null;
    }
  }

  // POST Request without authorization (for register, login, etc.)
  Future<Response?> postWithoutAuth(String endpoint, Map<String, dynamic> data) async {
    final dio = Dio(
      BaseOptions(
        //baseUrl: ApiConstants.baseURL,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );
    try {
      final response = await dio.post(
        endpoint,
        data: jsonEncode(data),
      );
      return response;
    } catch (e) {
      print("POST without auth error: $e");
      return null;
    }
  }

  Future<Response?> patchWithBody(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: jsonEncode(data),
        options: Options(
          headers: {
            'authorization': "Bearer ${box.read("user_token")}",
            "Content-Type": "application/json",
          },
        ),
      );
      return response;
    } catch (e) {
      print("PATCH error: $e");
      return null;
    }
  }

  Future deleteRaw(String s) async {}

}
