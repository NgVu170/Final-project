import 'package:flutter/material.dart' hide TextField;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Logic/Authentication/auth_cubit.dart';
import '../root_screen.dart';
import 'TextField.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: colorScheme.error),
          );
        } else if (state is Authenticated) {
          // FIX: When login is successful, navigate to the RootScreen
          // and clear the navigation stack.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => RootScreen(uid: state.user.uid)),
            (route) => false, // This removes all previous routes
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.edit_note_rounded, size: 80, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    "Welcome Back!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "Sign in to continue your notes",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    hintText: "Email Address",
                    icon: Icons.email_outlined,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscure: _isPasswordHidden,
                    onToggleVisibility: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                    validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().logIn(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Login", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.poppins(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}