local color_f4_text = Color(255, 184, 77)
local color_gray = Color(170, 170, 170)
local color_shadow = Color(74, 77, 89, 80)
local color_money = Color(62, 134, 92)
local color_item_hovered = Color(0, 0, 0, 34)
local mat_infinity = Material('moonf4/infinity.png')
local mat_limit = Material('moonf4/limit.png')
local color_max_count = Color(240, 80, 80)

// Вкладки

local function PaintBuyItem(pan, entity)
    local text_money = entity.price > 0 and DarkRP.formatMoney(entity.price) or 'Бесплатно'

    pan.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel[2])
        Mantle.func.gradient(0, 0, w, h, 1, color_shadow)

        if self:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, color_item_hovered)
        end

        draw.SimpleText(entity.name, 'Fated.24', 62, h * 0.25 + 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(text_money, 'Fated.24', 62, h * 0.75 - 4, color_money, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local text_count_info

        if entity.max then
            text_count_info = 'Максимум ' .. entity.max
        elseif entity.amount then
            text_count_info = 'Кол-во: ' .. entity.amount
        end

        if text_count_info then
            draw.SimpleText(text_count_info, 'Fated.22', w - 15, h * 0.5 - 1, color_gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        if entity.f4_text then
            draw.SimpleText(entity.f4_text, 'Fated.22', w * 0.6, h * 0.5 - 1, color_f4_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    pan.mdl = vgui.Create('SpawnIcon', pan)
    pan.mdl:Dock(LEFT)
    pan.mdl:DockMargin(6, 6, 6, 6)
    pan.mdl:SetWide(48)
    pan.mdl:SetModel(entity.model)
end

local function CreatePageFoods()
    local panel_center = vgui.Create('DScrollPanel', MoonF4.panel_content)
    Mantle.ui.sp(panel_center)
    panel_center:Dock(FILL)

    for i, food in pairs(FoodItems) do
        local btn_food = vgui.Create('DButton', panel_center)
        btn_food:Dock(TOP)
        btn_food:DockMargin(0, 0, 0, 6)
        btn_food:SetTall(60)
        btn_food:SetText('')
        btn_food.DoClick = function()
            Mantle.func.sound()

            RunConsoleCommand('darkrp', 'buyfood', food.name)
        end

        PaintBuyItem(btn_food, food)
    end
end

local function CreatePageItems(entity_type)
    local panel_center = vgui.Create('DScrollPanel', MoonF4.panel_content)
    Mantle.ui.sp(panel_center)
    panel_center:Dock(FILL)

    local mat_buy = Material('moonf4/buy.png')
    local color_btn_buy = Color(200, 200, 200)

    for i, cat_entity in pairs(DarkRP.getCategories()[entity_type]) do
        local tabl_entity_by_cat = {}

        for k, entity in pairs(cat_entity.members) do
            if istable(entity.allowed) and !table.HasValue(entity.allowed, LocalPlayer():Team()) then
                continue
            end
    
            if entity.customCheck and !entity.customCheck(LocalPlayer()) then
                continue 
            end

            if !tabl_entity_by_cat[entity.category] then
                tabl_entity_by_cat[entity.category] = {}
            end

            table.insert(tabl_entity_by_cat[entity.category], entity)
        end

        for cat_name, cat_members in pairs(tabl_entity_by_cat) do
            local panel_category = vgui.Create('DPanel', panel_center)
            panel_category:Dock(TOP)
            panel_category:DockMargin(0, 0, 0, 6)
            panel_category:SetTall(40)
            panel_category.Paint = function(_, w, h)
                draw.SimpleText(cat_name, 'Fated.24', 8, h * 0.5 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            
            local grid_items = vgui.Create('DGrid',panel_center)
            grid_items:Dock(TOP)
            grid_items:DockMargin(0, 0, 0, 6)
            grid_items:SetCols(2)
            
            local panel_size = (MoonF4:GetWide() - 18) / 2
            
            grid_items:SetColWide(panel_size)
            grid_items:SetRowHeight(66)

            for k, entity in pairs(cat_members) do
                local panel_entity = vgui.Create('DButton', grid_items)
                panel_entity:SetSize(panel_size - 6, 60)
                panel_entity:SetText('')

                local function BtnEntClick(btn)
                    btn.DoClick = function()
                        Mantle.func.sound()

                        if entity.amount then
                            RunConsoleCommand('darkrp', 'buyshipment', entity.name)
                        else
                            RunConsoleCommand('darkrp', entity.cmd)
                        end
                    end
                    btn.DoRightClick = function()
                        local DM = Mantle.ui.derma_menu()
                        DM:AddOption('Скопировать модель', function()
                            SetClipboardText(panel_entity.mdl:GetModelName())
                        end, 'icon16/disk.png')

                        if entity.cmd then
                            DM:AddOption('Скопировать команду', function()
                                SetClipboardText(entity.cmd)
                            end, 'icon16/application_xp_terminal.png')
                        end
                    end
                end

                BtnEntClick(panel_entity)
                PaintBuyItem(panel_entity, entity)

                grid_items:AddItem(panel_entity)
            end
        end
    end
end

local function CreateJobMenu(job, active_model)
    if !IsValid(MoonF4) then
        return
    end

    if IsValid(MoonF4.menu_job_background) then
        MoonF4.menu_job_background:Remove()
    end

    MoonF4.menu_job_background = vgui.Create('DButton')
    MoonF4.menu_job_background:SetSize(ScrW(), ScrH())
    MoonF4.menu_job_background:MakePopup()
    MoonF4.menu_job_background:SetText('')
    MoonF4.menu_job_background.Paint = nil
    MoonF4.menu_job_background.DoClick = function()
        MoonF4.menu_job_background:Remove()
    end

    MoonF4.menu_job = vgui.Create('DFrame', MoonF4.menu_job_background)
    Mantle.ui.frame(MoonF4.menu_job, 'Профессия ' .. job.name, 400, MoonF4:GetTall() * 0.9, true)
    MoonF4.menu_job:Center()
    MoonF4.menu_job:MakePopup()
    MoonF4.menu_job.active_model = active_model
    MoonF4.menu_job.background_alpha = false
    MoonF4.menu_job.cls.DoClick = function()
        MoonF4.menu_job_background:Remove()
        MoonF4.menu_job:Remove()
    end

    local text_job_salary = DarkRP.formatMoney(job.salary)

    MoonF4.menu_job.PaintOver = function(_, w, h)
        local job_count = team.NumPlayers(job['team'])

        if job.max > 0 then
            local text_job_count = job_count .. ' / ' .. job.max

            draw.SimpleText(text_job_count, 'Fated.20', 50, 330, (job_count == job.max and job.max != 0) and color_max_count or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        else
            surface.SetDrawColor(color_white)
            surface.SetMaterial((job.max == job_count and job.max != 0) and mat_limit or mat_infinity)
            surface.DrawTexturedRect(51, 315, 16, 16)

            draw.SimpleText(job_count .. ' /', 'Fated.16', 49, 331, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end

        draw.SimpleText(text_job_salary, 'Fated.22', w - 50, 330, color_money, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end

    MoonF4.menu_job.mdl_pan = vgui.Create('DPanel', MoonF4.menu_job)
    MoonF4.menu_job.mdl_pan:SetSize(200, 300)
    MoonF4.menu_job.mdl_pan:SetPos(100, 50)
    MoonF4.menu_job.mdl_pan.Paint = function(_, w, h)
        draw.RoundedBox(16, 0, 0, w, h, Mantle.color.panel[2])
    end

    if istable(job.model) then
        MoonF4.menu_job.active_model_index = table.KeyFromValue(job.model, active_model)
    end

    MoonF4.menu_job.mdl = vgui.Create('DModelPanel', MoonF4.menu_job.mdl_pan)
    MoonF4.menu_job.mdl:Dock(FILL)
    MoonF4.menu_job.mdl:SetModel(MoonF4.menu_job.active_model)
    MoonF4.menu_job.mdl:SetFOV(46)
    MoonF4.menu_job.mdl.LayoutEntity = function(_, entity)
        entity:SetAngles(Angle(0, 32, 0))
        entity:SetPos(Vector(0, 0, 4))

        return
    end

    MoonF4.menu_job.mdl.btn = vgui.Create('DButton', MoonF4.menu_job.mdl)
    MoonF4.menu_job.mdl.btn:Dock(FILL)
    MoonF4.menu_job.mdl.btn:SetText('')
    MoonF4.menu_job.mdl.btn.DoClick = function()
        local DM = Mantle.ui.derma_menu()
        DM:AddOption('Скопировать выбранную модель', function()
            SetClipboardText(MoonF4.menu_job.active_model)
        end, 'icon16/disk.png')
    end
    MoonF4.menu_job.mdl.btn.Paint = nil

    local lp_color = LocalPlayer():GetPlayerColor()
    local lp_color_vector = Vector(lp_color.x, lp_color.y, lp_color.z)

    MoonF4.menu_job.mdl.Entity.GetPlayerColor = function()
        return lp_color_vector
    end

    MoonF4.menu_job.text_sp = vgui.Create('DScrollPanel', MoonF4.menu_job)
    Mantle.ui.sp(MoonF4.menu_job.text_sp)
    MoonF4.menu_job.text_sp:Dock(FILL)
    MoonF4.menu_job.text_sp:DockMargin(0, 345, 0, 0)

    MoonF4.menu_job.text = vgui.Create('DLabel', MoonF4.menu_job.text_sp)
    MoonF4.menu_job.text:Dock(TOP)
    MoonF4.menu_job.text:DockMargin(4, 4, 4, 4)
    MoonF4.menu_job.text:SetText(job.description)
    MoonF4.menu_job.text:SetFont('Fated.18')
    MoonF4.menu_job.text:SetAutoStretchVertical(true)
    MoonF4.menu_job.text:SetWrap(true)

    MoonF4.menu_job.button_bottom = vgui.Create('DButton', MoonF4.menu_job)
    Mantle.ui.btn(MoonF4.menu_job.button_bottom, nil, nil, job.color, nil, nil, nil, true)
    MoonF4.menu_job.button_bottom:Dock(BOTTOM)
    MoonF4.menu_job.button_bottom:DockMargin(0, 6, 0, 0)
    MoonF4.menu_job.button_bottom:SetTall(40)
    MoonF4.menu_job.button_bottom:SetText('Взять')
    MoonF4.menu_job.button_bottom.DoClick = function()
        Mantle.func.sound()

        if job.vote then
            RunConsoleCommand('darkrp', 'vote' .. job.command)
        else
            RunConsoleCommand('darkrp', job.command)
        end

        MoonF4:SetVisible(false)
        MoonF4.menu_job_background:Remove()
    end

    if istable(job.model) then
        local color_btn_nav = Color(0, 0, 0, 80)

        MoonF4.menu_job.button_bottom.left = vgui.Create('DButton', MoonF4.menu_job.button_bottom)
        MoonF4.menu_job.button_bottom.left:Dock(LEFT)
        MoonF4.menu_job.button_bottom.left:SetWide(90)
        MoonF4.menu_job.button_bottom.left:SetText('<')
        MoonF4.menu_job.button_bottom.left:SetTextColor(color_white)
        MoonF4.menu_job.button_bottom.left.Paint = function(_, w, h)
            draw.RoundedBoxEx(6, 0, 0, w, h, color_btn_nav, true, false, true, false)
        end
        MoonF4.menu_job.button_bottom.left.DoClick = function()
            if MoonF4.menu_job.active_model_index > 1 then
                MoonF4.menu_job.active_model_index = MoonF4.menu_job.active_model_index - 1
                MoonF4.menu_job.active_model = job.model[MoonF4.menu_job.active_model_index]

                MoonF4.menu_job.mdl:SetModel(MoonF4.menu_job.active_model)
                MoonF4.menu_job.button_bottom.right:SetText('> ' .. MoonF4.menu_job.active_model_index + 1)
                MoonF4.menu_job.button_bottom.left:SetText(MoonF4.menu_job.active_model_index - 1 .. ' <')

                if MoonF4.menu_job.active_model_index == 1 then
                    MoonF4.menu_job.button_bottom.left:SetText('')
                end
            end
        end

        MoonF4.menu_job.button_bottom.right = vgui.Create('DButton', MoonF4.menu_job.button_bottom)
        MoonF4.menu_job.button_bottom.right:Dock(RIGHT)
        MoonF4.menu_job.button_bottom.right:SetWide(90)
        MoonF4.menu_job.button_bottom.right:SetText('>')
        MoonF4.menu_job.button_bottom.right:SetTextColor(color_white)
        MoonF4.menu_job.button_bottom.right.Paint = function(_, w, h)
            draw.RoundedBoxEx(6, 0, 0, w, h, color_btn_nav, false, true, false, true)
        end
        MoonF4.menu_job.button_bottom.right.DoClick = function()
            if MoonF4.menu_job.active_model_index < #job.model then
                MoonF4.menu_job.active_model_index = MoonF4.menu_job.active_model_index + 1
                MoonF4.menu_job.active_model = job.model[MoonF4.menu_job.active_model_index]

                MoonF4.menu_job.mdl:SetModel(MoonF4.menu_job.active_model)
                MoonF4.menu_job.button_bottom.right:SetText('> ' .. MoonF4.menu_job.active_model_index + 1)
                MoonF4.menu_job.button_bottom.left:SetText(MoonF4.menu_job.active_model_index - 1 .. ' <')

                if MoonF4.menu_job.active_model_index == #job.model then
                    MoonF4.menu_job.button_bottom.right:SetText('')
                end
            end
        end
    end
end

local function CreatePageJobs(jobs)
    local panel_center = vgui.Create('DScrollPanel', MoonF4.panel_content)
    Mantle.ui.sp(panel_center)
    panel_center:Dock(FILL)
    panel_center:GetVBar():SetWide(0)
    panel_center.job_fav = {}

    if file.Exists('moonf4_fav_jobs.txt', 'DATA') then
        panel_center.job_fav = util.JSONToTable(file.Read('moonf4_fav_jobs.txt', 'DATA'))
    end

    panel_center.grid = vgui.Create('DGrid', panel_center)
    panel_center.grid:Dock(TOP)
    panel_center.grid:SetCols(7)
    panel_center.grid:SetColWide(MoonF4.default_item_size / 1.778 + 6)
    panel_center.grid:SetRowHeight(MoonF4.default_item_size / 1.2)
    
    for i, job in pairs(jobs) do
        local panel_job = vgui.Create('DPanel', panel_center.grid)
        panel_job:SetSize(MoonF4.default_item_size / 1.778 - (i == 7 and 6 or 0), MoonF4.default_item_size / 1.2 - 6)
        panel_job:SetText('')

        panel_job.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])

            if self.btn:IsHovered() then
                draw.RoundedBox(6, 0, 0, w, h, color_item_hovered)
            end
        end
        panel_job.PaintOver = function(_, w, h)
            draw.RoundedBoxEx(6, 0, 0, w, 30, job.color, true, true, false, false)

            if job.f4_text and job.f4_text_dop then
                draw.SimpleText(job.f4_text, 'Fated.15', 5, h - 21, color_f4_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
                draw.SimpleText(job.f4_text_dop, 'Fated.15', 5, h - 5, color_f4_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            elseif job.f4_text then
                draw.SimpleText(job.f4_text, 'Fated.15', 5, h - 5, color_f4_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            end

            draw.SimpleText('Зарплата: ' .. DarkRP.formatMoney(job.salary), 'Fated.15', 4, 47, color_gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(job.name, 'Fated.16', w * 0.5, 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local job_active_count = team.NumPlayers(job['team'])
            local color_count = (job_active_count == job.max and job.max != 0) and color_max_count or color_white

            if job.max > 0 then
                local text_job_count = job_active_count .. ' / ' .. job.max

                draw.SimpleText(text_job_count, 'Fated.16', w - 6, h - 6, color_count, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            else
                surface.SetDrawColor(color_count)
                surface.SetMaterial((job.max == job_active_count and job.max != 0) and mat_limit or mat_infinity)
                surface.DrawTexturedRect(w - 22, h - 22, 16, 16)

                draw.SimpleText(job_active_count .. ' /', 'Fated.16', w - 24, h - 6, color_count, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            end
        end

        panel_job.mdl = vgui.Create('DModelPanel', panel_job)
        panel_job.mdl:Dock(FILL)
        panel_job.mdl:DockMargin(6, 6, 6, 22)
        panel_job.mdl.active_model = istable(job.model) and table.Random(job.model) or job.model
        panel_job.mdl:SetModel(panel_job.mdl.active_model)
        panel_job.mdl:SetFOV(60)
        panel_job.mdl.LayoutEntity = function(_, entity)
            entity:SetAngles(Angle(0, 32, 0))
            entity:SetPos(Vector(0, 0, -5))

            return
        end

        local lp_color = LocalPlayer():GetPlayerColor()
        local lp_color_vector = Vector(lp_color.x, lp_color.y, lp_color.z)

        panel_job.mdl.Entity.GetPlayerColor = function()
            return lp_color_vector
        end

        panel_job.btn = vgui.Create('DButton', panel_job)
        panel_job.btn:Dock(FILL)
        panel_job.btn:SetText('')
        panel_job.btn.Paint = nil
        panel_job.btn.DoRightClick = function()
            Mantle.func.sound()

            local DM = Mantle.ui.derma_menu()
            DM:AddOption('Добавить в избранное', function()
                local fav_jobs = {}

                if file.Exists('moonf4_fav_jobs.txt', 'DATA') then
                    fav_jobs = util.JSONToTable(file.Read('moonf4_fav_jobs.txt', 'DATA'))
                end

                if !table.HasValue(fav_jobs, job.command) then
                    table.insert(fav_jobs, job.command)

                    file.Write('moonf4_fav_jobs.txt', util.TableToJSON(fav_jobs))
                end
            end, 'icon16/star.png')
            DM:AddSpacer()
            DM:AddOption('Скопировать модель', function()
                SetClipboardText(panel_job.mdl.active_model)
            end, 'icon16/disk.png')
            DM:AddOption('Скопировать команду', function()
                SetClipboardText(job.command)
            end, 'icon16/application_xp_terminal.png')
        end
        panel_job.btn.DoClick = function()
            CreateJobMenu(job, panel_job.mdl.active_model)
        end

        panel_job.btn_fav = vgui.Create('DButton', panel_job)
        panel_job.btn_fav:SetSize(16, 16)
        panel_job.btn_fav:SetPos(panel_job:GetWide() - 20, 34)
        panel_job.btn_fav:SetText('')
        panel_job.btn_fav.DoClick = function()
            local fav_jobs = {}

            if file.Exists('moonf4_fav_jobs.txt', 'DATA') then
                fav_jobs = util.JSONToTable(file.Read('moonf4_fav_jobs.txt', 'DATA'))
            end

            if !table.HasValue(fav_jobs, job.command) then
                table.insert(fav_jobs, job.command)
                table.insert(panel_center.job_fav, job.command)
            else
                table.RemoveByValue(fav_jobs, job.command)
                table.RemoveByValue(panel_center.job_fav, job.command)
            end

            file.Write('moonf4_fav_jobs.txt', util.TableToJSON(fav_jobs))
        end

        local mat_fav = Material('icon16/star.png')

        panel_job.btn_fav.Paint = function(_, w, h)
            surface.SetDrawColor(table.HasValue(panel_center.job_fav, job.command) and color_white or color_gray)
            surface.SetMaterial(mat_fav)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        panel_center.grid:AddItem(panel_job)
    end
end

// Меню

local function Close()
    if IsValid(MoonF4) then
        MoonF4:SetVisible(false)

        if IsValid(MoonF4.menu_job_background) then
            MoonF4.menu_job_background:Remove()
        end
    end
end

local menu_width, menu_tall = 1344, 648
local scrw, scrh = ScrW(), ScrH()

local function Create()
    MoonF4 = vgui.Create('DFrame')
    Mantle.ui.frame(MoonF4, 'Меню F4', math.Clamp(menu_width, 0, scrw), math.Clamp(menu_tall, 0, scrh), true)
    MoonF4:Center()
    MoonF4:MakePopup()
    MoonF4:SetDraggable(false)
    MoonF4.hudBackAlpha = 0
    MoonF4.OnKeyCodePressed = function(_, key)
        if key == KEY_F4 then
            Close()
        end
    end
    MoonF4.cls.DoClick = function()
        Close()
    end

    MoonF4.panel_content = vgui.Create('DPanel', MoonF4)
    MoonF4.panel_content:Dock(FILL)
    MoonF4.panel_content.Paint = function(self, w, h)
        if #self:GetChildren() == 0 then
            draw.SimpleText('Выберете вкладку', 'Fated.20', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    MoonF4.panel_tabs = vgui.Create('DPanel', MoonF4)
    MoonF4.panel_tabs:Dock(TOP)
    MoonF4.panel_tabs:DockMargin(0, 0, 0, 6)
    MoonF4.panel_tabs:SetTall(46)
    MoonF4.panel_tabs.Paint = nil

    MoonF4.panel_split = vgui.Create('DPanel', MoonF4)
    MoonF4.panel_split:Dock(TOP)
    MoonF4.panel_split:DockMargin(0, 0, 0, 6)
    MoonF4.panel_split:SetTall(36)
    MoonF4.panel_split.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Mantle.color.panel_alpha[2])
    end

    local ConfigUrl = {
        {
            name = 'Дискорд',
            url = 'https://discord.com/',
            icon = ''
        },
        {
            name = 'Контент',
            url = 'https://steamcommunity.com/workshop/',
            icon = ''
        },
        {
            name = 'Правила сервера',
            url = 'https://docs.google.com/document/',
            icon = ''
        },
    }

    surface.SetFont('Fated.24')

    for i, page in pairs(ConfigUrl) do
        local button_url = vgui.Create('DButton', MoonF4.panel_split)
        button_url:Dock(LEFT)
        button_url:SetWide(surface.GetTextSize(page.name) + 12)
        button_url:SetText('')
        button_url.DoClick = function()
            Mantle.func.sound()

            gui.OpenURL(page.url)
        end
        button_url.Paint = function(self, w, h)
            draw.SimpleText(page.name, 'Fated.24', w * 0.5, h * 0.5 - 1, color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local function OpenPageAllJobs()
        local tabl_jobs = {}

        for k, category in pairs(DarkRP.getCategories().jobs) do
            if #category.members < 1 then
                continue
            end
            
            for v, job in pairs(category.members) do
                table.insert(tabl_jobs, job)
            end
        end

        MoonF4.panel_content:Clear()

        CreatePageJobs(tabl_jobs)

        MoonF4.center_title = 'Профессии - Все'
    end

    local ConfigPage = {
        {
            name = 'Профессии',
            icon = '',
            color = Color(142, 87, 54),
            func = function()
                OpenPageAllJobs()
            end,
            dop_vgui = function(pan)
                local btn_cats = vgui.Create('DButton', pan)
                btn_cats:SetSize(pan:GetTall() - 8, pan:GetTall() - 8)
                btn_cats:SetPos(pan:GetWide() - btn_cats:GetWide() - 4, 4)
                btn_cats:SetText('')

                local color_btn_shadow = Color(0, 0, 0, 40)
                local mat_arrow_down = Material('moonf4/arrow_down.png')

                btn_cats.Paint = function(_, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, color_btn_shadow)

                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(mat_arrow_down)
                    surface.DrawTexturedRect(3, 3, 32, 32)
                end
                btn_cats.DoClick = function()
                    local DM = Mantle.ui.derma_menu()
                
                    for k, category in pairs(DarkRP.getCategories().jobs) do
                        if #category.members < 1 then
                            continue
                        end
                        
                        DM:AddOption(category.name, function()
                            MoonF4.panel_content:Clear()
    
                            CreatePageJobs(category.members)
                            
                            MoonF4.center_title = 'Профессии - ' .. category.name
                        end, category.icon and category.icon or nil)
                    end
    
                    DM:AddSpacer()
                    DM:AddOption('Избранное', function()
                        local fav_jobs = {}

                        if file.Exists('moonf4_fav_jobs.txt', 'DATA') then
                            fav_jobs = util.JSONToTable(file.Read('moonf4_fav_jobs.txt', 'DATA'))
                        end
        
                        local tabl_jobs = {}

                        for k, category in pairs(DarkRP.getCategories().jobs) do
                            if #category.members < 1 then
                                continue
                            end
                            
                            for i, job in pairs(category.members) do
                                if table.HasValue(fav_jobs, job.command) then
                                    table.insert(tabl_jobs, job)
                                end
                            end
                        end

                        MoonF4.panel_content:Clear()
    
                        CreatePageJobs(tabl_jobs)
                        
                        MoonF4.center_title = 'Профессии - Избранное'
                    end, 'icon16/star.png')
                end
            end
        },
        {
            name = 'Предметы',
            icon = '',
            color = Color(87, 57, 123),
            func = function()
                MoonF4.panel_content:Clear()

                CreatePageItems('entities')

                MoonF4.center_title = 'Предметы'
            end
        },
        {
            name = 'Товары',
            icon = '',
            color = Color(64, 91, 43),
            func = function()
                MoonF4.panel_content:Clear()

                CreatePageItems('shipments')

                MoonF4.center_title = 'Товары'
            end
        },
        {
            name = 'Еда',
            icon = '',
            color = Color(51, 97, 117),
            func = function()
                if LocalPlayer():Team() != JOB_COOK then
                    chat.AddText('Вы не имеете прав покупать еду!')

                    return 
                end
                
                MoonF4.panel_content:Clear()

                CreatePageFoods()
                
                MoonF4.center_title = 'Еда'
            end
        }
    }

    MoonF4.default_item_size = (MoonF4:GetWide() - 12) / #ConfigPage - 3

    OpenPageAllJobs()

    for i, page in pairs(ConfigPage) do
        local button_page = vgui.Create('DButton', MoonF4.panel_tabs)

        local color_page_hover = Color(page.color.r - 25, page.color.g - 25, page.color.b - 25)

        Mantle.ui.btn(button_page, nil, nil, page.color, 4, false, color_page_hover)
        button_page:SetSize(MoonF4.default_item_size, MoonF4.panel_tabs:GetTall())
        button_page:SetPos((button_page:GetWide() + 6) * (i - 1), 0)
        button_page:SetText(page.name)
        button_page.btn_font = 'Fated.24'
        button_page.DoClick = function()
            Mantle.func.sound()

            page.func()
        end

        if page.mat then
            button_page:SetText('')
            button_page.Paint = function(self, w, h)
                surface.SetDrawColor(self:IsHovered() and color_gray or color_white)
                surface.SetMaterial(page.mat)
                surface.DrawTexturedRect(0, 0, w, h)
            end
        end

        if page.dop_vgui then
            page.dop_vgui(button_page)
        end
    end
end

hook.Add('ShowSpare2', 'Mantle.MoonF4', function()
    if !IsValid(MoonF4) then
        Create()
    else
        MoonF4:SetVisible(true)
    end

    return false
end)

concommand.Add('mantle_moonf4_remove', function()
    if IsValid(MoonF4) then
        MoonF4:Remove()

        chat.AddText('MoonF4 удалён!')
        chat.PlaySound()
    end
end)
