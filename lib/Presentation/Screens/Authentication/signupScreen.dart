import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Logic/Authentication/auth_cubit.dart';

class SignUpScreen extends StatefulWidget{
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

 @override
  void dispose(){
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
 }

 @override
  Widget build(BuildContext context){
   final theme = Theme.of(context);

   return Scaffold(
     backgroundColor: theme.scaffoldBackgroundColor,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.primaryColor),
        onPressed: (){
          Navigator.pop(context);
        },
      )
    ),
     body: BlocConsumer<AuthCubit, AuthState>(
       listener: (context, state){
         if (state is AuthFailure){
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(state.message), backgroundColor: Colors.red,)
           );
         }
       },
       builder: (context, state){
         if (state is AuthLoading){
           return const Center(
             child: CircularProgressIndicator(),
           );
         }
         return SingleChildScrollView(
           padding: const EdgeInsets.all(24.0),
           child: Form(
             key: _formKey,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 Text(
                   "Signup",
                   style: theme.textTheme.headlineMedium?.copyWith(
                     color: theme.primaryColor,
                     fontWeight: FontWeight.bold,
                  )
                 ),
                 SizedBox(height: 16,),
                 // --- DISPLAY NAME ---
                 TextFormField(
                   controller: displayNameController,
                   decoration: InputDecoration(
                     hintText: "Display name",
                     prefixIcon: const Icon(Icons.person),
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                   validator: (v) => v!.isEmpty ? "How will we call you?" : null,
                 ),
                 SizedBox(height: 16,),
                 // --- Email ---
                 TextFormField(
                   controller: emailController,
                   decoration: InputDecoration(
                     hintText: "Your email",
                     prefixIcon: const Icon(Icons.mail),
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                   validator: (v) => v!.contains('@') ? "Unvalid email" : null,
                 ),
                 SizedBox(height: 16,),
                 // --- Password ---
                 TextFormField(
                   controller: passwordController,
                   decoration: InputDecoration(
                     hintText: "Password",
                     prefixIcon: const Icon(Icons.lock),
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                   validator: (v) => v!.length < 6 ? "Password must be more than 6 characters" : null,
                 ),
                 SizedBox(height: 16,),
                 // --- Confirm Password ---
                 TextFormField(
                   controller: confirmPasswordController,
                   decoration: InputDecoration(
                     hintText: "Confirm Password",
                     prefixIcon: const Icon(Icons.lock_reset),
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                   validator: (v) {
                     if (v != passwordController.text) return "Password must be same as Cnnfirm password";
                     return null;
                   },
                 ),
                 SizedBox(height: 24,),

                 ElevatedButton(
                   onPressed: (){
                     if (_formKey.currentState!.validate()){
                      context.read<AuthCubit>().signUp(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        displayNameController.text.trim()
                      );
                     }
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: theme.primaryColor,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                   ),
                   child: const Text("Signup now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 ),
                 TextButton(
                   onPressed: () => Navigator.pop(context),
                   child: const Text("Already have one? Login here"),
                 ),
               ]
             )
           ),
         );
       },
     ),
   );
 }
}