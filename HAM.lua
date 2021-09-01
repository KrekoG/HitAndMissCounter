function HAM_init()
  if not(HAM) then
    HAM_reset()
  end
  HAM["record"] = false

  SLASH_HAM1 = "/ham"

  function SlashCmdList.HAM(msg)
    if msg =="dump" then
      DEFAULT_CHAT_FRAME:AddMessage("Dumping HAM data:")
      for key, value in pairs(HAM["data"]) do
        DEFAULT_CHAT_FRAME:AddMessage(key .. " - " .. value)
      end
    elseif msg =="sum" then
      local total = HAM["hit"] + HAM["miss"]
      DEFAULT_CHAT_FRAME:AddMessage("Total: " .. total)
      DEFAULT_CHAT_FRAME:AddMessage("Hits: " .. HAM["hit"])
      DEFAULT_CHAT_FRAME:AddMessage("Misses: " .. HAM["miss"])
      DEFAULT_CHAT_FRAME:AddMessage("Miss chance: " .. HAM["miss"] / total * 100 .. "%")
    elseif msg =="reset" then
      HAM_reset()
      DEFAULT_CHAT_FRAME:AddMessage("HAM is reset and is no longer recording")
    elseif msg =="record" then
      if HAM["record"] then
        HAM["record"] = false
        DEFAULT_CHAT_FRAME:AddMessage("HAM is no longer recording")
      else
        HAM["record"] = true
        table.insert(HAM["data"], "startup")
        DEFAULT_CHAT_FRAME:AddMessage("HAM is now recording")
      end
    else
      if HAM["record"] then
        DEFAULT_CHAT_FRAME:AddMessage("HAM is currently recording")
      else
        DEFAULT_CHAT_FRAME:AddMessage("HAM is currently not recording")
      end
      DEFAULT_CHAT_FRAME:AddMessage("/ham sum - for summary")
      DEFAULT_CHAT_FRAME:AddMessage("/ham dump - for data dump")
      DEFAULT_CHAT_FRAME:AddMessage("/ham reset - to reset the addon")
      DEFAULT_CHAT_FRAME:AddMessage("/ham record - to toggle recording")
    end
  end
end

function HAM_reset()
  HAM = {}
  HAM["record"] = false
  HAM["data"] = {}
  HAM["hit"] = 0
  HAM["miss"] = 0
end

function HAM_log(event)
  if not(HAM["record"]) then return end
  if event == "CHAT_MSG_COMBAT_SELF_HITS" then
    table.insert(HAM["data"], "hit")
    HAM["hit"] = HAM["hit"] + 1
  elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
    table.insert(HAM["data"], "miss")
    HAM["miss"] = HAM["miss"] + 1
  end
end
