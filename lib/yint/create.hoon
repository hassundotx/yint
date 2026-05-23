::
:: This door corresponds to create.rb.
::
/-  yint
/+  yint-all, yint-db, yint-match, yint-util
[[. yint-util] match=yint-match]
|_  a=all:yint

++  parse-linkable-room
  |=  [player=@sd room-name=tape]
  ^-  [@sd all:yint]
  ?:  =((cass room-name) "home")
    [home:yint a]
  =/  room
    ?:  =((cass room-name) "here")
      location:(~(got yint-db db.world.a) player)
    (parse-dbref room-name)
  ~&  [%checking-room room]
  ?:  =(room nothing:yint)
    [nothing:yint (queue-phrase 'not-a-room' a)]
  ?.  (~(is-room yint-db db.world.a) room)
    [nothing:yint (queue-phrase 'not-a-room' a)]
  ?.  (~(can-link-to yint-db db.world.a) player room)
    [nothing:yint (queue-phrase 'bad-link' a)]
  [room a]

::  Opens an exit belonging to the player in the specified direction.
++  do-open
  |=  [player=@sd direction=tape linkto=tape]
  ^-  all:yint
  =+  loc=location:(~(got yint-db db.world.a) player)
  ?:  =(loc nothing:yint)
    a
  ?~  direction
    (queue-phrase 'no-permission' a)
  =/  new-db=database:yint  db.world.a
  =^  can-pay  new-db  (~(payfor yint-db new-db) player exit-cost:yint)
  =.  a  [world.a(db new-db) io.a]
  ?.  can-pay
    (queue-phrase 'sorry-poor-open' a)
  =/  new-db=database:yint  db.world.a
  =^  index  new-db  ~(add-new-record yint-db new-db)
  =.  a  [world.a(db new-db) io.a]
  =+  loc-exits=exits:(~(got yint-db db.world.a) loc)
  =/  r  %-  record:yint  :*
    direction           :: name
    ""                  :: description
    nothing:yint        :: location
    nothing:yint        :: contents
    nothing:yint        :: exits
    loc-exits           :: next
    nothing:yint        :: key
    ""                  :: fail
    ""                  :: succ
    ""                  :: ofail
    ""                  :: osucc
    player              :: owner
    --0                 :: pennies
    type-exit:yint      :: type
    ""                  :: password
  ==
  =/  new-db=database:yint  (~(put yint-db db.world.a) index r)
  =.  a  [world.a(db new-db) io.a]
  =.  a  (~(exits-set yint-all a) loc index)
  =.  a  (queue-phrase 'opened' a)
  ?~  linkto
    a
  =.  a  (queue-phrase 'trying-to-link' a)
  =^  loc  a  (parse-linkable-room player linkto)
  ?:  =(loc nothing:yint)
    a
  =/  new-db=database:yint  db.world.a
  =^  can-pay  new-db  (~(payfor yint-db new-db) player link-cost:yint)
  =.  a  [world.a(db new-db) io.a]
  ?.  can-pay
    (queue-phrase 'too-poor-to-link' a)
  =.  a  (~(location-set yint-all a) index loc)
  (queue-phrase 'linked' a)

::
++  do-link
  |=  [player=@sd name=tape room-name=tape]
  ^-  all:yint
  =+  loc=location:(~(got yint-db db.world.a) player)
  ?:  =(nothing:yint loc)
    a
  =^  room  a  (parse-linkable-room player room-name)
  ?:  =(nothing:yint room)
    a
  =+  matcher=(init:yint-match a player name type-exit:yint)
  =.  matcher  ~(match-everything yint-match matcher)
  =^  thing  a  ~(noisy-match-result yint-match matcher)
  ?:  =(thing nothing:yint)
    a
  =+  type=(~(typeof yint-db db.world.a) thing)
  ?:  =(type type-exit:yint)
    ?.  =(location:(~(got yint-db db.world.a) thing) nothing:yint)
      ::  all error cases
      ?:  (~(controls yint-db db.world.a) player thing)
        ?:  (~(is-player yint-db db.world.a) location:(~(got yint-db db.world.a) thing))
          (queue-phrase 'exit-being-carried' a)
        (queue-phrase 'exit-already-linked' a)
      (queue-phrase 'no-permission' a)
    ?:  =(player owner:(~(got yint-db db.world.a) thing))
      =/  new-db=database:yint  db.world.a
      =^  can-pay  new-db  (~(payfor yint-db new-db) player link-cost:yint)
      =.  a  [world.a(db new-db) io.a]
      ?.  can-pay
        (queue-phrase 'too-poor-to-link' a)
      (complete-do-link-exit player thing room)
    =/  new-db=database:yint  db.world.a
    =^  can-pay  new-db  (~(payfor yint-db new-db) player (add link-cost:yint exit-cost:yint))
    =.  a  [world.a(db new-db) io.a]
    ?.  can-pay
      (queue-phrase 'cost-two-exit' a)
    =+  o=owner:(~(got yint-db db.world.a) thing)
    =+  old-p=pennies:(~(got yint-db db.world.a) o)
    =.  a  (~(pennies-set yint-all a) o (add old-p exit-cost:yint))
    (complete-do-link-exit player thing room)

  ?:  =(type type-thing:yint)
    (complete-do-link-thing player thing room)

  ?:  =(type type-player:yint)
    (complete-do-link-thing player thing room)

  ?:  =(type type-room:yint)
    ?.  (~(controls yint-db db.world.a) player thing)
      (queue-phrase 'no-permission' a)
    =.  a  (~(location-set yint-all a) thing room)
    (queue-phrase 'drop-to-set' a)
  a

