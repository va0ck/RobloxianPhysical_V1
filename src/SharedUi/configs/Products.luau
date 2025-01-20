export type CurrencyProduct = {
    name: string,
    iconId: string,
    devProductId: number,
    amount: number,
}

local Products: { CurrencyProduct } = {
    {
        name = "100 Coins",
        iconId = "rbxassetid://87784357150757",
        devProductId = 2698761482,
        amount = 100,
    },
    {
        name = "200 Coins",
        iconId = "rbxassetid://85990023280015",
        devProductId = 2698761954,
        amount = 200,
    },
    {
        name = "500 Coins",
        iconId = "rbxassetid://97450042167410",
        devProductId = 2698761952,
        amount = 500,
    },
    {
        name = "5000 Coins",
        iconId = "rbxassetid://91781912459223",
        devProductId = 2698761951,
        amount = 5000,
    },
}

return Products