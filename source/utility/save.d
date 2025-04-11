module utility.save;

import d2sqlite3;
import optibrev;

static final const class Save {
static:
private:

    //? This is temporarily wrapped in an option in case I blow something up.
    //? I am currently re-re-relearning sqlite.
    Option!Database database;

public: //* BEGIN PUBLIC API.

    void open(string saveName) {
        const string location = "saves/";
        const string fileExtension = ".sqlite";
        Database db = Database(location ~ saveName ~ fileExtension);
        database = database.Some(db);
    }

    void close() {
        if (database.isNone) {
            return;
        }
        database.unwrap().close();
    }

private: //* BEGIN INTERNAL API.

}
