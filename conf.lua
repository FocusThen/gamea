function love.conf(t)
	t.version = "11.5"
	t.identity = "game1"
	t.window.title = "Game 1"
	t.window.icon = nil

	t.window.width = 320 * 4
	t.window.height = 180 * 4
	t.window.resizable = true
	t.window.minwidth = 320
	t.window.minheight = 180

	t.modules.audio = false --	boolean	Enable the audio module.
	t.modules.event = true --	boolean	Enable the event module.
	t.modules.graphics = true --	boolean	Enable the graphics module.
	t.modules.image = true --	boolean	Enable the image module.
	t.modules.joystick = true --	boolean	Enable the joystick module.
	t.modules.keyboard = true --	boolean	Enable the keyboard module.
	t.modules.math = true --	boolean	Enable the math module.
	t.modules.mouse = false --	boolean	Enable the mouse module.
	t.modules.physics = false --	boolean	Enable the physics module.
	t.modules.sound = true --	boolean	Enable the sound module.
	t.modules.system = true --	boolean	Enable the system module.
	t.modules.timer = true --	boolean	Enable the timer module.
	t.modules.touch = false --	boolean	Enable the touch module.
	t.modules.video = true --	boolean	Enable the video module.
	t.modules.window = true --	boolean	Enable the window module.
	t.modules.thread = true --	boolean	Enable the thread module.
end
