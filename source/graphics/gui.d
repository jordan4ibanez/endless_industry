module graphics.gui;

import math.vec2d;

static final const class GUI {
static:
private:

    // We standardize the GUI with 1080p.
    immutable Vec2d standardSize = Vec2d(1920.0, 1080.0);
    double currentGUIScale = 1.0;

public: //* BEGIN PUBLIC API.

    double getGUIScale() {
        return currentGUIScale;
    }

    void __update(Vec2d newWindowSize) {
        // Find out which GUI scale is smaller so things can be scaled around it.

        Vec2d scales = Vec2d(newWindowSize.x / standardSize.x, newWindowSize.y / standardSize.y);

        if (scales.x >= scales.y) {
            currentGUIScale = scales.y;
        } else {
            currentGUIScale = scales.x;
        }
    }

private: //* BEGIN INTERNAL API.
}
