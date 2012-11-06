package dungeons.systems;

import nme.ObjectHash;

import net.richardlord.ash.core.Entity;
import net.richardlord.ash.core.Game;
import net.richardlord.ash.tools.ListIteratingSystem;

import dungeons.components.Position;
import dungeons.nodes.ObstacleNode;
import dungeons.PositionMap.PositionArrayMap;

class ObstacleSystem extends ListIteratingSystem<ObstacleNode>
{
    private var obstacleMap:PositionArrayMap<ObstacleNode>;
    private var listeners:ObjectHash<ObstacleNode, PositionChangeListener>;

    public function new(width:Int, height:Int)
    {
        obstacleMap = new PositionArrayMap(width, height);
        super(ObstacleNode, null, addNode, removeNode);
    }

    override public function addToGame(game:Game):Void
    {
        listeners = new ObjectHash();
        super.addToGame(game);
    }

    override public function removeFromGame(game:Game):Void
    {
        super.removeFromGame(game);
        for (node in listeners.keys())
            node.position.changed.remove(listeners.get(node));
        listeners = null;
        obstacleMap.clear();
    }

    public function isBlocked(x:Int, y:Int):Bool
    {
        var array:Array<ObstacleNode> = obstacleMap.get(x, y);
        return array != null && array.length > 0;
    }

    public function getBlocker(x:Int, y:Int):Entity
    {
        var array:Array<ObstacleNode> = obstacleMap.get(x, y);
        if (array != null && array.length > 0)
            return array[0].entity;
        else
            return null;
    }

    private function addObstacle(node:ObstacleNode):Void
    {
        obstacleMap.getOrCreate(node.position.x, node.position.y).push(node);
    }

    private function removeObstacle(node:ObstacleNode, x:Int, y:Int):Void
    {
        obstacleMap.get(x, y).remove(node);
    }

    private function addNode(node:ObstacleNode):Void
    {
        addObstacle(node);
        var listener = callback(onNodePositionChanged, node);
        node.position.changed.add(listener);
        listeners.set(node, listener);
    }

    private function onNodePositionChanged(node:ObstacleNode, oldX:Int, oldY:Int):Void
    {
        removeObstacle(node, oldX, oldY);
        addObstacle(node);
    }

    private function removeNode(node:ObstacleNode):Void
    {
        var listener = listeners.get(node);
        listeners.remove(node);
        node.position.changed.remove(listener);
        removeObstacle(node, node.position.x, node.position.y);
    }
}
