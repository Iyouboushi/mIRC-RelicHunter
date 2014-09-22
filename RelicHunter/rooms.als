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
; Returns total # of trees
; in a room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.treestotal {
  ; $1 = the zone name
  ; $2 = the room name

  var %tree.count $readini($zone($1), $2, trees)
  if (%tree.count = $null) { return 0 }
  else { return %tree.count }
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
; Looks at a room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.look {
  ; $1 = user

  ; Are you in battle? If so, you can't look at the room.
  if ($in.battle($1) = true) {  $battle.look($1) | halt }

  ; get zone
  set %look.zone $get.zone($1)

  ; get room
  set %room.look $get.room($1)

  ; Get zone + room
  var %look.zone.and.room $get.zone.and.room($1)

  ; build the room desc and show it
  msg =$nick 12[ $+ $readini($zone(%look.zone), %room.look, name) $+  ]  $iif($player.settings.flag($1, ShowPOS) = true, 15[ $+ %look.zone.and.room $+ ] )
  msg =$nick 3 $+ $readini($zone(%look.zone), %room.look, desc)

  ; Check for trees
  var %room.tree.count $readini($zone(%look.zone), %room.look, trees)
  if (%room.tree.count > 0) { 
    msg =$nick 3You see5 %room.tree.count $iif(%room.tree.count > 1, trees, tree) 3here 
  }

  var %look.exits $readini($zone(%look.zone), %room.look, ExitList)
  if (%look.exits != $null) {  %look.exits = $replace(%look.exits, $chr(046), $chr(044) $chr(032)) }
  if (%look.exits = $null) { var %look.exits none that you can see }

  msg =$nick 10Exits:12 %look.exits

  ; Are there any items in the room?
  $room.look.items($1)

  if (%look.items != $null) {  
    msg =$nick 10Items laying here:12 %look.items
    unset %look.items
  }

  ; Are there any online players in the room?
  var %user.location $get.zone.and.room($1)
  var %chat.look 1
  while ($chat(%chat.look) != $null) {  var %nick $chat(%chat.look) 
    if (%nick != $nick) {
      var %target.location $get.zone.and.room(%nick)
      if (%target.location = %user.location) { 
        var %player.to.add %nick
        if ($in.battle(%player.to.add) = true) { var %player.to.add 4 $+ %player.to.add $+ $chr(91) $+ in battle $+ $chr(93) $+ 12 }
        %players.in.room = $addtok(%players.in.room, %player.to.add, 46)
      }
    }
    inc %chat.look 1
  } 

  if (%players.in.room != $null) {
    var %replacechar $chr(044) $chr(032)
    %players.in.room = $replace(%players.in.room, $chr(046), %replacechar)
    msg =$nick 10Other players here:12 %players.in.room
  }

  ; Show weather, time of day and moon

  ; show dig location if flag is set to do so
  if ($player.settings.flag($1, ShowDigSpot) = true) { 
    if ($room.flag($1, CanDig) = true) { $dcc.private.message($1, $readini(translation.dat, system, CanDigHere)) }
  }

  unset %players.in.room | unset %look.zone | unset %room.look

}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the list of items that
; are in the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.look.items {
  var %room.item.list $readini($zone(%look.zone), %room.look, Items)
  var %value.item 1 | var %number.of.items $numtok(%room.item.list,46)

  while (%value.item <= %number.of.items) {
    var %item.name $gettok(%room.item.list, %value.item, 46)
    var %item.amount $readini($zone(%look.zone), %room.look,%item.name)

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
  $room.add.exit(%current.zone, %current.room, $2, $3)

  ; Create the room

  if ($4 >= 0) { 
    ; Need to create a "default room" for the zone rather than a tunnel or cave.

    ; Copy default room stuff over.   to do: find a better way to do this.
    var %new.room.name $readini($zone(%current.zone), defaultroom, name)
    var %new.room.desc $readini($zone(%current.zone), defaultroom, desc)
    var %new.room.isshop $readini($zone(%current.zone), defaultroom, shop)
    if (%new.room.isshop = true) { var %new.room.shopnamec $readini($zone(%current.zone), defaultroom, shopname) }
    var %new.room.warmth $readini($zone(%current.zone), defaultroom, warmthneeded)
    var %new.room.underwater $readini($zone(%current.zone), defaultroom, underwater)
    var %new.room.inside $readini($zone(%current.zone), defaultroom, inside)
    var %new.room.trees $readini($zone(%current.zone), defaultroom, trees)
    var %new.room.candig $readini($zone(%current.zone), defaultroom, candig)
    var %new.room.zonetype $readini($zone(%current.zone), defaultroom, zone)

    writeini $zone(%current.zone) $3 Name %new.room.name
    writeini $zone(%current.zone) $3 Desc %new.room.desc
    writeini $zone(%current.zone) $3 Shop %new.room.isshop
    if (%new.room.isshop = true) { writeini $zone(%current.zone) $3 ShopName %new.room.shopname }
    writeini $zone(%current.zone) $3 WarmthNeeded %new.room.warmth
    writeini $zone(%current.zone) $3 UnderWater %new.room.underwater
    writeini $zone(%current.zone) $3 Inside %new.room.inside
    writeini $zone(%current.zone) $3 Trees %new.room.trees
    writeini $zone(%current.zone) $3 CanDig %new.room.candig
    writeini $zone(%current.zone) $3 zone %new.room.zonetype

    ; Link to nearby rooms, if necessary
    var %room.x $gettok($3, 1, 58) | var %room.y $gettok($3, 2, 58) | var %room.z $gettok($3, 3, 58)

    ; Get POS for exits
    var %east.exit $calc(%room.x + 1) | var %east.exit.room %east.exit $+ : $+ %room.y $+ : $+ %room.z
    var %north.exit $calc(%room.y + 1) | var %north.exit.room %room.x $+ : $+ %north.exit $+ : $+ %room.z
    var %south.exit $calc(%room.y - 1) | var %south.exit.room %room.x $+ : $+ %south.exit $+ : $+ %room.z
    var %west.exit $calc(%room.x - 1) | var %west.exit.room %west.exit $+ : $+ %room.y $+ : $+ %room.z
    var %up.exit $calc(%room.z + 1) | var %up.exit.room %room.x $+ : $+ %room.y $+ : $+ %up.exit

    ; Check and create links to rooms
    if ($readini($zone(%current.zone), %east.exit.room, name) != $null) { 
      $room.add.exit(%current.zone, $3, east, %east.exit.room)
      $room.add.exit(%current.zone, %east.exit.room, west, $3)
    }

    if ($readini($zone(%current.zone), %west.exit.room, name) != $null) { 
      $room.add.exit(%current.zone, $3, west, %west.exit.room)
      $room.add.exit(%current.zone, %west.exit.room, east, $3)
    }

    if ($readini($zone(%current.zone), %south.exit.room, name) != $null) { 
      $room.add.exit(%current.zone, $3, south %south.exit.room)
      $room.add.exit(%current.zone, %south.exit.room, north, $3)
    }

    if ($readini($zone(%current.zone), %north.exit.room, name) != $null) { 
      $room.add.exit(%current.zone, $3, north %north.exit.room)
      $room.add.exit(%current.zone, %north.exit.room, south, $3)
    }

    if ($readini($zone(%current.zone), %up.exit.room, name) != $null) { 
      $room.add.exit(%current.zone, $3, up %up.exit.room)
      $room.add.exit(%current.zone, %up.exit.room, down, $3)
    }

  }

  if ($4 < 0) {

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

  }

  ; Create the exit in the current room back to the previous room
  var %previous.exit up
  if ($2 = north) { var %previous.exit south }
  if ($2 = east) { var %previous.exit west }
  if ($2 = south) { var %previous.exit north }
  if ($2 = west) { var %previous.exit east }
  if ($2 = up) { var %previous.exit  down }
  if ($2 = down) { var %previous.exit up }

  $room.add.exit(%current.zone, $3, %previous.exit, %current.room)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adds an exit to a room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.add.exit {
  ; $1 = zone
  ; $2 = room that gets the exit added to
  ; $3 = direction
  ; $4 = the room that is linked to that direction

  var %exit.list  $readini($zone($1), $2 , ExitList)
  if (%exit.list != $null) { %exit.list = $addtok(%exit.list, $3, 46) }
  if (%exit.list = $null) { %exit.list = $3 }
  writeini $zone($1) $2 ExitList %exit.list
  writeini $zone($1) $2 $3 $4
  unset %exit.list
}
