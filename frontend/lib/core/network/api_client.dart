import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient(String baseUrl)
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ));

  Future<Response<T>> get<T>(String path) => dio.get<T>(path);
  Future<Response<T>> post<T>(String path, {dynamic data}) => dio.post<T>(path, data: data);
  Future<Response<T>> put<T>(String path, {dynamic data}) => dio.put<T>(path, data: data);
  Future<Response<T>> patch<T>(String path, {dynamic data}) => dio.patch<T>(path, data: data);
  Future<Response<T>> delete<T>(String path) => dio.delete<T>(path);
}
