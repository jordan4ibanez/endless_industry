module game.inventory;

import game.item;
import linked_hash_queue;
import std.stdio;

//? That's right, the inventory is actually just an integer in disguise.
public alias Inventory = int;

static final const class InventoryHandler {
static:
private:

    // todo: swap to GC malloc so it doesn't incur boundary check

    LinkedHashQueue!int freeSlots = LinkedHashQueue!int();

    int length = 0;
    int[] widths;
    Item[][] items;

public:

    Inventory newInventory(const int size = 10, const int width = 10) {
        sizeCheck(size);
        widthCheck(width);
        Option!int slotResult = freeSlots.popFront();
        int slot = 0;
        // This means there was a free slot available and it's going to use it.
        if (slotResult.isSome()) {
            slot = slotResult.unwrap();
            widths[slot] = width;
            items[slot] = new Item[](size);
        } else {
            slot = this.length;
            widths ~= width;
            items ~= new Item[](size);
        }
        return slot;
    }

    void deleteInventory(const Inventory inventory) {
        if (length >= inventory || inventory <= 0) {
            throw new Error("Inventory is of bounds. (doesn't exist)");
        }
        widths[inventory] = 0;
        items[inventory] = null;
        freeSlots.pushBack(inventory);
    }

    int getSize(const Inventory inventory) {
        return cast(int) items[inventory].length;
    }

    void setSize(const Inventory inventory, const int size) {
        sizeCheck(size);
        const int currentSize = cast(int) items[inventory].length;
        if (size == currentSize) {
            writeln("warning: setting size to current size. No-op");
            return;
        } else if (size < currentSize) {
            items[inventory] = items[inventory][0 .. size];
        } else {
            items[inventory] ~= new Item[](size - currentSize);
        }
    }

    int getWidth(const Inventory inventory) {
        return widths[inventory];
    }

    void setWidth(const Inventory inventory, const int width) {
        widthCheck(width);
        widths[inventory] = width;
    }

private:
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
}
