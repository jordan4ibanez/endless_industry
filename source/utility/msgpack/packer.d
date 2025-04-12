module utility.msgpack.packer;

import utility.msgpack.attribute;
import utility.msgpack.common;
import utility.msgpack.exception;

import std.array;
import std.container;
import std.exception;
import std.range;
import std.stdio;
import std.traits;
import std.typecons;
import std.typetuple;

/**
 * $(D Packer) is a $(D MessagePack) serializer
 *
 * Example:
 * -----
 * auto packer = packer(Appender!(ubyte[])());
 *
 * packer.packArray(false, 100, 1e-10, null);
 *
 * stdout.rawWrite(packer.stream.data);
 * -----
 *
 * NOTE:
 *  Current implementation can't deal with a circular reference.
 *  If you try to serialize a object that has circular reference, runtime raises 'Stack Overflow'.
 */
struct PackerImpl(Stream)
        if (isOutputRange!(Stream, ubyte) && isOutputRange!(Stream, ubyte[])) {
private:
    static @system {
        alias PackHandler = void delegate(ref PackerImpl, void*);
        PackHandler[TypeInfo] packHandlers;

        public void registerHandler(T, alias Handler)() {
            packHandlers[typeid(T)] = delegate(ref PackerImpl packer, void* obj) {
                Handler(packer, *cast(T*) obj);
            };
        }

        public void register(T)() {
            packHandlers[typeid(T)] = delegate(ref PackerImpl packer, void* obj) {
                packer.packObject(*cast(T*) obj);
            };
        }
    }

    enum size_t offset = 1; // type-information offset

    Stream stream_; // the stream to write
    //? This is 11.
    ubyte[offset + RealSize] store_; // stores serialized value
    bool withFieldName_;

public:
    /**
     * Constructs a packer with $(D_PARAM stream).
     *
     * Params:
     *  stream        = the stream to write.
     *  withFieldName = serialize class / struct with field name
     */
    this(Stream stream, bool withFieldName = false) {
        stream_ = stream;
        withFieldName_ = withFieldName;
    }

    /**
     * Constructs a packer with $(D_PARAM withFieldName).
     *
     * Params:
     *  withFieldName = serialize class / struct with field name
     */
    this(bool withFieldName) {
        withFieldName_ = withFieldName;
    }

    /**
     * Forwards to stream.
     *
     * Returns:
     *  the stream.
     */
    @property @safe
    nothrow ref Stream stream() {
        return stream_;
    }

    /**
     * Serializes argument and writes to stream.
     *
     * If the argument is the pointer type, dereferences the pointer and serializes pointed value.
     * -----
     * int  a = 10;
     * int* b = &b;
     *
     * packer.pack(b);  // serializes 10, not address of a
     * -----
     * Serializes nil if the argument of nullable type is null.
     *
     * NOTE:
     *  MessagePack doesn't define $(D_KEYWORD real) type format.
     *  Don't serialize $(D_KEYWORD real) if you communicate with other languages.
     *  Transfer $(D_KEYWORD double) serialization if $(D_KEYWORD real) on your environment equals $(D_KEYWORD double).
     *
     * Params:
     *  value = the content to serialize.
     *
     * Returns:
     *  self, i.e. for method chaining.
     */
    ref PackerImpl pack(T)(in T value) if (is(Unqual!T == bool)) {
        if (value)
            stream_.put(Format.TRUE);
        else
            stream_.put(Format.FALSE);

        return this;
    }

    /// ditto
    ref PackerImpl pack(T)(in T value) if (isUnsigned!T && !is(Unqual!T == enum)) {
        // ulong < ulong is slower than uint < uint
        static if (!is(Unqual!T == ulong)) {
            enum Bits = T.sizeof * 8;

            if (value < (1 << 8)) {
                if (value < (1 << 7)) {
                    // fixnum
                    stream_.put(take8from!Bits(value));
                } else {
                    // uint 8
                    store_[0] = Format.UINT8;
                    store_[1] = take8from!Bits(value);
                    stream_.put(store_[0 .. offset + ubyte.sizeof]);
                }
            } else {
                if (value < (1 << 16)) {
                    // uint 16
                    const temp = convertEndianTo!16(value);

                    store_[0] = Format.UINT16;
                    *cast(ushort*)&store_[offset] = temp;
                    stream_.put(store_[0 .. offset + ushort.sizeof]);
                } else {
                    // uint 32
                    const temp = convertEndianTo!32(value);

                    store_[0] = Format.UINT32;
                    *cast(uint*)&store_[offset] = temp;
                    stream_.put(store_[0 .. offset + uint.sizeof]);
                }
            }
        } else {
            if (value < (1UL << 8)) {
                if (value < (1UL << 7)) {
                    // fixnum
                    stream_.put(take8from!64(value));
                } else {
                    // uint 8
                    store_[0] = Format.UINT8;
                    store_[1] = take8from!64(value);
                    stream_.put(store_[0 .. offset + ubyte.sizeof]);
                }
            } else {
                if (value < (1UL << 16)) {
                    // uint 16
                    const temp = convertEndianTo!16(value);

                    store_[0] = Format.UINT16;
                    *cast(ushort*)&store_[offset] = temp;
                    stream_.put(store_[0 .. offset + ushort.sizeof]);
                } else if (value < (1UL << 32)) {
                    // uint 32
                    const temp = convertEndianTo!32(value);

                    store_[0] = Format.UINT32;
                    *cast(uint*)&store_[offset] = temp;
                    stream_.put(store_[0 .. offset + uint.sizeof]);
                } else {
                    // uint 64
                    const temp = convertEndianTo!64(value);

                    store_[0] = Format.UINT64;
                    *cast(ulong*)&store_[offset] = temp;
                    stream_.put(store_[0 .. offset + ulong.sizeof]);
                }
            }
        }

        return this;
    }

    /// ditto
    ref PackerImpl pack(T)(in T value)
            if (isSigned!T && isIntegral!T && !is(Unqual!T == enum)) {
        // long < long is slower than int < int
        static if (!is(Unqual!T == long)) {
            enum Bits = T.sizeof * 8;

            if (value < -(1 << 5)) {
                if (value < -(1 << 15)) {
                    // int 32
                    const temp = convertEndianTo!32(value);

                    store_[0] = Format.INT32;
                    *cast(int*)&store_[offset] = temp;
                    stream_.put(store_[0 .. offset + int.sizeof]);
                } else if (value < -(1 << 7)) {
                    // int 16
                    const temp = convertEndianTo!16(value);

                    store_[0] = Format.INT16;
                    *cast(short*)&store_[offset] = temp;
                    stream_.put(store_[0 .. offset + short.sizeof]);
                } else {
                    // int 8
                    store_[0] = Format.INT8;
                    store_[1] = take8from!Bits(value);
                    stream_.put(store_[0 .. offset + byte.sizeof]);
                }
            } else if (value < (1 << 7)) {
                // fixnum
                stream_.put(take8from!Bits(value));
            } else {
                if (value < (1 << 8)) {
                    // uint 8
                    store_[0] = Format.UINT8;
                    store_[1] = take8from!Bits(value);
                    stream_.put(store_[0 .. offset + ubyte.sizeof]);
                } else if (value < (1 << 16)) {
                    // uint 16
                    const temp = convertEndianTo!16(value);

                    store_[0] = Format.UINT16;
                    *cast(ushort*)&store_[offset] = temp;
                    stream_.put(store_[0 .. offset + ushort.sizeof]);
                } else {
                    // uint 32
                    const temp = convertEndianTo!32(value);

                    store_[0] = Format.UINT32;
                    *cast(uint*)&store_[offset] = temp;
                    stream_.put(store_[0 .. offset + uint.sizeof]);
                }
            }
        } else {
            if (value < -(1L << 5)) {
                if (value < -(1L << 15)) {
                    if (value < -(1L << 31)) {
                        // int 64
                        const temp = convertEndianTo!64(value);

                        store_[0] = Format.INT64;
                        *cast(long*)&store_[offset] = temp;
                        stream_.put(store_[0 .. offset + long.sizeof]);
                    } else {
                        // int 32
                        const temp = convertEndianTo!32(value);

                        store_[0] = Format.INT32;
                        *cast(int*)&store_[offset] = temp;
                        stream_.put(store_[0 .. offset + int.sizeof]);
                    }
                } else {
                    if (value < -(1L << 7)) {
                        // int 16
                        const temp = convertEndianTo!16(value);

                        store_[0] = Format.INT16;
                        *cast(short*)&store_[offset] = temp;
                        stream_.put(store_[0 .. offset + short.sizeof]);
                    } else {
                        // int 8
                        store_[0] = Format.INT8;
                        store_[1] = take8from!64(value);
                        stream_.put(store_[0 .. offset + byte.sizeof]);
                    }
                }
            } else if (value < (1L << 7)) {
                // fixnum
                stream_.put(take8from!64(value));
            } else {
                if (value < (1L << 16)) {
                    if (value < (1L << 8)) {
                        // uint 8
                        store_[0] = Format.UINT8;
                        store_[1] = take8from!64(value);
                        stream_.put(store_[0 .. offset + ubyte.sizeof]);
                    } else {
                        // uint 16
                        const temp = convertEndianTo!16(value);

                        store_[0] = Format.UINT16;
                        *cast(ushort*)&store_[offset] = temp;
                        stream_.put(store_[0 .. offset + ushort.sizeof]);
                    }
                } else {
                    if (value < (1L << 32)) {
                        // uint 32
                        const temp = convertEndianTo!32(value);

                        store_[0] = Format.UINT32;
                        *cast(uint*)&store_[offset] = temp;
                        stream_.put(store_[0 .. offset + uint.sizeof]);
                    } else {
                        // uint 64
                        const temp = convertEndianTo!64(value);

                        store_[0] = Format.UINT64;
                        *cast(ulong*)&store_[offset] = temp;
                        stream_.put(store_[0 .. offset + ulong.sizeof]);
                    }
                }
            }
        }

        return this;
    }

    /// ditto
    ref PackerImpl pack(T)(in T value) if (isSomeChar!T && !is(Unqual!T == enum)) {
        static if (is(Unqual!T == char)) {
            return pack(cast(ubyte)(value));
        } else static if (is(Unqual!T == wchar)) {
            return pack(cast(ushort)(value));
        } else static if (is(Unqual!T == dchar)) {
            return pack(cast(uint)(value));
        }
    }

    /// ditto
    ref PackerImpl pack(T)(in T value)
            if (isFloatingPoint!T && !is(Unqual!T == enum)) {
        static if (is(Unqual!T == float)) {
            const temp = convertEndianTo!32(_f(value).i);

            store_[0] = Format.FLOAT;
            *cast(uint*)&store_[offset] = temp;
            stream_.put(store_[0 .. offset + uint.sizeof]);
        } else static if (is(Unqual!T == double)) {
            const temp = convertEndianTo!64(_d(value).i);

            store_[0] = Format.DOUBLE;
            *cast(ulong*)&store_[offset] = temp;
            stream_.put(store_[0 .. offset + ulong.sizeof]);
        } else {
            static if ((real.sizeof > double.sizeof) && EnableReal) {
                store_[0] = Format.REAL;
                const temp = _r(value);
                const fraction = convertEndianTo!64(temp.fraction);
                const exponent = convertEndianTo!16(temp.exponent);

                *cast(Unqual!(typeof(fraction))*)&store_[offset] = fraction;
                *cast(Unqual!(typeof(exponent))*)&store_[offset + fraction.sizeof] = exponent;
                stream_.put(store_[0 .. $]);
            } else { // Non-x86 CPUs, real type equals double type.
                pack(cast(double) value);
            }
        }

        return this;
    }

    /// ditto
    ref PackerImpl pack(T)(in T value) if (is(Unqual!T == enum)) {
        pack(cast(OriginalType!T) value);

        return this;
    }

    /// Overload for pack(null) for 2.057 or later
    static if (!is(typeof(null) == void*)) {
        ref PackerImpl pack(T)(in T value) if (is(Unqual!T == typeof(null))) {
            return packNil();
        }
    }

    /// ditto
    ref PackerImpl pack(T)(in T value) if (isPointer!T) {
        static if (is(Unqual!T == void*)) { // for pack(null) for 2.056 or earlier
            enforce(value is null, "Can't serialize void type");
            stream_.put(Format.NIL);
        } else {
            if (value is null)
                stream_.put(Format.NIL);
            else
                pack(mixin(AsteriskOf!T ~ "value"));
        }

        return this;
    }

    /// ditto
    ref PackerImpl pack(T)(in T array)
            if ((isArray!T || isInstanceOf!(Array, T)) && !is(Unqual!T == enum)) {
        alias U = typeof(T.init[0]);

        if (array.empty)
            return packNil();

        // Raw bytes
        static if (isByte!(U) || isSomeChar!(U)) {
            ubyte[] raw = cast(ubyte[]) array;

            beginRaw(raw.length);
            stream_.put(raw);
        } else {
            beginArray(array.length);
            foreach (elem; array)
                pack(elem);
        }

        return this;
    }

    /// ditto
    ref PackerImpl pack(T)(in T array) if (isAssociativeArray!T) {
        if (array is null)
            return packNil();

        beginMap(array.length);
        foreach (key, value; array) {
            pack(key);
            pack(value);
        }

        return this;
    }

    /// ditto
    ref PackerImpl pack(Types...)(auto ref const Types objects) if (Types.length > 1) {
        foreach (i, T; Types)
            pack(objects[i]);

        return this;
    }

    /**
     * Serializes $(D_PARAM object) and writes to stream.
     *
     * Calling $(D toMsgpack) if $(D_KEYWORD class) and $(D_KEYWORD struct) implement $(D toMsgpack) method. $(D toMsgpack) signature is:
     * -----
     * void toMsgpack(Packer)(ref Packer packer) const
     * -----
     * This method serializes all members of T object if $(D_KEYWORD class) and $(D_KEYWORD struct) don't implement $(D toMsgpack).
     *
     * An object that doesn't implement $(D toMsgpack) is serialized to Array type.
     * -----
     * packer.pack(tuple(true, 1, "Hi!"))  // -> '[true, 1, "Hi!"]', not 'ture, 1, "Hi!"'
     *
     * struct Foo
     * {
     *     int num    = 10;
     *     string msg = "D!";
     * }
     * packer.pack(Foo());  // -> '[10, "D!"]'
     *
     * class Base
     * {
     *     bool flag = true;
     * }
     * class Derived : Base
     * {
     *     double = 0.5f;
     * }
     * packer.pack(new Derived());  // -> '[true, 0.5f]'
     * -----
     *
     * Params:
     *  object = the content to serialize.
     *
     * Returns:
     *  self, i.e. for method chaining.
     */
    ref PackerImpl pack(T)(in T object) if (is(Unqual!T == class)) {
        if (object is null)
            return packNil();

        static if (hasMember!(T, "toMsgpack")) {
            static if (__traits(compiles, {
                    object.toMsgpack(this, withFieldName_);
                })) {
                object.toMsgpack(this, withFieldName_);
            } else static if (__traits(compiles, { object.toMsgpack(this); })) { // backward compatible
                object.toMsgpack(this);
            } else {
                static assert(0, "Failed to invoke 'toMsgpack' on type '" ~ Unqual!T.stringof ~ "'");
            }
        } else {
            if (auto handler = object.classinfo in packHandlers) {
                (*handler)(this, cast(void*)&object);
                return this;
            }
            if (T.classinfo !is object.classinfo) {
                throw new MessagePackException(
                    "Can't pack derived class through reference to base class.");
            }

            packObject!(T)(object);
        }

        return this;
    }

    /// ditto
    @trusted
    ref PackerImpl pack(T)(auto ref T object)
            if (is(Unqual!T == struct) &&
            !isInstanceOf!(Array, T) &&
            !is(Unqual!T == ExtValue)) {
        static if (hasMember!(T, "toMsgpack")) {
            static if (__traits(compiles, {
                    object.toMsgpack(this, withFieldName_);
                })) {
                object.toMsgpack(this, withFieldName_);
            } else static if (__traits(compiles, { object.toMsgpack(this); })) { // backward compatible
                object.toMsgpack(this);
            } else {
                static assert(0, "Failed to invoke 'toMsgpack' on type '" ~ Unqual!T.stringof ~ "'");
            }
        } else static if (isTuple!T) {
            beginArray(object.field.length);
            foreach (f; object.field)
                pack(f);
        } else { // simple struct
            if (auto handler = typeid(Unqual!T) in packHandlers) {
                (*handler)(this, cast(void*)&object);
                return this;
            }

            immutable memberNum = SerializingMemberNumbers!(T);
            if (withFieldName_)
                beginMap(memberNum);
            else
                beginArray(memberNum);

            if (withFieldName_) {
                foreach (i, f; object.tupleof) {
                    static if (isPackedField!(T.tupleof[i])) {
                        pack(getFieldName!(T, i));
                        static if (hasSerializedAs!(T.tupleof[i])) {
                            alias Proxy = getSerializedAs!(T.tupleof[i]);
                            Proxy.serialize(this, f);
                        } else static if (__traits(compiles, { pack(f); }))
                            pack(f);
                    }
                }
            } else {
                foreach (i, f; object.tupleof) {
                    static if (isPackedField!(T.tupleof[i])) {
                        static if (hasSerializedAs!(T.tupleof[i])) {
                            alias Proxy = getSerializedAs!(T.tupleof[i]);
                            Proxy.serialize(this, f);
                        } else static if (__traits(compiles, { pack(f); }))
                            pack(f);
                    }
                }
            }
        }

        return this;
    }

    void packObject(T)(in T object) if (is(Unqual!T == class)) {
        alias Classes = SerializingClasses!(T);

        immutable memberNum = SerializingMemberNumbers!(Classes);
        if (withFieldName_)
            beginMap(memberNum);
        else
            beginArray(memberNum);

        foreach (Class; Classes) {
            Class obj = cast(Class) object;
            if (withFieldName_) {
                foreach (i, f; obj.tupleof) {
                    static if (isPackedField!(Class.tupleof[i])) {
                        pack(getFieldName!(Class, i));
                        static if (hasSerializedAs!(T.tupleof[i])) {
                            alias Proxy = getSerializedAs!(T.tupleof[i]);
                            Proxy.serialize(this, f);
                        } else {
                            pack(f);
                        }
                    }
                }
            } else {
                foreach (i, f; obj.tupleof) {
                    static if (isPackedField!(Class.tupleof[i])) {
                        static if (hasSerializedAs!(T.tupleof[i])) {
                            alias Proxy = getSerializedAs!(T.tupleof[i]);
                            Proxy.serialize(this, f);
                        } else {
                            pack(f);
                        }
                    }
                }
            }
        }
    }

    /**
     * Serializes the arguments as container to stream.
     *
     * -----
     * packer.packArray(true, 1);  // -> [true, 1]
     * packer.packMap("Hi", 100);  // -> ["Hi":100]
     * -----
     *
     * In packMap, the number of arguments must be even.
     *
     * Params:
     *  objects = the contents to serialize.
     *
     * Returns:
     *  self, i.e. for method chaining.
     */
    ref PackerImpl packArray(Types...)(auto ref const Types objects) {
        beginArray(Types.length);
        foreach (i, T; Types)
            pack(objects[i]);
        //pack(objects);  // slow :(

        return this;
    }

    /// ditto
    ref PackerImpl packMap(Types...)(auto ref const Types objects) {
        static assert(Types.length % 2 == 0, "The number of arguments must be even");

        beginMap(Types.length / 2);
        foreach (i, T; Types)
            pack(objects[i]);

        return this;
    }

    /**
     * Packs $(D data) as an extended value of $(D type).
     *
     * ----
     * packer.packExt(3, bytes);
     * ----
     *
     * $(D type) must be a signed byte 0-127.
     *
     * Params:
     *  type = the application-defined type for the data
     *  data = an array of bytes
     *
     * Returns:
     *  seld, i.e. for method chaining.
     */
    ref PackerImpl pack(T)(auto ref const T data) if (is(Unqual!T == ExtValue)) {
        packExt(data.type, data.data);
        return this;
    }

    /**
     * Packs $(D data) as an extended value of $(D type).
     *
     * ----
     * packer.packExt(3, bytes);
     * ----
     *
     * $(D type) must be a signed byte 0-127.
     *
     * Params:
     *  type = the application-defined type for the data
     *  data = an array of bytes
     *
     * Returns:
     *  seld, i.e. for method chaining.
     */
    ref PackerImpl packExt(in byte type, const ubyte[] data) return {
        ref PackerImpl packExtFixed(int fmt) {
            store_[0] = cast(ubyte) fmt;
            store_[1] = type;
            stream_.put(store_[0 .. 2]);
            stream_.put(data);
            return this;
        }

        // Try packing to a fixed-length type
        if (data.length == 1)
            return packExtFixed(Format.EXT + 0);
        else if (data.length == 2)
            return packExtFixed(Format.EXT + 1);
        else if (data.length == 4)
            return packExtFixed(Format.EXT + 2);
        else if (data.length == 8)
            return packExtFixed(Format.EXT + 3);
        else if (data.length == 16)
            return packExtFixed(Format.EXT + 4);

        int typeByte = void;
        if (data.length <= (2 ^^ 8) - 1) {
            store_[0] = Format.EXT8;
            store_[1] = cast(ubyte) data.length;
            typeByte = 2;

        } else if (data.length <= (2 ^^ 16) - 1) {
            store_[0] = Format.EXT16;
            const temp = convertEndianTo!16(data.length);
            *cast(ushort*)&store_[offset] = temp;
            typeByte = 3;
        } else if (data.length <= (2 ^^ 32) - 1) {
            store_[0] = Format.EXT32;
            const temp = convertEndianTo!32(data.length);
            *cast(uint*)&store_[offset] = temp;
            typeByte = 5;
        } else
            throw new MessagePackException("Data too large to pack as EXT");

        store_[typeByte] = type;
        stream_.put(store_[0 .. typeByte + 1]);
        stream_.put(data);

        return this;
    }

    /*
     * Serializes raw type-information to stream for binary type.
     */
    void beginRaw(in size_t length) {
        import std.conv : text;

        if (length < 32) {
            const ubyte temp = Format.RAW | cast(ubyte) length;
            stream_.put(take8from(temp));
        } else if (length < 65_536) {
            const temp = convertEndianTo!16(length);

            store_[0] = Format.RAW16;
            *cast(ushort*)&store_[offset] = temp;
            stream_.put(store_[0 .. offset + ushort.sizeof]);
        } else {
            if (length > 0xffffffff)
                throw new MessagePackException(text("size of raw is too long to pack: ", length,
                        " bytes should be <= ", 0xffffffff));

            const temp = convertEndianTo!32(length);

            store_[0] = Format.RAW32;
            *cast(uint*)&store_[offset] = temp;
            stream_.put(store_[0 .. offset + uint.sizeof]);
        }
    }

    /**
     * Serializes the type-information to stream.
     *
     * These methods don't serialize contents.
     * You need to call pack method to serialize contents at your own risk.
     * -----
     * packer.beginArray(3).pack(true, 1);  // -> [true, 1,
     *
     * // other operation
     *
     * packer.pack("Hi!");                  // -> [true, 1, "Hi!"]
     * -----
     *
     * Params:
     *  length = the length of container.
     *
     * Returns:
     *  self, i.e. for method chaining.
     */
    ref PackerImpl beginArray(in size_t length) return {
        if (length < 16) {
            const ubyte temp = Format.ARRAY | cast(ubyte) length;
            stream_.put(take8from(temp));
        } else if (length < 65_536) {
            const temp = convertEndianTo!16(length);

            store_[0] = Format.ARRAY16;
            *cast(ushort*)&store_[offset] = temp;
            stream_.put(store_[0 .. offset + ushort.sizeof]);
        } else {
            const temp = convertEndianTo!32(length);

            store_[0] = Format.ARRAY32;
            *cast(uint*)&store_[offset] = temp;
            stream_.put(store_[0 .. offset + uint.sizeof]);
        }

        return this;
    }

    /// ditto
    ref PackerImpl beginMap(in size_t length) return {
        if (length < 16) {
            const ubyte temp = Format.MAP | cast(ubyte) length;
            stream_.put(take8from(temp));
        } else if (length < 65_536) {
            const temp = convertEndianTo!16(length);

            store_[0] = Format.MAP16;
            *cast(ushort*)&store_[offset] = temp;
            stream_.put(store_[0 .. offset + ushort.sizeof]);
        } else {
            const temp = convertEndianTo!32(length);

            store_[0] = Format.MAP32;
            *cast(uint*)&store_[offset] = temp;
            stream_.put(store_[0 .. offset + uint.sizeof]);
        }

        return this;
    }

private:
    /*
     * Serializes the nil value.
     */
    ref PackerImpl packNil() return {
        stream_.put(Format.NIL);
        return this;
    }
}

/// Default serializer
alias Packer = PackerImpl!(Appender!(ubyte[])); // should be pure struct?

/**
 * Helper for $(D Packer) construction.
 *
 * Params:
 *  stream = the stream to write.
 *  withFieldName = serialize class / struct with field name
 *
 * Returns:
 *  a $(D Packer) object instantiated and initialized according to the arguments.
 */
PackerImpl!(Stream) packer(Stream)(Stream stream, bool withFieldName = false) {
    return typeof(return)(stream, withFieldName);
}

version (unittest) {
    import core.stdc.string;
    import std.file;

    package mixin template DefinePacker() {
        Packer packer;
    }

    package mixin template DefineDictionalPacker() {
        Packer packer = Packer(false);
    }
}
