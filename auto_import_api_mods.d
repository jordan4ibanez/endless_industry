module auto_import_api_mods;

import std.algorithm.mutation;
import std.array;
import std.conv;
import std.file;
import std.stdio : File, writeln;
import std.string;

/*
This file literally just modified the api.d file.
*/

struct ModConfig {
    string modName = null;
    string modVersion = null;
}

void main() {

    // this turns it off when debugging the main mod API file.
    // if (true) {
    //     return;
    // }

    // writeln("AUTO IMPORT: Automating mod imports.");

    // These do not have to be synchronized.
    string[] importList = [];
    // But these do.
    string[] mainFunctionList = [];
    ModConfig[] configurationList = [];

    foreach (filename; dirEntries("mods/", SpanMode.shallow)) {
        if (isDir!string(filename)) {
            // writeln("folder: ", filename);

            string target = filename ~ "/mod.conf";

            // If your mod does not have an mod.conf file, it halts.

            try {
                // This will jump into the catch state if the mod.conf file isn't there.
                isFile!string(target);

                File confFile = File(target, "r");

                ModConfig thisConfig;

                foreach (thisLine; confFile.byLine()) {

                    // Get the version info.
                    if (thisLine.startsWith("version")) {
                        char[][] components = thisLine.split("=");
                        if (components.length != 2) {
                            throw new Error("Version line is malformed! " ~ target);
                        }
                        thisConfig.modVersion = components[1].idup;
                        // It has now been moved into a safely mutable area.

                        // Remove the quotes.
                        thisConfig.modVersion = thisConfig.modVersion.replace('"', ' ').strip();

                        // Now check if the string is semantically versioned.
                        string[] versionDataIndividual = thisConfig.modVersion.split(".");
                        if (versionDataIndividual.length != 3) {
                            throw new Error("Version is not semantic! " ~ target);
                        }
                        if (!versionDataIndividual.join().isNumeric()) {
                            throw new Error("Version contains garbage data! " ~ target);
                        }
                        foreach (thisPortion; versionDataIndividual) {
                            if (!thisPortion.isNumeric()) {
                                throw new Error("Version is malformed! " ~ target);
                            }
                        }
                    }
                    // Get the mod name.
                    if (thisLine.startsWith("name")) {
                        char[][] components = thisLine.split("=");
                        if (components.length != 2) {
                            throw new Error("Name line is malformed! " ~ target);
                        }
                        thisConfig.modName = components[1].idup;
                        // It has now been moved into a safely mutable area.

                        // Remove the quotes.
                        thisConfig.modName = thisConfig.modName.replace('"', ' ').strip();

                        // I only have a simple request, it should be plain ascii and have no spaces.
                        // This isn't to stop your creativity, it's to prevent any edge cases. 
                        if (thisConfig.modName.indexOf(' ') >= 0) {
                            throw new Error("Name must not contain spaces! " ~ target);
                        }
                        writeln(thisConfig.modName);
                    }
                }
            } catch (Exception e) {
                throw new Error(target ~ " | Missing mod.conf");
            }

            target = filename ~ "/main.d";

            // If your mod does not have an main.d file, it halts.

            if (isFile!string(target)) {

                // Turn it into a module path and chop the [.d] off it.
                string thisImport = target.replace("/", ".");

                thisImport = thisImport[0 .. (thisImport.length) - 2];
                importList ~= thisImport;

                // Extract the "main" function for the mod.

                string thisFunctionName = thisImport;

                // Remove the [source.mods.] and the [.main]

                thisFunctionName = thisFunctionName.replace("mods.", "");
                thisFunctionName = thisFunctionName.replace(".main", "");

                // These could probably use a regex, but, dumb solution first.

                // Take care of the periods and following characters.
                while (long x = thisFunctionName.indexOf(".")) {
                    if (x <= 0) {
                        break;
                    }
                    char[] temp = to!(char[])(thisFunctionName);
                    temp[x + 1 .. x + 2] = temp[x + 1 .. x + 2].toUpper();
                    temp = temp.remove(x);
                    thisFunctionName = temp.idup;
                }

                // Take care of the underscores and following characters.
                while (long x = thisFunctionName.indexOf("_")) {
                    if (x <= 0) {
                        break;
                    }
                    char[] temp = to!(char[])(thisFunctionName);
                    temp[x + 1 .. x + 2] = temp[x + 1 .. x + 2].toUpper();
                    temp = temp.remove(x);
                    thisFunctionName = temp.idup;
                }

                // Then, we plop Main onto the end.
                thisFunctionName ~= "Main";

                mainFunctionList ~= thisFunctionName;
            } else {
                throw new Error(target ~ " | Missing main.d");
            }
        }
    }

    File apiFile = File("mods/api.d", "r");

    string[] newFileData = [];

    bool detectedImport = false;

    bool inImports = false;
    bool insertedImports = false;

    bool inFunctions = false;
    bool insertedFunctions = false;

    foreach (thisLine; apiFile.byLine()) {
        if (inImports) {
            if (!insertedImports) {
                insertedImports = true;

                // Here we insert the imports.
                foreach (imp; importList) {
                    newFileData ~= "import " ~ imp ~ ";";
                }
            }

            if (thisLine == "//# =-AUTO IMPORT END-=") {
                // Insert a space to not fight the auto formatter.
                newFileData ~= "";
                inImports = false;
                // writeln("ended import");
                newFileData ~= to!string(thisLine);
            }
        } else if (inFunctions) {
            if (!insertedFunctions) {
                insertedFunctions = true;

                // Wrap the main function deployment in a function.
                newFileData ~= "void deployMainFunctions() {";

                // Here we insert the functions.
                foreach (func; mainFunctionList) {
                    newFileData ~= "    " ~ func ~ "();";
                }

                newFileData ~= "}";
            }
            if (thisLine == "//# =-AUTO FUNCTION END-=") {
                inFunctions = false;
                // writeln("ended function");
                newFileData ~= to!string(thisLine);
            }

        } else {
            newFileData ~= to!string(thisLine);

            if (thisLine == "//# =-AUTO IMPORT BEGIN-=") {
                // writeln("started import");
                inImports = true;
                detectedImport = true;
            } else if (thisLine == "//# =-AUTO FUNCTION BEGIN-=") {
                // writeln("start functions");
                inFunctions = true;
            }
        }
    }

    if (!detectedImport) {
        throw new Error("Do not modify the auto import!");
    }

    apiFile.close();

    File newApiFile = File("mods/api.d", "w");

    // writeln("========================================");
    foreach (line; newFileData) {
        // writeln(line);
        newApiFile.write(line ~ "\n");
    }
    // writeln("========================================");

    // writeln("AUTO IMPORT: Finished automating mod imports.");
}
