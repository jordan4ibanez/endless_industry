module gui.component_variables;

import math.vec2d;
import math.vec2i;
import raylib : Color, Colors;

//? Component.
abstract class ComponentVars {
package:

    // The ID of this component.
    string componentID = null;

public:

    // The position this component has in the window's work area.
    Vec2d position;

    /// The size of the button.
    Vec2i size = Vec2i(100, 100);
}

//? Label.
abstract class LabelVariables : ComponentVars {
package:
    /// What this label says on it.
    string __text = null;

public:

    /// The button text color.
    Color textColor = Colors.WHITE;
}

//? ImageLabel.
abstract class ImageLabelVars : ComponentVars {
package:

    /// What image this image label uses.
    string __image = null;

public:

    /// The button text color.
    Color textColor = Colors.WHITE;
}

//? Button.
abstract class ButtonVars : ComponentVars {

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
}

//? CheckBox.
abstract class CheckBoxVars : ComponentVars {
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
}

//? TextPad.
abstract class TextPadVars : ComponentVars {
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
}

//? TextBox.
abstract class TextBoxVars : ComponentVars {
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
}

//? DropMenu.
abstract class DropMenuVars : ComponentVars {
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
}

abstract class InventoryGUIVars : ComponentVars {
    import game.inventory;

package:
    int newSize = 0;
    int oldSize = -1;

    /// Which inventory this component is attached to.
    Inventory __inventory = Inventory(0);

public:
    //? State behavior.

    /// Which slot the mouse is hovering over.
    int mouseHovering = -1;

    //? General text/icon colors.

    /// The border color.
    Color borderColor = Colors.BLACK;
    /// The border color when hovered over.
    Color borderColorHover = Colors.BLACK;

    /// The background color of the slot.
    Color slotColor = Colors.DARKGRAY;
    /// The background color of the slot when hovered over.
    Color slotColorHover = Colors.MAGENTA;

}
