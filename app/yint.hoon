::  Modern Gall shell for the revived Yint code.
::
::  The old application used pre-2020 Gall/Sole arms (`poke-sole-action`,
::  `peer`, `pull`, custom cards).  The command libraries now build, but the
::  terminal wiring needs a deliberate port to `agent:gall`.  This scaffold
::  keeps the desk buildable while leaving runtime behavior explicit.
::
/-  yint
/+  default-agent
|%
+$  card  card:agent:gall
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
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
::
++  on-poke
  |=  =cage
  ^-  [(list card) _this]
  ?+  p.cage  (on-poke:def cage)
    %yint-import
      ::  Import/export and Sole interaction are intentionally deferred until
      ::  the old app protocol is mapped onto modern Gall cards.
      [~ this]
    %yint-export
      [~ this]
    %yint-load-phrases
      [~ this]
    %sole-action
      [~ this]
  ==
--
