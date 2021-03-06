;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; CHARACTER COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a new character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 1:TEXT:!new char*:*: {  $checkscript($2-)
  if ($isfile($char($nick)) = $true) { $display.private.message($readini(translation.dat, system, PlayerExists),privatemessage) | halt }
  if ($isfile($char($nick $+ _clone)) = $true) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($isfile($char(evil_ $+ $nick)) = $true)  { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($isfile($char($nick $+ _summon)) = $true) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($isfile($mon($nick)) = $true) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($isfile($boss($nick)) = $true) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt  }
  if ($isfile($npc($nick)) = $true) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($isfile($summon($nick)) = $true) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = $nick $+ _clone) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = evil_ $+ $nick) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = monster_warmachine) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = demon_wall) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = pirate_scallywag) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = pirate_firstmatey) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = bandit_leader) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = bandit_minion) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = crystal_shadow) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ($nick = alliedforces_president) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }
  if ((($nick = frost_monster) || ($nick = frost_monster1) || ($nick = frost_monster2))) { $display.private.message($readini(translation.dat, system, NameReserved),privatemessage) | halt }

  ; Create the new character now
  .copy $char(new_chr) $char($nick)
  writeini $char($nick) BaseStats Name $nick 
  writeini $char($nick) Info Created $fulldate
  writeini $char($nick) Info StartTime $ctime

  $display.system.message($readini(translation.dat, system, CharacterCreated),global)

  ; Generate a password
  set %password relichunter $+ $rand(1,100) $+ $rand(a,z)

  writeini $char($nick) info password $encode(%password)
  $display.private.message($readini(translation.dat, system, StartingCharPassword),privatemessage)

  ; Give voice
  mode %battlechan +v $nick

  .auser 2 $nick | dcc chat $nick 

  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$nick,46) = $true) {  .auser 50 $nick }

  unset %ip.address. [ $+ [ $nick ] ] 
  unset %totalplayers | unset %password
  unset %duplicate.ips | unset %file | unset %name | unset %current.shoplevel | unset %totalplayers
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set a new password
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 2:TEXT:!newpass *:?:{ $checkscript($2-) | $password($nick) 

  var %encode.type $readini($char($nick), info, PasswordType)

  if (%encode.type = $null) { var %encode.type encode }
  if (%encode.type = encode) { 
    if ($encode($2) = %password) {  
      if ($version < 6.3) { writeini $char($nick)  info PasswordType encode | writeini $char($nick) info password $encode($3)  }
      else { writeini $char($nick) info PasswordType hash |  writeini $char($nick) info password $sha1($3) }
      $display.private.message($readini(translation.dat, system, newpassword),privatemessage) | unset %password | halt
    }
    if ($encode($2) != %password) {  $display.private.message($readini(translation.dat, errors, wrongpassword),privatemessage) | unset %password | halt }
  }
  if (%encode.type = hash) {
    if ($sha1($2) = %password) { writeini $char($nick) info password $sha1($3) | writeini $char($nick) info PasswordType hash | $display.private.message($readini(translation.dat, system, newpassword), privatemessage) | unset %password | halt }
    if ($sha1($2) != %password) { $display.private.message($readini(translation.dat, errors, wrongpassword),privatemessage) | unset %password | halt }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log into the bot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 1:TEXT:!id*:*:{ 
  $idcheck($nick , $2) | mode %battlechan +v $nick |  /.dns $nick |  /close -m* 
  if ($readini($char($nick), info, CustomTitle) != $null) { var %custom.title " $+ $readini($char($nick), info, CustomTitle) $+ " }
}
ON 1:TEXT:!quick id*:*:{ $idcheck($nick , $3, quickid) | mode %battlechan +v $nick |   /.dns $nick
  /close -m* 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log out of the bot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 3:TEXT:!logout*:*:{ .auser 1 $nick | mode %battlechan -v $nick | .flush 1 }
on 3:TEXT:!log out*:*:{ .auser 1 $nick | mode %battlechan -v $nick | .flush 1 }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; See who's online
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!who*: { $dcc.who'sonline($nick) }
on 2:Chat:!who's online*: { $dcc.who'sonline($nick) }
on 2:Chat:!online list*: { $dcc.who'sonline($nick) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Help commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!view-info*: { $view-info($1, $2, $3, $4) }
on 2:Chat:!help*: { $gamehelp($2, $nick) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; See stats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!hp*: { 
  $set_chr_name($nick) | $hp_status_hpcommand($nick) 
  $dcc.private.message($nick,$readini(translation.dat, system, ViewMyHP))

  if ($person_in_mech($nick) = true) { var %mech.name $readini($char($nick), mech, name) | $hp_mech_hpcommand($nick) 
    $dcc.private.message($nick,$readini(translation.dat, system, ViewMyMechHP))
  }

  unset %real.name | unset %hstats
}

on 2:Chat:!tp*: { 
  $set_chr_name($nick) 
  $dcc.private.message($nick,$readini(translation.dat, system, ViewMyTP))
  unset %real.name
}

on 2:Chat:!hunger*: { 
  $set_chr_name($nick) 
  $dcc.private.message($nick,$readini(translation.dat, system, ViewMyHunger))
  unset %real.name
}

on 2:Chat:!stamina*: { 
  $set_chr_name($nick) 
  $dcc.private.message($nick,$readini(translation.dat, system, ViewMyStamina))
  unset %real.name
}

on 2:Chat:!stam*: { 
  $set_chr_name($nick) 
  $dcc.private.message($nick,$readini(translation.dat, system, ViewMyStamina))
  unset %real.name
}

on 2:Chat:!warmth*: { 
  $set_chr_name($nick) 
  $dcc.private.message($nick,$readini(translation.dat, system, ViewMyWarmth))
  unset %real.name
}

on 2:Chat:!level*: {
  if ($1 = !leveladjust) { halt }
  if ($2 = $null) { $set_chr_name($nick) | var %player.level $bytes($round($get.level($nick),0),b) | $dcc.private.message($nick, $readini(translation.dat, system, ViewLevel)) | unset %real.name }
  if ($2 != $null) { $checkscript($2-) | $checkchar($2) | $set_chr_name($2) | var %player.level $bytes($round($get.level($2),0),b) | $dcc.private.message($nick, $readini(translation.dat, system, ViewLevel)) | unset %real.name }
}

on 2:Chat:!xp*: { 
}

on 2:Chat:!stats*: { unset %all_status 
}

on 2:Chat:!status*: {  unset %all_status 
} 

on 2:Chat:!techs*: {
}

on 2:Chat:!skills*: { $skills.list($nick) }
on 2:Chat:skills: { $skills.list($nick) }

on 2:Chat:!race: { $dcc.private.message($nick, $readini(translation.dat, system, showrace))  }
on 2:Chat:!gender: { $dcc.private.message($nick, $readini(translation.dat, system, showgender))  }
on 2:Chat:!class: { $dcc.private.message($nick, $readini(translation.dat, system, showclass))  }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Equipment Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!weapons*: { 
}
on 2:Chat:!equip*: {
}

on 2:Chat:!unequip*: {
}

on 2:Chat:!wear*: { 
  var %item.type $readini($dbfile(equipment.db), $2, type)

  if (%item.type = accessory) { $wear.accessory($nick, $2) }
  if (%item.type = armor) { $wear.armor($nick, $2) }

  if ((%item.type != accessory) && (%item.type != armor)) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tWearThat)) | halt }
}

on 2:Chat:wear *: { 
  var %item.type $readini($dbfile(equipment.db), $2, type)

  if (%item.type = accessory) { $wear.accessory($nick, $2) }
  if (%item.type = armor) { $wear.armor($nick, $2) }

  if ((%item.type != accessory) && (%item.type != armor)) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tWearThat)) | halt }
}

