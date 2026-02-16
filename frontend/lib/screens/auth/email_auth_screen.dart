import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../layout/main_layout.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _signupStep = 1; // 1 = credentials, 2 = profile

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _leoIdController = TextEditingController();
  final _leoDistrictController = TextEditingController();
  final _clubNameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => _signupStep = 2);
    }
  }

  void _goBackToStep1() {
    setState(() => _signupStep = 1);
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (_isSignUp) {
          await ApiService.register(
            _usernameController.text,
            _emailController.text,
            _passwordController.text,
            _leoDistrictController.text,
            _clubNameController.text,
            leoId: _leoIdController.text.isEmpty ? null : _leoIdController.text,
            about: _aboutController.text.isEmpty ? null : _aboutController.text,
          );
        } else {
          final response = await ApiService.login(
            _emailController.text,
            _passwordController.text,
          );

          // Save authentication data to local storage
          await StorageService.saveAuthData(
            token: response['token'],
            userId: response['user']['id'],
            username: response['user']['username'],
            email: response['user']['email'],
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isSignUp ? "Account created!" : "Welcome back!"),
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainLayout()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isSignUp ? "Create Account" : "Sign In",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),

                Text(
                  _isSignUp
                      ? (_signupStep == 1
                            ? "Create your account"
                            : "Complete your profile")
                      : "Welcome back",
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isSignUp
                      ? (_signupStep == 1
                            ? "Step 1 of 2: Enter your credentials"
                            : "Step 2 of 2: Tell us about yourself")
                      : "Sign in to continue to LeoConnect",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 40),

                // Username (Sign Up Step 2 Only)
                if (_isSignUp && _signupStep == 2) ...[
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      hintText: "Your display name",
                      prefixIcon: Icon(PhosphorIcons.user()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your username';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Email (Step 1 or Login)
                if (!_isSignUp || _signupStep == 1) ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "your@email.com",
                      prefixIcon: Icon(PhosphorIcons.envelopeSimple()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your email';
                      if (!value.contains('@'))
                        return 'Please enter a valid email';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "••••••••",
                      prefixIcon: Icon(PhosphorIcons.lock()),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? PhosphorIcons.eye()
                              : PhosphorIcons.eyeSlash(),
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),

                  // Confirm Password (Step 1 only)
                  if (_isSignUp && _signupStep == 1) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        hintText: "••••••••",
                        prefixIcon: Icon(PhosphorIcons.lock()),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? PhosphorIcons.eye()
                                : PhosphorIcons.eyeSlash(),
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ],

                // Leo Fields (Sign Up Step 2 Only)
                if (_isSignUp && _signupStep == 2) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _leoIdController,
                    decoration: InputDecoration(
                      labelText: "Leo ID (Optional)",
                      hintText: "e.g. LEO-12345",
                      prefixIcon: Icon(PhosphorIcons.identificationCard()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _leoDistrictController,
                    decoration: InputDecoration(
                      labelText: "Leo District",
                      hintText: "Your Leo District",
                      prefixIcon: Icon(PhosphorIcons.mapPin()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your Leo District';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _clubNameController,
                    decoration: InputDecoration(
                      labelText: "Club Name",
                      hintText: "Your Leo Club Name",
                      prefixIcon: Icon(PhosphorIcons.users()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your club name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "About (Optional)",
                      hintText: "Tell us about yourself...",
                      prefixIcon: Icon(PhosphorIcons.notepad()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Navigation Buttons
                if (_isSignUp && _signupStep == 2)
                  // Step 2: Back + Sign Up buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _goBackToStep1,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Sign Up',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )
                else
                  // Step 1 or Login: Single button (Next or Sign In)
                  FilledButton(
                    onPressed: _isLoading
                        ? null
                        : (_isSignUp && _signupStep == 1
                              ? _goToNextStep
                              : _handleSubmit),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isSignUp ? "Create Account" : "Sign In",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                const SizedBox(height: 24),

                // Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp
                          ? "Already have an account?"
                          : "Don't have an account?",
                      style: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp ? "Sign In" : "Sign Up",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
