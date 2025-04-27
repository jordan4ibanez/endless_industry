module game.inventory;

public import game.item_database;
public import utility.option;
import game.player;
import std.conv;
import std.math.rounding;
import std.stdio;
import utility.linked_hash_queue;

private:

// todo: swap to GC malloc so it doesn't incur boundary check
/**
*~ Some notes:
*~ 
*~ Inventory 1 is reserved for the mouse.
*~
*~
*~
*~
*/

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
        mouseCheck(inventory);
        playerInventoryCheck(inventory);
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
    mouseCheck(inventory);
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
    mouseCheck(inventory);
    boundsCheck(inventory);
    return __widths[inventory];
}

void setWidth(const Inventory inventory, const int width) {
    mouseCheck(inventory);
    boundsCheck(inventory);
    widthCheck(width);
    __widths[inventory] = width;
}

ItemStack[] getInventoryItems(Inventory inventory) {
    boundsCheck(inventory);
    return __items[inventory];
}

/// This is a specialty function in which the mouse has clicked an inventory slot.
/// I would highly not recommend using this in your mods if you value your sanity.
void clickSlot(Inventory inventory, const int slot) {
    // writeln("clicked slot: ", slot, " | in inventory: ", inventory);
    Player.__setLastFocusedInv(inventory);
    ItemStack[] __mouseInv = __items[1];
    ItemStack* mouseStack = &__mouseInv[0];
    ItemStack[] __targetInv = __items[inventory];
    ItemStack* targetStack = &__targetInv[slot];
    if (mouseStack.id == 0) {
        // Taking.
        // But nothing to take.
        if (targetStack.id == 0) {
            return;
        }
        swap(mouseStack, targetStack);
    } else {
        // Put or swap.
        if (targetStack.id != mouseStack.id) {
            // Swap.
            swap(mouseStack, targetStack);
        } else {
            // Put. This will automatically leave any residual in the mouse slot.
            insert(mouseStack, targetStack);
        }
    }
}

/// This is a specialty function in which the mouse has clicked an inventory slot.
/// I would highly not recommend using this in your mods if you value your sanity.
void splitClickSlot(Inventory inventory, const int slot) {
    // writeln("clicked slot: ", slot, " | in inventory: ", inventory);
    Player.__setLastFocusedInv(inventory);
    ItemStack[] __mouseInv = __items[1];
    ItemStack* mouseStack = &__mouseInv[0];
    ItemStack[] __targetInv = __items[inventory];
    ItemStack* targetStack = &__targetInv[slot];

    if (mouseStack.id == 0) {
        // Taking.
        // But nothing to take.
        if (targetStack.id == 0) {
            return;
        }

        // Take the upper half if count is odd.
        const int takenCount = cast(int) ceil(cast(double) targetStack.count / 2.0);
        const int remainder = targetStack.count - takenCount;

        mouseStack.id = targetStack.id;
        mouseStack.count = takenCount;

        // If you right click a single item, it's 0.
        if (remainder == 0) {
            targetStack.id = 0;
        }
        targetStack.count = remainder;
    } else {
        // Put 1 or no-op.
        if (targetStack.id == 0) {
            targetStack.id = mouseStack.id;
            targetStack.count++;
        } else if (targetStack.id == mouseStack.id) {
            const ItemDefinition __itemDef = ItemDatabase.getItemByID(mouseStack.id)
                .expect("ID " ~ to!string(mouseStack.id) ~ " is not a registered item");
            if (targetStack.count + 1 > __itemDef.maxStackSize) {
                return;
            }
            targetStack.count++;
        }
        mouseStack.count--;
        // Ran out of items.
        if (mouseStack.count == 0) {
            mouseStack.id = 0;
        }
    }
}

/// Add an item into an inventory.
/// Returns the leftover items that didn't fit, if any.
Option!ItemStack addItemByName(Inventory inventory, string name, int count = 1) {
    Option!ItemStack result;
    ItemStack[] thisInv = __items[inventory];
    const ItemDefinition __itemDef = ItemDatabase.getItemByName(name)
        .expect(name ~ " is not a registered item");
    ItemStack itemStack = ItemStack(__itemDef.id, count);
    foreach (ref ItemStack invSlotStack; thisInv) {
        if (invSlotStack.id == 0 || invSlotStack.id == itemStack.id) {
            insert(&itemStack, &invSlotStack);
            assert(itemStack.count >= 0, "reached less than 0");
            if (itemStack.count == 0) {
                break;
            }
        }
    }
    // If there was no room for more, the leftover gets returned as Some.
    if (itemStack.count > 0) {
        result = result.Some(itemStack);
    }
    return result;
}

/// Add an item into an inventory.
/// Returns the leftover items that didn't fit, if any.
Option!ItemStack addItemByID(Inventory inventory, int id, int count = 1) {
    Option!ItemStack result;
    ItemStack[] thisInv = __items[inventory];
    const ItemDefinition __itemDef = ItemDatabase.getItemByID(id)
        .expect("ID " ~ to!string(id) ~ " is not a registered item");
    ItemStack itemStack = ItemStack(__itemDef.id, count);
    foreach (ref ItemStack invSlotStack; thisInv) {
        if (invSlotStack.id == 0 || invSlotStack.id == itemStack.id) {
            insert(&itemStack, &invSlotStack);
            assert(itemStack.count >= 0, "reached less than 0");
            if (itemStack.count == 0) {
                break;
            }
        }
    }
    // If there was no room for more, the leftover gets returned as Some.
    if (itemStack.count > 0) {
        result = result.Some(itemStack);
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

pragma(inline, true)
void mouseCheck(const Inventory inventory) {
    if (inventory == 1) {
        throw new Error("Do not modify the mouse inventory");
    }
}

pragma(inline, true)
void playerInventoryCheck(const Inventory inventory) {
    if (inventory == 2) {
        throw new Error("Do not delete the player inventory");
    }
}

pragma(inline, true)
void widthCheck(const int width) {
    if (width <= 0) {
        throw new Error("width cannot be less than 1");
    }
}

pragma(inline, true)
void sizeCheck(const int size) {
    if (size <= 0) {
        throw new Error("size cannot be less than 1");
    }
}

pragma(inline, true)
void swap(ItemStack* currentStack, ItemStack* targetStack) {
    const ItemStack oldTarget = *targetStack;
    *targetStack = *currentStack;
    *currentStack = oldTarget;
}

void insert(ItemStack* currentStack, ItemStack* targetStack) {
    const ItemDefinition itemDef = ItemDatabase.getItemByID(currentStack.id)
        .expect("ID " ~ to!string(currentStack.id) ~ " not a registered item");
    const int MAX_STACK = itemDef.maxStackSize;
    const int AMOUNT_CAN_FIT = MAX_STACK - targetStack.count;
    if (AMOUNT_CAN_FIT == 0) {
        return;
    }
    if (AMOUNT_CAN_FIT >= currentStack.count) {
        targetStack.count += currentStack.count;
        currentStack.count = 0;
    } else {
        targetStack.count += AMOUNT_CAN_FIT;
        currentStack.count -= AMOUNT_CAN_FIT;
    }
    targetStack.id = currentStack.id;
    if (currentStack.count == 0) {
        currentStack.id = 0;
    }
    // writeln("new: ", currentStack.count, " | adder: ", targetStack.count);
    // writeln("+++++++++++++++");
}
