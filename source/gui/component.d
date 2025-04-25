module gui.component;

import gui.component_base_functions;
import gui.component_draw_functions;
import gui.component_logic_functions;
import gui.component_variables;
import gui.gui;
import math.vec2d;
import math.vec2i;
import raylib : Color, Colors, Vector2;
import std.math.rounding;
import utility.instance_of;

/*

Components use the same origin system that the window itself uses.

0,0 is the center of the work area.

*/

abstract class Component : ComponentDrawFunctions {
public:

    //? Delegates.

    /// This is run when the window gets resized.
    /// Please note: You are getting the work area size.
    void function(Component, Vec2i) onWindowResize = (Component self, Vec2i newWorkAreaSize) {
    };

    /// This is run when the window gets closed.
    void function(Component) onWindowClose = (Component self) {};
}

/// Some text to label something.
/// Keep in mind: The origin is the top left like everything else.
/// This allows it to stay scaled with everything properly. (easier for me to make)
class Label : Component {
    LabelDrawFunctions drawFuns;
    alias drawFuns this;

    this() {
        size = Vec2i(0, 0);
        // draw = &drawLabel;
    }
}

/// An image to label something.
class ImageLabel : Component {
    ImageLabelDrawFunctions drawFuns;
    alias drawFuns this;

    this() {
        size = Vec2i(0, 0);
        // draw = &drawImageLabel;
    }
}

/// You click it.
class Button : Component {
    ButtonDrawFunctions drawFuns;
    alias drawFuns this;

    //? Delegates.

    /// What the button does when clicked.
    /// By default, this does nothing.
    void function() clickFunction = () {};

    this() {
        size = Vec2i(100, 32);
        // logic = &buttonLogic;
        // draw = &drawButton;
    }
}

/// You check it. Boolean state.
class CheckBox : Component {
    CheckBoxDrawFunctions drawFuns;
    alias drawFuns this;

    //? Delegates.

    /// What the check box does when clicked.
    /// By default, this does nothing.
    void function() clickFunction = () {};

    this() {
        size = Vec2i(100, 32);
        // logic = &checkBoxLogic;
        // draw = &drawCheckBox;
    }
}

class TextPad : Component {
    TextPadDrawFunctions drawFuns;
    alias drawFuns this;

    //? Delegates.

    this() {
        size = Vec2i(100, 100);
        // logic = &textPadLogic;
        // draw = &drawTextPad;
    }
}

class TextBox : Component {
    TextBoxDrawFunctions drawFuns;
    alias drawFuns this;

    //? Delegates.

    this() {
        size = Vec2i(200, 32);
        // logic = &textBoxLogic;
        // draw = &drawTextBox;
    }
}

/// In webdev, this is called "Dropdown menu".
class DropMenu : Component {
    DropMenuDrawFunctions drawFuns;
    alias drawFuns this;

    //? Delegates.

    /// What the menu does when clicked.
    /// By default, this does nothing.
    void function(DropMenu) clickFunction = (DropMenu self) {};

    /// What the menu does when opened.
    /// By default, this does nothing.
    void function(DropMenu) onOpen = (DropMenu self) {};

    /// What the menu does when closed.
    /// By default, this does nothing.
    void function(DropMenu) onClose = (DropMenu self) {};

    this() {
        size = Vec2i(200, 32);
        // logic = &dropMenuLogic;
        // draw = &drawDropMenu;
    }
}

/// An inventory.
class InventoryGUI : Component {
    InventoryGUIDrawFunctions drawFuns;
    alias drawFuns this;

    //? Delegates.

    /// What the slot does when clicked.
    /// By default, this does nothing.
    void function(InventoryGUI) clickFunction = (InventoryGUI self) {};

    /// What the slot does when opened.
    /// By default, this does nothing.
    void function(InventoryGUI) onOpen = (InventoryGUI self) {};

    /// What the slot does when closed.
    /// By default, this does nothing.
    void function(InventoryGUI) onClose = (InventoryGUI self) {};

    this() {
        size = Vec2i(200, 20);
        // logic = &inventoryLogic;
        // draw = &drawInventory;
    }
}
