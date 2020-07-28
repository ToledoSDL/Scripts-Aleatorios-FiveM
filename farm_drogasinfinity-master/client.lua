local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
emP = Tunnel.getInterface("emp_families")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local blips = true
local servico = false
local selecionado = 0
local CoordenadaX = -455.01 --coordenada de onde pega o serviço
local CoordenadaY = -1689.59
local CoordenadaZ = 19.29
local quantidade = 0
local porcentagem = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCAIS ENTREGA 
-----------------------------------------------------------------------------------------------------------------------------------------
local locs = {
	[1] = { ['x'] = 478.32, ['y'] = -107.83, ['z'] = 63.16 },
	[2] = { ['x'] = 879.77, ['y'] = -205.16, ['z'] = 71.98 },
	[3] = { ['x'] = 1247.77, ['y'] = -349.58, ['z'] = 69.21 }, 
	[4] = { ['x'] = -263.05, ['y'] = 202.44, ['z'] = 85.37 }, 
	[5] = { ['x'] = -1402.05, ['y'] = -452.01, ['z'] = 34.49 }, 
	[6] = { ['x'] = -1776.42, ['y'] = -670.95, ['z'] = 10.39 }, 
	[7] = { ['x'] = -3078.06, ['y'] = 658.99, ['z'] = 11.67 }, 
	[8] = { ['x'] = -794.54, ['y'] = 354.05, ['z'] = 87.88 } 
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRABALHAR
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if not servico then
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(CoordenadaX,CoordenadaY,CoordenadaZ)
			local distance = GetDistanceBetweenCoords(CoordenadaX,CoordenadaY,cdz,x,y,z,true)

			if distance <= 3 then
				DrawMarker(21,CoordenadaX,CoordenadaY,CoordenadaZ-0.6,0,0,0,0.0,0,0,0.5,0.5,0.4,147,60,204,50,0,0,0,1)
				if distance <= 1.2 then
					drawTxt("PRESSIONE  ~r~E~w~  PARA INICIAR AS ENTREGAS",4,0.5,0.93,0.50,255,255,255,180)
					if IsControlJustPressed(0,38) and emP.checkPermission() then
						servico = true
						selecionado = math.random(8) --CASO VOCE ADICIONE MAIS LOCAIS DE ENTREGA DEVERÁ COLOCAR AQUI O NUMERO TOTAL 
						CriandoBlip(locs,selecionado)
						emP.Quantidade()
						porcentagem = math.random(100)					
						
						TriggerEvent("Notify","sucesso","Você entrou em serviço.")
						TriggerEvent("Notify","importante","Vá até o próximo local e entregue <b>"..quantidade.."x Drogas</b>.")
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTREGAS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if servico then
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(locs[selecionado].x,locs[selecionado].y,locs[selecionado].z)
			local distance = GetDistanceBetweenCoords(locs[selecionado].x,locs[selecionado].y,cdz,x,y,z,true)

			if distance <= 3 then
				DrawMarker(21,locs[selecionado].x,locs[selecionado].y,locs[selecionado].z-0.6,0,0,0,0.0,0,0,0.5,0.5,0.4,147,60,204,50,0,0,0,1)
				if distance <= 1.2 then
					drawTxt("PRESSIONE  ~r~E~w~  PARA ENTREGAR AS METANFETAMINA",4,0.5,0.93,0.50,255,255,255,180)
					if IsControlJustPressed(0,38) then
						if emP.checkPayment() then
							
							porcentagem = math.random(1,100)

							if porcentagem >= 1 and porcentagem <= 80 then
								emP.MarcarOcorrencia()
							end
							RemoveBlip(blips)
							backentrega = selecionado
							while true do
								if backentrega == selecionado then
									selecionado = math.random(8)
								else
									break
								end
								Citizen.Wait(1)
							end
							
							CriandoBlip(locs,selecionado)
							TriggerEvent("Notify","importante","Vá até o próximo local e entregue <b>"..quantidade.."x Metanfetamina</b>.")
						end
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELAR
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if servico then
			if IsControlJustPressed(0,121) then
			TriggerEvent("Notify","importante","Vá até o próximo local e entregue <b>"..quantidade.."x metanfetamina</b>.")
			elseif IsControlJustPressed(0,168) then
				servico = false
				RemoveBlip(blips)
				TriggerEvent("Notify","aviso","Você saiu de serviço.")
			end
		end
	end
end)

RegisterNetEvent("quantidade-metanfetamina") --EVENTO DO SERVIDOR
AddEventHandler("quantidade-metanfetamina",function(status)
    quantidade = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function CriandoBlip(locs,selecionado)
	blips = AddBlipForCoord(locs[selecionado].x,locs[selecionado].y,locs[selecionado].z)
	SetBlipSprite(blips,1)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Entrega de Metanfetamina")
	EndTextCommandSetBlipName(blips)
end
