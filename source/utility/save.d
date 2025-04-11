module utility.save;

import d2sqlite3;
import optibrev;

static final const class Save {
static:
private:

    Option!Database database;

public: //* BEGIN PUBLIC API.

    void open(string saveName) {
        const string location = "saves/";
        const string fileExtension = ".sqlite";
        Database db = Database(location ~ saveName ~ fileExtension);

        database = database.Some(db);

    }

private: //* BEGIN INTERNAL API.

}
