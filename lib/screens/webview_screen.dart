import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/zip_service.dart';
import '../theme/glass_theme.dart';

class WebViewScreen extends StatefulWidget {
  final MiniApp app;
  const WebViewScreen({super.key, required this.app});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _controller;
  bool _loading = true;
  String? _cssToInject;
  bool _readyToRender = false;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      _cssToInject = await rootBundle.loadString('assets/design_system.css');
    } catch (e) {
      debugPrint("Error loading CSS asset: $e");
    }
    if (mounted) {
      setState(() {
        _readyToRender = true;
      });
    }
  }

  /// Inject CSS via a safe, multi-pronged approach.
  Future<void> _injectEverything(InAppWebViewController controller) async {
    if (_cssToInject == null) return;

    // 1. Inject as a <style> tag directly
    await controller.injectCSSCode(source: _cssToInject!);

    // 2. Also run a JS script to ensure body/font defaults match the new design
    await controller.evaluateJavascript(source: """
      (function() {
        document.body.style.fontFamily = "'Sora', sans-serif";
        document.body.style.background = 'transparent'; 
        // Background is handled by CSS, but transparency helps if CSS is slow
      })();
    """);
  }

  @override
  Widget build(BuildContext context) {
    final entryFile = File(widget.app.entryPath);
    final entryUrl = WebUri('file://${entryFile.path}');

    return Scaffold(
      backgroundColor: GlassTheme.bgStart,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: _AppBar(title: widget.app.name),
      ),
      body: !_readyToRender
          ? const Center(
              child: CircularProgressIndicator(
              color: GlassTheme.accent,
              strokeWidth: 2,
            ))
          : Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: entryUrl),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    allowFileAccessFromFileURLs: true,
                    allowUniversalAccessFromFileURLs: true,
                    allowsInlineMediaPlayback: true,
                    mediaPlaybackRequiresUserGesture: false,
                    transparentBackground: true, // Allow scaffold background to show
                    supportZoom: false,
                    useHybridComposition: true,
                  ),
                  onWebViewCreated: (controller) {
                    _controller = controller;
                  },
                  onLoadStart: (controller, url) async {
                    await _injectEverything(controller);
                  },
                  onLoadStop: (controller, url) async {
                    await _injectEverything(controller);
                    setState(() => _loading = false);
                  },
                  onLoadError: (controller, url, code, message) {
                    setState(() => _loading = false);
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                ),
                if (_loading)
                  Container(
                    color: GlassTheme.bgStart,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: GlassTheme.accent,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final String title;
  const _AppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xB8FFFFFF),
        border: const Border(
          bottom: BorderSide(color: Color(0x0F000000), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: GlassTheme.textPrimary),
            ),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: GlassTheme.textPrimary,
                  letterSpacing: -0.01,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
