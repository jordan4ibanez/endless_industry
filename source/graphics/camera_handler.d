module graphics.camera_handler;

import game.player;
import graphics.gui;
import math.vec2d;
import raylib;
import std.stdio;
import utility.window;

static final const class CameraHandler {
static:
private:

    Camera2D* camera;

public: //* BEGIN PUBLIC API.

    double realZoom = 100.0;

    void initialize() {
        camera = new Camera2D();
        camera.rotation = 0;
        camera.zoom = 100.0;
        camera.target = Vector2(0, 0);
    }

    void terminate() {
        camera = null;
    }

    void begin() {
        Matrix4 matOrigin = MatrixTranslate(-camera.target.x, camera.target.y, 0.0);
        Matrix4 matRotation = MatrixRotate(Vector3(0, 0, 1), camera.rotation * DEG2RAD);
        Matrix4 matScale = MatrixScale(camera.zoom, camera.zoom, 1.0);
        Matrix4 matTranslation = MatrixTranslate(camera.offset.x, camera.offset.y, 0.0);
        Matrix4 output = MatrixMultiply(MatrixMultiply(matOrigin, MatrixMultiply(matScale, matRotation)),
            matTranslation);

        BeginMode2D(*camera);
        rlSetMatrixModelview(output);
        // rlDisableBackfaceCulling();
    }

    void end() {
        EndMode2D();
    }

    void setTarget(const ref Vec2d position) {
        camera.target = position.toRaylib();
    }

    double getZoom() {
        return realZoom;
    }

    void setZoom(double zoom) {
        realZoom = zoom;
    }

    Vec2d screenToWorld(const ref Vec2d position) {
        return Vec2d(GetScreenToWorld2D(position.toRaylib(), *camera));
    }

    void centerToPlayer() {
        Vec2d playerPosition = Player.getPosition();
        Vec2d offset = Player.getSize();
        offset.x = 0;
        //? this will move it to the center of the collisionbox.
        // offset.y *= -0.5;
        offset.y = 0;

        Vec2d playerCenter = vec2dAdd(playerPosition, offset);

        camera.target = playerCenter.toRaylib();
    }

    Vec2d screenToWorld(int x, int y) {

        return Vec2d(GetScreenToWorld2D(Vec2d(x, y).toRaylib(), *camera));
    }

    void __update() {
        camera.offset = vec2dMultiply(Window.getSize(), Vec2d(0.5, 0.5)).toRaylib();
        camera.zoom = realZoom * GUI.getGUIScale();
    }

private: //* BEGIN INTERNAL API.

}
