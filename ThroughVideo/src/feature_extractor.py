import math


def distance(p1, p2):
    """
    Euclidean distance between two landmark points.
    """

    return math.sqrt(
        (p1[0] - p2[0]) ** 2 +
        (p1[1] - p2[1]) ** 2
    )


def calculate_ear(landmarks, eye_points):
    """
    Calculate Eye Aspect Ratio (EAR).

    eye_points:
        [p1, p2, p3, p4, p5, p6]
    """

    p1 = landmarks[eye_points[0]]
    p2 = landmarks[eye_points[1]]
    p3 = landmarks[eye_points[2]]
    p4 = landmarks[eye_points[3]]
    p5 = landmarks[eye_points[4]]
    p6 = landmarks[eye_points[5]]

    vertical_1 = distance(p2, p6)
    vertical_2 = distance(p3, p5)

    horizontal = distance(p1, p4)

    ear = (vertical_1 + vertical_2) / (2.0 * horizontal)

    return ear


def calculate_mar(landmarks, mouth_points):
    """
    Calculate Mouth Aspect Ratio (MAR).

    mouth_points:
        [left, top1, top2, right, bottom2, bottom1]
    """

    left = landmarks[mouth_points[0]]
    top_1 = landmarks[mouth_points[1]]
    top_2 = landmarks[mouth_points[2]]
    right = landmarks[mouth_points[3]]
    bottom_2 = landmarks[mouth_points[4]]
    bottom_1 = landmarks[mouth_points[5]]

    vertical_1 = distance(top_1, bottom_1)
    vertical_2 = distance(top_2, bottom_2)

    horizontal = distance(left, right)

    mar = (vertical_1 + vertical_2) / (2.0 * horizontal)

    return mar