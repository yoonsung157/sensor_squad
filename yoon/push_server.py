from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, messaging

app = Flask(__name__)

# Firebase Admin SDK 초기화
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# level → topic 매핑
TOPIC_BY_LEVEL = {
    "low": "bin-low",
    "middle": "bin-middle",
    "high": "bin-high",
}

@app.post("/push")
def push():
    data = request.get_json(force=True)

    level = (data.get("level") or "").lower()
    bin_id = data.get("bin_id", "bin-1")

    if level not in TOPIC_BY_LEVEL:
        return jsonify({"ok": False, "error": "level must be low|middle|high"}), 400

    topic = TOPIC_BY_LEVEL[level]

    message = messaging.Message(
        notification=messaging.Notification(
            title=f"쓰레기통 상태: {level.upper()}",
            body=f"{bin_id} 상태가 {level} 단계입니다"
        ),
        topic=topic,
        data={
            "level": level,
            "bin_id": bin_id
        }
    )

    messaging.send(message)

    return jsonify({"ok": True, "topic": topic, "level": level})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=6000)
