import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const LoanCalculatorApp());
}

class LoanCalculatorApp extends StatelessWidget {
  const LoanCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Calculator',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const LoanCalculatorScreen(),
    );
  }
}

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  _LoanCalculatorScreenState createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final TextEditingController loanController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();

  double emi = 0.0;
  double totalInterest = 0.0;
  double totalPayment = 0.0;

  void calculateLoan() {
    double principal = double.tryParse(loanController.text) ?? 0;
    double annualRate = double.tryParse(rateController.text) ?? 0;
    double tenure = double.tryParse(tenureController.text) ?? 0;

    double monthlyRate = annualRate / 12 / 100;
    double months = tenure * 12;

    if (principal > 0 && monthlyRate > 0 && months > 0) {
      emi = (principal * monthlyRate * pow(1 + monthlyRate, months)) /
          (pow(1 + monthlyRate, months) - 1);

      totalPayment = emi * months;
      totalInterest = totalPayment - principal;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Calculator"),
        backgroundColor: Colors.yellow
        
        ),
      body: Container(
        color: const Color.fromARGB(255, 201, 59, 59), // ✅ Light grey background
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: loanController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Loan Amount",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color.fromARGB(255, 131, 149, 233), // ✅ White background
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Interest Rate (%)",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color.fromARGB(255, 84, 182, 65), // ✅ White background
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tenureController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Tenure (Years)",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white, // ✅ White background
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateLoan,
              child: const Text("Calculate EMI"),
            ),
            const SizedBox(height: 20),
            if (emi > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Monthly EMI: ₹${emi.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18)),
                  Text("Total Interest: ₹${totalInterest.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18)),
                  Text("Total Payment: ₹${totalPayment.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18)),
                ],
              )
          ],
        ),
      ),
    );
  }
}
