extends Node

signal transition(requester, _fadeoutCallback, _fadeinCallback, _fadeoutTime, _fadeinTime)

signal activate_camera(screen)
signal activate_screen(screen)

signal boat_state_changed(boatState)

signal reset_boat()
signal caught_fish()
signal capsize_triggered()

signal create_blocking_ui(uiType)
signal blocking_ui_exit()

signal show_supplies_select()
signal show_inventory()
signal flaming_skull_purchsed()
signal cannon_purchased()
signal eye_purchased()
signal dehighlight_all(selfId)

signal ui_show_caught_fish(fishNode)
signal ui_hide_caught_fish()

signal ui_fishing_state_change(newFishingState)
signal ui_capsized_change()
signal ui_fog_warning_change(inFog)
signal cant_afford()

signal device_type_changed(deviceType)

signal hooked_QTE_success()

signal show_hooked_QTE(button)
signal hide_hooked_QTE()

signal show_pre_hook_QTE(button)
signal hide_pre_hook_QTE()

signal update_pre_hook_QTE(percentThroughQTE)
signal show_pre_hook_QTE_text(preHookTiming)
signal hide_pre_hook_QTE_text()

signal prehook_timing(timing)

signal progress_made(tier)
signal spawn_chest()

signal ui_alert_cargofull()

signal ui_alert_wallsToClose()

signal post_supplies_select(aborted)
signal ui_first_time_fish()
