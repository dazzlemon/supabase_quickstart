import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_quickstart/components/auth_required_state.dart';
import 'package:supabase_quickstart/utils/constants.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends AuthRequiredState<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  bool _isLoading = false;

	void _loadingAnimation(Function f) {
		setState(() {
      _isLoading = true;
    });
		f();
		setState(() {
      _isLoading = false;
    });
	}

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile(String userId) async =>
    _loadingAnimation(() async {
			final response = await supabase
					.from('profiles')
					.select()
					.eq('id', userId)
					.single()
					.execute();
			final error = response.error;
			if (error != null && response.status != 406) {
				context.showErrorSnackBar(message: error.message);
			}
			final data = response.data;
			if (data != null) {
				_usernameController.text = (data['username'] ?? '') as String;
				_websiteController.text = (data['website'] ?? '') as String;
			}
		});

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async =>
    _loadingAnimation(() async {
			final userName = _usernameController.text;
			final website = _websiteController.text;
			final user = supabase.auth.currentUser;
			final updates = {
				'id': user!.id,
				'username': userName,
				'website': website,
				'updated_at': DateTime.now().toIso8601String(),
			};
			final response = await supabase.from('profiles').upsert(updates).execute();
			final error = response.error;
			if (error != null) {
				context.showErrorSnackBar(message: error.message);
			} else {
				context.showSnackBar(message: 'Successfully updated profile!');
			}
		});

  Future<void> _signOut() async {
    final response = await supabase.auth.signOut();
    final error = response.error;
    if (error != null) {
      context.showErrorSnackBar(message: error.message);
    }
  }

  @override
  void onAuthenticated(Session session) {
    final user = session.user;
    if (user != null) {
      _getProfile(user.id);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'User Name'),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Website'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
              onPressed: _updateProfile,
              child: Text(_isLoading ? 'Saving...' : 'Update')),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: _signOut, child: const Text('Sign Out')),
        ],
      ),
    );
  }
}