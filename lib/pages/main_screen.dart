import 'dart:math'; //used for the random number generator

import "package:flutter/material.dart";
import 'package:learn_flutter/pages/upload.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:web3dart/web3dart.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _supabase = Supabase.instance.client;

  String _mail = "";
  String _password = "";

  bool isLoading = false;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });
    try {
      final AuthResponse response =
          await _supabase.auth.signUp(email: _mail, password: _password);

      if (response.user == null) return;

      var rng = Random.secure();
      EthPrivateKey random = EthPrivateKey.createRandom(rng);
      Wallet wallet = Wallet.createNew(random, _password, rng);

      await _supabase.from("wallet").insert([
        {"user_id": response.user!.id, "wallet": wallet.toJson()}
      ]);

      // do something, for example: navigate('home');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Upload(
              user: response.user!,
              wallet: wallet,
            ),
          ),
          (context) => false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });
    try {
      final AuthResponse response = await _supabase.auth
          .signInWithPassword(email: _mail, password: _password);

      if (response.user == null) return;

      List<Map<String, dynamic>> data = await _supabase
          .from("wallet")
          .select("wallet")
          .eq("user_id", response.user!.id);

      Wallet wallet = Wallet.fromJson(data[0]["wallet"], _password);

      // do something, for example: navigate('home');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Upload(
              user: response.user!,
              wallet: wallet,
            ),
          ),
          (context) => false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Auth page"),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Column(children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (String value) {
                          _mail = value;
                        },
                      ),
                      PasswordField(
                        errorMessage:
                            'required at least 1 letter and number 5+ chars',
                        passwordConstraint:
                            r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{5,}$',
                        border: PasswordBorder(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                width: 2, color: Colors.red.shade200),
                          ),
                        ),
                        onChanged: (String value) {
                          _password = value;
                        },
                      ),
                      FloatingActionButton(
                        onPressed: _register,
                        child: Text("Register"),
                      ),
                      FloatingActionButton(
                        onPressed: _login,
                        child: Text("Login"),
                      )
                    ]),
              // : // Create a Email sign-in/sign-up form
              // SupaEmailAuth(
              //     redirectTo: "/",
              //     onSignInComplete: (response) {},
              //     onSignUpComplete: (response) {
              //       // do something, for example: navigate("wait_for_email");
              //       Navigator.pushAndRemoveUntil(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => Upload(user: response.user),
              //           ),
              //           (context) => false);
              //     },
              //     metadataFields: [
              //       MetaDataField(
              //         prefixIcon: const Icon(Icons.person),
              //         label: 'Username',
              //         key: 'username',
              //         validator: (val) {
              //           if (val == null || val.isEmpty) {
              //             return 'Please enter something';
              //           }
              //           return null;
              //         },
              //       ),
              //     ],
              //   ),
            )
          ],
        ));
  }
}
