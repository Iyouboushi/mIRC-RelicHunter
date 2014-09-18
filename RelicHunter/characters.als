current.hp { return $readini($char($1), currentstats, hp) }
base.hp { return $readini($char($1), basestats, hp) }
current.stamina { return $readini($char($1), currentstats, stamina) }
current.hunger { return $readini($char($1), currentstats, hunger) }
current.warmth { return $readini($char($1), currentstats, warmth) }
in.battle { return $readini($char($1), currentstats, inbattle) }
player.settings.flag {
  var %flag.check $readini($char($1), settings, $2)
  if (%flag.check = $null) { return false }
  else { return %flag.check }
}
get.name { return $readini($char($1), basestats, name) } 
gender { return $readini($char($1), Info, Gender) }
gender2 {
  if ($gender($1) = her) { return her }
  if ($gender($1) = its) { return it }
  else { return him }
}
gender3 {
  if ($gender($1) = her) { return she }
  if ($gender($1) = its) { return it }
  else { return he }
}
setgender {
  if ($2 = male) { writeini $char($1) info gender his | writeini $char($1) info gender2 him }
  if ($2 = female) { writeini $char($1) info gender her | writeini $char($1) info gender2 she }
  if ($2 = other) { writeini $char($1) info gender its | writeini $char($1) info gender2 it }
}
get.gender {
  if ($gender($1) = her) { return female }
  if ($gender($1) = his) { return male }
  else { return other }
}
class { return $readini($char($1), info, class) }
setclass {
}

race { return $readini($char($1), info, race) }
setrace {
  if ($2 = human) {
    writeini $char($1) info race Human
    writeini $char($1) basestats hp 30
    writeini $char($1) basestats str 5
    writeini $char($1) basestats def 5
    writeini $char($1) basestats int 5
    writeini $char($1) basestats agi 5
    writeini $char($1) basestats char 5
  }

  if ($2 = elf) {
    writeini $char($1) info race Elf
    writeini $char($1) basestats hp 32
    writeini $char($1) basestats str 4
    writeini $char($1) basestats def 4
    writeini $char($1) basestats int 6
    writeini $char($1) basestats agi 6
    writeini $char($1) basestats char 5
  }

  if ($2 = sciencecreation) {
    writeini $char($1) info race Science Creation
    writeini $char($1) basestats hp 33
    writeini $char($1) basestats str 8
    writeini $char($1) basestats def 7
    writeini $char($1) basestats int 4
    writeini $char($1) basestats agi 4
    writeini $char($1) basestats char 2

  }

  if ($2 = unknownraceyet) {
    writeini $char($1) info race not decided upon yet
    writeini $char($1) basestats hp 28
    writeini $char($1) basestats str 3
    writeini $char($1) basestats def 4
    writeini $char($1) basestats int 4
    writeini $char($1) basestats agi 8
    writeini $char($1) basestats char 6

  }

  writeini $char($1) currentstats hunger 100
  writeini $char($1) currentstats warmth 1
  $fulls($1)
}

get.level {
  var %str $readini($char($1),currentstats, str)
  var %def $readini($char($1), currentstats, def)
  var %int $readini($char($1), currentstats, int)
  var %agi $readini($char($1), currentstats, agi)
  var %char $readini($char($1), currentstats, char)

  var %level %str
  inc %level %def
  inc %level %int
  inc %level %char

  var %level $round($calc(%level / 25), 1)

  return %level
}

is_charmed {
  if ($readini($char($1), status, charmed) = yes) { return true }
  else { return false }
}

is_confused {
  if ($readini($char($1), status, confuse) = yes) { return true }
  else { return false }
}

amnesia.check {
  var %amnesia.check $readini($char($1), status, amnesia)
  if (%amnesia.check = no) { return }
  else { 
    $set_chr_name($1) 
    $dcc.private.message($1, $readini(translation.dat, status, CurrentlyAmnesia)) 

    halt 
  }
}

