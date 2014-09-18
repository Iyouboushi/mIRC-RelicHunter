go {
  ; $1 = the person moving
  ; $2 = the direction

  ; Are you in battle? If so, you can't go anywhere.
  if ($in.battle($1) = true) {  $dcc.private.message($1, $readini(translation.dat, errors, CurrentlyInBattle)) | halt }

  ; Is it a valid exit?
  var %exit.location $readini($zone($readini($char($1), location, zone)), $readini($char($1), location, room), $2)
  if (%exit.location = $null) { $dcc.private.message($1, $readini(translation.dat, errors, NotValidExit)) | halt }

  ; Does the room exist to go into?
  var %valid.room $readini($zone($readini($char($1), location, zone)), %exit.location, name)
  if (%valid.room = $null) { $dcc.private.message($1, $readini(translation.dat, errors, RoomDoesNotExist)) | halt }

  ; ===Any flags that will prevent us from going there?===

  ; Check for under water and water breathing tech

  ; Check for warmth requirements
  if ($current.warmth($1) < $room.warmth.needed($1, %exit.location)) { $dcc.private.message($1, $readini(translation.dat, errors, TooColdToGoThere)) | halt }

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
