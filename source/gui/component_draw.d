module gui.component_draw;

import gui.component;
import gui.font;
import gui.gui;
import math.vec2d;
import math.vec2i;
import raylib : Color, Colors, DrawCircle, DrawCircleLines, DrawRectangle, DrawRectangleLines, Vector2;
import std.math.rounding;

///? Base component.
void drawComponent(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {
}

///? Label.
void drawLabel(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {

    Label label = cast(Label) __self;
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

    ImageLabel imageLabel = cast(ImageLabel) __self;

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
    Button button = cast(Button) __self;
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
    CheckBox checkBox = cast(CheckBox) __self;
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
