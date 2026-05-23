::  Modern Gall shell for the revived Yint code.
::
::  The old application used pre-2020 Gall/Sole arms (`poke-sole-action`,
::  `peer`, `pull`, custom cards).  The command libraries now build, but the
::  terminal wiring needs a deliberate port to `agent:gall`.  This scaffold
::  keeps the desk buildable while leaving runtime behavior explicit.
::
/-  yint
/+  default-agent, yint-db
|%
+$  card  card:agent:gall
+$  yint-poke
  $%  [%yint-import arg=path]
      [%yint-export arg=knot]
      [%yint-load-phrases arg=path]
  ==
+$  state
  $:  world=world:yint
  ==
--
^-  agent:gall
=|  =state
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init   on-init:def
++  on-save   on-save:def
++  on-load   on-load:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  [~ ~]
    [%x %world ~]    [~ ~ %noun !>(world.state)]
    [%x %db ~]       [~ ~ %noun !>(db.world.state)]
    [%x %phrases ~]  [~ ~ %noun !>(phrases.world.state)]
    [%x %dump ~]     [~ ~ %noun !>(~(serialize yint-db db.world.state))]
  ==
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
::
++  on-poke
  |=  =cage
  ^-  [(list card) _this]
  |^
  ?+    p.cage  (on-poke:def cage)
      %noun
    =/  cmd=yint-poke  !<(yint-poke q.cage)
    ?-  -.cmd
      %yint-import         (poke-yint-import arg.cmd)
      %yint-export         (poke-yint-export arg.cmd)
      %yint-load-phrases   (poke-yint-load-phrases arg.cmd)
    ==
  ==
  ::
  ++  poke-yint-load-phrases
    |=  arg=path
    ^-  [(list card) _this]
    =/  j=json  .^(json %cx arg)
    =,  dejs-soft:format
    =+  parsed=(need ((om sa) j))
    ~&  [%loaded-phrases]
    [~ this(state state(world world.state(phrases parsed)))]
  ::
  ++  poke-yint-import
    |=  arg=path
    ^-  [(list card) _this]
    =/  lines=wain  .^(wain %cx arg)
    =+  mydb=(~(restore yint-db db.world.state) lines)
    ?~  mydb
      ~&  [%failed-to-load]
      [~ this]
    ~&  [%reboot-world]
    =/  new-world=world:yint
      %=  world.state
        db         (need mydb)
        logged-in  (~(run by logged-in.world.state) |=(* ~))
        player-out  ~
      ==
    [~ this(state state(world new-world))]
  ::
  ++  poke-yint-export
    |=  arg=knot
    ^-  [(list card) _this]
    ~&  [%export-deferred arg]
    [~ this]
  --
--
