from flask import Flask, request, jsonify
import sqlite3, os

app = Flask(__name__)
DB = os.getenv("DB_PATH", "jobs.db")

def init_db():
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute("""
        CREATE TABLE IF NOT EXISTS jobs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            company TEXT NOT NULL,
            position TEXT NOT NULL,
            status TEXT NOT NULL
        )
    """)
    conn.commit()
    conn.close()

@app.route("/jobs", methods=["POST"])
def add_job():
    data = request.json
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute(
        "INSERT INTO jobs (company, position, status) VALUES (?, ?, ?)",
        (data["company"], data["position"], data["status"])
    )
    conn.commit()
    conn.close()
    return jsonify({"message": "Job added"}), 201

@app.route("/jobs", methods=["GET"])
def get_jobs():
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute("SELECT * FROM jobs")
    rows = c.fetchall()
    conn.close()
    return jsonify(rows)

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)