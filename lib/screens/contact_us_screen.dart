import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import '../widgets/header.dart';
import '../constants/app_colors.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  // Method to launch email client
  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@aicombo.com',
      query: 'subject=Support Request&body=Hello, I need help with...',
    );
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      // Handle error
    }
  }

  // Method to launch phone dialer
  void _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+11234567890',
    );
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      // Handle error
    }
  }

  // Method to launch map
  void _launchMap() async {
    final Uri mapUri = Uri(
      scheme: 'geo',
      path: '0,0',
      query: 'q=123 Main Street, Anytown, USA',
    );
    if (await canLaunch(mapUri.toString())) {
      await launch(mapUri.toString());
    } else {
      // Handle error
    }
  }

  // Method to launch social media
  void _launchSocialMedia(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'We\'d love to hear from you! If you have any questions, feedback, or concerns, please don\'t hesitate to get in touch with us.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'You can reach us via:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primaryPurple),
              title: const Text('Email'),
              subtitle: const Text('support@aicombo.com'),
              onTap: _launchEmail,
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primaryPurple),
              title: const Text('Phone'),
              subtitle: const Text('+1 123 456 7890'),
              onTap: _launchPhone,
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primaryPurple),
              title: const Text('Address'),
              subtitle: const Text('123 Main Street, Anytown, USA'),
              onTap: _launchMap,
            ),
            const SizedBox(height: 24),
            const Text(
              'Follow Us:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: AppColors.primaryPurple),
                  onPressed: () => _launchSocialMedia('https://facebook.com/alliedimpact'),
                ),
                IconButton(
                  icon: const Icon(Icons.link, color: AppColors.primaryPurple),
                  onPressed: () => _launchSocialMedia('https://twitter.com/alliedimpact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}