on 2:Chat:!remove*: { 
  var %item.type $readini($dbfile(equipment.db), $2, type)
  if (%item.type = accessory) { $remove.accessory($nick, $2) }
  if (%item.type = armor) { $remove.armor($nick, $2) }
  if ((%item.type != accessory) && (%item.type != armor)) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tRemoveThat)) | halt }
}

on 2:Chat:remove *: { 
  var %item.type $readini($dbfile(equipment.db), $2, type)
  if (%item.type = accessory) { $remove.accessory($nick, $2) }
  if (%item.type = armor) { $remove.armor($nick, $2) }
  if ((%item.type != accessory) && (%item.type != armor)) { $dcc.private.message($nick, $readini(translation.dat, errors, Can'tRemoveThat)) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Movement Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!go*: { $go($nick, $2) }
on 2:Chat:go*: { $go($nick, $2) }
on 2:Chat:north: { $go($nick, north) }
on 2:Chat:n: { $go($nick, north) }
on 2:Chat:east: { $go($nick, east) }
on 2:Chat:e: { $go($nick, east) }
on 2:Chat:south: { $go($nick, south) }
on 2:Chat:s: { $go($nick, south) }
on 2:Chat:west: { $go($nick, west) }
on 2:Chat:w: { $go($nick, west) }
on 2:Chat:down: { $go($nick, down) }
on 2:Chat:d: { $go($nick, down) }
on 2:Chat:u: {  $go($nick, up) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Digging Command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!dig *: { 
  var %valid.directions n.north.e.east.s.south.w.west.u.up.d.down
  if ($istok(%valid.directions, $2, 46) = $true) { $dig($nick, $2) }
  else { $dcc.private.message($nick, $readini(translation.dat, errors, CannotDigDirection)) }
}
on 2:Chat:dig *: { 
  var %valid.directions n.north.e.east.s.south.w.west.u.up.d.down
  if ($istok(%valid.directions, $2, 46) = $true) { $dig($nick, $2) }
  else { $dcc.private.message($nick, $readini(translation.dat, errors, CannotDigDirection)) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Chopping Command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!chop *: { $chop($nick) }
on 2:Chat:chop *: { $chop($nick) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Looking/room commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!weather*: {  
  ; get current room/zone and see if that location is inside.  If so, don't show.  If not, show weather.
  var %weather.zone $get.zone($nick) | var %weather.room $get.room($nick)
  if ($readini($zone(%weather.zone), %weather.room, inside) = true) {  $dcc.private.message($nick, $readini(translation.dat, errors, Can'tSeeWeather))  | halt }
  $dcc.private.message($nick, $readini(translation.dat, battle, CurrentWeather)) 
}

on 2:Chat:!moon*: {  
  ; get current room/zone and see if that location is inside.  If so, don't show.  If not, show moon.
  $dcc.private.message($nick, $readini(translation.dat, battle, CurrentMoon))
}

on 2:Chat:!time*: {  
  ; get current room/zone and see if that location is inside.  If so, don't show.  If not, show time.

  $dcc.private.message($nick, $readini(translation.dat, battle, CurrentTime)) 
}

on 2:Chat:!pos: {  $dcc.private.message($nick, $readini(translation.dat, system, CurrentPOS)) }
on 2:Chat:!look: { $room.look($nick) }
on 2:Chat:look: { $room.look($nick) }

on 2:Chat:!look at*: {
  ; Is it a person in the same room?

  ; Check for inventory object

  ; Finally, return that nothing was found.

}

on 2:Chat:!take*: {  
  ; Attempt to take an item from a room.
  $player.take.item($nick, $2)
}
on 2:Chat:take*: {  
  ; Attempt to take an item from a room.
  $player.take.item($nick, $2)
}
on 2:Chat:!pick up *: {  
  ; Attempt to take an item from a room.
  $player.take.item($nick, $3)
}
on 2:Chat:pick up *: {  
  ; Attempt to take an item from a room.
  $player.take.item($nick, $3)
}
on 2:Chat:!get*: {  
  ; Attempt to take an item from a room.
  $player.take.item($nick, $2)
}
on 2:Chat:get*: {  
  ; Attempt to take an item from a room.
  $player.take.item($nick, $2)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inventory/Item commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!items: { $inventory($nick, all) }
on 2:Chat:items: { $inventory($nick, all) }
on 2:Chat:!inventory*: { $inventory($nick, all) }
on 2:Chat:inventory: { $inventory($nick, all) }
on 2:Chat:i: { $inventory($nick, all) }
on 2:Chat:!keys*: { $inventory($nick, keys) }
on 2:Chat:!accessories*: { $inventory($nick, accessories) } 
on 2:Chat:accessories*: { $inventory($nick, accessories) } 

on 2:Chat:!drop*: {  
  ; Attempt to drop an item from inventory to the room.
  $player.dropitem($nick, $2)
}
on 2:Chat:drop *: {  
  ; Attempt to drop an item from inventory to the room.
  $player.dropitem($nick, $2)
}


ON 2:Chat:!use*: {  
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!push*: {  }
on 2:Chat:push *: {  }

on 2:Chat:!pull*: {  }
on 2:Chat:pull *: {  }

on 2:Chat:!eat*: {  }
on 2:Chat:eat *: {  }



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Toggle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:!toggle*: { 
  ; $2 = flag to toggle on/off

  if ($2 = showhunger) { 
    if ($player.settings.flag($nick, ShowHunger) = true) { 
      writeini $char($nick) settings ShowHunger false
      $dcc.private.message($nick, 3The setting: Show Hunger has been set to false) | halt 
    }
    if ($player.settings.flag($nick, ShowHunger) = false) { 
      writeini $char($nick) settings ShowHunger true
      $dcc.private.message($nick, 3The setting: Show Hunger has been set to true) | halt 
    }
  }

  if ($2 = showdigspot) {
    if ($player.settings.flag($nick, ShowDigSpot) = true) { 
      writeini $char($nick) settings ShowDigSpot false
      $dcc.private.message($nick, 3The setting: Show Dig Spot has been set to false) | halt 
    }
    if ($player.settings.flag($nick, ShowDigSpot) = false) { 
      writeini $char($nick) settings ShowDigSpot true
      $dcc.private.message($nick, 3The setting: Show Dig Spot has been set to true) | halt 
    }
  }

  if ($2 = showPOS) {
    if ($player.settings.flag($nick, ShowPOS) = true) { 
      writeini $char($nick) settings ShowPOS false
      $dcc.private.message($nick, 3The setting: Show POS has been set to false) | halt 
    }
    if ($player.settings.flag($nick, ShowPOS) = false) { 
      writeini $char($nick) settings ShowPOS true
      $dcc.private.message($nick, 3The setting: Show POS has been set to true) | halt 
    }
  }

  if ($2 = showWeather) {
    if ($player.settings.flag($nick, showWeather) = true) { 
      writeini $char($nick) settings showWeather false
      $dcc.private.message($nick, 3The setting: Show Weather has been set to false) | halt 
    }
    if ($player.settings.flag($nick, showWeather) = false) { 
      writeini $char($nick) settings showWeather true
      $dcc.private.message($nick, 3The setting: Show Weather has been set to true) | halt 
    }
  }

  ; More settings can be here.

}
