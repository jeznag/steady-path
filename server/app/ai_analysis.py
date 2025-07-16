import openai
import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

openai.api_key = os.getenv("OPENAI_API_KEY")
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

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

def analyze_with_gpt(transcript: str) -> dict:
    prompt = PROMPT_TEMPLATE.format(transcript=transcript)
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3
        )
        return response.choices[0].message["content"]
    except Exception as e:
        print(f"GPT analysis failed: {e}")
        return "{}"

def analyze_with_gemini(transcript: str) -> dict:
    prompt = PROMPT_TEMPLATE.format(transcript=transcript)
    try:
        model = genai.GenerativeModel("gemini-pro")
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        print(f"Gemini analysis failed: {e}")
        return "{}"

def analyze_transcript(transcript: str) -> dict:
    gpt_result = analyze_with_gpt(transcript)
    gemini_result = analyze_with_gemini(transcript)

    # For now, return GPT result only — can merge later if needed
    return {
        "gpt": gpt_result,
        "gemini": gemini_result
    }
