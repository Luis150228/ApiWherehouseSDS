// ==== Helpers (agrega una sola vez, arriba del archivo) ====
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
    : `data:image/*;base64,${base64}`;

  // Forzar refresh y limpiar transform/zoom
  img.style.transform = '';
  img.src = '';
  requestAnimationFrame(() => {
    img.src = src;
    img.__resetZoom?.();
  });
}
// ==== /Helpers ====


function draw(rows, incidentQuery) {
  // 1) Gráfico y aviso (reporte)
  renderTreemap('chart_generics', rows, DEFAULT_KEYS, { dateField: DATE_FIELD });

  const info = renderReport({
    rows,
    incidentQuery,
    dateField: DATE_FIELD,
    reportTitle: REPORT_TITLE,
    mountId: 'report',
  });

  CURRENT_REPORT_INCIDENT = info.incident || '';

  // 2) Modal/zoom + imagen
  initImageZoomOnce();

  const btn   = document.getElementById('ScreenFailBtn');
  const imgEl = document.getElementById('ScreenFailImg');
  if (!btn || !imgEl) {
    console.warn('[ScreenFail] Botón o imagen no encontrados.');
    return;
  }

  const hasImage =
    Number.isFinite(Number(info?.img_size)) &&
    Number(info.img_size) > 0 &&
    !!info?.img_64;

  if (hasImage) {
    setScreenFailImage(info.img_64);

    btn.style.display = 'inline-block';
    btn.disabled = false;
    btn.removeAttribute('aria-disabled');
    btn.title = 'Ver pantalla de error';
    btn.textContent = 'Pantalla error';
  } else {
    // Ocultar/deshabilitar cuando no hay imagen
    btn.style.display = 'none';
    btn.disabled = true;
    btn.setAttribute('aria-disabled', 'true');
    btn.title = 'Sin imagen disponible';
    btn.textContent = 'Pantalla error';
    imgEl.src = '';
    imgEl.style.transform = '';
  }
}