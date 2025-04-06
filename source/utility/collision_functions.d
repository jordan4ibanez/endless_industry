module utility.collision_functions;

import math.rect;
import math.vec2d;
import std.math.traits : sgn;
import std.stdio;

enum CollisionAxis {
    X,
    Y
}

struct CollisionResult {
    bool collides = false;
    double newPosition = 0;
    bool hitGround = false;
}

// This basically shoves the entity out of the tile.
//? Note: This will have issues extremely far out.
private immutable double magicAdjustment = 0.0001;

// CollisionResult collideXToTile(Vec2d entityPosition, Vec2d entitySize, Vec2d entityVelocity,
//     Vec2d tilePosition, Vec2d tileSize) {

//     CollisionResult result;
//     result.newPosition = entityPosition.x;

//     int dir = cast(int) sgn(entityVelocity.x);

//     // This thing isn't moving.
//     if (dir == 0) {
//         return result;
//     }

//     // Entity position is on the bottom center of the collisionbox.
//     const double entityHalfWidth = entitySize.x * 0.5;
//     const Rect entityRectangle = Rect(entityPosition.x - entityHalfWidth, entityPosition.y,
//         entitySize.x, entitySize.y);

//     const Rect tileRectangle = Rect(tilePosition.x, tilePosition.y, tileSize.x, tileSize.y);

//     if (checkCollisionRecs(entityRectangle, tileRectangle)) {
//         // This doesn't kick out in a specific direction on dir 0 because the Y axis check will kick them up as a safety.
//         result.collides = true;
//         if (dir > 0) {
//             // Kick left.
//             result.newPosition = tilePosition.x - entityHalfWidth - magicAdjustment;
//         } else if (dir < 0) {
//             // Kick right.
//             result.newPosition = tilePosition.x + tileSize.x + entityHalfWidth + magicAdjustment;
//         }
//     }

//     return result;
// }

// CollisionResult collideYToTile(Vec2d entityPosition, Vec2d entitySize, Vec2d entityVelocity,
//     Vec2d tilePosition, Vec2d tileSize) {

//     CollisionResult result;
//     result.newPosition = entityPosition.y;

//     int dir = cast(int) sgn(entityVelocity.y);

//     // This thing isn't moving.
//     if (dir == 0) {
//         return result;
//     }

//     // Entity position is on the bottom center of the collisionbox.
//     const double entityHalfWidth = entitySize.x * 0.5;
//     const Rect entityRectangle = Rect(entityPosition.x - entityHalfWidth, entityPosition.y,
//         entitySize.x, entitySize.y);

//     const Rect tileRectangle = Rect(tilePosition.x, tilePosition.y, tileSize.x, tileSize.y);

//     if (checkCollisionRecs(entityRectangle, tileRectangle)) {

//         result.collides = true;
//         if (dir <= 0) {
//             // Kick up. This is the safety default.
//             result.newPosition = tilePosition.y + tileSize.y + magicAdjustment;
//             result.hitGround = true;
//         } else {
//             // Kick down.
//             result.newPosition = tilePosition.y - entitySize.y - magicAdjustment;
//         }
//     }

//     return result;
// }
