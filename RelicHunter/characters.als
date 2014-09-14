current.hp { return $readini($char($1), currentstats, hp) }
base.hp { return $readini($char($1), basestats, hp) }
current.hunger { return $readini($char($1), currentstats, hunger) }
current.warmth { return $readini($char($1), currentstats, warmth) }
in.battle { return $readini($char($1), currentstats, inbattle) }
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
race { return $readini($char($1), info, race) }
setrace {
  if ($2 = human) {
    writeini $char($1) info race Human
    writeini $char($1) basestats hp 30
    writeini $char($1) basestats str 5
    writeini $char($1) basestats def 5
    writeini $char($1) basestats int 5
    writeini $char($1) basestats agi 5
  }

  if ($2 = elf) {
    writeini $char($1) info race Elf
    writeini $char($1) basestats hp 32
    writeini $char($1) basestats str 4
    writeini $char($1) basestats def 4
    writeini $char($1) basestats int 6
    writeini $char($1) basestats agi 6
  }

  if ($2 = sciencecreation) {
    writeini $char($1) info race Science Creation
    writeini $char($1) basestats hp 33
    writeini $char($1) basestats str 6
    writeini $char($1) basestats def 6
    writeini $char($1) basestats int 4
    writeini $char($1) basestats agi 4
  }

  if ($2 = unknownraceyet) {
    writeini $char($1) info race not decided upon yet
    writeini $char($1) basestats hp 28
    writeini $char($1) basestats str 3
    writeini $char($1) basestats def 4
    writeini $char($1) basestats int 4
    writeini $char($1) basestats agi 9
  }

  writeini $char($1) battle hunger 100
  writeini $char($1) battle warmth 1
  $fulls($1)
}

get.level {
  var %str $readini($char($1),currentstats, str)
  var %def $readini($char($1), currentstats, def)
  var %int $readini($char($1), currentstats, int)
  var %agi $readini($char($1), currentstats, agi)

  var %level %str
  inc %level %def
  inc %level %int
  inc %level %agi

  var %level $round($calc(%level / 20), 1)

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
    $display.system.message($readini(translation.dat, status, CurrentlyAmnesia),battle) 

    halt 
  }
}

weapon.equipped {  
}

look.room {
  ; get zone

  ; get room

  ; build the room desc and show it

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

inventory.count { return $readini($char($1), items, count) }
inventory {
  ; $1 = person
  ; $2 = type of inventory to show

  if ($2 = all) { }

  if ($2 = keys) { }

  if ($2 = accessories) { }
}
