namespace Vector;
using System;

/*     Type definitions     */

// Vector type
type Vector<T> ( private data : T?, readonly size : u64, private capacity : u64 );

/*     Constructors     */

// Empty constructor
fun Vector.Vector<T> ( )
{
    this.size = 0;
    this.capacity = 1;
    this.data = new T[1];
}

// Constructor with capacity
fun Vector.Vector<T> ( capacity : u64 )
{
    this.size = 0;
    this.capacity = capacity;
    this.data = new T[capacity];
}

// Vector destructor

fun Vector.~Vector ()
{
    destroy this.data;
}

/*     Methods     */

// Adds an item to the vector
fun Vector.Add : v ( data : T )
{
    this.size++;
    if ( this.size > this.capacity ) // maybe just call this.Reserve(this.capacity*2), albeit slightly slower
    {
        this.capacity *= 2;
        var newData : T? = new T[this.capacity];
        System.MemCopy( this.data, newData, ( this.capacity/2 ) * sizeof T ); // huh huh, do i need realloc? can i not just new and then memcpy, which i assume is what realloc does in the inside?
        destroy this.data;
        this.data = newData;
    }
    this.data[this.size-1] = data;
}

// Pops the last item from the vector
fun Vector.Pop : v ()
{
    if ( this.size == 0 ) { return; } // maybe throw an error
    this.size--;
}

// Removes an item from the vector
fun Vector.Remove : v ( index : i64 )
{
    if ( index < 0 || index >= this.size ) { return; } // maybe throw an error
    this.size--;
    for ( var i : i64 = index; i < this.size - 1; i++ )
    {
        // remember: MemCopy cannot copy on overlapping areas.
        this.data[index] = this.data[index+1];
    }
}

// Returns a reference to the item at the given index
fun Vector.[]op : T& ( index : i64 )
{
    if (index < -this.size || index >= this.size) { return this.data[0]; } // maybe throw an error
    return this.data[index < 0 ? this.size - index : index];
}

// Returns a reference to the last item
fun Vector.Back : v? ()
{
    return this.data[this.size-1];
}

// Reserves space for the vector
fun Vector.Reserve : v ( newCapacity : u64 )
{
    if ( newCapacity > this.size )
    {
        var newData : T? = new T[newCapacity];
        System.MemCopy( this.data, newData, this.capacity sizeof T );
        destroy this.data;
        this.data = newData;
        this.capacity = newCapacity;
    }
}

// Looks for an item in the vector and returns its index or -1 if not found
fun Vector.Find : i64 ( x : T )
{
    for ( var i : i64 = 0; i < this.size; i++ )
    {
        if ( this.data[i] == x ) return i;
    }
    return -1;
}

/*  Function-based methods, these are really cool   */

// Looks for the first item that matches the condition
fun Vector.First : i64 ( fun : u8(T) )
{
    for ( var i : i64 = 0; i < this.size; i++ )
    {
        if ( fun(this.data[i]) ) return i;
    }
    return -1;
}

// Runs the function on every item in the array.
fun Vector.ForEach : v ( fun : v(T&) )
{
    for ( var i : i64 = 0; i < this.size; i++ )
    {
        fun(this.data[i]);
    }
}

// Returns if any items in the vector match the condition
fun Vector.Any : u8 ( fun : u8(T) )
{
    for ( var i : i64 = 0; i < this.size; i++ )
    {
        if ( fun(this.data[i]) ) return 1;
    }
    return 0;
}


// Returns if all items in the vector match the condition
fun Vector.All : u8 ( fun : u8(T) )
{
    for ( var i : i64 = 0; i < this.size; i++ )
    {
        if ( !fun(this.data[i]) ) return 0;
    }
    return 1;
}

// Returns how many items in the vector match the condition
fun Vector.Count : u64 ( fun : u8(T) )
{
    var count : u64 = 0;
    for ( var i : i64 = 0; i < this.size; i++ )
    {
        if ( fun(this.data[i]) ) count++;
    }
    return count;
}