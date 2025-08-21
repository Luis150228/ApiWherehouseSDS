import { DEFAULT_KEYS, REPORT_TITLE } from './js/config.js';
import { byId } from './js/utils/dom.js';
import { fetchAll, resolveDateField } from './js/data/load.js';
import { filterTickets } from './js/filters/index.js';
import { renderTreemap } from './js/treemap/index.js';
import { renderReport } from './js/report/renderReport.js';
import { saveReportAsPng } from './js/export/saveImage.js';
import { fetchGet, fetchPOST } from '../../../js/connect.js';

let ALL = [];
let DATE_FIELD = 'abierto';
let CURRENT_REPORT_INCIDENT = '';

google.charts.load('current', { packages: ['treemap'] });
const chartsReady = () => new Promise((resolve) => google.charts.setOnLoadCallback(resolve));

(async () => {
	await chartsReady();

	ALL = await fetchGet('genericos', {generics : true, order : 'AllGenerics'});

	DATE_FIELD = resolveDateField(ALL.data, 'abierto');

	draw(ALL.data);

	byId('applyFilters')?.addEventListener('click', applyFilters);
	byId('clearFilters')?.addEventListener('click', () => {
		byId('qIncident').value = '';
		byId('qRegion').value = '';
		byId('qDate').value = '';
		draw(ALL.data);
	});

	['qIncident', 'qRegion', 'qDate'].forEach((id) => {
		byId(id)?.addEventListener('keydown', (e) => {
			if (e.key === 'Enter') applyFilters();
		});
	});

	byId('saveReportBtn')?.addEventListener('click', async () => {
		const node = byId('report');
		await saveReportAsPng({
			node,
			incidentName: CURRENT_REPORT_INCIDENT,
			background: getComputedStyle(document.body).backgroundColor || '#121212',
		});
	});

	byId('toggleEditBtn')?.addEventListener('click', async () => {
		const editables = document.querySelectorAll('#report .value.editable');
		const on = byId('toggleEditBtn').dataset.state !== 'on';
		editables.forEach((n) => n.setAttribute('contenteditable', on ? 'true' : 'false'));
		byId('toggleEditBtn').dataset.state = on ? 'on' : 'off';
		byId('toggleEditBtn').textContent = on ? 'Terminar edición' : 'Editar';

		if (byId('toggleEditBtn').dataset.state == 'off') {
			const out = {}/**Objeto Vacio */
			const cardBody = document.querySelector('.report-body')
			const dataKeys = cardBody.querySelectorAll('[data-key]')
			for (const dataKey of dataKeys) {
				const key = dataKey.dataset.key
				const content = dataKey.innerText
				out[key] = content /*Llenar objeto**/				
			}

			const updateGeneric = await fetchPOST('genericos', out)
			console.log(out)
			console.log(updateGeneric);
			// return out
		}

	});
})().catch(console.error);

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
	draw(rows, incident);
}

function openScreenFailModal(base64) {
  // Ajusta IDs si usas otros
  const modalEl = document.getElementById('screenFailModal');
  const imgEl   = document.getElementById('ScreenFailImg');

  if (!modalEl || !imgEl) {
    console.warn('[ScreenFail] Falta markup del modal o <img id="ScreenFailImg">');
    return;
  }

  // Asegura prefijo data URI
  const src = String(base64 || '').startsWith('data:')
    ? base64
    : `data:image/*;base64,${base64}`;

  imgEl.src = src;

  // Bootstrap 5 Modal
  if (window.bootstrap?.Modal) {
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();
  } else {
    // Fallback sin Bootstrap
    modalEl.style.display = 'block';
  }
}

