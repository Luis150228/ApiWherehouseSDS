const inpGeneric    = document.getElementById('inc-generic');
const inpGenericImg = document.getElementById('inc-image');
const previewBox    = document.getElementById('img-preview');
const MAX_IMG_BYTES = 9 * 1024 * 1024; // 9 MB

// Preview al seleccionar imagen
inpGenericImg?.addEventListener('change', () => {
  previewBox.innerHTML = '';
  const f = inpGenericImg.files?.[0];
  if (!f) return;

  if (!f.type.startsWith('image/')) {
    showMsg('El archivo debe ser una imagen.', 'warn');
    inpGenericImg.value = '';
    return;
  }
  if (f.size > MAX_IMG_BYTES) {
    showMsg('La imagen supera los 9 MB.', 'warn');
    inpGenericImg.value = '';
    return;
  }

  const url = URL.createObjectURL(f);
  const img = new Image();
  img.onload = () => URL.revokeObjectURL(url);
  img.src = url;
  img.alt = 'Vista previa';
  img.style.maxWidth = '240px';
  img.style.height = 'auto';
  img.style.borderRadius = '6px';
  previewBox.appendChild(img);
});

// Convierte File -> { base64, mime, size, name }
function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const fr = new FileReader();
    fr.onerror = () => reject(new Error('No se pudo leer la imagen'));
    fr.onload = () => {
      const dataUrl = String(fr.result || '');
      const base64 = dataUrl.split(',')[1] || ''; // sin "data:image/...;base64,"
      resolve({
        base64,
        mime: file.type,
        size: file.size,
        name: file.name,
      });
    };
    fr.readAsDataURL(file);
  });
}

// Guardar (texto + imagen opcional en base64)
btnSave.addEventListener('click', async (e) => {
  e.preventDefault();
  if (!inpGeneric || !btnSave) return;

  const value = inpGeneric.value.trim();
  if (!value) {
    showMsg('Captura un folio.', 'warn');
    return;
  }

  // Si hay imagen, valida y convierte
  let imgPayload = null;
  const file = inpGenericImg.files?.[0] || null;
  if (file) {
    if (!file.type.startsWith('image/')) {
      showMsg('El archivo debe ser una imagen.', 'warn');
      return;
    }
    if (file.size > MAX_IMG_BYTES) {
      showMsg('La imagen supera los 9 MB.', 'warn');
      return;
    }
    try {
      const { base64, mime, size, name } = await fileToBase64(file);
      imgPayload = { img_b64: base64, img_mime: mime, img_size: size, img_name: name };
    } catch (err) {
      console.error(err);
      showMsg('No se pudo procesar la imagen.', 'err');
      return;
    }
  }

  // estado busy
  showBtnSpinner(btnSave, 'Guardando…');
  inpGeneric.setAttribute('disabled', 'true');
  inpGenericImg.setAttribute('disabled', 'true');

  // Payload final
  const payload = {
    typeGeneric: 'activate',
    generic: value,
    order: 'CREATE',
    ...(imgPayload || {}), // añade img_* solo si hay imagen
  };
  console.log('payload', payload);

  try {
    const res  = await fetchPOST('genericos', payload);
    const code = typeof res?.code !== 'undefined' ? Number(res.code) : undefined;

    if (code === 200) {
      inpGeneric.value = '';
      inpGenericImg.value = '';
      previewBox.innerHTML = '';
      showMsg('Guardado.', 'ok');
      liActiveGeneric(res.data, 'list-active-generic');
    } else if (code === 204) {
      showMsg('El folio no existe (204).', 'err');
    } else {
      showMsg(`Error inesperado${code ? ` (${code})` : ''}.`, 'err');
    }
  } catch (err) {
    console.error(err);
    showMsg('Error de red/servidor.', 'err');
  } finally {
    hideBtnSpinner(btnSave);
    inpGeneric.removeAttribute('disabled');
    inpGenericImg.removeAttribute('disabled');
  }
});