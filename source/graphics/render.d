module graphics.render;

public import raylib : Colors;
import math.rect;
import math.vec2d;
import raylib;

static final const class Render {
static:
private:

    Matrix mat;
    float xOffset;
    float yOffset;
    Color currentColor;

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

    //? Begin high performance line draw function batch.

    pragma(inline)
    void startLineDrawBatch() {
        mat = rlGetMatrixTransform();
        xOffset = 0.5f / mat.m0;
        yOffset = 0.5f / mat.m5;
        rlBegin(RL_LINES);
        currentColor = Colors.WHITE;
        const Color black = Colors.BLACK;
        setLineDrawColor(black);
    }

    pragma(inline)
    void endLineDrawBatch() {
        rlEnd();
    }

    pragma(inline)
    void setLineDrawColor(const ref Color color) {
        // Do not bother sending this instruction to the GPU.
        if (color == currentColor) {
            return;
        }
        rlColor4ub(color.r, color.g, color.b, color.a);
        currentColor = color;
    }

    void batchDrawRectangleLines(const int posX, const int posY, const int width, const int height) {
        rlVertex2f(cast(float) posX + xOffset, cast(float) posY + yOffset);
        rlVertex2f(cast(float) posX + cast(float) width - xOffset, cast(float) posY + yOffset);

        rlVertex2f(cast(float) posX + cast(float) width - xOffset, cast(float) posY + yOffset);
        rlVertex2f(cast(float) posX + cast(float) width - xOffset, cast(float) posY + cast(
                float) height - yOffset);

        rlVertex2f(cast(float) posX + cast(float) width - xOffset, cast(float) posY + cast(
                float) height - yOffset);
        rlVertex2f(cast(float) posX + xOffset, cast(float) posY + cast(float) height - yOffset);

        rlVertex2f(cast(float) posX + xOffset, cast(float) posY + cast(float) height - yOffset);
        rlVertex2f(cast(float) posX + xOffset, cast(float) posY + yOffset);
    }

    //? End high performance line draw function batch.

private: //* BEGIN INTERNAL API.

    Vec2d invertPosition(Vec2d position) {
        return Vec2d(position.x, -position.y);
    }

}
