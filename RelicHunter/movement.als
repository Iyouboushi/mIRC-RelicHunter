go {
  ; $1 = the person moving
  ; $2 = the direction

  ; Are you in battle? If so, you can't go anywhere.
  if ($in.battle($1) = true) {  $dcc.private.message($1, $readini(translation.dat, errors, CurrentlyInBattle)) | halt }

  ; Is it a valid exit?
  var %exit.location $readini($zone($get.zone($1)), $get.room($1), $2)
  if (%exit.location = $null) { $dcc.private.message($1, $readini(translation.dat, errors, NotValidExit)) | halt }

  ; Perform any exit actions
  .echo -q $readini($zone($get.zone($1)), p, $get.room($1), $2 $+ Action)

  ; Does the room exist to go into?
  var %valid.room $readini($zone($readini($char($1), location, zone)), %exit.location, name)
  if (%valid.room = $null) { $dcc.private.message($1, $readini(translation.dat, errors, RoomDoesNotExist)) | halt }

  ; ===Any flags that will prevent us from going there?===

  ; Check for under water and water breathing tech

  if ($readini($zone($get.zone($1)), %exit.location, UnderWater) = true) { 
    var %water.breathing.level $skill.check($1, WaterBreathing)

    if (%water.breathing.level >= 1) { var %canswim true }
    if (%water.breathing.level <= 0) { 
      ; check for the accessory
      if ($accessory.type($1) = waterbreathing) { var %canswim true }
    }

    if (%canswim != true) { $dcc.private.message($1, $readini(translation.dat, errors, Can'tSwim)) | halt } 
  }


  ; Check for warmth requirements
  if ($current.warmth($1) < $room.warmth.needed($1, %exit.location)) { $dcc.private.message($1, $readini(translation.dat, errors, TooColdToGoThere)) | halt }

  ; Show people that you've moved.
  $announce.room.action($1, departroom, $2)
  $show.room.move($1, $2)

  ; Move the char over.
  writeini $char($1) location room %exit.location

  ; Display the new room description.
  $room.look($1)

  ; Show people that you've arrived
  $announce.room.action($1, arriveroom)

}
