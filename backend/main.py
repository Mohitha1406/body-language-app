from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import cv2
import numpy as np
import tempfile
import os
import urllib.request

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
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
    posture_scores = []
    head_stability = []
    gesture_counts = []
    prev_nose_y = None
    frame_count = 0

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

            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)
            result = landmarker.detect(mp_image)

            if result.pose_landmarks and len(result.pose_landmarks) > 0:
                lm = result.pose_landmarks[0]

                # Shoulder alignment (index 11=left, 12=right)
                left_shoulder = lm[11]
                right_shoulder = lm[12]
                shoulder_diff = abs(left_shoulder.y - right_shoulder.y)
                posture_score = max(0, 1 - shoulder_diff * 10)
                posture_scores.append(posture_score)

                # Head stability (index 0=nose)
                nose = lm[0]
                if prev_nose_y is not None:
                    movement = abs(nose.y - prev_nose_y)
                    head_stability.append(max(0, 1 - movement * 20))
                prev_nose_y = nose.y

                # Gesture proxy: wrist visibility (15=left wrist, 16=right wrist)
                left_wrist = lm[15]
                right_wrist = lm[16]
                wrists_visible = (left_wrist.visibility > 0.5) or (right_wrist.visibility > 0.5)
                gesture_counts.append(1 if wrists_visible else 0)

    cap.release()

    posture = np.mean(posture_scores) * 100 if posture_scores else 50
    head = np.mean(head_stability) * 100 if head_stability else 50
    gesture_ratio = np.mean(gesture_counts) * 100 if gesture_counts else 50

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
        "tips": tips
    }

@app.get("/")
def root():
    return {"status": "Body Language AI backend running"}

@app.post("/analyze")
async def analyze(video: UploadFile = File(...)):
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
        tmp.write(await video.read())
        tmp_path = tmp.name
    try:
        result = analyze_video(tmp_path)
        return result
    finally:
        os.unlink(tmp_path)