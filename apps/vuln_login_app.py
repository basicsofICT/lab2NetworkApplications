#!/usr/bin/env python3
"""Lab SQL injection target: deliberately vulnerable to numeric SQL injection.

GET /user?id=<n> builds its query with plain string concatenation, so an
attacker can inject a UNION SELECT to dump every row (including password
hashes) from the users table. The admin password hash is generated at
container setup time by .devcontainer/setup.sh (SHA-512 crypt, same format
used in Task 1) and stored in apps/.sqli_admin_hash (not committed to git).
"""
from flask import Flask, request, jsonify
import sqlite3
import os

DB_PATH = "/tmp/vuln_users.db"
HASH_FILE = os.path.join(os.path.dirname(__file__), ".sqli_admin_hash")


def load_admin_hash():
    if os.path.exists(HASH_FILE):
        with open(HASH_FILE) as f:
            return f.read().strip()
    # Fallback so the app still runs if setup.sh hasn't generated the hash yet.
    return "$6$sqlisalt$invalidhash"


def init_db():
    admin_hash = load_admin_hash()
    conn = sqlite3.connect(DB_PATH)
    conn.execute("DROP TABLE IF EXISTS users")
    conn.execute(
        "CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password_hash TEXT)"
    )
    conn.execute(
        "INSERT INTO users (id, username, password_hash) VALUES (1, 'guest', 'not-a-real-hash')"
    )
    conn.execute(
        "INSERT INTO users (id, username, password_hash) VALUES (2, 'admin', ?)",
        (admin_hash,),
    )
    conn.commit()
    conn.close()


app = Flask(__name__)
init_db()


@app.route("/user")
def user_lookup():
    user_id = request.args.get("id", "1")
    conn = sqlite3.connect(DB_PATH)
    # VULNERABLE: user input is concatenated directly into the SQL string.
    query = f"SELECT id, username, password_hash FROM users WHERE id={user_id}"
    try:
        rows = conn.execute(query).fetchall()
    except sqlite3.Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()
    return jsonify(
        [{"id": r[0], "username": r[1], "password_hash": r[2]} for r in rows]
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, threaded=True, use_reloader=False)
