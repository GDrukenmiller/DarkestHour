//==============================================================================
// Darklight Games (c) 2008-2019
//==============================================================================

class UHeap extends Object;

struct DataPoint
{
    var Object Item;
    var float  Priority;
    var int Tag; // can be used for mapping the data to something
};

var array<DataPoint> Data;
var bool             bMinHeap; // the heap is max by default

final function Clear() { Data.Length = 0; }
final function int GetLength() { return Data.Length; }

// Clear any nested heaps
final function ClearNested()
{
    local UHeap H;
    local int i;

    for (i = 0; i < Data.Length; ++i)
    {
        if (Data[i].Item.IsA('UHeap'))
        {
            H = UHeap(Data[i].Item);

            if (H == none)
            {
                Warn("Fatal error");
                continue;
            }

            H.ClearNested();
        }
    }

    Data.Length = 0;
}

final function Insert(Object Item, float Priority, optional int Tag)
{
    local DataPoint P;

    P.Item = Item;
    P.Priority = Priority;
    P.Tag = Tag;

    Data[Data.Length] = P;
    SiftUp(Data.Length - 1);
}

// Remove the root
final function Remove()
{
    local int EndIndex;

    if (Data.Length < 1)
    {
        return;
    }

    EndIndex = Data.Length - 1;

    if (EndIndex > 1)
    {
        Swap(0, EndIndex);
        SiftDown(0, EndIndex - 1);
    }

    Data.Remove(EndIndex, 1);
}

// Extract the root of the heap, removing it in the process
final function Object Pop()
{
    local Object O;

    if (Data.Length > 0)
    {
        Remove();
        O = Data[0].Item;
        return O;
    }
}

// Get the root item
final function Object Peek()
{
    if (Data.Length > 0)
    {
        return Data[0].Item;
    }
}

// Returns an array with all the items. Nulls are ignored.
final function array<Object> ToObjects()
{
    local array<Object> Result;
    local int i;

    for (i = 0; i < Data.Length; ++i)
    {
        if (Data[i].Item != none)
        {
            Result[Result.Length] = Data[i].Item;
        }
    }

    return Result;
}

final function array<Actor> ToActors()
{
    local array<Actor> Result;
    local Object O;
    local int i;

    for (i = 0; i < Data.Length; ++i)
    {
        O = Data[i].Item;

        if (O != none && O.IsA('Actor'))
        {
            Result[Result.Length] = Actor(O);
        }
    }

    return Result;
}

// Converts the root item into an array. If the root item is a heap, this function
// will return all of it's elements. Null items are ignored.
final function array<Object> RootToObjects()
{
    local array<Object> Result;
    local UHeap RootHeap;
    local Object O;

    if (Data.Length > 0)
    {
        if (RootIsHeap(RootHeap))
        {
            return RootHeap.ToObjects();
        }

        if (Data[0].Item != none)
        {
            Result[Result.Length] = Data[0].Item;
        }
    }
}

final function array<Actor> RootToActors()
{
    local array<Actor> A;
    local UHeap RootHeap;

    if (Data.Length > 0)
    {
        if (RootIsHeap(RootHeap))
        {
            return RootHeap.ToActors();
        }

        if (Data[0].Item.IsA('Actor'))
        {
            A[A.Length] = Actor(Data[0].Item);
        }
    }

    return A;
}

final function bool RootIsHeap(optional out UHeap Heap)
{
    if (Data.Length > 0)
    {
        if (Data[0].Item.IsA('UHeap'))
        {
            Heap = UHeap(Data[0].Item);
            return Heap != none;
        }
    }
}

final function Heapify()
{
    local int i;

    for (i = int(Data.Length * 0.5); i >= 0; --i)
    {
        SiftDown(i, Data.Length - 1);
    }
}

final function array<DataPoint> GetSorted()
{
    local int EndIndex;

    if (Data.Length < 2)
    {
        return self.Data;
    }

    EndIndex = Data.Length - 1;

    while (EndIndex > 0)
    {
        Swap(0, EndIndex);
        --EndIndex;
        SiftDown(0, EndIndex);
    }

    return self.Data;
}

final function SiftUp(int StartIndex)
{
    local int i, ParentIndex;

    if (StartIndex >= Data.Length)
    {
        Warn("Index overflow");
        return;
    }

    i = StartIndex;

    while (i > 0)
    {
        ParentIndex = GetParentIndex(i);

        if (ShouldSwap(i, ParentIndex))
        {
            Swap(i, ParentIndex);
            i = ParentIndex;
            continue;
        }

        break;
    }
}

