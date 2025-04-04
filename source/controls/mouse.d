module controls.mouse;

public import raylib : MouseButton;
import graphics.camera_handler;
import math.vec2d;
import raylib;
import utility.window;

static final const class Mouse {
static:
private:

public:

    //? I like to have specific modules for things.

    //* BEGIN PUBLIC API.

    Vec2d getDelta() {
        return Vec2d(GetMouseDelta());
    }

    Vec2d getWorldPosition() {
        Vec2d mPosition = Vec2d(GetMousePosition());
        immutable int windowHeight = Window.getHeight();
        mPosition.y = windowHeight - mPosition.y;
        return CameraHandler.screenToWorld(mPosition);
    }

    bool isButtonPressed(MouseButton button) {
        return IsMouseButtonPressed(button);
    }

    bool isButtonDown(MouseButton button) {
        return IsMouseButtonDown(button);
    }

    //* BEGIN INTERNAL API.

}
