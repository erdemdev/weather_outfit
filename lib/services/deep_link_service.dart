import 'dart:async';

import 'package:app_links/app_links.dart';

import 'log_service.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<Uri?> getInitialLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (e, st) {
      LogService.captureException(
        source: 'DeepLinkService.getInitialLink',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  void start(void Function(Uri uri) onLink) {
    _subscription?.cancel();
    _subscription = _appLinks.uriLinkStream.listen(
      onLink,
      onError: (Object e, StackTrace st) {
        LogService.captureException(
          source: 'DeepLinkService.uriLinkStream',
          error: e,
          stackTrace: st,
        );
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  static String? extractAction(Uri uri) {
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (uri.pathSegments.isEmpty) return null;
      if (uri.pathSegments.first == 'open' && uri.pathSegments.length > 1) {
        return uri.pathSegments[1];
      }
      return uri.pathSegments.first;
    }

    final parts = <String>[];
    if (uri.host.isNotEmpty) {
      parts.add(uri.host);
    }
    parts.addAll(uri.pathSegments.where((s) => s.isNotEmpty));

    if (parts.isEmpty) {
      return null;
    }

    if (parts.first == 'open' && parts.length > 1) {
      return parts[1];
    }

    return parts.first;
  }
}
