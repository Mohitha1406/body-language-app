import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'otp_verification_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Please enter a valid email');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (!_isLogin && name.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      if (_isLogin) {
        // Login
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          // Get name from profiles
          Map<String, dynamic>? profile = await supabase
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          if (profile == null) {
            final defaultName = email.contains('@') ? email.split('@').first : email;
            final defaultProfile = {
              'id': response.user!.id,
              'name': defaultName,
              'email': email,
              'phone': '',
            };
            try {
              await supabase.from('profiles').insert(defaultProfile);
            } catch (_) {
              // Handle insert exception gracefully
            }
            profile = defaultProfile;
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('user_name', profile['name'] ?? email);
          await prefs.setString('user_email', email);
          if (profile['phone'] != null) {
            await prefs.setString('user_phone', profile['phone'].toString());
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          }
        }
      } else {
        // Sign up
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', name);
          await prefs.setString('user_email', email);
          await prefs.setString('user_phone', phone);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => OtpVerificationScreen(
                        email: email,
                        name: name,
                        phone: phone,
                      )),
            );
          }
        }
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on PostgrestException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() => _error = msg.isNotEmpty ? msg : 'An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final dialogEmailController =
        TextEditingController(text: _emailController.text);
    bool isSending = false;
    String? dialogError;
    String? dialogSuccess;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Reset Password',
                  style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your email address and we will send you a password reset link.',
                    style: TextStyle(color: Color(0xFF475569), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dialogEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Color(0xFF0F172A)),
                    decoration: _inputDecoration(
                        'Enter your email', Icons.email_outlined),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 12),
                    Text(dialogError!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  if (dialogSuccess != null) ...[
                    const SizedBox(height: 12),
                    Text(dialogSuccess!,
                        style: const TextStyle(
                            color: Color(0xFF16A34A), fontSize: 12)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final email = dialogEmailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            setDialogState(() => dialogError =
                                'Please enter a valid email address');
                            return;
                          }
                          setDialogState(() {
                            isSending = true;
                            dialogError = null;
                            dialogSuccess = null;
                          });
                          try {
                            await supabase.auth.resetPasswordForEmail(
                              email,
                              redirectTo:
                                  'https://confidai-b469a.web.app/reset-password',
                            );
                            setDialogState(() {
                              isSending = false;
                              dialogSuccess =
                                  'Check your email for a password reset link';
                            });
                          } on AuthException catch (e) {
                            setDialogState(() {
                              isSending = false;
                              dialogError = e.message;
                            });
                          } catch (e) {
                            setDialogState(() {
                              isSending = false;
                              dialogError =
                                  'Failed to send reset link. Try again.';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Send Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A73E8), Color(0xFF00E5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.accessibility_new_rounded,
                      color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('Body Language AI',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
              const Center(
                child: Text('Analyze. Improve. Confidence.',
                    style: TextStyle(
                        color: Color(0xFF64748B), fontSize: 13)),
              ),
              const SizedBox(height: 40),

              // Toggle Login/Signup
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _isLogin = true;
                          _error = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLogin
                                ? const Color(0xFF1A73E8)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _isLogin
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _isLogin = false;
                          _error = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin
                                ? const Color(0xFF1A73E8)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Sign Up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: !_isLogin
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Name & Phone fields (only for signup)
              if (!_isLogin) ...[
                const Text('Full Name',
                    style: TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: _inputDecoration(
                      'Enter your full name', Icons.person_outline),
                ),
                const SizedBox(height: 16),
                const Text('Phone Number',
                    style: TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: _inputDecoration(
                      'Enter your phone number', Icons.phone_outlined),
                ),
                const SizedBox(height: 16),
              ],

              // Email field
              const Text('Email Address',
                  style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: _inputDecoration(
                    'Enter your email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),

              // Password field
              const Text('Password',
                  style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: Color(0xFF64748B)),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF1A73E8), width: 2),
                  ),
                ),
              ),
              if (_isLogin) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showForgotPasswordDialog,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF1A73E8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFDC2626), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Color(0xFFDC2626), fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _isLogin ? 'Login' : 'Create Account',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _isLogin
                      ? "Don't have an account? Tap Sign Up above"
                      : 'Already have an account? Tap Login above',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xFF1A73E8), width: 2),
      ),
    );
  }
}