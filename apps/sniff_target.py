#!/usr/bin/env python3
"""Lab sniffing target: plaintext HTTP so students can recover a flag from a packet capture."""
from flask import Flask

app = Flask(__name__)
FLAG = "FLAG{tr4ff1c_sn1ff_2026}"


@app.route("/")
def index():
    return f"Confidential sniff token: {FLAG}\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081, threaded=True, use_reloader=False)
