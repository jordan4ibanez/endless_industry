module gui.gui;

import controls.keyboard;
import controls.mouse;
import graphics.colors;
import gui.font;
import math.vec2d;
import math.vec2i;
import raylib;
import std.math.rounding;
import std.stdio;

/*
*
*   CONTROLS PROVIDED:
*     # Container/separators Controls
*       - WindowBox     --> StatusBar, Panel
*       - GroupBox      --> Line
*       - Line
*       - Panel         --> StatusBar
*       - ScrollPanel   --> StatusBar
*       - TabBar        --> Button
*
*     # Basic Controls
*       - Label
*       - LabelButton   --> Label
*       - Button
*       - Toggle
*       - ToggleGroup   --> Toggle
*       - ToggleSlider
*       - CheckBox
*       - ComboBox
*       - DropdownBox
*       - TextBox
*       - ValueBox      --> TextBox
*       - Spinner       --> Button, ValueBox
*       - Slider
*       - SliderBar     --> Slider
*       - ProgressBar
*       - StatusBar
*       - DummyRec
*       - Grid
*
*     # Advance Controls
*       - ListView
*       - ColorPicker   --> ColorPanel, ColorBarHue
*       - MessageBox    --> Window, Label, Button
*       - TextInputBox  --> Window, Label, TextBox, Button
*/

class Element {

}

// This is the basis of any GUI component, the container.
class WindowGUI {

    // If it's a window, this defines if you can resize it.
    bool resizeable = true;

    // This allows Windows to be moved around.
    Vec2d mouseDelta;

    // What this container's title says.
    string containerTitle = null;

    //? State behavior.

    // Position is top left of container.
    Vec2i position;

    // The current size of the window. (It will always be scaled to GUI scaling)
    Vec2i size;

    // The minimum size of the window. (It will always be scaled to GUI scaling)
    Vec2i minSize = Vec2i(100, 100);

    // If the mouse is hovering over the status bar.
    bool mouseHoveringStatusBar = false;

    // If the mouse is hovering over the close button.
    bool mouseHoveringCloseButton = false;

    // If the mouse is hovering over the resize button.
    bool mouseHoveringResizeButton = false;

    //? General solid colors.

    // The color of the work area.
    Color workAreaColor = Colors.GRAY;

    // The border color of the window. (All border components.)
    Color borderColor = Colors.BLACK;

    // The status bar background color.
    Color statusBarColor = Colors.BLUE;
    // The status bar background color when hovered over.
    Color statusBarHoverColor = Color(40, 50, 255, 255);

    // The close button background color.
    Color closeButtonBackgroundColor = Colors.GRAY;

    // The resize button background color.
    Color resizeButtonBackgroundColor = Colors.GRAY;
    // The resize button background color when hovered over.
    Color resizeButtonBackgroundColorHovered = Colors.DARKGRAY;

    //? General text/icon colors.

    // The text below the status bar.
    Color workAreaTextColor = Colors.BLACK;

    // The status bar text color.
    Color statusBarTextColor = Colors.WHITE;

    // The close button X color.
    Color closeButtonXColor = Colors.BLACK;
    // The close button X color when hovered over.
    Color closeButtonXHoverColor = Colors.RED;

}

