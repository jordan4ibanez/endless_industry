module controls.keyboard;

public import raylib : KeyboardKey;
import raylib;

static final const class Keyboard {
static:
private:

    bool doingTextInput = false;

public: //* BEGIN PUBLIC API.

    int getCharacterTyped() {
        return GetCharPressed();
    }

    bool isDown(KeyboardKey key) {
        return IsKeyDown(key);
    }

    bool isPressed(KeyboardKey key) {
        return IsKeyPressed(key);
    }

    bool isKeyRepeating(KeyboardKey key) {
        return IsKeyPressedRepeat(key);
    }

    bool isKeyPressedOrRepeating(KeyboardKey key) {
        return IsKeyPressed(key) || IsKeyPressedRepeat(key);
    }

    bool isReleased(KeyboardKey key) {
        return IsKeyReleased(key);
    }

    bool isDoingTextInput() {
        return doingTextInput;
    }

    void __setDoingTextInput(bool doingTextInput) {
        this.doingTextInput = doingTextInput;
    }

private: //* BEGIN INTERNAL API.

}
