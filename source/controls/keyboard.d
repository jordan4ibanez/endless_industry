module controls.keyboard;

public import raylib : KeyboardKey;
import raylib;

static final const class Keyboard {
static:
private:

    bool doingTextInput = false;

public: //* BEGIN PUBLIC API.

    bool isDown(KeyboardKey key) {
        return IsKeyDown(key);
    }

    bool isPressed(KeyboardKey key) {
        return IsKeyPressed(key);
    }

    bool isReleased(KeyboardKey key) {
        return IsKeyReleased(key);
    }

private: //* BEGIN INTERNAL API.

}
