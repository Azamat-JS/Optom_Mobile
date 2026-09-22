import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/theme/app_motion.dart';

/// Shared page-transition builder so every route fades consistently instead
/// of each screen picking its own transition ad hoc — see the implementation
/// plan's animation section. Extend with more variants (slide-up for
/// modals, shared-axis for shell-tab switches) as those screens land.
CustomTransitionPage<T> fadeThroughPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.standard,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AppMotion.emphasized),
        child: child,
      );
    },
  );
}
