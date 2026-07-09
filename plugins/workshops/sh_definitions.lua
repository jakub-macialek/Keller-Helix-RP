WorkshopType = {
    HOLD = 1,
    TOGGLE = 2
}

ix.workshop.Register({
    name = "tea_maker",
    models = {
        "models/props_interiors/vendingmachinesoda01a.mdl"
    },
    input = {
        {"water", 1},
    },
    output = {
        {"tea", 2},
    },
    workTime = 30,
    description = "tea_maker_desc",
    type = WorkshopType.HOLD,
    workSound = "eat.ogg",
})

ix.workshop.Register({
    name = "tree",
    models = {
        "models/props_foliage/tree_slice01.mdl",
        "models/props_foliage/tree_slice02.mdl"
    },
    output = {
        {"wood", 1}
    },
    workTime = 40,
    description = "chop_tree_desc",
    type = WorkshopType.TOGGLE,
    tools = {"axe"},
    workSound = "wood_chop.wav"
})