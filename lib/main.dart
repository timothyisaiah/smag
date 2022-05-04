import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:smag/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide WebView;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMAG Learning Centre',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SMAG Learning Centre'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  ReceivePort _port = ReceivePort();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late InAppWebViewController webView;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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

  static final List<Widget> _pages = <Widget>[
    HomeScreen(),
    InAppWebView(
      initialUrlRequest: URLRequest(
          url: Uri.parse(
              'http://shopper.toweroflove.org/products/vendor/hkabesindira@gmail.com'),
          headers: {},
          method: 'GET'),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true, useOnDownloadStart: true),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        // webView = controller;
      },
      onLoadStart: (InAppWebViewController controller, Uri? url) {},
      onLoadStop: (InAppWebViewController controller, Uri? url) {},
      onDownloadStartRequest: (controller, url) async {
        if (await Permission.storage.request().isGranted) {
          print("onDownloadStart $url");
          final taskId = await FlutterDownloader.enqueue(
            url: 'https://www.toweroflove.org/' + url.toString(),
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
    WebView(
      key: UniqueKey(),
      initialUrl: 'https://everestgauge.com/grader',
      javascriptMode: JavascriptMode.unrestricted,
    ),
    WebView(
      key: UniqueKey(),
      initialUrl: 'http://smag.everestgauge.org/records',
      javascriptMode: JavascriptMode.unrestricted,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _urlStartup().then((value) {
            print('Async done');
          });
        },
        backgroundColor: Colors.blue,
        icon: Icon(Icons.card_giftcard),
        label: Text('Live Class'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Grader',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            label: 'Records',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      body: (_selectedIndex == 0)
          ? HomeScreen()
          : _pages[
              _selectedIndex], //This displays the webviews based on the selected index
    );
  }

  _urlStartup() async {
    String url = "https://www.everestgauge.org/courses";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      print('Could not launch $url');
    }
  }
}
