const functions = require("firebase-functions");
const admin = require("firebase-admin");

const db = admin.firestore();

exports.deleteOverdueMembers = functions.pubsub
    .schedule("5 0 * * *")
    .timeZone("Asia/Karachi")
    .onRun(async () => {

        console.log("===== Delete Overdue Members Started =====");

        const today = new Date();

        const threeMonthsAgo = new Date(today);

        threeMonthsAgo.setMonth(today.getMonth() - 3);

        const yyyy = threeMonthsAgo.getFullYear();

        const mm = String(
            threeMonthsAgo.getMonth() + 1,
        ).padStart(2, "0");

        const dd = String(
            threeMonthsAgo.getDate(),
        ).padStart(2, "0");

        const threeMonthsAgoStr =
            `${yyyy}-${mm}-${dd}`;

        console.log(
            `Checking Members <= ${threeMonthsAgoStr}`,
        );

        try {

            const snapshot = await db
                .collection("members")
                .where(
                    "expiryDate",
                    "<=",
                    threeMonthsAgoStr,
                )
                .get();

            if (snapshot.empty) {

                console.log("No Members Found");

                return null;

            }

            const batch = db.batch();

            const logCollection =
                db.collection("deleted_members_log");

            snapshot.docs.forEach((doc) => {

                const data = doc.data();

                const logDoc =
                    logCollection.doc();

                batch.set(logDoc, {

                    name: data.name || "",

                    memberId: doc.id,

                    gymId: data.gymId || "",

                    lastPaymentDate:
                        data.lastPaymentDate || "",

                    expiryDate:
                        data.expiryDate || "",

                    deletedAt:
                        admin.firestore.FieldValue.serverTimestamp(),

                    reason:
                        "Overdue for 3+ months",

                });

                batch.delete(doc.ref);

                console.log(
                    `Deleting : ${data.name}`,
                );

            });

            await batch.commit();

            console.log(
                `${snapshot.size} Members Deleted`,
            );

        } catch (e) {

            console.error(e);

        }

        console.log(
            "===== Delete Overdue Members Finished =====",
        );

        return null;

    });