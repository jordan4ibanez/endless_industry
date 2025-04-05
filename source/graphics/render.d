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
        Vec2d invertedPosition = invertPosition(position);
        Rect rect = Rect(invertedPosition.x, invertedPosition.y, size.x, size.y);
        DrawRectangleLinesEx(rect.toRaylib(), thickness, color);
    }

    void circle(Vec2d center, double radius, Color color) {
        Vec2d invertedPosition = invertPosition(center);
        DrawCircleV(invertedPosition.toRaylib(), radius, color);
    }

private: //* BEGIN INTERNAL API.

    Vec2d invertPosition(Vec2d position) {
        return Vec2d(position.x, -position.y);
    }

}
