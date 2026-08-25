const admin = require("firebase-admin");

const {
    parseDate,
    addDays,
    addMonths,
    isSameDate,
} = require("../utils/date_utils");

const db = admin.firestore();

class MemberService {
    /// Get all active members
    async getAllMembers() {
        const snapshot = await db
            .collection("members")
            .where("status", "==", "Active")
            .get();

        return snapshot.docs.map((doc) => ({
            docId: doc.id,
            ...doc.data(),
        }));
    }

    /// Generic helper
    async getMembersByDate(targetDate) {
        const members = await this.getAllMembers();

        return members.filter((member) => {
            if (!member.expiryDate) return false;

            const expiryDate = parseDate(member.expiryDate);

            return isSameDate(expiryDate, targetDate);
        });
    }

    /// Membership expires after 3 days
    async getExpiringSoonMembers() {
        const reminderDate = addDays(new Date(), 3);

        return await this.getMembersByDate(reminderDate);
    }

    /// Membership expires today
    async getExpiredTodayMembers() {
        return await this.getMembersByDate(new Date());
    }

    /// Pending for 1 month
    async getPendingOneMonthMembers() {
        const members = await this.getAllMembers();

        const today = new Date();

        return members.filter((member) => {
            if (!member.expiryDate) return false;

            const expiry = parseDate(member.expiryDate);

            const pendingDate = addMonths(expiry, 1);

            return isSameDate(today, pendingDate);
        });
    }

    /// Pending for 2 months
    async getPendingTwoMonthMembers() {
        const members = await this.getAllMembers();

        const today = new Date();

        return members.filter((member) => {
            if (!member.expiryDate) return false;

            const expiry = parseDate(member.expiryDate);

            const pendingDate = addMonths(expiry, 2);

            return isSameDate(today, pendingDate);
        });
    }

    /// Admission expires after 3 months unpaid
    async getAdmissionExpiredMembers() {
        const members = await this.getAllMembers();

        const today = new Date();

        return members.filter((member) => {
            if (!member.expiryDate) return false;

            const expiry = parseDate(member.expiryDate);

            const deleteDate = addMonths(expiry, 3);

            return isSameDate(today, deleteDate);
        });
    }
}

module.exports = new MemberService();