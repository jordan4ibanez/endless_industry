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
    Rectangle rectangleShapeRectangle;
    int shapesTextureID;

public: //* BEGIN PUBLIC API.

    void initialize() {
        rectangleShapeRectangle = GetShapesTextureRectangle();
        shapesTextureID = GetShapesTexture().id;
    }

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

    //~ Begin high performance shape draw function batch.

    pragma(inline)
    void startShapeDrawBatch() {
        rlSetTexture(shapesTextureID);
        rlBegin(RL_TRIANGLES);
        currentColor = Colors.WHITE;
        setShapeDrawColor(Colors.BLACK);
    }

    pragma(inline)
    void endShapeDrawBatch() {
        rlEnd();
        rlSetTexture(0);
    }

    pragma(inline)
    void setShapeDrawColor(const Color color) {
        // Do not bother sending this instruction to the GPU.
        if (color == currentColor) {
            return;
        }
        rlColor4ub(color.r, color.g, color.b, color.a);
        currentColor = color;
    }

    void batchDrawRectangle(int posX, int posY, int width, int height) {
        Vector2 topLeft;
        Vector2 topRight;
        Vector2 bottomLeft;
        Vector2 bottomRight;

        float x = posX;
        float y = posY;
        topLeft = Vector2(x, y);
        topRight = Vector2(x + width, y);
        bottomLeft = Vector2(x, y + height);
        bottomRight = Vector2(x + width, y + height);

        rlVertex2f(topLeft.x, topLeft.y);
        rlVertex2f(bottomLeft.x, bottomLeft.y);
        rlVertex2f(topRight.x, topRight.y);

        rlVertex2f(topRight.x, topRight.y);
        rlVertex2f(bottomLeft.x, bottomLeft.y);
        rlVertex2f(bottomRight.x, bottomRight.y);
    }

    //~ End high performance shape draw function batch.

    //? Begin high performance line draw function batch.

    pragma(inline)
    void startLineDrawBatch() {
        mat = rlGetMatrixTransform();
        xOffset = 0.5 / mat.m0;
        yOffset = 0.5 / mat.m5;
        rlBegin(RL_LINES);
        currentColor = Colors.WHITE;
        setLineDrawColor(Colors.BLACK);
    }

    pragma(inline)
    void endLineDrawBatch() {
        rlEnd();
    }

    pragma(inline)
    void setLineDrawColor(const Color color) {
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
