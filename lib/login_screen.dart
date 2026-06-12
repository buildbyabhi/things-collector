import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'main.dart'; // To access themeNotifier

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';

  void _handleError(dynamic e) {
    setState(() {
      _errorMessage = e is FirebaseAuthException ? (e.message ?? 'Authentication failed') : 'An error occurred';
      _isLoading = false;
    });
  }

  Future<void> _signIn() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      await _authService.signInWithEmail(_emailController.text.trim(), _passwordController.text.trim());
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _signUp() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      await _authService.signUpWithEmail(_emailController.text.trim(), _passwordController.text.trim());
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Playful Pastel Background Blobs
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(isDark ? 0.2 : 0.15),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(isDark ? 0.2 : 0.15), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary.withOpacity(isDark ? 0.15 : 0.1),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.secondary.withOpacity(isDark ? 0.15 : 0.1), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),

          // Main Login Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF111827), letterSpacing: -1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access your vault',
                      style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 40),

                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(_errorMessage, style: TextStyle(color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 24),
                    ],

                    TextField(
                      controller: _emailController,
                      autofillHints: const [], // Disables browser autofill painting black boxes
                      cursorColor: Theme.of(context).colorScheme.primary,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Icon(Icons.email_rounded, color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [], // Disables browser autofill painting black boxes
                      cursorColor: Theme.of(context).colorScheme.primary,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Icon(Icons.lock_rounded, color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (_isLoading)
                      CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)
                    else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            elevation: 8,
                            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _signUp,
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), thickness: 1.5)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF), fontWeight: FontWeight.bold)),
                          ),
                          Expanded(child: Divider(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), thickness: 1.5)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: Icon(Icons.g_mobiledata_rounded, size: 36, color: isDark ? Colors.white : const Color(0xFF111827)),
                          label: const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF374151) : Colors.white,
                            foregroundColor: isDark ? Colors.white : const Color(0xFF111827),
                            side: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
          
          // Render the toggle ON TOP of everything else
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: IconButton(
                    icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? Colors.amber : const Color(0xFF6B7280)),
                    onPressed: () {
                      themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
