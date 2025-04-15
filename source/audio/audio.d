module audio.audio;

import raylib;

static final const class Audio {
static:
private:

    Sound[string] database;

public: //* BEGIN PUBLIC API.

    void initialize() {
        InitAudioDevice();
    }

    void terminate() {
        foreach (sound; database) {
            UnloadSound(sound);
        }
    }

    void loadSound(string location) {

    }

}
