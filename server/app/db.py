import sqlite3
import os
import json

DB_FILE = os.getenv("DATABASE_URL", "steadypath.db").replace("sqlite:///", "")

def init_db():
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute("""
        CREATE TABLE IF NOT EXISTS checkins (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            transcript TEXT,
            gpt_analysis TEXT,
            gemini_analysis TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

def save_checkin(user_id: str, transcript: str, analysis: dict):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute("""
        INSERT INTO checkins (user_id, transcript, gpt_analysis, gemini_analysis)
        VALUES (?, ?, ?, ?)
    """, (
        user_id,
        transcript,
        analysis.get("gpt", "{}"),
        analysis.get("gemini", "{}")
    ))
    conn.commit()
    conn.close()
