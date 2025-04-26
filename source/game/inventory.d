module game.inventory;

public import game.item_database;
public import utility.option;
import std.stdio;
import utility.linked_hash_queue;

private:

// todo: swap to GC malloc so it doesn't incur boundary check

LinkedHashQueue!int freeSlots = LinkedHashQueue!int();

int __length = 1;
int[] __widths = new int[](1);
ItemStack[][] __items = new ItemStack[][](1);

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
            __items[slot] = new ItemStack[](size);
        } else {
            slot = __length;
            __widths ~= width;
            __items ~= new ItemStack[](size);
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
        __items[inventory] ~= new ItemStack[](size - currentSize);
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

ItemStack[] getInventoryItems(Inventory inventory) {
    boundsCheck(inventory);
    return __items[inventory];
}

/// Add an item into an inventory.
/// Returns the leftover items that didn't fit, if any.
Option!ItemStack addItem(Inventory inventory, string name, int count = 1) {
    Option!ItemStack result;

    ItemStack[] thisInv = __items[inventory];

    const ItemDefinition itemDef = ItemDatabase.getItemByName(name)
        .expect(name ~ " is not a registered item");

    ItemStack itemStack = ItemStack(itemDef.id, count);

    const int MAX_STACK = itemDef.maxStackSize;

    void insert(ref int currentCount) {
        // const int test = ;
        writeln("===============");
        const int AMOUNT_CAN_FIT = MAX_STACK - currentCount;

        if (AMOUNT_CAN_FIT > itemStack.count) {
            currentCount += itemStack.count;
            itemStack.count = 0;
        } else {
            currentCount += AMOUNT_CAN_FIT;
            itemStack.count -= AMOUNT_CAN_FIT;
        }

        writeln("new: ", currentCount, " | adder: ", itemStack.count);

        writeln("+++++++++++++++");
    }

    foreach (ref invSlotItem; thisInv) {

        if (invSlotItem.id == 0 || invSlotItem.id == itemStack.id) {

            //todo: Empty, good to dump an entire stack in.
            //todo: this can still yield leftovers 

            insert(invSlotItem.count);

            //todo: Partially, if not entirely full. Needs to check for room.
            //todo: if room calculate how much can add, like if adding in
            //todo: more than a full stack at once, it could loop over until either finding another slot to add into or
            //todo: it reached the end.
            //todo: If the calculation drops to 0, break the loop.

            if (itemStack.count < 0) {
                writeln("wat ", itemStack.count);
                throw new Error("reached less than 0");
            }
            if (itemStack.count == 0) {
                break;
            }

        }
    }

    return result;
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
