ScriptName CS7ShipFuelFillerScript Extends Quest

;-- Variables ---------------------------------------
ObjectReference[] He3Containers
Int ModStartTimer = 20
Bool NoIdleA
ObjectReference OutpostBeacon
Int ShipExitTimer = 10
Bool bAddPerk
Bool bDockingLink
Bool bHe3OutpostLink
Bool bModEnabled
Bool bShipTakeOffEvent
spaceshipreference otherShipRef
spaceshipreference playerShipRef

;-- Properties --------------------------------------
sq_playershipscript Property SQ_PlayerShip Auto Const mandatory
dialogueshipservicesscript Property DialogueShipServices Auto Const mandatory
ActorValue Property SpaceshipGravJumpFuel Auto mandatory
ActorValue Property OutpostBuildAreaRadius Auto mandatory
ActorValue Property PlayerUnityTimesEntered Auto mandatory
Activator Property OutpostBeaconActivator Auto mandatory
FormList Property CS7OutpostHe3ContainerList Auto
GlobalVariable Property CS7_ModEnabled Auto
Keyword Property CannotBeHomeShip Auto Const mandatory
Keyword Property IsStarstation Auto Const mandatory
Keyword Property LocTypeOutpost Auto Const mandatory
Message Property CS7_RefuelMessage Auto
Message Property CS7_BordingMessage Auto
Message Property CS7_LockMessage Auto
Message Property CS7_OutpostMessage Auto
MiscObject Property InorgCommonHelium3 Auto
Perk Property CS7ShipFuelFillerButtonPerk Auto Const mandatory
Quest Property MQ101 Auto Const mandatory

;-- Functions ---------------------------------------

Event OnQuestInit()
  Self.RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame") ; #DEBUG_LINE_NO:37
  Self.RegisterForRemoteEvent(Game.GetPlayer(), "OnLocationChange") ; #DEBUG_LINE_NO:38
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip, "OnShipDock") ; #DEBUG_LINE_NO:39
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip, "OnShipUndock") ; #DEBUG_LINE_NO:40
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip, "OnShipLanding") ; #DEBUG_LINE_NO:41
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip, "OnShipTakeOff") ; #DEBUG_LINE_NO:42
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip, "OnLocationChange") ; #DEBUG_LINE_NO:43
  bModEnabled = False ; #DEBUG_LINE_NO:44
  bAddPerk = False ; #DEBUG_LINE_NO:45
  Self.StartTimer(1.0, ModStartTimer) ; #DEBUG_LINE_NO:46
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
  Self.AddFuelFillerPerk() ; #DEBUG_LINE_NO:51
  If Game.IsPluginInstalled("SpaceShipFuelMod.esm") == False ; #DEBUG_LINE_NO:53
    Self.UnregisterForAllRemoteEvents() ; #DEBUG_LINE_NO:54
    Self.RemoveFuelFillerPerk() ; #DEBUG_LINE_NO:55
    Self.CancelTimer(ShipExitTimer) ; #DEBUG_LINE_NO:56
    Self.Stop() ; #DEBUG_LINE_NO:57
  EndIf
EndEvent

Event OnTimer(Int aiTimerID)
  If aiTimerID == ShipExitTimer ; #DEBUG_LINE_NO:63
    Self.UnregisterForRemoteEvent(Game.GetPlayer() , "OnExitShipInterior") ; #DEBUG_LINE_NO:64
    CS7_LockMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:65
  EndIf
  If aiTimerID == ModStartTimer ; #DEBUG_LINE_NO:67
    If MQ101.IsStageDone(1305) || MQ101.IsStageDone(1310) || Game.GetPlayer().GetValueInt(PlayerUnityTimesEntered) > 0 ; #DEBUG_LINE_NO:69
      bAddPerk = True ; #DEBUG_LINE_NO:70
      Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:71
      Self.AddFuelFillerPerk() ; #DEBUG_LINE_NO:72
    Else
      Self.StartTimer(20.0, ModStartTimer) ; #DEBUG_LINE_NO:74
    EndIf
  EndIf
