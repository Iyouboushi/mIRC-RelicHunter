current.hp { return $readini($char($1), currentstats, hp) }
base.hp { return $readini($char($1), basestats, hp) }
current.stamina { return $readini($char($1), currentstats, stamina) }
current.hunger { return $readini($char($1), currentstats, hunger) }
current.warmth { return $readini($char($1), currentstats, warmth) }
in.battle { return $readini($char($1), currentstats, inbattle) }
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

look.room {
  ; $1 = user

  ; get zone
  set %look.zone $get.zone($1)

  ; get room
  set %look.room $get.room($1)

  ; Get zone + room
  var %look.zone.and.room $get.zone.and.room($1)

  ; build the room desc and show it
  msg =$nick 12[ $+ $readini($zone(%look.zone), %look.room, name) $+  ]
  msg =$nick 3 $+ $readini($zone(%look.zone), %look.room, desc)

  var %look.exits $readini($zone(%look.zone), %look.room, ExitList)
  if (%look.exits != $null) {  %look.exits = $replace(%look.exits, $chr(046), $chr(044) $chr(032)) }
  if (%look.exits = $null) { var %look.exits none that you can see }

  msg =$nick 10Exits:12 %look.exits

  ; Are there any items in the room?
  $look.room.items($1)

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
      if (%target.location = %user.location) { %players.in.room = $addtok(%players.in.room, %nick, 46) }
    }
    inc %chat.look 1
  } 

  if (%players.in.room != $null) {
    var %replacechar $chr(044) $chr(032)
    %players.in.room = $replace(%players.in.room, $chr(046), %replacechar)
    msg =$nick 10Other players here:12 %players.in.room
  }

  ; Show weather, time of day and moon

  unset %players.in.room | unset %look.zone | unset %look.room

}
look.room.items {
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

  ; Are there any trees?
  var %room.tree.count $readini($zone(%look.zone), %look.room, trees)
  if (%room.tree.count > 0) { 
    var %item_to_add tree $+ $chr(040) $+ %room.tree.count $+ $chr(041) 
    %look.items = $addtok(%look.items,%item_to_add,46)
  }


  %look.items = $replace(%look.items, $chr(046), $chr(044) $chr(032)) 
}

room.count.items {
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

room.add.item {
  var %current.zone $get.zone($1) | var %current.room $get.room($1)
  var %room.item.list $readini($zone(%current.zone), %current.room, items)

  %room.item.list = $addtok(%room.item.list, $2, 46)
  var %item.amount $readini($zone(%current.zone), %current.room, $2)

  if (%item.amount = $null) { var %item.amount 0 }
  inc %item.amount 1

  writeini $zone(%current.zone) %current.room $2 %item.amount
  writeini $zone(%current.zone) %current.room items %room.item.list

  unset %room.item.list
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
item.remove {
}

item.add {

}

inventory.count { return $readini($char($1), items, count) }
inventory {
  ; $1 = person
  ; $2 = type of inventory to show

  if ($2 = all) { }

  if ($2 = keys) { }

  if ($2 = accessories) { }
}


room.takeitem {


}

room.dropitem { 
  if ($item.count($1, $2) = 0) { echo -a don't have that item | halt }

  var %item.type $readini($dbfile(items.db), $2, type) 
  if (%item.type = $null) {
    var %item.type $readini($dbfile(equipment.db), $2, type)
    if (%item.type = $null) { echo -a item doesn't exist | halt }
  }

  if (%item.type = armor) { var %exclusive $readini($dbfile(equipment.db), $2, exclusive) }
  else { var %exclusive $readini($dbfile(items.db), $2, exclusive) }

  if (%exclusive = true) { echo -a can't drop this item | halt }

  ; Is the room full?
  if ($room.count.items($1) >= 15) { echo -a can't drop any more items here | halt }

  ; add the item to the room
  $room.add.item($1, $2)

  ; Remove this item from the player
  $item.remove($1, $2)

  ; Show everyone that we dropped it.
  $announce.room.action($1, dropitem, $2)
}
