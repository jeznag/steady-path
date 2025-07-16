import openai
import os
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

def transcribe_audio(file_path: str) -> str:
    try:
        with open(file_path, "rb") as f:
            transcript_response = openai.Audio.transcribe(
                model="whisper-1",
                file=f,
                language="en"
            )
        return transcript_response["text"]
    except Exception as e:
        print(f"❌ Transcription failed: {e}")
        return "[Transcription error]"
