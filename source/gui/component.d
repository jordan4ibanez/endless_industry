module gui.component;

import gui.component_logic;
import math.vec2d;
import math.vec2i;
import raylib : Color, Colors, Vector2;
import std.math.rounding;
import utility.instance_of;

/*

Components use the same origin system that the window itself uses.

0,0 is the center of the work area.

*/

abstract class Component {
package:

    // The ID of this component.
    string componentID = null;

    // The draw function of the component.
    void function() draw = () {};

    // The logic function of the component.
    void function() logic = () {};

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

/// Some text to label something.
/// Keep in mind: The origin is the top left like everything else.
/// This allows it to stay scaled with everything properly. (easier for me to make)
class Label : Component {
package:
    /// What this label says on it.
    string __text = null;

public:

    //? These are special property functions.
    //? These automate the sizing of the actual label when assigned to.
    //? This makes less work for the end modder.

    @property string text() {
        return __text;
    }

    @property void text(string text) {
        import gui.font;
        import std.math.rounding;

        this.__text = text;
        const Vec2d textSize = FontHandler.__getTextSizeSpecialFixed(text);
        this.size.x = cast(int) round(textSize.x * 0.25);
        this.size.y = cast(int) round(textSize.y * 0.25);
    }

    /// The button text color.
    Color textColor = Colors.WHITE;

    this() {
        size = Vec2i(0, 0);
    }
}

/// An image to label something.
class ImageLabel : Component {
package:
    /// What image this image label uses.
    string __image = null;

public:

    //? These are special property functions.
    //? These automate the sizing of the actual label when assigned to.
    //? This makes less work for the end modder.

    @property string image() {
        return __image;
    }

    @property void image(string image) {
        import graphics.texture;

        this.__image = image;
        OutputRect rect = TextureHandler.getTextureRectangle(image);
        this.size.x = rect.w;
        this.size.y = rect.h;
    }

    /// The button text color.
    Color textColor = Colors.WHITE;

    //? Functions/methods.

    this() {
        size = Vec2i(0, 0);
    }

    void scaleX(double size) {
        this.size.x = cast(int) round(this.size.x * size);
    }

    void scaleY(double size) {
        this.size.y = cast(int) round(this.size.y * size);
    }

    void scale(double size) {
        this.size.x = cast(int) round(this.size.x * size);
        this.size.y = cast(int) round(this.size.y * size);
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

class CheckBox : Component {
    /// What this check box says on it.
    string text = null;

    //? State behavior.

    /// If the mouse is hovering over the check box.
    bool mouseHovering = false;

    /// If the check box is checked.
    bool checked = false;

    //? General solid colors.

    /// The border color of the check box.
    Color borderColor = Colors.BLACK;
    /// The border color of the check box when hovered over.
    Color borderColorHover = Colors.BLACK;

    /// The background color of the check box.
    Color backgroundColor = Colors.LIGHTGRAY;
    /// The background color of the check box when hovered over.
    Color backgroundColorHover = Colors.MAGENTA;

    /// The inner circle color when the check box is checked.
    Color checkCircleColor = Colors.RED;

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
    /// The background color of the menu when hovered over.
    Color backgroundColorHover = Colors.MAGENTA;

    /// The text color.
    Color textColor = Colors.WHITE;
    /// The placeholder text color.
    Color placeholderTextColor = Colors.DARKGRAY;

    /// The drop triangle color indicator on the right.
    Color dropTriangleColor = Colors.WHITE;

    //? Functions/methods.

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
    }

}

class InventoryGUI : Component {
    import game.inventory;

package:
    int newSize = 0;
    int oldSize = -1;

    /// Which inventory this component is attached to.
    Inventory __inventory = Inventory(0);

    // todo: needs a function to calculate the size of the inventory.
    // todo: a function property for setting the inventory.

    /// This function makes it so this thing can automatically resize itself to
    /// fit a resized inventory on the fly.
    void calculateSize() {
        if (newSize == oldSize) {
            return;
        }
        const int invWidth = __inventory.getWidth();
        const int invHeight = cast(int) ceil(
            cast(double) __inventory.getSize() / cast(double) invWidth);
        size.x = (48 * invWidth) + (4 * (invWidth - 1));
        size.y = (48 * invHeight) + (4 * (invHeight - 1));
        newSize = __inventory.getSize();
        oldSize = newSize;
    }

public:
    //? State behavior.

    /// Which slot the mouse is hovering over.
    int mouseHovering = -1;

    @property void inventory(Inventory inventory) {
        __inventory = inventory;
        calculateSize();
    }

    @property Inventory inventory() {
        return __inventory;
    }

    //? General text/icon colors.

    /// The border color.
    Color borderColor = Colors.BLACK;
    /// The border color when hovered over.
    Color borderColorHover = Colors.BLACK;

    /// The background color of the slot.
    Color slotColor = Colors.DARKGRAY;
    /// The background color of the slot when hovered over.
    Color slotColorHover = Colors.MAGENTA;

    //? Functions/methods.

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
    }

}
