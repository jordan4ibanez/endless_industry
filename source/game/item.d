module game.item;

struct ItemDefinition {
    string name = null;
    string texture = null;

    //! DO NOT USE.
    int id = -1;
    ulong texturePointsIndex = 0;
}

struct Item {
    int id = 0;
    int count = 0;
}

static final const class ItemHandler {
static:
private:

    Item[string] nameDatabase;

public:

    void registerItem(const string name, Item item) {

    }

}
