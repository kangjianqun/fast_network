import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fast_utils/fast_utils.dart';
import 'package:flutter/material.dart';

import '../fast_net.dart';
import 'log.dart';

typedef ApiInterceptorOnRequest = Future<RequestOptions> Function(
    RequestOptions options, String baseUrl);

typedef RespDataJson = Function(RespData data, Map<String, dynamic> json);

typedef ProcessingExtend = Map<String, dynamic> Function(
    Map<String, dynamic>? json);

typedef ShowToast = Function(Object? msg);

///  API
class ApiInterceptor extends InterceptorsWrapper {
  ApiInterceptor(this.baseUrl);

  final String baseUrl;

  /// 是否在[Response]的extra保存原始json
  static bool extraSaveJson = true;

  @override
  onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.baseUrl = baseUrl;
    var o = await Config.onRequest(options, baseUrl);
    super.onRequest(o, handler);
  }

  @override
  onResponse(Response response, ResponseInterceptorHandler handler) async {
    bool dialog =
        BoolUtil.parse(response.requestOptions.extra[Config.keyShowDialog]);
    if (dialog) {
      bool allClear = BoolUtil.parse(
          response.requestOptions.extra[Config.keyDialogAllClear]);
      Config.closeLoading(response.requestOptions.uri.toString(),
          clear: allClear);
    }

    var disposeJson =
        BoolUtil.parse(response.requestOptions.extra[Config.keyParseJson]);
    response.extra.update(Config.keyParseJson, (v) => disposeJson,
        ifAbsent: () => disposeJson);
    if (disposeJson) {
      response.extra
          .update(Config.keyResult, (v) => true, ifAbsent: () => true);
      return handler.resolve(response);
    } else {
      Map<String, dynamic> jsonData = {};
      try {
        try {
          jsonData = response.data;
        } catch (e) {
          if (response.data?.runtimeType == String) {
            printLog("---response---> data: ${response.data}");
            int startIndex = (response.data as String).indexOf("{");
            int endIndex = (response.data as String).lastIndexOf("}");
            String data =
                (response.data as String).substring(startIndex, endIndex + 1);
            jsonData = json.decode(data);
            response.data = data;
          }
        }
      } catch (e) {
        jsonData["data"] = response.data;
        jsonData["code"] = response.statusCode;
        debugPrint(response.data);
      }
      RespData respData = RespData.fromJson(jsonData);

      response.data = respData.data;
      if (extraSaveJson) {
        response.extra.update(Config.keyJson, (v) => respData.json,
            ifAbsent: () => respData.json);
      }
      response.extra.update(Config.keyIsMore, (v) => respData.isMore,
          ifAbsent: () => respData.isMore);
      response.extra.update(Config.keyTotalPage, (v) => respData.totalPageNum,
          ifAbsent: () => respData.totalPageNum);
      response.extra.update(Config.keyHint, (v) => respData.hint,
          ifAbsent: () => respData.hint);
      response.extra.update(Config.keyResult, (v) => respData.result,
          ifAbsent: () => respData.result);
      response.extra.update(Config.keyExtendData, (v) => respData.getExtend(),
          ifAbsent: () => respData.getExtend());

      if (!respData.result) {
        response.statusCode = respData.code;
        printLog('---api-response--->error---->$respData');
        if (BoolUtil.parse(
                response.requestOptions.extra[Config.keyShowError]) &&
            respData.error.ne) {
          Config.showToast(respData.error);
        }

        ///需要登录
        // if (respData.login.ne && respData.login == "0") {
        //   throw const UnAuthorizedException();
        // }
      }

      if (BoolUtil.parse(response.requestOptions.extra[Config.keyShowHint]) &&
          respData.hint.ne) {
        Config.showToast(respData.error);
      }
      return handler.resolve(response);
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    Config.closeLoading("", clear: true);
    printLog(err.toString());
    printLog('---api-response--->error---->$err');
    super.onError(err, handler);
  }
}

class RespData {
  RespData({this.data});

  Map<String, dynamic>? json;
  dynamic data;
  int code = 0;
  String? login;
  bool isMore = false;
  int totalPageNum = 1;
  String? error;
  String? hint;

  /// 下一步路由路径
  String? next;

  /// 默认为空
  String? back;

  bool get result => codeSuccess == code;

  /// 处理扩展参数
  static ProcessingExtend? processingExtend;
  static RespDataJson? responseJson;

  ///成功code标识
  static int codeSuccess = 200;
  static String keyCode = "code";
  static String keyData = "data";
  static String keyLogin = "login";
  static String keyHint = "success";
  static String keyNext = "next";
  static String keyBack = "back";
  static String keyError = "error";
  static String keyHasMore = "hasmore";
  static String keyPageTotal = "page_total";

  Map<String, dynamic> getExtend() {
    var data = <String, dynamic>{};
    if (processingExtend != null) data = processingExtend!(json);
    return data;
  }

  @override
  String toString() {
    if (json == null) {
      return "";
    } else {
      return json.toString();
    }
  }

  RespData.fromJson(Map<String, dynamic> respJson) {
    json = respJson;
    code = respJson[keyCode];
    data = respJson[keyData];
    login = respJson[keyLogin];
    hint = respJson[keyHint];
    next = respJson[keyNext];
    back = respJson[keyBack];
    error = data != null && data is Map
        ? valueByType(data[keyError], String)
        : null;
    isMore = respJson[keyHasMore] ?? false;
    totalPageNum = respJson[keyPageTotal] ?? 1;

    if (data == null || data is String && (data as String).e) {
      data = <String, dynamic>{};
    }
    if (responseJson != null) responseJson!(this, respJson);
  }
}
