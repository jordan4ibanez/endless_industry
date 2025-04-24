module game.inventory;

final class Inventory {
private:

    int __size = 8;
public:

    this() {
    }

    @property void size(int size) {
        this.__size = size;
    }

    @property int size() {
        return this.__size;
    }

}
