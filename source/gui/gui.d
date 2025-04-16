module gui.gui;

public import gui.window_gui;
import audio.audio;
import controls.keyboard;
import controls.mouse;
import graphics.colors;
import gui.font;
import math.vec2d;
import math.vec2i;
import raylib;
import std.conv;
import std.math.rounding;
import std.random;
import std.stdio;

/*
*
*   CONTROLS PROVIDED:
*     # Container/separators Controls
*       - WindowBox     --> StatusBar, Panel
*       - GroupBox      --> Line
*       - Line
*       - Panel         --> StatusBar
*       - ScrollPanel   --> StatusBar
*       - TabBar        --> Button
*
*     # Basic Controls
*       - Label
*       - LabelButton   --> Label
*       - Button
*       - Toggle
*       - ToggleGroup   --> Toggle
*       - ToggleSlider
*       - CheckBox
*       - ComboBox
*       - DropdownBox
*       - TextBox
*       - ValueBox      --> TextBox
*       - Spinner       --> Button, ValueBox
*       - Slider
*       - SliderBar     --> Slider
*       - ProgressBar
*       - StatusBar
*       - DummyRec
*       - Grid
*
*     # Advance Controls
*       - ListView
*       - ColorPicker   --> ColorPanel, ColorBarHue
*       - MessageBox    --> Window, Label, Button
*       - TextInputBox  --> Window, Label, TextBox, Button
*/

pragma(inline, true)
T instanceof(T)(Object o) if (is(T == class)) {
    return cast(T) o;
}

