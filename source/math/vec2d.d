module math.vec2d;

import core.stdc.tgmath;
import raylib.raylib_types : Matrix, Vector2;
import std.algorithm.comparison;

struct Vec2d {
    double x = 0.0;
    double y = 0.0;

    this(double x, double y) {
        this.x = x;
        this.y = y;
    }

    this(Vector2 old) {
        this.x = old.x;
        this.y = old.y;
    }

    Vector2 toRaylib() const {
        return Vector2(x, y);
    }
}

/// Vector with components value 0.0.
Vec2d vec2dZero() {
    Vec2d result = Vec2d(0.0, 0.0);
    return result;
}

/// Vector with components value 1.0
Vec2d vec2dOne() {
    Vec2d result = Vec2d(1.0, 1.0);
    return result;
}

/// Add two vectors (v1 + v2)
Vec2d vec2dAdd(Vec2d v1, Vec2d v2) {
    Vec2d result = Vec2d(v1.x + v2.x, v1.y + v2.y);

    return result;
}

/// Add vector and double value
Vec2d vec2dAddValue(Vec2d v, double add) {
    Vec2d result = Vec2d(v.x + add, v.y + add);

    return result;
}

/// Subtract two vectors (v1 - v2)
Vec2d vec2dSubtract(Vec2d v1, Vec2d v2) {
    Vec2d result = Vec2d(v1.x - v2.x, v1.y - v2.y);

    return result;
}

/// Subtract vector by double value
Vec2d vec2dSubtractValue(Vec2d v, double sub) {
    Vec2d result = Vec2d(v.x - sub, v.y - sub);

    return result;
}

/// Calculate vector length
double vec2dLength(Vec2d v) {
    double result = sqrt((v.x * v.x) + (v.y * v.y));

    return result;
}

/// Calculate vector square length
double vec2dLengthSqr(Vec2d v) {
    double result = (v.x * v.x) + (v.y * v.y);

    return result;
}

/// Calculate two vectors dot product
double vec2dDotProduct(Vec2d v1, Vec2d v2) {
    double result = (v1.x * v2.x + v1.y * v2.y);

    return result;
}

/// Calculate two vectors cross product
double vec2dCrossProduct(Vec2d v1, Vec2d v2) {
    double result = (v1.x * v2.y - v1.y * v2.x);

    return result;
}

/// Calculate distance between two vectors
double vec2dDistance(Vec2d v1, Vec2d v2) {
    double result = sqrt((v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y));

    return result;
}

/// Calculate square distance between two vectors
double vec2dDistanceSqr(Vec2d v1, Vec2d v2) {
    double result = ((v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y));

    return result;
}

/// Calculate the signed angle from v1 to v2, relative to the origin (0, 0)
/// NOTE: Coordinate system convention: positive X right, positive Y down,
/// positive angles appear clockwise, and negative angles appear counterclockwise
double vec2dAngle(Vec2d v1, Vec2d v2) {
    double result = 0.0;

    double dot = v1.x * v2.x + v1.y * v2.y;
    double det = v1.x * v2.y - v1.y * v2.x;

    result = atan2(det, dot);

    return result;
}

/// Calculate angle defined by a two vectors line
/// NOTE: Parameters need to be normalized
/// Current implementation should be aligned with glm::angle
double vec2dLineAngle(Vec2d start, Vec2d end) {
    double result = 0.0;

    // TODO(10/9/2023): Currently angles move clockwise, determine if this is wanted behavior
    result = -atan2(end.y - start.y, end.x - start.x);

    return result;
}

/// Scale vector (multiply by value)
Vec2d vec2dScale(Vec2d v, double scale) {
    Vec2d result = Vec2d(v.x * scale, v.y * scale);

    return result;
}

/// Multiply vector by vector
Vec2d vec2dMultiply(Vec2d v1, Vec2d v2) {
    Vec2d result = Vec2d(v1.x * v2.x, v1.y * v2.y);

    return result;
}

/// Negate vector
Vec2d vec2dNegate(Vec2d v) {
    Vec2d result = Vec2d(-v.x, -v.y);

    return result;
}

/// Divide vector by vector
Vec2d vec2dDivide(Vec2d v1, Vec2d v2) {
    Vec2d result = Vec2d(v1.x / v2.x, v1.y / v2.y);

    return result;
}

/// Normalize provided vector
Vec2d vec2dNormalize(Vec2d v) {
    Vec2d result = Vec2d();
    double length = sqrt((v.x * v.x) + (v.y * v.y));

    if (length > 0) {
        double ilength = 1.0 / length;
        result.x = v.x * ilength;
        result.y = v.y * ilength;
    }

    return result;
}

