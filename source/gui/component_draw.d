module gui.component_draw;

import gui.component;
import gui.font;
import gui.gui;
import math.vec2d;
import math.vec2i;
import raylib : Color, Colors, DrawCircle, DrawCircleLines, DrawRectangle, DrawRectangleLines, DrawTriangle,
    DrawTriangleLines, Vector2;
import game.inventory;
import game.item_database;
import graphics.render;
import graphics.texture;
import std.conv;
import std.math.rounding;

package:

///? Base component.
void drawComponent(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {
}

///? Label.
void drawLabel(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {

    const Label label = cast(Label) __self;
    //~ This can sometimes be 1 pixel off, but I tried my best.
    const int posX = cast(int) floor(
        (label.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-label.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) round(label.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) round(label.size.y * GUI.currentGUIScale);

    if (startScissorComponent(posX, posY, sizeX, sizeY)) {
        return;
    }

    //! This is the debug box for the actual label.
    // DrawRectangleLines(
    //     posX,
    //     posY,
    //     sizeX,
    //     sizeY,
    //     Colors.BLACK);
    FontHandler.drawShadowed(label.__text, posX, posY, 0.25, label.textColor);
    endScissorComponent();
}

///? ImageLabel.
void drawImageLabel(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {
    import graphics.texture;

    const ImageLabel imageLabel = cast(ImageLabel) __self;

    //~ This can sometimes be 1 pixel off, but I tried my best.
    const int posX = cast(int) floor(
        (imageLabel.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-imageLabel.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) round(imageLabel.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) round(imageLabel.size.y * GUI.currentGUIScale);
    if (startScissorComponent(posX, posY, sizeX, sizeY)) {
        return;
    }
    TextureHandler.drawTexture(imageLabel.__image, Vec2d(posX, -posY), Vec2d(sizeX, sizeY));
    //! This is the debug box for the actual image label.
    // DrawRectangleLines(
    //     posX,
    //     posY,
    //     sizeX,
    //     sizeY,
    //     Colors.BLACK);
    endScissorComponent();
}

///? Button.
void drawButton(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {
    const Button button = cast(Button) __self;
    const int posX = cast(int) floor(
        (button.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-button.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(button.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(button.size.y * GUI.currentGUIScale);
    if (startScissorComponent(posX, posY, sizeX, sizeY)) {
        return;
    }
    Color buttonColor = (button.mouseHovering) ? button.backgroundColorHover
        : button.backgroundColor;
    Color borderColor = (button.mouseHovering) ? button.borderColorHover : button.borderColor;
    DrawRectangle(
        posX,
        posY,
        sizeX,
        sizeY,
        buttonColor);
    const string title = (button.text is null) ? "UNDEFINED" : button.text;
    const int adjustment = cast(int) floor(
        (sizeX * 0.5) - (FontHandler.getTextSize(title, 0.25)
            .x * 0.5));
    FontHandler.drawShadowed(
        title,
        posX + adjustment,
        posY,
        0.25,
        button.textColor);
    DrawRectangleLines(
        posX,
        posY,
        sizeX,
        sizeY,
        borderColor);
    endScissorComponent();
}

///? CheckBox.
void drawCheckBox(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {
    const CheckBox checkBox = cast(CheckBox) __self;
    const int posX = cast(int) floor(
        (checkBox.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-checkBox.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(checkBox.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(checkBox.size.y * GUI.currentGUIScale);
    const int statusAreaHeight = cast(int) floor(GUI.currentGUIScale * 32.0);
    // Initial check to see if this thing should even be drawn.
    if (startScissorComponent(posX, posY, sizeX, sizeY)) {
        return;
    }
    // First, draw what is basically a regular button.
    startScissorComponent(posX, posY, sizeX - statusAreaHeight, sizeY);
    Color buttonColor = (checkBox.mouseHovering) ? checkBox.backgroundColorHover
        : checkBox.backgroundColor;
    Color borderColor = (checkBox.mouseHovering) ? checkBox.borderColorHover : checkBox.borderColor;
    DrawRectangle(
        posX,
        posY,
        sizeX - statusAreaHeight,
        sizeY,
        buttonColor);
    const string title = (checkBox.text is null) ? "UNDEFINED" : checkBox.text;
    // Attempt to center this into the "mini button".
    const int adjustment = cast(int) floor(
        (sizeX * 0.5) - (FontHandler.getTextSize(title, 0.25)
            .x * 0.5)) - (statusAreaHeight / 2);
    FontHandler.drawShadowed(
        title,
        posX + adjustment,
        posY,
        0.25,
        checkBox.textColor);
    DrawRectangleLines(
        posX,
        posY,
        sizeX - statusAreaHeight,
        sizeY,
        borderColor);

    // Next, draw a toggle indicator.
    startScissorComponent(posX + sizeX - statusAreaHeight, posY, statusAreaHeight, sizeY);

    // Infill the background.
    DrawRectangle(
        posX + sizeX - statusAreaHeight,
        posY,
        statusAreaHeight,
        statusAreaHeight,
        buttonColor
    );

    const int halfHeight = statusAreaHeight / 2;
    const int thirdHeight = statusAreaHeight / 3;

    // Outer circle.
    DrawCircle(
        posX + sizeX - halfHeight,
        posY + halfHeight,
        thirdHeight,
        checkBox.backgroundColor
    );
    DrawCircleLines(
        posX + sizeX - halfHeight,
        posY + halfHeight,
        thirdHeight,
        borderColor
    );

    // Draw the internal circle (if checked).
    if (checkBox.checked) {
        const int fifthHeight = statusAreaHeight / 5;
        DrawCircle(
            posX + sizeX - halfHeight,
            posY + halfHeight,
            fifthHeight,
            checkBox.checkCircleColor
        );
        DrawCircleLines(
            posX + sizeX - halfHeight,
            posY + halfHeight,
            fifthHeight,
            borderColor
        );
    }

    // Then make it look nice with a border.
    DrawRectangleLines(
        posX + sizeX - statusAreaHeight,
        posY,
        statusAreaHeight,
        statusAreaHeight,
        borderColor
    );

    endScissorComponent();
}

///? TextPad.
void drawTextPad(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {
    const TextPad textPad = cast(TextPad) __self;
    const int posX = cast(int) floor(
        (textPad.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-textPad.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(textPad.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(textPad.size.y * GUI.currentGUIScale);
    if (startScissorComponent(posX, posY, sizeX, sizeY)) {
        return;
    }
    DrawRectangle(
        posX,
        posY,
        sizeX,
        sizeY,
        textPad.backgroundColor);
    // This is ultra extremely inefficient.
    // But, it works, probably.
    double currentWidth = 0;
    double width = 0;
    int currentHeight = 0;
    ulong currentIndexInString = 0;
    bool usePlaceHolder = (textPad.text is null || textPad.text.length == 0);
    const string text = (usePlaceHolder) ? textPad.placeholderText : textPad.text;
    const ulong lastIndex = (text.length == 0) ? 0 : (text.length) - 1;
    const Color textColor = (usePlaceHolder) ? textPad.placeholderTextColor : textPad.textColor;
    if (text is null || text.length <= 0) {
        goto SKIP_DRAW_TEXT_IN_PAD;
    }
    for (int i = 0; i < text.length; i++) {
        bool shouldDrawCursor() {
            return GUI.cursorVisible && GUI.focusedComponent == textPad && textPad.cursorPosition == i;
        }

        const char thisChar = text[i];
        width = FontHandler.getCharWidth(thisChar, 0.25);
        currentWidth += width;
        bool skipDrawCursor = false;
        if (thisChar == '\n') {
            // If newline is reached, it must jump over it.
            FontHandler.draw(text[currentIndexInString .. i], posX, posY + currentHeight,
                0.25, textColor);
            //? This needs to be inline because \n creates some complex situations.
            if (shouldDrawCursor()) {
                double w = currentWidth - width;
                if (w < 0) {
                    w = 0;
                }
                DrawRectangle(
                    cast(int) floor(posX + w + (GUI.currentGUIScale * 0.5)),
                    posY + currentHeight,
                    cast(int) floor(2 * GUI.currentGUIScale),
                    cast(int) floor(32 * GUI.currentGUIScale),
                    Colors.BLUE);
                skipDrawCursor = true;
            }
            currentHeight += cast(int) floor(32 * GUI.currentGUIScale);
            currentWidth = 0;
            currentIndexInString = i + 1;
        } else if (currentWidth >= sizeX) {
            FontHandler.draw(text[currentIndexInString .. i], posX, posY + currentHeight,
                0.25, textColor);
            currentWidth = width;
            currentHeight += cast(int) floor(32 * GUI.currentGUIScale);
            currentIndexInString = i;
        }
        // Catch all.
        if (i == lastIndex) {
            FontHandler.draw(text[currentIndexInString .. i + 1], posX, posY + currentHeight,
                0.25, textColor);
        }
        // Draw the cursor if the current focus is on this text pad.
        // This will draw it before the current character.
        //! Note: this will cause issues with newlines.
        //! You cannot select the last character visually in the line.
        //! It will just skip to the next line.
        //! It still works the same though. Oh well.
        if (!skipDrawCursor && shouldDrawCursor()) {
            double w = currentWidth - width;
            if (w < 0) {
                w = 0;
            }
            DrawRectangle(
                cast(int) floor(posX + w + (GUI.currentGUIScale * 0.5)),
                posY + currentHeight,
                cast(int) floor(2 * GUI.currentGUIScale),
                cast(int) floor(32 * GUI.currentGUIScale),
                Colors.BLUE);
        }
        // if (true) {
        //     DrawRectangleLines(
        //         cast(int) floor(posX + (currentWidth - width)),
        //         posY + currentHeight,
        //         cast(int) floor(width),
        //         cast(int) floor(32 * currentGUIScale),
        //         Colors.BLUE);
        //     FontHandler.draw(to!string(i), posX + (currentWidth - width), posY + currentHeight,
        //         0.05, Colors.GREEN);
        // }
    }

SKIP_DRAW_TEXT_IN_PAD:

    // If the text pad cursor is at the literal last position, it needs to be drawn here.
    if (!usePlaceHolder && GUI.cursorVisible && GUI.focusedComponent == textPad && textPad
        .cursorPosition == textPad
        .text.length) {
        const double w = currentWidth;
        DrawRectangle(
            cast(int) floor(posX + w + (GUI.currentGUIScale * 0.5)),
            posY + currentHeight,
            cast(int) floor(2 * GUI.currentGUIScale),
            cast(int) floor(32 * GUI.currentGUIScale),
            Colors.BLUE);
    }
    const Color borderColor = textPad.mouseHovering ? textPad.borderColorHover : textPad
        .borderColor;
    DrawRectangleLines(
        posX,
        posY,
        sizeX,
        sizeY,
        borderColor);
    endScissorComponent();
}

///? TextBox.
void drawTextBox(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {

    const TextBox textBox = cast(TextBox) __self;

    const int posX = cast(int) floor(
        (textBox.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-textBox.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(textBox.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(textBox.size.y * GUI.currentGUIScale);
    if (startScissorComponent(posX, posY, sizeX, sizeY)) {
        return;
    }
    DrawRectangle(
        posX,
        posY,
        sizeX,
        sizeY,
        textBox.backgroundColor);
    // This is ultra extremely inefficient.
    // But, it works, probably.
    double currentWidth = 0;
    double width = 0;
    bool usePlaceHolder = (textBox.text is null || textBox.text.length == 0);
    const string text = (usePlaceHolder) ? textBox.placeholderText : textBox.text;
    const Color textColor = (usePlaceHolder) ? textBox.placeholderTextColor : textBox.textColor;
    int adjustment = 0;
    const double totalSize = FontHandler.getTextSize(textBox.text, 0.25).x;

    if (text is null || text.length <= 0) {
        goto SKIP_DRAW_TEXT_IN_BOX;
    }

    if (totalSize > sizeX) {
        adjustment = cast(int) round((totalSize - sizeX) + (3 * GUI.currentGUIScale));
    }
    FontHandler.draw(text, posX - adjustment, posY, 0.25, textColor);
    for (int i = 0; i < text.length; i++) {
        bool shouldDrawCursor() {
            return GUI.cursorVisible && GUI.focusedComponent == textBox && textBox.cursorPosition == i;
        }

        const char thisChar = text[i];
        width = FontHandler.getCharWidth(thisChar, 0.25);
        currentWidth += width;
        // Draw the cursor if the current focus is on this text pad.
        // This will draw it before the current character.
        if (shouldDrawCursor()) {
            double w = currentWidth - width;
            if (w < 0) {
                w = 0;
            }
            DrawRectangle(
                cast(int) floor(posX + w + (GUI.currentGUIScale * 0.5)) - adjustment,
                posY,
                cast(int) floor(2 * GUI.currentGUIScale),
                cast(int) floor(32 * GUI.currentGUIScale),
                Colors.BLUE);
        }
        // if (true) {
        //     DrawRectangleLines(
        //         cast(int) floor(posX + (currentWidth - width)),
        //         posY,
        //         cast(int) floor(width),
        //         cast(int) floor(32 * currentGUIScale),
        //         Colors.BLUE);
        //     FontHandler.draw(to!string(i), posX + (currentWidth - width), posY,
        //         0.05, Colors.GREEN);
        // }
    }

SKIP_DRAW_TEXT_IN_BOX:

    // If the text pad cursor is at the literal last position, it needs to be drawn here.
    if (!usePlaceHolder && GUI.cursorVisible && GUI.focusedComponent == textBox && textBox
        .cursorPosition == textBox
        .text.length) {
        const double w = currentWidth;
        DrawRectangle(
            cast(int) floor(posX + w + (GUI.currentGUIScale * 0.5)) - adjustment,
            posY,
            cast(int) floor(2 * GUI.currentGUIScale),
            cast(int) floor(32 * GUI.currentGUIScale),
            Colors.BLUE);
    }
    const Color borderColor = textBox.mouseHovering ? textBox.borderColorHover : textBox
        .borderColor;
    DrawRectangleLines(
        posX,
        posY,
        sizeX,
        sizeY,
        borderColor);
    endScissorComponent();
}

//? DropMenu.
void drawDropMenu(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {
    const DropMenu dropMenu = cast(DropMenu) __self;
    const int posX = cast(int) floor(
        (dropMenu.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-dropMenu.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(dropMenu.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(dropMenu.size.y * GUI.currentGUIScale);
    const int statusAreaHeight = cast(int) floor(GUI.currentGUIScale * 32.0);

    // At the expense of talking to the GPU twice, check if the entire are is rendered.
    if (startScissorComponent(posX, posY, sizeX, sizeY)) {
        return;
    }

    // Now do the real scissor.
    // Drawing the button text portion.
    startScissorComponent(posX, posY, sizeX - statusAreaHeight, sizeY);

    const Color borderColor = (dropMenu.mouseHovering) ? dropMenu.borderColorHover
        : dropMenu.borderColor;

    const Color dropMenuColor = (dropMenu.mouseHovering) ? dropMenu.backgroundColorHover
        : dropMenu.backgroundColor;

    DrawRectangle(
        posX,
        posY,
        sizeX - statusAreaHeight,
        sizeY,
        dropMenuColor);

    const bool usePlaceHolder = (dropMenu.selection < 0 || dropMenu.selection >= dropMenu
            .items.length);

    const string title = (usePlaceHolder) ? ((dropMenu.placeholderText is null) ? "UNDEFINED"
            : dropMenu.placeholderText) : dropMenu.items[dropMenu.selection];

    FontHandler.drawShadowed(
        title,
        posX,
        posY,
        0.25,
        dropMenu.textColor);
    DrawRectangleLines(
        posX,
        posY,
        sizeX - statusAreaHeight,
        sizeY,
        borderColor);

    // Next, draw the icon that indicates this is a drop menu.
    startScissorComponent(posX + sizeX - statusAreaHeight, posY, statusAreaHeight, sizeY);

    const double __triPadding = (GUI.currentGUIScale * 4);

    // Hold precalculations on the stack.
    const Vector2[3] triPoints = [
        Vector2(round(posX + sizeX - statusAreaHeight + __triPadding), round(
                posY + __triPadding)),
        Vector2(round(posX + sizeX - __triPadding), round(posY + __triPadding)),
        Vector2(round(posX + sizeX - (statusAreaHeight / 2.0)) - 0.25, round(
                posY + statusAreaHeight - __triPadding))
    ];

    // Infill the background.

    DrawRectangle(
        posX + sizeX - statusAreaHeight,
        posY,
        statusAreaHeight,
        statusAreaHeight,
        dropMenuColor
    );

    // Then draw the triangle.

    DrawTriangle(
        triPoints[0],
        triPoints[1],
        triPoints[2],
        dropMenu.dropTriangleColor
    );

    DrawTriangleLines(
        triPoints[0],
        triPoints[1],
        triPoints[2],
        borderColor
    );

    // Then make it look nice with a border.
    DrawRectangleLines(
        posX + sizeX - statusAreaHeight,
        posY,
        statusAreaHeight,
        statusAreaHeight,
        borderColor
    );

    endScissorComponent();

    // If the menu is dropped down, each element must be drawn one by one.
    // This is extremely inefficient but, it is what it is.

    if (!dropMenu.droppedDown) {
        return;
    }

    const int incrementer = cast(int) floor(GUI.currentGUIScale);

    int yAdjustment = incrementer;
    ulong i = 0;
    foreach (__index, item; dropMenu.items) {
        if (__index == dropMenu.selection) {
            continue;
        }
        i++;
        const bool isSelected = dropMenu.hoverSelection == __index;
        const Color thisBorderColor = (isSelected) ? dropMenu.borderColorHover
            : dropMenu.borderColor;
        const Color thisSectionColor = (isSelected) ? dropMenu
            .backgroundColorHover : dropMenu.backgroundColor;

        const int yPos = (sizeY * cast(int) i) + yAdjustment;

        startScissorComponent(
            posX,
            posY + yPos,
            sizeX,
            sizeY);

        DrawRectangle(
            posX,
            posY + yPos,
            sizeX,
            sizeY,
            thisSectionColor
        );

        FontHandler.drawShadowed(
            item,
            posX,
            posY + yPos,
            0.25,
            dropMenu.textColor);

        DrawRectangleLines(
            posX,
            posY + yPos,
            sizeX,
            sizeY,
            thisBorderColor
        );

        yAdjustment += incrementer;
    }

    endScissorComponent();
}

///? Inventory.
void drawInventory(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {
    const InventoryGUI inv = cast(InventoryGUI) __self;
    const int posX = cast(int) floor(
        (inv.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-inv.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(cast(double) inv.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(cast(double) inv.size.y * GUI.currentGUIScale);

    if (startScissorComponent(posX, posY, sizeX, sizeY)) {
        return;
    }

    // This is literally an arbitrary number I came up with.
    const double slotSize = 48.0 * GUI.currentGUIScale;
    const double padding = 4.0 * GUI.currentGUIScale;

    // const int size = inv.__inventory.getSize();

    const ItemStack[] __itemsArray = inv.__inventory.getInventoryItems();
    const ItemStack* itemsPointer = __itemsArray.ptr;
    const int sizeInv = cast(int) __itemsArray.length;
    const int widthInv = inv.__inventory.getWidth();
    // const int rows = cast(int) ceil(cast(double) sizeInv / cast(double) widthInv);

    int currentColumn = 0;

    double currentWidth = 0;
    double currentHeight = 0;

    // Draw the slots of the inventory.
    foreach (i; 0 .. sizeInv) {

        const hovering = (inv.mouseHovering == i);

        const Color slotColor = (hovering) ? inv.slotColorHover : inv.slotColor;

        DrawRectangle(
            posX + cast(int) round(currentWidth),
            posY + cast(int) round(currentHeight),
            cast(int) floor(slotSize),
            cast(int) floor(slotSize),
            slotColor);

        currentWidth += (slotSize + padding);
        currentColumn++;
        if (currentColumn >= widthInv) {
            currentColumn = 0;
            currentWidth = 0;
            currentHeight += (slotSize + padding);
        }
    }

    currentColumn = 0;
    currentWidth = 0;
    currentHeight = 0;

    Render.startLineDrawBatch();

    foreach (i; 0 .. sizeInv) {

        const hovering = (inv.mouseHovering == i);

        const Color borderColor = (hovering) ? inv.borderColorHover : inv.borderColorHover;

        Render.setLineDrawColor(borderColor);

        Render.batchDrawRectangleLines(
            posX + cast(int) round(currentWidth),
            posY + cast(int) round(currentHeight),
            cast(int) floor(slotSize),
            cast(int) floor(slotSize));

        currentWidth += (slotSize + padding);
        currentColumn++;
        if (currentColumn >= widthInv) {
            currentColumn = 0;
            currentWidth = 0;
            currentHeight += (slotSize + padding);
        }
    }

    Render.endLineDrawBatch();
    // const ItemStack* thisStack = (itemsPointer + i);

    // // Draw the actual item. (if any)
    // if (thisStack.id > 0) {
    //     const ItemDefinition* thisDefPointer = ItemDatabase.unsafeGetByID(thisStack.id);

    // TextureHandler.drawTextureFromRectPointer(
    //     thisDefPointer.textureRectIndex,
    //     Vec2d(
    //         posX + round(currentWidth),
    //         -posY - round(currentHeight)),
    //     Vec2d(
    //         floor(slotSize),
    //         floor(slotSize)));

    // const string stackCountText = to!string(thisStack.count);

    // const Vec2d textSize = FontHandler.getTextSize(stackCountText, 0.165);

    // const int textX = cast(int) round(textSize.x);
    // const int textY = cast(int) round(textSize.y);

    // FontHandler.drawShadowed(
    //     stackCountText,
    //     (((posX + slotSize) - textX) - cast(int) round(2 * GUI.currentGUIScale)) +
    //         cast(int) round(currentWidth),
    //     (((posY + slotSize) - textY) + cast(int) round(GUI.currentGUIScale)) + cast(
    //         int) round(currentHeight),
    //     0.165,
    //     Colors.WHITE
    // );
    // }

    //! This is the debug box for the entirety of the inventory. 
    // DrawRectangleLines(
    //     posX,
    //     posY,
    //     sizeX,
    //     sizeY,
    //     Colors.RED);

    endScissorComponent();
}
