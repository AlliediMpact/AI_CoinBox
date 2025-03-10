const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.matchTrades = functions.firestore
    .document("/investments/{investmentId}")
    .onCreate(async (snap, context) => {
        try {
            const investment = snap.data();
            const investmentId = context.params.investmentId;

            // Check if the user is investing or borrowing
            if (!investment || !investment.userId) {
                console.log("Invalid investment data:", investment);
                return null;
            }
            // Search for a matching loan
            const matchingLoan = await admin.firestore()
                .collection("loans")
                .where("amount", "==", investment.amount)
                .where("status", "==", "pending")
                .limit(1)
                .get();

            if (!matchingLoan.empty) {
                // Found a match
                const loanDoc = matchingLoan.docs[0];
                const loan = loanDoc.data();
                const loanId = loanDoc.id;

                // Update investment and loan status
                await admin.firestore().collection("investments").doc(investmentId)
                    .update({
                        status: "matched",
                        matchedAt: admin.firestore.FieldValue.serverTimestamp(),
                        loanId: loanId,
                    });
                await admin.firestore().collection("loans").doc(loanId)
                    .update({
                        status: "matched",
                        matchedAt: admin.firestore.FieldValue.serverTimestamp(),
                        investmentId: investmentId,
                    });

                // Create a trade record
                const tradeRef = await admin.firestore().collection("trades").add({
                    investorId: investment.userId,
                    borrowerId: loan.userId,
                    investmentId: investmentId,
                    loanId: loanId,
                    tradeAmount: investment.amount,
                    status: "active",
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                const tradeId = tradeRef.id;
                await admin.firestore().collection("investments").doc(investmentId)
                    .update({
                        tradeId: tradeId,
                    });
                await admin.firestore().collection("loans").doc(loanId)
                    .update({
                        tradeId: tradeId,
                    });

                // Update investor and borrower balance
                await admin.firestore().collection("wallets").doc(investment.userId)
                    .update({
                        balance: admin.firestore.FieldValue.increment(-investment.amount),
                        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                    });
                await admin.firestore().collection("wallets").doc(loan.userId)
                    .update({
                        balance: admin.firestore.FieldValue.increment(investment.amount),
                        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                    });
                //Notify both users.
            }
        } catch (e) {
            console.error("Error in matchTrades:", e);
        }
        return null;
    });

exports.matchTradesLoan = functions.firestore
    .document("/loans/{loanId}")
    .onCreate(async (snap, context) => {
        try {
            const loan = snap.data();
            const loanId = context.params.loanId;

            // Check if the user is investing or borrowing
            if (!loan || !loan.userId) {
                console.log("Invalid loan data:", loan);
                return null;
            }
            // Search for a matching Investment
            const matchingInvestment = await admin.firestore()
                .collection("investments")
                .where("amount", "==", loan.amount)
                .where("status", "==", "pending")
                .limit(1)
                .get();

            if (!matchingInvestment.empty) {
                // Found a match
                const investmentDoc = matchingInvestment.docs[0];
                const investment = investmentDoc.data();
                const investmentId = investmentDoc.id;

                // Update investment and loan status
                await admin.firestore().collection("investments").doc(investmentId)
                    .update({
                        status: "matched",
                        matchedAt: admin.firestore.FieldValue.serverTimestamp(),
                        loanId: loanId,
                    });
                await admin.firestore().collection("loans").doc(loanId)
                    .update({
                        status: "matched",
                        matchedAt: admin.firestore.FieldValue.serverTimestamp(),
                        investmentId: investmentId,
                    });

                // Create a trade record
                const tradeRef = await admin.firestore().collection("trades").add({
                    investorId: investment.userId,
                    borrowerId: loan.userId,
                    investmentId: investmentId,
                    loanId: loanId,
                    tradeAmount: loan.amount,
                    status: "active",
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                const tradeId = tradeRef.id;
                await admin.firestore().collection("investments").doc(investmentId)
                    .update({
                        tradeId: tradeId,
                    });
                await admin.firestore().collection("loans").doc(loanId)
                    .update({
                        tradeId: tradeId,
                    });

                // Update investor and borrower balance
                await admin.firestore().collection("wallets").doc(investment.userId)
                    .update({
                        balance: admin.firestore.FieldValue.increment(-investment.amount),
                        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                    });
                await admin.firestore().collection("wallets").doc(loan.userId)
                    .update({
                        balance: admin.firestore.FieldValue.increment(loan.amount),
                        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                    });
            }
        } catch (e) {
            console.error("Error in matchTradesLoan:", e);
        }
        return null;
    });
