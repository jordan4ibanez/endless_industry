module gui.component;

import math.vec2d;
import math.vec2i;

class Component {
package:

    // The ID of this component.
    string componentID = null;

public:

    // The position this component has in the window's work area.
    Vec2d position;
}

class Button : Component {
    double width = 100;
    double height = 32;

    /// What this button says on it.
    string buttonText = null;

    abstract void clickFunction();
}
