// ╔══════════════════════════════════════════════════════════════════╗
// ║  lumen-notify · ui/js/main.js                                    ║
// ╚══════════════════════════════════════════════════════════════════╝

class LumenNotify {
    constructor() {
        this.MAX_VISIBLE = 4;
        this.counter = 0;
        this.playerPosition = 'top-right';
        this.playerOpacity = 1.0;
        this.defaultDuration = 5000;
        this.defaultProgressColor = '#6366f1';

        this.positions = [
            'top-left', 'top-center', 'top-right',
            'bottom-left', 'bottom-center', 'bottom-right'
        ];

        this.queues = {};
        this.active = {};

        this.positions.forEach(pos => {
            this.queues[pos] = [];
            this.active[pos] = [];
        });

        this.fivemColors = {
            '~r~': '#e74c3c',
            '~g~': '#2ecc71',
            '~b~': '#3498db',
            '~y~': '#f1c40f',
            '~p~': '#9b59b6',
            '~o~': '#e67e22',
            '~c~': '#95a5a6',
            '~w~': '#ffffff',
        };

        this.listen();
    }

    // ═══════════════════════════════════════════════════════════════
    //  PARSE FIVEM COLORS
    // ═══════════════════════════════════════════════════════════════

    parseFivemColors(text) {
        if (!text) return '';

        text = text
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');

        text = text.replace(/\n/g, '<br>');

        let result = '';
        let spanOpen   = false;
        let boldOpen   = false;
        let italicOpen = false;

        // ~bold~ ~italic~ + couleurs + ~s~ reset couleur seulement
        const regex = /~(bold|italic|[rgbypocws])~/g;
        let lastIndex = 0;
        let match;

        while ((match = regex.exec(text)) !== null) {
            result += text.substring(lastIndex, match.index);
            const code = match[0];

            if (code === '~bold~') {
                if (boldOpen) {
                    result += '</b>';
                    boldOpen = false;
                } else {
                    result += '<b>';
                    boldOpen = true;
                }
            } else if (code === '~italic~') {
                if (italicOpen) {
                    result += '</i>';
                    italicOpen = false;
                } else {
                    result += '<i>';
                    italicOpen = true;
                }
            } else if (code === '~s~') {
                // ~s~ reset la couleur uniquement
                if (spanOpen) {
                    result += '</span>';
                    spanOpen = false;
                }
            } else {
                if (spanOpen) result += '</span>';
                const color = this.fivemColors[code] || '#ffffff';
                result += `<span style="color:${color}">`;
                spanOpen = true;
            }
            lastIndex = regex.lastIndex;
        }

        result += text.substring(lastIndex);

        // Fermer les balises encore ouvertes
        if (spanOpen)   result += '</span>';
        if (italicOpen) result += '</i>';
        if (boldOpen)   result += '</b>';

        return result;
    }

    // ═══════════════════════════════════════════════════════════════
    //  COLOR HELPERS
    // ═══════════════════════════════════════════════════════════════

