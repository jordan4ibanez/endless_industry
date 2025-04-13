module gui.gui;

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
    // If this is interactive and drawn.
    bool visible = true;

    // The higher the layer, the higher priority it has.
    // If it's a window and covers another window, it gets priority over the other if it's higher.
    // If they're the same priority, it's random.
    int layer = 0;

    // The behavior and styling this container will have.
    ContainerType type = ContainerType.Window;

    // This allows Windows to be moved around.
    Vec2d mouseDelta;

    // What this container is called.
    string containerName = null;

    // What this container's title says.
    string containerTitle = null;

    // If the mouse is hovering over the status bar.
    bool mouseHoveringStatusBar = false;

    // Position is top left of container.
    Vec2i position;
    Vec2i size;

    //? General solid colors.

    // The color of the work area.
    Color workAreaColor = Colors.GRAY;

    // The border color of the window. (All border components.)
    Color borderColor = Colors.BLACK;

    // The status bar background color.
    Color statusBarColor = Colors.BLUE;
    // The status bar background color when hovered over.
    Color statusBarHoverColor = Color(40, 100, 255, 255);

    // The close button background color.
    Color closeButtonBackgroundColor = Colors.DARKGRAY;

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
    double currentGUIScale = 1.0;
    double inverseCurrentGUIScale = 1.0;

    Container[string] interfaces;
    Container currentDrag = null;

public: //* BEGIN PUBLIC API.

    void drawVisible() {
        foreach (key, container; interfaces) {
            int posX = cast(int) floor(container.position.x * currentGUIScale);
            int posY = cast(int) floor(container.position.y * currentGUIScale);
            int sizeX = cast(int) floor(container.size.x * currentGUIScale);
            int sizeY = cast(int) floor(container.size.y * currentGUIScale);
            int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);

            // Stop from drawing out of bounds.
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

            // Capture excessively long window titles.
            BeginScissorMode(posX, posY, sizeX - 1, statusAreaHeight);

            const string title = container.containerTitle;
            if (title !is null) {
                FontHandler.draw(title, posX + (currentGUIScale * 2), posY, 0.25, container
                        .statusBarTextColor);
            }

            EndScissorMode();

        }
    }

    void updateGUIs() {
        bool mouseFocusedOnGUI = false;

        Vector2 mousePos = Mouse.getPosition().toRaylib();

        if (currentDrag !is null) {

            if (!Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                currentDrag = null;
                return;
            }

            mouseFocusedOnGUI = true;

            double scaledDeltaX = currentDrag.mouseDelta.x * inverseCurrentGUIScale;
            double scaledDeltaY = currentDrag.mouseDelta.y * inverseCurrentGUIScale;
            double scaledMousePosX = mousePos.x * inverseCurrentGUIScale;
            double scaledMousePosY = mousePos.y * inverseCurrentGUIScale;

            currentDrag.position.x = cast(int) floor(scaledDeltaX + scaledMousePosX);
            currentDrag.position.y = cast(int) floor(scaledDeltaY + scaledMousePosY);

        } else {

            foreach (key, container; interfaces) {
                int posX = cast(int) floor(container.position.x * currentGUIScale);
                int posY = cast(int) floor(container.position.y * currentGUIScale);
                int sizeX = cast(int) floor(container.size.x * currentGUIScale);
                int sizeY = cast(int) floor(container.size.y * currentGUIScale);

                Rectangle windowRectangle = Rectangle(posX, posY, sizeX, sizeY);

                container.mouseHoveringStatusBar = false;

                // No collision with this window occured.
                if (!CheckCollisionPointRec(mousePos, windowRectangle)) {
                    continue;
                }

                mouseFocusedOnGUI = true;

                int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);

                Rectangle statusBarRectangle = Rectangle(posX, posY, sizeX, statusAreaHeight);

                // If the mouse is not hovering over this but is still trying to do something so, continue.
                if (CheckCollisionPointRec(mousePos, statusBarRectangle)) {

                    container.mouseHoveringStatusBar = true;

                    // The mouse is not trying to drag a window.
                    // It is just hovering over a window.
                    if (!Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                        break;
                    }

                    // The mouse is now dragging a window.
                    container.mouseDelta = Vec2d(Vector2Subtract(Vector2(posX, posY), mousePos));
                    currentDrag = container;
                    break;
                }
            }
        }

        Mouse.__setFocusedOnGUI(mouseFocusedOnGUI);
    }

    void debugTest() {

        Container testContainer = new Container();

        testContainer.containerName = "Test container";
        testContainer.containerTitle = "a_really_long_title_that_should_stop_before_the_close_button";
        testContainer.size.x = 400;
        testContainer.size.y = 400;

        testContainer.position.x = 100;
        testContainer.position.y = 100;

        interfaces["testMenu"] = testContainer;

    }

    double getGUIScale() {
        return currentGUIScale;
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

        inverseCurrentGUIScale = 1.0 / currentGUIScale;

        FontHandler.__update();
        updateGUIs();
    }

private: //* BEGIN INTERNAL API.

}
