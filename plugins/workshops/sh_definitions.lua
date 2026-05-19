--[[
ix.workshop.Register(model, 
	{
		name = "Workshop name",
		input = "item_name",
		output = 
			{"item_name_1", 1},
			{"item_name_2", 2} -- This means it will give 1 of the item. You can add multiple items like this.
		workTime = 30, -- Time in seconds it takes to make the output items
		description = "Description of the workshop.",
		color = Color(255, 196, 0, 150) -- Optional color for the workshop title in the tooltip
	}
)
]]

ix.workshop.Register("models/props_interiors/vendingmachinesoda01a.mdl", {
	name = "Tea maker",
	input = {
		{"water", 1},
	},
	output = {
		{"tea", 2},
	},
    workTime = 30,
	description = "A machine that makes tea. It requires water to work.",
	
})
