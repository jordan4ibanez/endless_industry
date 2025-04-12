module gui.gui;

import graphics.colors;
import math.vec2d;
import math.vec2i;

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

class Container {
    bool visible = true;

    // Position is top left of container.
    Vec2i position;
    Vec2i size;

    // The infill color of the window.
    Color infillColor = Colors.GRAY;
    // The border color of the window. (All border components.)
    Color borderColor = Colors.BLACK;

}

static final const class GUI {
static:
private:

    // We standardize the GUI with 1080p.
    const Vec2d standardSize = Vec2d(1920.0, 1080.0);
    double currentGUIScale = 1.0;

    Container[string] interfaces;

public: //* BEGIN PUBLIC API.

    double getGUIScale() {
        return currentGUIScale;
    }

    void __update(Vec2d newWindowSize) {
        // Find out which GUI scale is smaller so things can be scaled around it.

        Vec2d scales = Vec2d(newWindowSize.x / standardSize.x, newWindowSize.y / standardSize.y);

        if (scales.x >= scales.y) {
            currentGUIScale = scales.y;
        } else {
            currentGUIScale = scales.x;
        }
    }

private: //* BEGIN INTERNAL API.

}
