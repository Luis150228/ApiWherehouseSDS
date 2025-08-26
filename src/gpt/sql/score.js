<html>
  <head>
    <meta charset="utf-8" />
    <script src="https://www.gstatic.com/charts/loader.js"></script>
    <script>
      // Carga Google Charts
      google.charts.load('current', { packages: ['bar'] });
      google.charts.setOnLoadCallback(drawChart);

      // ---- EJEMPLO: tu JSON de backend (pégalo tal cual o reemplázalo por fetch) ----
      const apiResponse = {
        "code": "200",
        "mnj": "Datos Procesados",
        "data": [ /* <-- pega aquí tu array "data" completo tal como lo envías */ 
          {"folio":"INC057672909","incidencia_principal":"INC057666803","creator":"Z945591","analyst_name":null,"total_fields":12,"valid_count":9,"invalid_count":3,"completion_pct":"75.0","asCompleted":"Incompleto","missing_fields":"CORREO, UPN, IP","invalid_fields":""},
          {"folio":"INC057670240","incidencia_principal":"INC057666803","creator":"S789173","analyst_name":null,"total_fields":12,"valid_count":9,"invalid_count":3,"completion_pct":"75.0","asCompleted":"Incompleto","missing_fields":"CORREO, UPN, IP","invalid_fields":""},
          {"folio":"INC057670221","incidencia_principal":"INC057666803","creator":"S020225","analyst_name":null,"total_fields":12,"valid_count":9,"invalid_count":3,"completion_pct":"75.0","asCompleted":"Incompleto","missing_fields":"CORREO, UPN, IP","invalid_fields":""},
          {"folio":"INC057670041","incidencia_principal":"INC057666803","creator":"Z949981","analyst_name":null,"total_fields":12,"valid_count":9,"invalid_count":3,"completion_pct":"75.0","asCompleted":"Incompleto","missing_fields":"CORREO, UPN, IP","invalid_fields":""},
          {"folio":"INC057669995","incidencia_principal":"INC057666803","creator":"Z936829","analyst_name":null,"total_fields":12,"valid_count":9,"invalid_count":3,"completion_pct":"75.0","asCompleted":"Incompleto","missing_fields":"CORREO, UPN, IP","invalid_fields":""},
          {"folio":"INC057669968","incidencia_principal":"INC057666803","creator":"Z946606","analyst_name":null,"total_fields":12,"valid_count":9,"invalid_count":3,"completion_pct":"75.0","asCompleted":"Incompleto","missing_fields":"CORREO, UPN, IP","invalid_fields":""},
          {"folio":"INC057669897","incidencia_principal":"INC057666803","creator":"Z945589","analyst_name":null,"total_fields":12,"valid_count":9,"invalid_count":3,"completion_pct":"75.0","asCompleted":"Incompleto","missing_fields":"CORREO, UPN, IP","invalid_fields":""},
          {"folio":"INC057669886","incidencia_principal":"INC057666803","creator":"Z921067","analyst_name":null,"total_fields":12,"valid_count":9,"invalid_count":3,"completion_pct":"75.0","asCompleted":"Incompleto","missing_fields":"CORREO, UPN, IP","invalid_fields":""},
          {"folio":"INC057034290","incidencia_principal":"INC057033837","creator":"S013914","analyst_name":null,"total_fields":12,"valid_count":5,"invalid_count":7,"completion_pct":"41.7","asCompleted":"Incompleto","missing_fields":"EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO","invalid_fields":""},
          {"folio":"INC057034197","incidencia_principal":"INC057033837","creator":"C243104","analyst_name":null,"total_fields":12,"valid_count":5,"invalid_count":7,"completion_pct":"41.7","asCompleted":"Incompleto","missing_fields":"EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO","invalid_fields":""},
          {"folio":"INC057034138","incidencia_principal":"INC057033837","creator":"S269812","analyst_name":null,"total_fields":12,"valid_count":5,"invalid_count":7,"completion_pct":"41.7","asCompleted":"Incompleto","missing_fields":"EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO","invalid_fields":""},
          {"folio":"INC057034040","incidencia_principal":"INC057033837","creator":"S768600","analyst_name":null,"total_fields":12,"valid_count":5,"invalid_count":7,"completion_pct":"41.7","asCompleted":"Incompleto","missing_fields":"EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO","invalid_fields":""},
          {"folio":"INC057034023","incidencia_principal":"INC057033837","creator":"S273777","analyst_name":null,"total_fields":12,"valid_count":5,"invalid_count":7,"completion_pct":"41.7","asCompleted":"Incompleto","missing_fields":"EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO","invalid_fields":""},
          {"folio":"INC057033837","incidencia_principal":"INC057033837","creator":"S029277","analyst_name":null,"total_fields":12,"valid_count":5,"invalid_count":7,"completion_pct":"41.7","asCompleted":"Incompleto","missing_fields":"EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO","invalid_fields":""},
          {"folio":"","incidencia_principal":"INC057033837","creator":"","analyst_name":null,"total_fields":12,"valid_count":5,"invalid_count":7,"completion_pct":"41.7","asCompleted":"Incompleto","missing_fields":"EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO","invalid_fields":""}
        ]
      };

      // ---- Función independiente: convierte tu JSON a la tabla para Google Charts ----
      const toGoogleBarTable = (json) => {
        const rows = Array.isArray(json?.data) ? json.data : [];

        // 1) Agrupar por analyst_name (normalizando null/vacío)
        const normalize = (v) => {
          const s = (v ?? '').toString().trim();
          return s.length ? s : 'Sin analista';
        };

        const grouped = new Map();
        for (const r of rows) {
          const key = normalize(r.analyst_name);
          if (!grouped.has(key)) {
            grouped.set(key, { total_fields: 0, valid_count: 0, invalid_count: 0 });
          }
          const g = grouped.get(key);
          g.total_fields += Number(r.total_fields) || 0;
          g.valid_count += Number(r.valid_count) || 0;
          g.invalid_count += Number(r.invalid_count) || 0;
        }

        // 2) Construir el arreglo para arrayToDataTable
        const table = [
          ['Analyst', 'Sales', 'Expenses', 'Profit'] // encabezados requeridos
        ];

        for (const [name, v] of grouped.entries()) {
          table.push([name, v.total_fields, v.valid_count, v.invalid_count]);
        }

        // (Opcional) Ordenar por Sales desc
        table.splice(1, table.length - 1, ...table.slice(1).sort((a, b) => b[1] - a[1]));

        return table;
      };

      // ---- Dibujo del chart usando la función anterior ----
      function drawChart() {
        // Si en producción lo traes por fetch, sería:
        // fetch('/tu/endpoint').then(r => r.json()).then(json => { ... });
        const dataArray = toGoogleBarTable(apiResponse);
        const data = google.visualization.arrayToDataTable(dataArray);

        const options = {
          chart: {
            title: 'Calidad por analista',
            subtitle: 'Sales=total_fields, Expenses=valid_count, Profit=invalid_count'
          }
        };

        const chart = new google.charts.Bar(
          document.getElementById('columnchart_material')
        );

        chart.draw(data, google.charts.Bar.convertOptions(options));
      }
    </script>
  </head>
  <body>
    <div id="columnchart_material" style="width: 800px; height: 500px;"></div>
  </body>
</html>
