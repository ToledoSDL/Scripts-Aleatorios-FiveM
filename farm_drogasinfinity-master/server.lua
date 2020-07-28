local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRPclient = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
emP = {}
Tunnel.bindInterface("emp_families",emP) --aqui voce altera o nome da pasta se for necessário
local idgens = Tools.newIDGenerator()
local blips = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
function emP.checkPermission()
	local source = source
	local user_id = vRP.getUserId(source)
	return not (vRP.hasPermission(user_id,"gangues.permissao") or vRP.hasPermission(user_id,"policia.permissao") or vRP.hasPermission(user_id,"paramedico.permissao")) -- aqui voce muda as permissões que NÃO PODERÃO vender a droga.
end

local quantidade = {}
function emP.Quantidade()
	local source = source
	if quantidade[source] == nil then
		quantidade[source] = math.random(5,8)
	end
	TriggerClientEvent("quantidade-metanfetamina",source,parseInt(quantidade[source])) --"quantidade-metanfetamina é o nome do evento no client."
end

function emP.checkPayment()
	emP.Quantidade()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.tryGetInventoryItem(user_id,"metanfetamina",quantidade[source]) then --aqui verifica os itens no inventario do player e remove eles ao vende a droga
			vRP.giveInventoryItem(user_id,"dinheirosujo",math.random(440,523)*quantidade[source]) --aqui configura-se o que será pago ao player 
			quantidade[source] = nil
			emP.Quantidade()
			return true
		else
			TriggerClientEvent("Notify",source,"negado","Você precisa de <b>"..quantidade[source].."x Metanfetamina</b>.")
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- POLICIA -- AQUI FICA O ALERTA DA POLICIA.
-----------------------------------------------------------------------------------------------------------------------------------------
local blips = {}
function emP.MarcarOcorrencia()
	local source = source
	local user_id = vRP.getUserId(source)
	local x,y,z = vRPclient.getPosition(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		local soldado = vRP.getUsersByPermission("policia.permissao")
		for l,w in pairs(soldado) do
			local player = vRP.getUserSource(parseInt(w))
			if player then
				async(function()
					local id = idgens:gen()
					blips[id] = vRPclient.addBlip(player,x,y,z,10,84,"Ocorrência",0.5,false)
					vRPclient._playSound(player,"CONFIRM_BEEP","HUD_MINI_GAME_SOUNDSET")
					TriggerClientEvent('chatMessage',player,"911",{64,64,255},"Recebemos uma denuncia de tráfico de drogas, verifique o ocorrido.")
					SetTimeout(20000,function() vRPclient.removeBlip(player,blips[id]) idgens:free(id) end)
				end)
			end
		end
	end
end
