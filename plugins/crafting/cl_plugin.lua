if not CRAFTING_CATEGORY_LABELS then
	include("sh_categories.lua")
end

local CATEGORY_LABELS = CRAFTING_CATEGORY_LABELS or {
	["All"] = "All",
	["Crafting"] = "Crafting",
	["Metal Breakdown"] = "Metal Breakdown",
	["Metal Upgrade"] = "Metal Upgrade",
	["Miscellaneous"] = "Miscellaneous",
	["Schematics"] = "Schematics"
}

surface.CreateFont("WastelandTiny", {
	font = "Bahnschrift SemiLight Condensed",
	extended = false,
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("WastelandMedium", {
	font = "Bahnschrift SemiLight Condensed",
	extended = false,
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("WastelandStandard", {
	font = "Bahnschrift SemiLight Condensed",
	extended = false,
	size = 40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

-- Rejestracja tłumaczeń w natywny sposób dla Helixa
ix.lang.AddTable("english", {
	wsHoverInfo = "Hover over the icon of an item to get more information about it.",
	wsAll = "All",
	wsRequirements = "Requirements",
	wsResults = "Results",
	wsRequiredSkills = "Required Skills",
	wsNoRequiredSkills = "No Required Skills",
	wsUnlockedBlueprint = "Unlocked by Blueprint",
})

ix.lang.AddTable("polish", {
	wsHoverInfo = "Najedź na ikonę przedmiotu, aby wyświetlić więcej informacji.",
	wsAll = "Wszystkie",
	wsRequirements = "Wymagania",
	wsResults = "Rezultat",
	wsRequiredSkills = "Wymagane Umiejętności",
	wsNoRequiredSkills = "Brak Wymaganych Umiejętności",
	wsUnlockedBlueprint = "Odblokowane przez Schemat",
})

--------------------------------------------------------------------------------
-- GŁÓWNA RAMKA CRAFTINGU
--------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	ix.gui.crafting = self
	
	self:SetSize(ScrW() / 2, ScrH() / 1.5)
	self:Center()

	self.infolabel = self:Add("DLabel")
	self.infolabel:Dock(TOP)
	self.infolabel:SetContentAlignment(5)
	self.infolabel:SetExpensiveShadow(1, Color(0, 0, 0, 255))
	self.infolabel:SetText(L("wsHoverInfo"))
	self.infolabel:SetFont("WastelandMedium")
	self.infolabel:SizeToContents()
	self.infolabel:DockMargin(0, 5, 0, 10)

	self.MainContent = self:Add("DPanel")
	self.MainContent:Dock(FILL)
	self.MainContent:DockMargin(10, 0, 10, 10)
	self.MainContent.Paint = function() end

	self.CategoryPanel = self.MainContent:Add("DPanel")
	self.CategoryPanel:Dock(LEFT)
	self.CategoryPanel:DockMargin(0, 0, 10, 0)
	self.CategoryPanel:SetWide(190)
	self.CategoryPanel.Paint = function(p, w, h)
		surface.SetDrawColor(18, 18, 18, 220)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	self.CategoryList = self.CategoryPanel:Add("DScrollPanel")
	self.CategoryList:Dock(FILL)
	self.CategoryList.Paint = function() end

	self.CraftingScroll = self.MainContent:Add("DScrollPanel")
	self.CraftingScroll:Dock(FILL)
	self.CraftingScroll.Paint = function(p, w, h)
		surface.SetDrawColor(25, 25, 25, 220)
		surface.DrawRect(0, 0, w, h)
	end

	self.CraftingGrid = self.CraftingScroll:Add("DIconLayout")
	self.CraftingGrid:Dock(TOP)
	self.CraftingGrid:SetSpaceX(12)
	self.CraftingGrid:SetSpaceY(12)
	self.CraftingGrid:SetBorder(8)

	self:PopulateCategories()
	self:FilterRecipes()
end

function PANEL:PopulateCategories()
	local categories = { ["All"] = true }
	local char = LocalPlayer():GetCharacter()
	local blueprints = char and char:GetData("blueprints", {}) or {}

	for k, v in pairs(STORED_RECIPES) do
		if v["blueprint"] and not table.HasValue(blueprints, v["blueprint"]) then
			continue
		end

		local firstResultID = v["results"] and next(v["results"])
		local itemTable = firstResultID and ix.item.Get(firstResultID)
		local category = v["category"] or (itemTable and itemTable.category) or "Other"
		categories[category] = true
	end

	self.activeCategory = "All"
	self.categoryButtons = {}

	local sortedCats = {}
	for cat, _ in pairs(categories) do
		if cat ~= "All" then
			table.insert(sortedCats, cat)
		end
	end
	table.sort(sortedCats)
	table.insert(sortedCats, 1, "All")

	self.CategoryList:Clear()

	for _, category in ipairs(sortedCats) do
		local btn = self.CategoryList:Add("DButton")
		btn:Dock(TOP)
		btn:DockMargin(6, 0, 6, 6)
		btn:SetTall(34)
		local label = CATEGORY_LABELS[category] or category
		btn:SetText(category == "All" and L("wsAll") or L(label))
		btn:SetTextColor(Color(255, 255, 255))
		btn:SetFont("WastelandTiny")
		btn.category = category

		btn.DoClick = function()
			self.activeCategory = category
			self:FilterRecipes()

			for _, b in ipairs(self.categoryButtons) do
				b.selected = (b == btn)
			end
		end

		btn.Paint = function(pnl, w, h)
			local isSelected = self.activeCategory == category
			local col = isSelected and (ix.config.Get("color") or Color(0, 150, 0, 160)) or (pnl:IsHovered() and Color(55, 55, 55, 220) or Color(32, 32, 32, 220))
			surface.SetDrawColor(col)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		table.insert(self.categoryButtons, btn)
	end
end

function PANEL:FilterRecipes()
	self.CraftingGrid:Clear()

	local char = LocalPlayer():GetCharacter()
	if not char then return end

	local blueprints = char:GetData("blueprints", {})

	for k, v in pairs(STORED_RECIPES) do
		if v["blueprint"] and not table.HasValue(blueprints, v["blueprint"]) then
			continue
		end

		local firstResultID = v["results"] and next(v["results"])
		local itemTable = firstResultID and ix.item.Get(firstResultID)
		local category = v["category"] or (itemTable and itemTable.category) or "Other"

		if self.activeCategory == "All" or self.activeCategory == category then
			local item = self.CraftingGrid:Add("CraftingListItem")
			item:SetItem(v["id"], v["name"], v["model"], v["desc"], v["req"], v["results"], v["skill"], v["blueprint"] or false, v["guns"] or false, v["entity"] or false)
		end
	end
end

vgui.Register("CraftingListFrame", PANEL, "DPanel")

--------------------------------------------------------------------------------
-- KAFELEK PRZEDMIOTU (GRID ITEM)
--------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	self:SetSize(140, 140)

	self.spawnicon = self:Add("SpawnIcon")
	self.spawnicon:SetSize(92, 92)
	self.spawnicon:SetPos(24, 12)
	
	self.spawnicon.DoClick = function()
		self:DoClick()
	end

	self.labelitem = self:Add("DLabel")
	self.labelitem:SetPos(8, 95)
	self.labelitem:SetSize(124, 48)
	self.labelitem:SetFont("WastelandTiny")
	self.labelitem:SetContentAlignment(5)
	self.labelitem:SetWrap(true)
	self.labelitem:SetTextColor(Color(255, 255, 255))
	self.labelitem:SetMouseInputEnabled(false)
end

function PANEL:SetItem(recipeID, name, icon, desc, req, results, skill, blueprint, guns, entity)
	self.id = recipeID
	self.itemName = name
	self.description = desc
	self.requirements = req
	self.results = results
	self.skill = skill
	self.blueprint = blueprint
	self.guns = guns
	self.entity = entity

	self.labelitem:SetText(L(name))
	self.spawnicon:SetModel(icon)

	-- Konfiguracja dymka z informacjami na całej powierzchni kafelka oraz ikony
	self:SetupTooltip(self)
	self:SetupTooltip(self.spawnicon)
end

-- Reakcja na kliknięcie w wolny obszar kafelka
function PANEL:OnMouseReleased(mouseCode)
	if mouseCode == MOUSE_LEFT then
		self:DoClick()
	end
end

function PANEL:DoClick()
	surface.PlaySound("UI/buttonclick.wav")

	timer.Simple(SoundDuration("UI/buttonclick.wav") - 0.1, function()
		surface.PlaySound("UI/buttonclickrelease.wav")
	end)

	net.Start("ixCraftItem")
	net.WriteTable({self.id})
	net.SendToServer()
end

function PANEL:SetupTooltip(targetPanel)
	targetPanel:SetHelixTooltip(function(tooltip)
		-- Nazwa przedmiotu
		local title = tooltip:AddRow("title")
		title:SetImportant()
		title:SetText(L(self.itemName))
		title:SetBackgroundColor(ix.config.Get("color") or Color(0, 150, 0))
		title:SizeToContents()

		-- Opis przedmiotu
		local description = tooltip:AddRow("description")
		description:SetText(L(self.description))
		description:SizeToContents()

		-- Wymagania (Składniki)
		local requirements = tooltip:AddRow("requirements")
		local realreq = {}

		for k, v in pairs(self.requirements) do
			local item = ix.item.Get(k)
			if item then
				realreq[#realreq + 1] = L(item.name) .. " (" .. v .. "x)"
			end
		end

		requirements:SetText(L("wsRequirements") .. ": " .. table.concat(realreq, ", "))
		
		local missing = {}
		local inv = LocalPlayer():GetCharacter():GetInventory()

		for k, v in pairs(self.requirements) do
			if inv:GetItemCount(k) < v then
				local i = ix.item.Get(k)
				if i then
					missing[#missing + 1] = L(i.name)
				end
			end
		end

		-- Kolorowanie tła wymagań (Złoty ostrzegawczy / Zielony sukces)
		if #missing > 0 then
			requirements:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		else
			requirements:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		if #realreq >= 4 then
			requirements:SizeToContents()
			requirements:SetTall(56)
		else
			requirements:SizeToContents()
		end

		-- Rezultat wytwarzania
		local results = tooltip:AddRow("results")
		local realres = {}

		for k, v in pairs(self.results) do
			local item = ix.item.Get(k)
			if item then
				realres[#realres + 1] = L(item.name) .. " (" .. v .. "x)"
			end
		end

		results:SetText(L("wsResults") .. ": " .. table.concat(realres, ", "))
		results:SizeToContents()

		-- Wymagane umiejętności / atrybuty
		if self.skill then
			local skill = tooltip:AddRow("skill")
			local skillist = {}

			for k, v in pairs(self.skill) do
				local attrib = ix.attributes.list[k]
				if attrib then
					skillist[#skillist + 1] = L(attrib.name) .. " (" .. v .. ")"
				end
			end

			skill:SetText(L("wsRequiredSkills") .. ": " .. table.concat(skillist, ", "))
			skill:SizeToContents()
			
			local skillslist = {}
			for k, v in pairs(self.skill) do
				if LocalPlayer():GetCharacter():GetAttribute(k, 0) < v then
					skillslist[#skillslist + 1] = k
				end
			end

			if #skillslist > 0 then
				skill:SetBackgroundColor(derma.GetColor("Error", tooltip))
			else
				skill:SetBackgroundColor(derma.GetColor("Success", tooltip))
			end
		else
			local skill = tooltip:AddRow("skill")
			skill:SetText(L("wsNoRequiredSkills"))
			skill:SizeToContents()
		end

		-- Informacja o schemacie (Blueprint)
		if self.blueprint then
			local bp = tooltip:AddRow("blueprint")
			bp:SetColor(ix.config.Get("color") or Color(0, 150, 0))
			bp:SetText(L("wsUnlockedBlueprint"))
			bp:SizeToContents()
		end
	end)
end

function PANEL:Paint(w, h)
	local isCraftable = self:HasRequirements()
	
	if self:IsHovered() or self.spawnicon:IsHovered() then
		surface.SetDrawColor(55, 55, 55, 235)
	else
		surface.SetDrawColor(24, 24, 24, 205)
	end
	surface.DrawRect(0, 0, w, h)

	local borderCol = isCraftable and Color(0, 150, 0, 180) or Color(150, 50, 50, 120)
	surface.SetDrawColor(borderCol)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:HasRequirements()
	local char = LocalPlayer():GetCharacter()
	if not char then return false end
	
	local inv = char:GetInventory()
	if not inv then return false end

	for k, v in pairs(self.requirements) do
		if inv:GetItemCount(k) < v then
			return false
		end
	end

	-- Sprawdzanie również wymaganych poziomów umiejętności (jeśli zdefiniowane)
	if self.skill then
		for k, v in pairs(self.skill) do
			if char:GetAttribute(k, 0) < v then
				return false
			end
		end
	end

	return true
end

vgui.Register("CraftingListItem", PANEL, "DPanel")

--------------------------------------------------------------------------------
-- REJESTRACJA PRZYCISKU W MENU
--------------------------------------------------------------------------------

hook.Add("CreateMenuButtons", "ixCrafting", function(tabs)
	tabs["crafting"] = function(container)
		container:Add("CraftingListFrame")
	end
end)