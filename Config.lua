Config = {}
Config.DiscordWebhook = "https://discord.com/api/webhooks/1452022585624760461/4kdqN1YZ6mtuksB7S-KyEktKdGiKwmDgSGMWw1hTLzFr4CCjG8dtlCyHKYG5Bm_9EBwO"
Config.ServerName = "Serveur de développement"
Config.LogColor = {
    money = 3066993,      -- vert
    inventory = 15158332, -- rouge
    report = 3447003      -- bleu
}

Config.Webhooks = {
    money = "https://discord.com/api/webhooks/1452030292654034966/DVD-0ry6unlOTG84KRLpIJhEID4O2jzswW8NaHLNyUjVvVOd0bHyoIGmpGJ5o6A9xl3h",
    inventory = "https://discord.com/api/webhooks/1452030429333819494/I5JxuABk9y0yI5vRD1BcLlG0m4Icvur-1jh584ajlNYqasLXL5AEaNh4X27pPt1MofwA",
    report = "https://discord.com/api/webhooks/1452030484816199931/Fdj-wRHK39mHHDI4StpCLhQTRGjn7ta3DpESfSv3Z_COwNY56P2_Dy9sURgalA7xeojm",
    admin = "https://discord.com/api/webhooks/1452030544971038740/d-tHL-D2veX914JgKFY48i2Fx9R50WeVV6WrxtWTIwFtZK8Ee9cZ40STkCH_p_hQLaul" -- général
}

Config.LogColors = {
    money = 3066993,      -- vert
    inventory = 15158332, -- rouge
    report = 3447003,     -- bleu
    admin = 9807270       -- violet
}

Config.Blips = {
    -- Exemple :
    { name = "Parking centrale", pos = vector3(215.76, -810.12, 30.73), sprite = 357, scale = 0.6, color = 5 },
    { name = "Garage", pos = vector3( -282.73, -887.30, 31.08), sprite = 830, scale = 0.6, color = 3 },
    { name = "Garage", pos = vector3( -2035.48, -462.13, 11.41), sprite = 830, scale = 0.6, color = 3 },
    { name = "Garage", pos = vector3(1501.2, 3762.19, 33.7), sprite = 830, scale = 0.6, color = 3 },
    { name = "Garage", pos = vector3(-1041.457, -2676.34, 13.59), sprite = 830, scale = 0.6, color = 3 },
    { name = "Garage", pos = vector3(105.359, 6613.586, 32.3973), sprite = 830, scale = 0.6, color = 3 },
    { name = "Garage", pos = vector3(364.57, 297.71, 103.49), sprite = 830, scale = 0.6, color = 3 },
    { name = "Garage", pos = vector3(1033.78, -761.83, 57.90), sprite = 830, scale = 0.6, color = 3 },
    { name = "Supérette", pos = vector3(25.748573, -1345.674438, 29.497015), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(-1222.9, -907.3, 12.3), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(1135.652, -982.324, 46.4158), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(162.151627, 6636.610840, 31.554768), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(-707.4, -914.2, 19.2), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(1698.33, 4924.29, 42.06), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(-48.24798, -1757.722, 29.42102), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(1392.74, 3605.25, 35.0), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(1729.07, 6415.25, 34.86), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(1961.23, 3740.04, 32.36), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(1165.29, 2709.39, 37.98), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(374.209625, 327.736206, 103.56633), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(-1820.53, 792.55, 137.91), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(-3242.24, 1001.0, 12.85), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(-3039.96, 585.53, 7.53), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(-3242.24, 1001.0, 12.85), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(1163.54, -324.67, 68.99), sprite = 59, scale = 0.6, color = 2 },
    { name = "Supérette", pos = vector3(-1487.75, -378.51, 39.98), sprite = 59, scale = 0.6, color = 2 },
    { name = "Location de véhicule", pos = vector3(-1037.87, -2728.49, 20.05), sprite = 225, scale = 0.6, color = 26 },
    { name = "Location de bâteau", pos = vector3(-801.452942, -1513.531372, 1.595215), sprite = 410, scale = 0.6, color = 26 },
    { name = "Hopital", pos = vector3(298.76, -584.63, 43.26), sprite = 61, scale = 0.7, color = 1 },
    { name = "Benny's", pos = vector3(-205.69, -1310.29, 31.29), sprite = 446, scale = 0.7, color = 28 },
    { name = "Fourrière", pos = vector3(415.84, -1638.69, 28.88), sprite = 67, scale = 0.7, color = 47 },
    -- { name = "Station Essence", pos = vector3(49.4187, 2778.793, 58.043), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(263.894, 2606.463, 44.983), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(1207.260, 2660.175, 37.899), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(2539.685, 2594.192, 37.944), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(2679.858, 3263.946, 55.240), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(2005.055, 3773.887, 32.403), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(1687.156, 4929.392, 42.078), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(1701.314, 6416.028, 32.763), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(179.857, 6602.839, 31.868), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(-94.4619, 6419.594, 31.489), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(-2554.996, 2334.402, 33.078), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(-1800.375, 803.661, 138.651), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(-1437.622, -276.747, 46.207), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(-2096.243, 320.286, 13.168), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(-724.619, -935.163, 19.213), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(-526.019, -1211.000, 18.184), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(-70.2148, -1761.792, 29.534), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(265.648, -1261.309, 29.292), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(1208.951, -1402.567, 35.224), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(1181.381, -330.847, 69.316), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(2581.321, 362.039, 108.468), sprite = 361, scale = 0.6, color = 49 },
    -- { name = "Station Essence", pos = vector3(1785.363, 3330.372, 41.253), sprite = 361, scale = 0.6, color = 49 }, 
    -- { name = "Station Essence", pos = vector3(620.843, 269.100, 103.089), sprite = 361, scale = 0.6, color = 49 }, 
} 

Config.Blips.Jobs = {
    -- Exemple :
    --{ name = "Benny's", coords = vector3(-205.691956, -1310.292114, 31.29599), sprite = 446, scale = 0.7, color = 28, jobs = { "bennys" } }
}



Config.Advantages = {
    AllowedSteam = {
        ["steam:11000013e7d602f"] = true,
        ["steam:110000140c4d2d7"] = true,
    }
}

Config.pedList = {
    { label = "Homme (MP)", model = "csb_ballasog" },
    { label = "Femme (MP)", model = "csb_anita" },
    { label = "Policier", model = "s_m_y_cop_01" },
    { label = "Civil RP", model = "a_m_y_business_01" }
}
