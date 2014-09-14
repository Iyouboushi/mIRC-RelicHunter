;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SYSTEM CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
raw 421:*:echo -a 4,1Unknown Command: ( $+ $2 $+ ) | echo -a 4,1Location: %debug.location | halt
CTCP *:PING*:?:if ($nick == $me) haltdef
CTCP *:BOTVERSION*:ctcpreply $nick BOTVERSION $game.version
on 1:QUIT: { 
  if ($nick = %bot.name) { /nick %bot.name | /.timer 1 15 /identifytonickserv } 
  .auser 1 $nick | .flush 1 
} 
on 1:EXIT: {  .auser 1 $nick | .flush 1 }
on 1:PART:%battlechan:.auser 1 $nick | .flush 1
on 1:KICK:%battlechan:.auser 1 $knick | .flush 1 
on 1:JOIN:%battlechan:{  .auser 1 $nick | .flush 1 }
on 3:NICK: { .auser 1 $nick | mode %battlechan -v $newnick | .flush 1 }
on *:CTCPREPLY:PING*:if ($nick == $me) haltdef
on *:DNS: { 
  if ($isfile($char($nick)) = $true) { 
    var %lastip.address $iaddress
    if (%lastip.address != $null) { writeini $char($nick) info lastIP $iaddress }
  }
  set %ip.address. [ $+ [ $nick ] ] $iaddress
}

on 2:TEXT:!bot admin*:*: {  $bot.admin(list) }

alias bot.admin {
  if ($1 = list) { var %bot.admins $readini(system.dat, botinfo, bot.owner) 
    if (%bot.admins = $null) { $display.system.message(4There are no bot admins set., private) | halt }
    else {
      set %replacechar $chr(044) $chr(032)
      %bot.admins = $replace(%bot.admins, $chr(046), %replacechar)
      unset %replacechar
      $display.system.message(3Bot Admins:12 %bot.admins, private) | halt 
    }
  }

  if ($1 = add) { $checkchar($2) | var %bot.admins $readini(system.dat, botinfo, bot.owner) 
    if ($istok(%bot.admins,$2,46) = $true) { $display.system.message(4Error: $2 is already a bot admin, private) | halt }
    %bot.admins = $addtok(%bot.admins,$2,46) | $display.system.message(3 $+ $2 has been added as a bot admin., private) 
    writeini system.dat botinfo bot.owner %bot.admins | halt 
  }

  if ($1 = remove) { var %bot.admins $readini(system.dat, botinfo, bot.owner) 
    if ($istok(%bot.admins,$2,46) = $false) { $display.system.message(4Error: $2 is not a bot admin, private) | halt }

    ; The bot admin in the first position is considered to be the "bot owner" and cannot be removed via this command.
    var %bot.owner $gettok(%bot.admins,1,46)
    if ($2 = %bot.owner) { $display.system.message(4Error: $2 cannot be removed from the bot admin list using this command, private) | halt }

    %bot.admins = $remtok(%bot.admins,$2,46) | $display.system.message(3 $+ $2 has been removed as a bot admin., private) 
    writeini system.dat botinfo bot.owner %bot.admins | halt 
  }
}

on 1:START: {
  echo 12*** Welcome to Relic Hunter Bot version $game.version written by James "Iyouboushi" *** 

  /.titlebar Relic Hunter version $game.version written by James  "Iyouboushi" 

  if (%first.run = false) { 
    set %bot.owner $readini(system.dat, botinfo, bot.owner) 
    if (%bot.owner = $null) { echo 4*** WARNING: There is no bot admin set.  Please fix this now. 
    set %bot.owner $?="Please enter the bot admin's IRC nick" |  writeini system.dat botinfo bot.owner %bot.owner }
    else { echo 12*** The bot admin list is currently set to:4 %bot.owner 12***  |  

      var %value 1 | var %number.of.owners $numtok(%bot.owner, 46)
      while (%value <= %number.of.owners) {
        set %name.of.owner $gettok(%bot.owner,%value,46)
        .auser 50 %name.of.owner
        inc %value 1
      }
      unset %name.of.owner
    }

    set %battlechan $readini(system.dat, botinfo, questchan) 
    if (%battlechan = $null) { echo 4*** WARNING: There is no game channel set.  Please fix this now. 
    set %battlechan $?="Please enter the IRC channel you're using (include the #)" |  writeini system.dat botinfo questchan %battlechan }
    else { echo 12*** The battle channel is currently set to:4 %battlechan 12*** }

    set %bot.name $readini(system.dat, botinfo, botname)
    if (%bot.name = $null) { echo 4*** WARNING: The bot's nick is not set in the system file.  Please fix this now.
    set %bot.name $?="Please enter the nick you wish the bot to use" | writeini system.dat botinfo botname %bot.name | /nick %bot.name }
    else { /nick %bot.name } 

    var %botpass $readini(system.dat, botinfo, botpass)
    if (%botpass = $null) { 
      echo 12*** Now please set the password you plan to register the bot with
      var %botpass $?="Enter a password that you will use for the bot on Nickserv"
      if (%botpass = $null) { var %bosspass none }
      writeini system.dat botinfo botpass %botpass
      echo 12*** OK.  Your password has been set to4 %botpass  -- Don't forget to register the bot with nickserv.
    }

    $system_defaults_check
  }

  if ((%first.run = true) || (%first.run = $null)) { 
    echo 12*** It seems this is the first time you've ever run the Relic Hunter Game Bot!  The bot will now attempt to help you get things set up.
    echo 12*** Please set your bot's nick/name now.   Normal IRC nick rules apply (no spaces, for example) 
    set %bot.name $?="Please enter the nick you wish the bot to use"
    writeini system.dat botinfo botname %bot.name | /nick %bot.name
    echo 12*** Great.  The bot's nick is now set to4 %bot.name

    echo 12*** Please set a bot owner now.  
    set %bot.owner $?="Please enter the bot owner's IRC nick"
    writeini system.dat botinfo bot.owner %bot.owner
    echo 12*** Great.  The bot owner has been set to4 %bot.owner

    echo 12*** Now please set the IRC channel you plan to use the bot in
    set %battlechan $?="Enter an IRC channel (include the #)"
    writeini system.dat botinfo questchan %battlechan
    echo 12*** The battles will now take place in4 %battlechan

    echo 12*** Now please set the password you plan to register the bot with
    var %botpass $?="Enter a password"
    if (%botpass = $null) { var %bosspass none }
    writeini system.dat botinfo botpass %botpass
    echo 12*** OK.  Your password has been set to4 %botpass  -- Don't forget to register the bot with nickserv.

    set %first.run false
    .auser 50 %bot.owner

    $system_defaults_check

  }

  echo 12*** This bot is best used with mIRC version4 6.3 12 *** 
  echo 12*** You are currently using mIRC version4 $version 12 ***

  if ($version < 6.3) {   echo 4*** Your version is older than the recommended version for this bot. Some things may not work right.  It is recommended you update. 12 *** }
  if ($version > 6.3) {   echo 4*** Your version is newer than the recommended version for this bot. While it should work, it is currently untested and may have quirks or bugs.  It is recommended you downgrade if you run into any problems. 12 *** }

}

on 1:CONNECT: {
  ; Start a keep alive timer.
  /.timerKeepAlive 0 300 /.ctcp $!me PING 

  ; Join the channel
  /join %battlechan

  ; Get rid of a ghost, if necessary, and send password
  var %bot.pass $readini(system.dat, botinfo, botpass)
  if ($me != %bot.name) { /.msg NickServ GHOST %bot.name %bot.pass | /nick %bot.name } 
  $identifytonickserv

  $start.game.pulse
}
