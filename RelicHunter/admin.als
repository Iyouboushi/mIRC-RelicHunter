buildplayerlist {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 
    if ($readini($char(%name), info, flag) != $null) { return }
    write $nick $+ _players.txt %name 
  }
}

buildzappedlist {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 

    write $nick $+ _zapped.txt %name - $asctime($file($1-).mtime,mm/dd/yyyy - hh:mm:ss tt) 
    write zapped.html  <td> %name </td>
    write zapped.html  <td> $asctime($file($1-).mtime,mm/dd/yyyy - hh:mm:ss tt) </td>
    write zapped.html  </tr>
  }
}

clean_mainfolder { 
  if ($2 = $null) {  .remove $1 }
  if ($2 != $null) { 
    set %clean.file $nopath($1-) 
    .remove %clean.file
    unset %clean.file
  }
}

teleport {


}
