module utility.option;

// Written in the D programming language.

/**
Optibrev is a minimalistic and powerful D library for managing optional values. 
 
It gives you a flexible way to handle `null` or missing values without writing excessive code. It supports the fundamental monadic operations such as `map`, enabling you to transform your data in a functional manner. 
Alongside, it provides methods like `unwrap`, `isNone`, `isSome`, and `orElse` for easy extraction and error handling. The main data structure in Optibrev is `Option`, which encapsulates an optional value. 

Copyright: LightHouse Software, 2024
Authors:   Oleg Bakharev,
		   Emily Tiernan
*/

// Option type
struct Option(T) {
    private {
        // type of stored value
        enum OptionType : byte {
            NONE,
            SOME
        }

        OptionType type;
        T value;

        this(OptionType type, T value = T.init) {
            this.type = type;
            this.value = value;
        }
    }

    /**
	Сhecks if Option has None (i.e empty, null etc.) value
	Returns:
	Returns true if the option is None, false otherwise.
    
    Typical usage:
    ----
    import std.stdio : writeln;
    
    Option!int value;
    writeln(value.isNone) // true
    ----
    */
    bool isNone() {
        return type == OptionType.NONE;
    }

    /**
	Сhecks if Option has value (i.e empty, null etc.) value
	Returns:
	Returns true if the option holds value, false otherwise.
    
    Typical usage:
    ----
    import std.stdio : writeln;
    
    Option!int value;
    value.Some(10)
    writeln(value.isSome) // true
    ----
    */
    bool isSome() {
        return type == OptionType.SOME;
    }

    /**
	A method that gets the value if the Option is Some, or return defaultValue otherwise.
	Returns:
	Returns the value in Option or default value.
    
    Typical usage:
    ----
    Option!int x;
    writeln(x.orElse());  // Prints: 10
    ----
    */
    T orElse(T defaultValue) {
        return (type == OptionType.NONE) ? defaultValue : value;
    }

    /**
	Сreate None (i.e empty, null etc.) value, packed in Option!T
	Returns:
	Returns Option!T with None value for given type T.
    
    Typical usage:
    ----
    import std.stdio : writeln;
    
    // without using None method gives default None value
    Option!int value;
    // ditto
    value = value.None();
    ----
    */
    Option!T None() {
        return Option!T(OptionType.NONE);
    }

    /**
	Сreate non-null or non-empty value, packed in Option!T
	Returns:
	Returns Option!T with packed value for given type T.
    
    Typical usage:
    ----
    import std.stdio : writeln;
    
    // without using None method gives default None value
    Option!int value;
    // set value in Option!int
    value = value.Some(5);
    ----
    */
    Option!T Some(T value) {
        return Option!T(OptionType.SOME, value);
    }

    /**
	A string representation of a Option type.
	The toString() method output Option type as a string in the following format: Some(value) or None()
	Returns:
	String representation for Option type.
    
    Typical usage:
    ----
    import std.stdio : writeln;
    
    Option!string s;
	s.writeln; // "None"
    ----
    */
    string toString() const {
        import std.conv : to;
        import std.format : format;

        return (type == OptionType.NONE) ? "None" : format("Some(%s)", to!string(value));
    }

    /**
	A method to unwrap the value of the Option.
	Returns:
	Returns the value stored in Option if Option itself does not consider None.
    
    Typical usage:
    ----
    Option!int x;
    x = x.Some(10);
    writeln(x.unwrap());  // Prints: 10
    ----
    */
    T unwrap() const {
        if (type == OptionType.SOME) {
            return value;
        }

        throw new Exception("Can't unwrap None");
    }

    Option!U map(U)(U delegate(T) func) {
        Option!U tmp;

        if (type == OptionType.NONE) {
            tmp = tmp.None();
        } else {
            tmp = tmp.Some(func(value));
        }
        return tmp;
    }
}
