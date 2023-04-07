library fast_network;

import 'package:dio/dio.dart';
import 'package:fast_utils/fast_utils.dart';

import 'fast_network.dart';
import 'src/log.dart';

export 'src/http.dart';
export 'src/interceptor.dart';

void initHttpRequest({
  ApiInterceptorOnRequest? onRequest,
  bool? extraSaveJson,
}) {
  if (onRequest != null) Config.onRequest = onRequest;
  if (extraSaveJson != null) ApiInterceptor.extraSaveJson = extraSaveJson;
}

void initRespData({
  ProcessingExtend? processingExtend,
  RespDataJson? respDataJson,
}) {
  if (processingExtend != null) RespData.processingExtend = processingExtend;
  if (respDataJson != null) RespData.responseJson = respDataJson;
}

/// [parseJson]必须是顶层函数
void initHttp(
  Http http, {
  RequestHeaders? requestHeaders,
  BaseOptions? baseOptions,
  JsonDecodeCallback? parseJson,
  DioInit? dioInit,
  bool isPrintLog = false,
  ShowToast? showToast,
}) {
  Config.http = http;
  Config.isDebugPrint = isPrintLog;
  if (baseOptions != null) Config.baseOptions = baseOptions;
  if (requestHeaders != null) Config.headers = requestHeaders;
  if (parseJson != null) Config.jsonDecodeCallback = parseJson;
  if (showToast != null) Config.showToast = showToast;
}

class Config {
  static String? version;
  static bool isDebugPrint = true;
  static bool isVersion = false;
  static String versionKey = "version";
  static String keyShowDialog = "key_show_dialog";
  static String keyDialogAllClear = "key_dialog_clear";
  static String keyShowError = "key_show_error";
  static String keyShowHint = "key_show_hint";
  static String keyParseJson = "key_parse_json";
  static String keyIsMore = "key_isMore";
  static String keyJson = "key_json";
  static String keyExtendData = "key_extendData";
  static String keyTotalPage = "key_totalPage";
  static String keyHint = "key_hint";
  static String keyResult = "key_result";
  static bool postDataIsFromData = true;
  static JsonDecodeCallback? jsonDecodeCallback;
  static late Http http;

  static BaseOptions baseOptions = BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  );

  /// 初始化 Dio
  static DioInit dioInit = (Dio dio, String baseUrl) {
    dio.interceptors.add(ApiInterceptor(baseUrl));
  };

  /// 配置[headers] 等
  static ApiInterceptorOnRequest onRequest = (options, String baseUrl) async {
    if (headers != null) headers!(options, baseUrl);

    if (BoolUtil.parse(options.extra[keyShowDialog])) {
//      printLog("showDialog");
      try {
        showLoading(options.uri.toString());
      } catch (e) {
        printLog(e);
      }
    }
    printLog(options.uri);
    return options;
  };

  static RequestHeaders? headers;

  static ShowToast showToast = (msg) {};

  static Function(Object object) showLoading = (object) {};

  static Function(Object object, {bool clear}) closeLoading =
      (object, {bool clear = false}) {};
}
