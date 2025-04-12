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

class Element {

}

// This is the basis of any GUI component, the container.
class Container {
    bool visible = true;

    // What this container is called.
    string containerName = null;

    // What this container's title says.
    string containerTitle = null;

    // Position is top left of container.
    Vec2i position;
    Vec2i size;

    // General solid colors.

    // The color of the work area.
    Color workAreaColor = Colors.GRAY;
    // The border color of the window. (All border components.)
    Color borderColor = Colors.BLACK;
    // The status bar background color.
    Color statusBarColor = Colors.BLUE;

    // General text colors.

    // The text below the status bar.
    Color workAreaTextColor = Colors.BLACK;
    // The status bar text color.
    Color statusBarTextColor = Colors.WHITE;
}

static final const class GUI {
static:
private:

    // We standardize the GUI with 1080p.
    const Vec2d standardSize = Vec2d(1920.0, 1080.0);
    double currentGUIScale = 1.0;

    Container[string] interfaces;

public: //* BEGIN PUBLIC API.

    void drawVisible() {
        foreach (key, container; interfaces) {
            int posX = cast(int) floor(container.position.x * currentGUIScale);
            int posY = cast(int) floor(container.position.y * currentGUIScale);
            int sizeX = cast(int) floor(container.size.x * currentGUIScale);
            int sizeY = cast(int) floor(container.size.y * currentGUIScale);
            int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);

            // Work area background.
            DrawRectangle(posX, posY, sizeX, sizeY, container.workAreaColor);
            // Status area background.
            DrawRectangle(posX, posX, sizeX, statusAreaHeight, container.statusBarColor);

            // Work area outline.
            DrawRectangleLines(posX, posY, sizeX, sizeY, container.borderColor);

            // Status area outline.
            DrawRectangleLines(posX, posY, sizeX, statusAreaHeight, container.borderColor);

            const string title = container.containerTitle;
            if (title !is null) {
                FontHandler.draw(title, posX + (currentGUIScale * 2), posY, 0.25, container
                        .statusBarTextColor);
            }
        }
    }

    void updateGUIs() {
        bool mouseFocusedOnGUI = false;

        Mouse.__setFocusedOnGUI(mouseFocusedOnGUI);
    }

    void debugTest() {

        Container testContainer = new Container();

        testContainer.containerName = "Test container";
        testContainer.containerTitle = "Test Container";
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

        FontHandler.__update();
        updateGUIs();
    }

private: //* BEGIN INTERNAL API.

}