EndEvent

Event Actor.OnExitShipInterior(Actor akSender, ObjectReference akShip)
  Self.CancelTimer(ShipExitTimer) ; #DEBUG_LINE_NO:81
  Self.UnregisterForRemoteEvent(Game.GetPlayer() , "OnExitShipInterior") ; #DEBUG_LINE_NO:82
  playerShipRef = SQ_PlayerShip.PlayerShip.GetShipRef() ; #DEBUG_LINE_NO:83
  If playerShipRef ; #DEBUG_LINE_NO:84
    Float fShipFuelTankCapacity = playerShipRef.GetBaseValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:85
    Float fShipFuelTankCurrent = playerShipRef.GetValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:86
    If bHe3OutpostLink || Self.GetHe3OutpostLinkFromLandingReference(Game.GetPlayer() as ObjectReference) == True ; #DEBUG_LINE_NO:88
      Int iButton = CS7_OutpostMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:89
      If iButton == 0 ; #DEBUG_LINE_NO:90
        Self.He3OutpostAutoRefuelShip(fShipFuelTankCurrent, fShipFuelTankCapacity) ; #DEBUG_LINE_NO:91
      ElseIf iButton == 1 && Game.GetPlayer().Is3Dloaded() && akShip.Is3Dloaded() && (akShip.GetDistance(Game.GetPlayer() as ObjectReference) < 80 as Float) ; #DEBUG_LINE_NO:92
        Self.ManuallyRefuelShip(fShipFuelTankCurrent, fShipFuelTankCapacity) ; #DEBUG_LINE_NO:93
      EndIf
    ElseIf Game.GetPlayer().Is3Dloaded() && akShip.Is3Dloaded() && (akShip.GetDistance(Game.GetPlayer() as ObjectReference) < 80 as Float) ; #DEBUG_LINE_NO:97
      Self.ManuallyRefuelShip(fShipFuelTankCurrent, fShipFuelTankCapacity) ; #DEBUG_LINE_NO:98
    EndIf
  EndIf
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
  If akNewLoc.HasKeyword(LocTypeOutpost) && !bHe3OutpostLink ; #DEBUG_LINE_NO:106
    Self.GetHe3OutpostLinkFromLandingReference(Game.GetPlayer() as ObjectReference) ; #DEBUG_LINE_NO:107
  EndIf
  If bDockingLink && Game.GetPlayer().Is3Dloaded() ; #DEBUG_LINE_NO:110
    Float fShipFuelTankCapacity = playerShipRef.GetBaseValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:111
    Float fShipFuelTankCurrent = playerShipRef.GetValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:112
    Float fuelAvailable = otherShipRef.GetValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:113
    If (fuelAvailable > 0 as Float) && fShipFuelTankCapacity > fShipFuelTankCurrent ; #DEBUG_LINE_NO:114
      Utility.Wait(3.0) ; #DEBUG_LINE_NO:115
      If CS7_BordingMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) == 0 ; #DEBUG_LINE_NO:116
        Float fuelMax = fShipFuelTankCapacity - fShipFuelTankCurrent ; #DEBUG_LINE_NO:118
        Float fuelAmount = Math.Min(fuelMax, fuelAvailable) ; #DEBUG_LINE_NO:119
        playerShipRef.RestoreValue(SpaceshipGravJumpFuel, fuelAmount) ; #DEBUG_LINE_NO:120
        otherShipRef.DamageValue(SpaceshipGravJumpFuel, fuelAmount) ; #DEBUG_LINE_NO:121
        DialogueShipServices.UpdateFuelGlobals() ; #DEBUG_LINE_NO:122
        fShipFuelTankCurrent += fuelAmount ; #DEBUG_LINE_NO:123
        Utility.Wait(1.0) ; #DEBUG_LINE_NO:125
        Self.FuelGaugeMessage(fShipFuelTankCurrent, fShipFuelTankCapacity, 0) ; #DEBUG_LINE_NO:126
      EndIf
    EndIf
    bDockingLink = False ; #DEBUG_LINE_NO:129
  EndIf
EndEvent

