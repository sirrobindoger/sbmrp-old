sBMRP.NPCs = sBMRP.NPCs || {}
sBMRP.NPCs.Population = 20
sBMRP.NPCs.Behavior = 1
sBMRP.NPCs.Spawnlist = {
	Vector(6393,-3341,383),
	Vector(4109,-4067,110),
	Vector(3839,-2002,239),
	Vector(5631,-2696,86),
	Vector(5893,-5913,49),
	Vector(6745,-5404,75),
}
sBMRP.XenLocList = {
	["Xen"] = true,
	["Xenian Cave"] = true,
	["Gonarch Lair"] = true,

}
--[[-------------------------------------------------------------------------
Gronarch Boss fight
---------------------------------------------------------------------------]]

local function GetGonarch()
    for k,v in pairs(ents.FindByClass("monster_gonarch")) do
        if GetLocation(v:GetPos()) == "Gonarch Lair" then
            return v
        end
    end
end
if SERVER then

	function sBMRP.NPCs.GonarchCleanup()
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "monster_babyheadcrab" or v:GetClass() == "monster_gonarch" then
				v:Remove()
			end
		end
	end

	function sBMRP.NPCs.SpawnGonarch()
		if GetGonarch() then return end
		sBMRP.NPCs.Gonarch = DramaticNPCSpawn("monster_gonarch", Vector(5783,364,290))
	end
end
if SERVER then
	--[[-------------------------------------------------------------------------
	Relationship Processesor
	---------------------------------------------------------------------------]]
	hook.Add("OnEntityCreated", "npc_logic", function(npc)
		if not npc:IsNPC() then return end
		timer.Simple(.5, function()
			for k,v in pairs(ents.GetAll()) do
				if v:IsNPC() and v:GetClass() == npc:GetClass() then
					npc:AddEntityRelationship(v,D_LI,99)
				elseif v:IsPlayer() and v:IsAlien() then
					npc:AddEntityRelationship(v,D_LI,99)
				elseif v:IsPlayer() and not v:IsAlien() then
					if GetLocation(npc:GetPos()) == "Gonarch Lair" then continue end
					if sBMRP.NPCs.Behavior >= 2 then

						npc:AddEntityRelationship(v,D_HT,99)
					else
						npc:AddEntityRelationship(v,D_LI,99)
					end
				end
			end
			npc:SetNPCState(NPC_STATE_NONE)
		end)
	end)

	hook.Add("EntityTakeDamage", "npc_logic", function(npc, data)
		ply = data:GetAttacker()

		if IsValid(ply) and ply:IsPlayer() then
			npc:AddEntityRelationship(ply,D_HT,99)
			for k,v in pairs(ents.FindInSphere(npc:GetPos(), 3000)) do
				if IsValid(v) and v:IsNPC() then
					v:AddEntityRelationship(ply,D_HT,99)
					v:SetNPCState(NPC_STATE_COMBAT)
				end
			end
		end

		if npc:IsPlayer() and npc:IsAlien() and IsValid(ply) and ply:IsPlayer() then
			for k,v in pairs(ents.FindInSphere(npc:GetPos(), 3000)) do
				if IsValid(v) and v:IsNPC() then
					v:AddEntityRelationship(ply,D_HT,99)
					v:SetNPCState(NPC_STATE_COMBAT)
				end
			end			
		end
	end)
	--[[-------------------------------------------------------------------------
	Auto-Populate Xen logic
	---------------------------------------------------------------------------]]

	function sBMRP.GetXenPopulation()
		local xenjobcount = 0
		local surveycount = 0
		local npccount = 0
		for k,ent in pairs(ents.GetAll()) do
			if ent:IsPlayer() and ent:IsAlien() and sBMRP.XenLocList[GetLocation(ent)] then
				xenjobcount = xenjobcount + 1
			elseif ent:IsPlayer() and ent:IsSurvey() and sBMRP.XenLocList[GetLocation(ent)] then
				surveycount = surveycount + 1
			elseif ent:IsNPC() and ent.PrintName and sBMRP.XenLocList[GetLocation(ent:GetPos())] then
				npccount = npccount + 1
			end
		end
		return xenjobcount, surveycount, npccount
	end

end

if CLIENT then
	local NoUseNPCs = {
		["cycler"] = true,

	}
	local npchud = sBMRP.AppendFont("bossfight", ScreenScale(10))
	timer.Create("bmrp_npc-hud", 1, 0, function()
		local foundnpc = false
		for k,v in pairs(ents.FindInSphere(LocalPlayer():GetPos(),1000)) do
			if v:IsNPC() and not NoUseNPCs[v:GetClass()] and v.PrintName then
				if not foundnpc then
					LocalPlayer():SetNWEntity("bossfight",v)
					foundnpc = v
					continue
				end
				if (foundnpc:GetPos():Distance(LocalPlayer():GetPos())) > (v:GetPos():Distance(LocalPlayer():GetPos())) and IsValid(foundnpc) then
					LocalPlayer():SetNWEntity("bossfight",v)
					foundnpc = v
				end
			end
		end
		if not foundnpc then
			LocalPlayer():SetNWEntity("bossfight",nil)
		end
	end )

	hook.Add("HUDPaint", "HUDPaint_DrawABox", function()
		local npc = LocalPlayer():GetNWEntity("bossfight",nil)
		if npc and IsValid(npc) then
			--positional processing
			surface.SetFont(npchud)
			local npcname = npc.PrintName
			local textsize = surface.GetTextSize(npcname)
			local boxlength = 200
			--print(surface.GetTextSize(npcname))
			local diff = boxlength-textsize

			local pos = 553 + math.abs(diff)/1.7
			if diff < 0 then
				boxlength = boxlength + math.abs(diff)
			end	
			surface.SetTextPos(ScrW()*(753/1280), 0 )
			surface.DrawText(textsize .. "(DEBUG)")
			local healthpercent = npc:Health()/npc:GetMaxHealth()
			-- Background	
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( ScrW() *(553/1280), ScrH()*(0/720), ScrW() *(boxlength/1280),ScrH() *(40/720))
			-- Header
			surface.SetDrawColor( 50,50,50, 255 )
			surface.DrawRect( ScrW() *(553/1280), ScrH()*(0/720),ScrW() *(boxlength/1280),ScrH()*(20/720) )
			-- Health
			surface.SetDrawColor( 237, 24, 24, 156 )
			surface.DrawRect( ScrW() *(553/1280), ScrH()*(20/720),ScrW() *((healthpercent*boxlength)/1280), ScrH()*(20/720) )

			surface.SetTextColor(math.random(0,100), 255, 0)
			surface.SetTextPos(ScrW() *(pos/1280),0)
			surface.DrawText(npcname)
			-- subtext 1
			surface.SetTextColor(255,255,255)
			surface.SetTextPos(ScrW() *(633/1280),ScrH()*(20/720))
			surface.DrawText(math.Round(healthpercent*100) .. "%")
		end
	end)
	--hook.Remove("HUDPaint", "HUDPaint_DrawABox")
end