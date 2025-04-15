module audio.audio;

import raylib;
import std.file;
import std.path;
import std.stdio;
import std.string;

static final const class Audio {
static:
private:

    Sound[string] database;

public: //* BEGIN PUBLIC API.

    void initialize() {
        InitAudioDevice();
        loadAllSounds();
    }

    void terminate() {
        foreach (name, sound; database) {
            // writeln("unloaded sound: ", name);
            UnloadSound(sound);
        }
        CloseAudioDevice();
    }

    /// Play a sound.
    /// If it's already playing, it will restart.
    void playSound(string name) {
        Sound* thisSound = name in database;
        if (thisSound is null) {
            throw new Error("Sound " ~ name ~ " does not exist");
        }
        PlaySound(*thisSound);
    }

private: //* BEGIN INTERNAL API.

    void loadAllSounds() {
        foreach (string thisFilePathString; dirEntries("sounds", "*{.wav,.ogg}", SpanMode.depth)) {
            loadSound(thisFilePathString);
        }
    }

    void loadSound(string location) {
        // Extract the file name from the location.
        string fileName = () {
            string[] items = location.split("/");
            int len = cast(int) items.length;
            if (len <= 1) {
                throw new Error("Sound must not be in root directory.");
            }
            string outputFileName = items[len - 1];
            if (!outputFileName.endsWith(".wav") && !outputFileName.endsWith(".ogg")) {
                throw new Error("Not .ogg or .wav");
            }
            return outputFileName;
        }();

        Sound thisSound = LoadSound(toStringz(location));

        if (fileName in database) {
            throw new Error("Duplicate sound: " ~ location);
        }

        database[fileName] = thisSound;
        // writeln("Loaded sound: ", location);
    }

}
