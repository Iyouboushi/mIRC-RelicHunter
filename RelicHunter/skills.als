;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SKILL ALIASES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds & displays the skill list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

skills.list {
  ; Build the skill list.

  $passive.skills.list($1)

  if (%passive.skills.list != $null) { 
    $dcc.private.message($nick, $readini(translation.dat, system, ViewPassiveSkills))
    if (%passive.skills.list2 != $null) { $dcc.private.message($nick, 3 $+ %passive.skills.list2) }
  }

  $active.skills.list($1)

  if (%active.skills.list != $null) { 
    $dcc.private.message($nick, $readini(translation.dat, system, ViewActiveSkills))
    if (%active.skills.list2 != $null) { $dcc.private.message($nick, 3 $+ %active.skills.list2) }
  }

  set %resists.skills.list $resists.skills.list($1) 
  if (%resists.skills.list != $null) {  $dcc.private.message($nick, $readini(translation.dat, system, ViewResistanceSkills))  }


  set %killer.skills.list $killer.skills.list($1)
  if (%killer.skills.list != $null) { $dcc.private.message($nick, $readini(translation.dat, system, ViewKillerTraitSkills))  }

  if ((((%passive.skills.list = $null) && (%active.skills.list = $null) && (%killer.skills.list = $null) && (%resists.skills.list = $null)))) { 
    $dcc.private.message($nick, $readini(translation.dat, system, HaveNoSkills)) 
  }


  unset %total.skills | unset %skill.name | unset %skill_level | unset %replacechar | unset %active.skills.list | unset %active.skills.list2
  unset %passive.skills.list | unset %passive.skills.list2 | unset %resists.skills.list | unset %killer.skills.list
}

passive.skills.list { 
  ; CHECKING PASSIVE SKILLS
  unset %passive.skills.list | unset %passive.skills.list2 | unset %total.skills
  var %skills.lines $lines($lstfile(skills_passive.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_passive.lst)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      inc %total.skills 1
      if (%total.skills > 13) {  %passive.skills.list2 = $addtok(%passive.skills.list2,%skill_to_add,46) }
      else {  %passive.skills.list = $addtok(%passive.skills.list,%skill_to_add,46) }
    }
    inc %value 1
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %passive.skills.list) { set %replacechar $chr(044) $chr(032)
    %passive.skills.list = $replace(%passive.skills.list, $chr(046), %replacechar)
  }
  if ($chr(046) isin %passive.skills.list2) { set %replacechar $chr(044) $chr(032)
    %passive.skills.list2 = $replace(%passive.skills.list2, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value 
}

active.skills.list {
  ; CHECKING ACTIVE SKILLS
  unset %active.skills.list | unset %active.skills.list2 | unset %total.skills
  var %skills.lines $lines($lstfile(skills_active.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_active.lst)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      inc %total.skills 1
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      if (%total.skills > 13) { %active.skills.list2 = $addtok(%active.skills.list2,%skill_to_add,46) }
      else { %active.skills.list = $addtok(%active.skills.list,%skill_to_add,46) }
    }
    inc %value 1 
  }

  var %active.skills $readini($dbfile(skills.db), Skills, activeSkills2)
  var %number.of.skills $numtok(%active.skills, 46)
  var %value 1
  while (%value <= %number.of.skills) {
    set %skill.name $gettok(%active.skills, %value, 46)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      inc %total.skills 1
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      if (%total.skills > 13) { %active.skills.list2 = $addtok(%active.skills.list2,%skill_to_add,46) }
      else { %active.skills.list = $addtok(%active.skills.list,%skill_to_add,46) }
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  if ($chr(046) isin %active.skills.list) { set %replacechar $chr(044) $chr(032)
    %active.skills.list = $replace(%active.skills.list, $chr(046), %replacechar)
  }
  if ($chr(046) isin %active.skills.list2) { set %replacechar $chr(044) $chr(032)
    %active.skills.list2 = $replace(%active.skills.list2, $chr(046), %replacechar)
  }

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
}

resists.skills.list { 
  ; CHECKING RESISTANCE SKILLS
  unset %resists.skills.list
  var %skills.lines $lines($lstfile(skills_resists.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_resists.lst)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      %resists.skills.list = $addtok(%resists.skills.list,%skill_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %resists.skills.list = $replace(%resists.skills.list, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return %resists.skills.list
}

killer.skills.list { 
  ; CHECKING KILLER SKILLS
  unset %killer.skills.list

  var %skills.lines $lines($lstfile(skills_killertraits.lst))

  var %value 1
  while (%value <= %skills.lines) {
    set %skill.name $read -l $+ %value $lstfile(skills_killertraits.lst)
    set %skill_level $readini($char($1), skills, %skill.name)

    if ((%skill_level != $null) && (%skill_level >= 1)) { 
      ; add the skill level to the skill list
      var %skill_to_add %skill.name $+ $chr(040) $+ %skill_level $+ $chr(041) 
      %killer.skills.list = $addtok(%killer.skills.list,%skill_to_add,46)
    }
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %killer.skills.list = $replace(%killer.skills.list, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value
  return %killer.skills.list
}
