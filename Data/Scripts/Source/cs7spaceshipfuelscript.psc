ScriptName CS7SpaceShipFuelScript Extends Quest
{ Script for the fuel calculation including flying to or over an outpost. }

;-- Variables ---------------------------------------
Int AutoActivateMod = 30
Int[] Helium3PerOutpost
Int LocationTimer = 10
Int ModTimer = 20
Int MyUnityRuns
ObjectReference[] OutpostWorkshopIndex
Bool bGravJump
Bool bForceOpen
Bool bModEnabled
Int currentOutpostID
Float fFuelConsumptionValue = 0.0
Float fFuelOutpostValue = 0.0
Int iCountdown = 10
spaceshipreference playerShipRef
Float randomGravJumpFuelCost

;-- Properties --------------------------------------
Group OutpostFuelStorage
  ActorValue Property ResourceInorgCommonHelium3 Auto mandatory
  Activator Property OutpostBeaconActivator Auto mandatory
  { used to find an outpost and locate of the workshop reference }
  ActorValue Property OutpostBuildAreaRadius Auto mandatory
  { used to find the fuel containers in the outpost area }
  Keyword Property LocTypeOutpost Auto Const mandatory
  { used to identify the outpost location }
  Keyword Property OutpostProductionHalted Auto Const mandatory
  { not used but might be of use }
  FormList Property CS7OutpostHe3ContainerList Auto
  { list of all kind of Fuel containers }
  RefCollectionAlias Property FuelContainerOutpost00 Auto
  RefCollectionAlias Property FuelContainerOutpost01 Auto
  RefCollectionAlias Property FuelContainerOutpost02 Auto
  RefCollectionAlias Property FuelContainerOutpost03 Auto
  RefCollectionAlias Property FuelContainerOutpost04 Auto
  RefCollectionAlias Property FuelContainerOutpost05 Auto
  RefCollectionAlias Property FuelContainerOutpost06 Auto
  RefCollectionAlias Property FuelContainerOutpost07 Auto
  RefCollectionAlias Property FuelContainerOutpost08 Auto
  RefCollectionAlias Property FuelContainerOutpost09 Auto
  RefCollectionAlias Property FuelContainerOutpost10 Auto
  RefCollectionAlias Property FuelContainerOutpost11 Auto
  RefCollectionAlias Property FuelContainerOutpost12 Auto
  RefCollectionAlias Property FuelContainerOutpost13 Auto
  RefCollectionAlias Property FuelContainerOutpost14 Auto
  RefCollectionAlias Property FuelContainerOutpost15 Auto
  RefCollectionAlias Property FuelContainerOutpost16 Auto
  RefCollectionAlias Property FuelContainerOutpost17 Auto
  RefCollectionAlias Property FuelContainerOutpost18 Auto
  RefCollectionAlias Property FuelContainerOutpost19 Auto
  RefCollectionAlias Property FuelContainerOutpost20 Auto
  RefCollectionAlias Property FuelContainerOutpost21 Auto
  RefCollectionAlias Property FuelContainerOutpost22 Auto
  RefCollectionAlias Property FuelContainerOutpost23 Auto
  { collection of Fuel containers in list per outpost }
  RefCollectionAlias Property OutpostWorkshopRefs Auto
  { collection of registered outpost references }
  ReferenceAlias Property CurrentOutpost Auto
  { alias for the current outpost reference }
EndGroup

Group ShipAndFuel
  ActorValue Property SpaceshipGravJumpFuel Auto mandatory
  { AV on ship that tracks fuel amount /capacity BaseValue equals maximum capacyty }
  GlobalVariable Property CS7_SpaceshipFarTravelFuelCost Auto Const
  { Every far travel takes up this much fuel, regardless of distance }
  MiscObject Property InorgCommonHelium3 Auto
  { autofill }
  sq_playershipscript Property SQ_PlayerShip Auto Const mandatory
  { autofill }
  dialogueshipservicesscript Property DialogueShipServices Auto Const mandatory
  { autofill }
EndGroup

Static property XMarker Auto Const Mandatory
GlobalVariable Property CS7_IsManualRoute Mandatory Const Auto
GlobalVariable Property CS7_LastFuelCost Mandatory Const Auto
InputEnableLayer Property InputLayer Auto

Group OtherRequired
  ActorValue Property PlayerUnityTimesEntered Auto
  GlobalVariable Property CS7_ModEnabled Auto
  Message Property CS7_StarMapAbortMessage Auto
  Quest Property MQ101 Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Event OnQuestInit()
  OutpostWorkshopIndex = new ObjectReference[0] ; #DEBUG_LINE_NO:92
  Helium3PerOutpost = new Int[0] ; #DEBUG_LINE_NO:93
  currentOutpostID = -1 ; #DEBUG_LINE_NO:94
  Actor playerRef = Game.GetPlayer() ; #DEBUG_LINE_NO:95
  Self.RegisterForRemoteEvent(playerRef, "OnPlayerLoadGame") ; #DEBUG_LINE_NO:96
  Self.RegisterForRemoteEvent(playerRef, "OnExitShipInterior") ; #DEBUG_LINE_NO:97
  Self.RegisterForRemoteEvent(playerRef, "OnOutpostPlaced") ; #DEBUG_LINE_NO:98
  Self.RegisterForRemoteEvent(playerRef , "OnHomeShipSet") ; #DEBUG_LINE_NO:99
  Self.RegisterForRemoteEvent(playerRef , "OnPlayerModifiedShip") ; #DEBUG_LINE_NO:100
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip , "OnShipLanding") ; #DEBUG_LINE_NO:101
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip , "OnShipTakeOff") ; #DEBUG_LINE_NO:102
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip , "OnLocationChange") ; #DEBUG_LINE_NO:103
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip , "OnShipGravJump") ; #DEBUG_LINE_NO:104
  Self.RegisterForRemoteEvent(SQ_PlayerShip.PlayerShip , "OnShipFarTravel") ; #DEBUG_LINE_NO:105
  Self.RegisterForMenuOpenCloseEvent("GalaxyStarMapMenu") ; #DEBUG_LINE_NO:106
  bModEnabled = False ; #DEBUG_LINE_NO:107
  Self.StartTimer(5.0, ModTimer) ; #DEBUG_LINE_NO:108
  CassiopeiaPapyrusExtender.RegisterForNativeEvent("CS7SpaceShipFuelScript", "StarMapMenu_ExecuteRoute")
  CassiopeiaPapyrusExtender.RegisterForNativeEvent("CS7SpaceShipFuelScript", "OnPlayerPlotRoute")
  Debug.Trace("FCU: registered")
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
  If Game.IsPluginInstalled("SpaceShipFuelMod.esm") == False ; #DEBUG_LINE_NO:114
    Self.UnregisterForAllRemoteEvents() ; #DEBUG_LINE_NO:116
    Self.UnregisterForAllMenuOpenCloseEvents() ; #DEBUG_LINE_NO:117
    Self.Stop() ; #DEBUG_LINE_NO:118
  EndIf
