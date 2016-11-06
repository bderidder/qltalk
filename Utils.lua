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
        QLTalk:Print("nil")
    elseif (type(o) == "string") then
        QLTalk:Print(o)
    elseif (type(o) == "table") then
        QLTalk:Print(GetDumpIndentFormatting(currentIndent) .. "{\n")
        for k, v in pairs(o) do
            QLTalk:Print(GetDumpIndentFormatting(currentIndent) .. k .. ": ")
            DumpWithIndent(v, currentIndent+1)
        end
        QLTalk:Print(GetDumpIndentFormatting(currentIndent) .. "}")
    elseif (type(o) == "function") then
        QLTalk:Print("function")
    else
        QLTalk:Print(type(o))
    end
end

function QLTalk:Dump(o, label)
    if (label == nil) then
        label = type(o)
    end
    QLTalk:Print("Start variable dump - " .. label)
    DumpWithIndent(o, 0)
    QLTalk:Print("End variable dump")
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
