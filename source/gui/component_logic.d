module gui.component_logic;

import controls.keyboard;
import controls.mouse;
import game.inventory;
import game.item_database;
import gui.component;
import gui.font;
import gui.gui;
import math.vec2i;
import raylib : CheckCollisionPointRec, Rectangle, Vector2;
import std.algorithm.mutation;
import std.array;
import std.math.rounding;

package:

///? Base component.
bool baseLogic(ref Component __self, const ref Vec2i center, const ref Vector2 mousePos,
    ref bool keyboardDoingTextInput) {
    return false;
}

///? Button.
bool buttonLogic(ref Component __self, const ref Vec2i center, const ref Vector2 mousePos,
    ref bool keyboardDoingTextInput) {

    Button button = cast(Button) __self;

    button.mouseHovering = false;
    const int posX = cast(int) floor(
        (button.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-button.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(button.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(button.size.y * GUI.currentGUIScale);
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
            GUI.playButtonSound();
            button.clickFunction();
            return true;
        }
    }
    return false;
}

///? CheckBox.
bool checkBoxLogic(ref Component __self, const ref Vec2i center, const ref Vector2 mousePos,
    ref bool keyboardDoingTextInput) {
    CheckBox checkBox = cast(CheckBox) __self;
    checkBox.mouseHovering = false;
    const int posX = cast(int) floor(
        (checkBox.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-checkBox.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(checkBox.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(checkBox.size.y * GUI.currentGUIScale);
    const Rectangle buttonRect = Rectangle(
        posX,
        posY,
        sizeX,
        sizeY);
    // If the mouse is hovering over the button.
    if (CheckCollisionPointRec(mousePos, buttonRect)) {
        checkBox.mouseHovering = true;
        // If the mouse clicks the button.
        if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            GUI.playButtonSound();
            checkBox.checked = !checkBox.checked;
            checkBox.clickFunction();
            return true;
        }
    }
    return false;
}

///? TextPad.
bool textPadLogic(ref Component __self, const ref Vec2i center, const ref Vector2 mousePos,
    ref bool keyboardDoingTextInput) {
    TextPad textPad = cast(TextPad) __self;
    textPad.mouseHovering = false;
    const int posX = cast(int) floor(
        (textPad.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-textPad.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(textPad.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(textPad.size.y * GUI.currentGUIScale);
    const Rectangle buttonRect = Rectangle(
        posX,
        posY,
        sizeX,
        sizeY);
    if (CheckCollisionPointRec(mousePos, buttonRect)) {
        textPad.mouseHovering = true;
        if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            if (GUI.focusedComponent != textPad) {
                GUI.playButtonSound();
            }
            // Find which character mouse just clicked (if any)
            bool usePlaceHolder = (textPad.text is null || textPad.text.length == 0);
            if (usePlaceHolder) {
                textPad.cursorPosition = 0;
            } else {
                // This is ultra extremely inefficient.
                // But, it works, probably.
                double currentWidth = 0;
                double width = 0;
                int currentHeight = 0;
                ulong currentIndexInString = 0;
                const string text = (usePlaceHolder) ? textPad.placeholderText : textPad.text;
                bool foundChar = false;

                if (text is null || text.length <= 0) {
                    goto SKIP_TEXT_PAD_COLLISION_LOGIC;
                }

                COLLISION_LOOP_PAD: for (int i = 0; i < text.length; i++) {
                    const char thisChar = text[i];
                    width = FontHandler.getCharWidth(thisChar, 0.25);
                    currentWidth += width;
                    if (thisChar == '\n') {
                        // If newline is reached, it must jump over it.
                        currentHeight += cast(int) floor(32 * GUI.currentGUIScale);
                        currentWidth = 0;
                        currentIndexInString = i + 1;
                    } else if (currentWidth >= sizeX) {
                        currentWidth = width;
                        currentHeight += cast(int) floor(32 * GUI.currentGUIScale);
                        currentIndexInString = i;
                    }
                    Rectangle charRect = Rectangle(
                        cast(int) floor(posX + (currentWidth - width)),
                        posY + currentHeight,
                        cast(int) floor(width),
                        cast(int) floor(32 * GUI.currentGUIScale));
                    // Hit a character.
                    if (CheckCollisionPointRec(mousePos, charRect)) {
                        // Break it into two to find out which side to move the cursor into.
                        Rectangle charLeft = Rectangle(
                            charRect.x,
                            charRect.y,
                            charRect.width / 2,
                            charRect.height
                        );
                        // If it's not left it's right.
                        if (CheckCollisionPointRec(mousePos, charLeft)) {
                            textPad.cursorPosition = i;
                        } else {
                            textPad.cursorPosition = i + 1;
                        }
                        foundChar = true;
                        break COLLISION_LOOP_PAD;
                    }
                }
                // If it hit nothing, just shove it into the last position.
                if (!foundChar) {
                    textPad.cursorPosition = cast(int) textPad.text.length;
                }

            SKIP_TEXT_PAD_COLLISION_LOGIC:

            }
            GUI.focusedComponent = textPad;
        }
    } else {
        if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            if (GUI.focusedComponent == textPad) {
                GUI.playButtonSound();
                keyboardDoingTextInput = false;
                GUI.focusedComponent = null;
            }
        }
    }
    if (GUI.focusedComponent == textPad) {
        keyboardDoingTextInput = true;
        const int input = Keyboard.getCharacterTyped();
        if (input != 0) {
            char[] old = textPad.text.dup;
            old.insertInPlace(textPad.cursorPosition, cast(char) input);
            textPad.text = old.idup;
            GUI.cursorMovedUpdate();
            textPad.cursorPosition++;
        } else if (Keyboard.isKeyPressedOrRepeating(KeyboardKey.KEY_BACKSPACE)) {
            if (textPad.cursorPosition > 0 && textPad.text.length > 0) {
                char[] old = textPad.text.dup;
                old = old.remove(textPad.cursorPosition - 1);
                textPad.text = old.idup;
                textPad.cursorPosition--;
                GUI.cursorMovedUpdate();
            }
        } else if (Keyboard.isKeyPressedOrRepeating(KeyboardKey.KEY_DELETE)) {
            if (textPad.text.length > 0 && textPad.cursorPosition <
                textPad.text.length) {
                char[] old = textPad.text.dup;
                old = old.remove(textPad.cursorPosition);
                textPad.text = old.idup;
                GUI.cursorMovedUpdate();
            }
        } else if (Keyboard.isKeyPressedOrRepeating(KeyboardKey.KEY_ENTER)) {
            char[] old = textPad.text.dup;
            old.insertInPlace(textPad.cursorPosition, '\n');
            textPad.text = old.idup;
            textPad.cursorPosition++;
            GUI.cursorMovedUpdate();
        } else if (Keyboard.isKeyPressedOrRepeating(KeyboardKey.KEY_RIGHT)) {
            if (textPad.cursorPosition < textPad.text.length) {
                textPad.cursorPosition++;
                GUI.cursorMovedUpdate();
            }
        } else if (Keyboard.isKeyPressedOrRepeating(KeyboardKey.KEY_LEFT)) {
            if (textPad.cursorPosition > 0) {
                textPad.cursorPosition--;
                GUI.cursorMovedUpdate();
            }
        }
    }
    return false;
}

///? TextBox.
bool textBoxLogic(ref Component __self, const ref Vec2i center, const ref Vector2 mousePos,
    ref bool keyboardDoingTextInput) {
    TextBox textBox = cast(TextBox) __self;
    textBox.mouseHovering = false;
    const int posX = cast(int) floor(
        (textBox.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-textBox.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(textBox.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(textBox.size.y * GUI.currentGUIScale);
    const Rectangle buttonRect = Rectangle(
        posX,
        posY,
        sizeX,
        sizeY);
    if (CheckCollisionPointRec(mousePos, buttonRect)) {
        textBox.mouseHovering = true;
        if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            if (GUI.focusedComponent != textBox) {
                GUI.playButtonSound();
            }

            // Find which character mouse just clicked (if any)
            bool usePlaceHolder = (textBox.text is null || textBox.text.length == 0);
            if (usePlaceHolder) {
                textBox.cursorPosition = 0;
            } else {
                // This is ultra extremely inefficient.
                // But, it works, probably.
                double currentWidth = 0;
                double width = 0;
                int adjustment = 0;
                const string text = (usePlaceHolder) ? textBox.placeholderText : textBox.text;
                bool foundChar = false;
                const double totalSize = FontHandler.getTextSize(textBox.text, 0.25).x;

                if (text is null || text.length <= 0) {
                    goto SKIP_TEXT_BOX_COLLISION_LOGIC;
                }

                if (totalSize > sizeX) {
                    adjustment = cast(int) round(
                        (totalSize - sizeX) + (3 * GUI.currentGUIScale));
                }

                COLLISION_LOOP_BOX: for (int i = 0; i < text.length; i++) {
                    const char thisChar = text[i];
                    width = FontHandler.getCharWidth(thisChar, 0.25);
                    currentWidth += width;
                    Rectangle charRect = Rectangle(
                        cast(int) floor(
                            posX + (currentWidth - width)) - adjustment,
                        posY,
                        cast(int) floor(width),
                        cast(int) floor(32 * GUI.currentGUIScale));
                    // Hit a character.
                    if (CheckCollisionPointRec(mousePos, charRect)) {
                        // Break it into two to find out which side to move the cursor into.
                        Rectangle charLeft = Rectangle(
                            charRect.x,
                            charRect.y,
                            charRect.width / 2,
                            charRect.height
                        );
                        // If it's not left it's right.
                        if (CheckCollisionPointRec(mousePos, charLeft)) {
                            textBox.cursorPosition = i;
                        } else {
                            textBox.cursorPosition = i + 1;
                        }
                        foundChar = true;
                        break COLLISION_LOOP_BOX;
                    }
                }
                // If it hit nothing, just shove it into the last position.
                if (!foundChar) {
                    textBox.cursorPosition = cast(int) textBox.text.length;
                }

            SKIP_TEXT_BOX_COLLISION_LOGIC:

            }

            GUI.focusedComponent = textBox;
        }
    } else {
        if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            if (GUI.focusedComponent == textBox) {
                GUI.playButtonSound();
                keyboardDoingTextInput = false;
                GUI.focusedComponent = null;
            }
        }
    }
    if (GUI.focusedComponent == textBox) {
        keyboardDoingTextInput = true;
        const int input = Keyboard.getCharacterTyped();
        if (input != 0) {
            if (textBox.text.length < textBox.maxCharacters) {
                char[] old = textBox.text.dup;
                old.insertInPlace(textBox.cursorPosition, cast(char) input);
                textBox.text = old.idup;
                GUI.cursorMovedUpdate();
                textBox.cursorPosition++;
            }
        } else if (Keyboard.isKeyPressedOrRepeating(KeyboardKey.KEY_BACKSPACE)) {
            if (textBox.cursorPosition > 0 && textBox.text.length > 0) {
                char[] old = textBox.text.dup;
                old = old.remove(textBox.cursorPosition - 1);
                textBox.text = old.idup;
                textBox.cursorPosition--;
                GUI.cursorMovedUpdate();
            }
        } else if (Keyboard.isKeyPressedOrRepeating(KeyboardKey.KEY_DELETE)) {
            if (textBox.text.length > 0 && textBox.cursorPosition <
                textBox.text.length) {
                char[] old = textBox.text.dup;
                old = old.remove(textBox.cursorPosition);
                textBox.text = old.idup;
                GUI.cursorMovedUpdate();
            }
        } else if (Keyboard.isKeyPressedOrRepeating(KeyboardKey.KEY_RIGHT)) {
            if (textBox.cursorPosition < textBox.text.length) {
                textBox.cursorPosition++;
                GUI.cursorMovedUpdate();
            }
        } else if (Keyboard.isKeyPressedOrRepeating(KeyboardKey.KEY_LEFT)) {
            if (textBox.cursorPosition > 0) {
                textBox.cursorPosition--;
                GUI.cursorMovedUpdate();
            }
        }
    }
    return false;
}

///? DropMenu.
bool dropMenuLogic(ref Component __self, const ref Vec2i center, const ref Vector2 mousePos,
    ref bool keyboardDoingTextInput) {
    DropMenu dropMenu = cast(DropMenu) __self;
    dropMenu.mouseHovering = false;
    dropMenu.hoverSelection = -1;
    if (GUI.focusedComponent != dropMenu) {
        if (dropMenu.droppedDown) {
            dropMenu.onClose(dropMenu);
        }
        dropMenu.droppedDown = false;
    }
    const int posX = cast(int) floor(
        (dropMenu.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-dropMenu.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(dropMenu.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(dropMenu.size.y * GUI.currentGUIScale);
    const Rectangle buttonRect = Rectangle(
        posX,
        posY,
        sizeX,
        sizeY);
    // If the mouse is hovering over the button.
    if (CheckCollisionPointRec(mousePos, buttonRect)) {
        dropMenu.mouseHovering = true;
        // If the mouse clicks the button.
        if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            GUI.playButtonSound();
            // This top button is special.
            // If you click it it opens the drop menu items.
            // But if you click it again, it's canceling your decision and using whatever was there.
            if (dropMenu.droppedDown) {
                dropMenu.droppedDown = false;
                GUI.focusedComponent = null;
                dropMenu.onClose(dropMenu);
            } else {
                dropMenu.droppedDown = true;
                GUI.focusedComponent = dropMenu;
                dropMenu.onOpen(dropMenu);
            }

            dropMenu.clickFunction(dropMenu);
            return true;
        }
    }

    if (!dropMenu.droppedDown) {
        return false;
    }

    const int incrementer = cast(int) floor(GUI.currentGUIScale);
    int yAdjustment = incrementer;
    ulong i = 0;
    bool hoverOver = false;
    foreach (__index, item; dropMenu.items) {
        if (__index == dropMenu.selection) {
            continue;
        }
        i++;
        const int yPos = (sizeY * cast(int) i) + yAdjustment;
        const Rectangle collisionBox = Rectangle(
            posX,
            posY + yPos,
            sizeX,
            sizeY);

        if (CheckCollisionPointRec(mousePos, collisionBox)) {
            dropMenu.hoverSelection = cast(int) __index;
            hoverOver = true;
            if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                dropMenu.selection = cast(int) __index;
                dropMenu.droppedDown = false;
                GUI.focusedComponent = null;
                dropMenu.onClose(dropMenu);
                dropMenu.clickFunction(dropMenu);
                GUI.playButtonSound();
                return true;
            }
        }
        yAdjustment += incrementer;
    }

    //~ If it got here, that means that the player clicked off the entire drop menu.
    if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
        dropMenu.droppedDown = false;
        GUI.focusedComponent = null;
        dropMenu.onClose(dropMenu);
        GUI.playButtonSound();
    }

    return hoverOver;
}

///? Inventory.
bool inventoryLogic(ref Component __self, const ref Vec2i center, const ref Vector2 mousePos,
    ref bool keyboardDoingTextInput) {
    InventoryGUI inv = cast(InventoryGUI) __self;
    inv.mouseHovering = -1;

    const int posX = cast(int) floor(
        (inv.position.x * GUI.currentGUIScale) + center.x);
    const int posY = cast(int) floor(
        ((-inv.position.y) * GUI.currentGUIScale) + center.y);
    const int sizeX = cast(int) floor(cast(double) inv.size.x * GUI.currentGUIScale);
    const int sizeY = cast(int) floor(cast(double) inv.size.y * GUI.currentGUIScale);

    { // Don't need to check all this if it's being hovered over.
        const Rectangle collisionBox = Rectangle(
            posX,
            posY,
            sizeX,
            sizeY);
        if (!CheckCollisionPointRec(mousePos, collisionBox)) {
            return false;
        }
    }

    const Item[] __itemsArray = inv.__inventory.getInventoryItems();
    const int sizeInv = cast(int) __itemsArray.length;
    const int widthInv = inv.__inventory.getWidth();

    const double slotSize = 48.0 * GUI.currentGUIScale;
    const double padding = 4.0 * GUI.currentGUIScale;

    int currentColumn = 0;

    double currentWidth = 0;
    double currentHeight = 0;

    foreach (i; 0 .. sizeInv) {

        const Rectangle slotRec = Rectangle(
            posX + cast(int) round(currentWidth),
            posY + cast(int) round(currentHeight),
            cast(int) floor(slotSize),
            cast(int) floor(slotSize));

        if (CheckCollisionPointRec(mousePos, slotRec)) {
            inv.mouseHovering = i;
            if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
                GUI.playButtonSound();
                inv.clickFunction(inv);

                // todo: needs to have a thing where if there's an item you're holding with the mouse
                // todo: in the onclose function, or if something happens, then it can put it back where you got it from.
                // todo: so store the inventory, which slot it came from.
                // todo: if the player manages to get something put in that slot then just try to add it in.
                // todo: if that fails then just dump the item on the ground.
            }
            return true;
        }

        currentWidth += (slotSize + padding);

        currentColumn++;
        if (currentColumn >= widthInv) {
            currentColumn = 0;
            currentWidth = 0;
            currentHeight += (slotSize + padding);
        }
    }

    // If the mouse is hovering over the button.
    // if (CheckCollisionPointRec(mousePos, buttonRect)) {
    //     button.mouseHovering = true;
    //     // If the mouse clicks the button.
    //     if (Mouse.isButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
    //         playButtonSound();
    //         button.clickFunction();
    //         return true;
    //     }
    // }
    return false;
}
