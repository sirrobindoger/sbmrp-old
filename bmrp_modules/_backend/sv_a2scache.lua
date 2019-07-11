local cacheKeepAlive = 15
hook.Add('Initialize', 'serversecure initialization', function()
RunConsoleCommand('sv_hibernate_think', '1')
require('serversecure.core')
serversecure.EnableFileValidation(false)
serversecure.EnableThreadedSocket(true) -- receives packets from the game socket on another thread (as well as analyzing it)
serversecure.EnablePacketValidation(true) -- validates packets for having correct types, size, content, etc.
serversecure.EnableInfoCache(true) -- enable A2S_INFO response cache
serversecure.SetInfoCacheTime(cacheKeepAlive) -- seconds for cache to live (default is 5 seconds)
serversecure.EnableQueryLimiter(false) -- enable query limiter (similar to Source's one but all handled on the same place)
serversecure.SetMaxQueriesWindow(60) -- timespan over which to average query counts from IPs (default is 30 seconds)
serversecure.SetMaxQueriesPerSecond(2) -- maximum queries per second from a single IP (default is 1 per second)
serversecure.SetGlobalMaxQueriesPerSecond(120) -- maximum total queries per second (default is 60 per second)
serversecure.RefreshInfoCache()
timer.Create('a2s.CacheStartup', 5, 3, function()
serversecure.RefreshInfoCache()
end)
end)
local highestcount = 0
timer.Create('a2s.GetCurrentPlyCount', cacheKeepAlive, 0, function()
highestcount = player.GetCount()
end)
hook.Add('PlayerInitialSpawn', 'a2s.PlayerInitialSpawn', function()
if serversecure and (player.GetCount() > highestcount) then
highestcount = player.GetCount()
print('A2S Cache: buffing stats')
serversecure.RefreshInfoCache()
end
end)
