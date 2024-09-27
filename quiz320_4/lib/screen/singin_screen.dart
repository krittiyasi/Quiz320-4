import 'package:flutter/material.dart';
import 'package:quiz320_4/main.dart';
import 'package:quiz320_4/screen/signup_screen.dart';
import 'package:quiz320_4/service/auth-sevice.dart'; // Import the signup screen

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          height: 280,
          width: 300,
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "TODO",
                style: TextStyle(fontSize: 40),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Password", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text("Sign up"),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await AuthService().signin(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                      if (res == 'success') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IncomeExpenseApp(),
                          ),
                        );
                      } else {
                        print(res);
                      }
                    },
                    child: const Text("Sign in"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
