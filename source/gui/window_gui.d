module gui.window_gui;

public import gui.component;
import math.vec2d;
import math.vec2i;
import raylib;
import std.math.rounding;

// This is the basis of any GUI component, the window.
class WindowGUI {
package:

    // The ID of this window.
    string windowID = null;

    // These are hidden because they're kept in rendering order.
    Component[] componentsInOrder;
    Component[string] componentDatabase;

public:

    // If it's a window, this defines if you can resize it.
    bool resizeable = true;

    // What this window's title says.
    string windowTitle = null;

    //? State behavior.

    // Position is top left of window.
    Vec2i position;

    // The current size of the window. (It will always be scaled to GUI scaling)
    Vec2i size;

    // The minimum size of the window. (It will always be scaled to GUI scaling)
    Vec2i minSize = Vec2i(100, 100);

    // If the mouse is hovering over the status bar.
    bool mouseHoveringStatusBar = false;

    // If the mouse is hovering over the close button.
    bool mouseHoveringCloseButton = false;

    // If the mouse is hovering over the resize button.
    bool mouseHoveringResizeButton = false;

    //? General solid colors.

    // The color of the work area.
    Color workAreaColor = Colors.GRAY;

    // The border color of the window. (All border components.)
    Color borderColor = Colors.BLACK;

    // The status bar background color.
    Color statusBarColor = Colors.BLUE;
    // The status bar background color when hovered over.
    Color statusBarHoverColor = Color(40, 50, 255, 255);

    // The close button background color.
    Color closeButtonBackgroundColor = Colors.GRAY;

    // The resize button background color.
    Color resizeButtonBackgroundColor = Colors.GRAY;
    // The resize button background color when hovered over.
    Color resizeButtonBackgroundColorHovered = Colors.DARKGRAY;

    //? General text/icon colors.

    // The text below the status bar.
    Color workAreaTextColor = Colors.BLACK;

    // The status bar text color.
    Color statusBarTextColor = Colors.WHITE;

    // The close button X color.
    Color closeButtonXColor = Colors.BLACK;
    // The close button X color when hovered over.
    Color closeButtonXHoverColor = Colors.RED;

    /// Center the window.
    void center() {
        double halfWindowSizeX = size.x * 0.5;
        double halfWindowSizeY = size.y * 0.5;

        int newPositionX = cast(int) floor(-halfWindowSizeX);
        int newPositionY = cast(int) floor(-halfWindowSizeY);

        position.x = newPositionX;
        position.y = newPositionY;
    }

    void addComponent(string componentID, Component component) {
        component.componentID = componentID;

        // They both point to the same thing.
        componentsInOrder ~= component;
        componentDatabase[componentID] = component;
    }

}
