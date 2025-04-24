module game.inventory;

final class Inventory {
private:

    int __size = 10;
    int __width = 10;

public:

    /// Set the size of the inventory.
    @property void size(int size) {
        this.__size = size;
    }

    @property int size() {
        return this.__size;
    }

}
