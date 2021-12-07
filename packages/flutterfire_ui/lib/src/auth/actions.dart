import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

abstract class FlutterFireUIAction {
  static T? ofType<T extends FlutterFireUIAction>(BuildContext context) {
    final w =
        context.dependOnInheritedWidgetOfExactType<FlutterFireUIActions>();

    if (w == null) return null;

    for (final action in w.actions) {
      if (action is T) return action;
    }

    return null;
  }
}

class AuthStateChangeAction<T extends AuthState> extends FlutterFireUIAction {
  final void Function(BuildContext context, T state) callback;
  AuthStateChangeAction(this.callback);

  bool matches(AuthState state) => state is T;
  void invoke(BuildContext context, T state) => callback(context, state);
}

class SignedOutAction extends FlutterFireUIAction {
  final void Function(BuildContext context) callback;
  SignedOutAction(this.callback);
}

class FlutterFireUIActions extends InheritedWidget {
  final List<FlutterFireUIAction> actions;

  const FlutterFireUIActions({
    Key? key,
    required this.actions,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(FlutterFireUIActions oldWidget) {
    return oldWidget.actions != actions;
  }

  @override
  InheritedElement createElement() {
    return FlutterfireUIAuthActionsElement(this);
  }
}

class FlutterfireUIAuthActionsElement extends InheritedElement {
  FlutterfireUIAuthActionsElement(InheritedWidget widget) : super(widget);

  @override
  FlutterFireUIActions get widget => super.widget as FlutterFireUIActions;

  @override
  Widget build() {
    return AuthStateListener<AuthController>(
      listener: (oldState, newState, controller) {
        for (final action in widget.actions) {
          if (action is AuthStateChangeAction && action.matches(newState)) {
            action.invoke(this, newState);
          }
        }
      },
      child: super.build(),
    );
  }
}
