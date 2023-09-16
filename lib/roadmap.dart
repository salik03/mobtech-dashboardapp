import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewApp extends StatefulWidget {
  final String? roadmaplink;
  const WebViewApp({Key? key, this.roadmaplink}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..loadRequest(Uri.parse(widget.roadmaplink ?? 'https://roadmap.sh/'));
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Future<bool> goBack = controller.canGoBack();
        bool goback = await goBack;
        print(goBack);
        if (goback != true) {
          return true;
        } else {
          controller.goBack();
          return false;
        }
      },
      child: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
