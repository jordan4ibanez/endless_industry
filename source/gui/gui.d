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

enum ContainerType {
    Window,
    Box,
}

class Element {

}

// This is the basis of any GUI component, the container.
class Container {

    // The higher the layer, the higher priority it has.
    // If it's a window and covers another window, it gets priority over the other if it's higher.
    // If they're the same priority, it's random.
    int layer = 0;

    // The behavior and styling this container will have.
    ContainerType type = ContainerType.Window;

    // If it's a window, this defines if you can resize it.
    bool resizeable = true;

    // This allows Windows to be moved around.
    Vec2d mouseDelta;

    // What this container is called.
    string containerName = null;

    // What this container's title says.
    string containerTitle = null;

    //? State behavior.

    // Position is top left of container.
    Vec2i position;
    Vec2i size;

    // If this is interactive and drawn.
    bool visible = true;

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
    // The scale of GUI components.
    double currentGUIScale = 1.0;
    // Used to divide using multiplication.
    double inverseCurrentGUIScale = 1.0;
    // This will be an options menu component to adjust the size of the GUI.
    double masterGUIScale = 1.0;
    // This is the scale of the graphics components.
    // Mainly this is used for the camera's zoom.
    double graphicsScale = 1.0;

    Container[string] windows;
    bool dragging = true;
    Container currentWindow = null;

public: //* BEGIN PUBLIC API.

