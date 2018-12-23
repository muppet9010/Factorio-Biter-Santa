local Logging = {}

function Logging.Log(text)
	game.print(text)
	game.write_file("Biter_Santa_logOutput.txt", tostring(text) .. "\r\n", true)
end

return Logging
