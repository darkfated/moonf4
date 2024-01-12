// Затемение фона при открытии меню

hook.Add('HUDPaint', 'Mantle.MoonF4', function()
    if IsValid(MoonF4) then
        if MoonF4:IsVisible() then
            MoonF4.hudBackAlpha = Lerp(FrameTime() * 8, MoonF4.hudBackAlpha, 170)

            draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, MoonF4.hudBackAlpha))
        else
            MoonF4.hudBackAlpha = 0
        end
    end
end)
