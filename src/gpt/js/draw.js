function draw(rows, incidentQuery) {
  // 1) Gráfico y aviso
  renderTreemap('chart_generics', rows, DEFAULT_KEYS, { dateField: DATE_FIELD });

  const info = renderReport({
    rows,
    incidentQuery,
    dateField: DATE_FIELD,
    reportTitle: REPORT_TITLE,
    mountId: 'report',
  });

  CURRENT_REPORT_INCIDENT = info.incident || '';

  // 2) Modal + zoom (inicializa una vez)
  initImageZoomOnce();

  const btn   = document.getElementById('ScreenFailBtn');
  const imgEl = document.getElementById('ScreenFailImg');
  if (!btn || !imgEl) {
    console.warn('[ScreenFail] Botón o imagen no encontrados.');
    return;
  }

  // --- Tomar base64 de cualquiera de los dos campos
  const base64Raw = info?.img_64 || info?.img_b64 || '';

  // --- Construir data URL si aplica
  const dataUrl = String(base64Raw || '').startsWith('data:')
    ? base64Raw
    : (base64Raw ? `data:image/*;base64,${base64Raw}` : '');

  // --- Heurística de “hay imagen”: size válido o base64 decente
  const hasImage =
    (Number.isFinite(Number(info?.img_size)) && Number(info.img_size) > 0) ||
    (typeof base64Raw === 'string' && base64Raw.length > 100);

  // Debug mínimo para verificar qué llega
  console.debug('[ScreenFail] incident=', info.incident,
                'img_size=', info?.img_size,
                'b64_len=', base64Raw?.length || 0);

  if (hasImage && dataUrl) {
    // Forzar refresh del <img>: limpiar src y luego asignar
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
    // No hay imagen para este incidente
    imgEl.removeAttribute('src');
    imgEl.style.transform = '';

    btn.style.display = 'none';
    btn.disabled = true;
    btn.setAttribute('aria-disabled', 'true');
    btn.title = 'Sin imagen disponible';
    btn.textContent = 'Pantalla error';
  }
}