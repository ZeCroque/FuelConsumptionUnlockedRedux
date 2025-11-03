#include "Events.h"
#include "Helpers.h"

inline static std::string GetCommandStringArgumentFUNC_NONREF(const char* dataPointer, int offset)
{
	// Command_type: Non-ReferenceFunc + (Params_Optional)
	int offset2 = offset - 2;
	if (offset2 <= 0) {
		return "";
	}
	auto                       dataAddress = std::uint64_t(dataPointer);
	auto                       size = *reinterpret_cast<std::uint8_t*>(dataAddress + offset2);
	std::vector<unsigned char> buffer(150);
	for (std::uint8_t index = 0; index < size; index++) {
		auto symbAddress = dataAddress + offset + index;
		auto symb = *reinterpret_cast<unsigned char*>(symbAddress);
		buffer[index] = symb;
	}
	auto Value = reinterpret_cast<char*>(buffer.data());
	return std::string(Value, size);
}

inline static std::string ExtractFloatFromString(std::string srcString)
{
	if (srcString.empty() == false) {
		float f = -1.00f;
		try {
			f = std::stof(srcString);
		} catch (...) {
			REX::ERROR("std::stof exception thrown for srcString: " + srcString);
			return "stof_exception";
		}
		srcString = std::to_string(f);
	}
	return srcString;
}

inline static bool IsStringDigits(std::string s)
{
	bool Res = false;
	if (s.empty() == false)
		Res = s.find_first_not_of("0123456789") == std::string::npos;
	return Res;
}

inline static bool ToBool(std::string s)
{
	if (s.empty() == false) {
		auto ch = s.c_str();
		if (std::strcmp(ch, "0") == 0)
			return false;
	}
	return true;
}

///////////////////////////////////////////////////////////  PLUGIN  ///////////////////////////////////////////////////////////

inline static std::string sScriptName = "ShipFuelDataReceiverScript";
inline static bool        bLandingInputInProgress = true;
inline static bool        bMarkerGroupContainerVisibilityChanged = true;
inline static bool        bMarkerGroupEntryClicked = true;
inline static bool        bMarkerGroupEntryHoverChanged = true;
inline static bool        bShowRealCursor = true;
inline static bool        bQuickSelectChange = true;
inline static bool        bOnHintButtonClicked = true;
inline static bool        bGalaxyFocusSystem = true;
inline static bool        bOnCancel = true;
inline static bool        bOnClearRoute = true;
inline static bool        bOnOutpostEntrySelected = true;
inline static bool        bExecuteRoute = true;
inline static bool        bSaveLoadEvent = true;
inline static RE::IMenu*  StarMapMenu = nullptr;

inline static bool PapyrusCallbackEx(std::string sFunctionName, std::string sParams, bool bCheckThisForTrue)
{
	if (sScriptName.empty() || sFunctionName.empty() || sParams.empty() || bCheckThisForTrue != true)
		return false;
	std::string asCommand = "CGF \"" + sScriptName + "." + sFunctionName + "\"" + " " + sParams;
	REX::INFO("Executing console command = " + asCommand);
	ExecuteCommand(asCommand.c_str());
	return true;
}

inline static std::string GetFuelValuesAsString()
{
	std::string sMaxFuelRange = GetAS3VariableAsString("GalaxyStarMapMenu", "root1.Menu_mc.JumpData_mc.FuelMeter_mc.Data_mc.text_tf.text");
	if (sMaxFuelRange.empty())
		sMaxFuelRange = "-1";
	else
		sMaxFuelRange = ExtractFloatFromString(sMaxFuelRange);
	std::string sFuelConsumption = GetAS3VariableAsString("GalaxyStarMapMenu", "root1.Menu_mc.JumpData_mc.FuelMeter_mc.MeterAmount_mc.amount_tf.text");
	if (sFuelConsumption.empty())
		sFuelConsumption = "-1";
	else
		sFuelConsumption = ExtractFloatFromString(sFuelConsumption);
	std::string sOutput = sFuelConsumption + " " + sMaxFuelRange;
	return sOutput;
}

