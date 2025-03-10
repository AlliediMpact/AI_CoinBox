import 'package:flutter/material.dart';
import '../models/investment.dart';
import '../models/loan.dart';
import '../services/trade_service.dart';
import '../widgets/custom_button.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({Key? key}) : super(key: key);

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  List<Investment> _investments = [];
  List<Loan> _loans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTradingData();
  }

  // Method to load trading data from Firestore
  Future<void> _loadTradingData() async {
    try {
      final investments = await TradeService.getInvestments();
      final loans = await TradeService.getLoans();
      setState(() {
        _investments = investments;
        _loans = loans;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorDialog('Failed to load trading data. Please try again.');
    }
  }

  // Method to display error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Investment Opportunities',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ..._investments.map((investment) => InvestmentCard(investment: investment)).toList(),
                    const SizedBox(height: 20),
                    const Text(
                      'Borrowing Options',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ..._loans.map((loan) => LoanCard(loan: loan)).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}

// Example widget for displaying an investment opportunity
class InvestmentCard extends StatelessWidget {
  final Investment investment;

  const InvestmentCard({Key? key, required this.investment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              investment.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Amount: \$${investment.amount}'),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Invest Now',
              onPressed: () {
                // Implement investment logic
                _invest(investment);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle investment logic
  void _invest(Investment investment) {
    // TODO: Implement investment logic based on business model
  }
}

// Example widget for displaying a borrowing option
class LoanCard extends StatelessWidget {
  final Loan loan;

  const LoanCard({Key? key, required this.loan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loan.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Amount: \$${loan.amount}'),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Borrow Now',
              onPressed: () {
                // Implement borrowing logic
                _borrow(loan);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle borrowing logic
  void _borrow(Loan loan) {
    // TODO: Implement borrowing logic based on business model
  }
}

// Method to handle investment logic
void _invest(Investment investment) async {
  try {
    // Check user's membership plan and investment limit
    final userMembershipPlan = await TradeService.getUserMembershipPlan();
    if (investment.amount > userMembershipPlan.investmentLimit) {
      _showErrorDialog('Investment amount exceeds your plan limit.');
      return;
    }

    // Calculate interest and update Firestore
    final interest = investment.amount * 0.20; // 20% interest
    final walletInterest = interest * 0.05; // 5% to wallet
    final bankInterest = interest - walletInterest; // Rest to bank account

    await TradeService.processInvestment(
      investment: investment,
      walletInterest: walletInterest,
      bankInterest: bankInterest,
    );

    _showSuccessDialog('Investment successful! Interest will be credited.');
  } catch (e) {
    _showErrorDialog('Failed to process investment. Please try again.');
  }
}

// Method to display success dialog
void _showSuccessDialog(String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Success!'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text('Okay'),
        ),
      ],
    ),
  );
}

// Method to handle borrowing logic
void _borrow(Loan loan) async {
  try {
    // Check user's membership plan and loan limit
    final userMembershipPlan = await TradeService.getUserMembershipPlan();
    if (loan.amount > userMembershipPlan.loanLimit) {
      _showErrorDialog('Loan amount exceeds your plan limit.');
      return;
    }

    // Apply repayment fee and update Firestore
    final repaymentFee = loan.amount * 0.25; // 25% repayment fee
    final walletFee = repaymentFee * 0.05; // 5% to borrower's wallet
    final investorFee = repaymentFee - walletFee; // Rest to investor

    await TradeService.processLoan(
      loan: loan,
      walletFee: walletFee,
      investorFee: investorFee,
    );

    _showSuccessDialog('Loan processed successfully! Repayment details updated.');
  } catch (e) {
    _showErrorDialog('Failed to process loan. Please try again.');
  }
}