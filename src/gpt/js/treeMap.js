// Asegúrate de exportar así:
export function renderTreemap(containerId, rows, DEFAULT_KEYS, opts = {}) {
  const { dateField, onSelectIncident } = opts;
  const el = document.getElementById(containerId);
  if (!el) return;

  // 1) Construye DataTable con el INCIDENTE en la **columna 0**
  //    (ajusta si tu layout es distinto)
  const data = new google.visualization.DataTable();
  data.addColumn('string', 'ID');      // incidente padre / nodo
  data.addColumn('string', 'Parent');  // padre (o null para raíz)
  data.addColumn('number', 'Size');    // tamaño
  data.addColumn('number', 'Color');   // color

  // TODO: llena 'data' con tus rows; importante:
  //  - en col 0 mete r.incidencia_principal (o el ID que uses para filtrar)
  //  - en col 1 el parent (o null/'')
  //  - col 2 y 3 tus métricas

  // 2) Reusar una sola instancia si quieres (opcional)
  const chart = new google.visualization.TreeMap(el);

  // Limpia listeners viejos para evitar duplicados en cada draw
  google.visualization.events.removeAllListeners(chart);

  // 3) Click -> onSelectIncident(incidentID)
  google.visualization.events.addListener(chart, 'select', () => {
    const sel = chart.getSelection()[0];
    if (!sel) return;
    const rowIndex = sel.row;
    // OJO: Columna 0 debe ser tu "incidente id"
    const incidentId = data.getValue(rowIndex, 0);
    onSelectIncident?.(incidentId);
  });

  // 4) Dibuja
  chart.draw(data, {
    // ...tus opciones
    minColor: '#f5f5f5',
    midColor: '#bdbdbd',
    maxColor: '#616161',
    headerHeight: 15,
    fontColor: 'black',
    showScale: true
  });
}