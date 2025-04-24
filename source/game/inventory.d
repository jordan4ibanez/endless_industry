module game.inventory;

import game.item;
import linked_hash_queue;

//? That's right, the inventory is actually just an integer in disguise.
public alias Inventory = int;

static final const class InventoryHandler {
static:
private:

    // todo: swap to GC malloc so it doesn't incur boundary check

    LinkedHashQueue!int freeSlots = LinkedHashQueue!int();

    int length = 0;
    int[] sizes;
    int[] widths;
    Item[][] items;

public:

    Inventory newInventory(int size = 10, int width = 10) {
        Option!int slotResult = freeSlots.popFront();
        int slot = 0;
        // This means there was a free slot available and it's going to use it.
        if (slotResult.isSome()) {
            slot = slotResult.unwrap();
            sizes[slot] = size;
            widths[slot] = width;
            items[slot] = new Item[](size);
        } else {
            slot = this.length;
            sizes ~= size;
            widths ~= width;
            items ~= new Item[](size);
        }
        return slot;
    }

    void deleteInventory(Inventory inventory) {
        if (length >= inventory || inventory < 0) {
            throw new Error("Inventory is of bounds. (doesn't exist)");
        }
        sizes[inventory] = 0;
        widths[inventory] = 0;
        items[inventory] = null;
        freeSlots.pushBack(inventory);
    }

    // @property int size() {
    //     return __size;
    // }

    // @property void width(int width) {
    //     __width = width;
    // }

    // @property int width() {
    //     return __width;
    // }
}
