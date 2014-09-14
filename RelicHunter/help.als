gamehelp { 
  set %help.topics $readini %help_folder $+ topics.help Help List | set %help.topics2 $readini %help_folder $+ topics.help Help List2 | set %help.topics3 $readini %help_folder $+ topics.help Help List3
  if ($1 = $null) { $display.private.message2($2, 14::[Current Help Topics]::) |  $display.private.message2($2,2 $+ %help.topics) | $display.private.message2($2,2 $+ %help.topics2) | unset %help.topics | unset %help.topics2 | $display.private.message2($2, 14::[Type !help <topic> (without the <>) to view the topic]::) | halt }
  if ($1 isin %help.topics) || ($1 isin %help.topics2) || ($1 isin %help.topics3) {  set %topic %help_folder $+ $1 $+ .help |  set %lines $lines(%topic) | set %l 0 | goto help }
  else { $display.private.message2($2, 3The Librarian searchs through the ancient texts but returns with no results for your inquery!  Please try again) | halt }
  :help
  if (%l <= %lines) {  
    $display.private.message($read(%topic, %l)) 
    inc %l 1
  }
  unset %topic | unset %help.topics | unset %help.topics2 | unset %lines | unset %l | unset %help
}
