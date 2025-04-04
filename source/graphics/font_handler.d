module graphics.font_handler;

import graphics.gui;
import raylib;
import std.math.rounding;
import std.string;

static final const class FontHandler {
static:
private:

    // Roboto condensed medium looks pretty close to the Bass Rise font, kind of.
    Font* font = null;
    immutable double spacing = -1;
    double currentFontSize = 1;

public: //* BEGIN PUBLIC API.

    void initialize() {
        font = new Font();

        dstring codePointString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+={[]}|" ~
            "\\;:'\",<.>©";

        *font = LoadFontEx(
            toStringz("font/roboto_condensed.ttf"), 64, cast(int*) codePointString, 0);
    }

    Vector2 getTextSize(string text) {
        return MeasureTextEx(*font, toStringz(text), currentFontSize, spacing);
    }

    void draw(string text, double x, double y, Color color = Colors.BLACK) {
        DrawTextEx(*font, toStringz(text), Vector2(x, y), currentFontSize, spacing, color);
    }

    void drawShadowed(string text, double x, double y, Color foregroundColor = Colors.WHITE) {
        DrawTextEx(*font, toStringz(text), Vector2(x, y), currentFontSize, spacing, Colors.BLACK);
        DrawTextEx(*font, toStringz(text), Vector2(x - 1, y - 1), currentFontSize, spacing, foregroundColor);
    }

    void terminate() {
        UnloadFont(*font);
        font = null;
    }

    void __update() {
        // This allows the font to look slightly off, like it's a texture font.
        currentFontSize = font.baseSize * (GUI.getGUIScale() * 0.75);
    }

private: //* BEGIN INTERNAL API.

}
