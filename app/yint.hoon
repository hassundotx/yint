::  Modern Gall shell for the revived Yint code.
::
::  The old application used pre-2020 Gall/Sole arms (`poke-sole-action`,
::  `peer`, `pull`, custom cards).  The command libraries now build, but the
::  terminal wiring needs a deliberate port to `agent:gall`.  This scaffold
::  keeps the desk buildable while leaving runtime behavior explicit.
::
/-  yint
/+  default-agent, yint-create, yint-db, yint-help, yint-look, yint-move, yint-set, yint-speech, yint-util
[. yint-util]
|%
+$  card  card:agent:gall
+$  yint-poke
  $%  [%yint-import arg=path]
      [%yint-export arg=knot]
      [%yint-load-phrases arg=path]
      [%yint-command player=@sd line=tape entropy=@u]
  ==
+$  state
  $:  world=world:yint
      last-io=(unit io:yint)
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
    [%x %last-io ~]  [~ ~ %noun !>(last-io.state)]
    [%x %status %json ~]  [~ ~ %json !>(`json`[%s 'ok'])]
    [%status %json ~]     [~ ~ %json !>(`json`[%s 'ok'])]
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
      %yint-command        (poke-yint-command player.cmd line.cmd entropy.cmd)
    ==
  ==
  ::
  ++  poke-yint-command
    |=  [player=@sd line=tape entropy=@u]
    ^-  [(list card) _this]
    =/  new-io=io:yint  [src.bowl [~ player] entropy ~ ~ ~]
    =/  a=all:yint  [world.state new-io]
    =.  a  (process-player-line line a)
    [~ this(state state(world world.a, last-io [~ io.a]))]
  ::
  ++  process-player-line
    |=  [line=tape a=all:yint]
    ^-  all:yint
    ?:  =(line "")
      (queue "huh? (empty)" a)
    =/  c=command:yint  (parse-command line)
    =/  cmd=tape  (cass command.c)
    ?:  =(cmd "look")
      (~(do-look-at yint-look a) arg1.c)
    ?:  =(cmd "read")
      (~(do-look-at yint-look a) arg1.c)
    ?:  =(cmd "help")
      (~(do-help yint-help a) (need player.io.a))
    ?:  =(cmd "examine")
      (~(do-examine yint-look a) (need player.io.a) arg1.c)
    ?:  =(cmd "inventory")
      (~(do-inventory yint-look a) (need player.io.a))
    ?:  =(cmd "score")
      (~(do-score yint-look a) (need player.io.a))
    ?:  ?|  =(cmd "move")  =(cmd "goto")
        ==
      (~(do-move yint-move a) (need player.io.a) arg1.c)
    ?:  ?|  =(cmd "get")  =(cmd "take")
        ==
      (~(do-get yint-move a) (need player.io.a) arg1.c)
    ?:  ?|  =(cmd "drop")  =(cmd "throw")
        ==
      (~(do-drop yint-move a) (need player.io.a) arg1.c)
    ?:  =(cmd "say")
      (~(do-say yint-speech a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@dig")
      (~(do-dig yint-create a) (need player.io.a) arg1.c)
    ?:  =(cmd "@open")
      (~(do-open yint-create a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@link")
      (~(do-link yint-create a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@create")
      (~(do-create yint-create a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@describe")
      (~(do-describe yint-set a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@name")
      (~(do-name yint-set a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@lock")
      (~(do-lock yint-set a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@unlock")
      (~(do-unlock yint-set a) (need player.io.a) arg1.c)
    ?:  =(cmd "@unlink")
      (~(do-unlink yint-set a) (need player.io.a) arg1.c)
    ?:  =(cmd "@chown")
      (~(do-chown yint-set a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@fail")
      (~(do-fail yint-set a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@success")
      (~(do-success yint-set a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@ofail")
      (~(do-ofail yint-set a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "@osuccess")
      (~(do-osuccess yint-set a) (need player.io.a) arg1.c arg2.c)
    ?:  =(cmd "quit")
      (do-quit a)
    (queue-phrase 'huh' a)
  ::
  ++  parse-command
    |=  line=tape
    ^-  command:yint
    =+  f=(find " " line)
    ?~  f
      [line "" ""]
    =+  lhs=(trim (need f) line)
    =+  command=p.lhs
    =+  rhs=(trim (add 1 (need f)) line)
    =+  equals=(find "=" q.rhs)
    ?~  equals
      [command q.rhs ""]
    =+  arg1=(trim (need equals) q.rhs)
    =+  arg2=(trim (add 1 (need equals)) q.rhs)
    [command p.arg1 q.arg2]
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
