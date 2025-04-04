module math.rect;

import math.vec2d;
import raylib.raylib_types : Rectangle;
import std.math.algebraic;

struct Rect {
    double x = 0.0;
    double y = 0.0;
    double width = 0.0;
    double height = 0.0;

    this(double x, double y, double width, double height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    this(Vec2d position, Vec2d size) {
        x = position.x;
        y = position.y;
        width = size.x;
        height = size.y;
    }

    Rectangle toRaylib() {
        return Rectangle(x, y, width, height);
    }
}

/// Check if point is inside rectangle
bool checkCollisionPointRec(Vec2d point, Rect rec) {
    bool collision = false;

    if ((point.x >= rec.x) && (point.x < (rec.x + rec.width)) && (point.y >= rec.y) && (
            point.y < (rec.y + rec.height)))
        collision = true;

    return collision;
}

/// Check collision between two rectangles
bool checkCollisionRecs(Rect rec1, Rect rec2) {
    bool collision = false;

    if ((rec1.x < (rec2.x + rec2.width) && (rec1.x + rec1.width) > rec2.x) &&
        (rec1.y < (rec2.y + rec2.height) && (rec1.y + rec1.height) > rec2.y))
        collision = true;

    return collision;
}

/// Check collision between circle and rectangle
/// NOTE: Reviewed version to take into account corner limit case
bool checkCollisionCircleRec(Vec2d center, double radius, Rect rec) {
    bool collision = false;

    double recCenterX = rec.x + rec.width / 2.0;
    double recCenterY = rec.y + rec.height / 2.0;

    double dx = fabs(center.x - recCenterX);
    double dy = fabs(center.y - recCenterY);

    if (dx > (rec.width / 2.0 + radius)) {
        return false;
    }
    if (dy > (rec.height / 2.0 + radius)) {
        return false;
    }

    if (dx <= (rec.width / 2.0)) {
        return true;
    }
    if (dy <= (rec.height / 2.0)) {
        return true;
    }

    double cornerDistanceSq = (dx - rec.width / 2.0) * (dx - rec.width / 2.0) +
        (
            dy - rec.height / 2.0) * (dy - rec.height / 2.0);

    collision = (cornerDistanceSq <= (radius * radius));

    return collision;
}

/// Get collision rectangle for two rectangles collision
Rect getCollisionRec(Rect rec1, Rect rec2) {
    Rect overlap = Rect();

    double left = (rec1.x > rec2.x) ? rec1.x : rec2.x;
    double right1 = rec1.x + rec1.width;
    double right2 = rec2.x + rec2.width;
    double right = (right1 < right2) ? right1 : right2;
    double top = (rec1.y > rec2.y) ? rec1.y : rec2.y;
    double bottom1 = rec1.y + rec1.height;
    double bottom2 = rec2.y + rec2.height;
    double bottom = (bottom1 < bottom2) ? bottom1 : bottom2;

    if ((left < right) && (top < bottom)) {
        overlap.x = left;
        overlap.y = top;
        overlap.width = right - left;
        overlap.height = bottom - top;
    }

    return overlap;
}
