
const express = require('express')
const expApp = express()

const admin = require('firebase-admin');
const { getMessaging } = require('firebase-admin/messaging');
const serviceAccount = require("./mobilon-service-account.json");

PORT = 3000

const app = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
expApp.use(express.json());

var registrationTokens = [];

expApp.get('/', function (req, res) {
  res.send('Hello Sir')
})



expApp.post('/registerDevice', function (req, res) {
  registrationTokens.push(req.body.token);
  console.log("tokens: ", registrationTokens);
  res.send("Done")
})



expApp.post('/sendPushNotifications', function (req, res) {
  var title = req.body.title
  var body = req.body.body

  const message = {
    notification: {
      title: title,
      body: body
    },
    tokens: registrationTokens,
    priority: "high",
    android: {
        priority: "high"
    }
  };

  getMessaging(app).sendEachForMulticast(message)
    .then((response) => {
      if (response.failureCount > 0) {
        var failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(registrationTokens[idx]);
          }
        });
        console.log('List of tokens that caused failures: ' + failedTokens);
      } else {
        console.log('Notifications were sent successfully');
        res.send('Hello Sir Notifications are being Sent')
      }
    });

})


expApp.listen(PORT, () => {
  console.log(`Resonate Backend listening on port ${PORT}`);
});