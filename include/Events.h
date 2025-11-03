#pragma once

namespace Events
{
	struct StarMapMenu_LandingInputInProgress
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_LandingInputInProgress>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142192) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_LandingInputInProgress>* (*)()>(addr);
			return func();
		}
	};
	struct StarMapMenu_MarkerGroupContainerVisibilityChanged
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_MarkerGroupContainerVisibilityChanged>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142193) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_MarkerGroupContainerVisibilityChanged>* (*)()>(addr);
			return func();
		}
	};

	struct StarMapMenu_MarkerGroupEntryClicked
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_MarkerGroupEntryClicked>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142194) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_MarkerGroupEntryClicked>* (*)()>(addr);
			return func();
		}
	};

		struct StarMapMenu_MarkerGroupEntryHoverChanged
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_MarkerGroupEntryHoverChanged>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142195) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_MarkerGroupEntryHoverChanged>* (*)()>(addr);
			return func();
		}
	};

	struct StarMapMenu_ShowRealCursor
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_ShowRealCursor>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142199) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_ShowRealCursor>* (*)()>(addr);
			return func();
		}
	};

	struct StarMapMenu_QuickSelectChange
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_QuickSelectChange>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142493) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_QuickSelectChange>* (*)()>(addr);
			return func();
		}
	};

	struct StarMapMenu_OnHintButtonClicked
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_OnHintButtonClicked>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142949) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_OnHintButtonClicked>* (*)()>(addr);
			return func();
		}
	};

	struct StarMapMenu_Galaxy_FocusSystem
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_Galaxy_FocusSystem>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142763) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_Galaxy_FocusSystem>* (*)()>(addr);
			return func();
		}
	};

	struct StarMapMenu_ExecuteRoute
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_ExecuteRoute>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142945) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_ExecuteRoute>* (*)()>(addr);
			return func();
		}
	};
	struct StarMapMenu_OnCancel
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_OnCancel>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142946) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_OnCancel>* (*)()>(addr);
			return func();
		}
	};
	struct StarMapMenu_OnClearRoute
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_OnClearRoute>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142947) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_OnClearRoute>* (*)()>(addr);
			return func();
		}
	};

	struct StarMapMenu_OnOutpostEntrySelected
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<StarMapMenu_OnOutpostEntrySelected>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(142950) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<StarMapMenu_OnOutpostEntrySelected>* (*)()>(addr);
			return func();
		}
	};

	struct SaveLoadEvent
	{
	public:
		[[nodiscard]] static RE::BSTEventSource<SaveLoadEvent>* GetEventSource()
		{
			REL::Relocation<uintptr_t> funcPtr{ REL::ID(129747) };
			uintptr_t                  addr = funcPtr.address();
			const auto                 func = reinterpret_cast<RE::BSTEventSource<SaveLoadEvent>* (*)()>(addr);
			return func();
		}
	};
}