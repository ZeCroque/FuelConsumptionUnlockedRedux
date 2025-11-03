ScriptName ShipFuelDataReceiverScript Extends ScriptObject

;-- Functions ---------------------------------------

Function CloseShipFuelModLog() Global
  ; Empty function
EndFunction

Function OnCancel(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnClearRoute(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnGalaxyFocusSystem(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnHintButtonClicked(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnLandingInputInProgress(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnMarkerGroupContainerVisibilityChanged(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnMarkerGroupEntryClicked(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnMarkerGroupEntryHoverChanged(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnOutpostEntrySelected(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnQuickSelectChange(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OnShowRealCursor(Float sFuelConsumption, Float sMaxFuelRange) Global
  ; Empty function
EndFunction

Function OpenShipFuelModLog() Global
  ; Empty function
EndFunction

Function OnExecuteRoute(Float sFuelConsumption, Float sMaxFuelRange) Global
  String ModName = "" ; #DEBUG_LINE_NO:65
  If Game.IsPluginInstalled("SpaceShipFuelMod.esm") == 1 as Bool ; #DEBUG_LINE_NO:66
    ModName = "SpaceShipFuelMod.esm" ; #DEBUG_LINE_NO:67
  EndIf
  cs7spaceshipfuelscript MyQuestScript = Game.GetFormFromFile(2048, ModName) as cs7spaceshipfuelscript ; #DEBUG_LINE_NO:69
  If MyQuestScript as Bool ; #DEBUG_LINE_NO:70
    MyQuestScript.RouteExecute(sFuelConsumption, sMaxFuelRange) ; #DEBUG_LINE_NO:71
  EndIf
EndFunction

Function OnRequestedCallback(Float fValue) Global
  String ModName = "" ; #DEBUG_LINE_NO:83
  If Game.IsPluginInstalled("SpaceShipFuelMod.esm") == 1 as Bool ; #DEBUG_LINE_NO:84
    ModName = "SpaceShipFuelMod.esm" ; #DEBUG_LINE_NO:85
  EndIf
  cs7spaceshipfuelscript MyQuestScript = Game.GetFormFromFile(2048, ModName) as cs7spaceshipfuelscript ; #DEBUG_LINE_NO:87
  If MyQuestScript as Bool ; #DEBUG_LINE_NO:88
    MyQuestScript.RouteCalculationCallback(fValue) ; #DEBUG_LINE_NO:89
  EndIf
EndFunction

Function RequestMaxFuelRangeCallback() Global
  Debug.ExecuteConsole("ShipFuelRequestCallback" + " " + "MaxFuelRange") ; #DEBUG_LINE_NO:97
EndFunction

Function RequestFuelConsumptionCallback() Global
  Debug.ExecuteConsole("ShipFuelRequestCallback" + " " + "FuelConsumption") ; #DEBUG_LINE_NO:101
EndFunction
