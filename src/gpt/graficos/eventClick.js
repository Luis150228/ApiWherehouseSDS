// --- saber qué nodo se clickeó y, si es 1er nivel, obtener el incidente ---
google.visualization.events.addListener(tree, 'select', () => {
  const sel = tree.getSelection();
  if (!sel.length) return;

  const row = sel[0].row;
  if (row == null) return;

  const idPath = data.getValue(row, 0) || '';    // ej: "Tickets│INC057414910│METRO SUR│2025-08-12│16"
  const parent = data.getValue(row, 1);          // ej: "Tickets│INC057414910" (o "Tickets" en 1er nivel)
  const parts  = idPath.split('│').slice(1);     // sin "Tickets"
  const incident = parts[0] || '';               // INCxxxxx si es 1er nivel

  // ¿es 1er nivel? -> la ruta sólo tiene 1 segmento tras "Tickets"
  const isFirstLevel = parts.length === 1;

  console.log({ idPath, parent, incident, isFirstLevel });

  // Si quieres notificar a tu app:
  const container = document.getElementById('chart_generics'); // o el containerId que uses
  container?.dispatchEvent(new CustomEvent('treemap:select', {
    detail: { row, idPath, parent, incident, isFirstLevel }
  }));
});

document.getElementById('chart_generics')?.addEventListener('treemap:select', (e) => {
  const { incident, isFirstLevel } = e.detail;
  if (isFirstLevel) {
    console.log('Click en incidente de 1er nivel:', incident);
    // aquí haces lo que necesites (filtrar, abrir reporte, etc.)
  }
});
