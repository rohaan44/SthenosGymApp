const functions = require("firebase-functions");

const MemberService = require("../services/member_service");
const NotificationService = require("../services/notification_service");
const FCMService = require("../services/fcm_service");

async function checkNotifications() {

    console.log("===== Daily Notification Started =====");

    const expiring =
        await MemberService.getExpiringSoonMembers();

    const expired =
        await MemberService.getExpiredTodayMembers();

    const pendingOne =
        await MemberService.getPendingOneMonthMembers();

    const pendingTwo =
        await MemberService.getPendingTwoMonthMembers();

    const admissionExpired =
        await MemberService.getAdmissionExpiredMembers();

    const tokens =
        await NotificationService.getTokens();

    if (tokens.length === 0) {

        console.log("No Admin Tokens Found");

        return;

    }

    const title = "🏋️ Sthenos Gym";

    const body =
        `Membership Summary

Expiring Soon : ${expiring.length}
Expired Today : ${expired.length}
Pending 1 Month : ${pendingOne.length}
Pending 2 Months : ${pendingTwo.length}
Admission Expired : ${admissionExpired.length}`;

    await FCMService.sendNotification(

        tokens,

        title,

        body,

        {
            type: "daily_summary",
            expiring: expiring.length.toString(),
            expired: expired.length.toString(),
            pendingOne: pendingOne.length.toString(),
            pendingTwo: pendingTwo.length.toString(),
            admissionExpired: admissionExpired.length.toString(),
        }

    );

    console.log("===== Daily Notification Completed =====");

}

exports.dailyNotificationJob = functions.pubsub
    .schedule("5 0 * * *")
    .timeZone("Asia/Karachi")
    .onRun(async () => {

        await checkNotifications();

        return null;

    });

exports.testNotificationJob = functions.https.onRequest(
    async (req, res) => {

        await checkNotifications();

        res.send("Notification Test Completed");

    },
);