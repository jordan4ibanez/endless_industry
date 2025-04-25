module utility.linked_hash_queue;

public import utility.option;
import std.array;
import std.container.array;
import std.container.dlist;

struct LinkedHashQueue(T) {
protected:

    // These two are synchronized.
    bool[T] keys;
    DList!T queue;

public:

    /**
    Push element to the front of the queue. If it exists in the queue, this has no effect.
    */
    void pushFront(T element) {
        if (element in keys) {
            return;
        }
        keys[element] = true;
        queue.insertFront(element);
    }

    /**
    Push element to the back of the queue. If it exists in the queue, this has no effect.
    */
    void pushBack(T element) {
        if (element in keys) {
            return;
        }
        keys[element] = true;
        queue.insertBack(element);
    }

    /**
    Pop the front element off the front of the queue. If empty, it returns None.
    */
    Option!T popFront() {
        Option!T result;
        if (queue.empty()) {
            return result;
        }
        T gotten = queue.front();
        result = result.Some(gotten);
        queue.removeFront();
        keys.remove(gotten);
        return result;
    }

    /**
    Pop the back element off the back of the queue. If empty, it returns None.
    */
    Option!T popBack() {
        Option!T result;
        if (queue.empty()) {
            return result;
        }
        T gotten = queue.back();
        result = result.Some(gotten);
        queue.removeBack();
        keys.remove(gotten);
        return result;
    }
}

unittest {
    import std.stdio;

    LinkedHashQueue!int myCoolQueue;

    myCoolQueue.pushBack(1);
    myCoolQueue.pushBack(2);
    myCoolQueue.pushBack(3);
    myCoolQueue.pushBack(4);

    foreach (i; myCoolQueue.queue) {
        writeln(i);
    }

    writeln("====");

    Option!int testingThing = myCoolQueue.popFront();

    if (testingThing.isSome()) {
        writeln("some!");
    }

    myCoolQueue.pushBack(1);
    myCoolQueue.pushFront(5);

    foreach (i; myCoolQueue.queue) {
        writeln(i);
    }

    writeln("=====");

    myCoolQueue.popBack();
    myCoolQueue.popFront();

    foreach (i; myCoolQueue.queue) {
        writeln(i);
    }

    myCoolQueue.popFront();
    myCoolQueue.popFront();
    myCoolQueue.popFront();

    writeln("======");
    foreach (i; myCoolQueue.queue) {
        writeln(i);
    }

    assert(myCoolQueue.popBack().isNone());

    // FIFO

    myCoolQueue.pushBack(1);
    myCoolQueue.pushBack(2);
    myCoolQueue.pushBack(3);

    assert(myCoolQueue.popFront.unwrap == 1);
    assert(myCoolQueue.popFront.unwrap == 2);
    assert(myCoolQueue.popFront.unwrap == 3);

    // LILO

    myCoolQueue.pushFront(1);
    myCoolQueue.pushFront(2);
    myCoolQueue.pushFront(3);

    assert(myCoolQueue.popBack.unwrap == 1);
    assert(myCoolQueue.popBack.unwrap == 2);
    assert(myCoolQueue.popBack.unwrap == 3);

    // FILO/Stack

    myCoolQueue.pushBack(1);
    myCoolQueue.pushBack(2);
    myCoolQueue.pushBack(3);

    assert(myCoolQueue.popBack.unwrap == 3);
    assert(myCoolQueue.popBack.unwrap == 2);
    assert(myCoolQueue.popBack.unwrap == 1);

    // LIFO/Reverse Stack

    myCoolQueue.pushFront(1);
    myCoolQueue.pushFront(2);
    myCoolQueue.pushFront(3);

    assert(myCoolQueue.popFront.unwrap == 3);
    assert(myCoolQueue.popFront.unwrap == 2);
    assert(myCoolQueue.popFront.unwrap == 1);

    // I ran out of ideas for the unit test.

    myCoolQueue.pushFront(1);
    myCoolQueue.pushFront(2);
    myCoolQueue.pushFront(3);

    writeln(myCoolQueue.popBack());
    writeln(myCoolQueue.popFront());
    writeln(myCoolQueue.popBack());
    assert(myCoolQueue.popFront().isNone());
}
