// import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LearningScreen extends StatefulWidget {
  LearningScreen({required Key key}) : super(key: key);

  @override
  _LearningScreenState createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int _selectedIndex = 1;
  ReceivePort _port = ReceivePort();

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
    }
  }

  late InAppWebViewController webView;

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMAG Learning Centre'),
        backgroundColor: Colors.blue,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: Uri.parse('https://everestgauge.org/courses'),
            headers: {},
            method: 'POST'),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true, useOnDownloadStart: true),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          webView = controller;
        },
        onLoadStart: (InAppWebViewController controller, Uri? url) {},
        onLoadStop: (InAppWebViewController controller, Uri? url) {},
        onDownloadStart: (controller, url) async {
          if (await Permission.storage.request().isGranted) {
            print("onDownloadStart $url");
            final taskId = await FlutterDownloader.enqueue(
              url: 'https://everestgauge.org/' + url.path,
              savedDir: (await getExternalStorageDirectory())!.path,
              showNotification:
                  true, // show download progress in status bar (for Android)
              openFileFromNotification:
                  true, // click on notification to open downloaded file (for Android)
              saveInPublicStorage: true,
            );
          } else if (await Permission.storage.request().isPermanentlyDenied) {
            await openAppSettings();
          } else if (await Permission.storage.request().isDenied) {
            await openAppSettings();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_line_chart),
            label: 'Live Class',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
