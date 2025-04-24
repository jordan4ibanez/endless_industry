module gui.component_draw;

import gui.component;
import gui.font;
import gui.gui;
import math.vec2d;
import math.vec2i;
import raylib : Vector2;
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
