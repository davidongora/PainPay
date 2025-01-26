import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    // Configure platform-specific parameters
    final params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const {},
          )
        : const PlatformWebViewControllerCreationParams();

    // Initialize the WebView controller and make sure to set the user agent to a generic mobile one
    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..loadRequest(Uri.parse('{session_url}'));

    // Configure platform-specific settings
    final platformController = _controller.platform;

    // Handle permissions
    platformController.setOnPlatformPermissionRequest((request) {
      request.grant();
    });

    // Android-specific configuration
    if (platformController is AndroidWebViewController) {
      platformController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (params) async {
          return const GeolocationPermissionsResponse(
              allow: true, retain: true);
        },
        onHidePrompt: () {},
      );
      platformController.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
