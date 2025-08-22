<div class="modal fade" id="fail-screen-modal" tabindex="-1" aria-labelledby="fail-screen-modalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content">
      <div class="modal-header">
        <h1 class="modal-title fs-5" id="fail-screen-modalLabel">Pantalla de Error</h1>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <div class="modal-body">
        <!-- Viewport scrollable -->
        <div id="screenZoomViewport">
          <!-- Stage transformable -->
          <img id="ScreenFailImg" class="img-fluid" alt="Pantalla de error" draggable="false" />
        </div>
      </div>

      <div class="modal-footer">
        <div class="btn-group me-auto" role="group" aria-label="Zoom controls">
          <button type="button" class="btn btn-outline-secondary btn-sm" id="zoomOutBtn" title="Alejar">−</button>
          <button type="button" class="btn btn-outline-secondary btn-sm" id="zoomResetBtn" title="Restablecer">100%</button>
          <button type="button" class="btn btn-outline-secondary btn-sm" id="zoomInBtn" title="Acercar">+</button>
        </div>
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
      </div>
    </div>
  </div>
</div>

/******CSS********/
/* Usa tu tema grey para colores */
[data-bs-theme="grey"] .modal-content {
  background: var(--bs-card-bg);
  color: var(--bs-body-color);
  border: 1px solid var(--bs-border-color);
}
[data-bs-theme="grey"] .modal-header,
[data-bs-theme="grey"] .modal-footer {
  background: var(--bs-card-cap-bg);
  border-color: var(--bs-border-color);
}

/* Viewport: limita alto y permite scroll si se sale */
#screenZoomViewport {
  max-height: 80vh;
  overflow: auto;
  /* Evita que la rueda haga scroll de fondo */
  overscroll-behavior: contain;
}

/* Imagen transformable (zoom/pan) */
#ScreenFailImg {
  display: block;
  width: 100%;
  height: auto;
  transform-origin: center center;
  cursor: grab;
  user-select: none;
}
#ScreenFailImg.is-grabbing { cursor: grabbing; }


/************JS**************/
(function initImageZoom() {
  const modalEl   = document.getElementById('fail-screen-modal');
  const img       = document.getElementById('ScreenFailImg');
  const viewport  = document.getElementById('screenZoomViewport');
  const btnIn     = document.getElementById('zoomInBtn');
  const btnOut    = document.getElementById('zoomOutBtn');
  const btnReset  = document.getElementById('zoomResetBtn');

  if (!modalEl || !img || !viewport) return;

  let scale = 1;
  let tx = 0, ty = 0;          // translate
  const MIN = 1, MAX = 5, STEP = 0.2;

  let panning = false;
  let startX = 0, startY = 0;

  function apply() {
    img.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
    btnReset && (btnReset.textContent = `${Math.round(scale * 100)}%`);
  }

  function clamp(val, min, max) { return Math.max(min, Math.min(max, val)); }

  function zoom(delta) {
    scale = clamp(+((scale + delta).toFixed(2)), MIN, MAX);
    // Si volvemos a 1, centramos
    if (scale === 1) { tx = 0; ty = 0; }
    apply();
  }

  function reset() {
    scale = 1; tx = 0; ty = 0;
    apply();
  }

  // Botones
  btnIn?.addEventListener('click',  () => zoom(+STEP));
  btnOut?.addEventListener('click', () => zoom(-STEP));
  btnReset?.addEventListener('click', reset);

  // Pan con mouse (cuando hay zoom)
  img.addEventListener('mousedown', (e) => {
    if (scale <= 1) return; // sin pan en escala 1
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

  // Zoom con rueda (mantén Ctrl para no bloquear scroll normal)
  viewport.addEventListener('wheel', (e) => {
    if (!e.ctrlKey) return; // solo si presionas Ctrl
    e.preventDefault();
    const dir = e.deltaY > 0 ? -STEP : +STEP;
    zoom(dir);
  }, { passive: false });

  // Al abrir el modal: reset por si viene de un estado previo
  modalEl.addEventListener('shown.bs.modal', reset);
  // Al cerrar, resetea para siguiente uso
  modalEl.addEventListener('hidden.bs.modal', reset);
})();

// Ejemplo cuando preparas el modal
const img = document.getElementById('ScreenFailImg');
img.src = `data:image/*;base64,${img_64}`; // tu cadena base64
const modal = new bootstrap.Modal(document.getElementById('fail-screen-modal'));
modal.show();

