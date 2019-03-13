script_name("Activity checker") 
script_author('Edward_Franklin')
script_version("1.21")
script_properties('work-in-pause')
--------------------------------------------------------------------
require "lib.moonloader"
local inicfg = require 'inicfg'
local sampevents = require "lib.samp.events"
--------------------------------------------------------------------
local pInfo = inicfg.load({
  info = {
    day = "01.01.2019",
    dayOnline = 0,
    dayAFK = 0,
    dayPM = 0,
    weekPM = 0,
    weekOnline = 0
  },
  weeks = {
    Monday = 0,
    Tuesday = 0,
    Wednesday = 0,
    Thursday = 0,
    Friday = 0,
    Saturday = 0,
    Sunday = 0
  },
  punish = {
  	ban = 0,
  	warn = 0,
  	kick = 0,
  	prison = 0,
  	mute = 0,
  	banip = 0,
  	rmute = 0,
  	jail = 0
  }
}, "activity-checker")

local sInfo = {
  sessionStart = 0,
  authTime = 0,
  lvlAdmin = 0,
  onlineTime = 0,
  isALogin = false
}
local whiteList = {}
local ips = {}
local punishName = {"Ban", "Warn", "Kick", "Prison", "Mute", "BanIP", "RMute", "Jail"}
local dayName = {"�����������", "�������", "�����", "�������", "�������", "�������", "�����������"}
local nick = ""
--------------------------------------------------------------------
function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampRegisterChatCommand("activity", checkActivity)
    sampRegisterChatCommand("ppv", cmd_ppv)
    sampRegisterChatCommand("ego", cmd_ego)
    sampRegisterChatCommand("gip", cmd_gip)
    --------------------=========----------------------
    if not doesDirectoryExist("moonloader\\config") then
      createDirectory("moonloader\\config")
    end
    local day = os.date("%d.%m.%y")
    local weekday = os.date("%w")
    if pInfo.info.day ~= day and tonumber(os.date("%H")) > 4 then
      local weeknum = dateToWeekNumber(pInfo.info.day)
      -----------------
      if weeknum == 1 then pInfo.weeks.Monday = pInfo.info.dayOnline
      elseif weeknum == 2 then pInfo.weeks.Tuesday = pInfo.info.dayOnline
      elseif weeknum == 3 then pInfo.weeks.Wednesday = pInfo.info.dayOnline
      elseif weeknum == 4 then pInfo.weeks.Thursday = pInfo.info.dayOnline
      elseif weeknum == 5 then pInfo.weeks.Friday = pInfo.info.dayOnline
      elseif weeknum == 6 then pInfo.weeks.Saturday = pInfo.info.dayOnline
      elseif weeknum == 0 then pInfo.weeks.Sunday = pInfo.info.dayOnline end
      atext(string.format("������� ����� ����. ���� �������� ��� (%s): %s", pInfo.info.day, secToTime(pInfo.info.dayOnline)))
      -----------------
      if weeknum == 0 then
        atext('�������� ����� ������. ���� ������� ������: %s', secToTime(pInfo.info.weekOnline))
        for key in pairs(pInfo) do
          for k in pairs(pInfo[key]) do
            pInfo[key][k] = 0
          end
        end
        --[[
        pInfo.info.weekOnline = 0
        pInfo.info.weekPM = 0
        pInfo.weeks.Monday = 0
        pInfo.weeks.Tuesday = 0
        pInfo.weeks.Wednesday = 0
        pInfo.weeks.Thursday = 0
        pInfo.weeks.Friday = 0
        pInfo.weeks.Saturday = 0
        pInfo.weeks.Sunday = 0
        pInfo.punish.mute = 0
        pInfo.punish.banip = 0
        pInfo.punish.ban = 0
        pInfo.punish.warn = 0
        pInfo.punish.kick = 0
        pInfo.punish.jail = 0
        pInfo.punish.prison = 0
        pInfo.punish.rmute = 0]]
      end
      pInfo.info.day = day
      pInfo.info.dayPM = 0
      pInfo.info.dayOnline = 0
      pInfo.info.dayAFK = 0
    end
    sInfo.authTime = os.date("%d.%m.%y %H:%M:%S")
    if doesFileExist("moonloader/config/ip_whitelist.txt") then
      for player in io.lines("moonloader/config/ip_whitelist.txt") do
        table.insert(whiteList, player:match("(%S+)"))
      end
    else
      io.open("moonloader/config/ip_whitelist.txt", "w"):close()
    end
    --------------------=========----------------------
    while not sampIsLocalPlayerSpawned() do wait(0) end
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    nick = sampGetPlayerNickname(myid)
    while true do
      wait(1000)
      --if not sampIsPlayerConnected(myid) then sInfo.isALogin = false atext("not connected") end
      if sInfo.isALogin then
        pInfo.info.dayOnline = pInfo.info.dayOnline + 1
        pInfo.info.weekOnline = pInfo.info.weekOnline + 1
        sInfo.onlineTime = sInfo.onlineTime + 1
        if sInfo.onlineTime >= 30 then
          if sInfo.sessionStart ~= 0 then
            pInfo.info.dayAFK = pInfo.info.dayAFK + (os.time() - sInfo.sessionStart - sInfo.onlineTime)
          end
          sInfo.onlineTime = 0
          sInfo.sessionStart = os.time()
          inicfg.save(pInfo, "activity-checker")
        end
      end
    end
