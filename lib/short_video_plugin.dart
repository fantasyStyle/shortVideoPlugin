import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortVideoPlugin {
  static const MethodChannel _channel2 =
      const MethodChannel('short_video_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel2.invokeMethod('getPlatformVersion');
    return version;
  }

  static const MethodChannel _channel =
      const MethodChannel('gyb.cn/AliShortVideo');

  /// 视频录制
  ///
  /// @minDuration 最小时长sec
  /// @maxDuration 最大时长sec
  /// @path 裁剪视频的原始路径
  ///@recodertype 1录制 2相册导入 3视频裁剪
  static Future getVideoRecoder(
      int minDuration, int maxDuration, int recoderType,
      {String path = ''}) async {
    var result = await _channel.invokeMethod('getVideoRecoder', {
      "minDuration": minDuration,
      "maxDuration": maxDuration,
      "recoderType": recoderType,
      "path": path
    });
    // debugPrint('视频录制的结果$result');
    return result;
  }
}
