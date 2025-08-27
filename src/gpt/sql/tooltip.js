import { BASE_REPORT_URL } from '../config.js';
import { parseDateTime } from '../utils/date.js';

function rowHour(r, dateField) {
	if (r?.hora != null && r.hora !== '') {
		const m = String(r.hora).match(/\d{1,2}/);
		return m ? m[0] : String(r.hora);
	}
	const dt = parseDateTime(r?.[dateField]);
	return dt ? String(dt.getHours()) : '';
}

export function makeTooltip({ data, rows, keys, dateField }) {
	return function showSimpleTooltip(row, size) {
		const idPath = data.getValue(row, 0) || '';
		const parts = idPath.split('│').slice(1); // sin 'Tickets'

		// ⬇️ ahora sí tomamos el dia del label
		const [folioVal, regionVal, diaLabel, , hourLabel] = parts;
		const diaFromLabel = diaLabel?.trim();

		// ⬇️ filtra también por el día mostrado en el rectángulo
		const subset = rows.filter((r) => {
			if (folioVal && String(r.incidencia_principal) !== String(folioVal)) return false;
			if (regionVal && String(r.Region) !== String(regionVal)) return false;
			if (diaFromLabel && String(r.dia).trim() !== diaFromLabel) return false; // clave
			if (hourLabel) {
				if (rowHour(r, dateField) !== String(hourLabel).match(/\d{1,2}/)?.[0]) return false;
			}
			return true;
		});

		// El día a mostrar/enviar será el del label (o el del primer row filtrado)
		const dayValue = diaFromLabel || (subset[0] && subset[0].dia) || null;

		const params = new URLSearchParams();
		if (folioVal) params.set('folio', folioVal);
		if (regionVal) params.set('region', regionVal);
		if (diaFromLabel) params.set('dia', diaFromLabel); // ya no se usa el min/orden alfabético
		if (hourLabel) {
			const h = String(hourLabel).match(/\d{1,2}/);
			if (h) params.set('hour', h[0]);
		}
		const link = `${BASE_REPORT_URL}?generics=true&${params.toString()}`;

		const label = data.getFormattedValue(row, 0) || data.getValue(row, 0);
		// const total = Number(size) || 0;
		const total = (Number(size) || 0);
		const parent = data.getValue(row, 1);

		if (parent === null) {
			return `<div style="background:#272B30;padding:10px;color:#fff;font-family:Arial">
        <b>${label}</b><br/>Total: <b>${total}</b>
      </div>`;
		}

		const folio = folioVal ? String(folioVal) : '';

		return `
      <div style="background:#272B30;padding:10px;border:none;color:#fff;line-height:1.3;font-family:Arial">
        <div><b style="font-size:13px">${label}</b></div>
        ${folio ? `<div style="font-size:12px;opacity:.9;margin:2px 0 6px">Folio: <b>${folio}</b></div>` : ''}
        ${
					hourLabel
						? `<div style="font-size:12px;opacity:.9;margin:0 0 6px">Hora: <b>${
								String(hourLabel).match(/\d{1,2}/)?.[0] || hourLabel
						  }</b></div>`
						: ''
				}
        <div>Total: <b>${total}</b></div>
        <div style="margin-top:8px">
          <a href="${link}">
            <button type="button" style="background:#fa3939;color:#fff;border:none;padding:6px 10px;border-radius:6px;cursor:pointer">
              Descargar
            </button>
          </a>
        </div>
      </div>
    `;
	};
}
