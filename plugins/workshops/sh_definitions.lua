WorkshopType = {
	HOLD = 1, -- Hold the use key to work
	TOGGLE = 2 -- Press the use key once to start working, press it again to stop
}

--[[
ix.workshop.Register(model, 
	{
		name = "Workshop name",
		input = {
			{"item_name_1", 1}, -- This means it will require 1 of the item. You can add multiple items like this.
			{"item_name_2", 2},
		},
		output = {
			{"item_name_1", 1},
			{"item_name_2", 2} -- This means it will give 1 of the item. You can add multiple items like this.
		},
		workTime = 30, -- Time in seconds it takes to make the output items
		description = "Description of the workshop.",
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
