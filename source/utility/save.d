module utility.save;

import d2sqlite3;
import math.vec2d;
import optibrev;

static final const class Save {
static:
private:

    bool opened = false;
    Database database;

public: //* BEGIN PUBLIC API.

    void open(string saveName) {
        const string location = "saves/";
        const string fileExtension = ".sqlite";
        database = Database(location ~ saveName ~ fileExtension);
        opened = true;
        performanceTune();
        createBaseStructure();
    }

    void close() {
        database.close();
        opened = false;
    }

    void testWrite() {
        Vec2d blah = Vec2d(1, 2);
        // database.prepare("insert or replace into mapdata (key, value) " ~
        //         "values (:key, :value)")
        //     .inject("test", blah);
    }

private: //* BEGIN INTERNAL API.

    void createBaseStructure() {
        checkOpened();

        database.prepare("create table if not exists " ~
                "mapdata (key text not null primary key, value, unique(key))")
            .inject();
    }

    pragma(inline, true)
    void checkOpened() {
        if (!opened) {
            throw new Error("No database opened.");
        }
    }

    void performanceTune() {
        checkOpened();

        // Journal in memory;
        database.prepare("pragma journal_mode = memory;").inject();

        // Write Ahead Logging mode.
        database.prepare("pragma journal_mode = WAL;").inject();

        // Regular synchronous mode.
        database.prepare("pragma synchronous = normal;").inject();

    }

}