class ShipFuelDSStarMapMenu_LandingInputInProgressClass : public RE::BSTEventSink<Events::StarMapMenu_LandingInputInProgress>
{
public:
	virtual ~ShipFuelDSStarMapMenu_LandingInputInProgressClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_LandingInputInProgress& _event,
		RE::BSTEventSource<Events::StarMapMenu_LandingInputInProgress>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnLandingInputInProgress", GetFuelValuesAsString(), bLandingInputInProgress);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_LandingInputInProgressClass ShipFuelDSStarMapMenu_LandingInputInProgressSink;

class ShipFuelDSStarMapMenu_MarkerGroupContainerVisibilityChangedClass : public RE::BSTEventSink<Events::StarMapMenu_MarkerGroupContainerVisibilityChanged>
{
public:
	virtual ~ShipFuelDSStarMapMenu_MarkerGroupContainerVisibilityChangedClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_MarkerGroupContainerVisibilityChanged& _event,
		RE::BSTEventSource<Events::StarMapMenu_MarkerGroupContainerVisibilityChanged>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnMarkerGroupContainerVisibilityChanged", GetFuelValuesAsString(), bMarkerGroupContainerVisibilityChanged);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_MarkerGroupContainerVisibilityChangedClass ShipFuelDSStarMapMenu_MarkerGroupContainerVisibilityChangedSink;

class ShipFuelDSStarMapMenu_MarkerGroupEntryClickedClass : public RE::BSTEventSink<Events::StarMapMenu_MarkerGroupEntryClicked>
{
public:
	virtual ~ShipFuelDSStarMapMenu_MarkerGroupEntryClickedClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_MarkerGroupEntryClicked& _event,
		RE::BSTEventSource<Events::StarMapMenu_MarkerGroupEntryClicked>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnMarkerGroupEntryClicked", GetFuelValuesAsString(), bMarkerGroupEntryClicked);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_MarkerGroupEntryClickedClass ShipFuelDSStarMapMenu_MarkerGroupEntryClickedSink;

class ShipFuelDSStarMapMenu_MarkerGroupEntryHoverChangedClass : public RE::BSTEventSink<Events::StarMapMenu_MarkerGroupEntryHoverChanged>
{
public:
	virtual ~ShipFuelDSStarMapMenu_MarkerGroupEntryHoverChangedClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_MarkerGroupEntryHoverChanged& _event,
		RE::BSTEventSource<Events::StarMapMenu_MarkerGroupEntryHoverChanged>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnMarkerGroupEntryHoverChanged", GetFuelValuesAsString(), bMarkerGroupEntryHoverChanged);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_MarkerGroupEntryHoverChangedClass ShipFuelDSStarMapMenu_MarkerGroupEntryHoverChangedSink;

class ShipFuelDSStarMapMenu_ShowRealCursorClass : public RE::BSTEventSink<Events::StarMapMenu_ShowRealCursor>
{
public:
	virtual ~ShipFuelDSStarMapMenu_ShowRealCursorClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_ShowRealCursor& _event,
		RE::BSTEventSource<Events::StarMapMenu_ShowRealCursor>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnShowRealCursor", GetFuelValuesAsString(), bShowRealCursor);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_ShowRealCursorClass ShipFuelDSStarMapMenu_ShowRealCursorSink;

class ShipFuelDSStarMapMenu_QuickSelectChangeClass : public RE::BSTEventSink<Events::StarMapMenu_QuickSelectChange>
{
public:
	virtual ~ShipFuelDSStarMapMenu_QuickSelectChangeClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_QuickSelectChange& _event,
		RE::BSTEventSource<Events::StarMapMenu_QuickSelectChange>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnQuickSelectChange", GetFuelValuesAsString(), bQuickSelectChange);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_QuickSelectChangeClass ShipFuelDSStarMapMenu_QuickSelectChangeSink;

class ShipFuelDSStarMapMenu_OnHintButtonClickedClass : public RE::BSTEventSink<Events::StarMapMenu_OnHintButtonClicked>
{
public:
	virtual ~ShipFuelDSStarMapMenu_OnHintButtonClickedClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_OnHintButtonClicked& _event,
		RE::BSTEventSource<Events::StarMapMenu_OnHintButtonClicked>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnHintButtonClicked", GetFuelValuesAsString(), bOnHintButtonClicked);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_OnHintButtonClickedClass ShipFuelDSStarMapMenu_OnHintButtonClickedSink;

class ShipFuelDSStarMapMenu_Galaxy_FocusSystemClass : public RE::BSTEventSink<Events::StarMapMenu_Galaxy_FocusSystem>
{
public:
	virtual ~ShipFuelDSStarMapMenu_Galaxy_FocusSystemClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_Galaxy_FocusSystem& _event,
		RE::BSTEventSource<Events::StarMapMenu_Galaxy_FocusSystem>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnGalaxyFocusSystem", GetFuelValuesAsString(), bGalaxyFocusSystem);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_Galaxy_FocusSystemClass ShipFuelDSStarMapMenu_Galaxy_FocusSystemSink;

class ShipFuelDSStarMapMenu_OnCancelClass : public RE::BSTEventSink<Events::StarMapMenu_OnCancel>
{
public:
	virtual ~ShipFuelDSStarMapMenu_OnCancelClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_OnCancel& _event, RE::BSTEventSource<Events::StarMapMenu_OnCancel>* _source) override  // 01 override
	{
		PapyrusCallbackEx("OnCancel", GetFuelValuesAsString(), bOnCancel);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_OnCancelClass ShipFuelDSStarMapMenu_OnCancelSink;

class ShipFuelDSStarMapMenu_OnClearRouteClass : public RE::BSTEventSink<Events::StarMapMenu_OnClearRoute>
{
public:
	virtual ~ShipFuelDSStarMapMenu_OnClearRouteClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_OnClearRoute& _event,
		RE::BSTEventSource<Events::StarMapMenu_OnClearRoute>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnClearRoute", GetFuelValuesAsString(), bOnClearRoute);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_OnClearRouteClass ShipFuelDSStarMapMenu_OnClearRouteSink;

class ShipFuelDSStarMapMenu_OnOutpostEntrySelectedClass : public RE::BSTEventSink<Events::StarMapMenu_OnOutpostEntrySelected>
{
public:
	virtual ~ShipFuelDSStarMapMenu_OnOutpostEntrySelectedClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_OnOutpostEntrySelected& _event,
		RE::BSTEventSource<Events::StarMapMenu_OnOutpostEntrySelected>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnOutpostEntrySelected", GetFuelValuesAsString(), bOnOutpostEntrySelected);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_OnOutpostEntrySelectedClass ShipFuelDSStarMapMenu_OnOutpostEntrySelectedSink;

class ShipFuelDSStarMapMenu_ExecuteRouteClass : public RE::BSTEventSink<Events::StarMapMenu_ExecuteRoute>
{
public:
	virtual ~ShipFuelDSStarMapMenu_ExecuteRouteClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::StarMapMenu_ExecuteRoute& _event,
		RE::BSTEventSource<Events::StarMapMenu_ExecuteRoute>*                             _source) override  // 01 override
	{
		PapyrusCallbackEx("OnExecuteRoute", GetFuelValuesAsString(), bExecuteRoute);
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSStarMapMenu_ExecuteRouteClass ShipFuelDSStarMapMenu_ExecuteRouteSink;

static void HandleOnGalaxyStarMapMenuClose()
{
	REX::INFO("GalaxyStarMapMenu variable cleared.");
	StarMapMenu = nullptr;
}

class ShipFuelDSMenuOpenCloseEventClass : public RE::BSTEventSink<RE::MenuOpenCloseEvent>
{
	RE::BSEventNotifyControl ProcessEvent(const RE::MenuOpenCloseEvent& a_event, RE::BSTEventSource<RE::MenuOpenCloseEvent>*)
	{
		if (a_event.menuName.size() > 0 && std::strcmp(a_event.menuName.c_str(), "GalaxyStarMapMenu") == 0 && !a_event.opening) {
			HandleOnGalaxyStarMapMenuClose();
		}
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSMenuOpenCloseEventClass ShipFuelDSMenuOpenCloseEventSink;

inline static void ReloadSettings()
{
	sScriptName = ReadIni("ShipFuelDataSender", "Papyrus", "sScriptName");
	if (sScriptName.empty())
		sScriptName = "ShipFuelDataReceiverScript";

	bLandingInputInProgress = ToBool(ReadIni("ShipFuelDataSender", "Events", "bLandingInputInProgress"));
	bMarkerGroupContainerVisibilityChanged = ToBool(ReadIni("ShipFuelDataSender", "Events", "bMarkerGroupContainerVisibilityChanged"));
	bMarkerGroupEntryClicked = ToBool(ReadIni("ShipFuelDataSender", "Events", "bMarkerGroupEntryClicked"));
	bMarkerGroupEntryHoverChanged = ToBool(ReadIni("ShipFuelDataSender", "Events", "bMarkerGroupEntryHoverChanged"));
	bShowRealCursor = ToBool(ReadIni("ShipFuelDataSender", "Events", "bShowRealCursor"));
	bQuickSelectChange = ToBool(ReadIni("ShipFuelDataSender", "Events", "bQuickSelectChange"));
	bOnHintButtonClicked = ToBool(ReadIni("ShipFuelDataSender", "Events", "bOnHintButtonClicked"));
	bGalaxyFocusSystem = ToBool(ReadIni("ShipFuelDataSender", "Events", "bGalaxyFocusSystem"));
	bOnCancel = ToBool(ReadIni("ShipFuelDataSender", "Events", "bOnCancel"));
	bOnClearRoute = ToBool(ReadIni("ShipFuelDataSender", "Events", "bOnClearRoute"));
	bOnOutpostEntrySelected = ToBool(ReadIni("ShipFuelDataSender", "Events", "bOnOutpostEntrySelected"));
	bExecuteRoute = ToBool(ReadIni("ShipFuelDataSender", "Events", "bExecuteRoute"));
	bSaveLoadEvent = ToBool(ReadIni("ShipFuelDataSender", "Events", "bSaveLoadEvent"));

	REX::INFO("ReloadSettings: loaded sScriptName -> " + sScriptName);
	REX::INFO("ReloadSettings: loaded bLandingInputInProgress -> " + std::to_string(bLandingInputInProgress));
	REX::INFO("ReloadSettings: loaded bMarkerGroupContainerVisibilityChanged -> " + std::to_string(bMarkerGroupContainerVisibilityChanged));
	REX::INFO("ReloadSettings: loaded bMarkerGroupEntryClicked -> " + std::to_string(bMarkerGroupEntryClicked));
	REX::INFO("ReloadSettings: loaded bMarkerGroupEntryHoverChanged -> " + std::to_string(bMarkerGroupEntryHoverChanged));
	REX::INFO("ReloadSettings: loaded bShowRealCursor -> " + std::to_string(bShowRealCursor));
	REX::INFO("ReloadSettings: loaded bQuickSelectChange -> " + std::to_string(bQuickSelectChange));
	REX::INFO("ReloadSettings: loaded bOnHintButtonClicked -> " + std::to_string(bOnHintButtonClicked));
	REX::INFO("ReloadSettings: loaded bGalaxyFocusSystem -> " + std::to_string(bGalaxyFocusSystem));
	REX::INFO("ReloadSettings: loaded bOnCancel -> " + std::to_string(bOnCancel));
	REX::INFO("ReloadSettings: loaded bOnClearRoute -> " + std::to_string(bOnClearRoute));
	REX::INFO("ReloadSettings: loaded bOnOutpostEntrySelected -> " + std::to_string(bOnOutpostEntrySelected));
	REX::INFO("ReloadSettings: loaded bExecuteRoute -> " + std::to_string(bExecuteRoute));
	REX::INFO("ReloadSettings: loaded bSaveLoadEvent -> " + std::to_string(bSaveLoadEvent));
}

static void HandleOnSaveLoadEvent()
{
	std::string sDebug = "";
	bool        bIsMainMenuOpen = RE::UI::GetSingleton()->IsMenuOpen("MainMenu");
	bool        bIsPauseMenuOpen = RE::UI::GetSingleton()->IsMenuOpen("PauseMenu");
	sDebug = sDebug + "bIsMainMenuOpen = [" + std::to_string(bIsMainMenuOpen) + "]. bIsPauseMenuOpen [" + std::to_string(bIsPauseMenuOpen) + "].";
	if (bIsMainMenuOpen == false && bIsPauseMenuOpen == false) {
		sDebug = sDebug + " Reloading settings...";
		REX::INFO("" + sDebug);
		ReloadSettings();
	} else {
		sDebug = sDebug + " Couldn't reload settings.";
		REX::INFO("" + sDebug);
	}
}

class ShipFuelDSSaveLoadEventClass : public RE::BSTEventSink<Events::SaveLoadEvent>
{
public:
	virtual ~ShipFuelDSSaveLoadEventClass(){};

	virtual RE::BSEventNotifyControl ProcessEvent(const Events::SaveLoadEvent& _event, RE::BSTEventSource<Events::SaveLoadEvent>* _source) override  // 01 override
	{
		HandleOnSaveLoadEvent();
		return RE::BSEventNotifyControl::kContinue;
	}
};

ShipFuelDSSaveLoadEventClass ShipFuelDSSaveLoadEventSink;

inline static bool ShipFuelRequestedCallback(std::string CommandParameter)
{
	if (CommandParameter.size() < 2) {
		REX::ERROR("CommandParameter is too short.");
		return false;
	}

	REX::INFO("CommandParameter: " + CommandParameter);

	std::string sOutput = "";

	if (std::strcmp(ToLowerStr(CommandParameter).c_str(), "fuelconsumption") == 0) {
		REX::INFO("detected parameter = 'fuelconsumption'");
		sOutput = GetAS3VariableAsString("GalaxyStarMapMenu", "root1.Menu_mc.JumpData_mc.FuelMeter_mc.MeterAmount_mc.amount_tf.text");
		if (sOutput.empty())
			sOutput = "-1";
		else
			sOutput = ExtractFloatFromString(sOutput);
	} else if (std::strcmp(ToLowerStr(CommandParameter).c_str(), "maxfuelrange") == 0) {
		REX::INFO("detected parameter = 'maxfuelrange'");
		sOutput = GetAS3VariableAsString("GalaxyStarMapMenu", "root1.Menu_mc.JumpData_mc.FuelMeter_mc.Data_mc.text_tf.text");
		if (sOutput.empty())
			sOutput = "-1";
		else
			sOutput = ExtractFloatFromString(sOutput);
	}

	std::string sFunctionName = "OnRequestedCallback";
	std::string asCommand = "";

	if (sOutput.empty())
		asCommand = "CGF \"" + sScriptName + "." + sFunctionName + "\"" + " -1";
	else
		asCommand = "CGF \"" + sScriptName + "." + sFunctionName + "\" " + sOutput;

	REX::INFO("Executing console command = " + asCommand);
	ExecuteCommand(asCommand.c_str());
	return true;
}

inline static bool PapyrusCallbackCommand(const RE::SCRIPT_PARAMETER* paramInfo, const char* text, RE::TESObjectREFR* thisObj, RE::TESObjectREFR* containingObj, RE::Script* script,
	RE::ScriptLocals* locals, float* result, std::uint32_t* opcodeOffsetPtr)
{
	return ShipFuelRequestedCallback(GetCommandStringArgumentFUNC_NONREF(text, 8));
}

inline static bool Install_Command_ShipFuelPapyrusCallback()
{
	bool CommandRegistered = false;
	auto firstCommand = GetFirstConsoleCommand();
	if (!firstCommand) {
		REX::ERROR("firstCommand is nullptr.");
		return false;
	}
	RE::SCRIPT_FUNCTION* a;
	a->output;
	for (RE::SCRIPT_FUNCTION* i = firstCommand; i->output < (RE::Script::kNumConsoleCommands + RE::Script::kScriptOpBase); i++) {
		if (strcmp(i->functionName, "SetSubgraphToDebug") == 0) {
			i->functionName = "ShipFuelRequestCallback";
			i->shortName = "";
			i->helpString = "added by the SFSE Plugin 'ShipFuelDataSender.dll' by LarannKiar";
			i->referenceFunction = 0;
			i->numParams = 1;
			i->executeFunction = PapyrusCallbackCommand;
			static RE::SCRIPT_PARAMETER CommandParams[] = {
				{ "menu_var_script_func", 0, true }
			};
			i->params = CommandParams;
			CommandRegistered = true;
			break;
		}
	}
	if (CommandRegistered) {
		REX::INFO("command has been successfully registered");
		return true;
	}
	REX::INFO("command couldn't be registered");
	RE::ConsoleLog::GetSingleton()->Log("ERROR: Install_Command_ShipFuelPapyrusCallback command 'ShipFuelRequestCallback' couldn't be registered. This command will not work.");
	return false;
}

/////////////////////////////////////////////////////////// SFSE ///////////////////////////////////////////////////////////

inline static void HandleOnPostDataLoad(SFSE::MessagingInterface::Message* Message) noexcept
{
	if (Message->type == SFSE::MessagingInterface::kPostDataLoad) {
		//REX::INFO(std::string(PluginVersionInfo::PROJECT.data()) + " v" + PluginVersionInfo::NAME.data() + " by " + PluginVersionInfo::AUTHORNAME.data());

		REX::INFO("kPostDataLoad");

		// INI
		if (DoesIniExist("ShipFuelDataSender") == false) {
			REX::WARN("ShipFuelDataSender.ini couldn't be found. Creating one...");
			WriteIni("ShipFuelDataSender", "Papyrus", "sScriptName", "ShipFuelDataReceiverScript");
			WriteIni("ShipFuelDataSender", "Events", "bLandingInputInProgress", "1");
			WriteIni("ShipFuelDataSender", "Events", "bMarkerGroupContainerVisibilityChanged", "1");
			WriteIni("ShipFuelDataSender", "Events", "bMarkerGroupEntryClicked", "1");
			WriteIni("ShipFuelDataSender", "Events", "bMarkerGroupEntryHoverChanged", "1");
			WriteIni("ShipFuelDataSender", "Events", "bShowRealCursor", "1");
			WriteIni("ShipFuelDataSender", "Events", "bQuickSelectChange", "1");
			WriteIni("ShipFuelDataSender", "Events", "bOnHintButtonClicked", "1");
			WriteIni("ShipFuelDataSender", "Events", "bGalaxyFocusSystem", "1");
			WriteIni("ShipFuelDataSender", "Events", "bOnCancel", "1");
			WriteIni("ShipFuelDataSender", "Events", "bOnClearRoute", "1");
			WriteIni("ShipFuelDataSender", "Events", "bOnOutpostEntrySelected", "1");
			WriteIni("ShipFuelDataSender", "Events", "bExecuteRoute", "1");
			WriteIni("ShipFuelDataSender", "Events", "bSaveLoadEvent", "1");
		}
		if (DoesIniExist("ShipFuelDataSender") == false) {
			REX::WARN("ShipFuelDataSender.ini couldn't be found and couldn't create one. Continuing with the default settings...");
		}

		// Events
		Events::StarMapMenu_LandingInputInProgress().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_LandingInputInProgressSink);
		Events::StarMapMenu_MarkerGroupContainerVisibilityChanged().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_MarkerGroupContainerVisibilityChangedSink);
		Events::StarMapMenu_MarkerGroupEntryClicked().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_MarkerGroupEntryClickedSink);
		Events::StarMapMenu_MarkerGroupEntryHoverChanged().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_MarkerGroupEntryHoverChangedSink);
		Events::StarMapMenu_ShowRealCursor().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_ShowRealCursorSink);
		Events::StarMapMenu_QuickSelectChange().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_QuickSelectChangeSink);
		Events::StarMapMenu_OnHintButtonClicked().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_OnHintButtonClickedSink);
		Events::StarMapMenu_Galaxy_FocusSystem().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_Galaxy_FocusSystemSink);
		Events::StarMapMenu_OnCancel().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_OnCancelSink);
		Events::StarMapMenu_OnClearRoute().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_OnClearRouteSink);
		Events::StarMapMenu_OnOutpostEntrySelected().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_OnOutpostEntrySelectedSink);
		Events::StarMapMenu_ExecuteRoute().GetEventSource()->RegisterSink(&ShipFuelDSStarMapMenu_ExecuteRouteSink);
		Events::SaveLoadEvent().GetEventSource()->RegisterSink(&ShipFuelDSSaveLoadEventSink);
		RE::UI::GetSingleton()->RegisterSink(&ShipFuelDSMenuOpenCloseEventSink);
		if (Install_Command_ShipFuelPapyrusCallback() == false) {
			REX::ERROR("errors occured during installation, this plugin will not properly");
		} else {
			REX::INFO("installation complete");
		}
	}
}

inline static void HandleOnMenuInterfaceEvent(RE::IMenu* theMenu)
{
	if (theMenu != nullptr) {
		if (std::strcmp("GalaxyStarMapMenu", theMenu->GetName()) == 0) {
			REX::INFO("GalaxyStarMapMenu variable filled");
			StarMapMenu = theMenu;
		}
	}
}

SFSE_PLUGIN_PRELOAD(const SFSE::PreLoadInterface* a_sfse)
{
	SFSE::Init(a_sfse);

	return true;
}

SFSE_PLUGIN_LOAD(const SFSE::LoadInterface* a_sfse)
{
	SFSE::Init(a_sfse);

	REX::INFO("Hello World!");
	SFSE::GetMessagingInterface()->RegisterListener(HandleOnPostDataLoad);
	SFSE::GetMenuInterface()->Register(HandleOnMenuInterfaceEvent);

	return true;
}