::  (Helper detail of do-link.)
++  complete-do-link-exit
  |=  [player=@sd thing=@sd room=@sd]
  ^-  all:yint
  =.  a  (~(owner-set yint-all a) thing player)
  =.  a  (~(location-set yint-all a) thing room)
  (queue-phrase 'linked' a)

::  (Helper detail of do-link.)
++  complete-do-link-thing
  |=  [player=@sd thing=@sd room=@sd]
  ^-  all:yint
  ?.  (~(controls yint-db db.world.a) player thing)
    (queue-phrase 'no-permission' a)
  ?:  =(room home:yint)
    (queue-phrase 'no-set-home' a)
  =.  a  (~(exits-set yint-all a) thing room)
  (queue-phrase 'home-set' a)

::  Creates an object with a particular name under the ownership of a player.
++  do-create
  |=  [player=@sd name=tape in-cost=tape]
  ?:  =(name "")
    (queue-phrase 'create-what' a)
  ?.  (~(ok-name yint-db db.world.a) name)
    (queue-phrase 'silly-thing-name' a)
  =+  parsed-cost=(rust in-cost dim:ag)
  ?~  parsed-cost
    (queue-phrase 'objects-must-have-a-value' a)
  =/  cost=@ud
    ?:  (lth (need parsed-cost) object-cost:yint)
      object-cost:yint
    (need parsed-cost)
  =/  new-db=database:yint  db.world.a
  =^  can-pay  new-db  (~(payfor yint-db new-db) player cost)
  =.  a  [world.a(db new-db) io.a]
  ?.  can-pay
    (queue-phrase 'sorry-poor' a)
  =/  new-db=database:yint  db.world.a
  =^  index  new-db  ~(add-new-record yint-db new-db)
  =.  a  [world.a(db new-db) io.a]
  =+  player-r=(~(got yint-db db.world.a) player)
  =/  pennies=@sd
    =+  base=(endow cost)
    ?:  (gth base max-object-endowment:yint)
      (sun:si max-object-endowment:yint)
    (sun:si base)
  =/  exits=@sd
    ?:  ?&  !=(location:player-r nothing:yint)
            (~(can-link-to yint-db db.world.a) player location:player-r)
        ==
      location:player-r
    exits:player-r
  =/  r  %-  record:yint  :*
    name                :: name
    ""                  :: description
    player              :: location
    nothing:yint        :: contents
    exits               :: exits
    contents:player-r   :: next
    nothing:yint        :: key
    ""                  :: fail
    ""                  :: succ
    ""                  :: ofail
    ""                  :: osucc
    player              :: owner
    pennies             :: pennies
    type-thing:yint     :: type
    ""                  :: password
  ==
  ::  todo: if I could reliably set some of those default values to NOTHING, I could
  ::  use the following and cut down duplicates.
  :: =.  r  %=  r
  ::   name      name
  ::   location  player
  ::   contents  nothing:yint
  ::   exits     exits
  ::   next      contents:player-r
  ::   key       nothing:yint
  ::   owner     player
  ::   pennies   pennies
  ::   flags     type-thing:yint
  :: ==
  =/  new-db=database:yint  (~(put yint-db db.world.a) index r)
  =.  a  [world.a(db new-db) io.a]
  =.  a  (~(contents-set yint-all a) player index)
  (queue-phrase 'created' a)

::  Endow is a helper function to calculate the autmatic endowment for an object.
++  endow
  |=  cost=@ud
  ^-  @ud
  %+  div
    (sub cost endowment-calculator:yint)
    endowment-calculator:yint

::  Digs into an area, creating a new room. Notifies the player of outcome.
++  do-dig
  |=  [player=@sd name=tape]
  ^-  all:yint
  ?:  =(name "")
    (queue-phrase 'dig-what' a)
  ?.  (~(ok-name yint-db db.world.a) name)
    (queue-phrase 'silly-room-name' a)
  =/  new-db=database:yint  db.world.a
  =^  can-pay  new-db  (~(payfor yint-db new-db) player room-cost:yint)
  =.  a  [world.a(db new-db) io.a]
  ?.  can-pay
    (queue-phrase 'sorry-poor-dig' a)
  =/  new-db=database:yint  db.world.a
  =^  index  new-db  ~(add-new-record yint-db new-db)
  =.  a  [world.a(db new-db) io.a]
  =/  r  %-  record:yint  :*
    name                :: name
    ""                  :: description
    nothing:yint        :: location
    nothing:yint        :: contents
    nothing:yint        :: exits
    nothing:yint        :: next
    nothing:yint        :: key
    ""                  :: fail
    ""                  :: succ
    ""                  :: ofail
    ""                  :: osucc
    player              :: owner
    --0                 :: pennies
    type-room:yint      :: type
    ""                  :: password
  ==
  =/  new-db=database:yint  (~(put yint-db db.world.a) index r)
  =.  a  [world.a(db new-db) io.a]
  (queue-phrase-with 'created-room' [name (print-ref index) ~] a)
--
