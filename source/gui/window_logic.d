module gui.window_logic;

import controls.mouse;
import gui.gui;
import math.vec2d;
import math.vec2i;
import raylib : CheckCollisionPointRec, Rectangle, Vector2, Vector2Subtract;
import std.math.rounding;

package:

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

/// The logic for when a window is resized.
void windowResizeLogic(ref bool mouseFocusedOnGUI) {
    if (!Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
        GUI.resizing = false;
        GUI.playButtonSound();
        return;
    }
    mouseFocusedOnGUI = true;
    const int posX = GUI.currentWindow.position.x;
    const int posY = GUI.currentWindow.position.y;
    const Vector2 mousePosInGUI = GUI.getMousePositionInGUI();
    const double scaledDeltaX = GUI.mouseWindowDelta.x * GUI.inverseCurrentGUIScale;
    const double scaledDeltaY = GUI.mouseWindowDelta.y * GUI.inverseCurrentGUIScale;
    const double scaledMousePosX = mousePosInGUI.x * GUI.inverseCurrentGUIScale;
    const double scaledMousePosY = mousePosInGUI.y * GUI.inverseCurrentGUIScale;
    const int oldSizeX = GUI.currentWindow.size.x;
    const int oldSizeY = GUI.currentWindow.size.y;
    GUI.currentWindow.size.x = cast(int) floor((scaledMousePosX + scaledDeltaX) - posX);
    if (!GUI.windowXInBounds(GUI.currentWindow)) {
        GUI.currentWindow.size.x = oldSizeX;
    }
    GUI.currentWindow.size.y = cast(int) floor((scaledMousePosY + scaledDeltaY) - posY);
    if (!GUI.windowYInBounds(GUI.currentWindow)) {
        GUI.currentWindow.size.y = oldSizeY;
    }
    if (GUI.currentWindow.size.x < GUI.currentWindow.minSize.x) {
        GUI.currentWindow.size.x = GUI.currentWindow.minSize.x;
    }
    if (GUI.currentWindow.size.y < GUI.currentWindow.minSize.y) {
        GUI.currentWindow.size.y = GUI.currentWindow.minSize.y;
    }

    if (oldSizeX != GUI.currentWindow.size.x || oldSizeY != GUI.currentWindow.size.y) {
        Vec2i newSize = GUI.currentWindow.size;
        newSize.y -= 32 + 1;
        newSize.x += 1;
        foreach (component; GUI.currentWindow.componentDatabase) {
            component.onWindowResize(component, newSize);
        }
    }
}

/// The logic for when a window is dragged around.
void windowDragLogic(ref bool mouseFocusedOnGUI) {
    if (!Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
        GUI.dragging = false;
        GUI.playButtonSound();
        return;
    }
    mouseFocusedOnGUI = true;
    const Vector2 mousePosInGUI = GUI.getMousePositionInGUI();
    const double scaledDeltaX = GUI.mouseWindowDelta.x * GUI.inverseCurrentGUIScale;
    const double scaledDeltaY = GUI.mouseWindowDelta.y * GUI.inverseCurrentGUIScale;
    const double scaledMousePosX = mousePosInGUI.x * GUI.inverseCurrentGUIScale;
    const double scaledMousePosY = mousePosInGUI.y * GUI.inverseCurrentGUIScale;
    GUI.currentWindow.position.x = cast(int) floor(scaledDeltaX + scaledMousePosX);
    GUI.currentWindow.position.y = cast(int) floor(scaledDeltaY + scaledMousePosY);
    // Make sure the window stays on the screen.
    GUI.sweepWindowIntoBounds(GUI.currentWindow);
}