    void drawCurrentWindowGUI() {
        foreach (key, container; windows) {
            // This container is "asleep".
            if (!container.visible) {
                continue;
            }

            int posX = cast(int) floor(container.position.x * currentGUIScale);
            int posY = cast(int) floor(container.position.y * currentGUIScale);
            int sizeX = cast(int) floor(container.size.x * currentGUIScale);
            int sizeY = cast(int) floor(container.size.y * currentGUIScale);
            int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);

            //? Stop from drawing out of bounds.
            BeginScissorMode(posX - 1, posY - 1, sizeX + 1, sizeY + 1);

            // Work area background.
            DrawRectangle(posX, posY, sizeX, sizeY, container.workAreaColor);

            // Status area background.
            if (container.mouseHoveringStatusBar) {
                DrawRectangle(posX, posY, sizeX, statusAreaHeight, container.statusBarHoverColor);
            } else {
                DrawRectangle(posX, posY, sizeX, statusAreaHeight, container.statusBarColor);
            }

            // Work area outline.
            DrawRectangleLines(posX, posY, sizeX, sizeY, container.borderColor);

            // Status area outline.
            DrawRectangleLines(posX, posY, sizeX, statusAreaHeight, container.borderColor);

            EndScissorMode();

            //? Capture excessively long window titles.
            BeginScissorMode(posX, posY, sizeX - statusAreaHeight - 1, statusAreaHeight - 1);

            const string title = container.containerTitle;
            if (title !is null) {
                FontHandler.drawShadowed(title, posX + (currentGUIScale * 2), posY, 0.25, container
                        .statusBarTextColor);
            }

            EndScissorMode();

            //? Draw the close button.

            // I just like using the scissor mode. :D
            BeginScissorMode(posX + sizeX - statusAreaHeight - 1, posY - 1, statusAreaHeight + 1, statusAreaHeight + 1);

            // Background and border.
            DrawRectangle(posX + sizeX - statusAreaHeight, posY, statusAreaHeight, statusAreaHeight, container
                    .closeButtonBackgroundColor);
            DrawRectangleLines(posX + sizeX - statusAreaHeight, posY, statusAreaHeight, statusAreaHeight, container
                    .borderColor);

            const double closeTrim = 4 * currentGUIScale;
            const double closeThickness = 1 * currentGUIScale;

            // The X.

            Color closeButtonBackgroundColor = container.mouseHoveringCloseButton ? container.closeButtonXHoverColor
                : container.closeButtonXColor;

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

            if (container.mouseHoveringResizeButton) {
                DrawRectangle(
                    posX + sizeX - halfStatusAreaHeight,
                    posY + sizeY - halfStatusAreaHeight,
                    halfStatusAreaHeight,
                    halfStatusAreaHeight,
                    container.resizeButtonBackgroundColorHovered);
            } else {
                DrawRectangle(
                    posX + sizeX - halfStatusAreaHeight,
                    posY + sizeY - halfStatusAreaHeight,
                    halfStatusAreaHeight,
                    halfStatusAreaHeight,
                    container.resizeButtonBackgroundColor);
            }

            DrawRectangleLines(
                posX + sizeX - halfStatusAreaHeight,
                posY + sizeY - halfStatusAreaHeight,
                halfStatusAreaHeight,
                halfStatusAreaHeight,
                container.borderColor);

            EndScissorMode();

        }
    }

    void updateCurrentWindowGUI() {
        bool mouseFocusedOnGUI = false;

        if (currentWindow is null) {
            return;
        }

        Vector2 mousePos = Mouse.getPosition().toRaylib();

        if (dragging) {

            if (!Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                dragging = false;
                return;
            }

            mouseFocusedOnGUI = true;

            double scaledDeltaX = currentWindow.mouseDelta.x * inverseCurrentGUIScale;
            double scaledDeltaY = currentWindow.mouseDelta.y * inverseCurrentGUIScale;
            double scaledMousePosX = mousePos.x * inverseCurrentGUIScale;
            double scaledMousePosY = mousePos.y * inverseCurrentGUIScale;

            currentWindow.position.x = cast(int) floor(scaledDeltaX + scaledMousePosX);
            currentWindow.position.y = cast(int) floor(scaledDeltaY + scaledMousePosY);

        } else {

            foreach (key, container; windows) {
                // This container is "asleep".
                if (!container.visible) {
                    continue;
                }

                int posX = cast(int) floor(container.position.x * currentGUIScale);
                int posY = cast(int) floor(container.position.y * currentGUIScale);
                int sizeX = cast(int) floor(container.size.x * currentGUIScale);
                int sizeY = cast(int) floor(container.size.y * currentGUIScale);

                Rectangle windowRectangle = Rectangle(posX, posY, sizeX, sizeY);

                container.mouseHoveringStatusBar = false;
                container.mouseHoveringCloseButton = false;
                container.mouseHoveringResizeButton = false;

                //? Collide with the entire window.

                // No collision with this window occured.
                if (!CheckCollisionPointRec(mousePos, windowRectangle)) {
                    continue;
                }

                mouseFocusedOnGUI = true;

                int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);

                Rectangle statusBarRectangle = Rectangle(posX, posY, sizeX - statusAreaHeight - 1, statusAreaHeight);

                //? Check if the mouse is hovering over the status bar.
                if (CheckCollisionPointRec(mousePos, statusBarRectangle)) {

                    container.mouseHoveringStatusBar = true;

                    // The mouse is not trying to drag a window.
                    // It is just hovering over a window.
                    if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                        // The mouse is now dragging a window.
                        container.mouseDelta = Vec2d(Vector2Subtract(Vector2(posX, posY), mousePos));
                        dragging = true;
                        break;
                    }
                }

                Rectangle closeButtonRectangle = Rectangle(posX + sizeX - statusAreaHeight, posY, statusAreaHeight,
                    statusAreaHeight);

                //? Check if the mouse is hovering over the close button.
                if (CheckCollisionPointRec(mousePos, closeButtonRectangle)) {
                    container.mouseHoveringCloseButton = true;

                    if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                        container.visible = false;
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
                    container.mouseHoveringResizeButton = true;
                }
            }
        }

        Mouse.__setFocusedOnGUI(mouseFocusedOnGUI);
    }

    void debugTest() {

        Container testContainer = new Container();

        testContainer.containerName = "Pause Menu";
        testContainer.containerTitle = "Pause Menu";
        testContainer.size.x = 400;
        testContainer.size.y = 400;

        testContainer.position.x = 100;
        testContainer.position.y = 100;

        windows["testMenu"] = testContainer;

    }

    void bringBackDebugTest() {
        if (Keyboard.isPressed(KeyboardKey.KEY_ONE)) {
            windows["testMenu"].visible = true;
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
        // Find out which GUI scale is smaller so things can be scaled around it.
        Vec2d scales = Vec2d(newWindowSize.x / standardSize.x, newWindowSize.y / standardSize.y);

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
