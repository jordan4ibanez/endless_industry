module game.player;

import controls.keyboard;
import game.map;
import graphics.colors;
import graphics.render;
import graphics.texture;
import math.rect;
import math.vec2d;
import math.vec2i;
import raylib : DEG2RAD, PI, RAD2DEG;
import std.conv;
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

    Vec2d size = Vec2d(1, 1);
    Vec2d position = Vec2d(32, 32);
    Vec2d velocity = Vec2d(0, 0);
    Vec2i inChunk = Vec2i(int.max, int.max);
    bool firstGen = true;
    bool moving = false;
    // states:
    // 0 standing
    // 1 walking
    // 2 mining
    ubyte animationState = 1;
    ubyte directionFrame = 6;
    ubyte animationFrame = 0;
    double animationTimer = 0;

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

    /// Get if the player is moving.
    bool isMoving() {
        return moving;
    }

    void draw() {

        double delta = Delta.getDelta();

        animationTimer += delta;

        static immutable double _frameGoalWalking = 0.08;
        static immutable double _frameGoalStanding = 0.25;

        double frameGoal = 0;

        // Walking is animated slightly faster.
        if (animationState == 1) {
            frameGoal = _frameGoalWalking;
        } else { // Everything else is slightly slower.
            frameGoal = _frameGoalStanding;
        }

        if (animationTimer >= frameGoal) {
            animationTimer -= frameGoal;

            animationFrame++;

            // Walking has 8 frames.
            if (animationState == 1) {
                if (animationFrame >= 8) {
                    animationFrame = 0;
                }
            } else { // Everything else (for now) has 4.
                if (animationFrame >= 4) {
                    animationFrame = 0;
                }
            }
        }

        Render.rectangleLines(centerCollisionbox(position, size), size, Colors.WHITE);

        Vec2d adjustedPosition = centerCollisionbox(position, Vec2d(2, 2));
        adjustedPosition.y += 0.75;

        // This is some next level debugging horror right here lmao.
        string animationName;

        final switch (animationState) {
        case 0:
            animationName = "standing";
            break;
        case 1:
            animationName = "walking";
            break;
        case 2:
            animationName = "mining";
            break;
        }

        const string textureName = "player_" ~ animationName ~ "_direction_" ~ to!string(
            directionFrame) ~ "_frame_" ~ to!string(animationFrame) ~ ".png";

        TextureHandler.drawTexture(textureName, adjustedPosition, Rect(0, 0, 88, 88), Vec2d(2, 2));

    }

    void setAnimationState(ubyte newState) {
        // Walking has 8 frames.
        // Everything else (for now) has 4.
        // So we must catch that.
        if (newState != 1) {
            if (animationFrame >= 4) {
                animationFrame = 0;
            }
        }

        animationState = newState;
    }

    void move() {
        double delta = Delta.getDelta();

        // Todo: Make this API element later.
        const double acceleration = 40;
        const double deceleration = 50;
        const double topSpeed = 5;

        // writeln(velocity.x);

        moving = false;

        int xInput = 0;
        int yInput = 0;

        //? Controls first.
        if (Keyboard.isDown(KeyboardKey.KEY_D)) {
            moving = true;
            xInput = 1;
            if (sgn(velocity.x) < 0) {
                velocity.x += delta * deceleration;
            } else {
                velocity.x += delta * acceleration;
            }
        } else if (Keyboard.isDown(KeyboardKey.KEY_A)) {
            moving = true;
            xInput = -1;
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
            yInput = 1;
            if (sgn(velocity.y) < 0) {
                velocity.y += delta * deceleration;
            } else {
                velocity.y += delta * acceleration;
            }
        } else if (Keyboard.isDown(KeyboardKey.KEY_S)) {
            moving = true;
            yInput = -1;
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

        //! Animation components.
        setAnimationState(moving ? 1 : 0);
        //! End animation components.

        // Map.collideEntityToWorld(position, size, velocity, CollisionAxis.X);

        // if (velocity.x == 0 && velocity.y == 0) {
        //     moving = false;
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
