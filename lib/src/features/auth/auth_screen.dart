import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _loginOtp = TextEditingController();

  final _signupName = TextEditingController();
  final _signupEmail = TextEditingController();
  final _signupPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _loginOtp.dispose();
    _signupName.dispose();
    _signupEmail.dispose();
    _signupPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Welcome'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const <Tab>[
                Tab(text: 'Login'),
                Tab(text: 'Sign Up'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _LoginPane(
                loading: state.loading,
                otpRequested: state.otpRequested,
                emailController: _loginEmail,
                passwordController: _loginPassword,
                otpController: _loginOtp,
                onRequestOtp: () => state.requestLoginOtp(
                  _loginEmail.text.trim(),
                  _loginPassword.text,
                ),
                onVerifyOtp: () => state.verifyOtpAndLogin(_loginOtp.text.trim()),
                onGoogleLogin: state.loginUsingGoogle,
                statusMessage: state.statusMessage,
              ),
              _SignUpPane(
                loading: state.loading,
                nameController: _signupName,
                emailController: _signupEmail,
                passwordController: _signupPassword,
                onSignUp: () => state.register(
                  _signupName.text.trim(),
                  _signupEmail.text.trim(),
                  _signupPassword.text,
                ),
                statusMessage: state.statusMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoginPane extends StatelessWidget {
  const _LoginPane({
    required this.loading,
    required this.otpRequested,
    required this.emailController,
    required this.passwordController,
    required this.otpController,
    required this.onRequestOtp,
    required this.onVerifyOtp,
    required this.onGoogleLogin,
    required this.statusMessage,
  });

  final bool loading;
  final bool otpRequested;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController otpController;
  final VoidCallback onRequestOtp;
  final VoidCallback onVerifyOtp;
  final VoidCallback onGoogleLogin;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          'Login with password + OTP',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: loading ? null : onRequestOtp,
          child: const Text('Request OTP'),
        ),
        if (otpRequested) ...<Widget>[
          const SizedBox(height: 12),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter OTP'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: loading ? null : onVerifyOtp,
            child: const Text('Verify OTP & Login'),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: loading ? null : onGoogleLogin,
          icon: const Icon(Icons.account_circle_outlined),
          label: const Text('Login with Google'),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(statusMessage),
          ),
        ),
      ],
    );
  }
}

class _SignUpPane extends StatelessWidget {
  const _SignUpPane({
    required this.loading,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSignUp,
    required this.statusMessage,
  });

  final bool loading;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSignUp;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          'Create account',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: loading ? null : onSignUp,
          child: const Text('Sign Up'),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(statusMessage),
          ),
        ),
      ],
    );
  }
}
