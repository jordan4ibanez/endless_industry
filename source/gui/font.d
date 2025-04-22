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
    const double spacing = 0;
    double currentFontSize = 1;
    const int baseFontSize = 128;
    const double inverseBaseFontSize = 1.0 / cast(double) baseFontSize;
    double currentGUIScale = 1.0;

public: //* BEGIN PUBLIC API.

    void initialize() {

        dstring codePointString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+={[]}|" ~
            "\\;:'\",<.>© /?";

        font = LoadFontEx(
            toStringz("font/roboto_condensed.ttf"), baseFontSize, cast(int*) codePointString, 0);

        writeln("Loaded font roboto_condensed.ttf");
    }

    Vector2 getTextSize(string text, double fontScale = 1.0) {
        return MeasureTextEx(font, toStringz(text), currentFontSize * fontScale, spacing);
    }

    /// Get the CodePoint of a character.
    pragma(inline, true)
    int getCodePoint(char character) {
        int byteCount = 0;
        return GetCodepoint(&character, &byteCount);
    }

    /// Get the glyph index of a character using it's CodePoint.
    pragma(inline, true)
    int getGlyphIndex(int codePoint) {
        return GetGlyphIndex(font, codePoint);
    }

    /// Get the width of a character.
    double getCharWidth(char character, double fontScale = 1.0) {
        const int codePoint = getCodePoint(character);
        const int charIndex = getGlyphIndex(codePoint);
        const double scaleFactor = (currentFontSize * fontScale) * inverseBaseFontSize;
        return (font.glyphs[charIndex].advanceX == 0) ? cast(double) font.recs[charIndex].width * scaleFactor
            : cast(double) font.glyphs[charIndex].advanceX * scaleFactor;
    }

    /// Get the height of a character.
    double getCharHeight(char character, double fontScale = 1.0) {
        const int codePoint = getCodePoint(character);
        const int charIndex = getGlyphIndex(codePoint);
        const double scaleFactor = (currentFontSize * fontScale) * inverseBaseFontSize;
        return cast(double) font.recs[charIndex].height * scaleFactor;
    }

    /// Draw text on the screen.
    void draw(string text, double x, double y, double fontScale = 1.0, Color color = Colors.BLACK) {
        DrawTextEx(font, toStringz(text), Vector2(x, y), currentFontSize * fontScale, spacing, color);
    }

    /// Draw text on the screen with a black shadow.
    void drawShadowed(string text, double x, double y, double fontScale = 1.0, Color foregroundColor = Colors
            .WHITE) {
        DrawTextEx(font, toStringz(text), Vector2(x + (2 * currentGUIScale), y + (
                2 * currentGUIScale)), currentFontSize * fontScale, spacing, Colors
                .BLACK);

        DrawTextEx(font, toStringz(text), Vector2(x, y), currentFontSize * fontScale, spacing, foregroundColor);
    }

    void terminate() {
        UnloadFont(font);
    }

    void __update() {
        currentGUIScale = GUI.getGUIScale();
        currentFontSize = font.baseSize * currentGUIScale;
    }

    package Vector2 __getTextSizeSpecialFixed(string text, double fontScale = 1.0) {
        return MeasureTextEx(font, toStringz(text), baseFontSize * fontScale, spacing);
    }

private: //* BEGIN INTERNAL API.

}