EndEvent

Event OnTimer(Int aiTimerID)
  If aiTimerID == LocationTimer ; #DEBUG_LINE_NO:143
    If Game.GetPlayer().GetCurrentLocation().HasKeyword(LocTypeOutpost) ; #DEBUG_LINE_NO:144
      Self.StartTimer(60.0, LocationTimer) ; #DEBUG_LINE_NO:145
    Else
      Self.UnregisterForRemoteEvent(Game.GetPlayer() , "OnLocationChange") ; #DEBUG_LINE_NO:147
    EndIf
  EndIf
  If aiTimerID == ModTimer ; #DEBUG_LINE_NO:150
    MyUnityRuns = Game.GetPlayer().GetValueInt(PlayerUnityTimesEntered) ; #DEBUG_LINE_NO:151
    bModEnabled = CS7_ModEnabled.GetValue() as Bool ; #DEBUG_LINE_NO:154
    If !bModEnabled ; #DEBUG_LINE_NO:155
      If iCountdown == 10 ; #DEBUG_LINE_NO:156
        Debug.Notification("Press [FUEL] to activate mod.") ; #DEBUG_LINE_NO:157
        iCountdown -= 1 ; #DEBUG_LINE_NO:158
      ElseIf iCountdown == 0 ; #DEBUG_LINE_NO:159
        iCountdown = 10 ; #DEBUG_LINE_NO:160
      Else
        iCountdown -= 1 ; #DEBUG_LINE_NO:162
      EndIf
      Self.StartTimer(5.0, ModTimer) ; #DEBUG_LINE_NO:164
    Else
      Game.RequestAutoSave() ; #DEBUG_LINE_NO:166
      Debug.Notification("Fuel consumption is now enabled.") ; #DEBUG_LINE_NO:167
    EndIf
  EndIf
EndEvent

Function StarMapMenu_ExecuteRoute() Global
	Debug.Trace("FCU: Route executed")
  (Game.GetFormFromFile(0x825,"SpaceShipFuelMod.esp") as GlobalVariable).SetValueInt(1)
EndFunction

Function OnPlayerPlotRoute(ObjectReference akHomeshipRef, Int aeFailedPlotReason, Int aiJumps, Float afShipGravJumpRange, Float afDistance, Float afCargoWeight, Float afCargoCapacity, Float afFuelConsumption, Float afMaxFuel) global
  (Game.GetFormFromFile(0x826,"SpaceShipFuelMod.esp") as GlobalVariable).SetValue(afFuelConsumption)

  CS7SpaceShipFuelScript customSelf = (Game.GetFormFromFile(0x800,"SpaceShipFuelMod.esp") as CS7SpaceShipFuelScript)
  If(aeFailedPlotReason == 0 && afFuelConsumption > (Game.GetForm(0x174A2) as SQ_PlayerShipScript).PlayerShip.GetShipRef().GetValue(Game.GetForm(0x854F) as ActorValue))
    customSelf.InputLayer = InputEnableLayer.Create()
    customSelf.InputLayer.EnableGravJump(False)
    Debug.Trace("Disable fast travel")
  ElseIf(customSelf.InputLayer)
    Debug.Trace("Enabled fast travel")
    customSelf.InputLayer.Delete()
  EndIf
EndFunction

Event OnMenuOpenCloseEvent(String asMenuName, Bool abOpening)
  If asMenuName == "GalaxyStarMapMenu" && bModEnabled ; #DEBUG_LINE_NO:191
    If abOpening
      If(bForceOpen)
        Debug.Trace("FCU: forcing map")
        bForceOpen = False
        fFuelConsumptionValue = -1.0
        While(fFuelConsumptionValue == -1.0 || fFuelConsumptionValue == 0.0)
          fFuelConsumptionValue = CassiopeiaPapyrusExtender.GetPlayerSpaceshipFuelConsumption()
        EndWhile      
        Debug.Trace(fFuelConsumptionValue)
        CassiopeiaPapyrusExtender.CloseMenu("GalaxyStarMapMenu")
      EndIf
      Self.CollectHelium3DataForAllOutposts() ; #DEBUG_LINE_NO:195
      fFuelOutpostValue = 0 as Float ; #DEBUG_LINE_NO:196B
    EndIf
  EndIf
EndEvent

Event ReferenceAlias.OnShipGravJump(ReferenceAlias akSender, Location aDestination, Int aState)
  If akSender == SQ_PlayerShip.PlayerShip && bModEnabled ; #DEBUG_LINE_NO:215
    bGravJump = aState as Bool ; #DEBUG_LINE_NO:216
    If aState == 0    
      Debug.Trace("FCU: jump initiated")
      If(CS7_IsManualRoute.GetValueInt())
        fFuelConsumptionValue = CS7_LastFuelCost.GetValue()
      Else
        Debug.Trace("FCU: it's a scan mode jump")
        bForceOpen = True
        Game.ShowGalaxyStarMapMenu() ; #DEBUG_LINE_NO:226
      EndIf
    ElseIf aState == 2
      CS7_IsManualRoute.SetValueInt(0)
    EndIf      
  EndIf
EndEvent

Event ReferenceAlias.OnShipFarTravel(ReferenceAlias akSender, Location aDepartureLocation, Location aArrivalLocation, Int aState)
  If akSender == SQ_PlayerShip.PlayerShip && aState == 0 && bModEnabled ; #DEBUG_LINE_NO:236
    If bGravJump && (randomGravJumpFuelCost > 0 as Float) ; #DEBUG_LINE_NO:237
      randomGravJumpFuelCost = 0 as Float ; #DEBUG_LINE_NO:238
    EndIf
    If bGravJump || (fFuelConsumptionValue > 0 as Float) ; #DEBUG_LINE_NO:240
      
    Else
      playerShipRef = SQ_PlayerShip.PlayerShip.GetShipRef() ; #DEBUG_LINE_NO:243
      Float FarTravelFuelCost = CS7_SpaceshipFarTravelFuelCost.GetValue() ; #DEBUG_LINE_NO:244
      Float fShipFuelTankCapacity = playerShipRef.GetBaseValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:245
      Float fShipFuelTankCurrent = playerShipRef.GetValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:246
      Float fuelAmount = Math.Min(FarTravelFuelCost, fShipFuelTankCurrent) ; #DEBUG_LINE_NO:247
      playerShipRef.DamageValue(SpaceshipGravJumpFuel, fuelAmount) ; #DEBUG_LINE_NO:248
      DialogueShipServices.UpdateFuelGlobals() ; #DEBUG_LINE_NO:249
    EndIf
  EndIf
