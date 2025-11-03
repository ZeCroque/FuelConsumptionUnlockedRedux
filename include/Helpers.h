#pragma once

#include <cstringt.h>

#include "GameTypesEx.h"

#undef ERROR

inline static void ExecuteCommand(const char* asCommand)
{
	static REL::Relocation<void**> ConsoleRTTI{ REL::ID(808335) };
	using func_t = void (*)(const void*, const char*);
	REL::Relocation<func_t> func{ REL::ID(166307) };
	func(*ConsoleRTTI, asCommand);
}

inline static std::string GetAddressAsHex(unsigned long long address, bool bAsOffset = false)
{
    if (address <= 0)
        return "";
    std::string s;
    if (bAsOffset) {
        auto offset = address - REL::Module::GetSingleton()->base();
        if (offset <= 0) {
            REX::ERROR("calculated offset <= 0 --> [" + std::to_string(offset) + "]");
        }
        else {
            s = std::format("{:x}", offset);
            if (s.empty())
                return "";
            std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) -> char { return static_cast<char>(::toupper(c)); });
            s = "Starfield.exe + 0x" + s;
            return s;
        }
    }
    s = std::format("{:x}", address);
    if (s.empty())
        return "";
    std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) -> char { return static_cast<char>(::toupper(c)); });
    return s;
}

template <typename T>
inline static std::string GetObjectAddressAsHex(T* form, bool bAsOffset = false)
{
    if (!form)
        return "";
    return GetAddressAsHex(reinterpret_cast<unsigned long long>(form), bAsOffset);
}

template <typename T>
inline static BSTArrayCustom<T>* GetAsBSTArrayCustom(RE::BSTArray<T>* arr)
{
    if (!arr)
        return nullptr;
    return reinterpret_cast<BSTArrayCustom<T>*>(arr);
}

inline static RE::IMenu* GetMenu(std::string sMenuName, RE::UI* UIPassThru = nullptr)
{
    if (sMenuName.empty())
        return nullptr;
    RE::IMenu* theMenu     = nullptr;
    RE::UI*       UI          = nullptr;
    if (UIPassThru)
        UI = UIPassThru;
    else
        UI = RE::UI::GetSingleton();
    auto menuPtr = &UI->menuStack;
	auto menuArray = GetAsBSTArrayCustom(menuPtr);
	for (uint32_t i = 0; i < menuArray->size(); i++) {
		auto menu = menuArray->at(i);
        if (!menu)
            continue;
        if (std::strcmp(menu->GetName(), sMenuName.c_str()) == 0) {
            theMenu = menu.get();
        }
    }
    if (!theMenu) {
        REX::ERROR("theMenu with sMenuName [" + sMenuName + "] is nullptr.");
        return nullptr;
    }
    REX::DEBUG("result --> [" + GetObjectAddressAsHex(theMenu) + "] | params: sMenuName [" + sMenuName + "], UIPassThru [" + GetObjectAddressAsHex(UIPassThru) + "]");
    return theMenu;
}

inline static RE::Scaleform::GFx::ASMovieRootBase* GetMenuRoot(RE::IMenu* theMenu)
{
    if (!theMenu)
        return nullptr;
    auto root = theMenu->uiMovie.get()->asMovieRoot.get();
    if (!root) {
        REX::ERROR("theMenu.root couldn't be found for IMenu at address: " + GetObjectAddressAsHex(theMenu));
        return nullptr;
    }
    REX::DEBUG("result --> [" + GetObjectAddressAsHex(root) + "] | params: theMenu [" + GetObjectAddressAsHex(theMenu) + "]");
    return root;
}

