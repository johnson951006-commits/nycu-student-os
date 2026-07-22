// ─────────────────────────────────────────────────────────────────────────────
// THROWAWAY SPIKE HARNESS — F-1 WebView cookie extraction (INFRA-011).
//
// This is NOT production code and NOT part of the app. It lives in docs/spikes/
// (outside app/lib) so it never ships and is never scanned as product code.
// DELETE the throwaway branch once the verdict + redirect-detection pattern are
// transcribed into ../F-1-webview-cookie.md.
//
// Purpose: let an operator OBSERVE, against the real NYCU Portal login, (1) the
// navigation sequence that ends in an authenticated page, and (2) whether the
// session cookie jar is extractable. It intentionally does NOT hardcode a
// redirect rule — the whole point of F-1 is to DISCOVER that rule by observation
// (backlog Blocking Condition: never invent the redirect-detection pattern).
//
// Run: see README.md (add webview_flutter + webview_cookie_manager + http on the
// throwaway branch; supply PORTAL_LOGIN_URL via --dart-define).
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Real Portal login URL — supplied at run time, never committed.
/// `--dart-define=PORTAL_LOGIN_URL=https://...`
const String portalLoginUrl = String.fromEnvironment('PORTAL_LOGIN_URL');

/// Local stub of POST /auth/portal-session that echoes the received jar.
const String handoffStubUrl = String.fromEnvironment(
  'HANDOFF_STUB_URL',
  defaultValue: 'http://localhost:8787/auth/portal-session',
);

void main() {
  runApp(const F1SpikeApp());
}

class F1SpikeApp extends StatelessWidget {
  const F1SpikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'F-1 spike',
      home: F1SpikeScreen(),
    );
  }
}

class F1SpikeScreen extends StatefulWidget {
  const F1SpikeScreen({super.key});

  @override
  State<F1SpikeScreen> createState() => _F1SpikeScreenState();
}

class _F1SpikeScreenState extends State<F1SpikeScreen> {
  late final WebViewController _controller;
  final WebviewCookieManager _cookies = WebviewCookieManager();
  final List<String> _log = <String>[];

  @override
  void initState() {
    super.initState();
    if (portalLoginUrl.isEmpty) {
      _append('FATAL: pass --dart-define=PORTAL_LOGIN_URL=<real Portal login>');
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // The full navigation trace. RECORD this — the authenticated-redirect
          // signal is somewhere in this sequence. Do NOT add a detection rule
          // here; identify it from the log and write it into the verdict doc.
          onNavigationRequest: (NavigationRequest r) {
            _append('NAV_REQUEST  ${r.url}');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) => _append('PAGE_STARTED $url'),
          onPageFinished: (String url) => _append('PAGE_FINISHED $url'),
          onUrlChange: (UrlChange c) => _append('URL_CHANGE   ${c.url}'),
          onWebResourceError: (WebResourceError e) =>
              _append('WEB_ERROR    ${e.errorCode} ${e.description}'),
        ),
      );
    if (portalLoginUrl.isNotEmpty) {
      _controller.loadRequest(Uri.parse(portalLoginUrl));
    }
  }

  /// JS-visible cookies only — session cookies are usually HttpOnly and will
  /// NOT appear here. Kept to contrast against the platform-store extraction.
  Future<void> _dumpVisibleCookies() async {
    final Object result =
        await _controller.runJavaScriptReturningResult('document.cookie');
    _append('DOC_COOKIE   $result');
  }

  /// The real test: read the platform cookie store (Android CookieManager /
  /// iOS WKHTTPCookieStore, via webview_cookie_manager) — this is where an
  /// HttpOnly session cookie lives. Records names/domains/flags, then hands the
  /// jar to the stub. Whether this returns the session cookie IS the F-1 finding.
  Future<void> _extractAndHandoff() async {
    final List<Cookie> jar = await _cookies.getCookies(portalLoginUrl);
    _append('JAR_SIZE     ${jar.length} cookie(s) from platform store');
    for (final Cookie c in jar) {
      _append('  COOKIE     ${c.name} domain=${c.domain} '
          'httpOnly=${c.httpOnly} secure=${c.secure} expires=${c.expires}');
    }

    final Map<String, Object?> body = <String, Object?>{
      'cookieJar': <String, Object?>{
        'cookies': jar
            .map((Cookie c) => <String, Object?>{
                  'name': c.name,
                  'value': c.value,
                  'domain': c.domain,
                  'path': c.path,
                })
            .toList(),
      },
      'deviceInfo': <String, Object?>{
        'platform': Theme.of(context).platform.name,
        'appVersion': 'spike',
      },
    };

    try {
      final http.Response res = await http.post(
        Uri.parse(handoffStubUrl),
        headers: <String, String>{'content-type': 'application/json'},
        body: jsonEncode(body),
      );
      _append('HANDOFF      ${res.statusCode} ${res.body}');
    } on Object catch (e) {
      _append('HANDOFF_ERR  $e');
    }
  }

  void _append(String line) {
    // ignore: avoid_print — spike logging is the deliverable here.
    print('[F1] $line');
    setState(() => _log.add(line));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F-1 spike (throwaway)'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Dump document.cookie',
            onPressed: _dumpVisibleCookies,
            icon: const Icon(Icons.cookie_outlined),
          ),
          IconButton(
            tooltip: 'Extract jar + handoff (do this AT the authenticated page)',
            onPressed: _extractAndHandoff,
            icon: const Icon(Icons.download_done),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 3, child: WebViewWidget(controller: _controller)),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _log.length,
              itemBuilder: (BuildContext _, int i) => Text(
                _log[i],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
