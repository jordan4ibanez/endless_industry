module utility.save;

import d2sqlite3;

static final const class Save {
static:
private:

    Database database;

public: //* BEGIN PUBLIC API.

    void open(string saveName) {
        const string location = "saves/";
        const string fileExtension = ".sqlite";
        database = Database(location ~ saveName ~ fileExtension);
    }

private: //* BEGIN INTERNAL API.

}
