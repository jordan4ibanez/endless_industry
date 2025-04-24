module gui.window_logic;

import controls.mouse;
import gui.gui;
import math.vec2d;
import raylib : CheckCollisionPointRec, Rectangle, Vector2, Vector2Subtract;
import std.math.rounding;

/// This is the general logic of the window itself.
/// Not the components inside the window. That is a separate function.
/// The mouse collision, drag/resize initialization.
/// This returns if it's okay to proceed to checking window components in the work area.
void generalWindowLogic(ref bool mouseFocusedOnGUI, const ref Vec2d centerPoint) {
    const Vector2 mousePos = Mouse.getPosition.toRaylib();
    const int posX = cast(int) floor(
        centerPoint.x + (GUI.currentWindow.position.x * GUI.currentGUIScale));
    const int posY = cast(int) floor(
        centerPoint.y + (GUI.currentWindow.position.y * GUI.currentGUIScale));
    const int sizeX = cast(int) floor(GUI.currentWindow.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(GUI.currentWindow.size.y * GUI.currentGUIScale);
    const Rectangle windowRectangle = Rectangle(posX, posY, sizeX, sizeY);
    GUI.currentWindow.mouseHoveringStatusBar = false;
    GUI.currentWindow.mouseHoveringCloseButton = false;
    GUI.currentWindow.mouseHoveringResizeButton = false;
    //? Collide with the entire window.
    // No collision with this window occured.
    if (!CheckCollisionPointRec(mousePos, windowRectangle)) {
        return;
    }
    mouseFocusedOnGUI = true;
    const int statusAreaHeight = cast(int) floor(GUI.currentGUIScale * 32.0);
    //? Check if the mouse is hovering over the status bar.
    Rectangle statusBarRectangle = Rectangle(posX, posY, sizeX - statusAreaHeight - 1, statusAreaHeight);
    if (CheckCollisionPointRec(mousePos, statusBarRectangle)) {
        GUI.currentWindow.mouseHoveringStatusBar = true;
        // The user is dragging a window.
        if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            GUI.mouseWindowDelta = Vec2d(Vector2Subtract(Vector2(posX, posY), mousePos));
            GUI.dragging = true;
            GUI.playButtonSound();
            return;
        }
    }
    //? Check if the mouse is hovering over the close button.
    const Rectangle closeButtonRectangle = Rectangle(posX + sizeX - statusAreaHeight, posY,
        statusAreaHeight, statusAreaHeight);
    if (CheckCollisionPointRec(mousePos, closeButtonRectangle)) {
        GUI.currentWindow.mouseHoveringCloseButton = true;
        // The user closed the window.
        if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            GUI.closeWindow();
            GUI.playButtonSound();
            return;
        }
    }
    //? Check if the mouse is hovering over the resize button.
    if (GUI.currentWindow.resizeable) {
        const int halfStatusAreaHeight = cast(int) floor(statusAreaHeight * 0.5);
        const Rectangle resizeButtonRectangle = Rectangle(
            posX + sizeX - halfStatusAreaHeight,
            posY + sizeY - halfStatusAreaHeight,
            halfStatusAreaHeight,
            halfStatusAreaHeight);
        if (CheckCollisionPointRec(mousePos, resizeButtonRectangle)) {
            GUI.currentWindow.mouseHoveringResizeButton = true;
            // The user is resizing a window.
            if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                GUI.mouseWindowDelta = Vec2d(Vector2Subtract(Vector2(posX + sizeX, posY + sizeY),
                        mousePos));
                GUI.resizing = true;
                GUI.playButtonSound();
                return;
            }
        }
    }
}
