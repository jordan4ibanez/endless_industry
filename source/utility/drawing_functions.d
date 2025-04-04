module utility.drawing_functions;

import math.vec2d;

Vec2d centerCollisionbox(Vec2d position, Vec2d size) {
    Vec2d newPosition = position;
    newPosition.x -= size.x * 0.5;
    newPosition.y += size.y * 0.5;
    return newPosition;
}
