import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class GoogleOAuthScreen extends StatefulWidget {
  const GoogleOAuthScreen({super.key, required this.authUrl});

  final String authUrl;

  @override
  State<GoogleOAuthScreen> createState() => _GoogleOAuthScreenState();
}

class _GoogleOAuthScreenState extends State<GoogleOAuthScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _tokenExtracted = false;

  static const _callbackPath = '/google/callback';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: _onPageFinished,
          onWebResourceError: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  Future<void> _onPageFinished(String url) async {
    setState(() => _isLoading = false);
    if (_tokenExtracted) return;
    if (!url.contains(_callbackPath)) return;

    try {
      final result = await _controller.runJavaScriptReturningResult(
        'document.body.innerText',
      );

      String jsonStr = result.toString();
      // runJavaScriptReturningResult returns JS strings JSON-encoded
      try {
        jsonStr = jsonDecode(jsonStr) as String;
      } catch (_) {}

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final token = data['access_token'] as String?;

      if (token != null && mounted) {
        _tokenExtracted = true;
        context.router.pop(token);
      }
    } catch (e) {
      debugPrint('Google OAuth token extraction failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          'Sign in with Google',
          style: context.theme.typography.sm.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(FIcons.x, color: colors.foreground),
          onPressed: () => context.router.pop(null),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
