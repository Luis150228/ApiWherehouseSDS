// ===== Imports =====
import { DEFAULT_KEYS, REPORT_TITLE } from './js/config.js';
import { byId } from './js/utils/dom.js';
import { fetchAll, resolveDateField } from './js/data/load.js'; // si no usas fetchAll puedes quitarlo
import { filterTickets } from './js/filters/index.js';
import { renderTreemap } from './js/treemap/index.js';
import { renderReport } from './js/report/renderReport.js';
import { saveReportAsPng } from './js/export/saveImage.js';
import { fetchGet, fetchPOST } from '../../../js/connect.js';
import { divLoader, divLoaderCreate } from '../../../js/elements.js';

// ===== Estado global =====
let ALL = [];
let DATE_FIELD = 'abierto';
let CURRENT_REPORT_INCIDENT = '';
const LEVEL_USR = Number(sessionStorage.getItem('lev') || 0);

// ===== Google Charts ready =====
google.charts.load('current', { packages: ['treemap'] });
const chartsReady = () => new Promise((resolve) => google.charts.setOnLoadCallback(resolve));

// ====== Helpers Zoom/Modal (una sola vez) ======
let ZOOM_READY = false;
let __modalInstance = null;

function initImageZoomOnce() {
  if (ZOOM_READY) return;

  const modalEl  = document.getElementById('fail-screen-modal');
  const img      = document.getElementById('ScreenFailImg');
  const viewport = document.getElementById('screenZoomViewport');
  const btnIn    = document.getElementById('zoomInBtn');
  const btnOut   = document.getElementById('zoomOutBtn');
  const btnReset = document.getElementById('zoomResetBtn');
  if (!modalEl || !img || !viewport) return;

  __modalInstance = __modalInstance || new bootstrap.Modal(modalEl);

  let scale = 1, tx = 0, ty = 0;
  const MIN = 1, MAX = 5, STEP = 0.2;

  const apply = () => {
    img.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
    if (btnReset) btnReset.textContent = `${Math.round(scale * 100)}%`;
  };
  const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
  const zoom  = d => { scale = clamp(+((scale + d).toFixed(2)), MIN, MAX); if (scale === 1) { tx = 0; ty = 0; } apply(); };
  const reset = () => { scale = 1; tx = 0; ty = 0; apply(); };

  btnIn?.addEventListener('click',  () => zoom(+STEP));
  btnOut?.addEventListener('click', () => zoom(-STEP));
  btnReset?.addEventListener('click', reset);

  let panning = false, startX = 0, startY = 0;
  img.addEventListener('mousedown', e => {
    if (scale <= 1) return;
    panning = true; img.classList.add('is-grabbing');
    startX = e.clientX - tx; startY = e.clientY - ty; e.preventDefault();
  });
  document.addEventListener('mousemove', e => {
    if (!panning) return;
    tx = e.clientX - startX; ty = e.clientY - startY; apply();
  });
  document.addEventListener('mouseup', () => {
    if (!panning) return;
    panning = false; img.classList.remove('is-grabbing');
  });

  viewport.addEventListener('wheel', e => {
    if (!e.ctrlKey) return;
    e.preventDefault();
    zoom(e.deltaY > 0 ? -STEP : +STEP);
  }, { passive: false });

  modalEl.addEventListener('shown.bs.modal', reset);
  modalEl.addEventListener('hidden.bs.modal', reset);

  // expón reset para cuando cambies la imagen
  img.__resetZoom = reset;

  ZOOM_READY = true;
}

function setScreenFailImage(base64) {
  const img = document.getElementById('ScreenFailImg');
  if (!img) return;

  const src = String(base64 || '').startsWith('data:')
    ? base64
    : (base64 ? `data:image/*;base64,${base64}` : '');

  // Forzar refresh y limpiar transform/zoom
  img.style.transform = '';
  img.removeAttribute('src');
  requestAnimationFrame(() => {
    img.src = src;
    img.__resetZoom?.();
  });
}

// ===== Auto-refresh cada X minutos =====
let __autoRefreshTimer = null;
let __autoRefreshMs = 0;

async function refreshOnce() {
  // Si estás editando, NO refresques para no pisar cambios
  const isEditing = byId('toggleEditBtn')?.dataset.state === 'on';
  if (isEditing) return;

  try {
    divLoader();
    const resp = await fetchGet('genericos', { generics: true, order: 'AllGenerics' });
    if (!resp || !resp.data) return;

    ALL = resp; // si prefieres solo data, usa: ALL = { data: resp.data }
    DATE_FIELD = resolveDateField(ALL.data, 'abierto');

    const incident = CURRENT_REPORT_INCIDENT || undefined;
    const rowsToDraw = incident
      ? filterTickets(ALL.data, { incident, dateField: DATE_FIELD })
      : ALL.data;

    draw(rowsToDraw, incident);
  } catch (err) {
    console.error('[auto-refresh] error:', err);
  } finally {
    divLoader();
  }
}

function startAutoRefresh(minutes = 10) {
  stopAutoRefresh(); // evita timers duplicados
  __autoRefreshMs = Math.max(1, minutes) * 60 * 1000;
  __autoRefreshTimer = setInterval(refreshOnce, __autoRefreshMs);
  refreshOnce(); // ejecuta uno inmediato
}

function stopAutoRefresh() {
  if (__autoRefreshTimer) clearInterval(__autoRefreshTimer);
  __autoRefreshTimer = null;
}

// Pausa cuando la pestaña no está visible; reanuda al volver
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    stopAutoRefresh();
  } else if (__autoRefreshMs) {
    startAutoRefresh(__autoRefreshMs / 60000);
  }
});

