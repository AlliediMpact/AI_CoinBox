# AI CoinBox - P2P Loan and Investment Platform

AI CoinBox is a peer-to-peer (P2P) loan and investment platform designed to connect borrowers and investors. The platform provides a secure and transparent environment for financial transactions, including loans, investments, referrals, and more.

---

## Features

### **User Features**
- **Authentication**: Sign up, sign in, and reset passwords.
- **KYC Verification**: Submit KYC documents for verification.
- **Wallet Management**: Manage wallet balances for transactions.
- **Loans**: Request loans with interest rates and repayment terms.
- **Investments**: Create investments and earn monthly returns.
- **Referrals**: Refer users and earn commissions.
- **Transaction History**: View detailed transaction history.

### **Admin Features**
- **KYC Management**: Approve or reject KYC submissions.
- **User Management**: Suspend or delete users and assign roles.
- **System Reports**: View platform statistics and trends.
- **Escrow Management**: Handle escrow transactions securely.

---

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **Payment Gateway**: Paystack
- **State Management**: Provider
- **Charts and Visualization**: fl_chart, charts_flutter

---

## Installation

### Prerequisites
- Flutter SDK (>=3.7.0 <4.0.0)
- Firebase account
- Paystack account for payment integration

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/ai-coinbox.git
   cd ai-coinbox
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective directories.
   - Ensure `firebase_options.dart` is generated using the Firebase CLI.

4. Configure Paystack:
   - Replace `YOUR_PAYSTACK_SECRET_KEY` and `YOUR_PAYSTACK_PUBLIC_KEY` in `lib/services/paystack_service.dart` with your Paystack API keys.

5. Run the app:
   ```bash
   flutter run
   ```

---

## Project Structure

```
ai_coinbox/
├── lib/
│   ├── constants/          # App constants (e.g., membership tiers)
│   ├── models/             # Data models (e.g., Wallet, Loan, Investment)
│   ├── screens/            # UI screens (e.g., Auth, Dashboard, Admin Panel)
│   ├── services/           # Business logic and Firebase interactions
│   ├── main.dart           # App entry point
├── assets/                 # Images, icons, and animations
├── pubspec.yaml            # Project dependencies
├── README.md               # Project documentation
```

---

## Usage

### **User Flow**
1. **Sign Up**: Create an account and complete KYC verification.
2. **Dashboard**: Access wallet balance, loans, investments, and referrals.
3. **Transactions**: View transaction history and manage financial activities.

### **Admin Flow**
1. **KYC Management**: Approve or reject user KYC submissions.
2. **User Management**: Suspend or delete users and assign roles.
3. **Reports**: View system statistics and trends.

---

## Testing

### Unit Tests
Run unit tests for services and business logic:
```bash
flutter test
```

### Widget Tests
Run widget tests for UI components:
```bash
flutter test test/screens/auth_screen_test.dart
```

---

## Security

- **Authentication**: Firebase Authentication ensures secure user sign-in and sign-up.
- **Firestore Rules**: Access is restricted to authenticated users with proper roles.
- **Escrow Transactions**: Funds are securely locked and released using Firebase transactions.

---

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add feature-name"
   ```
4. Push to your branch:
   ```bash
   git push origin feature-name
   ```
5. Open a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

For questions or support, please contact:
- **Email**: support@ai-coinbox.com
- **Website**: [www.ai-coinbox.com](https://www.ai-coinbox.com)