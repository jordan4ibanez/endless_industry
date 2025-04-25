module game.inventory;

public import game.item_database;
public import utility.option;
import utility.linked_hash_queue;
import std.stdio;

private:

// todo: swap to GC malloc so it doesn't incur boundary check

LinkedHashQueue!int freeSlots = LinkedHashQueue!int();

int __length = 1;
int[] __widths = new int[](1);
Item[][] __items = new Item[][](1);

public:

//? That's right, the inventory is actually just an integer in disguise.
// I never use unions but now I can say I have.
union Inventory {
    int id = 0;
    alias id this;
}

//? This is just a facade to make it easier to figure out what is calling what.
static const struct InventoryHandler {
static:
    Inventory newInventory(const int size = 10, const int width = 10) {
        sizeCheck(size);
        widthCheck(width);
        Option!int slotResult = freeSlots.popFront();
        int slot = 0;
        // This means there was a free slot available and it's going to use it.
        if (slotResult.isSome()) {
            slot = slotResult.unwrap();
            __widths[slot] = width;
            __items[slot] = new Item[](size);
        } else {
            slot = __length;
            __widths ~= width;
            __items ~= new Item[](size);
            __length++;
        }
        return Inventory(slot);
    }

    void deleteInventory(const Inventory inventory) {
        boundsCheck(inventory);
        __widths[inventory] = 0;
        __items[inventory] = null;
        freeSlots.pushBack(inventory);
    }
}

int getSize(const Inventory inventory) {
    boundsCheck(inventory);
    return cast(int) __items[inventory].length;
}

void setSize(const Inventory inventory, const int size) {
    boundsCheck(inventory);
    sizeCheck(size);
    const int currentSize = cast(int) __items[inventory].length;
    if (size == currentSize) {
        writeln("warning: setting size to current size. No-op");
        return;
    } else if (size < currentSize) {
        __items[inventory] = __items[inventory][0 .. size];
    } else {
        __items[inventory] ~= new Item[](size - currentSize);
    }
}

int getWidth(const Inventory inventory) {
    boundsCheck(inventory);
    return __widths[inventory];
}

void setWidth(const Inventory inventory, const int width) {
    boundsCheck(inventory);
    widthCheck(width);
    __widths[inventory] = width;
}

Item[] getInventoryItems(Inventory inventory) {
    boundsCheck(inventory);
    return __items[inventory];
}

private:
pragma(inline)
void boundsCheck(const Inventory inventory) {
    import std.conv;

    assert(inventory < __length && inventory > 0, "Inventory is of bounds. (doesn't exist) " ~ to!string(
            inventory.id));
}

void widthCheck(const int width) {
    if (width <= 0) {
        throw new Error("width cannot be less than 1");
    }
}

void sizeCheck(const int size) {
    if (size <= 0) {
        throw new Error("size cannot be less than 1");
    }
}