skill.add {
  ; $1 = person to add skill to
  ; $2 = skill being added
  ; $3 = level of skill being added

  var %skill.level.adding $3
  if (%skill.level.adding = $null) { var %skill.level.adding 1 }

  writeini $char($1) skills $2 %skill.level.adding
  $dcc.private.message($1, $readini(translation.dat, system, LearnedNewSkill))

}
skill.increase {
  ; $1 = person increasing skill
  ; $2 = skill name
  ; $3 = amount that skill is being raised by

  var %skill.level.increase $3
  if (%skill.level.increase = $null) { var %skill.level.increase 1 }

  var %current.skill.knowledge $readini($char($1), skills, $2)
  inc %current.skill.knowledge %skill.level.increase
  writeini $char($1) skills $2 %current.skill.knowledge
  $dcc.private.message($1, $readini(translation.dat, system, IncreasedSkill))
}





weapon.equipped {  
}

look.target {
  $weapon.equipped($1) | $set_chr_name($1)
  var %equipped.accessory $readini($char($1), equipment, accessory) 
  if (%equipped.accessory = $null) { var %equipped.accessory nothing }
  var %equipped.armor.head $readini($char($1), equipment, head) 
  if (%equipped.armor.head = $null) { var %equipped.armor.head nothing }
  var %equipped.armor.body $readini($char($1), equipment, body) 
  if (%equipped.armor.body = $null) { var %equipped.armor.body nothing }
  var %equipped.armor.legs $readini($char($1), equipment, legs) 
  if (%equipped.armor.legs = $null) { var %equipped.armor.legs nothing }
  var %equipped.armor.feet $readini($char($1), equipment, feet) 
  if (%equipped.armor.feet = $null) { var %equipped.armor.feet nothing }
  var %equipped.armor.hands $readini($char($1), equipment, hands) 
  if (%equipped.armor.hands = $null) { var %equipped.armor.hands nothing }

  if ($readini($char($1), info, CustomTitle) != $null) { var %custom.title " $+ $readini($char($1), info, CustomTitle) $+ " }

  var %look.message 3 $+ %real.name is wearing %equipped.armor.head on $gender($1) head, %equipped.armor.body on $gender($1) body, %equipped.armor.legs on $gender($1) legs, %equipped.armor.feet on $gender($1) feet, %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped as an accessory and is currently using the %weapon.equipped weapon.
  $dcc.private.message($nick, %look.message) 
} 

look.object {
}

item.count {
  var %item.count $readini($char($1), items, $2) 
  if (%item.count = $null) { var %item.count 0 }
  return %item.count
}
item.total.count {
  return $readini($char($1), items, count)
}
item.remove {
  var %player.item.amount $item.count($1, $2)
  dec %player.item.amount 1
  if (%player.item.amount = 0) { remini $char($1) items $2 }
  else {  writeini $char($1) items $2 %player.item.amount }

  var %player.item.count $item.total.count($1, $2)
  dec %player.item.count 1
  writeini $char($1) items count %player.item.count

  ; Remove from the list
  var %player.item.list $readini($char($1), items, list)
  var %player.item.list $remtok(%player.item.list, $2, 46)
  if (%player.item.list = $null) { writeini $char($1) items list nothing }
  else { writeini $char($1) items list %player.item.list  }
}
item.add {
  var %player.item.amount $item.count($1, $2)
  inc %player.item.amount 1
  writeini $char($1) items $2 %player.item.amount

  var %player.item.count $item.total.count($1, $2)
  inc %player.item.count 1
  writeini $char($1) items count %player.item.count

  ; Add to the list
  var %player.item.list $readini($char($1), items, list)
  if (%player.item.list = nothing) { writeini $char($1) items list $2 }
  else { 
    var %player.item.list $addtok(%player.item.list, $2, 46)
    writeini $char($1) items list %player.item.list
  }
}

