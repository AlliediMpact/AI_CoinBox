// File: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/header.dart';
import '../widgets/custom_navigation_drawer.dart';
import '../services/firebase_service.dart';
import '../models/transaction.dart'; // Ensure this model defines a fromMap() method and a TransactionType enum if needed

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      // Refresh wallet data and load transactions
      walletProvider.refresh();
      transactionProvider.loadTransactions();
      _loadUserProfile(userProvider);
    });
  }

  Future<void> _loadUserProfile(UserProvider userProvider) async {
    final user = FirebaseService.auth.currentUser;
    if (user != null) {
      final doc = await FirebaseService.firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        userProvider.setUser(user);
        userProvider.setProfileData(doc.data()!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: const Header(),
      drawer: const CustomNavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await walletProvider.refresh();
          await transactionProvider.loadTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Welcome, ${userProvider.fullName.split(' ').first}!',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              // Wallet Balance Card
              _buildWalletCard(walletProvider),
              const SizedBox(height: 24),
              // Quick Actions Section
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              // Recent Transactions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/wallet');
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildRecentTransactions(transactionProvider),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWalletCard(WalletProvider walletProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryPurple,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wallet Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R${walletProvider.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem(
                  'Invested',
                  'R${walletProvider.totalInvested.toStringAsFixed(2)}',
                  Icons.trending_up,
                ),
                _buildBalanceItem(
                  'Borrowed',
                  'R${walletProvider.totalBorrowed.toStringAsFixed(2)}',
                  Icons.trending_down,
                ),
                _buildBalanceItem(
                  'Commission',
                  'R${walletProvider.commissionBalance.toStringAsFixed(2)}',
                  Icons.people,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String title, String amount, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          context,
          'Invest',
          Icons.trending_up,
          AppColors.success,
          () {
            Navigator.pushNamed(context, '/trade', arguments: 'invest');
          },
        ),
        _buildActionButton(
          context,
          'Borrow',
          Icons.trending_down,
          AppColors.error,
          () {
            Navigator.pushNamed(context, '/trade', arguments: 'borrow');
          },
        ),
        _buildActionButton(
          context,
          'Refer',
          Icons.people,
          AppColors.primaryPurple,
          () {
            Navigator.pushNamed(context, '/referrals');
          },
        ),
        _buildActionButton(
          context,
          'History',
          Icons.history,
          AppColors.textSecondary,
          () {
            Navigator.pushNamed(context, '/wallet');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        Ink(
          decoration: ShapeDecoration(
            color: color,
            shape: const CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(icon),
            color: Colors.white,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(TransactionProvider transactionProvider) {
    final transactions = transactionProvider.transactions;
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions yet.'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          leading: Icon(
            _getTransactionIcon(transaction.type),
            color: _getTransactionColor(transaction.type),
          ),
          title: Text(transaction.description),
          subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(transaction.date)),
          trailing: Text(
            'R${transaction.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: _getTransactionColor(transaction.type),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  IconData _getTransactionIcon(dynamic type) {
    // Convert enum to string if necessary.
    switch (type.toString()) {
      case 'TransactionType.deposit':
        return Icons.arrow_downward;
      case 'TransactionType.withdrawal':
        return Icons.arrow_upward;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getTransactionColor(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.deposit':
        return AppColors.success;
      case 'TransactionType.withdrawal':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        // Implement navigation based on index if needed.
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: 'Trading',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Referrals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'About Us',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contact_support),
          label: 'Contact Us',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }
}
