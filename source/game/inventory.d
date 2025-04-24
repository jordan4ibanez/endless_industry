module game.inventory;

import game.item;
import linked_hash_queue;

public alias Inventory = int;

static final const class InventoryHandler {
static:
private:

    // todo: swap to GC malloc so it doesn't incur boundary check

    LinkedHashQueue!int freeSlots = LinkedHashQueue!int();

    int length = 0;
    int[] size;
    int[] width;
    Item[][] items;

public:

    Inventory newInventory(int size = 10, int width = 10) {
        Option!int slotResult = freeSlots.popBack();

        int slot = 0;

        // This means there was a free slot available and it's going to use it.
        if (slotResult.isSome()) {
            slot = slotResult.unwrap();
            this.size[slot] = size;
            this.width[slot] = width;
            items[slot] = new Item[](size);
        } else {
            slot = this.length;
            this.size ~= size;
            this.width ~= width;
            items ~= new Item[](size);
        }

        return 0;
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