inventory.count { return $readini($char($1), items, count) }
inventory {
  ; $1 = person
  ; $2 = type of inventory to show

  if ($2 = all) { 
    $inventory.builditemslist($1)

    %items.list = $replace(%items.list, $chr(046), $chr(044) $chr(032))

    if (%items.list != nothing) {  $dcc.private.message($1, $readini(translation.dat, system, ViewItems)) }
    if (%items.list = nothing) {  $dcc.private.message($1, $readini(translation.dat, system, CarryingNoItems)) }

    unset %items.list
  }

  if ($2 = keys) { }

  if ($2 = accessories) { }
}

inventory.builditemslist {
  set %items.list $readini($char($1), items, list)

  if (%items.list = nothing) { return }

  ; If the items list isn't 'nothing' then we need to get the count of each item.
  var %item.place 1 | var %total.item.list.count $numtok(%items.list, 46)

  while (%item.place <= %total.item.list.count) {
    var %item.name $gettok(%items.list, %item.place, 46)
    var %item.amount $readini($char($1), items, %item.name)

    if (%item.amount = $null) { var %item.amount 1 }

    ; add the item and the amount to the item list
    var %item_to_add %item.name $+  $+ $chr(040) $+ %item.amount $+ $chr(041) $+ 
    %new.item.list = $addtok(%new.item.list,%item_to_add,46)

    inc %item.place 1 
  }

  set %items.list %new.item.list
  unset %new.item.list

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; drops an item into the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
player.dropitem { 

  ; Are you in battle? If so, you can't do this action
  if ($in.battle($1) = true) {  $battle.look($1) | halt }

  if ($item.count($1, $2) = 0) { $dcc.private.message($1, $readini(translation.dat, errors, DoNotHaveThatItem))  | halt  }

  var %item.type $readini($dbfile(items.db), $2, type) 
  if (%item.type = $null) {
    var %item.type $readini($dbfile(equipment.db), $2, type)
    if (%item.type = $null) { $dcc.private.message($1, $readini(translation.dat, errors, ItemDoesNotExist)) | halt }
  }

  if (%item.type = armor) { var %exclusive $readini($dbfile(equipment.db), $2, exclusive) }
  else { var %exclusive $readini($dbfile(items.db), $2, exclusive) }

  if (%exclusive = true) { $dcc.private.message($1, $readini(translation.dat, errors, ItemIsExclusive)) | halt }

  ; Is the room full?
  if ($room.count.items($1) >= 15) { $dcc.private.message($1, $readini(translation.dat, errors, RoomFull)) | halt }

  ; add the item to the room
  $room.add.item($1, $2)

  ; Remove this item from the player
  $item.remove($1, $2)

  ; Show everyone that we dropped it.
  $announce.room.action($1, dropitem, $2)

  ; Show the player that they've dropped it.
  $dcc.private.message($1, $readini(translation.dat, system, YouDropItem))
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; picks up an item from a
; room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
player.take.item {

  ; Are you in battle? If so, you can't do this action
  if ($in.battle($1) = true) {  $battle.look($1) | halt }

  if ($room.item.amount($1, $2) <= 0) {  $dcc.private.message($1, $readini(translation.dat, errors, RoomDoesn'tHaveItem))  | halt }
  if ($inventory.count($1) >= 15) { $dcc.private.message($1, $readini(translation.dat, errors, InventoryIsFull))  | halt }

  ; remove the item from the room
  $room.remove.item($1, $2)

  ; add the item to the player
  $item.add($1, $2)

  ; Show everyone that we took it.
  $announce.room.action($1, takeitem, $2)

  ; Show the player that they've picked it up.
  $dcc.private.message($1, $readini(translation.dat, system, YouTakeItem))
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The dig command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dig {

  ; Are you in battle? If so, you can't do this action
  if ($in.battle($1) = true) {  $battle.look($1) | halt }

  ; Do we have a pickaxe?
  if ($item.count($1, Pickaxe) = 0) { $dcc.private.message($1, $readini(translation.dat, errors, DoNotHavePickaxe))  | halt  }

  ; Do we have stamina?
  if ($current.stamina($1) < 5) { $dcc.private.message($1, $readini(translation.dat, errors, DoNotHaveStamina))  | halt  }

  ; Can we dig here?
  if ($room.flag($1, CanDig) = false) { $dcc.private.message($1, $readini(translation.dat, errors, CannotDigHere))  | halt  }

  ; If we're on Z level >= 0 we cannot dig anywhere except down.
  if ($get.z($1) >= 0) { 
    var %valid.directions d.down
    if ($istok(%valid.directions, $2, 46) = $false) { $dcc.private.message($1, $readini(translation.dat, errors, CannotDigDirection)) | halt }
  }

  var %current.zone $get.zone($1) | var %current.room $get.room($1) | var %current.x $get.x($1) | var %current.y $get.y($1) | var %current.z $get.z($1)

  ; Get the new room's location
  var %direction down 
  if (($2 = up) || ($2 = u)) { var %direction up | inc %current.z 1 }
  if (($2 = north) || ($2 = n)) { var %direction north |  inc %current.y 1 }
  if (($2 = east) || ($2 = e)) { var %direction east |  inc %current.x 1 }
  if (($2 = south) || ($2 = s)) { var %direction south | dec %current.y 1 }
  if (($2 = west) || ($2 = w)) { var %direction west | dec %current.x 1 }
  if (($2 = down) || ($2 = d)) { var %direction down | dec %current.z 1 }

  var %room.to.make %current.x $+ $chr(58) $+ %current.y $+ $chr(58) $+ %current.z
  if ($readini($zone($get.zone($1)), %room.to.make, CanDig) = false) { $dcc.private.message($1, $readini(translation.dat, errors, CannotDigDirection))  | halt  }
  if ($readini($zone($get.zone($1)), %room.to.make, Name) != $null) { 

    ; So the room exists.  Can we link to it? (If the CanDig = false then no)
    if ($readini($zone($get.zone($1)), %room.to.make, CanDig) = false) { $dcc.private.message($1, $readini(translation.dat, errors, CannotDigDirection))  | halt  }

    ; So we can link to it.  The first thing we need to do is figure out the opposite direction.

    if (%direction = down) { var %opposite.direction up }
    if (%direction = up) { var %opposite.direction down }
    if (%direction = north) { var %opposite.direction south }
    if (%direction = east) { var %opposite.direction west }
    if (%direction = south) { var %opposite.direction north }
    if (%direction = west) { var %opposite.direction east }

    ; Is there already a link to it?
    var %islinked $readini($zone($get.zone($1)), %room.to.make, %opposite.direction)
    if (%islinked != $null) { $dcc.private.message($1, $readini(translation.dat, errors, CannotDigDirection))  | halt  }

    ; Link the rooms
    $room.add.exit(%current.zone, %room.to.make, %opposite.direction, %current.room)
    $room.add.exit(%current.zone, %current.room, %direction, %room.to.make)

    $dcc.private.message($1, $readini(translation.dat, system, YouLinkRooms))
    $go($1, %direction)

    halt
  }


  ; Decrease Stamina
  writeini $char($1) currentstats stamina $calc($current.stamina($1) - 5) 

  ; Create the room
  var %direction $2

  $room.create.dig($1, %direction, %room.to.make, %current.z) 


  ; Announce that we've dug down.
  $announce.room.action($1, digging, %direction)
  $dcc.private.message($1, $readini(translation.dat, system, YouDigDirection))

  ; Random chance of adding an ore if z is -5 or lower.
  if (%current.z <= -5) { 
    if ($rand(1,10) > 5) { 
      ; create ore and add to room.
      $room.generateore($get.zone($1), %room.to.make, %current.z)
    }
  }

  ; Move the char.
  $go($1, %direction)
}
