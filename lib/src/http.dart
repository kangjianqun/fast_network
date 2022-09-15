import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:fast_net/fast_net.dart';
import 'package:fast_utils/fast_utils.dart';

import 'log.dart';

typedef DioInit = void Function(Dio dio, String baseUrl);

enum RequestType { get, post }

typedef RequestSucceed = void Function(Response);
typedef RequestFailure = void Function(DioError);

class Http extends DioForNative {
  static Http? instance;

  factory Http(String baseUrl,
      {bool isInstance = true, BaseOptions? options, String? contentType}) {
    var o = options ?? Config.baseOptions;
    if (!isInstance) return Http._(o).._init(baseUrl);
    instance ??= Http._(o).._init(baseUrl);
    if (contentType.ne) instance!.options.contentType = contentType;
    return instance!;
  }

  Http._([BaseOptions? options]) : super(options);

  /// 初始化 加入app通用处理
  _init(String baseUrl) {
    if (Config.jsonDecodeCallback != null) {
      (transformer as DefaultTransformer).jsonDecodeCallback =
          Config.jsonDecodeCallback;
    }
    Config.dioInit(this, baseUrl);
  }
}

Future<void> requestHttp(
  RequestType type,
  Http dio,
  String url, {
  Map<String, dynamic>? p,
  bool isShowDialog = false,
  bool dialogAllClear = false,
  bool isShowError = true,
  bool isShowHint = true,
  bool disposeJson = false,
  bool? isFromData,
  Function? notLogin,
  required RequestSucceed succeed,
  RequestFailure? failure,
}) async {
  Response response;
  dio.options.extra.update(Config.keyShowDialog, (item) => isShowDialog,
      ifAbsent: () => isShowDialog);
  dio.options.extra.update(Config.keyDialogAllClear, (item) => dialogAllClear,
      ifAbsent: () => dialogAllClear);
  dio.options.extra.update(Config.keyShowError, (item) => isShowError,
      ifAbsent: () => isShowError);
  dio.options.extra.update(Config.keyShowHint, (item) => isShowHint,
      ifAbsent: () => isShowHint);
  dio.options.extra.update(Config.keyParseJson, (item) => disposeJson,
      ifAbsent: () => disposeJson);
  try {
    switch (type) {
      case RequestType.get:
        response = await dio.get(url, queryParameters: p);
        break;
      case RequestType.post:
        var data = isFromData ?? Config.postDataIsFromData
            ? (p != null ? FormData.fromMap(p) : null)
            : p;
        response = await dio.post(url, data: data);
        break;
    }
    succeed(response);
  } on DioError catch (e) {
//    LogUtil.printLog("UnAuthorizedException");
//     if (e.error is UnAuthorizedException) {
//       if (notLogin != null) notLogin();
//     } else {
    printLog("error");
    if (failure != null) failure(e);
    // }
  }
}
