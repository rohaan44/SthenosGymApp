importScripts("https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js");



firebase.initializeApp({
    apiKey: "AIzaSyCUN89uPzff9NcJ6q1ypIVyPNWYpwycfL4",
    authDomain: "sthenos-gym-8de40.firebaseapp.com",
    projectId: "sthenos-gym-8de40",
    storageBucket: "sthenos-gym-8de40.firebasestorage.app",
    messagingSenderId: "589496774641",
    appId: "1:589496774641:web:5710ba9722081f6368de50",

});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
    console.log("Background Message:", payload);

    self.registration.showNotification(
        payload.notification.title,
        {
            body: payload.notification.body,
            icon: "/icons/Icon-192.png",
        },
    );
});