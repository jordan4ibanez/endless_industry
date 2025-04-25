module gui.component_logic_functions;

import gui.component_base_functions;
import math.vec2i;
import raylib : Vector2;

//? Component.
abstract class ComponentLogicFunctions : ComponentBaseFunctions {
package:

    // The logic facade function of the component.
    bool logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput) {
        return __logic(center, mousePos, keyboardDoingTextInput);
    }

protected:

    // The logic function of the component.
    abstract bool __logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput);
}

//? Label.
abstract class LabelLogicFunctions : ComponentLogicFunctions {
    LabelBaseFunctions baseFuns;
    alias baseFuns this;

protected:

    // The logic function of the component.
    override bool __logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput);
}

//? ImageLabel.
abstract class ImageLabelLogicFunctions : ComponentLogicFunctions {
    ImageLabelBaseFunctions baseFuns;
    alias baseFuns this;

protected:

    // The logic function of the component.
    override bool __logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput);
}

//? Button.
abstract class ButtonLogicFunctions : ComponentLogicFunctions {
    ButtonBaseFunctions baseFuns;
    alias baseFuns this;

protected:

    // The logic function of the component.
    override bool __logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput);
}

//? CheckBox.
abstract class CheckBoxLogicFunctions : ComponentLogicFunctions {
    CheckBoxBaseFunctions baseFuns;
    alias baseFuns this;

protected:

    // The logic function of the component.
    override bool __logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput);
}

//? TextPad.
abstract class TextPadLogicFunctions : ComponentLogicFunctions {
    TextPadBaseFunctions baseFuns;
    alias baseFuns this;

protected:

    // The logic function of the component.
    override bool __logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput);
}

//? TextBox.
abstract class TextBoxLogicFunctions : ComponentLogicFunctions {
    TextBoxBaseFunctions baseFuns;
    alias baseFuns this;

protected:

    // The logic function of the component.
    override bool __logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput);
}

//? DropMenu.
abstract class DropMenuLogicFunctions : ComponentLogicFunctions {
    DropMenuBaseFunctions baseFuns;
    alias baseFuns this;

protected:

    // The logic function of the component.
    override bool __logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput);
}

//? Inventory.
abstract class InventoryGUILogicFunctions : ComponentLogicFunctions {
    InventoryGUIBaseFunctions baseFuns;
    alias baseFuns this;

protected:

    // The logic function of the component.
    override bool __logic(const ref Vec2i center, const ref Vector2 mousePos, ref bool keyboardDoingTextInput);
}