// ===== Arranque =====
(async () => {
  await chartsReady();
  divLoader();

  // Carga inicial
  ALL = await fetchGet('genericos', { generics: true, order: 'AllGenerics' });
  DATE_FIELD = resolveDateField(ALL.data, 'abierto');

  // Primer render
  draw(ALL.data);

  // Filtros
  byId('applyFilters')?.addEventListener('click', applyFilters);
  byId('clearFilters')?.addEventListener('click', () => {
    byId('qIncident') && (byId('qIncident').value = '');
    byId('qRegion') && (byId('qRegion').value = '');
    byId('qDate') && (byId('qDate').value = '');
    CURRENT_REPORT_INCIDENT = ''; // limpiar selección
    draw(ALL.data);
  });
  ['qIncident', 'qRegion', 'qDate'].forEach((id) => {
    byId(id)?.addEventListener('keydown', (e) => { if (e.key === 'Enter') applyFilters(); });
  });

  // Guardar PNG
  byId('saveReportBtn')?.addEventListener('click', async () => {
    const node = byId('report');
    await saveReportAsPng({
      node,
      incidentName: CURRENT_REPORT_INCIDENT,
      background: getComputedStyle(document.body).backgroundColor || '#121212',
    });
  });

  // Editar reporte (según nivel)
  if (LEVEL_USR > 1) {
    byId('toggleEditBtn')?.setAttribute('disabled', true);
    if (byId('toggleEditBtn')) byId('toggleEditBtn').style.display = 'none';
  } else {
    byId('toggleEditBtn')?.addEventListener('click', async () => {
      const editables = document.querySelectorAll('#report .value.editable');
      const on = byId('toggleEditBtn').dataset.state !== 'on';
      editables.forEach((n) => n.setAttribute('contenteditable', on ? 'true' : 'false'));
      byId('toggleEditBtn').dataset.state = on ? 'on' : 'off';
      byId('toggleEditBtn').textContent = on ? 'Terminar edición' : 'Editar';

      // al terminar edición -> guardar
      if (byId('toggleEditBtn').dataset.state === 'off') {
        const out = {};
        const cardBody = document.querySelector('.report-body');
        const dataKeys = cardBody?.querySelectorAll('[data-key]') || [];
        for (const dataKey of dataKeys) {
          const key = dataKey.dataset.key;
          const content = dataKey.innerText;
          out[key] = content;
        }
        divLoader();
        await fetchPOST('genericos', out);
        divLoader();
      }
    });
  }

  // Modal pausa/continúa auto-refresh
  const modalEl = document.getElementById('fail-screen-modal');
  modalEl?.addEventListener('shown.bs.modal', stopAutoRefresh);
  modalEl?.addEventListener('hidden.bs.modal', () => {
    if (__autoRefreshMs) startAutoRefresh(__autoRefreshMs / 60000);
  });

  // Auto-refresh cada 10 min (cámbialo a 15 si quieres)
  startAutoRefresh(10);

  divLoader();
})().catch(console.error);

// ===== Funciones =====
function applyFilters() {
  const incident = byId('qIncident')?.value.trim();
  const region = byId('qRegion')?.value.trim();
  const onlyDate = byId('qDate')?.value;

  const rows = filterTickets(ALL.data, {
    incident: incident || undefined,
    region: region || undefined,
    onlyDate: onlyDate || undefined,
    dateField: DATE_FIELD,
  });

  // guardamos el incidente si vino en input
  CURRENT_REPORT_INCIDENT = incident || '';
  draw(rows, incident);
}

function draw(rows, incidentQuery) {
  // 1) Gráfico con callback de selección
  renderTreemap('chart_generics', rows, DEFAULT_KEYS, {
    dateField: DATE_FIELD,
    onSelectIncident: (incident) => {
      // Filtra por incidente y redibuja todo (gráfico + aviso + modal)
      const filtered = filterTickets(ALL.data, { incident, dateField: DATE_FIELD });
      CURRENT_REPORT_INCIDENT = incident || '';
      draw(filtered, incident);
    }
  });

  // 2) Render del Aviso
  const info = renderReport({
    rows,
    incidentQuery,
    dateField: DATE_FIELD,
    reportTitle: REPORT_TITLE,
    mountId: 'report',
  });

  CURRENT_REPORT_INCIDENT = info.incident || CURRENT_REPORT_INCIDENT || '';

  // 3) Modal/Zoom + Imagen
  initImageZoomOnce();

  const btn   = document.getElementById('ScreenFailBtn');
  const imgEl = document.getElementById('ScreenFailImg');
  if (!btn || !imgEl) {
    console.warn('[ScreenFail] Botón o imagen no encontrados.');
    return;
  }

  // Soporta img_64 o img_b64; no dependas solo de img_size
  const base64Raw = info?.img_64 || info?.img_b64 || '';
  const hasImage =
    (Number.isFinite(Number(info?.img_size)) && Number(info.img_size) > 0) ||
    (typeof base64Raw === 'string' && base64Raw.length > 100);

  if (hasImage) {
    setScreenFailImage(base64Raw);

    btn.style.display = 'inline-block';
    btn.disabled = false;
    btn.removeAttribute('aria-disabled');
    btn.title = 'Ver pantalla de error';
    btn.textContent = 'Pantalla error';
  } else {
    imgEl.removeAttribute('src');
    imgEl.style.transform = '';
    btn.style.display = 'none';
    btn.disabled = true;
    btn.setAttribute('aria-disabled', 'true');
    btn.title = 'Sin imagen disponible';
    btn.textContent = 'Pantalla error';
  }
}