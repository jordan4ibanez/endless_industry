module gui.window_draw;

import gui.font;
import gui.gui;
import raylib : BeginScissorMode, Color, DrawLineEx, DrawRectangle, DrawRectangleLines, EndScissorMode, Vector2;
import std.math.rounding;

void drawWindowFrame() {
    const int posX = cast(int) floor(
        GUI.centerPoint.x + (GUI.currentWindow.position.x * GUI.currentGUIScale));
    const int posY = cast(int) floor(
        GUI.centerPoint.y + (GUI.currentWindow.position.y * GUI.currentGUIScale));
    const int sizeX = cast(int) floor(GUI.currentWindow.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(GUI.currentWindow.size.y * GUI.currentGUIScale);
    const int statusAreaHeight = cast(int) floor(GUI.currentGUIScale * 32.0);
    //? Stop from drawing out of bounds.
    BeginScissorMode(
        posX - 1,
        posY - 1,
        sizeX + 1,
        sizeY + 1);
    // Work area background.
    DrawRectangle(
        posX,
        posY,
        sizeX,
        sizeY,
        GUI.currentWindow.workAreaColor);
    // Status area background.
    const Color statusBarColor = GUI.currentWindow.mouseHoveringStatusBar ? GUI
        .currentWindow.statusBarHoverColor : GUI.currentWindow.statusBarColor;
    DrawRectangle(
        posX,
        posY,
        sizeX,
        statusAreaHeight,
        statusBarColor);
    // Work area outline.
    DrawRectangleLines(
        posX,
        posY,
        sizeX,
        sizeY,
        GUI.currentWindow.borderColor);
    // Status area outline.
    DrawRectangleLines(
        posX,
        posY,
        sizeX,
        statusAreaHeight,
        GUI.currentWindow.borderColor);
    EndScissorMode();
    //? Capture excessively long window titles.
    BeginScissorMode(
        posX,
        posY,
        sizeX - statusAreaHeight - 1,
        statusAreaHeight - 1);
    const string title = (GUI.currentWindow.title is null) ? "UNDEFINED" : GUI.currentWindow.title;
    FontHandler.drawShadowed(
        title,
        posX + (GUI.currentGUIScale * 2),
        posY,
        0.25,
        GUI.currentWindow.statusBarTextColor);
    EndScissorMode();
    //? Draw the close button.
    // I just like using the scissor mode. :D
    BeginScissorMode(
        posX + sizeX - statusAreaHeight - 1,
        posY - 1,
        statusAreaHeight + 1,
        statusAreaHeight + 1);
    // Background and border.
    DrawRectangle(
        posX + sizeX - statusAreaHeight,
        posY,
        statusAreaHeight,
        statusAreaHeight,
        GUI.currentWindow.closeButtonBackgroundColor);
    DrawRectangleLines(
        posX + sizeX - statusAreaHeight,
        posY,
        statusAreaHeight,
        statusAreaHeight,
        GUI.currentWindow.borderColor);
    const double closeTrim = 4 * GUI.currentGUIScale;
    const double closeThickness = 1 * GUI.currentGUIScale;
    // The X.
    const Color closeButtonBackgroundColor = GUI.currentWindow.mouseHoveringCloseButton ? GUI
        .currentWindow
        .closeButtonXHoverColor : GUI.currentWindow.closeButtonXColor;
    // This: /
    DrawLineEx(
        Vector2(
            floor(posX + sizeX - statusAreaHeight + closeTrim),
            floor(posY + statusAreaHeight - closeTrim)),
        Vector2(
            floor(posX + sizeX - closeTrim),
            floor(posY + closeTrim)),
        closeThickness,
        closeButtonBackgroundColor);
    // This: \
    DrawLineEx(
        Vector2(
            floor(posX + sizeX - statusAreaHeight + closeTrim),
            floor(posY + closeTrim)),
        Vector2(
            floor(posX + sizeX - closeTrim),
            floor(posY + statusAreaHeight - closeTrim)),
        closeThickness,
        closeButtonBackgroundColor
    );
    EndScissorMode();
}
