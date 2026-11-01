# lumen-notify

Système de notifications NUI pour FiveM, au style de **LumenUI**. Notifications simples ou avancées (titre, sous-titre, logo, image de fond), 6 positions d'affichage, préférences joueur persistantes et adaptation automatique à la minimap.

![License](https://img.shields.io/badge/license-MIT-green.svg)
![FiveM](https://img.shields.io/badge/FiveM-resource-orange.svg)
![Lua](https://img.shields.io/badge/Lua-5.4-blue.svg)

---

## Fonctionnalités

- **Deux types de notifications** : `normal` (texte seul) et `advanced` (titre, sous-titre, logo, image de fond, couleurs personnalisées)
- **6 positions** : `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right`
- **Préférences joueur** : position et opacité sauvegardées côté client (KVP), utilisées par défaut quand aucune position n'est précisée
- **Barre de progression** avec couleur configurable
- **Gestion de la minimap** : décalage automatique des notifications selon l'état (minimap cachée, visible ou grande carte), avec option pour tout masquer quand la grande carte est ouverte
- **Limite d'empilement** : nombre maximum de notifications visibles par zone
- **API client et serveur** : exports et events, y compris l'envoi à tous les joueurs

---

## Prérequis

- [ox_lib](https://github.com/overextended/ox_lib) (chargé via `@ox_lib/init.lua` dans le `fxmanifest.lua`, utilisé par la commande de test)

---

## Installation

1. Télécharge ou clone la ressource dans ton dossier `resources` :

   ```bash
   git clone https://github.com/ImSamaCurrent/Lumen-notify.git 
   ```

2. Ajoute-la à ton `server.cfg`, **après** `ox_lib` :

   ```cfg
   ensure ox_lib
   ensure lumen-notify
   ```

3. Ajuste `config.lua` selon tes besoins, puis redémarre la ressource.

---

## Configuration

Tout se règle dans [`config.lua`](config.lua) :

| Option | Défaut | Description |
| --- | --- | --- |
| `Config.DefaultPosition` | `'bottom-left'` | Position par défaut si le joueur n'a pas de préférence |
| `Config.DefaultOpacity` | `1.0` | Opacité par défaut (de `0.1` à `1.0`) |
| `Config.DefaultProgressColor` | `'#8b5cf6'` | Couleur de la barre de progression (HEX) |
| `Config.DefaultDuration` | `5000` | Durée par défaut en millisecondes |
| `Config.MaxVisible` | `4` | Nombre max de notifications visibles par zone |
| `Config.HideOnBigmap` | `true` | Masque les notifications quand la grande carte est ouverte |
| `Config.MinimapOffsets` | voir fichier | Décalage en pixels depuis le bord, par zone et par état de la map (`normal`, `minimap`, `bigmap`) |

---

## Utilisation

### Côté client

#### `notify`

Notification simple.

```lua
exports['lumen-notify']:notify(text, duration, position)
```

| Paramètre | Type | Description |
| --- | --- | --- |
| `text` | `string` | Texte affiché |
| `duration` | `number?` | Durée en ms (défaut : `5000`) |
| `position` | `string?` | Position de la notification. `nil` utilise la préférence du joueur |

```lua
exports['lumen-notify']:notify('Bienvenue sur le serveur !')
exports['lumen-notify']:notify('Sauvegarde effectuée', 3000, 'top-right')
```

#### `notifyAdvanced`

Notification personnalisable.

```lua
exports['lumen-notify']:notifyAdvanced(options)
```

| Option | Type | Description |
| --- | --- | --- |
| `title` | `string?` | Titre |
| `subtitle` | `string?` | Sous-titre |
| `text` | `string?` | Texte principal |
| `logo` | `string?` | URL du logo |
| `backgroundImage` | `string?` | URL de l'image de fond |
| `backgroundColor` | `string?` | Couleur de fond |
| `progressColor` | `string?` | Couleur de la barre de progression |
| `duration` | `number?` | Durée en ms (défaut : `5000`) |
| `position` | `string?` | Position. `nil` utilise la préférence du joueur |

```lua
exports['lumen-notify']:notifyAdvanced({
    title           = 'Banque',
    subtitle        = 'Virement reçu',
    text            = 'Vous avez reçu 2 500$',
    logo            = 'https://exemple.com/logo.png',
    backgroundColor = '#1a1a2e',
    progressColor   = '#e94560',
    duration        = 7000,
    position        = 'top-right',
})
```

#### Préférences joueur

```lua
exports['lumen-notify']:setNotifyPosition('top-right')  -- change et sauvegarde la position
exports['lumen-notify']:getNotifyPosition()             -- retourne la position actuelle

exports['lumen-notify']:setNotifyOpacity(0.8)           -- change et sauvegarde l'opacité (0.1 à 1.0)
exports['lumen-notify']:getNotifyOpacity()              -- retourne l'opacité actuelle
```

### Côté serveur

Les exports serveur prennent l'ID du joueur en premier paramètre.

```lua
-- Vers un joueur
exports['lumen-notify']:notify(source, 'Texte', 5000, 'top-center')
exports['lumen-notify']:notifyAdvanced(source, {
    title = 'Annonce',
    text  = 'Redémarrage dans 10 minutes',
})

-- Vers tous les joueurs
exports['lumen-notify']:notifyAll('Texte', 5000, 'top-center')
exports['lumen-notify']:notifyAllAdvanced({
    title = 'Annonce',
    text  = 'Redémarrage dans 10 minutes',
})
```

### Events

| Event | Côté | Paramètres |
| --- | --- | --- |
| `lumen-notify:notify` | client | `text, duration, position` |
| `lumen-notify:notifyAdvanced` | client | `options` |
| `lumen-notify:setPosition` | client | `position` |
| `lumen-notify:setOpacity` | client | `opacity` |
| `lumen-notify:sv:notify` | serveur | `text, duration, position` |
| `lumen-notify:sv:notifyAdvanced` | serveur | `options` |

```lua
-- Depuis le serveur
TriggerClientEvent('lumen-notify:notify', source, 'Texte', 5000)

-- Depuis le client
TriggerServerEvent('lumen-notify:sv:notify', 'Texte', 5000)
```

---

## Commande de test

Le fichier `client/test.lua` ajoute la commande `/testnotify`, qui ouvre un formulaire `ox_lib` pour tester les notifications normales et avancées (texte, durée, position, couleurs, logo, image de fond).

> Pense à retirer `client/test.lua` du `fxmanifest.lua` en production.

---

## Structure

```
lumen-notify/
├── client/
│   ├── main.lua       # Exports, events, préférences joueur, watcher minimap
│   └── test.lua       # Commande /testnotify
├── server/
│   └── main.lua       # Exports et events serveur
├── ui/
│   ├── index.html
│   ├── css/style.css
│   └── js/main.js
├── config.lua
└── fxmanifest.lua
```

---

## Licence

Distribué sous licence **MIT**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
