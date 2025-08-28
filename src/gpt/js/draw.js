function draw(rows, incidentQuery) {
  // 1) Dibuja treemap y pasa callback de selección
  renderTreemap('chart_generics', rows, DEFAULT_KEYS, {
    dateField: DATE_FIELD,
    onSelectIncident: (incident) => {
      // Cada clic en el treemap vuelve a filtrar y REDIBUJA TODO
      const filtered = filterTickets(ALL.data, {
        incident,
        dateField: DATE_FIELD,
      });
      draw(filtered, incident); // <- aquí se reactualiza Aviso + Imagen
    }
  });

  // 2) Render del “Aviso”
  const info = renderReport({
    rows,
    incidentQuery,
    dateField: DATE_FIELD,
    reportTitle: REPORT_TITLE,
    mountId: 'report',
  });

  CURRENT_REPORT_INCIDENT = info.incident || '';

  // 3) Modal/zoom + imagen (esto es lo que ya hicimos)
  initImageZoomOnce();

  const btn   = document.getElementById('ScreenFailBtn');
  const imgEl = document.getElementById('ScreenFailImg');
  if (!btn || !imgEl) return;

  // soporta img_64 o img_b64; no dependas solo de img_size
  const base64Raw = info?.img_64 || info?.img_b64 || '';
  const dataUrl = String(base64Raw || '').startsWith('data:')
    ? base64Raw
    : (base64Raw ? `data:image/*;base64,${base64Raw}` : '');

  const hasImage =
    (Number.isFinite(Number(info?.img_size)) && Number(info.img_size) > 0) ||
    (typeof base64Raw === 'string' && base64Raw.length > 100);

  console.debug('[ScreenFail] incident=', info.incident,
                'img_size=', info?.img_size,
                'b64_len=', base64Raw?.length || 0);

  if (hasImage && dataUrl) {
    imgEl.style.transform = '';
    imgEl.removeAttribute('src');
    requestAnimationFrame(() => {
      imgEl.src = dataUrl;
      imgEl.__resetZoom?.();
    });

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