EndEvent

Event ReferenceAlias.OnLocationChange(ReferenceAlias akSender, Location akOldLoc, Location akNewLoc)
  If akSender == SQ_PlayerShip.PlayerShip ; #DEBUG_LINE_NO:256
    If akOldLoc.HasKeyword(LocTypeOutpost) && akNewLoc.HasKeyword(LocTypeOutpost) == False ; #DEBUG_LINE_NO:257
      If currentOutpostID >= 0 ; #DEBUG_LINE_NO:258
        Self.OnOutpostLeft() ; #DEBUG_LINE_NO:259
        Self.UnregisterForRemoteEvent(Game.GetPlayer() , "OnLocationChange") ; #DEBUG_LINE_NO:260
        Self.CancelTimer(LocationTimer) ; #DEBUG_LINE_NO:261
      EndIf
    EndIf
    If akOldLoc != akNewLoc && bModEnabled ; #DEBUG_LINE_NO:264
      Debug.Trace("FCU: removed fuel=" + fFuelConsumptionValue)
      Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:265
      If bGravJump || (fFuelConsumptionValue > 0 as Float) ; #DEBUG_LINE_NO:266
        Self.CheckRefuelingAtRegisteredOutposts() ; #DEBUG_LINE_NO:267
        Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:268
        Self.UpdateFuelValues(fFuelConsumptionValue, fFuelOutpostValue) ; #DEBUG_LINE_NO:269
        fFuelConsumptionValue = 0 as Float ; #DEBUG_LINE_NO:270
        fFuelOutpostValue = 0 as Float ; #DEBUG_LINE_NO:271
      EndIf
      bGravJump = False ; #DEBUG_LINE_NO:273
    EndIf
  EndIf
EndEvent

Event Actor.OnHomeShipSet(Actor akSource, spaceshipreference akShip, spaceshipreference akPrevious)
  If akShip != akPrevious ; #DEBUG_LINE_NO:280
    playerShipRef = akShip ; #DEBUG_LINE_NO:281
    Self.ResetShipServicesDialogue() ; #DEBUG_LINE_NO:282
  EndIf
EndEvent

Event Actor.OnPlayerModifiedShip(Actor akSource, spaceshipreference akShip)
  playerShipRef = SQ_PlayerShip.PlayerShip.GetShipRef() ; #DEBUG_LINE_NO:288
  If akShip == playerShipRef ; #DEBUG_LINE_NO:289
    Self.ResetShipServicesDialogue() ; #DEBUG_LINE_NO:290
  EndIf
EndEvent

Event ReferenceAlias.OnWorkshopMode(ReferenceAlias akSender, Bool aStart)
  If !aStart ; #DEBUG_LINE_NO:296
    Self.CallForUpdateCurrentOutpostFuelContainerCollection() ; #DEBUG_LINE_NO:297
  EndIf
EndEvent

Event ReferenceAlias.OnWorkshopObjectPlaced(ReferenceAlias akSender, ObjectReference akReference)
  If CS7OutpostHe3ContainerList.HasForm(akReference as Form) == True ; #DEBUG_LINE_NO:303
    Self.CallForUpdateCurrentOutpostFuelContainerCollection() ; #DEBUG_LINE_NO:304
  EndIf
EndEvent

Event Actor.OnOutpostPlaced(Actor akSender, ObjectReference akOutpostBeacon)
  If currentOutpostID >= 0 ; #DEBUG_LINE_NO:310
    Self.OnOutpostLeft() ; #DEBUG_LINE_NO:311
    Self.UnregisterForRemoteEvent(Game.GetPlayer() , "OnLocationChange") ; #DEBUG_LINE_NO:312
    Self.CancelTimer(LocationTimer) ; #DEBUG_LINE_NO:313
    Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:314
  EndIf
  Int playerUnityRuns = Game.GetPlayer().GetValueInt(PlayerUnityTimesEntered) ; #DEBUG_LINE_NO:317
  If playerUnityRuns > MyUnityRuns ; #DEBUG_LINE_NO:318
    MyUnityRuns = playerUnityRuns ; #DEBUG_LINE_NO:319
    Self.ResetModAfterUnity() ; #DEBUG_LINE_NO:320
  EndIf
  ObjectReference myOutpostRef = akOutpostBeacon ; #DEBUG_LINE_NO:323
  If myOutpostRef as Bool && Self.CleanOutpostWorkshopIndex() ; #DEBUG_LINE_NO:324
    Int myOutpostID = Self.GetOutpostID(myOutpostRef) ; #DEBUG_LINE_NO:325
    If myOutpostID < 0 ; #DEBUG_LINE_NO:326
      myOutpostID = Self.SetOutpostWorkshopIndex(myOutpostRef) ; #DEBUG_LINE_NO:327
      If bModEnabled == False ; #DEBUG_LINE_NO:328
        Debug.Notification("Outpost registered.") ; #DEBUG_LINE_NO:329
      EndIf
    EndIf
    currentOutpostID = myOutpostID ; #DEBUG_LINE_NO:333
    CurrentOutpost.ForceRefTo(myOutpostRef) ; #DEBUG_LINE_NO:334
    Self.OnOutpostDetect() ; #DEBUG_LINE_NO:335
  EndIf
EndEvent

Event ReferenceAlias.OnWorkshopObjectRemoved(ReferenceAlias akSource, ObjectReference akReference)
  If akReference == CurrentOutpost.GetRef() ; #DEBUG_LINE_NO:341
    OutpostWorkshopRefs.RemoveRef(akReference) ; #DEBUG_LINE_NO:342
    Int myOutpostID = Self.GetOutpostID(akReference) ; #DEBUG_LINE_NO:343
    If myOutpostID >= 0 ; #DEBUG_LINE_NO:344
      OutpostWorkshopIndex[myOutpostID] = None ; #DEBUG_LINE_NO:345
      Helium3PerOutpost[myOutpostID] = 0 ; #DEBUG_LINE_NO:346
      currentOutpostID = -1 ; #DEBUG_LINE_NO:347
    EndIf
    Self.OnOutpostLeft() ; #DEBUG_LINE_NO:349
  EndIf
EndEvent

