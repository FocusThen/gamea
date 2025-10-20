DEBUG = false
isDev = true

function love.conf(t)
	t.version = "11.5"
	t.identity = "game1"
	t.window.title = "Game 1"
	t.window.icon = nil
  t.window.vsync = -1
  t.window.highdpi = true
  t.window.width = 624
  t.window.height = 672
  t.window.minwidth = 416
  t.window.minheight = 448
  t.window.resizable = true
end
