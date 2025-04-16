module gui.component;

import math.vec2d;
import math.vec2i;
import raylib : Color, Colors;

/*

Components use the same origin system that the window itself uses.

0,0 is the center of the work area.

*/

class Component {
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
        this.position.y = this.size.y * 0.5;
    }
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

class TextBox : Component {
    /// What this text box will say when there's no text entered.
    string placeholderText = "Nothing here";

    //? State behavior.

    /// If the mouse is hovering over.
    bool mouseHovering = false;

    //~ I'm doing it like this cause I have no idea what I'm doing.
    /// This holds the data of the current text entered into it.
    /// This can also be used as default text.
    /// It is held line by line.
    string currentText = "";

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

    /// The cursor color.
    Color cursorColor = Colors.RED;

    //? Functions/methods.

    this() {
        size = Vec2i(100, 100);
    }

}
