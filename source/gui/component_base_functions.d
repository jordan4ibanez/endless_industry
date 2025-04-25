module gui.component_base_functions;

import gui.component_variables;
import gui.font;
import math.vec2d;
import math.vec2i;
import raylib : Vector2;
import std.math.rounding;

//? Component.
abstract class ComponentBaseFunctions : ComponentVars {

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
}

//? Label.
abstract class LabelBaseFunctions : ComponentBaseFunctions {
    LabelVariables vars;
    alias vars this;

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
}

//? ImageLabel.
abstract class ImageLabelBaseFunctions : ComponentBaseFunctions {
    ImageLabelVars vars;
    alias vars this;

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

    //? Functions/methods.

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

//? Button.
abstract class ButtonBaseFunctions : ComponentBaseFunctions {
    ButtonVars vars;
    alias vars this;
}

//? CheckBox.
abstract class CheckBoxBaseFunctions : ComponentBaseFunctions {
    CheckBoxVars vars;
    alias vars this;
}

//? TextPad.
abstract class TextPadBaseFunctions : ComponentBaseFunctions {
    TextPadVars vars;
    alias vars this;
}

//? TextBox.
abstract class TextBoxBaseFunctions : ComponentBaseFunctions {
    TextBoxVars vars;
    alias vars this;
}

//? DropMenu.
abstract class DropMenuBaseFunctions : ComponentBaseFunctions {
    DropMenuVars vars;
    alias vars this;
}

//? Inventory.
abstract class InventoryGUIBaseFunctions : ComponentBaseFunctions {
    InventoryGUIVars vars;
    alias vars this;

    import game.inventory;

package:

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
        oldSize = newSize;
    }

public:

    @property void inventory(Inventory inventory) {
        __inventory = inventory;
        newSize = inventory.getSize();
        calculateSize();
    }

    @property Inventory inventory() {
        return __inventory;
    }
}
