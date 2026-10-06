
import cv2
import mediapipe as mp

from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from feature_extractor import calculate_ear


MODEL_PATH = "models/face_landmarker.task"

# MediaPipe eye landmark indices
RIGHT_EYE = [33, 160, 158, 133, 153, 144]
LEFT_EYE = [263, 387, 385, 362, 380, 373]

latest_result = None


def print_result(result, output_image, timestamp_ms):
    global latest_result
    latest_result = result


# --------------------------------------------------
# MediaPipe configuration
# --------------------------------------------------

base_options = python.BaseOptions(
    model_asset_path=MODEL_PATH
)

options = vision.FaceLandmarkerOptions(
    base_options=base_options,
    running_mode=vision.RunningMode.LIVE_STREAM,
    num_faces=1,
    output_face_blendshapes=True,
    output_facial_transformation_matrixes=True,
    result_callback=print_result
)


# --------------------------------------------------
# Start Face Landmarker
# --------------------------------------------------

with vision.FaceLandmarker.create_from_options(options) as landmarker:

    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("ERROR: Could not open webcam.")
        exit()

    print("Camera started.")
    print("Press Q inside the camera window to quit.")

    timestamp_ms = 0

    while True:

        ret, frame = cap.read()

        if not ret:
            print("ERROR: Could not read frame.")
            break

        height, width, _ = frame.shape

        # --------------------------------------------------
        # OpenCV BGR → RGB
        # --------------------------------------------------

        rgb_frame = cv2.cvtColor(
            frame,
            cv2.COLOR_BGR2RGB
        )

        # --------------------------------------------------
        # Create MediaPipe image
        # --------------------------------------------------

        mp_image = mp.Image(
            image_format=mp.ImageFormat.SRGB,
            data=rgb_frame
        )

        # --------------------------------------------------
        # Send frame to MediaPipe
        # --------------------------------------------------

        landmarker.detect_async(
            mp_image,
            timestamp_ms
        )

        timestamp_ms += 33

        # --------------------------------------------------
        # Process detected face
        # --------------------------------------------------

        if latest_result is not None:

            for face_landmarks in latest_result.face_landmarks:

                # --------------------------------------------------
                # Convert ALL normalized landmarks → pixel coordinates
                # --------------------------------------------------

                points = []

                for landmark in face_landmarks:

                    x = int(landmark.x * width)
                    y = int(landmark.y * height)

                    points.append((x, y))

                # --------------------------------------------------
                # Calculate EAR AFTER all landmarks are collected
                # --------------------------------------------------

                right_ear = calculate_ear(
                    points,
                    RIGHT_EYE
                )

                left_ear = calculate_ear(
                    points,
                    LEFT_EYE
                )

                average_ear = (
                    right_ear + left_ear
                ) / 2.0

                # --------------------------------------------------
                # Display EAR values
                # --------------------------------------------------

                cv2.putText(
                    frame,
                    f"Right EAR: {right_ear:.3f}",
                    (20, 40),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 255, 0),
                    2
                )

                cv2.putText(
                    frame,
                    f"Left EAR: {left_ear:.3f}",
                    (20, 70),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 255, 0),
                    2
                )

                cv2.putText(
                    frame,
                    f"Average EAR: {average_ear:.3f}",
                    (20, 100),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 255, 0),
                    2
                )

                # --------------------------------------------------
                # Draw official MediaPipe face connections
                # --------------------------------------------------

                for connection in (
                    vision.FaceLandmarksConnections.FACE_LANDMARKS_CONTOURS
                ):

                    start = connection.start
                    end = connection.end

                    if (
                        start < len(points)
                        and end < len(points)
                    ):

                        cv2.line(
                            frame,
                            points[start],
                            points[end],
                            (0, 255, 0),
                            1
                        )

        # --------------------------------------------------
        # Display
        # --------------------------------------------------

        cv2.imshow(
            "MediaPipe Face Mesh",
            frame
        )

        # --------------------------------------------------
        # Q to quit
        # --------------------------------------------------

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    cap.release()
    cv2.destroyAllWindows()

