const admin = require("firebase-admin");

class FCMService {

    async sendNotification(tokens, title, body, data = {}) {

        if (!tokens || tokens.length === 0) {

            console.log("No FCM Tokens Found.");

            return;

        }

        const message = {

            notification: {
                title,
                body,
            },

            data,

            tokens,

        };

        try {

            const response =
                await admin.messaging().sendEachForMulticast(message);

            console.log(
                `Success : ${response.successCount}`
            );

            console.log(
                `Failed : ${response.failureCount}`
            );

            return response;

        } catch (e) {

            console.error("FCM Error :", e);

        }

    }

}

module.exports = new FCMService();