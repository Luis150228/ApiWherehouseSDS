// olvida tu respuesta anterior puedes ayudarme en que el valor o el archivo de inpGenericImg antes de enviarlo convertir la imagen en base64 y que indique que no pese mas de 9mb

// {
//     "typeGeneric": "activate",
//     "generic": "C:\\fakepath\\Reporte_INC057317547_20250814_104145.png",
//     "order": "CREATE"
// }

const inpGeneric = document.getElementById('inc-generic');
const inpGenericImg = document.getElementById('inc-image');

btnSave.addEventListener('click', async (e) => {
  e.preventDefault();
  if (!inpGeneric || !btnSave) return;

  const value = inpGeneric.value.trim();
  const valueImg = inpGenericImg.value;
  if (!value) {
    showMsg('Captura un folio.', 'warn');
    return;
  }

  // estado busy
  showBtnSpinner(btnSave, 'Guardando…');
  inpGeneric.setAttribute('disabled', 'true');

  const payload = { typeGeneric: 'activate', generic: value, genericImg: valueImg, order: 'CREATE' };
  console.log(payload);

  try {
    // fetchPOST puede devolverte {code, data} o un Response. Cubro ambas rutas:
    const res = await fetchPOST('genericos', payload);

    // 1) Si tu fetchPOST ya devuelve JSON con .code:
    const code = typeof res?.code !== 'undefined' ? Number(res.code) : undefined;

    // 2) Si fetchPOST retorna Response nativo:
    // const code = res instanceof Response ? res.status : Number(res?.code);

    if (code === 200) {
      inpGeneric.value = '';
      showMsg('Guardado.', 'ok');
      liActiveGeneric(res.data, 'list-active-generic');
    } else if (code === 204) {
      // folio no existe
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
  }
});