Event Actor.OnExitShipInterior(Actor akSender, ObjectReference akShip)
  If currentOutpostID < 0 && Game.GetPlayer().GetCurrentLocation().HasKeyword(LocTypeOutpost) ; #DEBUG_LINE_NO:355
    If Self.GetOutpostIDFromLandingReference(Game.GetPlayer() as ObjectReference) >= 0 ; #DEBUG_LINE_NO:356
      Self.OnOutpostDetect() ; #DEBUG_LINE_NO:357
    EndIf
  EndIf
EndEvent

Event ReferenceAlias.OnShipLanding(ReferenceAlias akSender, Bool abComplete)
  If abComplete && currentOutpostID < 0 ; #DEBUG_LINE_NO:364
    playerShipRef = SQ_PlayerShip.PlayerShip.GetShipRef() ; #DEBUG_LINE_NO:365
    ObjectReference landingMarker = playerShipRef.GetLinkedRef(SQ_PlayerShip.LandingMarkerKeyword) ; #DEBUG_LINE_NO:366
    If Self.GetOutpostIDFromLandingReference(landingMarker) >= 0 ; #DEBUG_LINE_NO:367
      Self.OnOutpostDetect() ; #DEBUG_LINE_NO:368
    EndIf
  EndIf
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
  If Game.GetPlayer().GetCurrentLocation().HasKeyword(LocTypeOutpost) ; #DEBUG_LINE_NO:375
    If currentOutpostID < 0 && Self.GetOutpostIDFromLandingReference(Game.GetPlayer() as ObjectReference) >= 0 ; #DEBUG_LINE_NO:376
      Self.OnOutpostDetect() ; #DEBUG_LINE_NO:377
    EndIf
  ElseIf currentOutpostID >= 0 ; #DEBUG_LINE_NO:379
    Self.OnOutpostLeft() ; #DEBUG_LINE_NO:380
  EndIf
EndEvent

Event ReferenceAlias.OnShipTakeoff(ReferenceAlias akSender, Bool abComplete)
  If !abComplete && currentOutpostID >= 0 ; #DEBUG_LINE_NO:386
    Self.OnOutpostLeft() ; #DEBUG_LINE_NO:387
    Self.UnregisterForRemoteEvent(Game.GetPlayer() , "OnLocationChange") ; #DEBUG_LINE_NO:388
    Self.CancelTimer(LocationTimer) ; #DEBUG_LINE_NO:389
  EndIf
EndEvent

Event ObjectReference.OnUnload(ObjectReference akSender)
  If currentOutpostID >= 0 ; #DEBUG_LINE_NO:395
    Self.OnOutpostLeft() ; #DEBUG_LINE_NO:396
    Self.UnregisterForRemoteEvent(Game.GetPlayer() , "OnLocationChange") ; #DEBUG_LINE_NO:397
    Self.CancelTimer(LocationTimer) ; #DEBUG_LINE_NO:398
  EndIf
EndEvent

Function ResetShipServicesDialogue()
  If Game.IsPlayerInDialogue() ; #DEBUG_LINE_NO:405
    Game.RequestDialogueExit() ; #DEBUG_LINE_NO:406
  EndIf
  While Game.IsPlayerInDialogue() == True ; #DEBUG_LINE_NO:408
    Utility.Wait(0.5) ; #DEBUG_LINE_NO:409
  EndWhile
  DialogueShipServices.UpdateFuelGlobals() ; #DEBUG_LINE_NO:411
EndFunction

Function UpdateFuelValues(Float afConsumptionVal, Float afOutpostVal)
  playerShipRef = SQ_PlayerShip.PlayerShip.GetShipRef() ; #DEBUG_LINE_NO:416
  If playerShipRef as Bool && bModEnabled ; #DEBUG_LINE_NO:417
    If (afConsumptionVal == 0 as Float) && (randomGravJumpFuelCost > 0 as Float) ; #DEBUG_LINE_NO:418
      afConsumptionVal = randomGravJumpFuelCost ; #DEBUG_LINE_NO:419
    EndIf
    randomGravJumpFuelCost = 0.0 ; #DEBUG_LINE_NO:421
    Float fShipFuelTankCapacity = playerShipRef.GetBaseValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:422
    Float fShipFuelTankCurrent = playerShipRef.GetValue(SpaceshipGravJumpFuel) ; #DEBUG_LINE_NO:423
    Float fuelDiffMaxTop = fShipFuelTankCapacity - fShipFuelTankCurrent ; #DEBUG_LINE_NO:424
    If afOutpostVal > 0 as Float ; #DEBUG_LINE_NO:425
      If afOutpostVal > afConsumptionVal ; #DEBUG_LINE_NO:426
        Float fuelDiff = afOutpostVal - afConsumptionVal ; #DEBUG_LINE_NO:427
        Float fuelAmount = Math.Min(fuelDiffMaxTop, fuelDiff) ; #DEBUG_LINE_NO:428
        If fuelDiffMaxTop - fuelAmount < 1 as Float ; #DEBUG_LINE_NO:429
          fuelAmount = fuelDiffMaxTop ; #DEBUG_LINE_NO:430
        EndIf
        playerShipRef.RestoreValue(SpaceshipGravJumpFuel, fuelAmount) ; #DEBUG_LINE_NO:432
      Else
        Float fueldiff = afConsumptionVal - afOutpostVal ; #DEBUG_LINE_NO:434
        If fueldiff < 1 as Float ; #DEBUG_LINE_NO:435
          fueldiff = 0 as Float ; #DEBUG_LINE_NO:436
        EndIf
        Float fuelamount = Math.Min(fShipFuelTankCurrent, fueldiff) ; #DEBUG_LINE_NO:438
        playerShipRef.DamageValue(SpaceshipGravJumpFuel, fuelamount) ; #DEBUG_LINE_NO:439
      EndIf
    Else
      Float fuelamount = Math.Min(afConsumptionVal, fShipFuelTankCurrent) ; #DEBUG_LINE_NO:442
      playerShipRef.DamageValue(SpaceshipGravJumpFuel, fuelamount) ; #DEBUG_LINE_NO:443
    EndIf
    DialogueShipServices.UpdateFuelGlobals() ; #DEBUG_LINE_NO:445
    Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:446
    Debug.Notification((("FUEL [ " + Math.Round(playerShipRef.GetValue(SpaceshipGravJumpFuel)) as String) + " / " + (fShipFuelTankCapacity as Int) as String) + " ]") ; #DEBUG_LINE_NO:447
  EndIf
EndFunction