Event ReferenceAlias.OnLocationChange(ReferenceAlias akSender, Location akOldLoc, Location akNewLoc)
  If akSender == SQ_PlayerShip.PlayerShip && akOldLoc != akNewLoc ; #DEBUG_LINE_NO:135
    If SQ_PlayerShip.PlayerShip.GetShipRef().IsInSpace() ; #DEBUG_LINE_NO:136
      If bHe3OutpostLink ; #DEBUG_LINE_NO:137
        Self.UnregisterOutpostLink() ; #DEBUG_LINE_NO:138
      EndIf
    ElseIf akNewLoc.HasKeyword(LocTypeOutpost) && !bHe3OutpostLink ; #DEBUG_LINE_NO:140
      playerShipRef = SQ_PlayerShip.PlayerShip.GetShipRef() ; #DEBUG_LINE_NO:141
      ObjectReference landingMarker = playerShipRef.GetLinkedRef(SQ_PlayerShip.LandingMarkerKeyword) ; #DEBUG_LINE_NO:142
      Self.GetHe3OutpostLinkFromLandingReference(landingMarker) ; #DEBUG_LINE_NO:143
    EndIf
  EndIf
EndEvent

Event ReferenceAlias.OnShipDock(ReferenceAlias akSource, Bool abComplete, spaceshipreference akDocking, spaceshipreference akParent)
  If abComplete == False ; #DEBUG_LINE_NO:150
    playerShipRef = SQ_PlayerShip.PlayerShip.GetShipRef() ; #DEBUG_LINE_NO:151
    otherShipRef = None ; #DEBUG_LINE_NO:152
    If playerShipRef == akDocking ; #DEBUG_LINE_NO:153
      otherShipRef = akParent ; #DEBUG_LINE_NO:154
    Else
      otherShipRef = akDocking ; #DEBUG_LINE_NO:156
    EndIf
    If (otherShipRef as Bool && !otherShipRef.HasKeyword(IsStarstation)) && !otherShipRef.HasKeyword(CannotBeHomeShip) ; #DEBUG_LINE_NO:158
      If SQ_PlayerShip.PlayerShips.Find(otherShipRef as ObjectReference) == -1 ; #DEBUG_LINE_NO:159
        bDockingLink = True ; #DEBUG_LINE_NO:160
      EndIf
    EndIf
  EndIf
EndEvent

Event ReferenceAlias.OnShipUndock(ReferenceAlias akSource, Bool abComplete, spaceshipreference akUndocking, spaceshipreference akParent)
  If abComplete && bDockingLink ; #DEBUG_LINE_NO:168
    bDockingLink = False ; #DEBUG_LINE_NO:169
  EndIf
EndEvent

Event ReferenceAlias.OnShipLanding(ReferenceAlias akSender, Bool abComplete)
  If abComplete && !bHe3OutpostLink ; #DEBUG_LINE_NO:175
    playerShipRef = SQ_PlayerShip.PlayerShip.GetShipRef() ; #DEBUG_LINE_NO:176
    ObjectReference landingMarker = playerShipRef.GetLinkedRef(SQ_PlayerShip.LandingMarkerKeyword) ; #DEBUG_LINE_NO:177
    Self.GetHe3OutpostLinkFromLandingReference(landingMarker) ; #DEBUG_LINE_NO:178
  EndIf
EndEvent

Event ReferenceAlias.OnShipTakeoff(ReferenceAlias akSender, Bool abComplete)
  If !abComplete && bHe3OutpostLink ; #DEBUG_LINE_NO:184
    Self.UnregisterOutpostLink() ; #DEBUG_LINE_NO:185
  EndIf
EndEvent

Event ObjectReference.OnWorkshopMode(ObjectReference akSender, Bool aStart)
  If aStart ; #DEBUG_LINE_NO:191
    bHe3OutpostLink = False ; #DEBUG_LINE_NO:192
  Else
    Self.GetHe3OutpostLinkFromLandingReference(Game.GetPlayer() as ObjectReference) ; #DEBUG_LINE_NO:194
  EndIf
EndEvent

