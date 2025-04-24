module game.inventory;

import game.item;

final class Inventory {
private:

    int __size = 10;
    int __width = 10;
    Item[] items;

public:

    this() {         
    }

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

// todo: data orient this
