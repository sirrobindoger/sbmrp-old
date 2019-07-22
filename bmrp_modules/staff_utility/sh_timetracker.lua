module( "Utime", package.seeall )

local meta = FindMetaTable( "Player" )
if not meta then return end

function meta:GetUTime()
	return self:GetNWFloat( "TotalUTime" )
end

function meta:SetUTime( num )
	self:SetNWFloat( "TotalUTime", num )
end

function meta:GetUTimeStart()
	return self:GetNWFloat( "UTimeStart" )
end

function meta:SetUTimeStart( num )
	self:SetNWFloat( "UTimeStart", num )
end

function meta:GetUTimeSessionTime()
	return CurTime() - self:GetUTimeStart()
end

function meta:GetUTimeTotalTime()
	return self:GetUTime() + CurTime() - self:GetUTimeStart()
end

function meta:GetUtimeTotalHours()
	return math.floor(self:GetUTime() + CurTime() - self:GetUTimeStart() / 60 / 60)
end

function timeToStr( time )
	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24
	tmp = math.floor( tmp / 24 )
	local d = tmp % 7
	local w = math.floor( tmp / 7 )

	return string.format( "%02iw %id %02ih %02im %02is", w, d, h, m, s )
end