Function UnregisterOutpostLink()
  bHe3OutpostLink = False ; #DEBUG_LINE_NO:200
  Self.UnregisterForRemoteEvent(OutpostBeacon , "OnWorkshopMode") ; #DEBUG_LINE_NO:201
  Self.UnregisterForRemoteEvent(Game.GetPlayer() , "OnExitShipInterior") ; #DEBUG_LINE_NO:202
  Self.CancelTimer(ShipExitTimer) ; #DEBUG_LINE_NO:203
EndFunction

Function AddFuelFillerPerk()
  Actor PlayerRef = Game.GetPlayer() ; #DEBUG_LINE_NO:208
  If !PlayerRef.HasPerk(CS7ShipFuelFillerButtonPerk) && bAddPerk ; #DEBUG_LINE_NO:209
    PlayerRef.AddPerk(CS7ShipFuelFillerButtonPerk, False) ; #DEBUG_LINE_NO:210
  EndIf
EndFunction

Function RemoveFuelFillerPerk()
  Actor PlayerRef = Game.GetPlayer() ; #DEBUG_LINE_NO:216
  If PlayerRef.HasPerk(CS7ShipFuelFillerButtonPerk) ; #DEBUG_LINE_NO:217
    PlayerRef.RemovePerk(CS7ShipFuelFillerButtonPerk) ; #DEBUG_LINE_NO:218
  EndIf
EndFunction

Function PlayerRefuelShip(ObjectReference akTargetRef, Actor akActor)
  If !NoIdleA ; #DEBUG_LINE_NO:225
    NoIdleA = True ; #DEBUG_LINE_NO:226
    Int iOpen = 0 ; #DEBUG_LINE_NO:228
    playerShipRef = SQ_PlayerShip.PlayerShip.GetShipRef() ; #DEBUG_LINE_NO:229
    If playerShipRef ; #DEBUG_LINE_NO:230
      Float fShipFuelTankCapacity = playerShipRef.GetBaseValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:231
      Float fShipFuelTankCurrent = playerShipRef.GetValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:232
      bModEnabled = CS7_ModEnabled.GetValue() as Bool ; #DEBUG_LINE_NO:233
      If bModEnabled == False ; #DEBUG_LINE_NO:234
        CS7_ModEnabled.SetValue(1.0) ; #DEBUG_LINE_NO:235
        Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:236
        iOpen = 5 ; #DEBUG_LINE_NO:237
      ElseIf playerShipRef.IsInSpace() == False ; #DEBUG_LINE_NO:238
        Self.RegisterForRemoteEvent(Game.GetPlayer() , "OnExitShipInterior") ; #DEBUG_LINE_NO:239
        Self.StartTimer(120.0, ShipExitTimer) ; #DEBUG_LINE_NO:240
        If bHe3OutpostLink ; #DEBUG_LINE_NO:241
          iOpen = 3 ; #DEBUG_LINE_NO:242
        Else
          iOpen = 1 ; #DEBUG_LINE_NO:244
        EndIf
      ElseIf bDockingLink
        iOpen = 2 ; #DEBUG_LINE_NO:247
      EndIf
      Self.FuelGaugeMessage(fShipFuelTankCurrent, fShipFuelTankCapacity, iOpen) ; #DEBUG_LINE_NO:249
    EndIf
    NoIdleA = False ; #DEBUG_LINE_NO:252
  EndIf
EndFunction

Function FuelGaugeMessage(Float fShipFuelTankCurrent, Float fShipFuelTankCapacity, Int iOpen)
  Math.Round(fShipFuelTankCurrent) ; #DEBUG_LINE_NO:258
  If iOpen == 1 ; #DEBUG_LINE_NO:259
    Debug.Notification("Fuel tanks unlocked.") ; #DEBUG_LINE_NO:260
  ElseIf iOpen == 2 ; #DEBUG_LINE_NO:261
    Debug.Notification("Refueling coupling locked.") ; #DEBUG_LINE_NO:262
  ElseIf iOpen == 3 ; #DEBUG_LINE_NO:263
    Debug.Notification("Exit ship for refueling.") ; #DEBUG_LINE_NO:264
  ElseIf iOpen == 4 ; #DEBUG_LINE_NO:265
    Debug.Notification("Refueling completed.") ; #DEBUG_LINE_NO:266
  ElseIf iOpen == 5 ; #DEBUG_LINE_NO:267
    Debug.Notification("This is the ship's fuel gauge.") ; #DEBUG_LINE_NO:268
  EndIf
  Debug.Notification((("FUEL [ " + Math.Round(fShipFuelTankCurrent) as String) + " / " + (fShipFuelTankCapacity as Int) as String) + " ]") ; #DEBUG_LINE_NO:270
