ScriptName Fragments:Perks:PRKF_CS7ShipFuelFillerButton_01000801 Extends Perk Const hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Quest Property CS7_ShipFuelFillerQuest Auto Const

;-- Functions ---------------------------------------

Function Fragment_Entry_02(ObjectReference akTargetRef, Actor akActor)
  cs7shipfuelfillerscript MyQuestScript = CS7_ShipFuelFillerQuest as cs7shipfuelfillerscript ; #DEBUG_LINE_NO:7
  MyQuestScript.PlayerRefuelShip(akTargetRef, akActor) ; #DEBUG_LINE_NO:8
EndFunction
