function draw(rows, incidentQuery) {
  renderTreemap('chart_div2', rows, DEFAULT_KEYS, { dateField: DATE_FIELD });
  const info = renderReport({ rows, incidentQuery, dateField: DATE_FIELD, reportTitle: REPORT_TITLE, mountId: 'report' });
  CURRENT_REPORT_INCIDENT = info.incident || '';

  // <-- NUEVO: actualizar el botón de imagen y el modal
  updateErrorImageButton(info);
}
/***/

import { byId } from './js/utils/dom.js'; // asegúrate de tener este import arriba

function ensureImageModal() {
  if (byId('imgModal')) return;
  const wrap = document.createElement('div');
  wrap.id = 'imgModal';
  wrap.className = 'modal-eut';
  wrap.innerHTML = `
    <div class="modal-eut__backdrop"></div>
    <div class="modal-eut__dialog" role="dialog" aria-modal="true" aria-labelledby="imgModalTitle">
      <button type="button" class="modal-eut__close" aria-label="Cerrar">&times;</button>
      <div class="modal-eut__body">
        <h3 id="imgModalTitle" class="modal-eut__title">Pantalla de Error</h3>
        <img id="imgModalPreview" alt="Pantalla de error" />
      </div>
    </div>`;
  document.body.appendChild(wrap);

  // Cierre
  wrap.querySelector('.modal-eut__backdrop').addEventListener('click', () => wrap.classList.remove('is-open'));
  wrap.querySelector('.modal-eut__close').addEventListener('click', () => wrap.classList.remove('is-open'));
  document.addEventListener('keydown', (ev) => {
    if (ev.key === 'Escape') wrap.classList.remove('is-open');
  });
}

function updateErrorImageButton({ hasImage, imgUrl }) {
  const actions = document.querySelector('#reportWrap .report-actions');
  if (!actions) return;

  let btn = byId('btnViewError');
  if (!hasImage) {
    if (btn) btn.remove();
    return;
  }

  // crea el botón si no existe
  if (!btn) {
    btn = document.createElement('button');
    btn.id = 'btnViewError';
    btn.type = 'button';
    btn.textContent = 'Pantalla de Error';
    // estilos; si usas Bootstrap puedes cambiar por "btn btn-outline-light btn-sm"
    btn.className = 'btn-view-error';
    const editBtn = byId('toggleEditBtn');
    actions.insertBefore(btn, editBtn || actions.firstChild);
  }

  // (re)bind del click
  btn.onclick = () => {
    ensureImageModal();
    const modal = byId('imgModal');
    const img   = byId('imgModalPreview');
    img.src = imgUrl;
    modal.classList.add('is-open');
  };
}