final function SiftDown(int StartIndex, int EndIndex)
{
    local int RootIndex, ChildIndex, SwapIndex, RightChildIndex;

    if (StartIndex < 0 || EndIndex >= Data.Length)
    {
        Warn("Index overflow");
        return;
    }

    RootIndex = StartIndex;

    while (GetLeftChildIndex(RootIndex) <= EndIndex)
    {
        ChildIndex = GetLeftChildIndex(RootIndex);
        SwapIndex = RootIndex;

        if (ShouldSwap(ChildIndex, SwapIndex))
        {
            SwapIndex = ChildIndex;
        }

        RightChildIndex = ChildIndex + 1;

        if (RightChildIndex <= EndIndex && ShouldSwap(RightChildIndex, SwapIndex))
        {
            SwapIndex = RightChildIndex;
        }

        if (SwapIndex != RootIndex)
        {
            Swap(RootIndex, SwapIndex);
            RootIndex = SwapIndex;
            continue;
        }

        break;
    }
}

protected function bool ShouldSwap(int A, int B)
{
    if (bMinHeap)
    {
        return Data[A].Priority < Data[B].Priority;
    }

    return Data[A].Priority > Data[B].Priority;
}

protected final function Swap(int A, int B)
{
    local DataPoint T;

    T = Data[A];
    Data[A] = Data[B];
    Data[B] = T;
}

static final function Heapsort(out array<DataPoint> Data, optional bool bDescending)
{
    local UHeap Heap;
    local int i;

    Heap = new class'UHeap';
    Heap.bMinHeap = bDescending;

    for (i = 0; i < Data.Length; ++i)
    {
        Heap.Data[Heap.Data.Length] = Data[i];
    }

    Heap.Heapify();
    Data = Heap.GetSorted();
    Heap.Clear();
}

static final function OHeapsort(out array<Object> Data, Functor_float_Object PriorityFunction, optional bool bDescending)
{
    local UHeap Heap;
    local DataPoint P;
    local array<DataPoint> Sorted;
    local int i;

    Heap = new class'UHeap';
    Heap.bMinHeap = bDescending;

    for (i = 0; i < Data.Length; ++i)
    {
        P.Item = Data[i];
        P.Priority = PriorityFunction.DelegateFunction(Data[i]);

        Heap.Data[Heap.Data.Length] = P;
    }

    Heap.Heapify();
    Sorted = Heap.GetSorted();
    Heap.Clear();
    Data.Length = 0;

    for (i = 0; i < Sorted.Length; ++i)
    {
        Data[Data.Length] = Sorted[i].Item;
    }
}

static final function Object OSortAndPeek(array<Object> Data, Functor_float_Object PriorityFunction, optional bool bDescending)
{
    local UHeap Heap;
    local DataPoint P;
    local Object O;
    local int i;

    Heap = new class'UHeap';
    Heap.bMinHeap = bDescending;

    for (i = 0; i < Data.Length; ++i)
    {
        P.Item = Data[i];
        P.Priority = PriorityFunction.DelegateFunction(Data[i]);

        Heap.Data[Heap.Data.Length] = P;
    }

    Heap.Heapify();
    O = Heap.Peek();
    Heap.Clear();

    return O;
}

static final function int GetLeftChildIndex(int Index) { return 2 * Index + 1; }
static final function int GetRightChildIndex(int Index) { return 2 * Index + 2; }
static final function int GetParentIndex(int Index) { return (Index - 1) >> 1; }

// DEBUG

function DebugLog(optional int IndentLevel)
{
    local string Indent;
    local UHeap Heap;
    local int i;

    for (i = 0; i < IndentLevel; ++i)
    {
        Indent $= "|  ";
    }

    Log(Indent $ "HEAP CONTENTS:");

    for (i = 0; i < Data.Length; ++i)
    {
        Log(Indent $ i $ ":" @ string(Data[i].Item.Class) @ ">" @ string(Data[i].Priority));

        if (Data[i].Item.IsA('UHeap'))
        {
            Heap = UHeap(Data[i].Item);

            if (Heap != none)
            {
                Heap.DebugLog(IndentLevel + 1);
            }
            else
            {
                Warn("Cast fail");
            }
        }
    }
}

function DebugSortedLog(optional int IndentLevel)
{
    local string Indent;
    local UHeap Heap;
    local array<DataPoint> Sorted;
    local int i;

    for (i = 0; i < IndentLevel; ++i)
    {
        Indent $= "|  ";
    }

    Log(Indent $ "HEAP CONTENTS (SORTED):");

    Sorted = GetSorted();

    for (i = 0; i < Sorted.Length; ++i)
    {
        Log(Indent $ i $ ":" @ string(Sorted[i].Item.Class) @ ">" @ string(Sorted[i].Priority));

        if (Sorted[i].Item.IsA('UHeap'))
        {
            Heap = UHeap(Data[i].Item);

            if (Heap != none)
            {
                Heap.DebugSortedLog(IndentLevel + 1);
            }
            else
            {
                Warn("Cast fail");
            }
        }
    }
}