function draw(rows, incidentQuery) {
  // 1) Treemap
  renderTreemap('chart_div2', rows, DEFAULT_KEYS, { dateField: DATE_FIELD });

  // 2) Aviso: renderReport DEBE devolver también img_size e img_64
  //    Asegúrate de que tu renderReport retorne, por ejemplo:
  //    return { incident: targetKey, img_size: withSec?.img_size, img_64: withSec?.img_64 };
  const info = renderReport({
    rows,
    incidentQuery,
    dateField: DATE_FIELD,
    reportTitle: REPORT_TITLE,
    mountId: 'report',
  });

  CURRENT_REPORT_INCIDENT = info.incident || '';

  // 3) Botón Pantalla Error (asegúrate que exista en el HTML)
  //    Ejemplo en tu index.html (antes del botón Editar):
  //    <button id="ScreenFailBtn" type="button" class="btn btn-outline-secondary btn-sm" title="Ver pantalla de error" style="display:none">Pantalla error</button>
  //
  //    Modal mínimo:
  //    <div class="modal fade" id="screenFailModal" tabindex="-1" aria-hidden="true">
  //      <div class="modal-dialog modal-lg modal-dialog-centered">
  //        <div class="modal-content">
  //          <div class="modal-header">
  //            <h5 class="modal-title">Pantalla de error</h5>
  //            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
  //          </div>
  //          <div class="modal-body"><img id="ScreenFailImg" class="img-fluid" alt="Pantalla de error" /></div>
  //        </div>
  //      </div>
  //    </div>

  let btn = document.getElementById('ScreenFailBtn');
  if (!btn) {
    // Si no está, no hacemos nada (no rompe)
    console.warn('[ScreenFail] #ScreenFailBtn no encontrado en el DOM.');
    return;
  }

  // Clonar para limpiar handlers anteriores (anti “no hace nada” por handler viejo)
  const btnClone = btn.cloneNode(true);
  btn.parentNode.replaceChild(btnClone, btn);
  btn = btnClone;

  // ¿Hay imagen válida?
  const hasImage =
    Number.isFinite(Number(info?.img_size)) &&
    Number(info.img_size) > 0 &&
    typeof info?.img_64 === 'string' &&
    info.img_64.trim().length > 0;

  if (hasImage) {
    // Mostrar + habilitar + texto + click
    btn.style.display = 'inline-block';
    btn.disabled = false;
    btn.removeAttribute('aria-disabled');
    btn.title = 'Ver pantalla de error';
    btn.textContent = 'Pantalla error';
    btn.addEventListener('click', () => openScreenFailModal(info.img_64), { once: true });
  } else {
    // Ocultar por completo (o deshabilitar si prefieres dejarlo visible)
    btn.style.display = 'none';
    btn.disabled = true;
    btn.setAttribute('aria-disabled', 'true');
    btn.title = 'Sin imagen disponible';
    btn.textContent = 'Pantalla error';
  }
}


/****************Logica modal************************ */
function ensureScreenFailModal() {
  let modal = document.getElementById('screenFailModal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'screenFailModal';
    modal.className = 'modal-eut';
    modal.setAttribute('role', 'dialog');
    modal.setAttribute('aria-modal', 'true');
    modal.setAttribute('aria-hidden', 'true');
    modal.innerHTML = `
      <div class="modal-eut__backdrop" data-close="1"></div>
      <div class="modal-eut__dialog">
        <button class="modal-eut__close" type="button" aria-label="Cerrar" data-close="1">&times;</button>
        <h3 class="modal-eut__title">Pantalla de Error</h3>
        <div class="modal-eut__body">
          <img id="screenFailImg" alt="Pantalla de Error" />
        </div>
      </div>
    `;
    modal.addEventListener('click', (e) => {
      if (e.target.dataset.close === '1') closeScreenFailModal();
    });
    document.body.appendChild(modal);
  }
  return modal;
}

function openScreenFailModal(img64) {
  const modal = ensureScreenFailModal();
  const img = modal.querySelector('#screenFailImg');
  const body = modal.querySelector('.modal-eut__body');

  if (img64 && img64.trim()) {
    img.style.display = 'block';
    img.src = `data:image/*;base64,${img64}`;
    body.dataset.empty = '0';
  } else {
    img.removeAttribute('src');
    img.style.display = 'none';
    body.dataset.empty = '1';
    body.innerHTML = '<p style="margin:8px 0">Sin imagen disponible.</p>';
  }
  modal.classList.add('is-open');
  modal.setAttribute('aria-hidden', 'false');
}

function closeScreenFailModal() {
  const modal = document.getElementById('screenFailModal');
  if (modal) {
    modal.classList.remove('is-open');
    modal.setAttribute('aria-hidden', 'true');
  }
}
