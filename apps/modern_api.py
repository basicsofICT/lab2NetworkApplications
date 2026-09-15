#!/usr/bin/env python3
"""Lab API for stolen Bearer tokens (Task 10) and IDOR (Task 11).

/oauth/token  issues a Bearer access token (plaintext HTTP)
/api/me       returns a flag only if a valid Authorization: Bearer header is sent
/api/users/<id> is an unauthenticated object lookup (broken object-level auth)
"""
from flask import Flask, jsonify, request
import secrets

app = Flask(__name__)
tokens = {}
FLAG_BEARER = "FLAG{b34r3r_t0k3n_2026}"
FLAG_IDOR = "FLAG{1d0r_b0la_2026}"

USERS = {
    1: {"id": 1, "username": "guest", "email": "guest@lab.local", "notes": "No confidential data."},
    2: {"id": 2, "username": "alice", "email": "alice@lab.local", "notes": FLAG_IDOR},
    3: {"id": 3, "username": "bob", "email": "bob@lab.local", "notes": "Ordinary user."},
}


@app.route("/oauth/token")
def issue_token():
    token = secrets.token_hex(16)
    tokens[token] = "admin"
    return jsonify(
        {"token_type": "Bearer", "access_token": token, "expires_in": 300}
    )


@app.route("/api/me")
def me():
    auth = request.headers.get("Authorization", "")
    if not auth.lower().startswith("bearer "):
        return jsonify({"error": "missing Bearer token"}), 401
    token = auth.split(" ", 1)[1].strip()
    if token not in tokens:
        return jsonify({"error": "invalid token"}), 401
    return jsonify({"user": tokens[token], "flag": FLAG_BEARER})


@app.route("/api/users/<int:user_id>")
def user_record(user_id):
    # VULNERABLE: no authentication and no object-level authorization.
    record = USERS.get(user_id)
    if record is None:
        return jsonify({"error": "not found"}), 404
    return jsonify(record)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5003, threaded=True, use_reloader=False)
