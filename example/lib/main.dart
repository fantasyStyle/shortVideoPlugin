import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:short_video_plugin/short_video_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ShortVideoPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  getVideoRecoder(minTime, maxTime, type, {String path = ''}) async {
    var result = await ShortVideoPlugin.getVideoRecoder(minTime, maxTime, type,
        path: path);
    debugPrint('视频录制的结果$result');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () async {
                    await getVideoRecoder(3, 15, 1);
                  },
                  child: Container(
                    child: Text('短视频录制'),
                  )),
              SizedBox(height: 50),
              FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () async {
                    await getVideoRecoder(3, 15, 2);
                  },
                  child: Container(
                    child: Text('相册选择'),
                  )),
              SizedBox(height: 50),
              FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () async {
                    ImagePicker()
                        .getVideo(source: ImageSource.gallery)
                        .then((PickedFile file) async {
                      debugPrint('选择的视频路径为${file.path}');
                      if (file != null && mounted) {
                        var result =
                            await getVideoRecoder(3, 15, 3, path: file.path);

                        if (result != null &&
                            result['path'] != null &&
                            result['path'].toString().isNotEmpty) {}
                      }
                    });
                  },
                  child: Container(
                    child: Text('视频裁剪'),
                  )),
            ])),
      ),
    );
  }
}
