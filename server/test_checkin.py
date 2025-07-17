import requests

url = "http://localhost:5000/checkin"
file_path = "audio_test.m4a"  # Replace with your actual path

with open(file_path, "rb") as audio:
    files = {
        "audio": (file_path, audio, "audio/m4a")
    }
    data = {
        "user_id": "test_user"
    }

    response = requests.post(url, files=files, data=data)

print("Status:", response.status_code)
print("Response:", response.json())

# from dotenv import load_dotenv
# import os
# import google.generativeai as genai
# load_dotenv()
# genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
# for model in genai.list_models():
#     print(model.name)