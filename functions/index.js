const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

/**
 * Scheduled daily trigger to delete members whose payment has been overdue
 * for 3+ months (lexicographically checking if expiryDate <= 3 months ago).
 */
exports.deleteOverdueMembers = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    const today = new Date();
    // Calculate the date 3 months ago
    const threeMonthsAgo = new Date();
    threeMonthsAgo.setMonth(today.getMonth() - 3);

    // Format to YYYY-MM-DD
    const yyyy = threeMonthsAgo.getFullYear();
    const mm = String(threeMonthsAgo.getMonth() + 1).padStart(2, "0");
    const dd = String(threeMonthsAgo.getDate()).padStart(2, "0");
    const threeMonthsAgoStr = `${yyyy}-${mm}-${dd}`;

    console.log(`Checking for members with expiryDate <= ${threeMonthsAgoStr} (overdue for 3+ months)`);

    try {
      // Query members who are overdue for 3+ months (lexicographical check on YYYY-MM-DD string)
      const membersRef = db.collection("members");
      const snapshot = await membersRef.where("expiryDate", "<=", threeMonthsAgoStr).get();

      if (snapshot.empty) {
        console.log("No overdue members found to delete.");
        return null;
      }

      const batch = db.batch();
      const logsRef = db.collection("deleted_members_log");

      snapshot.docs.forEach((doc) => {
        const data = doc.data();

        // 1. Write key details to deleted_members_log
        const logDocRef = logsRef.doc();
        batch.set(logDocRef, {
          name: data.name || "",
          memberId: doc.id,
          gymId: data.gymId || "",
          lastPaymentDate: data.lastPaymentDate || "",
          expiryDate: data.expiryDate || "",
          deletedAt: admin.firestore.FieldValue.serverTimestamp(),
          reason: "Overdue for 3+ months"
        });

        // 2. Delete the member's document
        batch.delete(doc.ref);
        console.log(`Scheduling deletion and audit logging for member ${data.name} (Doc ID: ${doc.id})`);
      });

      // Commit the batch writes & deletes
      await batch.commit();
      console.log(`Successfully logged and deleted ${snapshot.size} members.`);
    } catch (error) {
      console.error("Error executing deleteOverdueMembers Cloud Function:", error);
    }
    return null;
  });
