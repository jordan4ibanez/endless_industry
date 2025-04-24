module gui.component_logic;

import controls.mouse;
import gui.component;
import gui.gui;
import math.vec2i;
import raylib : CheckCollisionPointRec, Rectangle, Vector2;
import std.math.rounding;

///? Base component.
bool baseLogic(ref Component __self, const double currentGUIScale, const ref Vec2i center,
    const ref Vector2 mousePos) {
    return false;
}

///? Button.
bool buttonLogic(ref Component __self, const double currentGUIScale, const ref Vec2i center,
    const ref Vector2 mousePos) {

    Button button = cast(Button) __self;

    button.mouseHovering = false;
    const int posX = cast(int) floor(
        (button.position.x * currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-button.position.y) * currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(button.size.x * currentGUIScale);
    const int sizeY = cast(int) floor(button.size.y * currentGUIScale);
    const Rectangle buttonRect = Rectangle(
        posX,
        posY,
        sizeX,
        sizeY);
    // If the mouse is hovering over the button.
    if (CheckCollisionPointRec(mousePos, buttonRect)) {
        button.mouseHovering = true;
        // If the mouse clicks the button.
        if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            GUI.playButtonSound();
            button.clickFunction();
            return true;
        }
    }
    return false;
}
