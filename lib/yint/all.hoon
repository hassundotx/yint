::  The TinyMUD=MangledMUD code often mixes contexts where we have to output and cause
::  side effects as a single method in what's otherwise a pure function or a database only
::  mutating function. This is a catchall door which takes care of that.
/-  yint
/+  yint-db, yint-util, yint-speech
[. yint-util]
|_  a=all:yint
++  can-doit
  |=  [player=@sd thing=@sd default-fail-msg=tape]
  ^-  [? all:yint]
  =+  player-record=(~(got yint-db db.world.a) player)
  =+  loc=location:player-record
  =+  thing-record=(~(got yint-db db.world.a) thing)
  ?:  =(loc nothing:yint)
    [%.n a]
  =+  con-loc=contents:(~(got yint-db db.world.a) loc)
  ?.  (~(could-doit yint-db db.world.a) player thing)     :: can't do it
    =.  a
      ?.  =("" fail.thing-record)
        (queue fail.thing-record a)
      ?.  =("" default-fail-msg)
        (queue default-fail-msg a)
      a
    =.  a
      =+  ofail=ofail:thing-record
      ?:  =("" ofail)
        a
      =/  msg  :(weld name:player-record " " ofail)
      (~(notify-except yint-speech a) con-loc player msg)
    [%.n a]
  =.  a
    ?.  =("" succ.thing-record)
      (queue succ.thing-record a)
    a
  =.  a
    =+  osucc=osucc:thing-record
    ?:  =("" osucc)
      a
    =/  msg  :(weld name:player-record " " osucc)
    (~(notify-except yint-speech a) con-loc player msg)    
  [%.y a]


:: todo: continue here tomorrow.
::
++  reverse
  |=  list=@sd
  ^-  [@sd all:yint]
  =+  newlist=nothing:yint
  |-
  ?:  =(list nothing:yint)
    [newlist a]
  =+  rest=next:(~(got yint-db db.world.a) list)
  =.  a  (next-set list newlist)
  $(newlist list, list rest)


::  Helper for mutating db records concisely.
++  name-set
  |=  [what=@sd c=tape]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(name c))) io.a]
++  description-set
  |=  [what=@sd c=tape]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(description c))) io.a]
++  location-set
  |=  [what=@sd c=@sd]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(location c))) io.a]
++  contents-set
  |=  [what=@sd c=@sd]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(contents c))) io.a]
++  exits-set
  |=  [what=@sd c=@sd]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(exits c))) io.a]
++  next-set
  |=  [what=@sd c=@sd]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(next c))) io.a]
++  key-set
  |=  [what=@sd c=@sd]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(key c))) io.a]
++  fail-set
  |=  [what=@sd c=tape]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(fail c))) io.a]
++  success-set
  |=  [what=@sd c=tape]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(succ c))) io.a]
++  osuccess-set
  |=  [what=@sd c=tape]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(osucc c))) io.a]
++  ofail-set
  |=  [what=@sd c=tape]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(ofail c))) io.a]
++  owner-set
  |=  [what=@sd c=@sd]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(owner c))) io.a]
++  pennies-set
  |=  [what=@sd c=@sd]
  =+  old=(~(got yint-db db.world.a) what)
  [world.a(db (~(put yint-db db.world.a) what old(pennies c))) io.a]

++  flag-set
  |=  [what=@sd f=@u]
  =+  old=(~(got yint-db db.world.a) what)
  =+  new=(con flags:old f)
  [world.a(db (~(put yint-db db.world.a) what old(flags new))) io.a]

::  not a general &= ~ function. Only goes up to 0x100, which is what is used
::  in our bitfield.
++  flag-unset
  |=  [what=@sd f=@u]
  =+  old=(~(got yint-db db.world.a) what)
  =+  new=(dis flags:old (not 0 9 f))
  [world.a(db (~(put yint-db db.world.a) what old(flags new))) io.a]

--
