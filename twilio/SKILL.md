---
name: twilio
description: "Implements Twilio communication features: sending SMS messages, phone and email verification with Verify, and IVR call flows with TwiML. Use when integrating SMS notifications, OTP two-factor authentication, voice menus, webhooks, status callbacks, delivery receipts, call routing, or automated calls with the Twilio REST API, Messaging Service, phone numbers, and TwiML in Python, Node, or Flask."
---

# Twilio Communications

Add messaging, verification, and voice‑call capabilities to your application using Twilio's REST API and TwiML. The skill covers SMS sending, phone/email verification (2FA/OTP), and Interactive Voice Response (IVR) menus.

## When to use
- Send transactional or alert SMS to users.
- Verify a phone number or email during signup, password reset, or high‑value actions.
- Provide a phone menu, call routing, or voicemail system.

---

## 1. SMS Sending Pattern
### Workflow
1. Load `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, and a verified `TWILIO_PHONE_NUMBER` from environment variables.
2. Validate the destination number is in **E.164** format (`+1234567890`).
3. Count message segments (160 chars per segment). Warn if more than one segment – each segment incurs a separate charge.
4. Call `client.messages.create` with `to`, `from_`, `body`, and optional `status_callback` URL.
5. Capture the returned `Message SID` and status.
6. Handle `TwilioRestException` and map to a clear error response.

### Rules & Limits
- **Phone format**: Must match `^\+[1-9]\d{1,14}$`.
- **Rate limit**: Default 80 messages / second per account. Implement application‑level throttling for bursts.
- **Segmentation**: Messages >160 chars are split; each segment is billed.
- **Carrier filtering**: US carriers may block A2P traffic. Register for **A2P 10DLC** if sending commercial messages in the US.
- **Opt‑out**: Honor STOP/UNSTOP replies. Store opt‑out status in your database.

### Python example
```python
import os, re
from twilio.rest import Client
from twilio.base.exceptions import TwilioRestException

E164_REGEX = re.compile(r'^\+[1-9]\d{1,14}$')

class TwilioSMS:
    def __init__(self):
        self.client = Client(
            os.getenv('TWILIO_ACCOUNT_SID'),
            os.getenv('TWILIO_AUTH_TOKEN')
        )
        self.from_number = os.getenv('TWILIO_PHONE_NUMBER')

    def _valid_e164(self, phone: str) -> bool:
        return bool(E164_REGEX.fullmatch(phone))

    def send_sms(self, to: str, body: str, status_callback: str = None) -> dict:
        if not self._valid_e164(to):
            return {'success': False, 'error': 'Invalid E.164 phone number'}

        segments = (len(body) + 159) // 160
        if segments > 1:
            print(f'Warning: message will be sent as {segments} segments')

        try:
            msg = self.client.messages.create(
                to=to,
                from_=self.from_number,
                body=body,
                status_callback=status_callback,
            )
            return {
                'success': True,
                'sid': msg.sid,
                'status': msg.status,
                'segments': segments,
            }
        except TwilioRestException as e:
            return {'success': False, 'error': str(e)}
```
---

## 2. Phone/Email Verification (Twilio Verify)
### Workflow
1. Create a Verify Service in the Twilio Console. Note its `SERVICE_SID`.
2. Initialise the client with the same credentials as SMS.
3. Call `verify.services(SERVICE_SID).verifications.create` with the target (`to`) and a channel (`sms`, `call`, `email`, `whatsapp`).
4. Store the returned verification `status` (`pending`).
5. When the user submits a code, call `verify.services(...).verification_checks.create` with `to` and `code`.
6. Interpret `verification_check.status` – `approved` means the code is correct.

### Rules & Benefits
- **No OTP storage**: Twilio generates, expires, and validates codes.
- **Automatic rate limiting**: Prevents brute‑force attacks.
- **Fraud prevention**: Built‑in risk scoring and blocking.
- **Multi‑channel**: Choose SMS, voice call, email, or WhatsApp.
- **Locale**: Pass a language code (`en`, `es`, …) to localise the message.

### Python example
```python
import os
from enum import Enum
from twilio.rest import Client
from twilio.base.exceptions import TwilioRestException

class VerifyChannel(Enum):
    SMS = 'sms'
    CALL = 'call'
    EMAIL = 'email'
    WHATSAPP = 'whatsapp'

class TwilioVerify:
    def __init__(self, service_sid: str = None):
        self.client = Client(
            os.getenv('TWILIO_ACCOUNT_SID'),
            os.getenv('TWILIO_AUTH_TOKEN')
        )
        self.service_sid = service_sid or os.getenv('TWILIO_VERIFY_SID')

    def send_verification(self, to: str, channel: VerifyChannel = VerifyChannel.SMS, locale: str = 'en') -> dict:
        try:
            verification = self.client.verify.v2.services(self.service_sid)\
                .verifications.create(to=to, channel=channel.value, locale=locale)
            return {'success': True, 'status': verification.status, 'channel': channel.value}
        except TwilioRestException as e:
            return {'success': False, 'error': str(e)}

    def check_verification(self, to: str, code: str) -> dict:
        try:
            check = self.client.verify.v2.services(self.service_sid)\
                .verification_checks.create(to=to, code=code)
            return {'success': True, 'status': check.status, 'valid': check.status == 'approved'}
        except TwilioRestException as e:
            return {'success': False, 'error': str(e)}
