import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/home.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(child: SizedBox.shrink()),
            const Text(
              "Welcome to Budgeteer!",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              "Thank you for choosing Budgeteer! We'll need some information about you to get started.",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 24,
            ),
            const Text(
                "Your data is protected by Google's Firebase platform and will be handled according to our privacy policy."),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context)
                    .push(_createRouteTransitionRtoL(IncomeSetup()));
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Let\'s begin!',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      )),
    );
  }
}

Route _createRouteTransitionRtoL(Widget pageToTransitionTo) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => pageToTransitionTo,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class IncomeSetup extends StatefulWidget {
  const IncomeSetup({Key? key}) : super(key: key);

  @override
  State<IncomeSetup> createState() => _IncomeSetupState();
}

class _IncomeSetupState extends State<IncomeSetup> {
  TextEditingController incomeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Step 1 of 3"),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "How much do you earn per month?",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  "We'll use this to calculate how much of your monthly income should be saved, used for necessities, and spent on leisure.",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 16,
                ),
                Text("This data is not shared with any other Budgeteer user."),
                SizedBox(
                  height: 24,
                ),
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  controller: incomeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Monthly Income",
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (incomeController.text.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update(
                                {"income": int.parse(incomeController.text)});
                        Navigator.of(context)
                            .push(_createRouteTransitionRtoL(ExpenseSetup()));
                      }
                    },
                    child: Text(
                      "Next",
                    ))
              ],
            )),
      ),
    );
  }
}

class ExpenseSetup extends StatefulWidget {
  const ExpenseSetup({Key? key}) : super(key: key);

  @override
  State<ExpenseSetup> createState() => _ExpenseSetupState();
}

class _ExpenseSetupState extends State<ExpenseSetup> {
  TextEditingController strategyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    strategyController.text = "60-30-10";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Step 2 of 3"),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "What budgeting strategy do you want to do?",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  "Ensure that your budgeting strategy covers enough for your living expenses. You can change this anytime later.",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 16,
                ),
                Text("This data is not shared with any other Budgeteer user."),
                SizedBox(
                  height: 24,
                ),
                SizedBox(
                  height: 8,
                ),
                DropdownMenu(
                  width: 360,
                  controller: strategyController,
                  onSelected: (value) => setState(() {
                    if (value != null) strategyController.text = value;
                  }),
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: "60-30-10", label: "60-30-10"),
                    DropdownMenuEntry(value: "50-30-20", label: "50-30-20"),
                    DropdownMenuEntry(value: "70-20-10", label: "70-20-10"),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Text("With this strategy, you are allocating: "),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        Text(strategyController.text.split("-")[0] + "%",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Savings")
                      ],
                    )),
                    Expanded(
                        child: Column(children: [
                      Text(strategyController.text.split("-")[1] + "%",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Needs")
                    ])),
                    Expanded(
                        child: Column(children: [
                      Text(strategyController.text.split("-")[2] + "%",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Wants")
                    ]))
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Previous")),
                    SizedBox(
                      width: 16,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (strategyController.text.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({"strategy": strategyController.text});
                            Navigator.of(context).push(
                                _createRouteTransitionRtoL(ExpenseSetup()));
                          }
                          Navigator.of(context)
                              .push(_createRouteTransitionRtoL(FinalSetup()));
                        },
                        child: Text(
                          "Next",
                        ))
                  ],
                )
              ],
            )),
      ),
    );
  }
}

class FinalSetup extends StatefulWidget {
  const FinalSetup({Key? key}) : super(key: key);

  @override
  State<FinalSetup> createState() => _FinalSetupState();
}

class _FinalSetupState extends State<FinalSetup> {
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Step 3 of 3"),
              SizedBox(
                height: 12,
              ),
              Text(
                "Budgeteer isn't just a budget tracker.",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 24,
              ),
              Text(
                "With Budgeteer, you can also plan your expenses ahead of time, and track your progress towards your savings goals. You can even set up a collaborative goal with other Budgeteer users!",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 24,
              ),
              Text("Ready to start using Budgeteer?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Wait, go back")),
                  SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({"setup_finished": true});
                        Navigator.of(context).pushAndRemoveUntil(
                            _createRouteTransitionRtoL(HomePage()),
                            (route) => false);
                      },
                      child: Text(
                        "Let's go!",
                      ))
                ],
              )
            ],
          )),
    ));
  }
}
