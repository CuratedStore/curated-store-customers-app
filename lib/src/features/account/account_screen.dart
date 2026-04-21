import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../shared/brand_widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const BrandHeader(
              title: 'Customer Account',
              subtitle: 'Auth endpoints are wired to live API routes.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name (for register)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                ElevatedButton(
                  onPressed: state.loading
                      ? null
                      : () => state.login(
                            _emailController.text.trim(),
                            _passwordController.text,
                          ),
                  child: const Text('Login API'),
                ),
                OutlinedButton(
                  onPressed: state.loading
                      ? null
                      : () => state.register(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _passwordController.text,
                          ),
                  child: const Text('Register API'),
                ),
                OutlinedButton(
                  onPressed: state.loading ? null : state.bootstrap,
                  child: const Text('Refresh API Status'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(state.statusMessage),
              ),
            ),
          ],
        );
      },
    );
  }
}
