  // ...lo anterior de renderReport()

  mount.innerHTML = `
    <div class="report-card">
      <div class="report-header">
        <div class="slot-logo-header"><img src="./images/logoServiceDesk.svg" alt="Logotipo ServiceDesk"></div>
        <div class="title">${REPORT_TITLE}</div>
      </div>
      <div class="report-body">
        <div class="row"><span class="label">Aplicación:</span>
          <div class="value editable" contenteditable="true" data-placeholder="Escribe la aplicación">${escapeHtml(aplicacion)}</div></div>
        <div class="row"><span class="label">Falla:</span>
          <div class="value editable" contenteditable="true" data-placeholder="Describe la falla">${escapeHtml(falla)}</div></div>
        <div class="row"><span class="label">Mensaje de Error / Pantalla de Error:</span>
          <div class="value editable" contenteditable="true" data-placeholder="Mensaje o pantalla de error">${escapeHtml(mensajeError)}</div></div>
        <div class="row"><span class="label">Impacto:</span>
          <div class="value editable" contenteditable="true" data-placeholder="Número de afectados / detalle">${escapeHtml(impacto)}</div></div>
        <div class="row"><span class="label">Afectación:</span>
          <div class="value editable" contenteditable="true" data-placeholder="Área/servicio afectado">${escapeHtml(afectacion)}</div></div>
        <div class="row"><span class="label">Incidente Padre:</span>
          <span class="value strong">${escapeHtml(incidentePadre)}</span></div>
        <div class="row"><span class="label">Incidentes Asociados:</span>
          <div class="value editable" contenteditable="true" data-placeholder="Cantidad o lista">${escapeHtml(incidentesAsoc)}</div></div>
        <div class="row"><span class="label">Horario de inicio:</span>
          <div class="value editable" contenteditable="true" data-placeholder="YYYY-MM-DD hh:mm am/pm">${escapeHtml(hInicio)}</div></div>
        <div class="row"><span class="label">Hora de corte:</span>
          <div class="value editable" contenteditable="true" data-placeholder="YYYY-MM-DD hh:mm am/pm">${escapeHtml(hCorte)}</div></div>
      </div>
      <div class="report-footer">
        <div class="slot-brand-footer"><img src="./images/Banco_Santander_Logotipo.png" alt="Logotipo Santander"></div>
        <div class="sd">SERVICE DESK<br/>Soporte usuarios y Edificios<br/>End User Technologies<br/>Tel. 5551741101 Ext. 70767<br/>Bandejas Ext. 79500</div>
      </div>
    </div>`;

  // -------- Datos de imagen (si vienen) --------
  const raw64  = withSec?.img_64 || '';
  const imgSz  = Number.parseInt(withSec?.img_size ?? '', 10);
  const imgMime = withSec?.img_mime || 'image/png';

  const hasImage = !!raw64 && Number.isFinite(imgSz) && imgSz >= 0;
  const imgUrl   = hasImage
    ? (/^data:/.test(raw64) ? raw64 : `data:${imgMime};base64,${raw64}`)
    : '';

  return { incident: targetKey, hasImage, imgUrl };
}
