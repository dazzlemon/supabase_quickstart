import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_quickstart/utils/constants.dart';

class AuthState<T extends StatefulWidget> extends SupabaseAuthState<T> {
	void changeRoute(String newRoute) {
		if (mounted) {
			Navigator.of(context)
			         .pushNamedAndRemoveUntil(newRoute, (route) => false);
		}
	}

  @override
  void onUnauthenticated() => changeRoute('/login');

  @override
  void onAuthenticated(Session session) => changeRoute('/account');

  @override
  void onPasswordRecovery(Session session) {}

  @override
  void onErrorAuthenticating(String message) {
    context.showErrorSnackBar(message: message);
  }
}