local addonName, QLTalk = ...
local L = QLTalk.L

function QLTalk:error()
    print("You are not in a guild and cannot use this addon. Bummer...")
end

local function GetDumpIndentFormatting(indent)
    return string.rep(" ", indent)
end

local function DumpWithIndent(o, currentIndent)
    if (type(o) == "nil") then
        QLTalk:Debug("nil")
    elseif (type(o) == "string") then
        QLTalk:Debug(o)
    elseif (type(o) == "table") then
        QLTalk:Debug(GetDumpIndentFormatting(currentIndent) .. "{\n")
        for k, v in pairs(o) do
            QLTalk:Debug(GetDumpIndentFormatting(currentIndent) .. k .. ": ")
            DumpWithIndent(v, currentIndent+1)
        end
        QLTalk:Debug(GetDumpIndentFormatting(currentIndent) .. "}")
    elseif (type(o) == "function") then
        QLTalk:Debug("function")
    else
        QLTalk:Debug(type(o))
    end
end

function QLTalk:Dump(o, label)
    if (label == nil) then
        label = type(o)
    end
    QLTalk:Debug("Start variable dump - " .. label)
    DumpWithIndent(o, 0)
    QLTalk:Debug("End variable dump")
end

function QLTalk:Debug(debugMessage)
    if (QLTalk.DEBUG) then
        if (debugMessage ~= nil) then
          QLTalk:Print("DEBUG - " .. debugMessage)
        else
          QLTalk:Print("DEBUG - <nil>")
        end
    end
end
