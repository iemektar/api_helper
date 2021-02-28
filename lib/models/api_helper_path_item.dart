import 'api_helper_request_type.dart';

class ApiHelperPathItem {
  final String key;
  final String path;
  Map<String, dynamic> _query;
  dynamic _data;
  ApiHelperRequestType _type;

  ApiHelperPathItem.get(this.key, this.path)
      : assert(key != null && key.isNotEmpty),
        assert(path != null && path.isNotEmpty),
        _type = ApiHelperRequestType.get,
        _query = {};

  ApiHelperPathItem.post(this.key, this.path)
      : assert(key != null && key.isNotEmpty),
        assert(path != null && path.isNotEmpty),
        _type = ApiHelperRequestType.post,
        _query = {};

  void addQueryParameter(String key, dynamic value) =>
      _query.addAll({key: value});

  void setQueryParamters(Map<String, dynamic> query) => _query = query;

  void setData(dynamic data) {
    assert(_type != ApiHelperRequestType.post,
        "This method usable for post items.");
    _data = data;
  }

  Map<String, dynamic> get queryParameters => _query;

  dynamic get data => _data;

  ApiHelperRequestType get requestType => _type;
}
