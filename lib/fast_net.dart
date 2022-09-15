library fast_net;

import 'package:dio/dio.dart';
import 'package:fast_net/src/log.dart';
import 'package:fast_utils/fast_utils.dart';

import 'fast_net.dart';
import 'src/interceptor.dart';
import 'package:package_info_plus/package_info_plus.dart';

export 'src/http.dart';

void initHttpRequest({
  ApiInterceptorOnRequest? onRequest,
  bool? extraSaveJson,
  ShowToast? showToast,
  bool isPrintLog = false,
}) {
  if (onRequest != null) Config.onRequest = onRequest;
  if (extraSaveJson != null) ApiInterceptor.extraSaveJson = extraSaveJson;
  if (showToast != null) Config.showToast = showToast;
  Config.isDebugPrint = isPrintLog;
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
  BaseOptions? baseOptions,
  JsonDecodeCallback? parseJson,
  DioInit? dioInit,
) {
  if (baseOptions != null) Config.baseOptions = baseOptions;
  if (parseJson != null) Config.jsonDecodeCallback = parseJson;
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

  static BaseOptions baseOptions =
      BaseOptions(connectTimeout: 1000 * 60, receiveTimeout: 1000 * 60);

  /// 初始化 Dio
  static DioInit dioInit = (Dio dio, String baseUrl) {
    dio.interceptors.add(ApiInterceptor(baseUrl));
  };

  static Future<String> getAppVersion() async {
    if (version != null) return version!;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    return version!;
  }

  /// 配置[headers] 等
  static ApiInterceptorOnRequest onRequest = (options, String baseUrl) async {
    if (isVersion) {
      var version = await getAppVersion();
      options.headers.putIfAbsent(versionKey, () => "v$version");
    }

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

  static ShowToast showToast = (msg) {};

  static Function(Object object) showLoading = (object) {};

  static Function(Object object, {bool clear}) closeLoading =
      (object, {bool clear = false}) {};
}