static final const class GUI {
static:
private:

    // We standardize the GUI with 1080p.
    const Vec2d standardSize = Vec2d(1920.0, 1080.0);
    // This is the real window size.
    Vec2d realSize = Vec2d(1920.0, 1080.0);
    // The scale of GUI components.
    double currentGUIScale = 1.0;
    // Used to divide using multiplication.
    double inverseCurrentGUIScale = 1.0;
    // This is the anchor for all windows. The origin is in the center of the window.
    Vec2d centerPoint;
    // This will be an options menu component to adjust the size of the GUI.
    double masterGUIScale = 1.0;
    // This is the scale of the graphics components.
    // Mainly this is used for the camera's zoom.
    double graphicsScale = 1.0;
    // For dragging and resizing windows.
    Vec2d mouseWindowDelta;

    WindowGUI[string] windows;
    bool dragging = false;
    bool resizing = false;
    WindowGUI currentWindow = null;

    Mt19937 rnd;

public: //* BEGIN PUBLIC API.

    void registerWindow(string windowID, WindowGUI window) {
        window.windowID = windowID;
        windows[windowID] = window;
    }

    bool windowXInBounds(WindowGUI window) {
        bool result = true;
        const int posX = cast(int) floor(
            centerPoint.x + (window.position.x * currentGUIScale));
        const int sizeX = cast(int) floor(window.size.x * currentGUIScale);
        if (posX < 0) {
            result = false;
        } else if (posX + sizeX > realSize.x) {
            result = false;
        }
        return result;
    }

    bool windowYInBounds(WindowGUI window) {
        bool result = true;
        const int posY = cast(int) floor(
            centerPoint.y + (window.position.y * currentGUIScale));
        const int sizeY = cast(int) floor(window.size.y * currentGUIScale);
        if (posY < 0) {
            result = false;
        } else if (posY + sizeY > realSize.y) {
            result = false;
        }

        return result;
    }

    bool sweepWindowIntoBounds(WindowGUI window) {
        bool result = false;
        const int posX = cast(int) floor(
            centerPoint.x + (window.position.x * currentGUIScale));
        const int posY = cast(int) floor(
            centerPoint.y + (window.position.y * currentGUIScale));
        const int sizeX = cast(int) floor(window.size.x * currentGUIScale);
        const int sizeY = cast(int) floor(window.size.y * currentGUIScale);

        if (posX < 0) {
            window.position.x = cast(int) floor(
                (-centerPoint.x) * inverseCurrentGUIScale);
            result = true;
        } else if (posX + sizeX > realSize.x) {
            window.position.x = cast(int) ceil(
                (centerPoint.x - sizeX) * inverseCurrentGUIScale);
            result = true;
        }

        if (posY < 0) {
            window.position.y = cast(int) floor(
                (-centerPoint.y) * inverseCurrentGUIScale);
            result = true;
        } else if (posY + sizeY > realSize.y) {
            window.position.y = cast(int) ceil(
                (centerPoint.y - sizeY) * inverseCurrentGUIScale);
            result = true;
        }
        return result;
    }

    void drawWindowFrame() {
        const int posX = cast(int) floor(centerPoint.x + (currentWindow.position.x * currentGUIScale));
        const int posY = cast(int) floor(centerPoint.y + (currentWindow.position.y * currentGUIScale));
        const int sizeX = cast(int) floor(currentWindow.size.x * currentGUIScale);
        const int sizeY = cast(int) floor(currentWindow.size.y * currentGUIScale);
        const int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);
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
            currentWindow.workAreaColor);
        // Status area background.
        const Color statusBarColor = currentWindow.mouseHoveringStatusBar ? currentWindow.statusBarHoverColor
            : currentWindow.statusBarColor;
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
            currentWindow.borderColor);
        // Status area outline.
        DrawRectangleLines(
            posX,
            posY,
            sizeX,
            statusAreaHeight,
            currentWindow.borderColor);
        EndScissorMode();
        //? Capture excessively long window titles.
        BeginScissorMode(
            posX,
            posY,
            sizeX - statusAreaHeight - 1,
            statusAreaHeight - 1);
        const string title = (currentWindow.title is null) ? "UNDEFINED" : currentWindow.title;
        FontHandler.drawShadowed(
            title,
            posX + (currentGUIScale * 2),
            posY,
            0.25,
            currentWindow.statusBarTextColor);
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
            currentWindow.closeButtonBackgroundColor);
        DrawRectangleLines(
            posX + sizeX - statusAreaHeight,
            posY,
            statusAreaHeight,
            statusAreaHeight,
            currentWindow.borderColor);
        const double closeTrim = 4 * currentGUIScale;
        const double closeThickness = 1 * currentGUIScale;
        // The X.
        const Color closeButtonBackgroundColor = currentWindow.mouseHoveringCloseButton ? currentWindow
            .closeButtonXHoverColor : currentWindow.closeButtonXColor;
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

    /// This draws the resize button on the bottom right of the window.
    void drawResizeButton() {
        //? Draw the resize button.
        const int posX = cast(int) floor(centerPoint.x + (currentWindow.position.x * currentGUIScale));
        const int posY = cast(int) floor(centerPoint.y + (currentWindow.position.y * currentGUIScale));
        const int sizeX = cast(int) floor(currentWindow.size.x * currentGUIScale);
        const int sizeY = cast(int) floor(currentWindow.size.y * currentGUIScale);
        const int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);
        const int halfStatusAreaHeight = cast(int) floor(statusAreaHeight * 0.5);
        BeginScissorMode(
            posX + sizeX - halfStatusAreaHeight - 1,
            posY + sizeY - halfStatusAreaHeight - 1,
            halfStatusAreaHeight + 1,
            halfStatusAreaHeight + 1);
        const Color resizeButtonColor = currentWindow.mouseHoveringResizeButton ? currentWindow
            .resizeButtonBackgroundColorHovered : currentWindow.resizeButtonBackgroundColor;
        DrawRectangle(
            posX + sizeX - halfStatusAreaHeight,
            posY + sizeY - halfStatusAreaHeight,
            halfStatusAreaHeight,
            halfStatusAreaHeight,
            resizeButtonColor);
        DrawRectangleLines(
            posX + sizeX - halfStatusAreaHeight,
            posY + sizeY - halfStatusAreaHeight,
            halfStatusAreaHeight,
            halfStatusAreaHeight,
            currentWindow.borderColor);
        EndScissorMode();
    }

    void drawWindowComponents() {

        const int workAreaPosX = cast(int) floor(
            centerPoint.x + (currentWindow.position.x * currentGUIScale));
        const int workAreaPosY = cast(int) floor(
            centerPoint.y + (currentWindow.position.y * currentGUIScale));
        const int workAreaSizeX = cast(int) floor(currentWindow.size.x * currentGUIScale);
        const int workAreaSizeY = cast(int) floor(currentWindow.size.y * currentGUIScale);
        const int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);

        const int centerX = cast(int) floor(workAreaPosX + (workAreaSizeX * 0.5));
        const int centerY = cast(int) floor(workAreaPosY + (workAreaSizeY * 0.5));

        // All components will only be able to render within the work area.
        BeginScissorMode(
            workAreaPosX,
            workAreaPosY + statusAreaHeight,
            workAreaSizeX - 1,
            workAreaSizeY - statusAreaHeight - 1);

        //! You can't layer scissor.
        //! So, I'd rather have the components be able to be messed up rather than
        //! have the components spill out of the work area.

        foreach (thisComponent; currentWindow.componentsInOrder) {
            if (Button button = instanceof!Button(thisComponent)) {
                const int posX = cast(int) floor(
                    (button.position.x * currentGUIScale) + centerX);
                const int posY = cast(int) floor(
                    ((-button.position.y) * currentGUIScale) + centerY);
                const int sizeX = cast(int) floor(button.size.x * currentGUIScale);
                const int sizeY = cast(int) floor(button.size.y * currentGUIScale);
                Color buttonColor = button.mouseHovering ? button.backgroundColorHover
                    : button.backgroundColor;
                DrawRectangle(
                    posX,
                    posY,
                    sizeX,
                    sizeY,
                    buttonColor);
                const string title = (button.text is null) ? "UNDEFINED" : button.text;
                const int adjustment = cast(int) floor((sizeX * 0.5) - (FontHandler.getTextSize(title, 0.25)
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
                    button.borderColor);
            } else if (TextBox textBox = instanceof!TextBox(thisComponent)) {

                // This section is powered by Megadeth

                const int posX = cast(int) floor(
                    (textBox.position.x * currentGUIScale) + centerX);
                const int posY = cast(int) floor(
                    ((-textBox.position.y) * currentGUIScale) + centerY);
                const int sizeX = cast(int) floor(textBox.size.x * currentGUIScale);
                const int sizeY = cast(int) floor(textBox.size.y * currentGUIScale);
                Color buttonColor = textBox.backgroundColor;



            }
        }

        EndScissorMode();
    }

    void drawCurrentWindow() {

        if (currentWindow is null) {
            return;
        }

        drawWindowFrame();

        drawWindowComponents();

        if (currentWindow.resizeable) {
            drawResizeButton();
        }

    }

    /// Close the currently opened window.
    /// If no window is opened, this has no effect.
    void closeWindow() {
        currentWindow = null;
    }

    void playButtonSound() {
        // This is a really unfitting sound but it works for now.
        int keySelection = uniform(1, 6, rnd);
        Audio.playSound("keyboard_" ~ to!string(keySelection) ~ ".wav");
    }

    Vector2 getMousePositionInGUI() {
        Vector2 mousePos = GetMousePosition();
        mousePos.x -= centerPoint.x;
        mousePos.y -= centerPoint.y;
        return mousePos;
    }

    /// The logic for when a window is dragged around.
    void windowDragLogic(ref bool mouseFocusedOnGUI) {
        if (!Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
            dragging = false;
            playButtonSound();
            return;
        }
        mouseFocusedOnGUI = true;
        const Vector2 mousePosInGUI = getMousePositionInGUI();
        const double scaledDeltaX = mouseWindowDelta.x * inverseCurrentGUIScale;
        const double scaledDeltaY = mouseWindowDelta.y * inverseCurrentGUIScale;
        const double scaledMousePosX = mousePosInGUI.x * inverseCurrentGUIScale;
        const double scaledMousePosY = mousePosInGUI.y * inverseCurrentGUIScale;
        currentWindow.position.x = cast(int) floor(scaledDeltaX + scaledMousePosX);
        currentWindow.position.y = cast(int) floor(scaledDeltaY + scaledMousePosY);
        // Make sure the window stays on the screen.
        sweepWindowIntoBounds(currentWindow);
    }

    /// The logic for when a window is resized.
    void windowResizeLogic(ref bool mouseFocusedOnGUI) {
        if (!Mouse.isButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
            resizing = false;
            playButtonSound();
            return;
        }
        mouseFocusedOnGUI = true;
        const int posX = currentWindow.position.x;
        const int posY = currentWindow.position.y;
        const Vector2 mousePosInGUI = getMousePositionInGUI();
        const double scaledDeltaX = mouseWindowDelta.x * inverseCurrentGUIScale;
        const double scaledDeltaY = mouseWindowDelta.y * inverseCurrentGUIScale;
        const double scaledMousePosX = mousePosInGUI.x * inverseCurrentGUIScale;
        const double scaledMousePosY = mousePosInGUI.y * inverseCurrentGUIScale;
        const int oldSizeX = currentWindow.size.x;
        const int oldSizeY = currentWindow.size.y;
        currentWindow.size.x = cast(int) floor((scaledMousePosX + scaledDeltaX) - posX);
        if (!windowXInBounds(currentWindow)) {
            currentWindow.size.x = oldSizeX;
        }
        currentWindow.size.y = cast(int) floor((scaledMousePosY + scaledDeltaY) - posY);
        if (!windowYInBounds(currentWindow)) {
            currentWindow.size.y = oldSizeY;
        }
        if (currentWindow.size.x < currentWindow.minSize.x) {
            currentWindow.size.x = currentWindow.minSize.x;
        }
        if (currentWindow.size.y < currentWindow.minSize.y) {
            currentWindow.size.y = currentWindow.minSize.y;
        }
    }

    /// This is the general logic of the window itself.
    /// Not the components inside the window. That is a separate function.
    /// The mouse collision, drag/resize initialization.
    /// This returns if it's okay to proceed to checking window components in the work area.
    bool generalWindowLogic(ref bool mouseFocusedOnGUI) {
        bool okayToCheckComponents = false;
        const Vector2 mousePos = Mouse.getPosition.toRaylib();
        const int posX = cast(int) floor(
            centerPoint.x + (currentWindow.position.x * currentGUIScale));
        const int posY = cast(int) floor(
            centerPoint.y + (currentWindow.position.y * currentGUIScale));
        const int sizeX = cast(int) floor(currentWindow.size.x * currentGUIScale);
        const int sizeY = cast(int) floor(currentWindow.size.y * currentGUIScale);
        const Rectangle windowRectangle = Rectangle(posX, posY, sizeX, sizeY);
        currentWindow.mouseHoveringStatusBar = false;
        currentWindow.mouseHoveringCloseButton = false;
        currentWindow.mouseHoveringResizeButton = false;
        //? Collide with the entire window.
        // No collision with this window occured.
        if (!CheckCollisionPointRec(mousePos, windowRectangle)) {
            return okayToCheckComponents;
        }
        okayToCheckComponents = true;
        mouseFocusedOnGUI = true;
        const int statusAreaHeight = cast(int) floor(currentGUIScale * 32.0);
        //? Check if the mouse is hovering over the status bar.
        Rectangle statusBarRectangle = Rectangle(posX, posY, sizeX - statusAreaHeight - 1, statusAreaHeight);
        if (CheckCollisionPointRec(mousePos, statusBarRectangle)) {
            okayToCheckComponents = false;
            currentWindow.mouseHoveringStatusBar = true;
            // The user is dragging a window.
            if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                mouseWindowDelta = Vec2d(Vector2Subtract(Vector2(posX, posY), mousePos));
                dragging = true;
                playButtonSound();
                return okayToCheckComponents;
            }
        }
        //? Check if the mouse is hovering over the close button.
        const Rectangle closeButtonRectangle = Rectangle(posX + sizeX - statusAreaHeight, posY,
            statusAreaHeight, statusAreaHeight);
        if (CheckCollisionPointRec(mousePos, closeButtonRectangle)) {
            currentWindow.mouseHoveringCloseButton = true;
            okayToCheckComponents = false;
            // The user closed the window.
            if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                currentWindow = null;
                playButtonSound();
                return okayToCheckComponents;
            }
        }
        //? Check if the mouse is hovering over the resize button.
        if (currentWindow.resizeable) {
            const int halfStatusAreaHeight = cast(int) floor(statusAreaHeight * 0.5);
            const Rectangle resizeButtonRectangle = Rectangle(
                posX + sizeX - halfStatusAreaHeight,
                posY + sizeY - halfStatusAreaHeight,
                halfStatusAreaHeight,
                halfStatusAreaHeight);
            if (CheckCollisionPointRec(mousePos, resizeButtonRectangle)) {
                currentWindow.mouseHoveringResizeButton = true;
                okayToCheckComponents = false;
                // The user is resizing a window.
                if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                    mouseWindowDelta = Vec2d(Vector2Subtract(Vector2(posX + sizeX, posY + sizeY),
                            mousePos));
                    resizing = true;
                    playButtonSound();
                    return okayToCheckComponents;
                }
            }
        }
        return okayToCheckComponents;
    }

    /// This will only run when the mouse is in the work area.
    void windowComponentLogic() {
        const int workAreaPosX = cast(int) floor(
            centerPoint.x + (currentWindow.position.x * currentGUIScale));
        const int workAreaPosY = cast(int) floor(
            centerPoint.y + (currentWindow.position.y * currentGUIScale));
        const int workAreaSizeX = cast(int) floor(currentWindow.size.x * currentGUIScale);
        const int workAreaSizeY = cast(int) floor(currentWindow.size.y * currentGUIScale);
        const int centerX = cast(int) floor(workAreaPosX + (workAreaSizeX * 0.5));
        const int centerY = cast(int) floor(workAreaPosY + (workAreaSizeY * 0.5));
        const Vector2 mousePos = Mouse.getPosition.toRaylib();

        foreach (thisComponent; currentWindow.componentsInOrder) {
            if (Button button = instanceof!Button(thisComponent)) {
                button.mouseHovering = false;
                const int posX = cast(int) floor(
                    (button.position.x * currentGUIScale) + centerX);
                const int posY = cast(int) floor(
                    ((-button.position.y) * currentGUIScale) + centerY);
                const int sizeX = cast(int) floor(button.size.x * currentGUIScale);
                const int sizeY = cast(int) floor(button.size.y * currentGUIScale);
                const Rectangle buttonRect = Rectangle(
                    posX,
                    posY,
                    sizeX,
                    sizeY);
                // If the mouse is hovering over the button.
                if (CheckCollisionPointRec(mousePos, buttonRect)) {
                    button.mouseHovering = true;
                    // If the mouse clicks the button.
                    if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                        playButtonSound();
                        button.clickFunction();
                        break;
                    }
                }

            } else if (TextBox tbox = instanceof!TextBox(thisComponent)) {

            }
        }
    }

    void updateCurrentWindowGUI() {
        bool mouseFocusedOnGUI = false;
        if (currentWindow is null) {
            Mouse.__setFocusedOnGUI(mouseFocusedOnGUI);
            return;
        }
        if (dragging) {
            windowDragLogic(mouseFocusedOnGUI);
        } else if (resizing) {
            windowResizeLogic(mouseFocusedOnGUI);
        } else {
            if (generalWindowLogic(mouseFocusedOnGUI)) {
                windowComponentLogic();
            }
        }
        Mouse.__setFocusedOnGUI(mouseFocusedOnGUI);
    }

    void debugTest() {

        // Pause menu.
        {
            WindowGUI pauseMenu = new WindowGUI();
            pauseMenu.title = "Pause Menu";
            pauseMenu.size.x = 400;
            pauseMenu.size.y = 600;
            // pauseMenu.resizeable = false;
            pauseMenu.center();

            Button continueButton = new Button();
            continueButton.clickFunction = () { closeWindow(); };
            continueButton.size.x = 200;
            continueButton.position.y = 200;
            continueButton.text = "CONTINUE";
            continueButton.centerX();
            pauseMenu.addComponent("continue_button", continueButton);

            Button settingsButton = new Button();
            settingsButton.clickFunction = () {
                writeln(
                    "Here's where I'd put a settings menu IF I HAD ONE (╯°□°）╯︵ ┻━┻");
            };
            settingsButton.size.x = 200;
            settingsButton.position.y = 0;
            settingsButton.text = "SETTINGS";
            settingsButton.centerX();
            pauseMenu.addComponent("settings_button", settingsButton);

            Button exitButton = new Button();
            exitButton.clickFunction = () {
                import graphics.window;

                Window.close();
            };

            exitButton.size.x = 200;
            exitButton.position.y = -200;
            exitButton.text = "EXIT";
            exitButton.centerX();
            pauseMenu.addComponent("exit_button", exitButton);

            registerWindow("pause_menu", pauseMenu);
        }

        // Settings menu.
        {
            WindowGUI settingsMenu = new WindowGUI();
            settingsMenu.title = "Settings";
            settingsMenu.size.x = 800;
            settingsMenu.size.y = 800;
            settingsMenu.center();
            registerWindow("settings_menu", settingsMenu);

        }

        currentWindow = windows["settings_menu"];
    }

    void bringBackDebugTest() {

        if (Keyboard.isPressed(KeyboardKey.KEY_ESCAPE)) {
            playButtonSound();
            if (currentWindow is null) {
                currentWindow = windows["pause_menu"];
            } else {
                currentWindow = null;
            }

        }
        // if (Keyboard.isPressed(KeyboardKey.KEY_TWO)) {
        //     windows["pause_menu"].center();
        // }
    }

    double getGUIScale() {
        return currentGUIScale;
    }

    double getGraphicsScale() {
        return graphicsScale;
    }

    void initialize() {
        FontHandler.initialize();
        rnd = Random(unpredictableSeed());
        debugTest();
    }

    void terminate() {
        FontHandler.terminate();
    }

    void __update(Vec2d newWindowSize) {
        const Vec2d oldSize = realSize;

        realSize.x = newWindowSize.x;
        realSize.y = newWindowSize.y;

        centerPoint.x = realSize.x * 0.5;
        centerPoint.y = realSize.y * 0.5;

        // Find out which GUI scale is smaller so things can be scaled around it.
        const Vec2d scales = Vec2d(
            newWindowSize.x / standardSize.x,
            newWindowSize.y / standardSize.y);

        if (scales.x >= scales.y) {
            currentGUIScale = scales.y;
        } else {
            currentGUIScale = scales.x;
        }

        graphicsScale = currentGUIScale;

        currentGUIScale *= masterGUIScale;

        inverseCurrentGUIScale = 1.0 / currentGUIScale;

        if (oldSize != realSize) {
            foreach (window; windows) {
                sweepWindowIntoBounds(window);
            }
        }

        FontHandler.__update();
        updateCurrentWindowGUI();

        bringBackDebugTest();
    }

private: //* BEGIN INTERNAL API.

}
