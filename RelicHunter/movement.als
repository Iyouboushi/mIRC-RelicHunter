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
  $show.room.move($nick, $2)

  ; Move the char over.
  writeini $char($1) location room %exit.location

  ; Display the new room description.
  $look.room($1)

  ; Show people that you've arrived
  $show.room.arrive($nick)

}

show.room.move {
  ; $1 = person moving
  ; $2 = direction person took

  var %user.location $get.zone.and.room($1)
  var %chat.move 1
  while ($chat(%chat.move) != $null) {  var %move.nick $chat(%chat.move) 
    if (%move.nick != $nick) {
      var %target.location $get.zone.and.room(%move.nick)
      if (%target.location = %user.location) { $dcc.private.message(%move.nick, $readini(translation.dat, system, movedtonewroom)) }
    }
    inc %chat.move 1
  } 
}

show.room.arrive {
  ; $1 = person moving

  var %user.location $get.zone.and.room($1)
  var %chat.arrive 1
  while ($chat(%chat.arrive) != $null) {  var %move.nick $chat(%chat.arrive) 
    if (%move.nick != $nick) {
      var %target.location $get.zone.and.room(%move.nick)
      if (%target.location = %user.location) { $dcc.private.message(%move.nick, $readini(translation.dat, system, ArrivedToRoom)) }
    }
    inc %chat.arrive 1
  } 
}
