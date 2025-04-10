module controls.mouse;

public import raylib : MouseButton;
import graphics.camera;
import graphics.window;
import math.vec2d;
import raylib;
import std.stdio;

static final const class Mouse {
static:
private:

public:

    //? I like to have specific modules for things.

    //* BEGIN PUBLIC API.

    Vec2d getDelta() {
        return Vec2d(GetMouseDelta());
    }

    double getScrollDelta() {
        return GetMouseWheelMove();
    }

    Vec2d getWorldPosition() {
        return CameraHandler.screenToWorld(Vec2d(GetMousePosition()));
    }

    bool isButtonPressed(MouseButton button) {
        return IsMouseButtonPressed(button);
    }

    bool isButtonDown(MouseButton button) {
        return IsMouseButtonDown(button);
    }

    //* BEGIN INTERNAL API.

}
