import 'package:dio/dio.dart';

class DioClient {
  static Dio? _dio;

  static Dio getInstance() {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: 'http://192.168.0.111:3000',
        // baseUrl: 'http://10.0.2.2:3000', // emulador Android
        // baseUrl: 'http://localhost:3000', // web/iOS
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return _dio!;
  }
}
