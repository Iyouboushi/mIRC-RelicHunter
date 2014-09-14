;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ADMIN COMMANDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot Admins have  the ability to zap/erase characters.
on 50:TEXT:!zap *:*: {  $set_chr_name($2) | $checkchar($2) | $zap_char($2) | $display.system.message($readini(translation.dat, system, zappedcomplete),global) | halt }
ON 50:Chat:!zap*: { $set_chr_name($2) | $checkchar($2) | $zap_char($2) | $dcc.global.message($readini(translation.dat, system, zappedcomplete)) | halt }
on 50:TEXT:!unzap *:*: {  
  if ($isfile($zapped($2)) = $false) { $display.private.message(4Error: $2 does not exist as a zapped file) | halt }
  $unzap_char($2) | $display.system.message($readini(translation.dat, system, unzappedcomplete),global) |
  halt
}

; Force the bot to quit
on 50:TEXT:!quit*:*:{ /quit $game.version }

; Add or remove a bot admin (note: cannot remove the person in position 1 with this command)
on 50:TEXT:!bot admin*:*: {  
  if (($3 = $null) || ($3 = list)) { $bot.admin(list) }
  if ($3 = add) { $bot.admin(add, $4) }
  if ($3 = remove) { $bot.admin(remove, $4) }
}

; Cleans out the main folder of .txt, .lst, and .db files.
on 50:TEXT:!main folder cleanup:*:{ 
  .echo -q $findfile( $mircdir , *.lst, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir  , *.db, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir  , *.txt, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir , *.html, 0, 0, clean_mainfolder $1-) 
  $display.system.message(4.db & .lst & .txt & .html files have been cleaned up from the main bot folder.)
}



; Bot admin command for displaying active and zapped player lists.
on 50:TEXT:!display *:*:{  
  if (($2 = player) || ($2 = players)) { 
    ; create a temporary text file with all the active players
    .remove $nick $+ _players.txt
    .echo -q $findfile( $char_path , *.char, 0 , 0, buildplayerlist $1-)

    ; do a loop to show the text file to the bot admin
    var %number.of.entries $lines($nick $+ _players.txt)
    if (%number.of.entries = 0) { $display.private.message(4No players found) }
    else {
      $display.private.message(3Active Player List)

      var %entry.line 1
      while (%entry.line <= %number.of.entries) {
        $display.private.message.delay(2 $+ $read($nick $+ _players.txt, %entry.line))
        inc %entry.line 1
      }
    }

    ; erase the temporary text file
    .remove $nick $+ _players.txt
  }

  if ($2 = zapped) { 
    ; create a temporary text file with all the zapped players  
    .remove zapped.html
    .remove $nick $+ _zapped.txt

    write zapped.html <center><B> <font size=13> Zapped List</font> </B></center> <BR><BR> 
    write zapped.html <table border="1" bordercolor="#FFCC00" style="background-color:#FFFFCC" width="100%" cellpadding="3" cellspacing="3">
    write zapped.html  <tr>
    write zapped.html  <td><B>NAME</B></td>
    write zapped.html  <td><B>ZAPPED TIME</B></td>
    write zapped.html  </tr>

    write zapped.html  <tr>

    .echo -q $findfile( $zap_path , *.char, 0 , 0, buildzappedlist $1-)

    ; do a loop to show the text file to the bot admin
    var %number.of.entries $lines($nick $+ _zapped.txt)
    if (%number.of.entries = 0) { $display.private.message(4No zapped players found) }
    else {
      $display.private.message(3Zapped Player List - zapped time)

      var %entry.line 1
      while (%entry.line <= %number.of.entries) {
        var %delay.time %entry.line
        $display.private.message.delay.custom(2 $+ $read($nick $+ _zapped.txt, %entry.line), %delay.time)
        inc %entry.line 1
      }
    }

    ; erase the temporary text file
    .remove $nick $+ _zapped.txt
  }
}

ON 50:Chat:!teleport*: {
  ; $1 = zone number
  ; $2 = room number (in X:Y format)

  ; Check to see if zone exists.

  ; Check to see if room exists

  ; teleport the player to that location
} 
