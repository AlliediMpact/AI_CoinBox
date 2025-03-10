import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/security_service.dart';
import '../utils/error_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  String _appVersion = '';
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  bool _isBiometricAvailable = false;
  
  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _loadNotificationSettings();
    _loadSecuritySettings();
  }
  
  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
    }
  }
  
  Future<void> _loadNotificationSettings() async {
    try {
      final notificationsEnabled = await NotificationService.getNotificationsEnabled();
      setState(() {
        _notificationsEnabled = notificationsEnabled;
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
    }
  }

  Future<void> _loadSecuritySettings() async {
    try {
      final biometricAvailable = await SecurityService.isBiometricAvailable();
      final biometricEnabled = await SecurityService.isBiometricEnabled();
      final pinEnabled = await SecurityService.isPinEnabled();
      
      setState(() {
        _isBiometricAvailable = biometricAvailable;
        _biometricEnabled = biometricEnabled;
        _pinEnabled = pinEnabled;
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace: stackTrace);
    }
  }
  
  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    
    try {
      await FirebaseService.authService.signOut();
      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e, stackTrace) {
      ErrorHandler.handleAuthError(context, e, stackTrace: stackTrace);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _showDeleteAccountDialog() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);
    
    try {
      // Delete user account
      await FirebaseService.authService.deleteAccount();
      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e, stackTrace) {
      ErrorHandler.handleAuthError(context, e, stackTrace: stackTrace);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showPinSetupDialog() async {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
            TextField(
              controller: confirmPinController,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (pinController.text.isEmpty || 
                  pinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PINs do not match or are empty'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              try {
                await SecurityService.setPin(pinController.text);
                await SecurityService.setPinEnabled(true);
                Navigator.of(ctx).pop();
                setState(() {
                  _pinEnabled = true;
                });
              } catch (e, stackTrace) {
                ErrorHandler.logError(e, stackTrace: stackTrace);
                ErrorHandler.showErrorSnackBar(
                  context, 
                  'Failed to set PIN'
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = userProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Account settings section
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Profile'),
                        subtitle: Text(user?.email ?? 'Not signed in'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.security),
                        title: const Text('Change Password'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to change password screen or show dialog
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App settings section
                const Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Notifications'),
                        subtitle: const Text('Enable push notifications'),
                        value: _notificationsEnabled,
                        onChanged: (value) async {
                          try {
                            await NotificationService.setNotificationsEnabled(value);
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          } catch (e, stackTrace) {
                            ErrorHandler.logError(e, stackTrace: stackTrace);
                            ErrorHandler.showErrorSnackBar(
                              context, 
                              'Failed to update notification settings'
                            );
                          }
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Enable dark theme'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.setDarkMode(value);
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Security section
                const Text(
                  'Security',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      if (_isBiometricAvailable)
                        SwitchListTile(
                          title: const Text('Biometric Authentication'),
                          subtitle: const Text('Use fingerprint or face ID'),
                          value: _biometricEnabled,
                          onChanged: (value) async {
                            try {
                              if (value) {
                                // Authenticate before enabling
                                final authenticated = await SecurityService.authenticateWithBiometrics(context);
                                if (!authenticated) {
                                  return;
                                }
                              }
                              
                              await SecurityService.setBiometricEnabled(value);
                              setState(() {
                                _biometricEnabled = value;
                              });
                            } catch (e, stackTrace) {
                              ErrorHandler.logError(e, stackTrace: stackTrace);
                              ErrorHandler.showErrorSnackBar(
                                context, 
                                'Failed to update biometric settings'
                              );
                            }
                          },
                        ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('PIN Authentication'),
                        subtitle: const Text('Use a PIN to secure your account'),
                        value: _pinEnabled,
                        onChanged: (value) async {
                          try {
                            if (value) {
                              // Show PIN setup dialog
                              _showPinSetupDialog();
                            } else {
                              // Disable PIN
                              await SecurityService.setPinEnabled(false);
                              setState(() {
                                _pinEnabled = false;
                              });
                            }
                          } catch (e, stackTrace) {
                            ErrorHandler.logError(e, stackTrace: stackTrace);
                            ErrorHandler.showErrorSnackBar(
                              context, 
                              'Failed to update PIN settings'
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Support section
                const Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/contact');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('About'),
                        subtitle: Text('Version: $_appVersion'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/about');
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Account actions section
                const Text(
                  'Account Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Sign Out'),
                        onTap: _signOut,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: Colors.red),
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: _showDeleteAccountDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}