Function OnOutpostDetect()
  Self.RegisterForRemoteEvent(CurrentOutpost , "OnWorkshopMode") ; #DEBUG_LINE_NO:455
  Self.RegisterForRemoteEvent(CurrentOutpost , "OnWorkshopObjectPlaced") ; #DEBUG_LINE_NO:456
  Self.RegisterForRemoteEvent(CurrentOutpost , "OnUnload") ; #DEBUG_LINE_NO:457
  Self.RegisterForRemoteEvent(CurrentOutpost , "OnWorkshopObjectRemoved") ; #DEBUG_LINE_NO:458
  Self.RegisterForRemoteEvent(Game.GetPlayer() , "OnLocationChange") ; #DEBUG_LINE_NO:459
  Self.StartTimer(60.0, LocationTimer) ; #DEBUG_LINE_NO:460
EndFunction

Function OnOutpostLeft()
  Self.UnregisterForRemoteEvent(CurrentOutpost , "OnWorkshopMode") ; #DEBUG_LINE_NO:465
  Self.UnregisterForRemoteEvent(CurrentOutpost , "OnWorkshopObjectPlaced") ; #DEBUG_LINE_NO:466
  Self.UnregisterForRemoteEvent(CurrentOutpost , "OnWorkshopObjectRemoved") ; #DEBUG_LINE_NO:467
  Self.UnregisterForRemoteEvent(CurrentOutpost , "OnUnload") ; #DEBUG_LINE_NO:468
  CurrentOutpost.Clear() ; #DEBUG_LINE_NO:469
  currentOutpostID = -1 ; #DEBUG_LINE_NO:470
EndFunction

Int Function GetOutpostIDFromLandingReference(ObjectReference theReference)
  Int myOutpostID = -1 ; #DEBUG_LINE_NO:475
  If currentOutpostID == -1 && theReference as Bool ; #DEBUG_LINE_NO:476
    currentOutpostID = -2 ; #DEBUG_LINE_NO:477
    ObjectReference[] OutpostBeaconsArray = theReference.FindAllReferencesOfType(OutpostBeaconActivator as Form, 400 as Float) ; #DEBUG_LINE_NO:478
    If OutpostBeaconsArray.Length == 1 && OutpostBeaconsArray[0].GetCurrentLocation().HasKeyword(LocTypeOutpost) ; #DEBUG_LINE_NO:479
      ObjectReference myOutpostRef = OutpostBeaconsArray[0] ; #DEBUG_LINE_NO:480
      If myOutpostRef as Bool && Self.CleanOutpostWorkshopIndex() ; #DEBUG_LINE_NO:481
        myOutpostID = Self.GetOutpostID(myOutpostRef) ; #DEBUG_LINE_NO:482
        If myOutpostID < 0 ; #DEBUG_LINE_NO:483
          myOutpostID = Self.SetOutpostWorkshopIndex(myOutpostRef) ; #DEBUG_LINE_NO:484
          If bModEnabled == False ; #DEBUG_LINE_NO:485
            Debug.Notification("Outpost registered.") ; #DEBUG_LINE_NO:486
          EndIf
        ElseIf bModEnabled == False ; #DEBUG_LINE_NO:488
          Debug.Notification("Outpost registered.") ; #DEBUG_LINE_NO:489
        EndIf
        currentOutpostID = myOutpostID ; #DEBUG_LINE_NO:492
        CurrentOutpost.ForceRefTo(myOutpostRef) ; #DEBUG_LINE_NO:493
        Self.CallForUpdateCurrentOutpostFuelContainerCollection() ; #DEBUG_LINE_NO:494
      Else
        Debug.MessageBox("ERROR getting Outpost Beacon !?!") ; #DEBUG_LINE_NO:497
        currentOutpostID = -1 ; #DEBUG_LINE_NO:498
      EndIf
    Else
      currentOutpostID = -1 ; #DEBUG_LINE_NO:501
    EndIf
  EndIf
  Return myOutpostID ; #DEBUG_LINE_NO:504
EndFunction

Int Function GetOutpostID(ObjectReference akOutpostRef)
  Int index = -1 ; #DEBUG_LINE_NO:509
  Int I = 0 ; #DEBUG_LINE_NO:510
  While I < OutpostWorkshopIndex.Length && index == -1 ; #DEBUG_LINE_NO:511
    If OutpostWorkshopIndex[I] == akOutpostRef ; #DEBUG_LINE_NO:512
      index = I ; #DEBUG_LINE_NO:513
    EndIf
    I += 1 ; #DEBUG_LINE_NO:515
  EndWhile
  Return index ; #DEBUG_LINE_NO:517
EndFunction

Int Function SetOutpostWorkshopIndex(ObjectReference akOutpostRef)
  Int newOutpostID = -1 ; #DEBUG_LINE_NO:522
  If currentOutpostID < 0 ; #DEBUG_LINE_NO:523
    Int I = 0 ; #DEBUG_LINE_NO:524
    Int j = OutpostWorkshopIndex.Length ; #DEBUG_LINE_NO:525
    While I < j && newOutpostID == -1 ; #DEBUG_LINE_NO:526
      If OutpostWorkshopIndex[I] == None ; #DEBUG_LINE_NO:527
        newOutpostID = I ; #DEBUG_LINE_NO:528
        OutpostWorkshopIndex[I] = akOutpostRef ; #DEBUG_LINE_NO:529
        Helium3PerOutpost[I] = 0 ; #DEBUG_LINE_NO:530
      EndIf
      I += 1 ; #DEBUG_LINE_NO:532
    EndWhile
    If newOutpostID < 0 ; #DEBUG_LINE_NO:534
      OutpostWorkshopIndex.add(akOutpostRef, 1) ; #DEBUG_LINE_NO:535
      Helium3PerOutpost.add(0, 1) ; #DEBUG_LINE_NO:536
      newOutpostID = j ; #DEBUG_LINE_NO:537
    EndIf
    OutpostWorkshopRefs.AddRef(akOutpostRef) ; #DEBUG_LINE_NO:539
  EndIf
  Return newOutpostID ; #DEBUG_LINE_NO:541
EndFunction

Bool Function CleanOutpostWorkshopIndex()
  Bool update = False ; #DEBUG_LINE_NO:546
  Int I = 0 ; #DEBUG_LINE_NO:547
  While I < OutpostWorkshopIndex.Length ; #DEBUG_LINE_NO:548
    If OutpostWorkshopIndex[I] != None && OutpostWorkshopRefs.Find(OutpostWorkshopIndex[I]) >= 0 ; #DEBUG_LINE_NO:549
      
    Else
      OutpostWorkshopIndex[I] = None ; #DEBUG_LINE_NO:552
      Helium3PerOutpost[I] = 0 ; #DEBUG_LINE_NO:553
    EndIf
    I += 1 ; #DEBUG_LINE_NO:555
  EndWhile
  update = True ; #DEBUG_LINE_NO:557
  Return update ; #DEBUG_LINE_NO:558
