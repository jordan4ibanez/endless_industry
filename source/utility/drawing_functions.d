module utility.drawing_functions;

import math.vec2d;

/// This takes the game coordinates and shifts it to be drawn by raylib for a rectangle.
Vec2d centerCollisionboxBottom(Vec2d position, Vec2d size) {
    Vec2d newPosition = position;
    newPosition.x -= size.x * 0.5;
    newPosition.y += size.y;
    return newPosition;
}
