// --- Estado global (arriba del archivo)
let __zoomInited = false;
let __modalInstance = null;

function ensureModalAndZoomInit() {
  if (__zoomInited) return;

  const modalEl  = document.getElementById('fail-screen-modal');
  const img      = document.getElementById('ScreenFailImg');
  const viewport = document.getElementById('screenZoomViewport');
  const btnIn    = document.getElementById('zoomInBtn');
  const btnOut   = document.getElementById('zoomOutBtn');
  const btnReset = document.getElementById('zoomResetBtn');

  if (!modalEl || !img || !viewport) return;

  // Reusar la instancia del modal
  __modalInstance = __modalInstance || new bootstrap.Modal(modalEl);

  // Estado de zoom
  let scale = 1, tx = 0, ty = 0;
  const MIN = 1, MAX = 5, STEP = 0.2;

  let panning = false;
  let startX = 0, startY = 0;

  function apply() {
    img.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
    if (btnReset) btnReset.textContent = `${Math.round(scale * 100)}%`;
  }
  function clamp(val, min, max) { return Math.max(min, Math.min(max, val)); }
  function zoom(delta) {
    scale = clamp(+((scale + delta).toFixed(2)), MIN, MAX);
    if (scale === 1) { tx = 0; ty = 0; }
    apply();
  }
  function reset() {
    scale = 1; tx = 0; ty = 0;
    img.style.transform = '';
    apply();
  }

  // Exponer reset para otros lados
  img.dataset.resetFn = '1';
  img.__resetZoom = reset;

  // Controles
  btnIn?.addEventListener('click',  () => zoom(+STEP));
  btnOut?.addEventListener('click', () => zoom(-STEP));
  btnReset?.addEventListener('click', reset);

  // Pan con mouse
  img.addEventListener('mousedown', (e) => {
    if (scale <= 1) return;
    panning = true;
    img.classList.add('is-grabbing');
    startX = e.clientX - tx;
    startY = e.clientY - ty;
    e.preventDefault();
  });
  document.addEventListener('mousemove', (e) => {
    if (!panning) return;
    tx = e.clientX - startX;
    ty = e.clientY - startY;
    apply();
  });
  document.addEventListener('mouseup', () => {
    if (!panning) return;
    panning = false;
    img.classList.remove('is-grabbing');
  });

  // Zoom con rueda (Ctrl)
  viewport.addEventListener('wheel', (e) => {
    if (!e.ctrlKey) return;
    e.preventDefault();
    zoom(e.deltaY > 0 ? -STEP : +STEP);
  }, { passive: false });

  modalEl.addEventListener('shown.bs.modal', reset);
  modalEl.addEventListener('hidden.bs.modal', reset);

  __zoomInited = true;
}

function updateScreenFailImage(base64) {
  const img = document.getElementById('ScreenFailImg');
  if (!img) return;

  // Asegura data URL correcto
  const src = String(base64 || '').startsWith('data:')
    ? base64
    : `data:image/*;base64,${base64}`;

  // Forzar recarga y limpiar transform
  img.style.transform = '';
  img.src = ''; // “invalidate” actual
  requestAnimationFrame(() => {
    img.src = src;
    // Reset de zoom si existe
    if (typeof img.__resetZoom === 'function') img.__resetZoom();
  });
}