EndFunction

Function CallForUpdateCurrentOutpostFuelContainerCollection()
  If currentOutpostID == 0 ; #DEBUG_LINE_NO:563
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost00) ; #DEBUG_LINE_NO:564
  ElseIf currentOutpostID == 1 ; #DEBUG_LINE_NO:565
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost01) ; #DEBUG_LINE_NO:566
  ElseIf currentOutpostID == 2 ; #DEBUG_LINE_NO:567
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost02) ; #DEBUG_LINE_NO:568
  ElseIf currentOutpostID == 3 ; #DEBUG_LINE_NO:569
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost03) ; #DEBUG_LINE_NO:570
  ElseIf currentOutpostID == 4 ; #DEBUG_LINE_NO:571
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost04) ; #DEBUG_LINE_NO:572
  ElseIf currentOutpostID == 5 ; #DEBUG_LINE_NO:573
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost05) ; #DEBUG_LINE_NO:574
  ElseIf currentOutpostID == 6 ; #DEBUG_LINE_NO:575
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost06) ; #DEBUG_LINE_NO:576
  ElseIf currentOutpostID == 7 ; #DEBUG_LINE_NO:577
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost07) ; #DEBUG_LINE_NO:578
  ElseIf currentOutpostID == 8 ; #DEBUG_LINE_NO:579
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost08) ; #DEBUG_LINE_NO:580
  ElseIf currentOutpostID == 9 ; #DEBUG_LINE_NO:581
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost09) ; #DEBUG_LINE_NO:582
  ElseIf currentOutpostID == 10 ; #DEBUG_LINE_NO:583
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost10) ; #DEBUG_LINE_NO:584
  ElseIf currentOutpostID == 11 ; #DEBUG_LINE_NO:585
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost11) ; #DEBUG_LINE_NO:586
  ElseIf currentOutpostID == 12 ; #DEBUG_LINE_NO:587
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost12) ; #DEBUG_LINE_NO:588
  ElseIf currentOutpostID == 13 ; #DEBUG_LINE_NO:589
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost13) ; #DEBUG_LINE_NO:590
  ElseIf currentOutpostID == 14 ; #DEBUG_LINE_NO:591
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost14) ; #DEBUG_LINE_NO:592
  ElseIf currentOutpostID == 15 ; #DEBUG_LINE_NO:593
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost15) ; #DEBUG_LINE_NO:594
  ElseIf currentOutpostID == 16 ; #DEBUG_LINE_NO:595
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost16) ; #DEBUG_LINE_NO:596
  ElseIf currentOutpostID == 17 ; #DEBUG_LINE_NO:597
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost17) ; #DEBUG_LINE_NO:598
  ElseIf currentOutpostID == 18 ; #DEBUG_LINE_NO:599
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost18) ; #DEBUG_LINE_NO:600
  ElseIf currentOutpostID == 19 ; #DEBUG_LINE_NO:601
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost19) ; #DEBUG_LINE_NO:602
  ElseIf currentOutpostID == 20 ; #DEBUG_LINE_NO:603
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost20) ; #DEBUG_LINE_NO:604
  ElseIf currentOutpostID == 21 ; #DEBUG_LINE_NO:605
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost21) ; #DEBUG_LINE_NO:606
  ElseIf currentOutpostID == 22 ; #DEBUG_LINE_NO:607
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost22) ; #DEBUG_LINE_NO:608
  ElseIf currentOutpostID == 23 ; #DEBUG_LINE_NO:609
    Self.UpdateCurrentOutpostFuelContainerCollection(FuelContainerOutpost23) ; #DEBUG_LINE_NO:610
  EndIf
EndFunction

Function UpdateCurrentOutpostFuelContainerCollection(RefCollectionAlias theFuelContainerOutpostXX)
  Float searchRadius = CurrentOutpost.GetRef().GetValue(OutpostBuildAreaRadius) ; #DEBUG_LINE_NO:617
  ObjectReference[] He3Containers = CurrentOutpost.GetRef().FindAllReferencesOfType(CS7OutpostHe3ContainerList as Form, searchRadius) ; #DEBUG_LINE_NO:618
  If He3Containers.Length > 0 ; #DEBUG_LINE_NO:619
    If theFuelContainerOutpostXX.GetCount() == 0 ; #DEBUG_LINE_NO:620
      theFuelContainerOutpostXX.AddArray(He3Containers) ; #DEBUG_LINE_NO:621
    Else
      Int I = 0 ; #DEBUG_LINE_NO:623
      While I < He3Containers.Length ; #DEBUG_LINE_NO:624
        If theFuelContainerOutpostXX.Find(He3Containers[I]) < 0 ; #DEBUG_LINE_NO:625
          theFuelContainerOutpostXX.AddRef(He3Containers[I]) ; #DEBUG_LINE_NO:626
        EndIf
        I += 1 ; #DEBUG_LINE_NO:628
      EndWhile
    EndIf
  Else
    theFuelContainerOutpostXX.RemoveAll() ; #DEBUG_LINE_NO:632
  EndIf
EndFunction

Function CollectHelium3DataForAllOutposts()
  Int I = 0 ; #DEBUG_LINE_NO:639
  While I < OutpostWorkshopIndex.Length ; #DEBUG_LINE_NO:640
    If OutpostWorkshopIndex[I] != None ; #DEBUG_LINE_NO:641
      Self.CallForHelium3DataArrayPerOutpostID(I) ; #DEBUG_LINE_NO:642
    EndIf
    I += 1 ; #DEBUG_LINE_NO:644
  EndWhile
EndFunction

