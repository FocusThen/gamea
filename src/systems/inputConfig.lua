local inputConfig = {}

-- Common input bindings that multiple states use
inputConfig.commonMenuControls = {
	up = { "key:up", "key:w", "axis:lefty-", "button:dpup" },
	down = { "key:down", "key:s", "axis:lefty+", "button:dpdown" },
	left = { "key:left", "key:a", "axis:leftx-", "button:dpleft" },
	right = { "key:right", "key:d", "axis:leftx+", "button:dpright" },
	select = { "key:space", "key:return", "key:z", "button:a" },
	quit = { "key:escape", "button:b" },
	back = { "key:escape", "button:b" },
	continue_key = {
		"key:space",
		"key:return",
		"key:z",
		"button:a",
	},
}

-- Create standard menu bindings
function inputConfig.createMenuBindings()
	return baton.new({
		controls = inputConfig.commonMenuControls,
		joystick = love.joystick.getJoysticks()[1],
	})
end

-- Create simple bindings with custom controls
function inputConfig.createSimpleBindings(controls)
	return baton.new({
		controls = controls,
		joystick = love.joystick.getJoysticks()[1],
	})
end

return inputConfig

