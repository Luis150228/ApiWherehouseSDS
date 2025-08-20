// dataupdateGenerics.js
import { fetchGet, fetchPOST } from '../../js/connect.js';
import {
  btnDisplayBlock,
  btnDisplaynone,
  cardsUpdb,
  divLoader,
  divLoaderCreate,
  mostrarTiempo,
  navMenufn,
  popOvers,
} from '../../js/elements.js';
import { openFile } from '../../js/fileReader.js';
import { actionsGenerics, liActiveGeneric } from './generics/activeGeneric.js';

// ---------- Loader inicial ----------
const cadsGroup = document.querySelector('#veiw-secction');
divLoaderCreate();

const activeGenerics = { generics: true, active: true };

// Carga de menús/bases/lista
const dataMenu = await fetchPOST('variablesData', { orden: 'menu' });
const dataBases = await fetchPOST('variablesData', { orden: 'bases' });
const listActiveGeneric = await fetchGet('genericos', activeGenerics);
const dataBaseDates = [dataBases.data[0]];

cardsUpdb(dataBaseDates, 'temp-card', cadsGroup);
liActiveGeneric(listActiveGeneric.data, 'list-active-generic');
navMenufn('nav-bar-primary', dataMenu.data);
divLoader();

// ---------- Refs comunes ----------
const titleTime = document.querySelector('#eut-time');
const frmDatas = document.querySelectorAll('form');
const inpFile = document.querySelectorAll('[type="file"]');
const reloadBtns = document.querySelectorAll('[data-load="true"]');
const linkDb = document.querySelectorAll('.link-db');
// const popData = document.querySelectorAll('[data-bs-toggle="popover"]')
const mnsLoad = document.querySelectorAll('.msj-load');
const mnsAlert = document.querySelectorAll('.msj-alert');
const BarProgressz = document.querySelectorAll('.zone-progressbar');
const btnSumit = document.querySelectorAll('button[type="submit"]');
const pText = document.querySelectorAll('p[class="card-text info-text-color"]');
const btnsAlt = document.querySelectorAll('[data-bs-target="#altUpdate"]');

// ---------- Seguimiento a Genérico (botón + spinner + mensajes) ----------
const btnSave = document.getElementById('save-generic-active');
const inpGeneric = document.getElementById('inc-generic');
const msgBox = document.getElementById('save-generic-msg');