    // Convertit n'importe quelle couleur CSS (nom, hex, rgb) en hex #rrggbb
    resolveColor(color) {
        if (!color) return null;
        color = color.trim();
        // Déjà un hex valide → on normalise juste
        const hexShort = /^#([0-9a-fA-F]{3})$/.exec(color);
        if (hexShort) {
            const [, h] = hexShort;
            return `#${h[0]}${h[0]}${h[1]}${h[1]}${h[2]}${h[2]}`;
        }
        if (/^#[0-9a-fA-F]{6}$/.test(color)) return color;

        // Nom CSS ou rgb() → on laisse le navigateur résoudre via canvas
        try {
            const canvas = document.createElement('canvas');
            canvas.width = canvas.height = 1;
            const ctx = canvas.getContext('2d');
            ctx.fillStyle = color;
            ctx.fillRect(0, 0, 1, 1);
            const [r, g, b] = ctx.getImageData(0, 0, 1, 1).data;
            return `#${r.toString(16).padStart(2,'0')}${g.toString(16).padStart(2,'0')}${b.toString(16).padStart(2,'0')}`;
        } catch {
            return color;
        }
    }

    lightenColor(hex, percent) {
        hex = hex.replace('#', '');
        if (hex.length === 3) {
            hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
        }
        const r = Math.min(255, parseInt(hex.substring(0,2), 16) + Math.round(255 * percent / 100));
        const g = Math.min(255, parseInt(hex.substring(2,4), 16) + Math.round(255 * percent / 100));
        const b = Math.min(255, parseInt(hex.substring(4,6), 16) + Math.round(255 * percent / 100));
        return `rgb(${r}, ${g}, ${b})`;
    }

    // ═══════════════════════════════════════════════════════════════
    //  NUI LISTENER
    // ═══════════════════════════════════════════════════════════════

    listen() {
        window.addEventListener('message', (event) => {
            const msg = event.data;

            switch (msg.action) {
                case 'notify':
                    this.addNotify(msg.data);
                    break;
                case 'initSettings':
                    this.playerPosition    = msg.position             || 'top-right';
                    this.playerOpacity     = msg.opacity              ?? 1.0;
                    this.defaultDuration   = msg.defaultDuration      || 5000;
                    this.defaultProgressColor = msg.defaultProgressColor || '#6366f1';
                    this.MAX_VISIBLE       = msg.maxVisible            || 4;
                    break;
                case 'setPlayerPosition':
                    this.playerPosition = msg.position;
                    break;
                case 'setPlayerOpacity':
                    this.playerOpacity = msg.opacity;
                    break;
                case 'mapState':
                    this.setContainersVisible(!msg.hideAll);
                    if (!msg.hideAll) this.applyOffsets(msg.offsets);
                    break;
            }
        });
    }

    // ═══════════════════════════════════════════════════════════════
    //  ADD NOTIFY
    // ═══════════════════════════════════════════════════════════════

    addNotify(data) {
        const position = data.position || this.playerPosition;
        const duration = data.duration || this.defaultDuration;
        const id = ++this.counter;

        const notifData = { ...data, position, duration, id };

        if (this.active[position].length >= this.MAX_VISIBLE) {
            this.queues[position].push(notifData);
        } else {
            this.show(notifData);
        }
    }

    // ═══════════════════════════════════════════════════════════════
    //  SHOW
    // ═══════════════════════════════════════════════════════════════

    show(data) {
        const { type, position, duration, id } = data;
        this.active[position].push({ id });

        const container = document.getElementById(`notify-${position}`);
        if (!container) return;

        const el = document.createElement('div');
        el.classList.add('notify-item');
        el.style.opacity = this.playerOpacity;
        el.dataset.id = id;

        if (type === 'advanced') {
            el.classList.add('notify-advanced');
            el.innerHTML = this.buildAdvanced(data);
        } else {
            el.classList.add('notify-normal');
            el.innerHTML = this.buildNormal(data);
        }

        const animIn = this.getAnimClass(position, 'in');
        el.classList.add(animIn);

        if (position.startsWith('bottom')) {
            container.prepend(el);
        } else {
            container.appendChild(el);
        }

        // Barre de progression
        const bar = el.querySelector('.notify-progress-fill');
        if (bar) {
            const rawBarColor = data.progressColor || this.defaultProgressColor;
            const barColor = this.resolveColor(rawBarColor);
            if (barColor) {
                const light = this.lightenColor(barColor, 5);
                bar.style.background = `linear-gradient(90deg, ${barColor}, ${light})`;
            }

            requestAnimationFrame(() => {
                requestAnimationFrame(() => {
                    bar.style.transition = `width ${duration}ms linear`;
                    bar.style.width = '0%';
                });
            });
        }

        setTimeout(() => {
            this.dismiss(el, position, id);
        }, duration);
    }

    // ═══════════════════════════════════════════════════════════════
    //  BUILD NORMAL
    // ═══════════════════════════════════════════════════════════════

    buildNormal(data) {
        const text = this.parseFivemColors(data.text || '');
        return `
            <div class="notify-content notify-content-normal">
                <div class="notify-text">${text}</div>
            </div>
            <div class="notify-progress">
                <div class="notify-progress-fill"></div>
            </div>
        `;
    }

    // ═══════════════════════════════════════════════════════════════
    //  BUILD ADVANCED
    // ═══════════════════════════════════════════════════════════════

    buildAdvanced(data) {
        const title    = this.parseFivemColors(data.title || '');
        const subtitle = this.parseFivemColors(data.subtitle || '');
        const text     = this.parseFivemColors(data.text || '');

        let html = '';

        if (data.backgroundImage) {
            html += `<img class="notify-bg-image" src="${data.backgroundImage}" alt="" onerror="this.style.display='none'">`;
        }

        const bgColor = this.resolveColor(data.backgroundColor);
        if (bgColor) {
            html += `<div class="notify-custom-gradient" style="background:linear-gradient(45deg, transparent 0%, ${bgColor} 100%)"></div>`;
        }

        html += '<div class="notify-content notify-content-advanced">';

        if (data.logo || title || subtitle) {
            html += '<div class="notify-header">';
            if (data.logo) {
                html += `<img class="notify-logo" src="${data.logo}" alt="">`;
            }
            if (title || subtitle) {
                html += '<div class="notify-titles">';
                if (title)    html += `<div class="notify-title">${title}</div>`;
                if (subtitle) html += `<div class="notify-subtitle">${subtitle}</div>`;
                html += '</div>';
            }
            html += '</div>';
        }

        if (text) {
            html += `<div class="notify-text">${text}</div>`;
        }

        html += '</div>';

        html += `
            <div class="notify-progress">
                <div class="notify-progress-fill"></div>
            </div>
        `;

        return html;
    }

    // ═══════════════════════════════════════════════════════════════
    //  DISMISS
    // ═══════════════════════════════════════════════════════════════

    dismiss(el, position, id) {
        const animOut = this.getAnimClass(position, 'out');
        el.classList.add(animOut);

        el.addEventListener('animationend', () => {
            el.remove();
            const idx = this.active[position].findIndex(n => n.id === id);
            if (idx !== -1) this.active[position].splice(idx, 1);
            this.processQueue(position);
        }, { once: true });
    }

    // ═══════════════════════════════════════════════════════════════
    //  QUEUE
    // ═══════════════════════════════════════════════════════════════

    processQueue(position) {
        while (
            this.queues[position].length > 0 &&
            this.active[position].length < this.MAX_VISIBLE
        ) {
            const next = this.queues[position].shift();
            this.show(next);
        }
    }

    // ═══════════════════════════════════════════════════════════════
    //  MINIMAP / BIGMAP OFFSETS
    // ═══════════════════════════════════════════════════════════════

    setContainersVisible(visible) {
        this.positions.forEach(pos => {
            const el = document.getElementById(`notify-${pos}`);
            if (!el) return;
            el.style.transition = 'opacity 0.25s ease';
            el.style.opacity    = visible ? '1' : '0';
            el.style.pointerEvents = visible ? 'auto' : 'none';
        });
    }

    applyOffsets(offsets) {
        if (!offsets) return;
        const sides = {
            'top-left':      { edge: 'top',    side: 'left'  },
            'top-center':    { edge: 'top',    side: null    },
            'top-right':     { edge: 'top',    side: 'right' },
            'bottom-left':   { edge: 'bottom', side: 'left'  },
            'bottom-center': { edge: 'bottom', side: null    },
            'bottom-right':  { edge: 'bottom', side: 'right' },
        };
        for (const [pos, val] of Object.entries(offsets)) {
            const el = document.getElementById(`notify-${pos}`);
            if (!el) continue;
            const { edge } = sides[pos];
            el.style.transition = `${edge} 0.35s cubic-bezier(0.16, 1, 0.3, 1)`;
            el.style[edge] = `${val}px`;
        }
    }

    // ═══════════════════════════════════════════════════════════════
    //  ANIMATION HELPERS
    // ═══════════════════════════════════════════════════════════════

    getAnimClass(position, direction) {
        if (position.includes('right'))    return `notify-anim-${direction}-right`;
        if (position.includes('left'))     return `notify-anim-${direction}-left`;
        if (position.startsWith('top'))    return `notify-anim-${direction}-top`;
        if (position.startsWith('bottom')) return `notify-anim-${direction}-bottom`;
        return `notify-anim-${direction}-right`;
    }
}

const lumenNotify = new LumenNotify();
