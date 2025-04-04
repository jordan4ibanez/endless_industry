module controls.keyboard;

import raylib;
public import raylib : KeyboardKey;

static final const class Keyboard {
static:
private:

    //? I like to have specific modules for things.

    //* BEGIN PUBLIC API.

    public bool isDown(KeyboardKey key) {
        return IsKeyDown(key);
    }

    public bool isPressed(KeyboardKey key) {
        return IsKeyPressed(key);
    }

    public bool isReleased(KeyboardKey key) {
        return IsKeyReleased(key);
    }

    //* BEGIN INTERNAL API.

}
