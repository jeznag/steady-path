# 🎙️ SteadyPath Voice-Based Mental Health Check-In Proposal

**SteadyPath** is an iOS app designed for individuals with schizophrenia or bipolar disorder. It facilitates structured, AI-led voice check-ins to support medication adherence, substance use monitoring, and mental health triage. The app conducts a **two-way voice conversation**, records the full session, and uses AI (GPT-4.1 and Gemini) to assess mental state and escalate if necessary.

---

## 🧠 Clinical Goals

- Encourage **medication adherence**
- Monitor for **substance use** (alcohol, cannabis)
- Detect signs of:
  - **Stress and low mood**
  - **Suicidality**
  - **Paranoia or thought disorder**
  - **Decompensation / incoherence**
- Provide **early warning alerts** to clinicians or carers

---

## 🗣️ Check-In Structure: Two-Way Voice Conversation

### ✳️ Inspired by:
- BASIS-32
- Life Skills Profile
- HoNOS

### 🎤 Conversation Flow (AI asks, user responds)
1. Hi there. Let’s check in — did you take your medication today?
2. What did you get up to today?
3. How has your mood been today?
4. Have you been feeling more stressed than usual?
5. Did you drink alcohol or use cannabis today?
6. Have you had any thoughts of hurting yourself or ending your life?
7. Have you found it hard to get out of bed, eat, or take care of yourself?
8. Did you have any arguments or feel unsafe around others today?
9. Have you had any strange or suspicious thoughts lately?
10. Is there anything else you want to share with me today?

---

## 🧱 Technical Architecture

### 📱 iOS App (Frontend)
| Component            | Tech                        |
|---------------------|-----------------------------|
| UI                  | SwiftUI                     |
| TTS (AI voice)      | `AVSpeechSynthesizer` or ElevenLabs |
| Speech recognition  | `SFSpeechRecognizer` or Whisper |
| Voice recording     | `AVAudioEngine` / `AVCaptureSession` (to mix user + AI audio) |
| Local audio storage | `.m4a` / `.wav`             |
| Upload              | HTTPS to Python backend     |

---

### 🔁 Conversation Engine (On-Device)
1. AI asks a question (via TTS)
2. User speaks response (captured via mic)
3. Transcribed to text using STT
4. Text sent to GPT/Gemini for response/triage
5. AI responds with follow-up question
6. Repeat until all questions complete

All audio (both sides) is recorded and saved locally.

---

## 🧪 Backend (Python Server)

### 🔄 Upload Payload

```json
{
  "audio_url": "...",
  "transcript": "...",
  "session_metadata": {
    "timestamp": "...",
    "user_id": "...",
    "duration_sec": ...
  }
}

### 🧠 AI Analysis via GPT-4.1 + Gemini
Prompt:

plaintext
Copy
Edit
You are a clinical assistant. Based on the transcript below, rate the following from 0–10:

- Stress level
- Mood (0 = sad, 10 = happy)
- Coherence of speech
- Paranoia or suspicious thoughts
- Suicidality
- Alcohol or drug use
- Medication adherence

Return a short summary and triage status: OK / Flag / Urgent.
✅ AI Output Format
json
Copy
Edit
{
  "stress": 7,
  "mood": 4,
  "coherence": 8,
  "paranoia": 2,
  "suicidality": 0,
  "substance_use": 5,
  "med_adherence": 9,
  "summary": "User has mild stress and low mood but no urgent risks.",
  "triage": "Flag"
}
🚨 Triage & Alert Logic
Condition	Action
Any score ≥ 8	Immediate alert
Suicidality ≥ 3	Immediate alert
Coherence < 5	Flag for review
Trend worsens over 3 sessions	Delayed alert
All scores mild/stable	No alert

### Alerts can go to:

Carer/family (email/SMS)

Clinical dashboard

Crisis team (for urgent cases)

### 🗃️ Database Storage
Table	Fields
users	user_id, contact info, risk profile
checkins	timestamp, transcript, triage score JSON, audio URL
alerts	user_id, timestamp, type (urgent/trend), resolution status

### ⏱️ Session Lifecycle
User initiates check-in

Full audio session recorded

Transcript + audio uploaded to backend

AI generates triage data

Risk scored + trend logged

Alert sent if threshold met

### 📦 Future Enhancements
Support real-time voice interaction (streaming STT/LLM)

Use on-device LLMs for privacy-preserving analysis

Sync with HealthKit for mood/sleep correlation

Add motivational video playback if non-adherence detected

Web dashboard for clinicians

### 👩‍💻 Dev Roles (5-Dev Team)
Dev Role	Responsibilities
iOS Dev 1	TTS + STT integration
iOS Dev 2	Voice recording + session control
iOS Dev 3	SwiftUI UI + local storage
Backend Dev	Python API for upload + analysis
AI Engineer	Prompt design + GPT/Gemini integration + risk logic

### ✅ MVP Build Scope
10-question scripted check-in

Voice-to-voice conversation loop

Record full audio session (user + AI)

Transcribe + analyse with GPT/Gemini

Triage + alert trigger