/// Transforms a Vec2d by a given Matrix
Vec2d vec2dTransform(Vec2d v, Matrix mat) {
    Vec2d result = Vec2d();

    double x = v.x;
    double y = v.y;
    double z = 0;

    result.x = mat.m0 * x + mat.m4 * y + mat.m8 * z + mat.m12;
    result.y = mat.m1 * x + mat.m5 * y + mat.m9 * z + mat.m13;

    return result;
}

/// Calculate linear interpolation between two vectors
Vec2d vec2dLerp(Vec2d v1, Vec2d v2, double amount) {
    Vec2d result = Vec2d();

    result.x = v1.x + amount * (v2.x - v1.x);
    result.y = v1.y + amount * (v2.y - v1.y);

    return result;
}

/// Calculate reflected vector to normal
Vec2d vec2dReflect(Vec2d v, Vec2d normal) {
    Vec2d result = Vec2d();

    double dotProduct = (v.x * normal.x + v.y * normal.y); /// Dot product

    result.x = v.x - (2.0 * normal.x) * dotProduct;
    result.y = v.y - (2.0 * normal.y) * dotProduct;

    return result;
}

/// Get min value for each pair of components
Vec2d vec2dMin(Vec2d v1, Vec2d v2) {
    Vec2d result = Vec2d();

    result.x = min(v1.x, v2.x);
    result.y = min(v1.y, v2.y);

    return result;
}

/// Get max value for each pair of components
Vec2d vec2dMax(Vec2d v1, Vec2d v2) {
    Vec2d result = Vec2d();

    result.x = max(v1.x, v2.x);
    result.y = max(v1.y, v2.y);

    return result;
}

/// Rotate vector by angle
Vec2d vec2dRotate(Vec2d v, double angle) {
    Vec2d result = Vec2d();

    double cosres = cos(angle);
    double sinres = sin(angle);

    result.x = v.x * cosres - v.y * sinres;
    result.y = v.x * sinres + v.y * cosres;

    return result;
}

/// Move Vector towards target
Vec2d vec2dMoveTowards(Vec2d v, Vec2d target, double maxDistance) {
    Vec2d result = Vec2d();

    double dx = target.x - v.x;
    double dy = target.y - v.y;
    double value = (dx * dx) + (dy * dy);

    if ((value == 0) || ((maxDistance >= 0) && (value <= maxDistance * maxDistance)))
        return target;

    double dist = sqrt(value);

    result.x = v.x + dx / dist * maxDistance;
    result.y = v.y + dy / dist * maxDistance;

    return result;
}

/// Invert the given vector
Vec2d vec2dInvert(Vec2d v) {
    Vec2d result = Vec2d(1.0 / v.x, 1.0 / v.y);

    return result;
}

/// Clamp the components of the vector between
/// min and max values specified by the given vectors
Vec2d vec2dClamp(Vec2d v, Vec2d mind, Vec2d maxd) {
    Vec2d result = Vec2d();

    result.x = min(maxd.x, max(mind.x, v.x));
    result.y = min(maxd.y, max(mind.y, v.y));

    return result;
}

/// Clamp the magnitude of the vector between two min and max values
Vec2d vec2dClampValue(Vec2d v, double min, double max) {
    Vec2d result = v;

    double length = (v.x * v.x) + (v.y * v.y);
    if (length > 0.0) {
        length = sqrt(length);

        double scale = 1; // By default, 1 as the neutral element.
        if (length < min) {
            scale = min / length;
        } else if (length > max) {
            scale = max / length;
        }

        result.x = v.x * scale;
        result.y = v.y * scale;
    }

    return result;
}

private immutable double EPSILON = 0.000001;

/// Check whether two given vectors are almost equal
int vec2dEquals(Vec2d p, Vec2d q) {

    int result = ((fabs(p.x - q.x)) <= (EPSILON * max(1.0, max(fabs(p.x), fabs(q.x))))) &&
        ((fabs(p.y - q.y)) <= (EPSILON * max(1.0, max(fabs(p.y), fabs(q.y)))));

    return result;
}

/// Compute the direction of a refracted ray
/// v: normalized direction of the incoming ray
/// n: normalized normal vector of the interface of two optical media
/// r: ratio of the refractive index of the medium from where the ray comes
///    to the refractive index of the medium on the other side of the surface
Vec2d vec2dRefract(Vec2d v, Vec2d n, double r) {
    Vec2d result = Vec2d();

    double dot = v.x * n.x + v.y * n.y;
    double d = 1.0 - r * r * (1.0 - dot * dot);

    if (d >= 0.0) {
        d = sqrt(d);
        v.x = r * v.x - (r * dot + d) * n.x;
        v.y = r * v.y - (r * dot + d) * n.y;

        result = v;
    }

    return result;
}
