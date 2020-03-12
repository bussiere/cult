// ui class for cult
// js version

import js.Browser;
import Alert;
import Static;

#if electron
import js.node.Fs;
#end


@:expose
class UI
{
  var game: Game;
  public var music: Music; // music player

  // ui blocks
  public var status: Status; // status block
  public var mainMenu: MainMenu; // main menu block
  public var loadMenu: LoadMenu; // load menu block
  public var saveMenu: SaveMenu; // save menu block
  public var customMenu: CustomMenu; // custom menu block
  public var mpMenu: MultiplayerMenu; // multiplayer menu block
  public var info: Info; // cult info block
  public var logWindow: Log; // log block
  public var alertWindow: Alert; // alert block
  public var debug: Debug; // debug menu block
  public var map: MapUI; // map block
  public var config: Config; // configuration
  public var logPanel: LogPanel; // log panel
  public var top: TopMenu; // top menu block
  public var sects: SectsInfo; // sects info block
  public var options: OptionsMenu; // options block
  public var manual: Manual; // ingame manual
  public var messageWindow: Message;


  public function new(g)
    {
      game = g;
      config = new Config();

      untyped  __js__("window.devicePixelRatio = 1;");

      Browser.window.onerror = onError;

      // pick mode
      var url = Browser.window.location.href;
      var isClassic = (StringTools.endsWith(url, 'index.html') ||
        StringTools.endsWith(url, 'app-classic.html'));
      classicMode = isClassic;
      modernMode = !isClassic;
      vars = (isClassic ? classicModeVars : modernModeVars);
    }