Function CallForHelium3DataArrayPerOutpostID(Int aiOutpostID)
  If aiOutpostID == 0 ; #DEBUG_LINE_NO:650
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost00, aiOutpostID) ; #DEBUG_LINE_NO:651
  ElseIf aiOutpostID == 1 ; #DEBUG_LINE_NO:652
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost01, aiOutpostID) ; #DEBUG_LINE_NO:653
  ElseIf aiOutpostID == 2 ; #DEBUG_LINE_NO:654
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost02, aiOutpostID) ; #DEBUG_LINE_NO:655
  ElseIf aiOutpostID == 3 ; #DEBUG_LINE_NO:656
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost03, aiOutpostID) ; #DEBUG_LINE_NO:657
  ElseIf aiOutpostID == 4 ; #DEBUG_LINE_NO:658
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost04, aiOutpostID) ; #DEBUG_LINE_NO:659
  ElseIf aiOutpostID == 5 ; #DEBUG_LINE_NO:660
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost05, aiOutpostID) ; #DEBUG_LINE_NO:661
  ElseIf aiOutpostID == 6 ; #DEBUG_LINE_NO:662
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost06, aiOutpostID) ; #DEBUG_LINE_NO:663
  ElseIf aiOutpostID == 7 ; #DEBUG_LINE_NO:664
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost07, aiOutpostID) ; #DEBUG_LINE_NO:665
  ElseIf aiOutpostID == 8 ; #DEBUG_LINE_NO:666
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost08, aiOutpostID) ; #DEBUG_LINE_NO:667
  ElseIf aiOutpostID == 9 ; #DEBUG_LINE_NO:668
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost09, aiOutpostID) ; #DEBUG_LINE_NO:669
  ElseIf aiOutpostID == 10 ; #DEBUG_LINE_NO:670
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost10, aiOutpostID) ; #DEBUG_LINE_NO:671
  ElseIf aiOutpostID == 11 ; #DEBUG_LINE_NO:672
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost11, aiOutpostID) ; #DEBUG_LINE_NO:673
  ElseIf aiOutpostID == 12 ; #DEBUG_LINE_NO:674
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost12, aiOutpostID) ; #DEBUG_LINE_NO:675
  ElseIf aiOutpostID == 13 ; #DEBUG_LINE_NO:676
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost13, aiOutpostID) ; #DEBUG_LINE_NO:677
  ElseIf aiOutpostID == 14 ; #DEBUG_LINE_NO:678
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost14, aiOutpostID) ; #DEBUG_LINE_NO:679
  ElseIf aiOutpostID == 15 ; #DEBUG_LINE_NO:680
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost15, aiOutpostID) ; #DEBUG_LINE_NO:681
  ElseIf aiOutpostID == 16 ; #DEBUG_LINE_NO:682
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost16, aiOutpostID) ; #DEBUG_LINE_NO:683
  ElseIf aiOutpostID == 17 ; #DEBUG_LINE_NO:684
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost17, aiOutpostID) ; #DEBUG_LINE_NO:685
  ElseIf aiOutpostID == 18 ; #DEBUG_LINE_NO:686
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost18, aiOutpostID) ; #DEBUG_LINE_NO:687
  ElseIf aiOutpostID == 19 ; #DEBUG_LINE_NO:688
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost19, aiOutpostID) ; #DEBUG_LINE_NO:689
  ElseIf aiOutpostID == 20 ; #DEBUG_LINE_NO:690
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost20, aiOutpostID) ; #DEBUG_LINE_NO:691
  ElseIf aiOutpostID == 21 ; #DEBUG_LINE_NO:692
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost21, aiOutpostID) ; #DEBUG_LINE_NO:693
  ElseIf aiOutpostID == 22 ; #DEBUG_LINE_NO:694
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost22, aiOutpostID) ; #DEBUG_LINE_NO:695
  ElseIf aiOutpostID == 23 ; #DEBUG_LINE_NO:696
    Self.CollectHelium3InventoryPerOutpostInArray(FuelContainerOutpost23, aiOutpostID) ; #DEBUG_LINE_NO:697
  EndIf
EndFunction

Function CollectHelium3InventoryPerOutpostInArray(RefCollectionAlias theFuelContainerOutpostXX, Int aiOutpostID)
  Int He3CountTotal = 0 ; #DEBUG_LINE_NO:703
  Int I = 0 ; #DEBUG_LINE_NO:704
  While I < theFuelContainerOutpostXX.GetCount() ; #DEBUG_LINE_NO:705
    Int He3CountPerContainer = theFuelContainerOutpostXX.GetAt(I).GetItemCount(InorgCommonHelium3 as Form) ; #DEBUG_LINE_NO:706
    If He3CountPerContainer > 0 ; #DEBUG_LINE_NO:707
      He3CountTotal += He3CountPerContainer ; #DEBUG_LINE_NO:708
    EndIf
    I += 1 ; #DEBUG_LINE_NO:710
  EndWhile
  Helium3PerOutpost[aiOutpostID] = He3CountTotal ; #DEBUG_LINE_NO:712
EndFunction

Function CheckRefuelingAtRegisteredOutposts()
  Int I = 0 ; #DEBUG_LINE_NO:717
  While I < OutpostWorkshopIndex.Length ; #DEBUG_LINE_NO:718
    If OutpostWorkshopIndex[I] != None ; #DEBUG_LINE_NO:719
      Self.CallForCheckHelium3InventoryAtRegisteredOutposts(I) ; #DEBUG_LINE_NO:720
    EndIf
    I += 1 ; #DEBUG_LINE_NO:722
  EndWhile
EndFunction

