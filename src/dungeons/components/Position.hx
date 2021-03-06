package dungeons.components;

import dungeons.utils.Vector;
import ash.signals.Signal1;
import ash.signals.Signal2;

import dungeons.utils.Direction;

using dungeons.utils.Direction;

class Position
{
    public var x(default, null):Int;
    public var y(default, null):Int;
    public var moveRequested:Signal1<Direction>;
    public var changed(default, null):Signal2<Int, Int>;

    public function new(x:Int = 0, y:Int = 0)
    {
        this.x = x;
        this.y = y;
        changed = new Signal2<Int, Int>();
        moveRequested = new Signal1<Direction>();
    }

    public function moveTo(x:Int, y:Int):Void
    {
        if (this.x == x && this.y == y)
            return;

        var oldX:Int = this.x;
        var oldY:Int = this.y;

        this.x = x;
        this.y = y;

        changed.dispatch(oldX, oldY);
    }

    public inline function moveBy(dx:Int, dy:Int):Void
    {
        moveTo(x + dx, y + dy);
    }

    public function requestMove(direction:Direction):Void
    {
        moveRequested.dispatch(direction);
    }

    public function getAdjacentTile(direction:Direction):Vector
    {
        var offset:Vector = direction.offset();
        return {x: x + offset.x, y: y + offset.y};
    }
}


typedef PositionChangeListener = Int -> Int -> Void;
typedef MoveRequestListener = Direction -> Void;