end

function cmd_ego(params)
  if #params == 0 then
    sampAddChatMessage("�������: /ego [id/nick]", -1)
    return
  end
  local playername = ""
  local paramid = tonumber(params)
  if sampIsPlayerConnected(paramid) then playername = sampGetPlayerNickname(paramid)
  else playername = params
  end
  if checkIntable(whiteList, playername) then
    local i = 1
    while i <= #whiteList do
        if whiteList[i] == playername then
            table.remove(whiteList, i)
        else
            i = i + 1
        end
    end
    local open = io.open("moonloader/config/ip_whitelist.txt", "w")
    for k, v in pairs(whiteList) do
        open:write('\n'..v)
    end
    open:close()
    open = nil
    atext("����� "..playername.." ������� ������ �� ������ ������")
  else
    local open = io.open("moonloader/config/ip_whitelist.txt", 'a')
    open:write('\n'..playername)
    open:close()
    open = nil
    table.insert(whiteList, playername)
    atext("����� "..playername.." ������� �������� � ����� ������")
  end  
end

function cmd_gip(params)
  if #params == 0 then
    sampAddChatMessage("�������: /gip [playerid]", -1)
    return
  end
  params = tonumber(params)
  if not sampIsPlayerConnected(params) then
    sampAddChatMessage("����� �������!", 0xCCCCCC)
    return
  end
  sampSendChat("/getip "..params)
  if checkIntable(whiteList, sampGetPlayerNickname(params)) then
    atext("����� ������ � ����� ������!")
  end
end

