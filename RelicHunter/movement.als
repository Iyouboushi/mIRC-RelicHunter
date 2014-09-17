go {
  ; $1 = the person moving
  ; $2 = the direction

  ; Is it a valid exit?
  var %exit.location $readini($zone($readini($char($1), location, zone)), $readini($char($1), location, room), $2)
  if (%exit.location = $null) { $dcc.private.message($1, $readini(translation.dat, errors, NotValidExit)) | halt }

  ; Does the room exist to go into?
  var %valid.room $readini($zone($readini($char($1), location, zone)), %exit.location, name)
  if (%valid.room = $null) { $dcc.private.message($1, 4The room this exit leads to does not exist yet, sorry!) | halt }

  ; ===Any flags that will prevent us from going there?===

  ; Check for under water and water breathing tech

  ; Check for warmth requirements

  ; Perform any exit actions
  .echo -q $readini($zone($readini($char($1), location, zone)), p, $readini($char($1), location, room), $2 $+ Action)

  ; Show people that you've moved.
  $announce.room.action($1, departroom, $2)
  $show.room.move($1, $2)

  ; Move the char over.
  writeini $char($1) location room %exit.location

  ; Display the new room description.
  $look.room($1)

  ; Show people that you've arrived
  $announce.room.action($1, arriveroom)

}

show.room.arrive {

}
