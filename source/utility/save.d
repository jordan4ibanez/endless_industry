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
        database = database.Some(Database(location ~ saveName ~ fileExtension));

    }

private: //* BEGIN INTERNAL API.

}