Function CallForCheckHelium3InventoryAtRegisteredOutposts(Int aiOutpostID)
  If aiOutpostID == 0 ; #DEBUG_LINE_NO:728
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost00, aiOutpostID) ; #DEBUG_LINE_NO:729
  ElseIf aiOutpostID == 1 ; #DEBUG_LINE_NO:730
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost01, aiOutpostID) ; #DEBUG_LINE_NO:731
  ElseIf aiOutpostID == 2 ; #DEBUG_LINE_NO:732
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost02, aiOutpostID) ; #DEBUG_LINE_NO:733
  ElseIf aiOutpostID == 3 ; #DEBUG_LINE_NO:734
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost03, aiOutpostID) ; #DEBUG_LINE_NO:735
  ElseIf aiOutpostID == 4 ; #DEBUG_LINE_NO:736
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost04, aiOutpostID) ; #DEBUG_LINE_NO:737
  ElseIf aiOutpostID == 5 ; #DEBUG_LINE_NO:738
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost05, aiOutpostID) ; #DEBUG_LINE_NO:739
  ElseIf aiOutpostID == 6 ; #DEBUG_LINE_NO:740
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost06, aiOutpostID) ; #DEBUG_LINE_NO:741
  ElseIf aiOutpostID == 7 ; #DEBUG_LINE_NO:742
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost07, aiOutpostID) ; #DEBUG_LINE_NO:743
  ElseIf aiOutpostID == 8 ; #DEBUG_LINE_NO:744
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost08, aiOutpostID) ; #DEBUG_LINE_NO:745
  ElseIf aiOutpostID == 9 ; #DEBUG_LINE_NO:746
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost09, aiOutpostID) ; #DEBUG_LINE_NO:747
  ElseIf aiOutpostID == 10 ; #DEBUG_LINE_NO:748
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost10, aiOutpostID) ; #DEBUG_LINE_NO:749
  ElseIf aiOutpostID == 11 ; #DEBUG_LINE_NO:750
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost11, aiOutpostID) ; #DEBUG_LINE_NO:751
  ElseIf aiOutpostID == 12 ; #DEBUG_LINE_NO:752
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost12, aiOutpostID) ; #DEBUG_LINE_NO:753
  ElseIf aiOutpostID == 13 ; #DEBUG_LINE_NO:754
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost13, aiOutpostID) ; #DEBUG_LINE_NO:755
  ElseIf aiOutpostID == 14 ; #DEBUG_LINE_NO:756
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost14, aiOutpostID) ; #DEBUG_LINE_NO:757
  ElseIf aiOutpostID == 15 ; #DEBUG_LINE_NO:758
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost15, aiOutpostID) ; #DEBUG_LINE_NO:759
  ElseIf aiOutpostID == 16 ; #DEBUG_LINE_NO:760
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost16, aiOutpostID) ; #DEBUG_LINE_NO:761
  ElseIf aiOutpostID == 17 ; #DEBUG_LINE_NO:762
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost17, aiOutpostID) ; #DEBUG_LINE_NO:763
  ElseIf aiOutpostID == 18 ; #DEBUG_LINE_NO:764
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost18, aiOutpostID) ; #DEBUG_LINE_NO:765
  ElseIf aiOutpostID == 19 ; #DEBUG_LINE_NO:766
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost19, aiOutpostID) ; #DEBUG_LINE_NO:767
  ElseIf aiOutpostID == 20 ; #DEBUG_LINE_NO:768
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost20, aiOutpostID) ; #DEBUG_LINE_NO:769
  ElseIf aiOutpostID == 21 ; #DEBUG_LINE_NO:770
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost21, aiOutpostID) ; #DEBUG_LINE_NO:771
  ElseIf aiOutpostID == 22 ; #DEBUG_LINE_NO:772
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost22, aiOutpostID) ; #DEBUG_LINE_NO:773
  ElseIf aiOutpostID == 23 ; #DEBUG_LINE_NO:774
    Self.CheckHelium3InventoryAtRegisteredOutpost(FuelContainerOutpost23, aiOutpostID) ; #DEBUG_LINE_NO:775
  EndIf
EndFunction

Function CheckHelium3InventoryAtRegisteredOutpost(RefCollectionAlias theFuelContainerOutpostXX, Int aiOutpostID)
  Int He3CountTotal = 0 ; #DEBUG_LINE_NO:781
  If Helium3PerOutpost[aiOutpostID] > 0 ; #DEBUG_LINE_NO:782
    Int I = 0 ; #DEBUG_LINE_NO:783
    While I < theFuelContainerOutpostXX.GetCount() ; #DEBUG_LINE_NO:784
      Int He3CountPerContainer = theFuelContainerOutpostXX.GetAt(I).GetItemCount(InorgCommonHelium3 as Form) ; #DEBUG_LINE_NO:785
      If He3CountPerContainer > 0 ; #DEBUG_LINE_NO:786
        He3CountTotal += He3CountPerContainer ; #DEBUG_LINE_NO:787
      EndIf
      I += 1 ; #DEBUG_LINE_NO:789
    EndWhile
  EndIf
  If He3CountTotal < Helium3PerOutpost[aiOutpostID] ; #DEBUG_LINE_NO:793
    Float he3Difference = (Helium3PerOutpost[aiOutpostID] - He3CountTotal) as Float ; #DEBUG_LINE_NO:794
    Float fuelDifference = he3Difference * 0.5 ; #DEBUG_LINE_NO:795
    fFuelOutpostValue += Math.Ceiling(fuelDifference) as Float ; #DEBUG_LINE_NO:796
  EndIf
EndFunction

Function ResetModAfterUnity()
  currentOutpostID = -1 ; #DEBUG_LINE_NO:803
  CurrentOutpost.Clear() ; #DEBUG_LINE_NO:804
  OutpostWorkshopIndex.clear() ; #DEBUG_LINE_NO:805
  Helium3PerOutpost.clear() ; #DEBUG_LINE_NO:806
  OutpostWorkshopRefs.RemoveAll() ; #DEBUG_LINE_NO:807
  FuelContainerOutpost00.RemoveAll() ; #DEBUG_LINE_NO:808
  FuelContainerOutpost01.RemoveAll() ; #DEBUG_LINE_NO:809
  FuelContainerOutpost02.RemoveAll() ; #DEBUG_LINE_NO:810
  FuelContainerOutpost03.RemoveAll() ; #DEBUG_LINE_NO:811
  FuelContainerOutpost04.RemoveAll() ; #DEBUG_LINE_NO:812
  FuelContainerOutpost05.RemoveAll() ; #DEBUG_LINE_NO:813
  FuelContainerOutpost06.RemoveAll() ; #DEBUG_LINE_NO:814
  FuelContainerOutpost07.RemoveAll() ; #DEBUG_LINE_NO:815
  FuelContainerOutpost08.RemoveAll() ; #DEBUG_LINE_NO:816
  FuelContainerOutpost09.RemoveAll() ; #DEBUG_LINE_NO:817
  FuelContainerOutpost10.RemoveAll() ; #DEBUG_LINE_NO:818
  FuelContainerOutpost11.RemoveAll() ; #DEBUG_LINE_NO:819
  FuelContainerOutpost12.RemoveAll() ; #DEBUG_LINE_NO:820
  FuelContainerOutpost13.RemoveAll() ; #DEBUG_LINE_NO:821
  FuelContainerOutpost14.RemoveAll() ; #DEBUG_LINE_NO:822
  FuelContainerOutpost15.RemoveAll() ; #DEBUG_LINE_NO:823
  FuelContainerOutpost16.RemoveAll() ; #DEBUG_LINE_NO:824
  FuelContainerOutpost17.RemoveAll() ; #DEBUG_LINE_NO:825
  FuelContainerOutpost18.RemoveAll() ; #DEBUG_LINE_NO:826
  FuelContainerOutpost19.RemoveAll() ; #DEBUG_LINE_NO:827
  FuelContainerOutpost20.RemoveAll() ; #DEBUG_LINE_NO:828
  FuelContainerOutpost21.RemoveAll() ; #DEBUG_LINE_NO:829
  FuelContainerOutpost22.RemoveAll() ; #DEBUG_LINE_NO:830
  FuelContainerOutpost23.RemoveAll() ; #DEBUG_LINE_NO:831
EndFunction
