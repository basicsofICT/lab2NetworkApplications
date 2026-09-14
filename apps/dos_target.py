#!/usr/bin/env python3
"""Lab DoS target: a tiny HTTP service used to observe volumetric flood behavior.

Endpoints:
  GET /       -> increments a request counter, simulates a small processing delay
  GET /stats  -> returns JSON {count, elapsed_seconds, requests_per_second}
  GET /reset  -> resets the counter (useful before re-running a flood test)
"""
from flask import Flask, jsonify
import threading
import time

app = Flask(__name__)
lock = threading.Lock()
state = {"count": 0, "start": time.time()}


@app.route("/")
def index():
    with lock:
        state["count"] += 1
    time.sleep(0.01)  # simulate a resource-constrained backend
    return "OK\n"


@app.route("/stats")
def stats():
    with lock:
        elapsed = max(time.time() - state["start"], 0.001)
        payload = {
            "count": state["count"],
            "elapsed_seconds": round(elapsed, 2),
            "requests_per_second": round(state["count"] / elapsed, 2),
        }
    return jsonify(payload)


@app.route("/reset")
def reset():
    with lock:
        state["count"] = 0
        state["start"] = time.time()
    return "reset\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, threaded=True)