inline static std::string GetAS3VariableAsString(std::string MenuName, std::string VarPath, RE::UI* UIPassThru = nullptr)
{
    if (MenuName.empty() || VarPath.empty())
        return "";
    auto theMenu = GetMenu(MenuName, UIPassThru);
    if (!theMenu) {
        REX::ERROR("theMenu is nullptr for MenuName: " + MenuName);
        return "";
    }
    auto menuRoot = GetMenuRoot(theMenu);
    if (!menuRoot) {
        REX::ERROR("menuRoot is nullptr for IMenu at address: " + GetAddressAsHex(reinterpret_cast<uintptr_t>(theMenu)));
        return "";
    }
    RE::Scaleform::GFx::Value* GFxValue = new RE::Scaleform::GFx::Value();
    if (!GFxValue) {
        REX::ERROR("GFxValue is nullptr");
        return "";
    }
    bool bVarFound = menuRoot->GetVariable(GFxValue, VarPath.c_str());
    if (!bVarFound) {
        REX::ERROR("bVarFound is false");
        return "";
    }
    std::string sValue;
    if (GFxValue->IsString()) {
		sValue = GFxValue->GetString();
    }
    else if (GFxValue->IsStringW()) {
        auto ch = GFxValue->GetStringW();
        if (!ch) {
            REX::ERROR("ch is nullptr");
        }
        else {
            std::ostringstream os;
            while (*ch != L'\0') {
                os << std::use_facet<std::ctype<wchar_t>>(std::locale()).narrow(*ch++, 'n');
            }
            sValue = os.str();
        }
    }
    else if (GFxValue->IsBoolean()) {
        auto ch = GFxValue->GetBoolean();
        if (ch == true)
            sValue = "True";
        else
            sValue = "False";
    }
    else if (GFxValue->IsInt()) {
        auto ch = GFxValue->GetInt();
        sValue  = std::to_string(ch);
    }
    else if (GFxValue->IsUInt()) {
        auto ch = GFxValue->GetUInt();
        sValue  = std::to_string(ch);
    }
    else if (GFxValue->IsNumber()) {
        auto ch = GFxValue->GetNumber();
        sValue  = std::to_string(ch);
    }
    if (sValue.size() > 0) {
        return sValue;
    }
    REX::ERROR("returning empty string");
    return "";
}

class LKIniRead
{
public:
    // LKIniRead(const char* szFileName);
    // int         RInt(const char* szSection, const char* szKey, int iDefaultValue);
    // float       RFloat(const char* szSection, const char* szKey, float fltDefaultValue);
    // bool        RBool(const char* szSection, const char* szKey, bool bolDefaultValue);
    // const char* RStr(const char* szSection, const char* szKey, const const char* szDefaultValue);

    LKIniRead(const char* szFileName)
    {
        memset(m_szFileName, 0x00, 255);
        memcpy(m_szFileName, szFileName, strlen(szFileName));
    }

    inline int RInt(const char* Section, const char* Key, int iDefValue)
    {
        int iValue = GetPrivateProfileInt(Section, Key, iDefValue, m_szFileName);
        return iValue;
    }

    inline float RFloat(const char* Section, const char* Key, float fDefValue)
    {
        char  out[255];
        char  def[255];
        float fValue;
        sprintf_s(def, "%f", fDefValue);
        GetPrivateProfileString(Section, Key, def, out, 255, m_szFileName);
        fValue = static_cast<float>(atof(out));
        return fValue;
    }

    inline bool RBool(const char* Section, const char* Key, bool bDefValue)
    {
        char out[255];
        char def[255];
        bool bValue;
        sprintf_s(def, "%s", bDefValue ? "1" : "0");
        GetPrivateProfileString(Section, Key, def, out, 255, m_szFileName);
        bValue = (strcmp(out, "1") == 0 || strcmp(out, "True") == 0 || strcmp(out, "true") == 0) ? 1 : 0;
        return bValue;
    }

    inline const char* RStr(const char* Section, const char* Key, const char* chDefValue)
    {
        char* c   = new char[10000];
        LPSTR out = c;
        memset(out, 0, 10000);
        GetPrivateProfileString(Section, Key, chDefValue, out, 10000, m_szFileName);
        return out;
    }

private:
    char m_szFileName[255];
};

inline static std::string ReadIni(std::string FileName, std::string Section, std::string Key, std::string bOptionalSubfolder = "")
{
    if (FileName.empty() || Section.empty() || Key.empty())
        return "";
    std::string DefValue = "";
    std::string pt1      = ".\\Data\\SFSE\\Plugins\\";
    if (!bOptionalSubfolder.empty())
        pt1 = bOptionalSubfolder;
    std::string pt2  = FileName.c_str();
    std::string pt3  = ".ini";
    const auto  path = pt1 + pt2 + pt3;
    if (std::filesystem::exists(path.c_str()) == false) {
        return "";
    }
    LKIniRead   INI(path.c_str());
    std::string ReturnString = INI.RStr(Section.c_str(), Key.c_str(), DefValue.c_str());
    if (ReturnString.empty() || ReturnString.length() == 0) {
        return "";
    }
    return ReturnString;
}

