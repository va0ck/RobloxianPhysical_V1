-- A table containing all emotes in the game

export type Emote = {
	name: string,
	price: number,
	audioId: string,
	iconId: string,
}

local Emotes: { [string]: Emote } = {
	["96367286491996"] = {
		name = "Juke Dance",
		price = 100,
		audioId = "rbxassetid://1847665497",
		iconId = "rbxassetid://95168394825327",
	},
	["116443136824042"] = {
		name = "Bandage Up",
		price = 100,
		audioId = "rbxassetid://1847373110",
		iconId = "rbxassetid://131082043192630",
	},
	["114476136061463"] = {
		name = "Move It",
		price = 100,
		audioId = "rbxassetid://1847558354",
		iconId = "rbxassetid://88600534759602",
	},
	["124097445821633"] = {
		name = "Steven",
		price = 100,
		audioId = "rbxassetid://9047164632",
		iconId = "rbxassetid://103216203857347",
	},
	["121652739117585"] = {
		name = "Americano",
		price = 100,
		audioId = "rbxassetid://1847345231",
		iconId = "rbxassetid://126135506861673",
	},
	["118913582908013"] = {
		name = "Jumpin'",
		price = 100,
		audioId = "rbxassetid://1847484908",
		iconId = "rbxassetid://119043109089713",
	},
	["80509858659806"] = {
		name = "Y.M.C.A",
		price = 100,
		audioId = "rbxassetid://1839226060",
		iconId = "rbxassetid://86444878501833",
	},
	["85431698709346"] = {
		name = "Groovy",
		price = 100,
		audioId = "rbxassetid://1836028548",
		iconId = "rbxassetid://78300589721076",
	},
	["120856575164478"] = {
		name = "Egypt Dance",
		price = 100,
		audioId = "rbxassetid://1847195514",
		iconId = "rbxassetid://110155505152683",
	},
	["75667137779622"] = {
		name = "Fish",
		price = 100,
		audioId = "rbxassetid://1847395862",
		iconId = "rbxassetid://97144922318844",
	},
}

return Emotes