btnSave?.addEventListener('click', async (e) => {
  e.preventDefault();
  if (!inpGeneric || !btnSave) return;

  const value = inpGeneric.value.trim();
  if (!value) {
    showMsg('Captura un folio.', 'warn');
    return;
  }

  // estado busy
  showBtnSpinner(btnSave, 'Guardando…');
  inpGeneric.setAttribute('disabled', 'true');

  const payload = { typeGeneric: 'activate', generic: value, order: 'CREATE' };

  try {
    const res = await fetchPOST('genericos', payload);
    const code = typeof res?.code !== 'undefined' ? Number(res.code) : undefined;

    if (code === 200) {
      inpGeneric.value = '';
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
  }
});

// Helpers de spinner/mensajes para botones de acción
function showBtnSpinner(btn, text = 'Procesando…') {
  if (!btn || btn.dataset.busy === '1') return;
  btn.dataset.busy = '1';
  btn.disabled = true;
  if (!btn.dataset.prevHtml) btn.dataset.prevHtml = btn.innerHTML;
  btn.innerHTML = `<span class="mini-spinner" aria-hidden="true"></span> ${text}`;
}
function hideBtnSpinner(btn) {
  if (!btn) return;
  btn.disabled = false;
  btn.innerHTML = btn.dataset.prevHtml || 'Guardar';
  btn.dataset.busy = '0';
  delete btn.dataset.prevHtml;
}
function showMsg(text, kind = 'ok') {
  if (!msgBox) {
    alert(text);
    return;
  }
  msgBox.textContent = text;
  msgBox.className = `msg ${kind}`;
  clearTimeout(showMsg.tid);
  showMsg.tid = setTimeout(() => {
    msgBox.textContent = '';
    msgBox.className = 'msg';
  }, 2500);
}

// ---------- Acciones lista de genéricos (activar/pausar/borrar) ----------
actionsGenerics();
popOvers();

// ---------- Reloj ----------
setInterval(() => {
  titleTime.innerHTML = mostrarTiempo();
}, 1000);

// ---------- Validación inputs file (tamaño/tipo) ----------
for (const [i, file] of Array.from(inpFile).entries()) {
  const alerta = mnsAlert[i];
  const btn = btnSumit[i];
  file.addEventListener('change', (e) => {
    const f = e.target.files?.[0];
    if (!f) return;
    const typeFile = f.type;
    const sizFile = f.size / 1024 / 1024;
    const typeFiles = [
      'text/csv',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ];

    if (typeFiles.includes(typeFile) && sizFile <= 19) {
      btn.removeAttribute('disabled');
      if (!mnsAlert[i].classList.contains('msj-none')) {
        mnsAlert[i].classList.add('msj-none');
      }
    } else {
      mnsAlert[i].classList.remove('msj-none');
      alerta.innerHTML = `<div class="alert alert-success" role="alert">
        Tipo de documento incorrecto o tamaño excede los 9 MB
      </div>`;
      btn.setAttribute('disabled', true);
    }
  });
}

// ---------- Botón recargar (por card) ----------
for (const [i, reloadBtn] of Array.from(reloadBtns).entries()) {
  reloadBtn.addEventListener('click', async () => {
    await fetchGet('bridge', { reload: true });
    btnSumit[i].style.display = 'block';
    inpFile[i].style.display = 'block';
    inpFile[i].value = '';
    BarProgressz[i].style.display = 'none';
  });
}

// ---------- Submit de cada formulario de carga ----------
for (const [i, frmData] of Array.from(frmDatas).entries()) {
  frmData.addEventListener('submit', async (e) => {
    e.preventDefault();

    // Oculta botones/inputs de todos los forms mientras procesa
    for (const frmDataObj of frmDatas) {
      const inpsFile = frmDataObj.querySelectorAll('input[type="file"]');
      const buttons = frmDataObj.querySelectorAll('button[type="submit"]');
      for (const button of buttons) button.style.display = 'none';
      for (const inpFile of inpsFile) inpFile.style.display = 'none';
    }

    const archivo = e.target[0].files[0];
    const base = e.target.name;
    const tiempo = mostrarTiempo();

    btnDisplaynone(btnSumit);
    btnSumit[i].style.display = 'none';
    mnsLoad[i].classList.toggle('msj-none');

    setTimeout(() => {
      mnsLoad[i].classList.toggle('msj-none');
      btnsAlt[i].classList.toggle('btn');
    }, 15000);

    let data;
    if (base !== 'tablero') {
      data = await openFile(base, archivo, tiempo, BarProgressz[i], mnsAlert[i], mnsLoad[i], btnsAlt[i]);
    }

    // Limpia el bridge al terminar
    await fetchGet(data.data[0].type, { bridge: data.data[0].type });

    // Restaura UI
    for (const frmDataObj of frmDatas) {
      const inpsFile = frmDataObj.querySelectorAll('input[type="file"]');
      const buttons = frmDataObj.querySelectorAll('button[type="submit"]');
      for (const button of buttons) button.style.display = 'block';
      for (const inpFile of inpsFile) inpFile.style.display = 'block';
    }

    pText[i].innerHTML = data.data[0].actualizado == 0 ? 'Sin Cambios' : data.data[0].actualizado;
    mnsLoad[i].classList.toggle('msj-none');
    mnsAlert[i].classList.toggle('msj-none');
    setTimeout(() => {
      mnsAlert[i].classList.toggle('msj-none');
    }, 10000);

    btnDisplayBlock(btnSumit);
    btnSumit[i].style.display = 'block';
    inpFile[i].value = '';
    BarProgressz[i].style.display = 'none';
  });
}

// ---------- Modal alternativa ----------
for (const [i, btnAlt] of Array.from(btnsAlt).entries()) {
  btnAlt.addEventListener('click', (e) => {
    const title = document.querySelector('#title-update-alt');
    const baseCSV = document.querySelector('#recipient-base');
    const linkDataBase = document.querySelector('#link-database');
    const loadModal = document.querySelector('.load-modal');
    const base = e.target.dataset.bsType;

    let nameFile;
    if (base == 'Solicitudes') nameFile = 'sc_task';
    else if (base == 'Incidentes') nameFile = 'incident';

    title.innerHTML = `Actualizacion Alternativa ${base}`;
    baseCSV.value = nameFile;
    btnSumit[i].style.display = 'none';
    inpFile[i].style.display = 'none';

    linkDataBase.addEventListener('click', async () => {
      loadModal.classList.toggle('msj-none');
      linkDataBase.classList.toggle('btn');
      linkDataBase.classList.toggle('msj-none');
      mnsLoad[i].classList.toggle('msj-none');
      btnsAlt[i].disabled = true;

      const fileUp = await fetchGet('ImportSaveFile', { base: base, file: baseCSV.value });

      loadModal.classList.toggle('msj-none');
      linkDataBase.classList.toggle('btn');
      linkDataBase.classList.toggle('msj-none');
      mnsLoad[i].classList.toggle('msj-none');

      pText[i].innerHTML = fileUp.data[0].dbUpdate == 0 ? 'Sin Cambios' : fileUp.data[0].dbUpdate;

      if (fileUp.code == '200') {
        btnsAlt[i].classList.toggle('btn');
        mnsAlert[i].innerHTML = `<div class="alert alert-success" role="alert">${fileUp.mnj}</div>`;
        mnsAlert[i].classList.toggle('msj-none');
        btnSumit[i].style.display = 'block';
        inpFile[i].style.display = 'block';
      } else {
        mnsAlert[i].innerHTML = `<div class="alert alert-danger" role="alert">Falla en importacion contactar a C356882</div>`;
        mnsAlert[i].classList.toggle('msj-none');
      }

      btnsAlt[i].disabled = false;
      setTimeout(() => {
        mnsAlert[i].classList.toggle('msj-none');
      }, 15000);
    });
  });
}

// ---------- Links de BD ----------
for (const link of linkDb) {
  link.addEventListener('click', (e) => {
    const urlLink = e.target.parentElement.dataset.link;
    openInWindow(urlLink);
  });
}
function openInWindow(url) {
  window.open(url, '_blank', 'width=800, height=600');
}

// ======================================================================
// ====================  VISOR DE IMAGEN BASE64  ========================
// ======================================================================
// HTML esperado (opcional):
//  - input#folio-view (folio a consultar)
//  - button#btn-load-img (cargar imagen)
//  - button#btn-clear-img (limpiar)
//  - button#btn-download-img (descargar)
//  - div#b64frame > img#b64img + .placeholder + .b64spinner

const vFolio  = document.getElementById('folio-view');
const vBtnLoad = document.getElementById('btn-load-img');
const vBtnClear = document.getElementById('btn-clear-img');
const vBtnDown = document.getElementById('btn-download-img');
const vFrame = document.getElementById('b64frame');
const vImg = document.getElementById('b64img');
const vPh = vFrame?.querySelector('.placeholder') || null;
const vSpin = vFrame?.querySelector('.b64spinner') || null;

const VIEW_STATE = { current: null }; // { b64, mime, folio }

// UI helpers visor
function viewerSpin(on) {
  if (vSpin) vSpin.hidden = !on;
  if (vBtnLoad) vBtnLoad.disabled = !!on;
}
function toDataUrl(b64, mime) {
  if (!b64) return '';
  if (b64.startsWith('data:')) return b64;
  return `data:${mime || 'image/png'};base64,${b64}`;
}
function renderViewerImage(b64, mime) {
  const dataUrl = toDataUrl(b64, mime);
  if (!dataUrl) {
    if (vImg) { vImg.hidden = true; vImg.removeAttribute('src'); }
    if (vPh) vPh.hidden = false;
    if (vBtnDown) vBtnDown.disabled = true;
    VIEW_STATE.current = null;
    return;
  }
  if (vImg) {
    vImg.src = dataUrl;
    vImg.hidden = false;
  }
  if (vPh) vPh.hidden = true;
  if (vBtnDown) vBtnDown.disabled = false;
  VIEW_STATE.current = { b64, mime, folio: (vFolio?.value || '').trim() };
}
function clearViewer() {
  if (vImg) { vImg.removeAttribute('src'); vImg.hidden = true; }
  if (vPh) vPh.hidden = false;
  if (vBtnDown) vBtnDown.disabled = true;
  VIEW_STATE.current = null;
}
function downloadBase64(b64, mime = 'image/png', filename = 'evidencia.png') {
  const dataUrl = b64.startsWith('data:') ? b64 : toDataUrl(b64, mime);
  const a = document.createElement('a');
  a.href = dataUrl;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
}

// API: obtener imagen por folio (ajusta a tu backend real)
async function fetchImageByFolio(folio) {
  // Endpoint sugerido: 'genericos' con order GET_IMAGE
  return fetchPOST('genericos', { typeGeneric: 'activate', order: 'GET_IMAGE', generic: folio });
}

// Bind eventos visor (si existen elementos)
vBtnLoad?.addEventListener('click', async () => {
  const folio = (vFolio?.value || '').trim();
  if (!folio) { alert('Captura folio.'); return; }

  try {
    viewerSpin(true);
    const resp = await fetchImageByFolio(folio);
    const code = typeof resp?.code !== 'undefined' ? Number(resp.code) : undefined;

    if (code === 200 && resp?.data?.img_b64) {
      renderViewerImage(resp.data.img_b64, resp.data.img_mime || 'image/png');
    } else if (code === 204) {
      clearViewer();
      alert('Sin imagen para este folio.');
    } else {
      clearViewer();
      alert('Respuesta inesperada del servidor.');
    }
  } catch (err) {
    console.error(err);
    clearViewer();
    alert('Error de red/servidor.');
  } finally {
    viewerSpin(false);
  }
});

vBtnClear?.addEventListener('click', () => {
  if (vFolio) vFolio.value = '';
  clearViewer();
});

vBtnDown?.addEventListener('click', () => {
  if (!VIEW_STATE.current) return;
  const name = `Evidencia_${VIEW_STATE.current.folio || 'sin_folio'}.png`;
  downloadBase64(VIEW_STATE.current.b64, VIEW_STATE.current.mime, name);
});
