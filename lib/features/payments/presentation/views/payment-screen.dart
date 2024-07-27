import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String redirectLink;
  const PaymentScreen({super.key, required this.redirectLink});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setBackgroundColor(ColorManager.background)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => log("Start Loading: $url"),
        onPageFinished: (url) => log("Finished Loading: $url"),
        onUrlChange: (change) => log("Changed to new url: ${change.url}"),
      ))
      ..loadRequest(Uri.parse(widget.redirectLink));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
