enum EscrowStatus {
  pending,
  completed,
  disputed
}

class Escrow {
  final String id;
  double amount;
  EscrowStatus status;
  String senderId; // Add senderId
  String recipientId; // Add recipientId

  Escrow({required this.id, required this.amount, this.status = EscrowStatus.pending, required this.senderId, required this.recipientId});

  void deposit(double amount) {
    this.amount += amount;
  }

  void release(double amount) {
    if (amount <= this.amount && status == EscrowStatus.pending) {
      this.amount -= amount;
      this.status = EscrowStatus.completed;
    } else {
      throw Exception('Insufficient funds in escrow or escrow is not pending.');
    }
  }

  void dispute() {
    this.status = EscrowStatus.disputed;
  }

  Future<void> resolveDispute(bool releaseToRecipient, Function(String userId, double amount) updateUserWallet) async {
    if (status == EscrowStatus.disputed) {
      if (releaseToRecipient) {
        // Release funds to recipient
        this.status = EscrowStatus.completed;
      } else {
        // Return funds to sender
        this.status = EscrowStatus.completed;
        // Implement return of funds to sender
        try {
          await updateUserWallet(senderId, amount);
        } catch (e) {
          print('Error returning funds to sender: $e');
          throw Exception('Failed to return funds to sender.');
        }
      }
    } else {
      throw Exception('Escrow is not in disputed state.');
    }
  }

  double getAmount() {
    return this.amount;
  }

  EscrowStatus getStatus() {
    return this.status;
  }
}
