import 'package:campus_event_app/features/auth/presentation/widgets/app_button.dart';
import 'package:campus_event_app/features/auth/presentation/widgets/app_text_field.dart';
import 'package:campus_event_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await context.read<AuthProvider>().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (!success) {
        _errorMessage = context.read<AuthProvider>().errorMessage;
      }
    });
    // Navigation on success is handled by the route guard reacting to the
    // AuthProvider status change.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text(
                  "Log in account",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                SizedBox(height: 3,),

                Text(
                  "Enter your email to sign in for this app",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 25,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: SizedBox(
                    height: 40,
                    child: AppTextField(
                      controller: _emailController, 
                      hintText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';

                        final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value)) return 'Enter a valid email';

                        return null;
                      },
                    ),
                  ),
                  
                ),

                SizedBox(height: 15,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50,),
                  child: SizedBox(
                    height: 40,
                    child: AppTextField(
                      controller: _passwordController, 
                      obscureText: _obscurePassword,
                      hintText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        return null;
                      },
                    ),
                  ),
                ),

                SizedBox(height: 6,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Align(
                    alignment: Alignment.centerRight, 
                    child: GestureDetector(
                      onTap: () {
                        // Go to forgot screen
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20,),

                if (_errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: AppButton(
                      label: "Sign in",
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _signIn,
                    ),
                  ),
                ),

                SizedBox(height: 20,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dont have an account?",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF828282),
                      ),
                    ),

                    SizedBox(width: 3,),

                    GestureDetector(
                      onTap: () {
                        // Go to sign up screen
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 25,),
              
                ],
              ),
            ),
          ),
        )
      );
  }
}
