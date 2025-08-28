/*
Y ahora en tu draw(rows, incidentQuery) reemplaza todo el bloque donde manejas ScreenFailBtn/modal por esto:
*/



const btn = document.getElementById('ScreenFailBtn');
  const imgEl = document.getElementById('ScreenFailImg');
  if (!btn || !imgEl) return;

  const hasImage =
    Number.isFinite(Number(info?.img_size)) &&
    Number(info.img_size) > 0 &&
    !!info?.img_64;

  if (hasImage) {
    ensureModalAndZoomInit();
    updateScreenFailImage(info.img_64);

    btn.style.display = 'inline-block';
    btn.disabled = false;
    btn.removeAttribute('aria-disabled');
    btn.title = 'Ver pantalla de error';
    btn.textContent = 'Pantalla error';

    // Si quieres abrir directo:
    // __modalInstance?.show();
  } else {
    btn.style.display = 'none';
    btn.disabled = true;
    btn.setAttribute('aria-disabled', 'true');
    btn.title = 'Sin imagen disponible';
    btn.textContent = 'Pantalla error';
    // Limpia imagen si no hay
    if (imgEl) imgEl.src = '';
  }