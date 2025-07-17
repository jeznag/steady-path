import requests

# url = "http://localhost:5000/checkin"
# file_path = "audio_test.m4a"  # Replace with your actual path

# with open(file_path, "rb") as audio:
#     files = {
#         "audio": (file_path, audio, "audio/m4a")
#     }
#     data = {
#         "user_id": "test_user"
#     }

#     response = requests.post(url, files=files, data=data)

# print("Status:", response.status_code)
# print("Response:", response.json())

url = "http://localhost:5000/next_prompt"

test_cases = [
    {
        "persona": "Bogan Barry",
        "transcript": "Alright mate, yeah I had a few last night, feelin' rough today. Skipped the meds, couldn’t be stuffed."
    },
    {
        "persona": "Calm Carla",
        "transcript": "I’ve just been feeling kind of numb. Not really eating. Just staying in bed most days. Haven’t talked to anyone in a while."
    },
    {
        "persona": "Supportive Sam",
        "transcript": "Hey, yeah, I’ve been trying to keep busy. Went for a walk this morning. Still having trouble sleeping, though. Only got like two hours last night."
    },
    {
        "persona": "Neutral",
        "transcript": "Honestly? I don't really know how I’m doing. Everything just feels heavy. I’ve been missing work and skipping meds."
    }
]

for i, case in enumerate(test_cases):
    response = requests.post(url, json=case)
    print(f"\n🧪 Test Case {i+1}: Persona = {case['persona']}")
    print("Status:", response.status_code)
    print("Response:", response.json())