import cv2
import mediapipe as mp

from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from feature_extractor import calculate_ear


MODEL_PATH = "models/face_landmarker.task"

# MediaPipe eye landmark indices
RIGHT_EYE = [33, 160, 158, 133, 153, 144]
LEFT_EYE = [263, 387, 385, 362, 380, 373]

latest_result = None


def print_result(result, output_image, timestamp_ms):
    global latest_result
    latest_result = result


# --------------------------------------------------
# MediaPipe configuration
# --------------------------------------------------

base_options = python.BaseOptions(
    model_asset_path=MODEL_PATH
)

options = vision.FaceLandmarkerOptions(
    base_options=base_options,
    running_mode=vision.RunningMode.LIVE_STREAM,
    num_faces=1,
    output_face_blendshapes=True,
    output_facial_transformation_matrixes=True,
    result_callback=print_result
)


# --------------------------------------------------
# Start Face Landmarker
# --------------------------------------------------

with vision.FaceLandmarker.create_from_options(options) as landmarker:

    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("ERROR: Could not open webcam.")
        exit()

    print("Camera started.")
    print("Press Q inside the camera window to quit.")

    timestamp_ms = 0

    while True:

        ret, frame = cap.read()

        if not ret:
            print("ERROR: Could not read frame.")
            break

        height, width, _ = frame.shape

        # --------------------------------------------------
        # OpenCV BGR → RGB
        # --------------------------------------------------

        rgb_frame = cv2.cvtColor(
            frame,
            cv2.COLOR_BGR2RGB
        )

        # --------------------------------------------------
        # Create MediaPipe image
        # --------------------------------------------------

        mp_image = mp.Image(
            image_format=mp.ImageFormat.SRGB,
            data=rgb_frame
        )

        # --------------------------------------------------
        # Send frame to MediaPipe
        # --------------------------------------------------

        landmarker.detect_async(
            mp_image,
            timestamp_ms
        )

        timestamp_ms += 33

        # --------------------------------------------------
        # Process detected face
        # --------------------------------------------------

        if latest_result is not None:

            for face_landmarks in latest_result.face_landmarks:

                # --------------------------------------------------
                # Convert ALL normalized landmarks → pixel coordinates
                # --------------------------------------------------

                points = []

                for landmark in face_landmarks:

                    x = int(landmark.x * width)
                    y = int(landmark.y * height)

                    points.append((x, y))

                # --------------------------------------------------
                # Calculate EAR AFTER all landmarks are collected
                # --------------------------------------------------

                right_ear = calculate_ear(
                    points,
                    RIGHT_EYE
                )

                left_ear = calculate_ear(
                    points,
                    LEFT_EYE
                )

                average_ear = (
                    right_ear + left_ear
                ) / 2.0

                # --------------------------------------------------
                # Display EAR values
                # --------------------------------------------------

                cv2.putText(
                    frame,
                    f"Right EAR: {right_ear:.3f}",
                    (20, 40),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 255, 0),
                    2
                )

                cv2.putText(
                    frame,
                    f"Left EAR: {left_ear:.3f}",
                    (20, 70),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 255, 0),
                    2
                )

                cv2.putText(
                    frame,
                    f"Average EAR: {average_ear:.3f}",
                    (20, 100),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 255, 0),
                    2
                )

                # --------------------------------------------------
                # Draw official MediaPipe face connections
                # --------------------------------------------------

                for connection in (
                    vision.FaceLandmarksConnections.FACE_LANDMARKS_CONTOURS
                ):

                    start = connection.start
                    end = connection.end

                    if (
                        start < len(points)
                        and end < len(points)
                    ):

                        cv2.line(
                            frame,
                            points[start],
                            points[end],
                            (0, 255, 0),
                            1
                        )

        # --------------------------------------------------
        # Display
        # --------------------------------------------------

        cv2.imshow(
            "MediaPipe Face Mesh",
            frame
        )

        # --------------------------------------------------
        # Q to quit
        # --------------------------------------------------

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    cap.release()
    cv2.destroyAllWindows()
