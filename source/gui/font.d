module gui.font;

import gui.gui;
import raylib;
import std.math.rounding;
import std.stdio;
import std.string;

static final const class FontHandler {
static:
private:

    // Roboto condensed medium looks pretty close to the Bass Rise font, kind of.
    Font font;
    const double spacing = -1;
    double currentFontSize = 1;
    const int baseFontSize = 128;

public: //* BEGIN PUBLIC API.

    void initialize() {

        dstring codePointString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+={[]}|" ~
            "\\;:'\",<.>©";

        font = LoadFontEx(
            toStringz("font/roboto_condensed.ttf"), baseFontSize, cast(int*) codePointString, 0);

        writeln("Loaded font roboto_condensed.ttf");
    }

    Vector2 getTextSize(string text, double fontScale = 1.0) {
        return MeasureTextEx(font, toStringz(text), currentFontSize * fontScale, spacing);
    }

    void draw(string text, double x, double y, double fontScale = 1.0, Color color = Colors.BLACK) {
        DrawTextEx(font, toStringz(text), Vector2(x, y), currentFontSize * fontScale, spacing, color);
    }

    void drawShadowed(string text, double x, double y, double fontScale = 1.0, Color foregroundColor = Colors
            .WHITE) {
        DrawTextEx(font, toStringz(text), Vector2(x, y), currentFontSize * fontScale, spacing, Colors
                .BLACK);
        DrawTextEx(font, toStringz(text), Vector2(x - 1, y - 1), currentFontSize * fontScale, spacing, foregroundColor);
    }

    void terminate() {
        UnloadFont(font);
    }

    void __update() {
        currentFontSize = font.baseSize * GUI.getGUIScale();
    }

private: //* BEGIN INTERNAL API.

}
