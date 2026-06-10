// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _nameCtrl        = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmCtrl     = TextEditingController();

  bool _showPassword        = false;
  bool _showConfirmPassword = false;
  bool _isLoading           = false;

  String _passwordStrength      = '';
  Color  _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Password strength ─────────────────────
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength      = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }
    bool hasUpper   = password.contains(RegExp(r'[A-Z]'));
    bool hasNumber  = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[\W]'));
    bool hasLength  = password.length >= 8;

    int strength = 0;
    if (hasUpper)   strength++;
    if (hasNumber)  strength++;
    if (hasSpecial) strength++;
    if (hasLength)  strength++;

    setState(() {
      if (strength <= 1) {
        _passwordStrength      = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength == 2) {
        _passwordStrength      = 'Fair';
        _passwordStrengthColor = Colors.orange;
      } else if (strength == 3) {
        _passwordStrength      = 'Good';
        _passwordStrengthColor = Colors.blue;
      } else {
        _passwordStrength      = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  // ── Validators ────────────────────────────
  String? _validateName(String? value) {
    if (value == null || value.isEmpty)
      return 'Full name is required';
    if (value.length < 8)
      return 'Name must be at least 8 characters';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value))
      return 'Name can only contain letters and spaces';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty)
      return 'Email is required';
    if (value.contains(' '))
      return 'Email cannot contain spaces';
    // Must have at least 4 characters before @
    final parts = value.split('@');
    if (parts.length != 2)
      return 'Enter a valid email address';
    if (parts[0].length < 4)
      return 'Email must have at least 4 characters before @';
    // Must have valid domain
    if (!parts[1].contains('.'))
      return 'Enter a valid email domain';
    // Basic email format check
    if (!RegExp(r'^[\w._-]+@[\w.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value))
      return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty)
      return 'Password is required';
    if (value.length < 8)
      return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]')))
      return 'Must have at least 1 uppercase letter';
    if (!value.contains(RegExp(r'[0-9]')))
      return 'Must have at least 1 number';
    if (!value.contains(RegExp(r'[\W]')))
      return 'Must have at least 1 special character';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty)
      return 'Please confirm your password';
    if (value != _passwordCtrl.text)
      return 'Passwords do not match';
    return null;
  }

  // ── Register ──────────────────────────────
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await AuthService.register(
        name:            _nameCtrl.text.trim(),
        email:           _emailCtrl.text.trim(),
        password:        _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        _showSnack('Account created! Please login.', Colors.green);
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showSnack(result['message'], Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Connection failed. Check internet.', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Logo ─────────────────────
                const Center(
                  child: Text('🔪',
                      style: TextStyle(fontSize: 50)),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text('Create Account',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: kRed)),
                ),
                const Center(
                  child: Text('Join Chiksy today!',
                      style: TextStyle(
                          fontSize: 13,
                          color: kMuted)),
                ),
                const SizedBox(height: 28),

                // ── Full Name ────────────────
                const Text('Full Name',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kMuted)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  validator: _validateName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Ram Bahadur Thapa',
                    prefixIcon: Icon(
                        Icons.person_outline,
                        color: kMuted),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Email ────────────────────
                const Text('Email Address',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kMuted)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'e.g. ram@gmail.com',
                    prefixIcon: Icon(
                        Icons.email_outlined,
                        color: kMuted),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Password ─────────────────
                const Text('Password',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kMuted)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: !_showPassword,
                  validator: _validatePassword,
                  onChanged: _checkPasswordStrength,
                  decoration: InputDecoration(
                    hintText: 'Min 8 chars, A-Z, 0-9, !@#',
                    prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: kMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: kMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _showPassword = !_showPassword),
                    ),
                  ),
                ),

                // Password strength bar
                if (_passwordStrength.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength == 'Weak'
                              ? 0.25
                              : _passwordStrength == 'Fair'
                                  ? 0.50
                                  : _passwordStrength == 'Good'
                                      ? 0.75
                                      : 1.0,
                          backgroundColor: kBorder,
                          color: _passwordStrengthColor,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_passwordStrength,
                          style: TextStyle(
                              fontSize: 11,
                              color: _passwordStrengthColor,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],

                // Password rules
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kRedLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _rule('At least 8 characters',
                          _passwordCtrl.text.length >= 8),
                      _rule('At least 1 uppercase (A-Z)',
                          _passwordCtrl.text
                              .contains(RegExp(r'[A-Z]'))),
                      _rule('At least 1 number (0-9)',
                          _passwordCtrl.text
                              .contains(RegExp(r'[0-9]'))),
                      _rule('At least 1 special char (!@#\$)',
                          _passwordCtrl.text
                              .contains(RegExp(r'[\W]'))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Confirm Password ─────────
                const Text('Confirm Password',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kMuted)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: !_showConfirmPassword,
                  validator: _validateConfirm,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: kMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: kMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _showConfirmPassword =
                              !_showConfirmPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign Up Button ───────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2))
                        : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Login link ───────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                          color: kMuted, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: kRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────
  Widget _rule(String text, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.circle_outlined,
          size: 14,
          color: passed ? Colors.green : kMuted,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
              fontSize: 11,
              color: passed ? Colors.green : kMuted),
        ),
      ],
    );
  }
}