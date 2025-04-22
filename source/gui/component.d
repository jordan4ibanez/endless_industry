module gui.component;

import math.vec2d;
import math.vec2i;
import raylib : Color, Colors;
import utility.instance_of;

/*

Components use the same origin system that the window itself uses.

0,0 is the center of the work area.

*/

abstract class Component {
package:

    // The ID of this component.
    string componentID = null;

public:

    // The position this component has in the window's work area.
    Vec2d position;

    /// The size of the button.
    Vec2i size = Vec2i(100, 100);

    /// Center the X position.
    void centerX() {
        this.position.x = this.size.x * -0.5;
    }

    /// Center the Y position.
    void centerY() {
        this.position.y = (this.size.y * 0.5) - 16;
    }

    /// Center both X and Y position;
    void center() {
        this.position.x = this.size.x * -0.5;
        this.position.y = (this.size.y * 0.5) - 16;
    }

    /// This is run when the window gets resized.
    /// Please note: You are getting the work area size.
    void function(Component, Vec2i) onWindowResize = (Component self, Vec2i newWorkAreaSize) {
    };

    /// This is run when the window gets closed.
    void function(Component) onWindowClose = (Component self) {};
}

class Button : Component {
    /// What this button says on it.
    string text = null;

    //? State behavior.

    /// If the mouse is hovering over the button.
    bool mouseHovering = false;

    //? General solid colors.

    /// The border color of the button.
    Color borderColor = Colors.BLACK;
    /// The border color of the button when hovered over.
    Color borderColorHover = Colors.BLACK;

    /// The background color of the button.
    Color backgroundColor = Colors.LIGHTGRAY;
    /// The background color of the button when hovered over.
    Color backgroundColorHover = Colors.MAGENTA;

    //? General text/icon colors.

    /// The button text color.
    Color textColor = Colors.WHITE;

    //? Functions/methods.

    /// What the button does when clicked.
    /// By default, this does nothing.
    void function() clickFunction = () {};

    this() {
        size = Vec2i(100, 32);
    }

}

class CheckBox : Component {
    /// What this check box says on it.
    string text = null;

    //? State behavior.

    /// If the mouse is hovering over the check box.
    bool mouseHovering = false;

    //? General solid colors.

    /// The border color of the check box.
    Color borderColor = Colors.BLACK;
    /// The border color of the check box when hovered over.
    Color borderColorHover = Colors.BLACK;

    /// The background color of the check box.
    Color backgroundColor = Colors.LIGHTGRAY;
    /// The background color of the check box when hovered over.
    Color backgroundColorHover = Colors.MAGENTA;

    //? General text/icon colors.

    /// The check box text color.
    Color textColor = Colors.WHITE;

    //? Functions/methods.

    /// What the check box does when clicked.
    /// By default, this does nothing.
    void function() clickFunction = () {};

    this() {
        size = Vec2i(100, 32);
    }

}

class TextPad : Component {

    //? State behavior.

    /// If the mouse is hovering over.
    bool mouseHovering = false;

    /// This holds the data of the current text entered into it.
    string text = "";
    /// What this text pad will say when there's no text entered.
    string placeholderText = "Nothing here";

    /// Where the cursor is in the text.
    int cursorPosition = 0;

    //? General text/icon colors.

    /// The border color.
    Color borderColor = Colors.BLACK;
    /// The border color when hovered over.
    Color borderColorHover = Colors.RED;

    /// The background color.
    Color backgroundColor = Colors.WHITE;

    /// The text color.
    Color textColor = Colors.BLACK;
    /// The placeholder text color.
    Color placeholderTextColor = Colors.GRAY;

    /// The cursor color.
    Color cursorColor = Colors.RED;

    //? Functions/methods.

    this() {
        size = Vec2i(100, 100);
    }

}

class TextBox : Component {

    //? State behavior.

    /// If the mouse is hovering over.
    bool mouseHovering = false;

    /// This holds the data of the current text entered into it.
    string text = "";
    /// What this text box will say when there's no text entered.
    string placeholderText = "Nothing here";

    /// The maximum amount of characters this text box can have.
    ulong maxCharacters = 16;

    /// Where the cursor is in the text.
    int cursorPosition = 0;

    //? General text/icon colors.

    /// The border color.
    Color borderColor = Colors.BLACK;
    /// The border color when hovered over.
    Color borderColorHover = Colors.RED;

    /// The background color.
    Color backgroundColor = Colors.WHITE;

    /// The text color.
    Color textColor = Colors.BLACK;
    /// The placeholder text color.
    Color placeholderTextColor = Colors.GRAY;

    /// The cursor color.
    Color cursorColor = Colors.RED;

    //? Functions/methods.

    this() {
        size = Vec2i(200, 32);
    }

}

/// In webdev, this is called "Dropdown menu".
class DropMenu : Component {

    //? State behavior.

    /// If the mouse is hovering over.
    bool mouseHovering = false;

    /// This holds the items to select.
    string[] items = [];

    /// This is the current selection.
    int selection = 0;
    /// This is the current hover selection.
    int hoverSelection = -1;

    /// What this text box will say when there's no text entered.
    string placeholderText = null;

    /// If the drop down menu is...dropped down.
    bool droppedDown = false;

    //? General text/icon colors.

    /// The border color.
    Color borderColor = Colors.BLACK;
    /// The border color when hovered over.
    Color borderColorHover = Colors.BLACK;

    /// The background color.
    Color backgroundColor = Colors.LIGHTGRAY;
    /// The background color of the button when hovered over.
    Color backgroundColorHover = Colors.MAGENTA;

    /// The text color.
    Color textColor = Colors.WHITE;
    /// The placeholder text color.
    Color placeholderTextColor = Colors.DARKGRAY;

    /// The drop triangle color indicator on the right.
    Color dropTriangleColor = Colors.WHITE;

    //? Functions/methods.

    /// What the button does when clicked.
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
    }

}
