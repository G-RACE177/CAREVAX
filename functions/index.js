const functions = require('firebase-functions');
const axios = require('axios');

// Callable Cloud Function: sendSms
// Expects payload: { message: string, recipients: [string], method: 'json' }
// This function uses environment variables to hold SMS credentials.
// Set them with:
// firebase functions:config:set sms.username="USER" sms.password="PASS" sms.sender="SENDER"

exports.sendSms = functions.https.onCall(async (data, context) => {
  // Optional: enforce authentication/roles
  // if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');

  const message = data.message;
  const recipients = data.recipients || [];
  const method = data.method || 'json';

  if (!message || !Array.isArray(recipients) || recipients.length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing message or recipients');
  }

  const username = functions.config().sms?.username || process.env.EGOSMS_USERNAME;
  const password = functions.config().sms?.password || process.env.EGOSMS_PASSWORD;
  const sender = functions.config().sms?.sender || process.env.EGOSMS_SENDER || 'CareVax';

  if (!username || !password) {
    throw new functions.https.HttpsError('failed-precondition', 'SMS credentials not configured');
  }

  try {
    if (method === 'plain') {
      const params = new URLSearchParams();
      params.append('username', username);
      params.append('password', password);
      params.append('number', recipients.join(','));
      params.append('message', message);
      params.append('sender', sender);

      const resp = await axios.post('https://www.egosms.co/api/v1/plain/', params.toString(), {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      });
      return { success: true, data: resp.data };
    }

    // JSON bulk API
    const msgData = recipients.map((number) => ({ number, message, senderid: sender, priority: '0' }));
    const body = {
      method: 'SendSms',
      userdata: { username, password },
      msgdata: msgData,
    };

    const resp = await axios.post('https://www.egosms.co/api/v1/json/', body, { headers: { 'Content-Type': 'application/json' } });
    return { success: true, data: resp.data };
  } catch (err) {
    console.error('sendSms error', err?.response?.data ?? err.message ?? err);
    throw new functions.https.HttpsError('internal', 'Failed to send SMS');
  }
});
