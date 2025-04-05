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

    Vec2d size = Vec2d(0.5, 0.5);
    Vec2d position = Vec2d(16, 16);
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
        Vec2d centeredPosition = centerCollisionbox(position, size);
        return Rect(centeredPosition.x, centeredPosition.y, size.x, size.y);
    }

    void draw() {

        Render.rectangleLines(centerCollisionbox(position, size), size, Colors.WHITE);
    }

    void move() {
        double delta = Delta.getDelta();

        // Todo: Make this API element later.
        const double acceleration = 10_000; //40;
        const double deceleration = 10_000; //50;
        const double topSpeed = 1_000;

        // writeln(velocity.x);

        moving = false;

        //? Controls first.
        if (Keyboard.isDown(KeyboardKey.KEY_D)) {
            moving = true;
            if (sgn(velocity.x) < 0) {
                velocity.x += delta * deceleration;
            } else {
                velocity.x += delta * acceleration;
            }
        } else if (Keyboard.isDown(KeyboardKey.KEY_A)) {
            moving = true;
            if (sgn(velocity.x) > 0) {
                velocity.x -= delta * deceleration;
            } else {
                velocity.x -= delta * acceleration;
            }
        } else {
            if (abs(velocity.x) > delta * deceleration) {
                double valSign = sgn(velocity.x);
                velocity.x = (abs(velocity.x) - (delta * deceleration)) * valSign;
            } else {
                velocity.x = 0;
            }
        }

        if (Keyboard.isDown(KeyboardKey.KEY_W)) {
            moving = true;
            if (sgn(velocity.y) < 0) {
                velocity.y += delta * deceleration;
            } else {
                velocity.y += delta * acceleration;
            }
        } else if (Keyboard.isDown(KeyboardKey.KEY_S)) {
            moving = true;
            if (sgn(velocity.y) > 0) {
                velocity.y -= delta * deceleration;
            } else {
                velocity.y -= delta * acceleration;
            }
        } else {
            if (abs(velocity.y) > delta * deceleration) {
                double valSign = sgn(velocity.y);
                velocity.y = (abs(velocity.y) - (delta * deceleration)) * valSign;
            } else {
                velocity.y = 0;
            }
        }

        // Speed limiter. 
        if (abs(velocity.x) > topSpeed) {
            double valSign = sgn(velocity.x);
            velocity.x = valSign * topSpeed;
        }
        if (abs(velocity.y) > topSpeed) {
            double valSign = sgn(velocity.y);
            velocity.y = valSign * topSpeed;
        }

        //? Then apply Y axis.
        position.y += velocity.y * delta;

        //? Finally apply X axis.
        position.x += velocity.x * delta;

        // Map.collideEntityToWorld(position, size, velocity, CollisionAxis.X);

        if (velocity.x == 0 && velocity.y == 0) {
            moving = false;
        }

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
