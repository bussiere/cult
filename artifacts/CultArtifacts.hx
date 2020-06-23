// cult artifacts storage
package artifacts;

class CultArtifacts
{
  var game: Game;
  var cult: Cult;
  var storage: Array<CultArtifact>;
  public var length(get, null): Int;

  public function new(g: Game, c: Cult)
    {
      game = g;
      cult = c;
      storage = [];
    }

// end turn
  public function turn()
    {
      // active book degrades awareness each turn
      if (hasUnique('book'))
        {
          var info = StaticArtifacts.uniqueArtifacts['book'];
          cult.awareness -= info.val;
        }
    }

// ritual points
  public function getRitualPoints(): Int
    {
      var pts = 0;
      for (a in storage)
        if (a.node != null)
          pts += a.level;
      return pts;
    }

// check if we can upgrade a priest
  public function canUpgrade(level: Int): Bool
    {
      if (level < 1)
        return true;

      for (a in storage)
        if (a.node == null)
          return true;
      return false;
    }

// upgrade a node
  public function onUpgrade(node: Node)
    {
      // pick an artifact - highest level first
      var art: CultArtifact = null;
      for (a in storage)
        if (a.node == null)
          {
            if (art == null || (art != null && a.level > art.level))
              art = a;
          }
      art.node = node;
      node.artifact = art;
      cult.logAndPanel(node.name + ' becomes a priest binding with ' + art.name + '.',
        { symbol: 'A' });
    }

// lose a node
  public function onLose(node: Node)
    {
      if (node.artifact == null)
        return;

      cult.logAndPanel(node.artifact.name + ' is lost with the priest.',
        { symbol: 'A' });
      storage.remove(node.artifact);
      node.artifact = null;
    }

// returns true if cult has this artifact activated
  public function hasUnique(id: String): Bool
    {
      for (a in storage)
        if (a.node != null && a.isUnique &&
            StaticArtifacts.uniqueArtifacts[a.id].id == id)
          return true;
      return false;
    }

  public function add(a: CultArtifact)
    {
      storage.push(a);
    }

  public function list()
    {
      return storage;
    }

  public function iterator()
    {
      return storage.iterator();
    }

  function get_length(): Int
    {
      return storage.length;
    }
}
