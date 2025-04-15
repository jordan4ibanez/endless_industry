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
}

class Button : Component {
    /// What this button says on it.
    string buttonText = null;

    //? State behavior.

    /// The size of the button.
    Vec2i size = Vec2i(100, 32);

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

    /// What the button does when clicked.
    /// By default, this does nothing.
    void function() clickFunction = () {};

    /// Center the X position.
    void centerX() {
        this.position.x = this.size.x * -0.5;
    }
}