EndFunction

Bool Function GetHe3OutpostLinkFromLandingReference(ObjectReference theReference)
  bHe3OutpostLink = False ; #DEBUG_LINE_NO:275
  OutpostBeacon = None ; #DEBUG_LINE_NO:276
  If theReference ; #DEBUG_LINE_NO:277
    ObjectReference[] OutpostBeaconsArray = theReference.FindAllReferencesOfType(OutpostBeaconActivator as Form, 400 as Float) ; #DEBUG_LINE_NO:278
    If OutpostBeaconsArray.Length == 1 && OutpostBeaconsArray[0].GetCurrentLocation().HasKeyword(LocTypeOutpost) ; #DEBUG_LINE_NO:279
      OutpostBeacon = OutpostBeaconsArray[0] ; #DEBUG_LINE_NO:280
      Float He3SearchRadius = OutpostBeacon.GetValue(OutpostBuildAreaRadius) ; #DEBUG_LINE_NO:282
      He3Containers = OutpostBeacon.FindAllReferencesOfType(CS7OutpostHe3ContainerList as Form, He3SearchRadius) ; #DEBUG_LINE_NO:283
      If He3Containers.Length > 0 ; #DEBUG_LINE_NO:284
        bHe3OutpostLink = True ; #DEBUG_LINE_NO:285
        Self.RegisterForRemoteEvent(OutpostBeacon , "OnWorkshopMode") ; #DEBUG_LINE_NO:286
      EndIf
    EndIf
  EndIf
  Return bHe3OutpostLink ; #DEBUG_LINE_NO:290
EndFunction

Function He3OutpostAutoRefuelShip(Float shipFuelCurrent, Float shipFuelCapacity)
  Float fuelAvailable = 0 as Float ; #DEBUG_LINE_NO:295
  Int He3Count = 0 ; #DEBUG_LINE_NO:296
  Int I = 0 ; #DEBUG_LINE_NO:297
  While I < He3Containers.Length ; #DEBUG_LINE_NO:298
    He3Count = He3Containers[I].GetItemCount(InorgCommonHelium3 as Form) ; #DEBUG_LINE_NO:299
    fuelAvailable += He3Count as Float * 0.5 ; #DEBUG_LINE_NO:300
    I += 1 ; #DEBUG_LINE_NO:301
  EndWhile
  If fuelAvailable > 0 as Float ; #DEBUG_LINE_NO:304
    Float fuelMax = shipFuelCapacity - shipFuelCurrent ; #DEBUG_LINE_NO:305
    Float fuelAmount = Math.Min(fuelMax, fuelAvailable) ; #DEBUG_LINE_NO:306
    playerShipRef.RestoreValue(SpaceshipGravJumpFuel, fuelAmount) ; #DEBUG_LINE_NO:307
    DialogueShipServices.UpdateFuelGlobals() ; #DEBUG_LINE_NO:308
    shipFuelCurrent += fuelAmount ; #DEBUG_LINE_NO:309
    Float fuelToHe3Items = Math.Floor(fuelAmount * 2 as Float) as Float ; #DEBUG_LINE_NO:311
    Float subtractor = 0 as Float ; #DEBUG_LINE_NO:312
    I = 0 ; #DEBUG_LINE_NO:313
    While I < He3Containers.Length && (fuelToHe3Items > 0 as Float) ; #DEBUG_LINE_NO:314
      He3Count = He3Containers[I].GetItemCount(InorgCommonHelium3 as Form) ; #DEBUG_LINE_NO:315
      subtractor = Math.Min(He3Count as Float, fuelToHe3Items) ; #DEBUG_LINE_NO:316
      He3Containers[I].RemoveItem(InorgCommonHelium3 as Form, subtractor as Int, True, None) ; #DEBUG_LINE_NO:317
      fuelToHe3Items -= subtractor ; #DEBUG_LINE_NO:318
      I += 1 ; #DEBUG_LINE_NO:319
    EndWhile
    Utility.Wait(3.0) ; #DEBUG_LINE_NO:322
    Self.FuelGaugeMessage(shipFuelCurrent, shipFuelCapacity, 4) ; #DEBUG_LINE_NO:323
  Else
    Debug.Notification("Outpost has no supply of Helium-3.") ; #DEBUG_LINE_NO:325
    ObjectReference theShip = playerShipRef as ObjectReference ; #DEBUG_LINE_NO:328
    If Game.GetPlayer().Is3Dloaded() && theShip.Is3Dloaded() && (theShip.GetDistance(Game.GetPlayer() as ObjectReference) < 80 as Float) && Game.GetPlayer().GetItemCount(InorgCommonHelium3 as Form) >= 2 ; #DEBUG_LINE_NO:329
      Self.ManuallyRefuelShip(shipFuelCurrent, shipFuelCapacity) ; #DEBUG_LINE_NO:330
    EndIf
  EndIf
