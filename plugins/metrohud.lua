local PLUGIN = PLUGIN

PLUGIN.name = "Metro HUD"
PLUGIN.author = "Keller"
PLUGIN.description = "Adds a MetroRP HUD."
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2026 Keller

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

hook.Add("InitializedPlugins", "MetroHUD_Initialize", function()
    if (CLIENT) then
        if not ix.bar or not ix.bar.Add then return end
        ix.bar.Add(function()
            local ply = LocalPlayer()
            local char = ply:GetCharacter()

            if not char then return end

            local hunger = math.Clamp(char:GetHunger() or char:GetData("hunger", 0), 0, 100)

            return hunger / 100
        end, 
        Color(255, 165, 0), 
        4, 
        "hunger")

        ix.bar.Add(function()
            local ply = LocalPlayer()
            local char = ply:GetCharacter()

            if not char then return end

            local thirst = math.Clamp(char:GetThirst() or char:GetData("thirst", 0), 0, 100)

            return thirst / 100
        end, 
        Color(0, 165, 255), 
        4, 
        "thirst")
    end
end)