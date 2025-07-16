import os
from dotenv import load_dotenv
from openai import OpenAI
import google.generativeai as genai

load_dotenv()

# OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Gemini client
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

import re
import json

def extract_json(text):
    match = re.search(r"```json(.*?)```", text, re.DOTALL)
    if match:
        return json.dumps(json.loads(match.group(1).strip()))
    try:
        return json.dumps(json.loads(text))
    except:
        return {}

PROMPT_TEMPLATE = """
You are a clinical assistant. Analyze the following check-in conversation transcript.
Respond with a JSON object that includes:

- stress (0–10)
- mood (0–10, where 0 = sad, 10 = happy)
- coherence (0–10)
- paranoia (0–10)
- suicidality (0–10)
- substance_use (0–10)
- med_adherence (0–10)
- summary (1 sentence)
- triage: "OK", "Flag", or "Urgent"

Transcript:
---
{transcript}
---
"""

def analyze_with_gpt(transcript: str) -> str:
    prompt = PROMPT_TEMPLATE.format(transcript=transcript)
    try:
        response = client.chat.completions.create(
            model="gpt-4.1",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3
        )
        return response.choices[0].message.content
    except Exception as e:
        print(f"❌ GPT analysis failed: {e}")
        return "{}"

def analyze_with_gemini(transcript: str) -> str:
    prompt = PROMPT_TEMPLATE.format(transcript=transcript)
    try:
        model = genai.GenerativeModel("gemini-2.5-pro")

        response = model.generate_content(prompt)
        return extract_json(response.text)

    except Exception as e:
        print(f"❌ Gemini analysis failed: {e}")
        return "{}"

def analyze_transcript(transcript: str) -> dict:
    gpt_result = analyze_with_gpt(transcript)
    gemini_result = analyze_with_gemini(transcript)

    return {
        "gpt": gpt_result,
        "gemini": gemini_result
    }

def get_next_prompt(transcript: str, persona: str) -> dict:
    prompt = f"""
You are a mental health check-in assistant using the persona "{persona}".
You're chatting informally to assess the person's current mental state and risk level.

Your goals:
1. Validate what the user just said in a **natural and persona-appropriate** way.
2. Ask the next question that helps assess mental health and risk — picking from the list below, **only if it hasn't already been answered**.
3. The tone and vocabulary must fully reflect the chosen persona. Don't just be generic.

Personas and tone examples:
- Bogan Barry: rough, casual, Aussie slang ("bit cooked", "fair dinkum", "no dramas mate")
- Calm Carla: gentle, validating, slow and warm ("That sounds tough", "You're doing your best")
- Supportive Sam: friendly, upbeat ("Thanks for telling me that", "Good on you for checking in")
- Neutral: professional, clear, no slang ("Thanks for sharing that. Let’s keep going.")

Here's your checklist of questions (only ask one at a time):
1. How are you feeling overall?
2. What have you been up to today?
3. Did you take your meds today?
4. How’s your sleep been lately?
5. Been eating alright?
6. Had any drinks or anything else?
7. Feeling paranoid or a bit on edge?
8. Been having trouble concentrating or thinking clearly?
9. Feeling like yourself, or a bit off?
10. Had any dark thoughts or thoughts of not wanting to be here?
11. Feeling safe right now?
12. Been keeping in touch with mates/family?
13. How’s work or study going?
14. Anything feeling too much or overwhelming?
15. Are you taking your meds most days or missing them a bit?

Each time, respond in this format:

The app will read out the validation first and then the next prompt. Make sure the next prompt flows naturally from the validation statement.

{{
  "validation": "brief, persona-appropriate comment validating what the user said",
  "next_prompt": "the next most relevant, not-yet-asked question from the list - make it sound natural - it should flow from the validation statement."
}}

Transcript so far:
{transcript}
"""
    try:
        response = client.chat.completions.create(
            model="gpt-4.1",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.9
        )
        return json.loads(extract_json(response.choices[0].message.content))
    except Exception as e:
        print(f"❌ Failed to generate next prompt: {e}")
        return {"validation": "", "next_prompt": ""}
    