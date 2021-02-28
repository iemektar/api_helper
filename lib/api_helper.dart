import 'package:custom_response/custom_response.dart' as ResponseHelper;
import 'package:dio/dio.dart';

import 'models/api_helper_path_item.dart';
import 'models/api_helper_request_type.dart';

class ApiHelper {
  final Uri baseUrl;
  final String token;
  List<ApiHelperPathItem> _paths;
  dynamic Function(Map<String, dynamic>) responseResolver;

  Dio dio;
  ApiHelper.setup(this.baseUrl, this.token, List<ApiHelperPathItem> paths,
      {dynamic Function(Map<String, dynamic>) responseResolverFunc,
      int timeout = 30000})
      : assert(baseUrl != null),
        assert(token != null && token.isNotEmpty),
        assert(paths != null && paths.isNotEmpty) {
    dio = Dio(
      BaseOptions(
        baseUrl: _getUriAsUrl(baseUrl),
        headers: {"Authorization": "Bearer $token"},
        connectTimeout: timeout,
        sendTimeout: timeout,
      ),
    );

    _paths = paths;
    responseResolver = responseResolverFunc;
  }

  Dio get dioInstance => dio;

  List<ApiHelperPathItem> get paths => _paths;

  String _getUriAsUrl(Uri uri) {
    var url = "${uri.scheme}://${uri.host}";
    if (uri.hasPort) url += ":${uri.port}";
    url += uri.path;
    return url;
  }

  Future<ResponseHelper.Response> _get(ApiHelperPathItem pathItem) async {
    var response =
        await dio.get(pathItem.path, queryParameters: pathItem.queryParameters);
    return _processResponse(response);
  }

  Future<ResponseHelper.Response> _post(ApiHelperPathItem pathItem) async {
    var response = await dio.post(pathItem.path,
        data: pathItem.data, queryParameters: pathItem.queryParameters);

    return _processResponse(response);
  }

  ResponseHelper.Response _processResponse(Response response) {
    if (response.statusCode != 200)
      return ResponseHelper.Response.error(
          "Status Code: ${response.statusCode}\n${response.statusMessage}");

    return ResponseHelper.Response.success(response.data);
  }

  ResponseHelper.Response _errorHandler(Exception e) {
    String error = "";

    if (e is! DioError) error = e.toString();

    switch ((e as DioError).type) {
      case DioErrorType.CANCEL:
        error = "Request to API server was cancelled";
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        error = "Connection timeout with API server";
        break;
      case DioErrorType.DEFAULT:
        error = "Connection to API server failed due to internet connection";
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        error = "Receive timeout in connection with API server";
        break;
      case DioErrorType.RESPONSE:
        error =
            "Received invalid status code: ${(e as DioError).response.statusCode}";
        break;
      case DioErrorType.SEND_TIMEOUT:
        error = "Send timeout in connection with API server";
        break;
    }

    return ResponseHelper.Response.error(error);
  }

  ApiHelperPathItem getPathItem(String pathKey) {
    var item = _paths.firstWhere((element) => element.key == pathKey);
    return item;
  }

  Future<dynamic> request(ApiHelperPathItem pathItem,
      {dynamic Function(Map<String, dynamic>) jsonResolver,
      bool useReolver = true}) async {
    try {
      ResponseHelper.Response response;
      if (pathItem.requestType == ApiHelperRequestType.get)
        response = await _get(pathItem);
      else
        response = await _post(pathItem);

      if (jsonResolver != null) return jsonResolver(response.value);
      if (useReolver && responseResolver != null)
        return responseResolver(response.value);

      return response;
    } catch (e) {
      return _errorHandler(e);
    }
  }
}
