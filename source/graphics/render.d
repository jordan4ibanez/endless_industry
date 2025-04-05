module graphics.render;

public import raylib : Colors;
import math.rect;
import math.vec2d;
import raylib;

static final const class Render {
static:
private:

public: //* BEGIN PUBLIC API.

    void rectangle(Vec2d position, Vec2d size, Color color) {
        DrawRectangleV(invertPosition(position).toRaylib(), size.toRaylib(), color);
    }

    void rectangleLines(Vec2d position, Vec2d size, Color color, double thickness = 0.01) {
        Rect rect = Rect(position.x, position.y, size.x, size.y);
        DrawRectangleLinesEx(rect.toRaylib(), thickness, color);
    }

    void circle(Vec2d center, double radius, Color color) {
        DrawCircleV(center.toRaylib(), radius, color);
    }

private: //* BEGIN INTERNAL API.

}
