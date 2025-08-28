import { DEFAULT_KEYS, REPORT_TITLE } from './js/config.js';
import { byId } from './js/utils/dom.js';
import { fetchAll, resolveDateField } from './js/data/load.js';
import { filterTickets } from './js/filters/index.js';
import { renderTreemap } from './js/treemap/index.js';
import { renderReport } from './js/report/renderReport.js';
import { saveReportAsPng } from './js/export/saveImage.js';
import { fetchGet, fetchPOST } from '../../../js/connect.js';
import { divLoader, divLoaderCreate } from '../../../js/elements.js';

let ALL = [];
let DATE_FIELD = 'abierto';
let CURRENT_REPORT_INCIDENT = '';
let LEVEL_USR = sessionStorage.getItem('lev')
if (LEVEL_USR > 1) {
	byId('toggleEditBtn')?.setAttribute('disabled', true)
	byId('toggleEditBtn').style.display = 'none'
}

google.charts.load('current', { packages: ['treemap'] });
const chartsReady = () => new Promise((resolve) => google.charts.setOnLoadCallback(resolve));

(async () => {
	await chartsReady();
	// divLoaderCreate();
	divLoader();
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
	divLoader();
	
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
			divLoader();
			await fetchPOST('genericos', out)
			divLoader();
			// console.log(out)
			// console.log(updateGeneric);
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
  renderTreemap('chart_generics', rows, DEFAULT_KEYS, { dateField: DATE_FIELD });
  const info = renderReport({
    rows,
    incidentQuery,
    dateField: DATE_FIELD,
    reportTitle: REPORT_TITLE,
    mountId: 'report',
  });

  CURRENT_REPORT_INCIDENT = info.incident || '';

  let btn = document.getElementById('ScreenFailBtn');
  const imgEl = document.getElementById('ScreenFailImg');
  if (!btn) {
    console.warn('[ScreenFail] #ScreenFailBtn no encontrado en el DOM.');
    return;
  }

  const hasImage =
    Number.isFinite(Number(info?.img_size)) &&
    Number(info.img_size) > 0;
	
	if (hasImage) {
	  const base64 = info.img_64
		const src = String(base64 || '').startsWith('data:')
		  ? base64
		  : `data:image/*;base64,${base64}`;
  
		imgEl.src = src;

    // Mostrar + habilitar + texto + click
    btn.style.display = 'inline-block';
    btn.disabled = false;
    btn.removeAttribute('aria-disabled');
    btn.title = 'Ver pantalla de error';
    btn.textContent = 'Pantalla error';
    // btn.addEventListener('click', () => openScreenFailModal(info.img_64), { once: true });
	/*************Control zoom*******************/
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
  img.src = `data:image/*;base64,${base64}`; // tu cadena base64
  const modal = new bootstrap.Modal(document.getElementById('fail-screen-modal'));
  // modal.show();
	/*************Control zoom*******************/

  } else {
    // Ocultar por completo (o deshabilitar si prefieres dejarlo visible)
    btn.style.display = 'none';
    btn.disabled = true;
    btn.setAttribute('aria-disabled', 'true');
    btn.title = 'Sin imagen disponible';
    btn.textContent = 'Pantalla error';
  }
  
}
