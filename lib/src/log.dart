import 'package:flutter/material.dart';

import '../fast_network.dart';

const String _tag = "projectDebugLog";

printLog(Object msg) {
  var content = "$_tag: ";
  content += msg.toString();
  if (Config.isDebugPrint) {
    debugPrint(content);
  } else {
    print(content);
  }
}