function cmd_ppv()
  -- ips[#ips+1] = { "name" = nick, "regip" = rip, "ip" = ip }
  local zstring = "{FFFFFF}���\t{FFFFFF}R-IP\t{FFFFFF}IP\n"
  local count = #ips
  for i = 1, count do
    zstring = zstring..string.format("%s\t%s\t%s\n", ips[i].name, ips[i].regip, ips[i].lip)
  end
  lua_thread.create(function()
    sampShowDialog(811653, "{FFFFFF}����������� �������� | {954F4F}������", zstring, "�������", "�������", DIALOG_STYLE_TABLIST_HEADERS)
    while sampIsDialogActive(811653) do wait(50) end
    local _, button, list, _ = sampHasDialogRespond(811653)
    if button == 1 then
      table.remove(ips, list+1)
      cmd_ppv()
    end
  end)  
end

function checkPunishments()
  local zstring = "{FFFFFF}���������\t{FFFFFF}����������\n"
  local i = 1
  for key, value in pairs(pInfo.punish) do
    zstring = zstring..string.format("%s\t%s\n", punishName[i], value)
    i = i + 1
  end
  lua_thread.create(function()
    sampShowDialog(835163, string.format("{FFFFFF}��������� �� ������ | {954F4F}%s", nick), zstring, "�������", "�����", DIALOG_STYLE_TABLIST_HEADERS)
    while sampIsDialogActive(835163) do wait(50) end
    local _, button, _, _ = sampHasDialogRespond(835163)
    if button == 0 then
      checkActivity()
    end
  end)
end

function checkWeek()
  local daynumber = dateToWeekNumber(os.date("%d.%m.%y"))
  local i = 1
  local zstring = "{FFFFFF}����\t{FFFFFF}������\n"
  for key, value in pairs(pInfo.weeks) do
    local colour = ""
    if daynumber > 0 then
      if daynumber < i then colour = "ec3737"
      elseif daynumber == i then colour = "FFFFFF"
      else colour = "00BF80" end
    else
      if daynumber == 0 and i == 7 then colour = "FFFFFF"
      else colour = "00BF80" end
    end
    zstring = zstring..string.format("%s\t{%s}%s\n", dayName[i], colour, daynumber == i and secToTime(pInfo.info.dayOnline) or secToTime(value))
    i = i + 1
  end
  lua_thread.create(function()
    sampShowDialog(837763, string.format("{FFFFFF}���������� �� ���� ������ | {954F4F}%s", nick), zstring, "�������", "�����", DIALOG_STYLE_TABLIST_HEADERS)
    while sampIsDialogActive(837763) do wait(50) end
    local _, button, _, _ = sampHasDialogRespond(837763)
    if button == 0 then
      checkActivity()
    end
  end)
end

function checkActivity()
  local zstring = "{ffffff}��������\t{FFFFFF}��������\n"
  zstring = zstring.."����������� ������ �� ���� ������\n"
  zstring = zstring.."���������� ������� ��������� �� ������\n"
  zstring = zstring..string.format("��������� ����������\t%s ������ �����\n", sInfo.sessionStart == 0 and "-" or (os.time() - sInfo.sessionStart))
  zstring = zstring..string.format("����� �����������\t%s\n", sInfo.authTime)
  zstring = zstring..string.format("����������� � ALogin\t%s\n", sInfo.isALogin and "�������������" or "�����������")
  if sInfo.isALogin then
    zstring = zstring..string.format("������� ����������\t%s\n", sInfo.lvlAdmin)
  end  
  zstring = zstring..string.format("�������� �� �������\t%s\n", secToTime(pInfo.info.dayOnline))
  zstring = zstring..string.format("AFK �� �������\t%s\n", sInfo.sessionStart == 0 and secToTime(pInfo.info.dayAFK) or secToTime(pInfo.info.dayAFK + (os.time() - sInfo.sessionStart - sInfo.onlineTime)))
  zstring = zstring..string.format("������� �� �������\t%d\n", pInfo.info.dayPM)
  zstring = zstring..string.format("������� �� ������\t%d\n", pInfo.info.weekPM)
  zstring = zstring..string.format("�������� �� ������\t%s\n", secToTime(pInfo.info.weekOnline))
  -------
  lua_thread.create(function()
    sampShowDialog(827453, string.format("{FFFFFF}���������� | {954F4F}%s", nick), zstring, "�������", "", DIALOG_STYLE_TABLIST_HEADERS)
    while sampIsDialogActive(827453) do wait(50) end
    local _, button, list, _ = sampHasDialogRespond(827453)
    if button == 1 and list == 0 then
      checkWeek()
    elseif button == 1 and list == 1 then
      checkPunishments()
    end
  end)
end

function onScriptTerminate(script, quitGame)
  if script == thisScript() then
    if sInfo.sessionStart ~= 0 then
      pInfo.info.dayAFK = pInfo.info.dayAFK + (os.time() - sInfo.sessionStart - sInfo.onlineTime)
    end
    inicfg.save(pInfo, "activity-checker")
  end
end

function sampevents.onServerMessage(color, text)
  if text:match(nick) then
    -- OffBan[�������: Laurence_Lawson][�������: Raffaell_Vailiane][�������: upom_rodnix_JB 30][����: 30][27/12/2018  0:6]
    -- �������������: Maks_Wirense ������� Skylar_Love. �������: �������������
    -- SBan[�������: Native_Pechenkov][�������: CblH_Admina][�������: nick][27/12/2018  18:24]
    -- IOffBan[�������: Salvatore_Amici][�������: Jonathans_Wilsons][�������: akk_prodavca/ppv][27/12/2018  18:36]
    if text:match("OffBan") or text:match("������� .+ �������") or text:match("SBan") or text:match("IOffBan") then
      pInfo.punish.ban = pInfo.punish.ban + 1
    end
    -- �������������: Diego_Hudson ����� warn Dean_Voodoo. �������: cheat [ballas/6]
    -- Skot_Foster ������� �������������� �� 14:32 18.01.19 �� Laurence_Lawson
    if text:match("����� warn") or text:match("������� �������������� ��") then
      pInfo.punish.warn = pInfo.punish.warn + 1
    end
    -- �������������: William_Marshal ������ Fabio_Vercetti. �������: offtop in /ask
    if text:match("������ .+ �������") then
      pInfo.punish.kick = pInfo.punish.kick + 1
    end
    -- Kirill_Baka ������� � prison �� 60 �����. �������������: Edward_Franklin. �������: dm
    --  ������������� Jay_Rise �������� � �������� Danik_Star �� 30 �����. �������: DB
    if text:match("�������� � ��������") or text:match("������� � prison") then
      pInfo.punish.prison = pInfo.punish.prison + 1
    end
    -- ������������� Jay_Rise [476] ������������ ��� ������ Miroslav_Vhoot [501], �� 10 �����. �������: ���
    -- OffMute[�������: Laurence_Lawson][�������: Diego_Pink][�������: osk_JB][�����: 60]
    if text:match("������������ ���") or text:match("OffMute") then
      pInfo.punish.mute = pInfo.punish.mute + 1
    end
    -- Laurence_Lawson ������� IP: 178.216.230.192
    if text:match("������� IP") then
      pInfo.punish.banip = pInfo.punish.banip + 1
    end
    -- ������������� Chrisstian_Norton ����� ������� �� ������ Semyon_Lobanov' �
    if text:match("����� ������� �� ������") then
      pInfo.punish.rmute = pInfo.punish.rmute + 1
    end
  end
  -- �� �������� Edward_Franklin [541] � ������ �� 1 �����
  if text:match("�� �������� .+ � ������ ��") then
  	pInfo.punish.jail = pInfo.punish.jail + 1
  end
  if text:match("�� ���������������� ��� ��������� .+ ������") then
    sInfo.lvlAdmin = tonumber(text:match("�� ���������������� ��� ��������� (.+) ������"))
    sInfo.isALogin = true
    sInfo.sessionStart = os.time()
  end
  if text:match("����� �� "..nick) then
    pInfo.info.dayPM = pInfo.info.dayPM + 1
    pInfo.info.weekPM = pInfo.info.weekPM + 1
  end
  -- -- ����� online �� ������� ���� - 0:09 (��� ����� ���) | �������: 0
  if text:match("����� online �� ������� ����") then -- CP1251
    sampAddChatMessage(string.format(" ����� online �� ������ - %s (��� ����� ���) | �������: %d", secToTime(pInfo.info.weekOnline), pInfo.info.weekPM), 0xCCCCCC)
  end
  if text:match("Nik %[.+%]  R%-IP %[.+%]  L%-IP %[.+%]  IP %[(.+)%]") and color == -10270806 then
    local nick, rip, ip = text:match("Nik %[(.+)%]  R%-IP %[(.+)%]  L%-IP %[.+%]  IP %[(.+)%]")
    local checked = false
    for i = 1, #ips do
      if checkIntable(ips[i], nick) then
        checked = true
      end
    end
    if not checked then
      local sp = string.split(rip, ".")
      local sp2 = string.split(ip, ".")
      if sp[1] ~= sp2[1] or sp[2] ~= sp2[2] then 
        ips[#ips+1] = { name = nick, regip = rip, lip = ip }
      end  
    end   
  end
  if text:match('^ Nik %[.+%]   R%-IP %[.+%]   L%-IP %[.+%]   IP %[.+%]$') then
    local nick, rip, ip = text:match('^ Nik %[(.+)%]   R%-IP %[(.+)%]   L%-IP %[.+%]   IP %[(.+)%]$')
    local checked = false
    for i = 1, #ips do
      if checkIntable(ips[i], nick) then
        checked = true
      end
    end
    if not checked then
      local sp = string.split(rip, ".")
      local sp2 = string.split(ip, ".")
      if sp[1] ~= sp2[1] or sp[2] ~= sp2[2] then 
        ips[#ips+1] = { name = nick, regip = rip, lip = ip }
      end  
    end  
  end
end
--------------------------------------------------------------------
function checkIntable(t, key)
  for k, v in pairs(t) do
      if v == key then return true end
  end
  return false
end
function dateToWeekNumber(date) -- Start on Sunday(0)
  --print(date)
  local wsplit = string.split(date, ".")
  local day = tonumber(wsplit[1])
  local month = tonumber(wsplit[2])
  local year = tonumber(wsplit[3])
  local a = math.floor((14 - month) / 12)
  local y = year - a
  local m = month + 12 * a - 2
  return math.floor((day + y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + (31 * m) / 12) % 7)
end

function getLocalPlayerId()
  local _, id = sampGetPlayerIdByCharHandle(playerPed)
  return id
end

function getCurrentNickname(id)
  local _, myId = sampGetPlayerIdByCharHandle(playerPed)
  if id == nil then
    id = myId
  end
  if sampIsPlayerConnected(id) or id == myId then
    local name = sampGetPlayerNickname(id)
    local prefix = nil
    if string.find(name, "^%[GW%]") or string.find(name, "^%[DM%]") or string.find(name, "^%[TR%]") or string.find(name, "^%[LC%]") then
      prefix = string.match(name, "^%[([A-Z]+)%].*")
      name = string.gsub(name, "^%[[A-Z]+%]", "")
    end
    return name, prefix
  end
  return ""
end

function secToTime(sec)
  local hour, minute, second = sec / 3600, math.floor(sec / 60), sec % 60
  return string.format("%02d:%02d:%02d", math.floor(hour) ,  minute - (math.floor(hour) * 60), second)
end

function string.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function getDistanceToPlayer(playerId) 
  if sampIsPlayerConnected(playerId) then
    local result, ped = sampGetCharHandleBySampPlayerId(playerId)
    if result and doesCharExist(ped) then
      local myX, myY, myZ = getCharCoordinates(playerPed)
      local playerX, playerY, playerZ = getCharCoordinates(ped)
      return getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
    end
  end
  return -1
end

function atext(text)
  sampAddChatMessage("[Activity Helper] {FFFFFF}"..text, 0x008B8B)
end

function ARGBtoRGB(color)
    local a = bit.band(bit.rshift(color, 24), 0xFF)
    local r = bit.band(bit.rshift(color, 16), 0xFF)
    local g = bit.band(bit.rshift(color, 8), 0xFF)
    local b = bit.band(color, 0xFF)
    local rgb = b
    rgb = bit.bor(rgb, bit.lshift(g, 8))
    rgb = bit.bor(rgb, bit.lshift(r, 16))
    return rgb
end