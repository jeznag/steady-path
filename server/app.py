from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os
from app.audio_utils import transcribe_audio
from app.ai_analysis import analyze_transcript
from app.db import save_checkin, init_db

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

app = Flask(__name__)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

init_db()

@app.route("/checkin", methods=["POST"])
def handle_checkin():
    print("FILES RECEIVED:", request.files.keys())
    audio_file = request.files.get("audio")
    user_id = request.form.get("user_id", "anonymous")

    if not audio_file:
        return jsonify({"error": "Missing audio file"}), 400

    filename = secure_filename(audio_file.filename)
    file_path = os.path.join(app.config["UPLOAD_FOLDER"], filename)
    audio_file.save(file_path)

    # Transcribe
    transcript = transcribe_audio(file_path)

    # Analyze
    result = analyze_transcript(transcript)

    # Save to DB
    save_checkin(user_id=user_id, transcript=transcript, analysis=result)

    return jsonify({
        "user_id": user_id,
        "transcript": transcript,
        "analysis": result
    })

if __name__ == "__main__":
    init_db()
    app.run(debug=True, host="0.0.0.0", port=5000)
