module gui.component_draw_functions;

import gui.component_logic_functions;
import gui.gui;
import math.vec2i;

//? Component
abstract class ComponentDrawFunctions : ComponentLogicFunctions {
package:

    // The draw facade function of the component.
    void draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent) {

    }

protected:

    // The draw function of the component.
    abstract void __draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent);
}

//? Label.
abstract class LabelDrawFunctions : ComponentDrawFunctions {
    LabelLogicFunctions logicFuns;
    alias logicFuns this;

protected:

    override void __draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent);
}

//? ImageLabel.
abstract class ImageLabelDrawFunctions : ComponentDrawFunctions {
    ImageLabelLogicFunctions logicFuns;
    alias logicFuns this;

protected:

    override void __draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent);
}

//? Button.
abstract class ButtonDrawFunctions : ComponentDrawFunctions {
    ButtonLogicFunctions logicFuns;
    alias logicFuns this;

protected:

    override void __draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent);
}

//? CheckBox.
abstract class CheckBoxDrawFunctions : ComponentDrawFunctions {
    CheckBoxLogicFunctions logicFuns;
    alias logicFuns this;

protected:

    override void __draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent);
}

//? TextPad.
abstract class TextPadDrawFunctions : ComponentDrawFunctions {
    TextPadLogicFunctions logicFuns;
    alias logicFuns this;

protected:

    override void __draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent);
}

//? TextBox.
abstract class TextBoxDrawFunctions : ComponentDrawFunctions {
    TextBoxLogicFunctions logicFuns;
    alias logicFuns this;

protected:

    override void __draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent);
}

//? DropMenu.
abstract class DropMenuDrawFunctions : ComponentDrawFunctions {
    DropMenuLogicFunctions logicFuns;
    alias logicFuns this;

protected:

    override void __draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent);
}

//? Inventory.
abstract class InventoryGUIDrawFunctions : ComponentDrawFunctions {
    InventoryGUILogicFunctions logicFuns;
    alias logicFuns this;

protected:

    override void __draw(const ref Vec2i center, const StartScissorFunction startScissorComponent,
        const EndScissorFunction endScissorComponent);
}
