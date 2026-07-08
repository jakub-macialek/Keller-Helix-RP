local PANEL = {}

function PANEL:Init()
	self:SetWide(190)
	self:SetPaintBackground(false)
	self.buttons = {}
	self.activeCategory = "All"

	self.categoryScroll = self:Add("DScrollPanel")
	self.categoryScroll:Dock(FILL)
	self.categoryScroll:DockMargin(0, 0, 0, 0)
	self.categoryScroll.Paint = function() end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(18, 18, 18, 220)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:Populate(categories, callback)
	self.categoryScroll:Clear()
	self.buttons = {}
	self.callback = callback

	for _, category in ipairs(categories) do
		local btn = self.categoryScroll:Add("DButton")
		btn:Dock(TOP)
		btn:DockMargin(6, 0, 6, 6)
		btn:SetTall(34)
		btn:SetText(category == "All" and L("wsAll") or L(category))
		btn:SetTextColor(Color(255, 255, 255))
		btn:SetFont("WastelandTiny")
		btn.category = category

		btn.DoClick = function()
			self:SetActiveCategory(category)

			if callback then
				callback(category)
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

		table.insert(self.buttons, btn)
	end

	self:SetActiveCategory("All")
end

function PANEL:SetActiveCategory(category)
	self.activeCategory = category

	for _, btn in ipairs(self.buttons) do
		btn.selected = (btn.category == category)
	end
end

vgui.Register("CraftingCategoryPanel", PANEL, "DPanel")
