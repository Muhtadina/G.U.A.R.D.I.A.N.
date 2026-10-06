import math


def distance(p1, p2):
    """Calculate Euclidean distance between two points."""

    return math.sqrt(
        (p1[0] - p2[0]) ** 2 +
        (p1[1] - p2[1]) ** 2
    )


def calculate_ear(landmarks, eye_points):
    """
    Calculate Eye Aspect Ratio (EAR).

    eye_points:
        [p1, p2, p3, p4, p5, p6]

    p1 and p4 = horizontal eye corners
    p2, p3, p5, p6 = vertical eye points
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

    if horizontal == 0:
        return 0.0

    ear = (vertical_1 + vertical_2) / (
        2.0 * horizontal
    )

    return ear
