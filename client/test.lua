-- client/test.lua (ou n'importe quel fichier client)

local POSITIONS = {
    { value = 'default',       label = 'Préférence joueur' },
    { value = 'top-right',     label = 'Haut droite' },
    { value = 'top-left',      label = 'Haut gauche' },
    { value = 'top-center',    label = 'Haut centre' },
    { value = 'bottom-right',  label = 'Bas droite' },
    { value = 'bottom-left',   label = 'Bas gauche' },
    { value = 'bottom-center', label = 'Bas centre' },
}

local function emptyToNil(v)
    if v == nil or v == '' then return nil end
    return v
end

if Config.CommandTest then

    RegisterCommand('testnotify', function()
        local input = lib.inputDialog('Test lumen-notify', {
            {
                type = 'select', label = 'Type de notification', required = true,
                default = 'normal',
                options = {
                    { value = 'normal',   label = 'Normal (notify)' },
                    { value = 'advanced', label = 'Avancée (notifyAdvanced)' },
                },
            },
            { type = 'textarea', label = 'Texte', default = 'Ceci est une notification de test', autosize = true },
            { type = 'number',   label = 'Durée (ms)', default = 5000, min = 500, max = 60000 },
            { type = 'select',   label = 'Position', default = 'default', options = POSITIONS },

            -- Champs avancés uniquement
            { type = 'input', label = '[Avancé] Titre',    placeholder = 'Titre' },
            { type = 'input', label = '[Avancé] Sous-titre', placeholder = 'Sous-titre' },
            { type = 'color', label = '[Avancé] Couleur de fond',    format = 'hex', default = '#1a1a2e' },
            { type = 'color', label = '[Avancé] Couleur progression', format = 'hex', default = '#e94560' },
            { type = 'input', label = '[Avancé] Logo (URL)',          placeholder = 'https://...' },
            { type = 'input', label = '[Avancé] Image de fond (URL)', placeholder = 'https://...' },
        })

        if not input then return end -- dialogue fermé / annulé

        local notifyType = input[1]
        local text       = emptyToNil(input[2])
        local duration   = input[3]
        local position   = input[4] ~= 'default' and input[4] or nil

        if notifyType == 'normal' then
            exports['lumen-notify']:notify(text, duration, position)
        else
            exports['lumen-notify']:notifyAdvanced({
                title           = emptyToNil(input[5]),
                subtitle        = emptyToNil(input[6]),
                text            = text,
                backgroundColor = emptyToNil(input[7]),
                progressColor   = emptyToNil(input[8]),
                logo            = emptyToNil(input[9]),
                backgroundImage = emptyToNil(input[10]),
                duration        = duration,
                position        = position,
            })
        end
    end, false)

end