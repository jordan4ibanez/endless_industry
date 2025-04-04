module game.player;

import controls.keyboard;
import game.map;
import graphics.colors;
import graphics.render;
import graphics.texture_handler;
import math.rect;
import math.vec2d;
import math.vec2i;
import raylib : DEG2RAD, PI, RAD2DEG;
import std.math.algebraic : abs;
import std.math.rounding;
import std.math.traits : sgn;
import std.math.trigonometry;
import std.stdio;
import utility.collision_functions;
import utility.delta;
import utility.drawing_functions;

static final const class Player {
static:
private:

    Vec2d size = Vec2d(0.6, 1.8);
    Vec2d position = Vec2d(0, 0);
    Vec2d velocity = Vec2d(0, 0);
    Vec2i inChunk = Vec2i(int.max, int.max);
    bool firstGen = true;
    bool jumpQueued = false;
    bool inJump = false;
    double rotation = 0;
    bool moving = false;

public: //* BEGIN PUBLIC API.

    Vec2d getSize() {
        return size;
    }

    Vec2d getPosition() {
        return position;
    }

    double getWidth() {
        return size.y;
    }

    double getHalfWidth() {
        return size.x * 0.5;
    }

    Vec2d getVelocity() {
        return velocity;
    }

    void setPosition(Vec2d newPosition) {
        position = newPosition;
    }

    void setVelocity(Vec2d newVelocity) {
        velocity = newVelocity;
    }

    Rect getRectangle() {
        Vec2d centeredPosition = centerCollisionboxBottom(position, size);
        return Rect(centeredPosition.x, centeredPosition.y, size.x, size.y);
    }

    void draw() {

        double delta = Delta.getDelta();
        // rotation += delta * 230.0;
        immutable double scale = 0.05625;

        immutable double centerX = size.x * 0.5;

        immutable double DOUBLE_PI = PI * 2;
        immutable double QUARTER_PI = PI * 0.25;
        immutable double HALF_PI = PI * 0.5;

        immutable double speedMultiplier = 4;

        // writeln(abs(velocity.x * delta));
        if (abs(velocity.x * delta) <= 0.00001 || !moving) {

            if (rotation == 0) {
                // do nothing.
            } else if (rotation > QUARTER_PI) {
                rotation += delta * speedMultiplier;
                if (rotation >= PI) {
                    rotation = 0;
                }
            } else if (rotation > 0) {
                rotation -= delta * speedMultiplier;

                if (rotation <= 0) {
                    rotation = 0;
                }
            } else if (rotation < -QUARTER_PI) {
                rotation -= delta * speedMultiplier;
                if (rotation <= -PI) {
                    rotation = 0;
                }
            } else if (rotation < 0) {
                rotation += delta * speedMultiplier;
                if (rotation >= 0) {
                    rotation = 0;
                }
            }
        } else {
            rotation += abs(velocity.x) * (delta * 2.0);
        }

        if (rotation < -PI) {
            rotation += DOUBLE_PI;
        } else if (rotation > PI) {
            rotation -= DOUBLE_PI;
        }

        double animationRotation = sin(rotation) * RAD2DEG;

        Render.rectangleLines(centerCollisionboxBottom(position, size), size, Colors.WHITE);
    }

    void move() {
        double delta = Delta.getDelta();

        immutable double acceleration = 20;
        immutable double deceleration = 25;

        // writeln(velocity.x);

        moving = false;

        //? Controls first.
        // if (Keyboard.isDown(KeyboardKey.KEY_D)) {
        //     direction = Direction.Right;
        //     moving = true;
        //     if (sgn(velocity.x) < 0) {
        //         skidding = true;
        //         velocity.x += delta * deceleration;
        //     } else {
        //         velocity.x += delta * acceleration;
        //     }
        // } else if (Keyboard.isDown(KeyboardKey.KEY_A)) {
        //     direction = Direction.Left;
        //     moving = true;
        //     if (sgn(velocity.x) > 0) {
        //         skidding = true;
        //         velocity.x -= delta * deceleration;
        //     } else {
        //         velocity.x -= delta * acceleration;
        //     }
        // } else {
        //     if (abs(velocity.x) > delta * deceleration) {
        //         double valSign = sgn(velocity.x);
        //         velocity.x = (abs(velocity.x) - (delta * deceleration)) * valSign;
        //     } else {
        //         velocity.x = 0;
        //     }
        // }

        // Speed limiter. 
        if (abs(velocity.x) > 5) {
            double valSign = sgn(velocity.x);
            velocity.x = valSign * 5;
        }

        if (!inJump && Keyboard.isDown(KeyboardKey.KEY_SPACE)) {
            jumpQueued = true;
        }

        //? Then apply Y axis.
        position.y += velocity.y * delta;

        bool hitGround = Map.collideEntityToWorld(position, size, velocity, CollisionAxis.Y);

        if (inJump && hitGround) {
            inJump = false;
        } else if (jumpQueued && hitGround) {
            velocity.y = 7;
            jumpQueued = false;
            inJump = true;
        }

        //? Finally apply X axis.
        position.x += velocity.x * delta;

        Map.collideEntityToWorld(position, size, velocity, CollisionAxis.X);

        if (velocity.x == 0) {
            moving = false;
        }

        // todo: the void.
        // if (position.y <= 0) {
        //     position.y = 0;
        // }

        Vec2i oldChunk = inChunk;
        Vec2i newChunk = Map.calculateChunkAtWorldPosition(position);

        if (oldChunk != newChunk) {
            inChunk = newChunk;
            Map.worldLoad(inChunk);
        }
    }

    Vec2i inWhichChunk() {
        return inChunk;
    }

private: //* BEGIN INTERNAL API.

}
