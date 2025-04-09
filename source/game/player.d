module game.player;

import controls.keyboard;
import core.memory;
import game.map;
import graphics.colors;
import graphics.render;
import graphics.texture;
import math.constants;
import math.rect;
import math.vec2d;
import math.vec2i;
import raylib : DEG2RAD, PI, RAD2DEG;
import std.bitmanip;
import std.conv;
import std.math.algebraic : abs;
import std.math.rounding;
import std.math.traits : sgn;
import std.math.trigonometry;
import std.stdio;
import utility.collision_functions;
import utility.delta;
import utility.drawing_functions;

private struct AnimationState {
    mixin(bitfields!(
            ubyte, "state", 2,
            ubyte, "direction", 3,
            ubyte, "frame", 3));
}

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
    AnimationState animation;
    double animationTimer = 0;
    string[] __frameNames = null;
    OutputRect* frames = null;

public: //* BEGIN PUBLIC API.

    void setPlayerFrames(string[] frames) {
        const uint frameLength = 3 * 8 * 8;
        if (frames.length != frameLength) {
            throw new Error("Player frames does not equal " ~ to!string(
                    frameLength) ~ " | equals: " ~ to!string(frames.length));
        }
        this.__frameNames = frames;
    }

    void finalize() {
        if (__frameNames == null) {
            throw new Error("Player frames were never set.");
        }

        frames = cast(OutputRect*) GC.malloc(OutputRect.sizeof * __frameNames.length);

        foreach (ulong index, string key; __frameNames) {
            if (key is null) {
                continue;
            }
            if (!TextureHandler.hasTexture(key)) {
                throw new Error("Missing frame: " ~ key ~ " in player");
            }

            frames[index] = TextureHandler.getTextureRectangle(key);
        }

        this.__frameNames = null;

    }

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

        static immutable double _frameGoalWalking = 0.1;
        static immutable double _frameGoalStanding = 0.25;

        double frameGoal = 0;

        // Walking is animated slightly faster.
        if (animation.state == 1) {
            frameGoal = _frameGoalWalking;
        } else { // Everything else is slightly slower.
            frameGoal = _frameGoalStanding;
        }

        // writeln(*cast(ubyte*)&animation);

        // 3 states.
        // 8 directions.
        // 8 total frames.
        const uint stateStride = 8 * 8;
        const uint directionStride = 8;

        if (animationTimer >= frameGoal) {
            animationTimer -= frameGoal;

            if (animation.frame == 7) {
                animation.frame = 0;
            } else {
                animation.frame = cast(ubyte)(animation.frame + 1);
            }

            // Walking has 8 frames.
            if (animation.state == 1) {
                if (animation.frame >= 8) {
                    animation.frame = 0;
                }
            } else { // Everything else (for now) has 4.
                if (animation.frame >= 4) {
                    animation.frame = 0;
                }
            }
        }

        Render.rectangleLines(centerCollisionbox(position, size), size, Colors.WHITE);

        Vec2d adjustedPosition = centerCollisionbox(position, Vec2d(3, 3));
        adjustedPosition.y += 1.0;

        uint index = (animation.state * stateStride) + (
            animation.direction * directionStride) + animation.frame;

        TextureHandler.drawTextureKnownCoordinates(frames + index, adjustedPosition, Rect(0, 0, 88, 88), Vec2d(3, 3));
    }

    void setAnimationState(ubyte newState) {
        // Walking has 8 frames.
        // Everything else (for now) has 4.
        // So we must catch that.
        if (newState != 1) {
            if (animation.frame >= 4) {
                animation.frame = 0;
            }
        }

        animation.state = newState;
    }

    void move() {
        double delta = Delta.getDelta();

        // Todo: Make this API element later.
        const double acceleration = 40;
        const double deceleration = 50;
        const double topSpeed = 7;

        // writeln(velocity.x);

        moving = false;

        struct InputBits {
            mixin(bitfields!(
                    byte, "x", 2,
                    byte, "y", 2,
                    bool, "", 4));
        }

        InputBits input;
        input.x = 0;
        input.y = 0;

        //? Controls first.
        if (Keyboard.isDown(KeyboardKey.KEY_D)) {
            moving = true;
            input.x = 1;
            velocity.x = topSpeed;
        } else if (Keyboard.isDown(KeyboardKey.KEY_A)) {
            moving = true;
            input.x = -1;
            velocity.x = -topSpeed;
        } else {
            velocity.x = 0;
        }
        if (Keyboard.isDown(KeyboardKey.KEY_W)) {
            moving = true;
            input.y = 1;
            velocity.y = topSpeed;
        } else if (Keyboard.isDown(KeyboardKey.KEY_S)) {
            moving = true;
            input.y = -1;
            velocity.y = -topSpeed;
        } else {
            velocity.y = 0;
        }

        // Speed limiter. 
        if (vec2dLength(velocity) > topSpeed) {
            velocity = vec2dMultiply(vec2dNormalize(velocity), Vec2d(topSpeed, topSpeed));
        }

        //? Then apply Y axis.
        position.y += velocity.y * delta;

        //? Finally apply X axis.
        position.x += velocity.x * delta;

        //! Animation components.
        setAnimationState(moving ? 1 : 0);
        if (moving) {
            const double __preprocessYaw = atan2(cast(double) input.y, cast(double) input.x) + HALF_PI;
            const double __processedYaw = atan2(cos(__preprocessYaw), sin(__preprocessYaw)) + PI;
            // Rounded to prevent floating point errors.
            animation.direction = cast(ubyte) round(__processedYaw * DIV_QUARTER_PI);
        }
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