EndFunction

Function ManuallyRefuelShip(Float fShipFuelTankCurrent, Float fShipFuelTankCapacity)
  Float fuelAvailable = Game.GetPlayer().GetItemCount(InorgCommonHelium3 as Form) as Float * 0.5 ; #DEBUG_LINE_NO:337
  If (fuelAvailable > 0 as Float) && fShipFuelTankCapacity > fShipFuelTankCurrent ; #DEBUG_LINE_NO:338
    Utility.Wait(3.0) ; #DEBUG_LINE_NO:339
    If CS7_RefuelMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) == 0 ; #DEBUG_LINE_NO:340
      inputenablelayer myEnableLayer = inputenablelayer.Create() ; #DEBUG_LINE_NO:342
      myEnableLayer.DisablePlayerControls(True, True, True, False, False, True, True, False, True, True, False) ; #DEBUG_LINE_NO:343
      Game.FadeOutGame(True, True, 1 as Float, 0.5, True) ; #DEBUG_LINE_NO:344
      Utility.Wait(1.0) ; #DEBUG_LINE_NO:345
      Float fuelMax = fShipFuelTankCapacity - fShipFuelTankCurrent ; #DEBUG_LINE_NO:347
      Float fuelAmount = Math.Min(fuelMax, fuelAvailable) ; #DEBUG_LINE_NO:348
      playerShipRef.RestoreValue(SpaceshipGravJumpFuel, fuelAmount) ; #DEBUG_LINE_NO:349
      DialogueShipServices.UpdateFuelGlobals() ; #DEBUG_LINE_NO:350
      Int fuelToHe3Items = Math.Floor(fuelAmount * 2 as Float) ; #DEBUG_LINE_NO:351
      Game.GetPlayer().RemoveItem(InorgCommonHelium3 as Form, fuelToHe3Items, False, None) ; #DEBUG_LINE_NO:352
      fShipFuelTankCurrent += fuelAmount ; #DEBUG_LINE_NO:353
      Utility.Wait(1.0) ; #DEBUG_LINE_NO:355
      Game.FadeOutGame(False, True, 1.0, 0.5, True) ; #DEBUG_LINE_NO:356
      myEnableLayer.Delete() ; #DEBUG_LINE_NO:357
      Self.FuelGaugeMessage(fShipFuelTankCurrent, fShipFuelTankCapacity, 0) ; #DEBUG_LINE_NO:358
    Else
      CS7_LockMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:360
    EndIf
  Else
    Utility.Wait(3.0) ; #DEBUG_LINE_NO:363
    CS7_LockMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:364
  EndIf
EndFunction
