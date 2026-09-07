import cv2

print("OpenCV version:", cv2.__version__)

cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("ERROR: Could not open the webcam.")
    exit()

print("Webcam opened successfully!")
print("Press Q to quit.")

while True:
    ret, frame = cap.read()

    if not ret:
        print("ERROR: Could not read frame.")
        break

    cv2.imshow("Webcam Test", frame)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cap.release()
cv2.destroyAllWindows()