from fastapi import FastAPI, File, UploadFile, Request
from fastapi.middleware.cors import CORSMiddleware
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import cv2
import numpy as np
import tempfile
import os
import urllib.request
import base64
from typing import Optional

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_PATH = "pose_landmarker.task"
if not os.path.exists(MODEL_PATH):
    print("Downloading pose model...")
    urllib.request.urlretrieve(
        "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/latest/pose_landmarker_lite.task",
        MODEL_PATH
    )
    print("Model downloaded.")


def analyze_video(video_path):
    cap = cv2.VideoCapture(video_path)
    cap.set(cv2.CAP_PROP_ORIENTATION_AUTO, 1)

    posture_scores = []
    head_stability = []
    gesture_counts = []
    prev_nose_y = None
    frame_count = 0
    total_processed = 0

    base_options = python.BaseOptions(model_asset_path=MODEL_PATH)
    options = vision.PoseLandmarkerOptions(
        base_options=base_options,
        output_segmentation_masks=False
    )

    with vision.PoseLandmarker.create_from_options(options) as landmarker:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            frame_count += 1
            if frame_count % 3 != 0:
                continue

            total_processed += 1
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)
            result = landmarker.detect(mp_image)

            if result.pose_landmarks and len(result.pose_landmarks) > 0:
                lm = result.pose_landmarks[0]
                left_shoulder = lm[11]
                right_shoulder = lm[12]
                shoulder_diff = abs(left_shoulder.y - right_shoulder.y)
                posture_score = max(0, 1 - shoulder_diff * 10)
                posture_scores.append(posture_score)

                nose = lm[0]
                if prev_nose_y is not None:
                    movement = abs(nose.y - prev_nose_y)
                    head_stability.append(max(0, 1 - movement * 20))
                prev_nose_y = nose.y

                left_wrist = lm[15]
                right_wrist = lm[16]
                wrists_visible = (left_wrist.visibility > 0.5) or (right_wrist.visibility > 0.5)
                gesture_counts.append(1 if wrists_visible else 0)

    cap.release()

    if not posture_scores:
        return {
            "confidence_score": 0.0,
            "posture_score": 0.0,
            "head_stability_score": 0.0,
            "gesture_score": 0.0,
            "debug_frames_processed": total_processed,
            "person_detected": False,
            "tips": [
                "No person detected in the video frame.",
                "Please stand clearly in front of the camera.",
                "Make sure your upper body and head are visible in good lighting."
            ]
        }

    posture = np.mean(posture_scores) * 100
    head = np.mean(head_stability) * 100 if head_stability else 50.0
    gesture_ratio = np.mean(gesture_counts) * 100

    confidence = (posture * 0.4) + (head * 0.3) + (gesture_ratio * 0.3)
    confidence = round(min(max(confidence, 10), 98), 1)

    tips = []
    if posture < 60:
        tips.append("Keep your shoulders level and back straight while presenting.")
    else:
        tips.append("Great posture! Your shoulders are well-aligned.")
    if head < 60:
        tips.append("Try to reduce head movement — steady eye contact builds confidence.")
    else:
        tips.append("Good head stability. You maintain a steady presence.")
    if gesture_ratio < 30:
        tips.append("Use more hand gestures to emphasize your key points.")
    elif gesture_ratio > 80:
        tips.append("Slightly reduce hand movement to avoid distracting the audience.")
    else:
        tips.append("Your hand gestures are natural and engaging.")

    return {
        "confidence_score": confidence,
        "posture_score": round(posture, 1),
        "head_stability_score": round(head, 1),
        "gesture_score": round(gesture_ratio, 1),
        "debug_frames_processed": total_processed,
        "person_detected": True,
        "tips": tips
    }


@app.get("/")
def root():
    return {"status": "ConfidAI backend running"}


@app.post("/analyze")
async def analyze(request: Request, video: Optional[UploadFile] = File(None)):
    video_bytes = None
    if video is not None:
        try:
            video_bytes = await video.read()
        except Exception:
            video_bytes = None

    if not video_bytes:
        try:
            body = await request.json()
            if isinstance(body, dict) and "video_bytes" in body:
                raw_b64 = body["video_bytes"]
                if "," in raw_b64:
                    raw_b64 = raw_b64.split(",", 1)[1]
                video_bytes = base64.b64decode(raw_b64)
        except Exception as e:
            print(f"Error parsing JSON body: {e}")

    if not video_bytes:
        return {
            "confidence_score": 0.0,
            "posture_score": 0.0,
            "head_stability_score": 0.0,
            "gesture_score": 0.0,
            "person_detected": False,
            "tips": [
                "No video data received.",
                "Please verify your camera feed and try recording again."
            ]
        }

    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
        tmp.write(video_bytes)
        tmp_path = tmp.name

    try:
        result = analyze_video(tmp_path)
        return result
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)