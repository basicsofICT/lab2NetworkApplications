#!/usr/bin/env python3
"""Lab session-hijacking target.

/login   issues a session cookie for the given ?user= (plaintext HTTP, no TLS)
/account returns a confidential flag ONLY if a valid session cookie is presented
/logout  invalidates a session cookie

A companion script (simulate_admin.sh) periodically logs in as "admin" to
generate realistic session traffic on the wire for students to capture.
"""
from flask import Flask, request, make_response
import secrets

app = Flask(__name__)
valid_tokens = {}
FLAG = "FLAG{s3ss10n_hijack_2026}"


@app.route("/login")
def login():
    user = request.args.get("user", "guest")
    token = secrets.token_hex(8)
    valid_tokens[token] = user
    resp = make_response(f"Logged in as {user}\n")
    resp.set_cookie("session", token)
    return resp


@app.route("/account")
def account():
    token = request.cookies.get("session")
    user = valid_tokens.get(token)
    if not user:
        return "Access denied: no valid session cookie\n", 403
    return f"Welcome back, {user}! Confidential flag: {FLAG}\n"


@app.route("/logout")
def logout():
    token = request.cookies.get("session")
    valid_tokens.pop(token, None)
    return "Logged out\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, threaded=True, use_reloader=False)
