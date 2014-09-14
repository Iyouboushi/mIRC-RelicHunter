;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Updates weather, moon
; and time of day in the zones
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
update.zone {
  var %value 1 | var %zones.lines $lines($lstfile(zones.lst))

  while (%value <= %zones.lines) {
    var %zone.num $read -l $+ %value $lstfile(zones.lst)
    var %zone.weather.list $readini($zone(%zone.num), weather, list)
    var %zone.current.weather $readini($zone(%zone.num), weather, current)

    if (($isfile($zone(%zone.num)) = $true) && ($readini($zone(%zone.num), info, active) = true)) {
      if ($rand(1,10) > 6) {
        var %zone.random.weatherchange $gettok(%zone.weather.list,$rand(1,$numtok(%zone.weather.list,46)),46)
        if (%zone.random.weatherchange != %zone.current.weather) { 
          writeini $zone(%zone.num) weather current %zone.random.weatherchange
          ; display message to people in that zone
          $dcc.zone.message(%zone.num, $readini(translation.dat, weatherchange, %zone.random.weatherchange), weather)
        }
      }

      $moonphase(%zone.num)
      $timeofday(%zone.num)
    }

    inc %value 1 
  }
}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Controls the phase of the
; moon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moonphase {
  ; $1 = the zone number that needs to be updated

  set %moonphase $readini($zone($1), moonphase, CurrentMoonPhase)
  if (%moonphase = $null) { var %moonphase New | remini $zone($1) moonphase CurrentMoonTurn | writeini $zone($1) moonphase currentMoonPhase New }

  var %moonphase.turn $readini($zone($1), MoonPhase, CurrentMoonTurn)
  if (%moonphase.turn = $null) { var %moonphase.turn 0 }
  inc %moonphase.turn 1
  writeini $zone($1) MoonPhase CurrentMoonTurn %moonphase.turn

  set %moonphase.turn.max $readini($zone($1), moonphasetime, %moonphase)
  if (%moonphase.turn.max = $null) { var %moonphase.turn.max 1 }

  if (%moonphase.turn > %moonphase.turn.max) { 
    $moonphase.increase($1) 
    writeini $zone($1) moonphase CurrentMoonPhase %moonphase
  }
  if (%moonphase = New) { $moonphase.bloodmoon($1) }

  set %moon.phase %moonphase Moon

  unset %moonphase | unset %moonphase.turn.max 
}
moonphase.increase {
  writeini $zone($1) moonphase currentMoonTurn 1

  if (%moonphase = Full) { set %moonphase New | return }
  if (%moonphase = New) { set %moonphase Crescent | return }
  if (%moonphase = Blood) { set %moonphase Crescent | return }
  if (%moonphase = Crescent) { set %moonphase Quarter | return }
  if (%moonphase = Quarter) { set %moonphase Gibbous | return }
  if (%moonphase = Gibbous) { set %moonphase Full | return }
}

moonphase.bloodmoon {
  var %bloodmoon.chance $readini($zone($1), MoonPhaseTime, BloodMoonChance)
  if (%bloodmoon.chance = $null) { var %bloodmoon.chance 40 }

  var %curse.chance $rand(1,100)

  if (%curse.chance <= %bloodmoon.chance) { 
    set %bloodmoon on 
    set %moonphase Blood
    writeini $zone($1) moonphase CurrentMoonPhase Blood
    writeini $zone($1) moonphase currentMoonTurn 1
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Controls the time of day
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
timeofday {
  ; $1 = the zone number to be updated
  set %timeofday $readini($zone($1) , timeofday, CurrentTimeofDay)
  if (%timeofday = $null) { var %timeofday Morning | remini $zone($1) timeofday CurrentTimeOfDayTurn | writeini $zone($1)  timeofday currentTimeOfDay Morning }

  var %timeofday.turn $readini($zone($1), timeofday, CurrentTimeOfDayTurn)
  if (%timeofday.turn = $null) { var %timeofday.turn 0 }
  inc %timeofday.turn 1
  writeini $zone($1) timeofday CurrentTimeOfDayTurn %timeofday.turn

  set %timeofday.turn.max $readini($zone($1), timeofdaytime, %timeofday)
  if (%timeofday.turn.max = $null) { var %timeofday.turn.max 2 }

  if (%timeofday.turn > %timeofday.turn.max) { $timeofday.increase($1) | writeini $zone($1) timeofday Currenttimeofday %timeofday }

  unset %timeofday | unset %timeofday.turn.max 
}
timeofday.increase {
  writeini $zone($1) timeofday currentTimeOfDayTurn 1

  if (%timeofday = Morning) { set %timeofday Noon | return }
  if (%timeofday = Noon) { set %timeofday Evening | return }
  if (%timeofday = Evening) { set %timeofday Night | return }
  if (%timeofday = Night) { 
    set %timeofday Morning 
    var %number.of.gamedays $readini($zone($1), info, GameDays)
    if (%number.of.gamedays = $null) { var %number.of.gamedays 1  }
    inc %number.of.gamedays 1
    writeini $zone($1) info GameDays %number.of.gamedays
    return
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gives HP back and 
; lowers hunger.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
game.tick {
  ; give some HP back to those who need it if hunger is above 10

  var %chat.gametick 1
  while ($chat(%chat.gametick) != $null) {  var %gametick.nick $chat(%chat.gametick) 

    ; If the person is not in battle, give back some HP

    if ($in.battle(%gametick.nick) = false) { 

      var %current.hp $current.hp(%gametick.nick)

      if ((%current.hp < $base.hp(%gametick.nick)) && ($current.hunger(%gametick.nick)  >= 10))  { 
        var %increase.hp $round($calc($base.hp(%gametick.nick) * .50),0)
        inc %current.hp %increase.hp
        if (%current.hp > $base.hp(%gametick.nick)) { var %current.hp $base.hp(%gametick.nick) }
        writeini $char(%gametick.nick) currentstats hp %current.hp 
      }

      ; lower hunger by 10
      var %current.hunger $current.hunger(%gametick.nick)
      dec %current.hunger 10
      if (%current.hunger < 0) { var %current.hunger 0 }
      writeini $char(%gametick.nick) currentstats hunger %current.hunger

      if (%current.hunger <= 10) { $dcc.private.message(%gametick.nick, $readini(translation.dat, system, starving))  }
    }

    inc %chat.gametick 1
  } 

}
