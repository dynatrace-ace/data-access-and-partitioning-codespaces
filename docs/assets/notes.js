(function () {
    // ===== generic helpers =====
    const PREFIX = 'mkdocs:notes:widget:';

    const parseCSV = (s) =>
        (s || '')
            .split(',')
            .map(x => x.trim())
            .filter(Boolean);

    function safeJSON(s) {
        try { return JSON.parse(s); } catch { return {}; }
    }

    // Build a regex that matches a term with flexible separators and case-insensitive.
    // e.g. "google cloud platform" => /\bgoogle[\s_-]*cloud[\s_-]*platform\b/i
    function termToRegex(term) {
        const parts = term.trim().replace(/\s+/g, ' ').split(' ');
        const joined = parts.map(p => p.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('[\\s_\\-]*');
        return new RegExp(`\\b${joined}\\b`, 'i');
    }

    // Compile alias map: { canonical -> [regexes...] }
    function compileMatchers(required, aliasesMap) {
        const matchers = {};
        for (const canon of required) {
            const alist = [canon, ...(aliasesMap[canon] || [])];
            matchers[canon] = alist.map(termToRegex);
        }
        return matchers;
    }

    const keyFor = (pagePath, widgetSig, idx) =>
        PREFIX + pagePath.replace(/\/index\.html$/, '/') + '|' + widgetSig + '|' + idx;

    const load = (k) => localStorage.getItem(k) || '';
    const save = (k, v) => localStorage.setItem(k, v);

    function analyze(text, matchers) {
        const found = [];
        for (const canon in matchers) {
            const regs = matchers[canon];
            if (regs.some(re => re.test(text))) found.push(canon.toLowerCase());
        }
        return { found, total: Object.keys(matchers).length };
    }

    // party time 🎉
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
        if (crazy && Math.random() < 0.7) {
            const burst = document.createElement('div');
            burst.className = 'notes__burst';
            burst.textContent = (POOL[Math.floor(Math.random() * POOL.length)]);
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

    function buildWidget(anchor, idx) {
        const required = parseCSV(anchor.getAttribute('data-required')).map(s => s.toLowerCase());
        if (!required.length) return;

        const aliasesRaw = anchor.getAttribute('data-aliases');
        const aliasesObj = safeJSON(aliasesRaw);
        // Normalize alias keys to canonical lowercase
        const normalizedAliases = {};
        for (const k in aliasesObj) {
            normalizedAliases[k.toLowerCase()] = (aliasesObj[k] || []).map(v => String(v).toLowerCase());
        }

        const matchers = compileMatchers(required, normalizedAliases);

        const hintText = anchor.getAttribute('data-hint') || 'Write what you discover, then Save.';
        const widgetSig = required.join(','); // storage signature
        const storageKey = keyFor(location.pathname, widgetSig, idx);

        const card = document.createElement('section');
        card.className = 'notes__card';

        const hint = document.createElement('div');
        hint.className = 'notes__hint';
        hint.textContent = hintText;
        card.appendChild(hint);

        const textarea = document.createElement('textarea');
        textarea.className = 'notes__textarea';
        textarea.rows = 8;
        textarea.placeholder = 'Type here…';
        textarea.value = load(storageKey);
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
        anchor.replaceWith(card);

        let lastFound = new Set(analyze(textarea.value, matchers).found);
        renderStatus(status, { found: [...lastFound], total: required.length });

        saveBtn.addEventListener('click', (e) => {
            ripple(e);
            const text = textarea.value;
            save(storageKey, text);

            const res = analyze(text, matchers);
            const newFound = new Set(res.found);
            const gained = [...newFound].filter(x => !lastFound.has(x));

            const all = newFound.size === required.length;
            if (all) {
                const crazy = Math.random() < 0.6;
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
                status.textContent = '🤔 No new items found. Keep exploring!';
                status.classList.add('notes__status--warn');
            }

            saveBtn.classList.add('notes__btn--saved');
            setTimeout(() => saveBtn.classList.remove('notes__btn--saved'), 600);

            lastFound = newFound;
        });

        textarea.addEventListener('input', () => {
            const res = analyze(textarea.value, matchers);
            renderStatus(status, res);
        });
    }

    function initAll() {
        const anchors = Array.from(document.querySelectorAll('.notes-widget'));
        if (!anchors.length) return;
        anchors.forEach((a, i) => buildWidget(a, i));
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initAll);
    } else {
        initAll();
    }
})();
