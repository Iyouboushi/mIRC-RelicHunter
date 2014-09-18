;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ROOM ALIASES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a flag from the
; room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.flag { 
  ; $1 = person who is in the room
  ; $2 = the flag you want to check

  var %room.flag $readini($zone($get.zone($1)), $get.room($1), $2)

  if (%room.flag = $null) { return false }
  else { return %room.flag }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns total # of rooms
; in a zone
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.roomtotal {
  ; $1 = the zone name

  var %room.count $readini($zone($1), info, numberofrooms)
  if (%room.count = $null) { return 0 }
  else { return %room.count }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the warmth
; needed to enter the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.warmth.needed { 
  ; $1 = person moving
  ; $2 = room that needs to be checked

  var %room.warmth $readini($zone($get.zone($1)), $2, WarmthNeeded)
  if (%room.warmth = $null) { return 0 }
  else { return %room.warmth }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the list of items that
; are in the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.look.items {
  var %room.item.list $readini($zone(%look.zone), %look.room, Items)
  var %value.item 1 | var %number.of.items $numtok(%room.item.list,46)

  while (%value.item <= %number.of.items) {
    var %item.name $gettok(%room.item.list, %value.item, 46)
    var %item.amount $readini($zone(%look.zone), %look.room,%item.name)

    if (%item.amount = $null) { var %item.amount 1 }

    ; add the item and the amount to the item list
    var %item_to_add %item.name $+ $chr(040) $+ %item.amount $+ $chr(041) 
    %look.items = $addtok(%look.items,%item_to_add,46)

    inc %value.item 1 
  }

  %look.items = $replace(%look.items, $chr(046), $chr(044) $chr(032)) 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Counts how many of each
; item is in the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.count.items.individual {
  var %room.total.item.count 0

  var %current.zone $get.zone($1) | var %current.room $get.room($1)
  var %room.item.list $readini($zone(%current.zone), %current.room,items)
  var %value.item 1 | var %number.of.items $numtok(%room.item.list,46)
  while (%value.item <= %number.of.items) {
    var %item.name $gettok(%room.item.list, %value.item, 46)
    var %item.amount $readini($zone(%current.zone), %current.room,%item.name)

    if (%item.amount = $null) { var %item.amount 1 }

    inc %room.total.item.count %item.amount
    inc %value.item 1 
  }

  return %room.total.item.count
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns how many different
; items are in the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.count.items {
  var %current.zone $get.zone($1) | var %current.room $get.room($1)
  var %room.item.list $readini($zone(%current.zone), %current.room,items)
  var %number.of.room.items $numtok(%room.item.list,46)
  if (%number.of.room.items = $null) { return 0 }
  return %number.of.room.items
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns how much of a
; specific item is in the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.item.amount {
  var %current.zone $get.zone($1) | var %current.room $get.room($1)
  var %item.amount $readini($zone(%current.zone), %current.room, $2)

  if (%item.amount < 0) { writeini $zone(%current.zone) %current.room $2 0 | return 0 }
  if (%item.amount = $null) { return 0 }
  return %item.amount
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adds an item to the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.add.item {
  var %current.zone $get.zone($1) | var %current.room $get.room($1)
  var %room.item.list $readini($zone(%current.zone), %current.room, items)

  %room.item.list = $addtok(%room.item.list, $2, 46)
  var %item.amount $room.item.amount($1, $2)

  if (%item.amount = $null) { var %item.amount 0 }
  inc %item.amount 1

  writeini $zone(%current.zone) %current.room $2 %item.amount
  writeini $zone(%current.zone) %current.room items %room.item.list

  unset %room.item.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Removes an item from the
; room.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.remove.item {
  var %current.zone $get.zone($1) | var %current.room $get.room($1)
  var %room.item.list $readini($zone(%current.zone), %current.room, items)

  var %item.amount $readini($zone(%current.zone), %current.room, $2)
  if (%item.amount = $null) { var %item.amount 1 }
  dec %item.amount 1
  writeini $zone(%current.zone) %current.room $2 %item.amount

  if (%item.amount <= 0) {  
    %room.item.list = $remtok(%room.item.list,$2,1,46) 
    if (%room.item.list = $null) { remini $zone(%current.zone) %current.room items }
    else {  writeini $zone(%current.zone) %current.room items %room.item.list }
  }

  unset %room.item.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Creates a room from the
; dig command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.create.dig {
  ; $1 = user creating the room
  ; $2 = direction to make the exit
  ; $3 = POS of the new room
  ; $4 = the z of the new room

  var %current.zone $get.zone($1) | var %current.room $get.room($1) 

  ; Create the exit in the previous room
  writeini $zone(%current.zone) %current.room $2 $3
  var %exit.list  $readini($zone(%current.zone), %current.room, ExitList)
  %exit.list = $addtok(%exit.list, $2, 46)
  writeini $zone(%current.zone) %current.room ExitList %exit.list
  unset %exit.list

  ; Create the room
  if ($4 >= -4) { 
    writeini $zone(%current.zone) $3 Name Dark Tunnel
    writeini $zone(%current.zone) $3 Desc A dark tunnel created by $get.name($1)
    writeini $zone(%current.zone) $3 zone tunnel
  }
  if ($4 <= -5) { 
    writeini $zone(%current.zone) $3 Name Dark Cavern
    writeini $zone(%current.zone) $3 Desc A dark cavern created by $get.name($1)
    writeini $zone(%current.zone) $3 zone cavern
  }

  ; Add flags
  writeini $zone(%current.zone) $3 shop false

  var %warmth.needed $abs($4)
  var %warmth.needed $round($calc(%warmth.needed * 2),0)
  writeini $zone(%current.zone) $3 warmthNeeded %warmth.needed
  writeini $zone(%current.zone) $3 underwater false
  writeini $zone(%current.zone) $3 inside true
  writeini $zone(%current.zone) $3 trees 0

  if ($4 <= -50) { writeini $zone(%current.zone) $3 CanDig false }
  else { writeini $zone(%current.zone) $3 CanDig true }

  ; Create the exit in the current room back to the previous room
  var %previous.exit up
  if ($2 = north) { var %previous.exit south }
  if ($2 = east) { var %previous.exit west }
  if ($2 = south) { var %previous.exit north }
  if ($2 = west) { var %previous.exit east }
  if ($2 = up) { var %previous.exit  down }
  if ($2 = down) { var %previous.exit up }

  var %exit.list  $readini($zone(%current.zone), $3 , ExitList)
  if (%exit.list != $null) { %exit.list = $addtok(%exit.list, %previous.exit, 46) }
  if (%exit.list = $null) { %exit.list = %previous.exit }
  writeini $zone(%current.zone) $3 ExitList %exit.list
  writeini $zone(%current.zone) $3 %previous.exit %current.room
  unset %exit.list

  ; Increase total # of rooms in the zone
  var %total.room.count $room.roomtotal(%current.zone)
  inc %total.room.count 1
  writeini $zone(%current.zone) info NumberOfRooms %total.room.count

  unset %room.to.make
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generates random ore
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.generateore {
  ; $1 = the zone name
  ; $2 = the room to spawn ore in
  ; $3 = the z position

  if ($3 >= -5) { 
    var %total.lines $lines($zoneores($1))
    if (%total.lines = 0) { return }
    if (%total.lines < 2) { var %total.lines 1 }
    if (%total.lines >= 2) { var %total.lines 2 }
    var %random.ore $rand(1,%total.lines)
    set %ore.name $read -l $+ %random.ore $zoneores($1)
  }

  if (($3 < -5) && ($3 > - 10)) { 
    var %total.lines $lines($zoneores($1))
    if (%total.lines = 0) { return }
    if (%total.lines <= 3) { var %total.lines %total.lines }
    if (%total.lines >= 4) { var %total.lines 4 }
    var %random.ore $rand(1,%total.lines)
    set %ore.name $read -l $+ %random.ore $zoneores($1)
  }

  if ($3 < -10) { 
    var %total.lines $lines($zoneores($1))
    if (%total.lines = 0) { return }
    if (%total.lines <= 4) { var %total.lines %total.lines }
    if (%total.lines >= 6) { var %total.lines 6 }
    var %random.ore $rand(1,%total.lines)
    set %ore.name $read -l $+ %random.ore $zoneores($1)
  }

  if (%ore.name != $null) { 
    var %room.item.list $readini($zone($1), $2, items)
    %room.item.list = $addtok(%room.item.list, %ore.name, 46)
    var %item.amount $rand(1,2)

    writeini $zone($1) $2 %ore.name %item.amount
    writeini $zone($1) $2 items %room.item.list
  }

  unset %room.item.list
  unset %ore.name

}
