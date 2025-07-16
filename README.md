# 🧠 Project Overview: SteadyPath
SteadyPath is an iOS app that helps people with schizophrenia or bipolar disorder stay on track with medication, monitor mental wellbeing, and receive AI-guided support. It combines:

📹 Video-confirmed medication adherence

🤖 AI conversation check-ins

🧠 Substance use + mood triage

🚨 Escalation system for crisis situations

🛡️ Privacy-first design leveraging Apple Intelligence

🧱 Architecture Overview
⚙️ Frontend: iOS App
Framework: SwiftUI + Combine

Apple Intelligence:

On-device LLM API (for AI conversation + triage)

Core ML + VisionKit for video analysis (pill-taking)

HealthKit integration (mood tracking, sleep, etc.)

AVFoundation: record/preview video for med ingestion

FaceID / Secure Enclave: protect sensitive content

Push Notifications: for check-in reminders + alerts

☁️ Backend (if needed)
While most logic stays on-device, some minimal cloud infra may be needed:

API Gateway + Backend

Auth (e.g. Firebase Auth or Sign in with Apple)

Encrypted cloud sync for:

Check-in logs (optional)

Escalation triggers

Clinician access portal (if applicable)

DB: Firebase Firestore or PostgreSQL

Serverless Functions: For handling escalations (e.g. notify carer / crisis line)

🧰 AI Components
Triage NLP Engine (on-device)

Detects keywords/patterns for:

Missed meds

Risky substance use

Self-harm / relapse

Provides a risk score and maps to escalation level

Conversational AI Companion

Motivational interviewing style

Reflective listening

Pulls in personalised video clips if needed

🧩 Key Features Breakdown
Feature	Description	Tools / APIs
✅ Daily AI Check-In	Conversational chatbot asks about meds, mood, and substance use	Apple LLM API / on-device
📹 Med Adherence Confirmation	Record + analyse pill-taking	VisionKit + Core ML
🧠 Mood + Substance Log	Track daily states, optional journaling	HealthKit + SwiftUI
🧷 Escalation Engine	Multi-tier triage: carer, crisis line, 000	On-device + optional backend
🔁 Motivation Video Loop	Watch pre-recorded messages when feeling unwell	Local storage + media player
🔒 Privacy & Security	No cloud storage of video unless user consents	FaceID, App Group Keychain