```
---

## 3. IVR with TwiML (Voice)
### Workflow
1. Expose an HTTPS endpoint that Twilio can POST to for incoming calls.
2. Validate the request using `RequestValidator` and the `X‑Twilio‑Signature` header.
3. Return a **TwiML** `VoiceResponse` XML document that defines the call flow.
4. Use TwiML verbs:
   - `<Say>` – text‑to‑speech.
   - `<Play>` – play an audio file.
   - `<Gather>` – collect DTMF or speech input.
   - `<Dial>` – connect to another number.
   - `<Record>` – record caller audio.
   - `<Redirect>` – move to another TwiML URL.
5. For each user interaction, store a session identifier (e.g., in a cookie, DB, or Redis) because Twilio treats each webhook call as stateless.

### Rules & Security
- **Signature validation** is mandatory; reject requests that fail.
- **HTTPS** is required for production.
- **Stateless design**: Do not rely on in‑memory state between webhook calls.
- **Timeouts**: Twilio waits up to 15 seconds for a response. Return TwiML quickly.
- **Error handling**: Return `<Say>` with an error message and `<Hangup>` if unrecoverable.

### Flask example (Python)
```python
import os
from flask import Flask, request, Response
from twilio.request_validator import RequestValidator
from twilio.twiml.voice_response import VoiceResponse, Gather

app = Flask(__name__)
validator = RequestValidator(os.getenv('TWILIO_AUTH_TOKEN'))

def twilio_valid(f):
    def wrapper(*args, **kwargs):
        url = request.url
        params = request.form.to_dict()
        signature = request.headers.get('X-Twilio-Signature', '')
        if not validator.validate(url, params, signature):
            return 'Invalid signature', 403
        return f(*args, **kwargs)
    wrapper.__name__ = f.__name__
    return wrapper

@app.route('/voice/incoming', methods=['POST'])
@twilio_valid
def incoming():
    resp = VoiceResponse()
    gather = Gather(num_digits=1, action='/voice/menu', method='POST', timeout=5)
    gather.say('Welcome. Press 1 for sales. Press 2 for support. Press 3 to leave a message.')
    resp.append(gather)
    resp.redirect('/voice/incoming')  # repeat if no input
    return Response(str(resp), mimetype='text/xml')

@app.route('/voice/menu', methods=['POST'])
@twilio_valid
def menu():
    digit = request.form.get('Digits')
    resp = VoiceResponse()
    if digit == '1':
        resp.say('Connecting you to sales.')
        resp.dial(os.getenv('SALES_PHONE'))
    elif digit == '2':
        resp.say('Connecting you to support.')
        resp.dial(os.getenv('SUPPORT_PHONE'))
    elif digit == '3':
        resp.say('Please leave a message after the tone.')
        resp.record(maxLength=120, action='/voice/recording')
    else:
        resp.say('Invalid selection.')
        resp.redirect('/voice/incoming')
    return Response(str(resp), mimetype='text/xml')

@app.route('/voice/recording', methods=['POST'])
@twilio_valid
def recording():
    resp = VoiceResponse()
    resp.say('Thank you. Goodbye.')
    resp.hangup()
    # Here you could store request.form['RecordingUrl']
    return Response(str(resp), mimetype='text/xml')
```
---

## 4. Sharp Edges & Common Pitfalls
- **Never hard‑code credentials**; always read from environment or a secret manager.
- **Register for A2P 10DLC** (US) to avoid carrier blocks on commercial SMS.
- **Implement retry logic** for transient network errors (e.g., exponential back‑off).
- **Track opt‑out** (STOP, UNSUBSCRIBE) and respect it in all outbound flows.
- **Rate‑limit** both at Twilio level (default 80 MPS) and at your application level to avoid spikes.
- **Validate Twilio signatures** on every webhook; failure is a security risk.
- **Session management**: Use a persistent store (Redis, DB) for multi‑step IVR flows.
- **Testing**: Use Twilio’s test credentials and sandbox numbers to avoid real charges.

## Checklist
- [ ] Set `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER` in environment.
- [ ] Verify phone numbers are in E.164 format before sending.
- [ ] Register a Verify Service and store its SID (`TWILIO_VERIFY_SID`).
- [ ] Implement request signature validation for all webhook endpoints.
- [ ] Use HTTPS URLs for Twilio webhooks.
- [ ] Add application‑level rate limiting (e.g., token bucket).
- [ ] Store user opt‑out status and exclude them from future messages.
- [ ] Log Twilio request IDs (`MessageSid`, `CallSid`) for troubleshooting.
- [ ] Test SMS/Verify/IVR with Twilio sandbox before production.
- [ ] Monitor Twilio usage dashboards for unexpected spikes.

## Related skills

Load these when the task spans more than this skill.

- [`telegram-bot`](../telegram-bot/SKILL.md) — Step‑by‑step guide to create, configure, and deploy a Telegram bot with Node.js or Python. Covers token handli…
- [`voice-ai`](../voice-ai/SKILL.md) — The voice‑ai skill guides you to build low‑latency, production‑grade voice agents. It covers speech‑to‑speech…
- [`email-marketing`](../email-marketing/SKILL.md) — Provides a complete guide for building effective email marketing sequences and the supporting email infrastruc…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
- [`background-jobs`](../background-jobs/SKILL.md) — Provides guidance for implementing reliable background jobs in Node.js/TypeScript using BullMQ, Trigger.dev, o…