inline static std::string ToLowerStr(std::string str)
{
    std::transform(str.begin(), str.end(), str.begin(), [](unsigned char c) -> char { return static_cast<char>(::tolower(c)); });
    return str;
}

inline static RE::SCRIPT_FUNCTION* GetFirstConsoleCommand()
{
    // Starfield.exe + 0x0557F0D0 in v1.8.88.0 (REL::ID = 841465). Script::SCRIPT_FUNCTION*.
    static REL::Relocation<unsigned long long> FirstConsoleCommand{ REL::ID(841465) };
    unsigned long long                         k = FirstConsoleCommand.get();
    RE::SCRIPT_FUNCTION*               j = reinterpret_cast<RE::SCRIPT_FUNCTION*>(k);
    if (!j) {
        REX::ERROR("found command is nullptr");
        return nullptr;
    }
    else {
        REX::DEBUG("found console command at " + GetObjectAddressAsHex(j, true));
        return j;
    }
    return nullptr;
}

inline static bool DoesIniExist(std::string FileName, std::string bOptionalSubfolder = "")
{
    if (FileName.empty())
        return false;
    std::string pt1 = ".\\Data\\SFSE\\Plugins\\";
    if (!bOptionalSubfolder.empty())
        pt1 = bOptionalSubfolder;
    std::string pt2  = FileName.c_str();
    std::string pt3  = ".ini";
    const auto  path = pt1 + pt2 + pt3;
    if (std::filesystem::exists(path.c_str()) == true) {
        return true;
    }
    return false;
}

class LKIniWrite
{
public:
    // LKIniWrite(const char* szFileName);
    // void WInt(const char* szSection, const char* szKey, int iValue);
    // void WFloat(const char* szSection, const char* szKey, float fltValue);
    // void WBool(const char* szSection, const char* szKey, bool bolValue);
    // void WStr(const char* szSection, const char* szKey, const char* szValue);

    LKIniWrite(const char* szFileName)
    {
        memset(m_szFileName, 0x00, 255);
        memcpy(m_szFileName, szFileName, strlen(szFileName));
    }

    void WInt(const char* Section, const char* Key, int iValue)
    {
        char chValue[255];
        sprintf_s(chValue, "%d", iValue);
        WritePrivateProfileString(CA2CT(Section), CA2CT(Key), CA2CT(chValue), CA2CT(m_szFileName));
    }

    void WFloat(const char* Section, const char* Key, float fValue)
    {
        char chValue[255];
        sprintf_s(chValue, "%f", fValue);
        WritePrivateProfileString(CA2CT(Section), CA2CT(Key), CA2CT(chValue), CA2CT(m_szFileName));
    }

    void WBool(const char* Section, const char* Key, bool bValue)
    {
        char chValue[255];
        sprintf_s(chValue, "%s", bValue ? "1" : "0");
        WritePrivateProfileString(CA2CT(Section), CA2CT(Key), CA2CT(chValue), CA2CT(m_szFileName));
    }

    void WStr(const char* Section, const char* Key, const char* chValue) { WritePrivateProfileString(CA2CT(Section), CA2CT(Key), CA2CT(chValue), CA2CT(m_szFileName)); }

private:
    char m_szFileName[255];
};

inline static bool WriteIni(std::string FileName, std::string Section, std::string Key, std::string Value, std::string bOptionalSubfolder = "")
{
    if (FileName.empty() || Section.empty() || Key.empty())
        return false;
    std::string pt1 = ".\\Data\\SFSE\\Plugins\\";
    if (!bOptionalSubfolder.empty())
        pt1 = bOptionalSubfolder;
    std::string pt2  = FileName.c_str();
    std::string pt3  = ".ini";
    const auto  path = pt1 + pt2 + pt3;
    LKIniWrite  iniWriter(path.c_str());
    iniWriter.WStr(Section.c_str(), Key.c_str(), Value.c_str());
    if (std::filesystem::exists(path.c_str()) == true) {
        LKIniRead   INI(path.c_str());
        std::string theString = INI.RStr(Section.c_str(), Key.c_str(), Value.c_str());
        if (strcmp(theString.c_str(), Value.c_str()) == 0) {
            return true;
        }
    }
    return false;
}