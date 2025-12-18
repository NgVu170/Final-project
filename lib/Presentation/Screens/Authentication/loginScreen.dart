import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_using_para/Logic/Authentication/auth_cubit.dart';
import 'package:note_app_using_para/Presentation/Screens/Authentication/signupScreen.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state){
            if (state is AuthFailure){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state){
            if (state is AuthLoading){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //--- LOGO / ICON ---
                      Icon(
                        Icons.sticky_note_2,
                        size: 80,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 16,),
                      Text(
                          "Welcome Back!",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      //---EMAIL---
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2)
                          )
                        ),
                        validator: (value){
                          if (value == null || value.isEmpty){
                            return "Please enter your email";
                          }
                          if (!value.contains('@')) return "Invalid email";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16,),

                      //--- PASSWORD ---
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Please enter your Password";
                          if (value.length < 6) return "Password length must be more than 6 characters";
                          return null;
                        },
                      ),
                      //--- FORGOT PASSWORD ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: (){
                            _showForgotPasswordDialog(context);
                          },
                          child: const Text("Forgot password?"),
                        )
                      ),
                    //--- Login Button ---
                      ElevatedButton(
                        onPressed: (){
                          if (_formKey.currentState!.validate()){
                            context.read<AuthCubit>().logIn(
                              emailController.text.trim(),
                              passwordController.text.trim()
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 16,),

                      //---Signup link ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
                            },
                              child: Text(
                                  "Register now",
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                              )
                          ),
                        ],
                      )
                    ],
                  )
                )
              )
            );
          }
      )
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset passowrd"),
          content: SizedBox(
            width: 300,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Your email will be sent to reset your password."),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: resetEmailController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Missing your email";
                      if (!value.contains('@')) return "Unvalid email";
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<AuthCubit>().resetPassword(
                      resetEmailController.text.trim()
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Have send mail to reset password, Please check your inbox or spam"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text("Send email"),
            ),
          ],
        );
      },
    );
  }
}