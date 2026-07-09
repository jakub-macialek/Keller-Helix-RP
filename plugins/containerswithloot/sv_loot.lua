local PLUGIN = PLUGIN

PLUGIN.containers = {
    ["models/props_junk/trashbin01a.mdl"] = "trash",
    ["models/props_junk/trashdumpster01a.mdl"] = "trash",
}

PLUGIN.loots = {
    ["trash"] = {
        {"fish", 50},
        {"water", 50},
    }
}