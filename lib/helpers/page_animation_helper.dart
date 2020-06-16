import 'package:flutter/material.dart';

class PageAnimation extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    final _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: _slideAnimation,
        child: child,
      ),
    );
  }
}

class PageAnimationTheme extends PageTransitionsTheme {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    final _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.5),
      end: Offset(0, 0),
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: _slideAnimation,
        child: child,
      ),
    );
  }
}
