const admin = require("firebase-admin");

const db = admin.firestore();

class NotificationService {

    async getTokens() {

        const snapshot = await db.collection("admins").get();

        if (snapshot.empty) {
            return [];
        }

        const tokens = [];

        snapshot.docs.forEach(doc => {

            const data = doc.data();

            if (
                data.tokens &&
                Array.isArray(data.tokens)
            ) {

                tokens.push(...data.tokens);

            }

        });

        return [...new Set(tokens)];

    }

}

module.exports = new NotificationService();