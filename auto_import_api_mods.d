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

void main() {

    // this turns it off when debugging the main mod API file.
    if (true) {
        return;
    }

    // writeln("AUTO IMPORT: Automating mod imports.");

    // These do not have to be synchronized.
    string[] importList = [];
    string[] mainFunctionList = [];

    foreach (filename; dirEntries("mods/", SpanMode.shallow)) {
        if (isDir!string(filename)) {
            // writeln("folder: ", filename);

            string target = filename ~ "/main.d";

            // If your mod does not have an main file, it gets skipped.

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