  function onError(msg: Dynamic, url: String, line: Int, col: Int, err: Dynamic): Bool
    {
      var d = Date.now();
      var l = d.getHours() + ':' +
        (d.getMinutes() < 10 ? '0' : '') + d.getMinutes() + ':' +
        (d.getSeconds() < 10 ? '0' : '') + d.getSeconds() + ' ' +
        msg + ', ' + err.stack + ', line ' + line + ', col ' + col + '\n';
      trace(l);
#if electron
      try {
        Fs.appendFileSync('log.txt', l);
      }
      catch (e: Dynamic)
        {}
#end
      return false;
    }


// init game screen
  public function init()
    {
      logWindow = new Log(this, game);
      logPanel = new LogPanel(this, game);
      alertWindow = new Alert(this, game);
      info = new Info(this, game);
      debug = new Debug(this, game);
      status = new Status(this, game);
      map = new MapUI(this, game);
      music = new Music(this);
      mainMenu = new MainMenu(this, game);
      loadMenu = new LoadMenu(this, game);
      saveMenu = new SaveMenu(this, game);
      customMenu = new CustomMenu(this, game);
      mpMenu = new MultiplayerMenu(this, game);
      top = new TopMenu(this, game);
      sects = new SectsInfo(this, game);
      options = new OptionsMenu(this, game);
      manual = new Manual(this, game);
      messageWindow = new Message(this, game);
      music.onRandom = status.onMusic;

      Browser.document.onkeyup = onKey;
      Browser.window.onresize = onResize;
      onResize(null); // once after game start
    }


// on resizing document
  function onResize(event: Dynamic)
    {
      map.resize();
      top.resize();
    }


// on key press
  function onKey(e: Dynamic)
    {
//      var key = (Browser.window.event) ? Browser.window.event.keyCode : event.keyCode;
      var key = e.keyCode;
//      trace(key);

      var windowOpen = ( loadMenu.isVisible || saveMenu.isVisible ||
        mainMenu.isVisible || debug.isVisible || alertWindow.isVisible ||
        logWindow.isVisible || info.isVisible || sects.isVisible ||
        customMenu.isVisible || manual.isVisible);

      if (loadMenu.isVisible) // load menu keys
        loadMenu.onKey(e);

      else if (saveMenu.isVisible) // save menu keys
        saveMenu.onKey(e);

      else if (mainMenu.isVisible) // main menu keys
        mainMenu.onKey(e);

      else if (customMenu.isVisible) // custom menu keys
        customMenu.onKey(e);

      else if (mpMenu.isVisible) // multiplayer menu keys
        mpMenu.onKey(e);

      else if (debug.isVisible) // debug menu keys
        debug.onKey(e);

      else if (sects.isVisible) // sects keys
        sects.onKey(e);

      // close current window
      else if (e.keyCode == 27 || // ESC
               e.keyCode == 13 || // Enter
               e.keyCode == 32) // Space
        {
          // Enter disabled in Sects info
          if (e.keyCode == 13 && sects.isVisible)
            return;

          if (alertWindow.isVisible)
            alertWindow.onClose(null);

          else if (logWindow.isVisible)
            logWindow.onClose(null);

          else if (info.isVisible)
            info.onClose(null);

          else if (sects.isVisible)
            sects.onClose(null);

          else if (options.isVisible)
            options.onClose(null);

          else if (manual.isVisible)
            manual.onClose(null);

          // open main menu
          else if (e.keyCode == 27)
            mainMenu.show();
        }

      // close yes/no dialog with yes
      else if (alertWindow.isVisible && alertWindow.isYesNo)
        {
          if (e.keyCode == 49) // 1
            alertWindow.onYes(null);
          else if (e.keyCode == 50) // 2
            alertWindow.onClose(null);
        }

      // close window
      else if (logWindow.isVisible && e.keyCode == 76) // L
        logWindow.onClose(null);

      else if (info.isVisible && e.keyCode == 67) // C
        info.onClose(null);

      else if (options.isVisible && e.keyCode == 79) // O
        options.onClose(null);

      else if (manual.isVisible && e.keyCode == 77) // M
        manual.onClose(null);

      else if (!windowOpen) // these work only without windows open
        {
          // advanced map mode
          if (e.keyCode == 65) // A
            top.onAdvanced(null);

          // cults
          else if (e.keyCode == 67) // C
            top.onCults(null);

          // debug
          else if (e.keyCode == 68) // D
            top.onDebug(null);

          // end turn
          else if (e.keyCode == 69) // E
            status.onEndTurn(null);

          // log
          else if (e.keyCode == 76) // L
            top.onLog(null);

          // manual
          else if (e.keyCode == 77) // M
            manual.show();

          // options
          else if (e.keyCode == 79) // O
            top.onOptions(null);

          // sects
          else if (e.keyCode == 83) // S
            top.onSects(null);

          // upgrade neophytes
          else if (e.keyCode == 49 && !game.isFinished) // 1
            game.player.upgrade(0);

          // upgrade adepts
          else if (e.keyCode == 50 && !game.isFinished) // 2
            game.player.upgrade(1);

          // summon
          else if (e.keyCode == 51 && !game.isFinished) // 3
            game.player.upgrade(2);
        }
    }


// clear map
  public function clearMap()
    {
      map.clear();
    }


// message box
  public inline function msg(s)
    {
      messageWindow.show(s);
    }


// update status block
  public function updateStatus()
    {
      status.update();
    }


// finish game window (ffin)
  public function finish(cult: Cult, state)
    {
      var msg = "<div style='text-size: 20px'><b>GAME OVER</b></div><br>";
      var w = 600;
      var h = 250;

      if (state == "summon" && !cult.isAI)
        {
          msg += "The stars were right. The Elder God was summoned in " +
            game.turns + " turns.";
          msg += "<br><br><center><b>YOU WIN</b></center>";
          track("winGame diff:" + game.difficultyLevel, "summon", game.turns);
          h = 210;
        }

      else if (state == "summon" && cult.isAI)
        {
          msg += cult.fullName +
            " has completed the " + Static.rituals['summoning'].name +
            ".<br><br>" + cult.info.summonFinish;
          msg += "<br><br><center><b>YOU LOSE</b></center>";
          track("loseGame diff:" + game.difficultyLevel, "summon", game.turns);
          w = 700;
          h = 470;
        }

      else if (state == "conquer" && !cult.isAI)
        {
          msg += cult.fullName + " has taken over the world in " +
            game.turns + " turns. The Elder Gods are pleased.";
          msg += "<br><br><center><b>YOU WIN</b></center>";
          track("winGame diff:" + game.difficultyLevel, "conquer", game.turns);
          h = 210;
        }

      else if (state == "conquer" && cult.isAI)
        {
          msg += cult.fullName + " has taken over the world. You fail.";
          msg += "<br><br><center><b>YOU LOSE</b></center>";
          track("loseGame diff:" + game.difficultyLevel, "conquer", game.turns);
          h = 210;
        }

      else if (state == "wiped")
        {
          msg += cult.fullName + " was wiped away completely. " +
            "The Elder God lies dormant beneath the sea, waiting.";
          msg += "<br><br><center><b>YOU LOSE</b></center>";
          track("loseGame diff:" + game.difficultyLevel, "wiped", game.turns);
          h = 210;
        }

      else if (state == "multiplayerFinish")
        {
          msg += "The great game has ended. Humanity will live.";
          msg += "<br><br><center><b>YOU ALL LOSE</b></center>";
          track("loseGame diff:" + game.difficultyLevel, "multiplayerFinish", game.turns);
          h = 190;
        }

      // open map fully
      for (n in game.nodes)
        {
          n.setVisible(game.player, true);
          n.isKnown[game.player.id] = true;
        }
      map.paint(); // final map repaint

      alert(msg, {
        w: w,
        h: h,
      });
    }


// show colored power name
  public static function powerName(i: Int, ?isShort: Bool = false)
    {
      return "<span class=shadow style='color:var(--power-color-" + i + ")'>" +
        (isShort ? Game.powerShortNames[i] : Game.powerNames[i]) + "</span>";
    }


// show colored cult name
  public static function cultName(i: Int, info: CultInfo)
    {
      return "<span class='cultText shadow' style='color:" + UI.vars.cultColors[i] + "'>" +
        info.name + "</span>";
    }


// message with confirmation
  public function alert(s, ?opts: _AlertOptions)
    {
      alertWindow.show(s, opts);
    }


// add message to logs of all player cults who know about this cult (more info)
  public function log2(cultOrigin: Cult, s: String, ?params: Dynamic)
    {
      // no messages about unknown cults
      for (c in game.cults)
        if (c.isDiscovered[cultOrigin.id] || cultOrigin.isDiscovered[c.id])
          {
            c.log(s);

            // skip sect messages is on
            if (params != null && params.type == 'sect' &&
                c.options.getBool('logPanelSkipSects'))
              continue;
            c.logPanel({
              id: -1,
              old: false,
              type: null,
              text: s,
              obj: cultOrigin,
              turn: game.turns + 1,
              params: params });
          }
    }


// clear log
  public function clearLog()
    {
      logWindow.clear();
      logPanel.clear();
    }


// get element shortcut
  public static inline function e(s)
    {
      return Browser.document.getElementById(s);
    }


// update tooltip for object
  public function updateTip(name: String, tip: String)
    {
      name = "#" + name;
      if (name.indexOf(".") > 0)
        {
          name = name.substr(0, name.indexOf(".")) + "\\" +
            name.substr(name.indexOf("."));
        }
      new JQuery(name).attr('tooltipText', tip);
    }


// get CSS variable
  public static inline function getVar(s: String): String
    {
      return Browser.window.getComputedStyle(
        Browser.document.documentElement).getPropertyValue(s);
    }


// get CSS variable as int
  public static inline function getVarInt(s: String): Int
    {
      return Std.parseInt(getVar(s));
    }


// track stuff through google analytics
  public inline function track(action: String, ?label: String, ?value: Int)
    {
      action = "cult " + action +  " " + Game.version;
      if (label == null)
        label = '';
      if (value == null)
        value = 0;
#if !electron
      untyped pageTracker._trackEvent('Evil Cult', action, label, value);
#end
    }



// =========================== ui vars ================================

