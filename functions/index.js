const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.unlockDoorAfterTimeout = functions.firestore
    .document("devices/{deviceId}")
    .onUpdate((change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        const deviceId = context.params.deviceId;

        // Only run if the door has just been locked and has a lockUntil timestamp
        if (!before.locked && after.locked && after.lockUntil > Date.now()) {
            const unlockDelay = after.lockUntil - Date.now();

            console.log(`Scheduling unlock for device ${deviceId} in ${unlockDelay} ms`);

            // setTimeout for short timeouts (max 9 minutes)
            setTimeout(async () => {
                try {
                    const docRef = admin.firestore().collection("devices").doc(deviceId);
                    const docSnap = await docRef.get();
                    const current = docSnap.data();

                    // Check if it's still locked and lockUntil hasn't been changed
                    if (current.locked && current.lockUntil === after.lockUntil) {
                        await docRef.update({
                            locked: false,
                            lockUntil: 0,
                            mode: "closed",
                        });
                        console.log(`Device ${deviceId} unlocked successfully`);
                    } else {
                        console.log(`Device ${deviceId} already unlocked or lockUntil changed`);
                    }
                } catch (error) {
                    console.error(`Failed to unlock device ${deviceId}:`, error);
                }
            }, unlockDelay);
        }

        return null;
    });
