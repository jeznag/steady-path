import os
from dotenv import load_dotenv
from openai import OpenAI
load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def transcribe_audio(file_path: str) -> str:
    with open(file_path, "rb") as f:
        response = client.audio.transcriptions.create(
            model="whisper-1",
            file=f,
            language="en"
        )
    return response.text
