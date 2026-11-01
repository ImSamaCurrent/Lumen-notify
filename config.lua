-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  lumen-notify · config.lua                                       ║
-- ╚══════════════════════════════════════════════════════════════════╝

Config = {}


Config.CommandTest = true

-- ── Position par défaut ───────────────────────────────────────────
-- Valeurs possibles :
--   'top-left'      'top-center'      'top-right'
--   'bottom-left'   'bottom-center'   'bottom-right'

Config.DefaultPosition = 'bottom-left'

-- ── Opacité par défaut ────────────────────────────────────────────
-- Valeur entre 0.1 (quasi transparent) et 1.0 (opaque)

Config.DefaultOpacity = 1.0

-- ── Couleur par défaut de la barre de progression ─────────────────
-- Format HEX : '#RRGGBB'
-- Utilisée uniquement si la notification ne passe pas de backgroundColor

Config.DefaultProgressColor = '#8b5cf6'

-- ── Durée par défaut des notifications (en millisecondes) ─────────

Config.DefaultDuration = 5000

-- ── Nombre max de notifications visibles simultanément par zone ───

Config.MaxVisible = 4

-- ── Décalages automatiques selon l'état de la minimap ────────────
-- Chaque état définit le décalage en px depuis le bord (bottom ou top)
-- pour chaque zone de notification.
--
--  'normal'  → minimap cachée (joueur en intérieur, cutscene, etc.)
--  'minimap' → minimap visible (IsMinimapRendering = true)
--  'bigmap'  → grande carte ouverte (IsBigmapActive = true)
--
-- Tu peux ajuster les valeurs librement selon ta résolution / UI.

-- Masquer toutes les notifications quand la grande carte est ouverte
Config.HideOnBigmap = true

Config.MinimapOffsets = {
    normal = {
        ['top-left']      = 20,
        ['top-center']    = 20,
        ['top-right']     = 20,
        ['bottom-left']   = 20,
        ['bottom-center'] = 20,
        ['bottom-right']  = 20,
    },
    minimap = {
        ['top-left']      = 20,
        ['top-center']    = 20,
        ['top-right']     = 20,
        ['bottom-left']   = 230,  -- au-dessus de la minimap GTA
        ['bottom-center'] = 20,
        ['bottom-right']  = 20,
    },
    bigmap = {
        -- La grande carte couvre tout l'écran → les notifications sont masquées
        -- Les offsets sont ignorés quand hideOnBigmap = true
        ['top-left']      = 20,
        ['top-center']    = 20,
        ['top-right']     = 20,
        ['bottom-left']   = 20,
        ['bottom-center'] = 20,
        ['bottom-right']  = 20,
    },
}