static final const class GUI {
static:
private:

    // We standardize the GUI with 1080p.
    const Vec2d standardSize = Vec2d(1920.0, 1080.0);
    // This is the real window size.
    Vec2d realSize = Vec2d(1920.0, 1080.0);
    // The scale of GUI components.
    double currentGUIScale = 1.0;
    // Used to divide using multiplication.
    double inverseCurrentGUIScale = 1.0;
    // This is the anchor for all windows. The origin is in the center of the window.
    Vec2d centerPoint;
    // This will be an options menu component to adjust the size of the GUI.
    double masterGUIScale = 1.0;
    // This is the scale of the graphics components.
    // Mainly this is used for the camera's zoom.
    double graphicsScale = 1.0;

    WindowGUI[string] windows;
    bool dragging = false;
    bool resizing = false;
    WindowGUI currentWindow = null;

public: //* BEGIN PUBLIC API.

    void drawCurrentWindowGUI() {

        if (currentWindow is null) {
            return;
        }

        int posX = cast(int) floor(centerPoint.x + (currentWindow.position.x * currentGUIScale));
        int posY = cast(int) floor(centerPoint.y + (currentWindow.position.y * currentGUIScale));
        int sizeX = cast(int) floor(currentWindow.size.x * currentGUIScale);
        int sizeY = cast(int) floor(currentWindow.size.y * currentGUIScale);
        int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);

        //? Stop from drawing out of bounds.
        BeginScissorMode(posX - 1, posY - 1, sizeX + 1, sizeY + 1);

        // Work area background.
        DrawRectangle(posX, posY, sizeX, sizeY, currentWindow.workAreaColor);

        // Status area background.
        if (currentWindow.mouseHoveringStatusBar) {
            DrawRectangle(posX, posY, sizeX, statusAreaHeight, currentWindow.statusBarHoverColor);
        } else {
            DrawRectangle(posX, posY, sizeX, statusAreaHeight, currentWindow.statusBarColor);
        }

        // Work area outline.
        DrawRectangleLines(posX, posY, sizeX, sizeY, currentWindow.borderColor);

        // Status area outline.
        DrawRectangleLines(posX, posY, sizeX, statusAreaHeight, currentWindow.borderColor);

        EndScissorMode();

        //? Capture excessively long window titles.
        BeginScissorMode(posX, posY, sizeX - statusAreaHeight - 1, statusAreaHeight - 1);

        const string title = currentWindow.containerTitle;
        if (title !is null) {
            FontHandler.drawShadowed(title, posX + (currentGUIScale * 2), posY, 0.25, currentWindow
                    .statusBarTextColor);
        }

        EndScissorMode();

        //? Draw the close button.

        // I just like using the scissor mode. :D
        BeginScissorMode(posX + sizeX - statusAreaHeight - 1, posY - 1, statusAreaHeight + 1, statusAreaHeight + 1);

        // Background and border.
        DrawRectangle(posX + sizeX - statusAreaHeight, posY, statusAreaHeight, statusAreaHeight, currentWindow
                .closeButtonBackgroundColor);
        DrawRectangleLines(posX + sizeX - statusAreaHeight, posY, statusAreaHeight, statusAreaHeight, currentWindow
                .borderColor);

        const double closeTrim = 4 * currentGUIScale;
        const double closeThickness = 1 * currentGUIScale;

        // The X.

        Color closeButtonBackgroundColor = currentWindow.mouseHoveringCloseButton ? currentWindow
            .closeButtonXHoverColor : currentWindow.closeButtonXColor;

        // This: /
        DrawLineEx(
            Vector2(
                floor(posX + sizeX - statusAreaHeight + closeTrim),
                floor(posY + statusAreaHeight - closeTrim)),
            Vector2(
                floor(posX + sizeX - closeTrim),
                floor(posY + closeTrim)),
            closeThickness,
            closeButtonBackgroundColor);

        // This: \
        DrawLineEx(
            Vector2(
                floor(posX + sizeX - statusAreaHeight + closeTrim),
                floor(posY + closeTrim)),
            Vector2(
                floor(posX + sizeX - closeTrim),
                floor(posY + statusAreaHeight - closeTrim)),
            closeThickness,
            closeButtonBackgroundColor
        );

        EndScissorMode();

        //? Draw the resize button.

        const int halfStatusAreaHeight = cast(int) floor(statusAreaHeight * 0.5);

        BeginScissorMode(
            posX + sizeX - halfStatusAreaHeight - 1,
            posY + sizeY - halfStatusAreaHeight - 1,
            halfStatusAreaHeight + 1,
            halfStatusAreaHeight + 1);

        if (currentWindow.mouseHoveringResizeButton) {
            DrawRectangle(
                posX + sizeX - halfStatusAreaHeight,
                posY + sizeY - halfStatusAreaHeight,
                halfStatusAreaHeight,
                halfStatusAreaHeight,
                currentWindow.resizeButtonBackgroundColorHovered);
        } else {
            DrawRectangle(
                posX + sizeX - halfStatusAreaHeight,
                posY + sizeY - halfStatusAreaHeight,
                halfStatusAreaHeight,
                halfStatusAreaHeight,
                currentWindow.resizeButtonBackgroundColor);
        }

        DrawRectangleLines(
            posX + sizeX - halfStatusAreaHeight,
            posY + sizeY - halfStatusAreaHeight,
            halfStatusAreaHeight,
            halfStatusAreaHeight,
            currentWindow.borderColor);

        EndScissorMode();

    }

    Vector2 getMousePositionInGUI() {
        Vector2 mousePos = GetMousePosition();
        mousePos.x -= centerPoint.x;
        mousePos.y -= centerPoint.y;
        return mousePos;
    }

    void updateCurrentWindowGUI() {

        bool mouseFocusedOnGUI = false;

        if (currentWindow is null) {
            return;
        }

        Vector2 mousePos = Mouse.getPosition.toRaylib();

        if (dragging) {

            if (!Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                dragging = false;
                return;
            }

            mouseFocusedOnGUI = true;

            const Vector2 mousePosInGUI = getMousePositionInGUI();

            double scaledDeltaX = currentWindow.mouseDelta.x * inverseCurrentGUIScale;
            double scaledDeltaY = currentWindow.mouseDelta.y * inverseCurrentGUIScale;
            double scaledMousePosX = mousePosInGUI.x * inverseCurrentGUIScale;
            double scaledMousePosY = mousePosInGUI.y * inverseCurrentGUIScale;

            currentWindow.position.x = cast(int) floor(scaledDeltaX + scaledMousePosX);
            currentWindow.position.y = cast(int) floor(scaledDeltaY + scaledMousePosY);

        } else if (resizing) {

            if (!Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                resizing = false;
                return;
            }

            mouseFocusedOnGUI = true;

            int posX = currentWindow.position.x;
            int posY = currentWindow.position.y;

            const Vector2 mousePosInGUI = getMousePositionInGUI();

            double scaledDeltaX = currentWindow.mouseDelta.x * inverseCurrentGUIScale;
            double scaledDeltaY = currentWindow.mouseDelta.y * inverseCurrentGUIScale;
            double scaledMousePosX = mousePosInGUI.x * inverseCurrentGUIScale;
            double scaledMousePosY = mousePosInGUI.y * inverseCurrentGUIScale;

            currentWindow.size.x = cast(int) floor((scaledMousePosX + scaledDeltaX) - posX);
            currentWindow.size.y = cast(int) floor((scaledMousePosY + scaledDeltaY) - posY);

            if (currentWindow.size.x < currentWindow.minSize.x) {
                currentWindow.size.x = currentWindow.minSize.x;
            }
            if (currentWindow.size.y < currentWindow.minSize.y) {
                currentWindow.size.y = currentWindow.minSize.y;
            }

        } else {

            int posX = cast(int) floor(centerPoint.x + (currentWindow.position.x * currentGUIScale));
            int posY = cast(int) floor(centerPoint.y + (currentWindow.position.y * currentGUIScale));
            int sizeX = cast(int) floor(currentWindow.size.x * currentGUIScale);
            int sizeY = cast(int) floor(currentWindow.size.y * currentGUIScale);

            Rectangle windowRectangle = Rectangle(posX, posY, sizeX, sizeY);

            currentWindow.mouseHoveringStatusBar = false;
            currentWindow.mouseHoveringCloseButton = false;
            currentWindow.mouseHoveringResizeButton = false;

            //? Collide with the entire window.

            // No collision with this window occured.
            if (CheckCollisionPointRec(mousePos, windowRectangle)) {

                mouseFocusedOnGUI = true;

                int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);

                //? Check if the mouse is hovering over the status bar.

                Rectangle statusBarRectangle = Rectangle(posX, posY, sizeX - statusAreaHeight - 1, statusAreaHeight);

                if (CheckCollisionPointRec(mousePos, statusBarRectangle)) {

                    currentWindow.mouseHoveringStatusBar = true;

                    // The user is dragging a window.
                    if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                        currentWindow.mouseDelta = Vec2d(Vector2Subtract(Vector2(posX, posY), mousePos));
                        dragging = true;
                        return;
                    }
                }

                //? Check if the mouse is hovering over the close button.
                Rectangle closeButtonRectangle = Rectangle(posX + sizeX - statusAreaHeight, posY, statusAreaHeight,
                    statusAreaHeight);

                if (CheckCollisionPointRec(mousePos, closeButtonRectangle)) {
                    currentWindow.mouseHoveringCloseButton = true;

                    // The user closed the window.
                    if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                        currentWindow = null;
                    }
                }

                //? Check if the mouse is hovering over the resize button.

                const int halfStatusAreaHeight = cast(int) floor(statusAreaHeight * 0.5);

                Rectangle resizeButtonRectangle = Rectangle(
                    posX + sizeX - halfStatusAreaHeight,
                    posY + sizeY - halfStatusAreaHeight,
                    halfStatusAreaHeight,
                    halfStatusAreaHeight);

                if (CheckCollisionPointRec(mousePos, resizeButtonRectangle)) {
                    currentWindow.mouseHoveringResizeButton = true;

                    // The user is resizing a window.
                    if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                        currentWindow.mouseDelta = Vec2d(Vector2Subtract(Vector2(posX + sizeX, posY + sizeY),
                                mousePos));
                        resizing = true;
                        return;
                    }
                }
            }
        }

        Mouse.__setFocusedOnGUI(mouseFocusedOnGUI);
    }

    void debugTest() {

        WindowGUI testContainer = new WindowGUI();

        testContainer.containerTitle = "Pause Menu";
        testContainer.size.x = 400;
        testContainer.size.y = 400;

        testContainer.position.x = 0;
        testContainer.position.y = 0;

        windows["testMenu"] = testContainer;

        currentWindow = testContainer;

    }

    void centerWindow(WindowGUI window) {

        double x = floor((realSize.x * 0.5) * inverseCurrentGUIScale);
        double y = floor((realSize.y * 0.5) * inverseCurrentGUIScale);

        double halfWindowSizeX = window.size.x * 0.5;
        double halfWindowSizeY = window.size.y * 0.5;

        int newPositionX = cast(int) floor(x - halfWindowSizeX);
        int newPositionY = cast(int) floor(y - halfWindowSizeY);

        window.position.x = newPositionX;
        window.position.y = newPositionY;
    }

    void bringBackDebugTest() {
        if (Keyboard.isPressed(KeyboardKey.KEY_ONE)) {
            currentWindow = windows["testMenu"];
        }
        if (Keyboard.isPressed(KeyboardKey.KEY_TWO)) {
            centerWindow(windows["testMenu"]);
        }
    }

    double getGUIScale() {
        return currentGUIScale;
    }

    double getGraphicsScale() {
        return graphicsScale;
    }

    void initialize() {
        FontHandler.initialize();
        debugTest();
    }

    void terminate() {
        FontHandler.terminate();
    }

    void __update(Vec2d newWindowSize) {
        realSize.x = newWindowSize.x;
        realSize.y = newWindowSize.y;

        centerPoint.x = realSize.x * 0.5;
        centerPoint.y = realSize.y * 0.5;

        // Find out which GUI scale is smaller so things can be scaled around it.
        const Vec2d scales = Vec2d(
            newWindowSize.x / standardSize.x,
            newWindowSize.y / standardSize.y);

        if (scales.x >= scales.y) {
            currentGUIScale = scales.y;
        } else {
            currentGUIScale = scales.x;
        }

        graphicsScale = currentGUIScale;

        currentGUIScale *= masterGUIScale;

        inverseCurrentGUIScale = 1.0 / currentGUIScale;

        FontHandler.__update();
        updateCurrentWindowGUI();

        bringBackDebugTest();
    }

private: //* BEGIN INTERNAL API.

}
