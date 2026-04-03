import 'package:flutter/material.dart';

/// A utility to help GoRouter listen to providers or streams.
/// This allows the router to automatically redirect the user
/// when their authentication state changes.
class RouterListenable extends ChangeNotifier {
  RouterListenable({required this.changes}) {
    // Listen for changes and notify GoRouter.
    _subscription = changes.listen((_) {
      notifyListeners();
    });
  }

  final Stream<dynamic> changes;
  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
