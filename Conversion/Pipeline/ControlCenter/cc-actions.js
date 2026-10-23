// SSG-4: Control Center routines, loaded into the CC page with
//   await page.addScriptTag({ path: 'E:/Repos/SsgTrial/Conversion/Pipeline/ControlCenter/cc-actions.js' })
// then called with page.evaluate, e.g.  return await page.evaluate(() => ccStartJob('SSG4_FUSBA_CASES'));
// DOM/jQuery only (the CC tab is often not visible, so real mouse clicks time out). All return a short text result.
(function () {
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  const vis = el => !!(el && (el.offsetWidth || el.offsetHeight || el.getClientRects().length));
  const fire = el => { el.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true })); };
  async function waitFor(fn, ms = 15000, step = 250) { for (let t = 0; t < ms; t += step) { const v = fn(); if (v) return v; await sleep(step); } return null; }
  function button(text, root = document) { return [...root.querySelectorAll('button')].find(b => vis(b) && b.innerText.trim() === text) || [...root.querySelectorAll('button')].find(b => vis(b) && b.innerText.includes(text)); }
  function openDialogs() { return [...document.querySelectorAll('.ui-dialog')].filter(d => d.style.display !== 'none'); }
  async function menu(mainId, item) {
    const main = document.getElementById(mainId); fire(main); await sleep(600);
    const panel = document.getElementById(main.getAttribute('aria-controls'));
    const mi = [...panel.querySelectorAll('[role=menuitem]')].find(m => m.innerText.trim() === item) || [...panel.querySelectorAll('[role=menuitem]')].find(m => m.innerText.includes(item));
    if (!mi) throw new Error(`menu item ${item} not found`);
    fire(mi); await sleep(1500);
  }
  function rowIn(root, name) { return [...root.querySelectorAll('.slick-row')].find(r => vis(r) && [...r.querySelectorAll('div')].some(d => d.innerText.trim() === name)); }
  // SlickGrid draws only the rows in view and redraws on a scroll event (setting scrollTop alone is not enough).
  async function gridRow(root, name) {
    const vp = [...root.querySelectorAll('.slick-viewport')].find(vis);
    if (!vp) return rowIn(root, name);
    const go = async top => { vp.scrollTop = top; vp.dispatchEvent(new Event('scroll')); await sleep(350); };
    await go(0);
    for (let i = 0; i < 200; i++) {
      const r = rowIn(root, name); if (r) { r.scrollIntoView({ block: 'nearest' }); return r; }
      if (vp.scrollTop + vp.clientHeight >= vp.scrollHeight) return null;
      await go(vp.scrollTop + Math.max(50, vp.clientHeight - 40));
    }
    return null;
  }

  // System Configuration > Batch & Forms > Available Jobs: read all jobs of the application.
  window.ccReadJobs = async function (app = 'AFBUS_2200COBOL_AMT') {
    await menu('SystemConfiguration-MainMenuItem', 'Batch');
    const s = await waitFor(() => document.getElementById('AvailableJobsFilterApplicationsMultiSelect'));
    for (const o of s.options) o.selected = (o.text === app);
    s.dispatchEvent(new Event('change', { bubbles: true }));
    if (window.jQuery && jQuery(s).multiselect) { try { jQuery(s).multiselect('refresh'); } catch (e) { } }
    await sleep(400);
    fire(button('Read all jobs from system', document.getElementById('BatchAndForms-AvailableJobs-tabPage')));
    const dlg = await waitFor(() => openDialogs().find(d => d.innerText.includes('Load new jobs from disk')));
    fire(button('Start Reading', dlg));
    const done = await waitFor(() => /Status\s+Done/.test(dlg.innerText.replace(/\s+/g, ' ')) && dlg, 120000, 1000);
    const txt = dlg.innerText.replace(/\s+/g, ' ');
    const ok = document.getElementById('OkButton'); if (ok) fire(ok);
    const n = k => (txt.match(new RegExp(k + ' (\\d+)')) || [])[1];
    return done ? `read jobs: ${n('Number of Jobs')} jobs, ${n('Jobs added')} added, ${n('Jobs removed')} removed` : 'read jobs: TIMEOUT ' + txt.slice(0, 200);
  };

  // Security > Jobs: make sure the named jobs are activated (Refresh, Edit, tick, Apply).
  window.ccActivate = async function (...names) {
    await menu('SecurityConfiguration-MainMenuItem', 'Jobs');
    const p = document.getElementById('SecurityJobs-tabPage');
    const only = p.querySelector('input[type=checkbox]'); if (only && only.checked) fire(only);
    fire(button('Refresh', p)); await sleep(2500);
    fire(button('Edit', p)); await sleep(1500);
    const out = [];
    for (const n of names) {
      const row = await gridRow(p, n);
      if (!row) { out.push(`${n}: NOT FOUND`); continue; }
      const cb = row.querySelector('input[type=checkbox]');
      if (cb.checked) { out.push(`${n}: already active`); continue; }
      fire(cb); out.push(`${n}: activated`);
    }
    const apply = button('Apply', p); if (apply && !apply.disabled) fire(apply); else fire(button('Cancel', p));
    await sleep(2000);
    return out.join('; ');
  };

  // Jobs > Start Job: start one job (optional script parameter), return the start time (local, yyyy-MM-dd HH:mm:ss).
  window.ccStartJob = async function (name, scriptParameter) {
    await menu('Jobs-MainMenuItem', 'Start Job');
    const box = await waitFor(() => [...document.querySelectorAll('input[type=text]')].find(i => vis(i) && /Jobname/i.test(i.getAttribute('aria-label') || i.id || i.name || '')) || [...document.querySelectorAll('input[type=text]')].filter(vis).pop());
    box.value = name; box.dispatchEvent(new Event('input', { bubbles: true })); box.dispatchEvent(new Event('change', { bubbles: true }));
    fire(button('Refresh')); await sleep(2000);
    const row = await gridRow(document.querySelector('#StartJob-tabPage') || document, name);
    if (!row) return `${name}: NOT FOUND in Start Job (activated? read?)`;
    fire(row.querySelector('.slick-cell') || row); await sleep(400);
    fire(button('Start job'));
    const dlg = await waitFor(() => openDialogs().find(d => d.innerText.includes('New Start job')));
    if (!dlg) return `${name}: start dialog did not open`;
    if (scriptParameter) {
      const cell = [...dlg.querySelectorAll('tr')].find(tr => tr.innerText.includes('Commandline (script) parameter'));
      const ed = cell && cell.querySelector('[contenteditable], input, textarea');
      if (ed) { if ('value' in ed) ed.value = scriptParameter; else ed.innerText = scriptParameter; ed.dispatchEvent(new Event('input', { bubbles: true })); }
    }
    const d = new Date(); const pad = v => String(v).padStart(2, '0');
    const at = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
    fire(button('Ok', dlg)); await sleep(1500);
    const still = openDialogs().find(x => x.innerText.includes('New Start job'));
    return still ? `${name}: dialog still open (not started)` : `${name}: started ${at}`;
  };

  window.ccFindRow = async (rootId, name) => { const r = await gridRow(document.getElementById(rootId), name); return r ? r.innerText.replace(/\s+/g, ' ').trim() : 'NOT FOUND'; };
  window.ccLoaded = 'cc-actions 3';
})();
