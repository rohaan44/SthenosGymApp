const admin = require("firebase-admin");

admin.initializeApp();

const deleteOverdueMembers =
  require("./jobs/delete_overdue_job");

const dailyNotificationJob =
  require("./jobs/daily_notification_job");

exports.deleteOverdueMembers =
  deleteOverdueMembers.deleteOverdueMembers;

exports.dailyNotificationJob =
  dailyNotificationJob.dailyNotificationJob;

exports.testNotificationJob =
  dailyNotificationJob.testNotificationJob;