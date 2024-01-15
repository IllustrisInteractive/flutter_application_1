import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/register.dart';
import 'package:flutter_application_1/setup.dart';
import 'package:flutter_application_1/styles/HeaderStyle.dart';
import "package:flutter_application_1/home.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budgeteer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection("users").doc(user.uid);

        userRef.get().then((value) {
          Map data = value.data() as Map;
          if (data['setup_finished'] == true) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => SetupPage()));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(children: [
        Expanded(
          child: SizedBox.shrink(),
        ),
        Row(children: [
          Expanded(
            child: Text(
              "Budgeteer",
              style: Header1,
              textAlign: TextAlign.center,
            ),
          )
        ]),
        SizedBox(
          height: 64,
        ),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
        ),
        SizedBox(
          height: 16,
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password',
          ),
        ),
        SizedBox(
          height: 16,
        ),
        ElevatedButton(onPressed: () {}, child: Text("Login")),
        SizedBox(
          height: 16,
        ),
        TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterPage()));
            },
            child: Text(
              "Create Account",
              style: TextStyle(color: Colors.deepPurple),
            )),
        Expanded(
          child: SizedBox.shrink(),
        )
      ]),
    )));
  }
}
