import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/budget.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/styles/HeaderStyle.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Row(children: [
              Text(
                "Hello, " + FirebaseAuth.instance.currentUser!.displayName!,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(child: SizedBox.shrink()),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 200,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.logout),
                                title: Text("Logout"),
                                onTap: () {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RootPage()));
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.logout),
                                title: Text("Reset income and strategy"),
                                onTap: () {
                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({"setup_finished": false});
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RootPage()));
                                },
                              )
                            ],
                          ),
                        );
                      });
                },
                child: Icon(Icons.settings),
              ),
            ]),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(blurRadius: 10, color: Colors.grey)
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Column(
                    children: [
                      Text(
                        "₱" + "0.00",
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      Text("Current Savings"),
                    ],
                  ),
                ))
              ],
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: InkWell(
                    onTap: () {
                      Navigator.push(
                          (context),
                          MaterialPageRoute(
                              builder: (context) => BudgetPlan()));
                    },
                    child: Column(
                      children: [Icon(Icons.money), Text("Budget Plan")],
                    ),
                  )),
                  Expanded(
                      child: Column(
                    children: [Icon(Icons.help), Text("Collab Goal")],
                  ))
                ],
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Text("Transaction History"),
                Expanded(child: SizedBox.shrink()),
                TextButton(onPressed: () {}, child: Text("View All"))
              ],
            ),
            Expanded(
                child: Row(
              children: [
                Expanded(
                    child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(blurRadius: 10, color: Colors.grey)
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Column(
                    children: [],
                  ),
                ))
              ],
            ))
          ],
        ),
      )),
    );
  }
}
