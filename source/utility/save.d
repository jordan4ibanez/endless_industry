module utility.save;

import d2sqlite3;
import game.map;
import math.vec2d;
import optibrev;
import std.stdio;
import utility.msgpack;

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

    void writePlayerPosition(Vec2d position) {
        const ubyte[] packedPosition = pack(position);
        writeIntoPlayerDatabase("singleplayerposition", packedPosition);
    }

    // void testRead() {
    //     checkOpened();

    //     // This may be using nullable but nullable is simply awful to work with.
    //     // Supplement it with optibrev.

    //     ResultRange results = database.execute(
    //         "select * from mapdata where \"key\" = :key", "test");

    //     foreach (Row row; results) {
    //         writeln("found");
    //         auto exists = row.peek!string(0);
    //         writeln(exists);
    //         auto testing = row.peek!(ubyte[])(1);
    //         Vec2d blah = unpack!Vec2d(testing);
    //         writeln(blah);

    //     }

    // }

    // void testWrite() {
    //     checkOpened();

    //     // Vec2d blah = Vec2d(1, 2);
    //     // ubyte[] testing = pack(blah);
    //     // database.prepare(
    //     //     "insert or replace into mapdata (key, value) " ~
    //     //         "values (:key, :value)")
    //     //     .inject("test", testing);
    // }

private: //* BEGIN INTERNAL API.

    void writeIntoPlayerDatabase(string key, const ubyte[] value) {
        checkOpened();
        database.prepare(
            "insert or replace into playerdata (key, value) " ~
                "values (:key, :value)")
            .inject(key, value);
    }

    void createBaseStructure() {
        checkOpened();

        database.prepare("create table if not exists " ~
                "mapdata (key text not null primary key, value, unique(key))")
            .inject();

        database.prepare(
            "create table if not exists " ~
                "playerdata (key text not null primary key, value, unique(key))")
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

        // Write Ahead Logging mode.
        database.prepare("pragma journal_mode = WAL;").inject();

        // Regular synchronous mode.
        database.prepare("pragma synchronous = normal;").inject();

        // Journal in memory;
        database.prepare("pragma journal_mode = memory;").inject();

    }

}
