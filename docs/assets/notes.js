(function () {
    const KEY_PREFIX = 'mkdocs:notes:';
    const REQUIRED = ['app', 'environment', 'component', 'platform']; // hidden

    const pageKey = () => KEY_PREFIX + location.pathname.replace(/\/index\.html$/, '/');
    const loadNotes = () => localStorage.getItem(pageKey()) || '';
    const saveNotes = txt => localStorage.setItem(pageKey(), txt);

    function analyze(text) {
        const found = [];
        for (const dim of REQUIRED) {
            const re = new RegExp(`\\b${dim}\\b`, 'i');
            if (re.test(text)) found.push(dim);
        }
        return { found, total: REQUIRED.length };
    }

    function fireConfetti(container, { crazy = false } = {}) {
        const BASE = ['🎉', '✨', '🎊', '💥', '🌟', '💫', '🔥'];
        const EXTRA = ['🚀', '🦄', '🪄', '💎', '🌈', '🍀', '⚡', '🎯', '🧠', '🎈', '🍾', '🥳', '🧩', '🏆', '💜', '💙', '💚', '💛', '🪩', '🌀'];
        const POOL = crazy ? BASE.concat(EXTRA) : BASE;

        const count = crazy ? 52 : 24;
        const box = document.createElement('div');
        box.className = 'notes__confetti';
        for (let i = 0; i < count; i++) {
            const s = document.createElement('span');
            s.textContent = POOL[Math.floor(Math.random() * POOL.length)];
            s.style.left = Math.random() * 100 + '%';
            s.style.animationDelay = (Math.random() * 0.35) + 's';
            s.style.animationDuration = (1.2 + Math.random() * (crazy ? 1.3 : 0.8)) + 's';
            s.style.fontSize = (crazy ? 16 : 14) + Math.floor(Math.random() * (crazy ? 20 : 12)) + 'px';
            s.style.setProperty('--twist', (Math.random() * (crazy ? 720 : 480)) + 'deg');
            s.style.setProperty('--drift', (Math.random() * (crazy ? 50 : 30) - (crazy ? 25 : 15)) + 'px');
            box.appendChild(s);
        }

        // occasional center burst
        if (crazy && Math.random() < 0.7) {
            const burst = document.createElement('div');
            burst.className = 'notes__burst';
            burst.textContent = POOL[Math.floor(Math.random() * POOL.length)];
            box.appendChild(burst);
        }

        container.appendChild(box);
        setTimeout(() => box.remove(), crazy ? 2200 : 1800);
    }

    function ripple(e) {
        const btn = e.currentTarget;
        const r = document.createElement('span');
        r.className = 'notes__ripple';
        const rect = btn.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        r.style.width = r.style.height = size + 'px';
        r.style.left = (e.clientX - rect.left - size / 2) + 'px';
        r.style.top = (e.clientY - rect.top - size / 2) + 'px';
        btn.appendChild(r);
        setTimeout(() => r.remove(), 600);
    }

    function renderStatus(el, { found, total }, variant = 'neutral') {
        if (found.length === total) {
            el.textContent = `✅ You found all ${total}!`;
        } else if (found.length > 0) {
            el.textContent = `🔎 Found ${found.length}/${total}: ${found.join(', ')}`;
        } else {
            el.textContent = `✍️ Write your findings and hit Save.`;
        }
        el.classList.remove('notes__status--warn', 'notes__status--ok');
        if (variant === 'warn') el.classList.add('notes__status--warn');
        if (variant === 'ok') el.classList.add('notes__status--ok');
    }

    function init() {
        const container =
            document.querySelector('#reader-notes') ||
            document.querySelector('main article, .md-content__inner') ||
            document.querySelector('main, body');

        const card = document.createElement('section');
        card.className = 'notes__card';

        const hint = document.createElement('div');
        hint.className = 'notes__hint';
        hint.textContent = 'Write down the key dimensions you discover in this exercise.';
        card.appendChild(hint);

        const textarea = document.createElement('textarea');
        textarea.className = 'notes__textarea';
        textarea.rows = 8;
        textarea.placeholder = 'Type here…';
        textarea.value = loadNotes();
        card.appendChild(textarea);

        const row = document.createElement('div');
        row.className = 'notes__row';

        const saveBtn = document.createElement('button');
        saveBtn.className = 'notes__btn';
        saveBtn.type = 'button';
        saveBtn.textContent = '💾 Save';
        row.appendChild(saveBtn);

        const status = document.createElement('div');
        status.className = 'notes__status';
        row.appendChild(status);

        card.appendChild(row);
        container.appendChild(card);

        let lastFound = new Set(analyze(textarea.value).found);

        // Initial status
        renderStatus(status, { found: [...lastFound], total: REQUIRED.length });

        saveBtn.addEventListener('click', (e) => {
            ripple(e);
            const text = textarea.value;
            saveNotes(text);

            const res = analyze(text);
            const newFound = new Set(res.found);
            const gained = [...newFound].filter(x => !lastFound.has(x));

            const all = newFound.size === REQUIRED.length;
            if (all) {
                // choose randomly to go CRAZY sometimes
                const crazy = Math.random() < 0.6; // 60% chance bigger party
                renderStatus(status, res, 'ok');
                card.classList.remove('notes__card--shake');
                void card.offsetWidth;
                card.classList.add('notes__card--pulse', 'notes__card--rainbow');
                setTimeout(() => card.classList.remove('notes__card--pulse'), 600);
                setTimeout(() => card.classList.remove('notes__card--rainbow'), 1000);
                fireConfetti(card, { crazy });
            } else if (gained.length > 0) {
                card.classList.remove('notes__card--shake');
                void card.offsetWidth;
                card.classList.add('notes__card--pulse');
                setTimeout(() => card.classList.remove('notes__card--pulse'), 600);
                renderStatus(status, res, 'ok');
            } else {
                card.classList.remove('notes__card--pulse');
                void card.offsetWidth;
                card.classList.add('notes__card--shake');
                setTimeout(() => card.classList.remove('notes__card--shake'), 500);
                status.textContent = '🤔 No new dimensions found. Keep exploring!';
                status.classList.add('notes__status--warn');
            }

            // Button saved glow
            saveBtn.classList.add('notes__btn--saved');
            setTimeout(() => saveBtn.classList.remove('notes__btn--saved'), 600);

            lastFound = newFound;
        });

        // live feedback
        textarea.addEventListener('input', () => {
            const res = analyze(textarea.value);
            renderStatus(status, res);
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
