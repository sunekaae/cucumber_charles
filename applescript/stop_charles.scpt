on run argv
	tell application "Finder"
		set procExists to process "Charles" exists
	end tell
	if procExists then
		try
			tell application "Charles"
				activate
			end tell
			delay 2
			if isCharlesInForeground() is true then
				tell application "System Events"
					key down {command}
					keystroke "q"
					key up {command}
					delay 2
				end tell
			else
				return "not in foreground on step 2"
			end
			if isCharlesInForeground() is true then
				tell application "System Events"
					keystroke return
					delay 2			
				end tell
			else
				return "not in foreground on step 3"
			end
			if isCharlesInForeground() is true then
				tell application "System Events"
					keystroke item 1 of argv
					keystroke return
				end tell
			else
				return "not in foreground on step 4"
			end
		end try
		return "done"
	else
		return "charles not running"
	end if
end run

on isCharlesInForeground()
	return isAppInForeground("Charles")
end isCharlesInForeground

on isAppInForeground(appName)
	tell application "System Events" to (name of processes) contains appName

	tell application "System Events"
	set frontApp to name of first application process whose frontmost is true
	end tell
	if frontApp equals appName then
		return true
	else
		return false
	end
end isAppInForeground
