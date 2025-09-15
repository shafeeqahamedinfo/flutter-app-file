import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        primarySwatch: Colors.blue,
      ),
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
        title: const Text("💰 Loan Calculator"),
        backgroundColor: const Color.fromARGB(221, 238, 236, 236),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: TextField(
                  controller: loanController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Loan Amount",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: TextField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Interest Rate (%)",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: TextField(
                  controller: tenureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Tenure (Years)",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 900),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFD4AF37), // Gold button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: calculateLoan,
                    child: const Text(
                      "Calculate EMI",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (emi > 0)
                BounceIn(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Monthly EMI: ₹${emi.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 6),
                        Text("Total Interest: ₹${totalInterest.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.redAccent)),
                        const SizedBox(height: 6),
                        Text("Total Payment: ₹${totalPayment.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.green)),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
