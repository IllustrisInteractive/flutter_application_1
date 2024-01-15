import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BudgetPlan extends StatefulWidget {
  const BudgetPlan({Key? key}) : super(key: key);

  @override
  _BudgetPlanState createState() => _BudgetPlanState();
}

class Expense {
  String name;
  double amount;
  int month;
  int day;
  int year;
  String type;
  Expense(this.name, this.amount, this.month, this.day, this.year, this.type);
}

class Savings {
  String name;
  double amount;
  int month;
  int day;
  int year;
  Savings(this.name, this.amount, this.month, this.day, this.year);
}

class _BudgetPlanState extends State<BudgetPlan>
    with SingleTickerProviderStateMixin {
  TextEditingController strategyController = TextEditingController();
  List<Expense> expenses = [];
  List<Savings> savings = [];
  bool ready = false;
  late TabController _tabController;
  num income = 0;
  num wantsBalance = 0;
  num needsBalance = 0;
  num savingsBalance = 0;

  @override
  void initState() {
    super.initState();
    strategyController.text = "60-30-10";
    _tabController = TabController(vsync: this, length: 2);
    getAllThisMonth();
  }

  void addExpense(String name, double amount, String type) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("expenses")
        .add({
      "name": name,
      "amount": amount,
      "month": DateTime.now().month,
      "day": DateTime.now().day,
      "year": DateTime.now().year,
      "type": type
    });

    setState(() {
      expenses.add(Expense(name, amount, DateTime.now().month,
          DateTime.now().day, DateTime.now().year, type));
      if (type == "wants") {
        wantsBalance -= amount;
      } else if (type == "needs") {
        needsBalance -= amount;
      }
    });
  }

  Future<void> getAllThisMonth() async {
    var availableBalance = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var expenses = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("expenses")
        .get();

    num wantsTotal = 0;
    num needsTotal = 0;
    num savingsTotal = 0;

    List<Expense> expenseList = [];
    expenses.docs.forEach((element) {
      var data = element.data() as Map;
      expenseList.add(Expense(data['name'], data['amount'], data['month'],
          data['day'], data['year'], data['type']));
      if (data['month'] == DateTime.now().month) {
        if (data['type'] == "wants") {
          wantsTotal += data['amount'];
        } else if (data['type'] == "needs") {
          needsTotal += data['amount'];
        }
      }
    });

    var savings = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("savings")
        .get();
    List<Savings> savingsList = [];
    savings.docs.forEach((element) {
      var data = element.data() as Map;
      savingsList.add(Savings(data['name'], data['amount'], data['month'],
          data['day'], data['year']));
      if (data['month'] == DateTime.now().month && data['type'] == "needs") {
        savingsTotal += data['amount'];
      }
    });

    setState(() {
      this.expenses = expenseList;
      this.savings = savingsList;
      ready = true;
      this.needsBalance = availableBalance['income'] *
              int.parse(strategyController.text.split("-")[1]) /
              100 -
          needsTotal;
      this.wantsBalance = availableBalance['income'] *
              int.parse(strategyController.text.split("-")[2]) /
              100 -
          wantsTotal;
      this.savingsBalance = savingsTotal;
    });
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
            Row(children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
              ),
              SizedBox(
                width: 16,
              ),
              Text(
                "Budget Plan",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            ]),
            SizedBox(
              height: 24,
            ),
            Text("Your current budget strategy"),
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Needs")
                ])),
                Expanded(
                    child: Column(children: [
                  Text(strategyController.text.split("-")[2] + "%",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Wants")
                ]))
              ],
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              "Balance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(blurRadius: 10, color: Colors.grey[300]!)
                  ],
                  color: Colors.white),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("₱‎" + (needsBalance).toString(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          "Needs",
                        ),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("₱‎" + wantsBalance.toString(),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          "Wants",
                        ),
                      ],
                    ))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            if (!ready)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else ...[
              TabBar(
                  labelPadding: EdgeInsets.all(16),
                  unselectedLabelStyle: TextStyle(fontSize: 16),
                  labelStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  padding: EdgeInsets.only(bottom: 16),
                  tabs: [Text("Expenses"), Text("Income")],
                  controller: _tabController),
              Expanded(
                  child: TabBarView(children: [
                ExpenseHistory(
                  expenses: expenses,
                  addExpense: addExpense,
                ),
                Text("Hello")
              ], controller: _tabController)),
            ]
          ],
        ),
      )),
    );
  }
}

class ExpenseHistory extends StatefulWidget {
  ExpenseHistory({Key? key, required this.expenses, required this.addExpense})
      : super(key: key);
  //add expenses as prop
  List<Expense> expenses = [];
  Function(String, double, String) addExpense;

  @override
  _ExpenseHistoryState createState() => _ExpenseHistoryState();
}

class _ExpenseHistoryState extends State<ExpenseHistory> {
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Expanded(
          child: widget.expenses.isEmpty
              ? Center(
                  child: Text("You have no expenses registered yet."),
                )
              : ListView(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  children: widget.expenses.map((e) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name),
                                Text(e.month.toString() +
                                    "/" +
                                    e.day.toString() +
                                    "/" +
                                    e.year.toString()),
                              ],
                            ),
                            Expanded(child: SizedBox.shrink()),
                            Text(
                              "- ₱‎" + e.amount.toString(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[800]),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList()),
        ),
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      widget.addExpense("Test", 100, "wants");
                    },
                    child: Text("Add Expense")))
          ],
        )
      ]),
    );
  }
}
