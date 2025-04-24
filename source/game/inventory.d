module game.inventory;

final class Inventory {
private:

    int __size = 10;
    int __width = 10;

public:

    @property void size(int size) {
        __size = size;
    }

    @property int size() {
        return __size;
    }

    @property void width(int width) {
        __width = width;
    }

    @property int width() {
        return __width;
    }

}
