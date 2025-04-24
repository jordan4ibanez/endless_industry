module gui.component_draw;

import gui.component;
import gui.font;
import gui.gui;
import math.vec2i;
import raylib : Vector2;
import std.math.rounding;

///? Base component.
void drawComponent(ref Component __self, const ref Vec2i center, const StartScissorFunction startScissorComponent,
    const EndScissorFunction endScissorComponent) {
}