  static var classicModeVars = {
    cultColors: [
      "#00B400",
      "#2F43FD",
      "#B400AE",
      "#B4AE00",
      "#0988ff",
      "#609612",
      "#a85700",
      "bb000b"
    ],
    lineColors: [
      "#55dd55",
      "#2727D7",
      "#E052CA",
      "#D8E151",
      "#0988ff",
      "#609612",
      "#a85700",
      "#990009"
    ],
    nodePixelColors: [
      [ 85, 221, 85 ],
      [ 39, 39, 215 ],
      [ 224, 82, 202 ],
      [ 216, 225, 81 ],
      [ 9, 136, 255 ],
      [ 96, 150, 18 ],
      [ 168, 87, 0 ],
      [ 153, 0, 9 ]
    ],
    nodeNeutralPixelColors: [ 120, 120, 120 ],
    markerWidth: 15,
    markerHeight: 15,
    scaleFactor: 1.0,
  };
  static var modernModeVars = {
    cultColors: [
      '#009933', // green
      '#FF3366', // pink
      '#009999', // cyan
      '#ff9900', // orange
      '#FF3300', // yellow
      '#3300CC', // blue
      '#660099', // violet
      '#330000', // red
      '#999999', // neutral
    ],
    lineColors: [ // same as cult
      '#009933', // green
      '#FF3366', // pink
      '#009999', // cyan
      '#ff9900', // orange
      '#FF3300', // yellow
      '#3300CC', // blue
      '#660099', // violet
      '#330000', // red
    ],
    nodePixelColors: [
      [ 0, 153, 51 ], // green
      [ 255, 51, 102 ], // pink
      [ 0, 153, 153 ], // cyan
      [ 255, 151, 0 ], // orange
      [ 255, 51, 0 ], // yellow
      [ 51, 60, 254 ], // blue
      [ 142, 0, 193 ], // violet
      [ 51, 0, 0 ] // red
    ],
    nodeNeutralPixelColors: [ 150, 150, 150 ],
    markerWidth: 60,
    markerHeight: 60,
    scaleFactor: 4.0, // sqrt(60 * 60 + 60 * 60) / sqrt(15 * 15 + 15 * 15)
  };
  public static var modernPowerImages = [
    'power-intimidation',
    'power-persuasion',
    'power-bribery',
  ];
  public static var modernGeneratorColors = [
    null, // green
    [ null, 'b0', 'd0' ], // pink
    null, // cyan
    [ null, 'a0', 'c0' ], // orange
    [ null, 'a0', 'c0' ], // yellow
    null, // blue
    null, // violet
    null, // red
    [ null, '70', 'c0' ], // neutral
  ];

  public static var modernMode = true; // modern mode flag
  public static var classicMode = false; // classic mode flag
  public static var vars = modernModeVars;

  public static var maxSaves:Int = 5; // max number of saves displayed
}
