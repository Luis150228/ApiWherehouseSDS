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

function draw(rows, incidentQuery) {
  // Dibuja el treemap
  renderTreemap('chart_generics', rows, DEFAULT_KEYS, { dateField: DATE_FIELD });

  // Render del aviso y datos auxiliares (incluye img_size, img_64)
  const info = renderReport({
    rows,
    incidentQuery,
    dateField: DATE_FIELD,
    reportTitle: REPORT_TITLE,
    mountId: 'report',
  });

  // Nombre del incidente para el PNG
  CURRENT_REPORT_INCIDENT = info.incident || '';

  // ===== Botón "Pantalla Error" =====
  const screenBtn = document.getElementById('ScreenFailBtn');

  // ¿hay imagen válida? (tamaño > 0 y base64 no vacío)
  const hasImage =
    Number.isFinite(info.img_size) &&
    info.img_size > 0 &&
    !!(info.img_64 && String(info.img_64).trim());

  if (screenBtn) {
    if (hasImage) {
      // Mostrar y habilitar
      screenBtn.style.display = 'inline-block';
      screenBtn.disabled = false;
      screenBtn.removeAttribute('aria-disabled');
      screenBtn.title = 'Ver pantalla de error';
      screenBtn.onclick = () => openScreenFailModal(info.img_64);
    } else {
      // Opción A: deshabilitar y dejar visible
      screenBtn.disabled = true;
      screenBtn.setAttribute('aria-disabled', 'true');
      screenBtn.title = 'Sin imagen disponible';
      screenBtn.onclick = null;

      // Opción B: ocultar completamente (descomenta si prefieres ocultar)
      // screenBtn.style.display = 'none';
    }
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
