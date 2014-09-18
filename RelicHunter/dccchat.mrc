;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GENERAL DCC CHAT 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enter the DCC chat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:open:=: {
  var %p 1 
  var %where.zonenumber $readini($char($nick), location, zone)
  var %where $readini($zone(%where.zonenumber), info, name)
  $set_chr_name($nick)

  while ($chat(%p) != $null) { 
    if ($chat(%p) == $nick) { inc %p 1 }
    else {  msg = $+ $chat(%p) 14###4 $nick has entered the universe on planet %where $+ . | inc %p 1 }
  }

  $dcc.who'sonline($nick)


  if ($readini($char($nick), currentStats, InBattle) = false) { $look.room($nick) }
  else { 
    ; Resume battle
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DCC chat, check for log in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.check.for.double.login {
  var %double.check 1
  while ($chat(%double.check) != $null) {
    if ($chat(%double.check) = $1) { .msg $nick 4You are already logged into the game elsewhere! | set %dcc.alreadyloggedin true }
    inc %double.check
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display who's online
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.who'sonline {
  var %who.online 1
  $dcc.private.message($1, 3Who's Online)
  while ($chat(%who.online) != $null) {
    var %online.location.zonenumber $readini($char($chat(%who.online)), location, zone)
    var %online.location $readini($zone(%online.location.zonenumber), info, name)
    var %online.name 7[ $+ %online.location $+ ] 2 $+ $chat(%who.online)
    $dcc.private.message($1, %online.name)
    inc %who.online 1
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Leave the DCC chat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:close:=: { var %p 1
  while ($chat(%p) != $null) { 
    if ($chat(%p) == $nick) { inc %p 1 }
    else {  msg = $+ $chat(%p) 14###4 $nick has left the game. | inc %p 1 }
  }
  close -c $nick
  .auser 1 $nick | mode %battlechan -v $nick | .flush 1
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a System Message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.global.message {
  var %p 1
  while ($chat(%p) != $null) {  var %nick $chat(%p) | var %system.message $1
    msg = $+ $chat(%p) %system.message 
    inc %p 1 
  } 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display the status effects
; during battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.status.messages {
  ; $1 = the text file to read

  var %total.lines $lines($1)
  var %current.status.line 1
  while (%current.status.line <= %total.lines) {
    $dcc.battle.message($read($1, %current.status.line))
    inc %current.status.line
  }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a message to
; a single person
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.private.message {
  ; $1 = person
  ; $2 = message
  var %p 1
  while ($chat(%p) != $null) {  var %nick $chat(%p)
    if ($chat(%p) = $1) { msg = $+ $chat(%p) $2 }
    inc %p 1 
  } 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a message to
; everyone in a zone
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias dcc.zone.message {
  ; $1 = zone
  ; $2 = message
  ; $3 = special flag

  var %zp 1
  while ($chat(%zp) != $null) {
    var %nick $chat(%zp)

    if ((($3 = weather) || ($3 = moon) || ($3 = time))) { 
      var %inside.zone $get.zone(%nick) | var %inside.room $get.room(%nick)
      if ($readini($zone(%inside.zone), %inside.room, inside) != true) { 
        if (%inside.zone = $1) { 
          if ($player.settings.flag(%zp, ShowWeather) = true) { msg = $+ $chat(%zp) $2 }
        }
      }
    } 
    else { 
      if ($readini($char(%nick), location, zone) = $1) { msg = $+ $chat(%zp) $2 }
    }
    inc %zp
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; For normal actions let's
; do the command emote 
; instead.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:emote *: { $dcc.emote($nick, $2-) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; speaking commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:Chat:say *: { $say($nick,$2-) }
on 2:Chat:shout *: {  $shout($nick,$2-) }
on 2:Chat:global *: {  $global($nick,$2-) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This isn't working quite right
; in version 6.3 but will
; leave it up for now.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:CHAT:*:{ unset %^p
  if ($1 = ACTION) { $dcc.emote($nick, $2-) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aliases for the speaking
; commands.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias say {
  ; $1 = person talking 
  ; $2 = message

  var %user.location $get.zone.and.room($1)
  var %chat.p 1
  while ($chat(%chat.p) != $null) {  var %nick $chat(%chat.p) 

    if (%nick != $1) {
      var %target.location $get.zone.and.room(%nick)
      if (%target.location = %user.location) { msg = $+ $chat(%chat.p) 4< $+ $1 $+ > 12 $+ $2- }
    }
    inc %chat.p 1
  } 
}

alias shout {
  ; $1 = person talking 
  ; $2 = message
  var %user.location $get.zone($1)
  var %shout.chat.p 1
  while ($chat(%shout.chat.p) != $null) {  var %nick $chat(%shout.chat.p) 
    if (%nick != $1) {
      var %target.location $get.zone(%nick)
      if (%target.location = %user.location) { msg = $+ $chat(%shout.chat.p) 4[Zone] < $+ $1 $+ > 12 $+ $2- }
    }
    inc %shout.chat.p 1
  } 
}

alias global {
  ; $1 = person talking 
  ; $2 = message

  var %user.location $get.zone($1)
  var %chat.p 1
  while ($chat(%chat.p) != $null) {  var %nick $chat(%chat.p) 
    if (%nick != $1) { msg = $+ $chat(%chat.p) 4[ $+ Global $+ $chr(93) < $+ $1 $+ > 12 $+ $2-   }
    inc %chat.p 1
  } 
}

alias dcc.emote {
  ; $1 = person talking 
  ; $2 = message
  var %user.location $readini($char($1), Location, Zone) $+ : $+ $readini($char($1), Location, Room)
  var %chat.p 1
  while ($chat(%chat.p) != $null) {  var %nick $chat(%chat.p) 
    if (%nick != $nick) { 
      var %target.location $readini($char(%nick), Location, Zone) $+ : $+ $readini($char(%nick), Location, Room)
      if (%target.location = %user.location) { msg = $+ $chat(%chat.p) 13*7 $nick 12 $+ $2- $+ 13 * }
    }
    inc %chat.p 1
  } 
}
