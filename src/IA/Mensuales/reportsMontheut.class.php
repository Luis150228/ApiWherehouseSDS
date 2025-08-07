<?php
ini_set('max_execution_time', 1800);
require_once "../conexion/cnx.php";
require '../vendor/autoload.php';

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Alignment;

class valores extends cnx
{
    public function eut_weeklyrange($token, $reporte)
    {
        $data = $this->rangoSemanal($token, $reporte);

        return $data;
    }

    public function eut_monthReports($token, $reporte)
    {
        $id = date('Y') . str_pad(date('n', strtotime('-1 month')), 2, '0', STR_PAD_LEFT);
        $semana = date('Y') . '-' . str_pad(date('n', strtotime('-1 month')), 2, '0', STR_PAD_LEFT);
        $month = date('n', strtotime('-1 month'));
        $numMonth = date('n', strtotime('-1 month'));
        $data = $this->genarateMensualReports($token, $id, $semana, $numMonth, $month);

        return $data;
    }

    public function createReports($token, $destino, $destinoMes, $id)
    {
        $reportes = array('CAU_INC', 'CAU_INCK', 'CAU_SOL', 'SDK_INC', 'SDK_INCK', 'SDK_SOL');
        foreach ($reportes as $reporte) {
            $data = $this->createReportSDKCAU($reporte, $destino, $destinoMes, $id);
        }
        return $data;
    }


    private function genarateMensualReports($tk, $id, $range, $numMonth, $month)
    {
        $targetWeek = $id . ' ' . $range;
        $targetMonth = $numMonth . ' ' . $month;
        $data = $this->createReports($tk, $targetWeek, $targetMonth, $id);
        return $data;
    }

    private function createReportSDKCAU($r, $destino, $destinoMes, $id)
    {
        $sql = "CALL stp_mensualesDetalle('$r', '$id')";
        // print_r($sql);
        $query = parent::getData($sql);
        // /*
        if (empty($query)) {
            $result = array(
                "code" => "202",
                "mnj" => "Reporte sin data",
                "data" => "",
            );

            return $result;
        } else {
            $data = $this->saveReportSDKCAU($query, $r, $destino, $destinoMes);
            return $data;
        }
        // */
    }


    private function saveReportSDKCAU($data, $namefile, $targetW, $targetM)
    {
        $semanal = $data[0]['SEMANAL'];

        if ($namefile == 'CAU_INC') {
            $fileName = 'CAU Reporte Incidentes';
        } elseif ($namefile == 'CAU_INCK') {
            $fileName = 'CAU Reporte Incidentes KS';
        } elseif ($namefile == 'CAU_SOL') {
            $fileName = 'CAU Reporte Solicitudes';
        } elseif ($namefile == 'SDK_INC') {
            $fileName = 'SDK Reporte Incidentes';
        } elseif ($namefile == 'SDK_INCK') {
            $fileName = 'SDK Reporte Incidentes KS';
        } elseif ($namefile == 'SDK_SOL') {
            $fileName = 'SDK Reporte Solicitudes';
        }

        $saveFile = $fileName . ' ' . $semanal;
        // $targetFile = '../xlsx/weeklyReports/' . $targetW . '/';
        // if (!file_exists($targetFile)) {
        //     mkdir($targetFile);
        // }
        $anhio = date('Y');
        $targetFile = 'D://Reporteria/03 Mensuales/' . $anhio . '/' . $targetM . '/' . $targetW . '/';
        // $targetFile = 'R://02 Semanales/SDKCAU/' . $anhio . '/' . $targetM . '/' . $targetW . '/';
        if (!is_dir($targetFile)) {
            mkdir($targetFile, 0777, true);
        }

        /**/
        $filePath = $targetFile . $saveFile . '.xlsx';
        if (!file_exists($filePath)) {
            $spreadsheet = new Spreadsheet();
            $sheet = $spreadsheet->getActiveSheet();
            $sheet->setTitle($namefile);

            // Obtener las claves del primer registro para generar las columnas
            $firstRecord = reset($data);
            $columns = array_keys($firstRecord);

            // Establecer estilos para los encabezados (títulos)
            $headerStyle = [
                'font' => ['bold' => true, 'color' => ['rgb' => 'FF0000']],
                'alignment' => ['horizontal' => \PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER],
            ];
            $sheet->getStyle('A1:' . \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex(count($columns)) . '1')->applyFromArray($headerStyle);

            // Fijar la primera fila (encabezados) para que esté siempre visible mientras se desplaza por la hoja
            $sheet->freezePane('A2');

            // Activar autofiltro en la primera fila (encabezados)
            $sheet->setAutoFilter('A1:' . \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex(count($columns)) . '1');
            // Escribir los encabezados de las columnas en la primera fila de la hoja
            $columnIndex = 1;
            foreach ($columns as $column) {
                $cellCoordinate = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($columnIndex) . '1';
                $sheet->setCellValue($cellCoordinate, $column);
                // $sheet->getColumnDimension(\PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($columnIndex))->setAutoSize(true);
                $columnIndex++;
            }

            $sheet->getColumnDimension('A:B')->setWidth(13);
            $sheet->getColumnDimension('C:D')->setWidth(13);
            $sheet->getColumnDimension('I:J')->setWidth(22);
            $sheet->getColumnDimension('F')->setWidth(20);
            $sheet->getColumnDimension('G')->setWidth(20);
            $sheet->getColumnDimension('H')->setWidth(20);
            $sheet->getColumnDimension('K')->setWidth(20);
            $sheet->getColumnDimension('M')->setWidth(18);
            $sheet->getColumnDimension('Q')->setWidth(18);

            $rowIndex = 2; // Comenzar a partir de la segunda fila, ya que la primera fila contiene los encabezados
            foreach ($data as $record) {
                $columnIndex = 1;
                foreach ($record as $value) {
                    $cellCoordinate = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($columnIndex) . $rowIndex;
                    $sheet->setCellValue($cellCoordinate, $value);
                    $statusCell = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex(array_search('Estatus', $columns) + 1) . $rowIndex;

                    // Ajustar el ancho y alto del contenido
                    // $sheet->getColumnDimension(\PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($columnIndex))->setAutoSize(true);
                    $sheet->getRowDimension($rowIndex)->setRowHeight(16);

                    $range = 'A' . $rowIndex . ':' . \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex(count($record)) . $rowIndex;
                    $sheet->getStyle($range)->getFont()->setName('Verdana');
                    $sheet->getStyle($range)->getFont()->setSize(8);

                    // Aplicar formato a toda la fila cuando el campo "Estatus" sea "VENCIDO" (Color de fuente rojo)
                    if ($sheet->getCell($statusCell)->getValue() === 'VENCIDO') {
                        // Aplicar formato de fuente roja a toda la fila desde la columna A hasta la última columna
                        $range = 'A' . $rowIndex . ':' . \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex(count($record)) . $rowIndex;
                        $sheet->getStyle($range)->getFont()->getColor()->setRGB('FF0000');
                    }
                    $columnIndex++;
                }
                $rowIndex++;
            }

            $writer = new Xlsx($spreadsheet);
            $writer->save($filePath);
            $filesWeekReports = scandir($targetFile);
            $filesWeekReports = array_diff($filesWeekReports, array('.', '..'));
            $arrFilesWeek = array_values($filesWeekReports);

            if (file_exists($filePath)) {
                $fileCreationTime = filectime($filePath);
                if ($fileCreationTime > 0) {
                    $formattedCreationTime = date('Y-m-d H:i:s', $fileCreationTime);
                    $response = array(
                        'code' => "200",
                        'mnj' => 'Los archivos se ha generado y guardado correctamente.',
                        'status' => 'success',
                        'week' => $targetW,
                        'targetFiles' => $targetFile,
                        'files' => $arrFilesWeek,
                        'creation_time' => $formattedCreationTime
                    );
                } else {
                    $response = array(
                        "code" => "204",
                        "mnj" => "Hubo un problema al generar y guardar los archivos.",
                        'status' => 'error'
                    );
                }
            } else {
                $response = array(
                    "code" => "204",
                    "mnj" => "Los archivos no se pudieron guardar en la ubicación especificada.",
                    'status' => 'error'
                );
            }
        }

        $filesWeekReports = scandir($targetFile);
        $filesWeekReports = array_diff($filesWeekReports, array('.', '..'));
        $arrFilesWeek = array_values($filesWeekReports);

        if (file_exists($filePath)) {
            $fileCreationTime = filectime($filePath);
            if ($fileCreationTime > 0) {
                $formattedCreationTime = date('Y-m-d H:i:s', $fileCreationTime);
                $response = array(
                    "code" => "200",
                    'mnj' => 'Los archivos se ha generado y guardado correctamente. Originales.',
                    'status' => 'success',
                    'week' => $targetW,
                    'targetFiles' => $targetFile,
                    'files' => $arrFilesWeek,
                    'creation_time' => $formattedCreationTime
                );
            } else {
                $response = array(
                    "code" => "204",
                    "mnj" => "Hubo un problema al generar y guardar los archivos.",
                    'status' => 'error'
                );
            }
        } else {
            $response = array(
                "code" => "204",
                "mnj" => "Los archivos no se pudieron guardar en la ubicación especificada.",
                'status' => 'error'
            );
        }

        return $response;
        /**/
    }
    /*********************************************************************************************************************************************************** */
    private function saveReportRVSS($data, $targetW, $targetM)
    {
        $semanal = $data[0]['SEMANAL'];

        $incidentesCAU = array_filter($data, function ($item) {
            return $item['type'] === 'RVVS_INC_CAU';
        });

        $incidentesSDK = array_filter($data, function ($item) {
            return $item['type'] === 'RVVS_INC_SDK';
        });

        $solicitudesCAU = array_filter($data, function ($item) {
            return $item['type'] === 'RVVS_SOL_CAU';
        });

        $solicitudesSDK = array_filter($data, function ($item) {
            return $item['type'] === 'RVVS_SOL_SDK';
        });

        $totalIncidentes = count($incidentesCAU) + count($incidentesSDK);
        $totalSolicitudes = count($solicitudesCAU) + count($solicitudesSDK);

        $resumen = array(
            "IncidentesSDK" => count($incidentesSDK),
            "prcIncSDK" => number_format((count($incidentesSDK) / $totalIncidentes) * 100, 2),
            "IncidentesCAU" => count($incidentesCAU),
            "prcIncCAU" => number_format((count($incidentesCAU) / $totalIncidentes) * 100, 2),
            "TotalIncidentes" => $totalIncidentes,
            "SolicitudesSDK" => count($solicitudesSDK),
            "SolicitudesCAU" => count($solicitudesCAU),
            "prcSolSDK" => number_format((count($solicitudesSDK) / $totalSolicitudes) * 100, 2),
            "prcSolCAU" => number_format((count($solicitudesCAU) / $totalSolicitudes) * 100, 2),
            "TotalSolicitudes" => $totalSolicitudes,
            "Semana" => $semanal,
        );

        $anhio = date('Y');

        // $targetFile = '../xlsx/weeklyReports/' . $targetW . '/';
        // $saveFile = 'Remoto vs Sitio ' . $semanal;
        // if (!file_exists($targetFile)) {
        //     mkdir($targetFile);
        // }
        // $targetFile = 'R://02 Semanales/SDKCAU/' . $anhio . '/' . $targetM . '/' . $targetW . '/';
        $targetFile = 'D://Reporteria/02 Semanales/SDKCAU/' . $anhio . '/' . $targetM . '/' . $targetW . '/';
        $saveFile = 'Remoto vs Sitio ' . $semanal;
        if (!is_dir($targetFile)) {
            mkdir($targetFile, 0777, true);
        }

        $filePath = $targetFile . $saveFile . '.xlsx';

        if (!file_exists($filePath)) {
            $spreadsheet = new Spreadsheet();
            $sheet1 = $spreadsheet->getActiveSheet();
            $sheet1->setTitle('Incidentes');
            $sheet2 = $spreadsheet->createSheet();
            $sheet2->setTitle('Solicitudes');
            $activeSheet = $spreadsheet->setActiveSheetIndex(0);
            $activeSheet->setShowGridlines(false);

            $activeSheet->setCellValue('A1', "Cumplimiento de Incidentes Atendidos Via Remota vs Sitio");
            $activeSheet->setCellValue('A2', "Consulta del periodo " . date('Y') . " del " . $resumen['Semana']);
            $activeSheet->getStyle('A1:A2')->getFont()->setBold(true);

            $activeSheet->setCellValue('A4', 'Estatus');
            $activeSheet->setCellValue('B4', 'Folios');
            $activeSheet->setCellValue('C4', '% Meta');
            $activeSheet->setCellValue('D4', '% Alcance');
            $headerStyle = $activeSheet->getStyle('A4:D4');
            $headerStyle->getFont()->setBold(true);
            $headerStyle->getFont()->getColor()->setRGB('FF0000');

            $activeSheet->setCellValue('A5', 'Via Remota');
            $activeSheet->setCellValue('A6', 'En Sitio');
            $activeSheet->setCellValue('A7', 'Total General');
            $resumenStyle = $activeSheet->getStyle('A5:A7');
            $resumenStyle->getFont()->getColor()->setRGB('FFFFFF');
            $resumenStyle->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
            $resumenStyle = $activeSheet->getStyle('A5:D7');
            $resumenStyle->getFont()->setBold(true);
            $resumenStyle->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $resumenStyle->getAlignment()->setVertical(Alignment::VERTICAL_CENTER);

            $activeSheet->setCellValue('B5', $resumen['IncidentesSDK']);
            $activeSheet->setCellValue('C5', 'Mayor 80.00');
            $activeSheet->setCellValue('D5', $resumen['prcIncSDK']);

            $activeSheet->setCellValue('B6', $resumen['IncidentesCAU']);
            $activeSheet->setCellValue('C6', 'Menor 20.00');
            $activeSheet->setCellValue('D6', $resumen['prcIncCAU']);

            $activeSheet->setCellValue('B7', $resumen['TotalIncidentes']);

            // Fila de inicio
            $row = 9;
            $activeSheet->setCellValue('A' . $row, 'Remoto');
            $subtitleStyle = $activeSheet->getStyle('A' . $row);
            $subtitleStyle->getFont()->getColor()->setRGB('FFFFFF');
            $subtitleStyle->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
            $row++;

            // Agregar los encabezados a la primera tabla
            $activeSheet->setCellValue('A' . $row, 'Ticket');
            $activeSheet->setCellValue('B' . $row, 'ID Externo');
            $activeSheet->setCellValue('C' . $row, 'Fecha Envio');
            $activeSheet->setCellValue('D' . $row, 'Fecha Cierre');
            $activeSheet->setCellValue('E' . $row, 'Tiempo');
            $activeSheet->setCellValue('F' . $row, 'Nivel 1');
            $activeSheet->setCellValue('G' . $row, 'Nivel 2');
            $activeSheet->setCellValue('H' . $row, 'Nivel 3');
            $activeSheet->setCellValue('I' . $row, 'Grupo Asignado');
            $activeSheet->setCellValue('J' . $row, 'Resuelto');
            $activeSheet->setCellValue('K' . $row, 'Estatus');

            // Aplicar formato a la fila de encabezados
            $headerStyle = $activeSheet->getStyle('A' . $row . ':K' . $row);
            $headerStyle->getFont()->setBold(true);
            $headerStyle->getFont()->getColor()->setRGB('FF0000');
            // Ajustar el ancho de la columna A al ancho de 95px
            $activeSheet->getColumnDimension('A')->setWidth(13);
            $activeSheet->getColumnDimension('I')->setWidth(24);

            // Llenar la primera tabla con los datos de Incidentes SDK
            $row++;
            foreach ($incidentesSDK as $item) {
                $activeSheet->setCellValue('A' . $row, $item['ticket']);
                $activeSheet->setCellValue('B' . $row, $item['id_externo']);
                $activeSheet->setCellValue('C' . $row, $item['fecha_envio']);
                $activeSheet->setCellValue('D' . $row, $item['fecha_cierre']);
                $activeSheet->setCellValue('E' . $row, $item['time']);
                $activeSheet->setCellValue('F' . $row, $item['nivel1']);
                $activeSheet->setCellValue('G' . $row, $item['nivel2']);
                $activeSheet->setCellValue('H' . $row, $item['nivel3']);
                $activeSheet->setCellValue('I' . $row, $item['grupo_asignado']);
                $activeSheet->setCellValue('J' . $row, $item['resuelto']);
                $activeSheet->setCellValue('K' . $row, $item['estatus']);
                $row++;
            }

            // Dejar una fila de espacio
            $row++;
            $activeSheet->setCellValue('A' . $row, 'Sitio');
            $subtitleStyle = $activeSheet->getStyle('A' . $row);
            $subtitleStyle->getFont()->getColor()->setRGB('FFFFFF');
            $subtitleStyle->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
            $row++;

            // Agregar los encabezados a la segunda tabla
            $activeSheet->setCellValue('A' . $row, 'Ticket');
            $activeSheet->setCellValue('B' . $row, 'ID Externo');
            $activeSheet->setCellValue('C' . $row, 'Fecha Envio');
            $activeSheet->setCellValue('D' . $row, 'Fecha Cierre');
            $activeSheet->setCellValue('E' . $row, 'Tiempo');
            $activeSheet->setCellValue('F' . $row, 'Nivel 1');
            $activeSheet->setCellValue('G' . $row, 'Nivel 2');
            $activeSheet->setCellValue('H' . $row, 'Nivel 3');
            $activeSheet->setCellValue('I' . $row, 'Grupo Asignado');
            $activeSheet->setCellValue('J' . $row, 'Resuelto');
            $activeSheet->setCellValue('K' . $row, 'Estatus');
            // Agregar más encabezados aquí
            // Aplicar formato a la fila de encabezados
            $headerStyle = $activeSheet->getStyle('A' . $row . ':K' . $row);
            $headerStyle->getFont()->setBold(true);
            $headerStyle->getFont()->getColor()->setRGB('FF0000');

            // Llenar la segunda tabla con los datos de Incidentes CAU
            $row++;
            foreach ($incidentesCAU as $item) {
                $activeSheet->setCellValue('A' . $row, $item['ticket']);
                $activeSheet->setCellValue('B' . $row, $item['id_externo']);
                $activeSheet->setCellValue('C' . $row, $item['fecha_envio']);
                $activeSheet->setCellValue('D' . $row, $item['fecha_cierre']);
                $activeSheet->setCellValue('E' . $row, $item['time']);
                $activeSheet->setCellValue('F' . $row, $item['nivel1']);
                $activeSheet->setCellValue('G' . $row, $item['nivel2']);
                $activeSheet->setCellValue('H' . $row, $item['nivel3']);
                $activeSheet->setCellValue('I' . $row, $item['grupo_asignado']);
                $activeSheet->setCellValue('J' . $row, $item['resuelto']);
                $activeSheet->setCellValue('K' . $row, $item['estatus']);
                $row++;
            }

            // Ajustar el ancho de las columnas al contenido
            $activeSheet->getColumnDimension('B')->setAutoSize(true);
            $activeSheet->getColumnDimension('C')->setAutoSize(true);
            $activeSheet->getColumnDimension('D')->setAutoSize(true);


            /*********************HOJA DE SOLICITUDES******************************************************** */
            $activeSheet = $spreadsheet->setActiveSheetIndex(1);
            $activeSheet->setShowGridlines(false);

            $activeSheet->setCellValue('A1', "Cumplimiento de Solicitudes Atendidos Via Remota vs Sitio");
            $activeSheet->setCellValue('A2', "Consulta del periodo " . date('Y') . " del " . $resumen['Semana']);
            $activeSheet->getStyle('A1:A2')->getFont()->setBold(true);


            $activeSheet->setCellValue('A4', 'Estatus');
            $activeSheet->setCellValue('B4', 'Folios');
            $activeSheet->setCellValue('C4', '% Meta');
            $activeSheet->setCellValue('D4', '% Alcance');
            $headerStyle = $activeSheet->getStyle('A4:D4');
            $headerStyle->getFont()->setBold(true);
            $headerStyle->getFont()->getColor()->setRGB('FF0000');

            $activeSheet->setCellValue('A5', 'Via Remota');
            $activeSheet->setCellValue('A6', 'En Sitio');
            $activeSheet->setCellValue('A7', 'Total General');
            $resumenStyle = $activeSheet->getStyle('A5:A7');
            $resumenStyle->getFont()->getColor()->setRGB('FFFFFF');
            $resumenStyle->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
            $resumenStyle = $activeSheet->getStyle('A5:D7');
            $resumenStyle->getFont()->setBold(true);
            $resumenStyle->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $resumenStyle->getAlignment()->setVertical(Alignment::VERTICAL_CENTER);

            $activeSheet->setCellValue('A5', 'Via Remota');
            $activeSheet->setCellValue('B5', $resumen['SolicitudesSDK']);
            $activeSheet->setCellValue('C5', 'Mayor 80.00');
            $activeSheet->setCellValue('D5', $resumen['prcSolSDK']);

            $activeSheet->setCellValue('A6', 'En Sitio');
            $activeSheet->setCellValue('B6', $resumen['SolicitudesCAU']);
            $activeSheet->setCellValue('C6', 'Menor 20.00');
            $activeSheet->setCellValue('D6', $resumen['prcSolCAU']);

            $activeSheet->setCellValue('A7', 'Total General');
            $activeSheet->setCellValue('B7', $resumen['TotalSolicitudes']);

            // Fila de inicio
            $row = 9;
            $activeSheet->setCellValue('A' . $row, 'Remoto');
            $subtitleStyle = $activeSheet->getStyle('A' . $row);
            $subtitleStyle->getFont()->getColor()->setRGB('FFFFFF');
            $subtitleStyle->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
            $row++;

            // Agregar los encabezados a la primera tabla
            $activeSheet->setCellValue('A' . $row, 'Ticket');
            $activeSheet->setCellValue('B' . $row, 'ID Externo');
            $activeSheet->setCellValue('C' . $row, 'Fecha Envio');
            $activeSheet->setCellValue('D' . $row, 'Fecha Cierre');
            $activeSheet->setCellValue('E' . $row, 'Tiempo');
            $activeSheet->setCellValue('F' . $row, 'Nivel 1');
            $activeSheet->setCellValue('G' . $row, 'Nivel 2');
            $activeSheet->setCellValue('H' . $row, 'Nivel 3');
            $activeSheet->setCellValue('I' . $row, 'Grupo Asignado');
            $activeSheet->setCellValue('J' . $row, 'Resuelto');
            $activeSheet->setCellValue('K' . $row, 'Estatus');

            // Aplicar formato a la fila de encabezados
            $headerStyle = $activeSheet->getStyle('A' . $row . ':K' . $row);
            $headerStyle->getFont()->setBold(true);
            $headerStyle->getFont()->getColor()->setRGB('FF0000');
            // Ajustar el ancho de la columna A al ancho de 95px
            $activeSheet->getColumnDimension('A')->setWidth(13);
            $activeSheet->getColumnDimension('I')->setWidth(24);

            // Llenar la primera tabla con los datos de Incidentes SDK
            $row++;
            foreach ($solicitudesSDK as $item) {
                $activeSheet->setCellValue('A' . $row, $item['ticket']);
                $activeSheet->setCellValue('B' . $row, $item['id_externo']);
                $activeSheet->setCellValue('C' . $row, $item['fecha_envio']);
                $activeSheet->setCellValue('D' . $row, $item['fecha_cierre']);
                $activeSheet->setCellValue('E' . $row, $item['time']);
                $activeSheet->setCellValue('F' . $row, $item['nivel1']);
                $activeSheet->setCellValue('G' . $row, $item['nivel2']);
                $activeSheet->setCellValue('H' . $row, $item['nivel3']);
                $activeSheet->setCellValue('I' . $row, $item['grupo_asignado']);
                $activeSheet->setCellValue('J' . $row, $item['resuelto']);
                $activeSheet->setCellValue('K' . $row, $item['estatus']);
                $row++;
            }

            // Dejar una fila de espacio
            $row++;
            $activeSheet->setCellValue('A' . $row, 'Sitio');
            $subtitleStyle = $activeSheet->getStyle('A' . $row);
            $subtitleStyle->getFont()->getColor()->setRGB('FFFFFF');
            $subtitleStyle->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
            $row++;

            // Agregar los encabezados a la segunda tabla
            $activeSheet->setCellValue('A' . $row, 'Ticket');
            $activeSheet->setCellValue('B' . $row, 'ID Externo');
            $activeSheet->setCellValue('C' . $row, 'Fecha Envio');
            $activeSheet->setCellValue('D' . $row, 'Fecha Cierre');
            $activeSheet->setCellValue('E' . $row, 'Tiempo');
            $activeSheet->setCellValue('F' . $row, 'Nivel 1');
            $activeSheet->setCellValue('G' . $row, 'Nivel 2');
            $activeSheet->setCellValue('H' . $row, 'Nivel 3');
            $activeSheet->setCellValue('I' . $row, 'Grupo Asignado');
            $activeSheet->setCellValue('J' . $row, 'Resuelto');
            $activeSheet->setCellValue('K' . $row, 'Estatus');
            // Agregar más encabezados aquí
            // Aplicar formato a la fila de encabezados
            $headerStyle = $activeSheet->getStyle('A' . $row . ':K' . $row);
            $headerStyle->getFont()->setBold(true);
            $headerStyle->getFont()->getColor()->setRGB('FF0000');

            // Llenar la segunda tabla con los datos de Incidentes CAU
            $row++;
            foreach ($solicitudesCAU as $item) {
                $activeSheet->setCellValue('A' . $row, $item['ticket']);
                $activeSheet->setCellValue('B' . $row, $item['id_externo']);
                $activeSheet->setCellValue('C' . $row, $item['fecha_envio']);
                $activeSheet->setCellValue('D' . $row, $item['fecha_cierre']);
                $activeSheet->setCellValue('E' . $row, $item['time']);
                $activeSheet->setCellValue('F' . $row, $item['nivel1']);
                $activeSheet->setCellValue('G' . $row, $item['nivel2']);
                $activeSheet->setCellValue('H' . $row, $item['nivel3']);
                $activeSheet->setCellValue('I' . $row, $item['grupo_asignado']);
                $activeSheet->setCellValue('J' . $row, $item['resuelto']);
                $activeSheet->setCellValue('K' . $row, $item['estatus']);
                $row++;
            }

            // Ajustar el ancho de las columnas al contenido
            $activeSheet->getColumnDimension('B')->setAutoSize(true);
            $activeSheet->getColumnDimension('C')->setAutoSize(true);
            $activeSheet->getColumnDimension('D')->setAutoSize(true);


            // Guardar el archivo
            $activeSheet = $spreadsheet->setActiveSheetIndex(0);
            $activeSheet->getStyle('A1');
            $writer = new Xlsx($spreadsheet);
            $writer->save($filePath);

            if (file_exists($filePath)) {
                $fileCreationTime = filectime($filePath);
                if ($fileCreationTime > 0) {
                    $formattedCreationTime = date('Y-m-d H:i:s', $fileCreationTime);
                    $response = array(
                        "code" => "200",
                        'mnj' => 'Los archivos semanales se ha generado y guardado correctamente.',
                        'status' => 'success',
                        'week' => $targetW,
                        'file_url' => $filePath,
                        'creation_time' => $formattedCreationTime,
                        'resume' => $resumen,
                    );
                } else {
                    $response = array(
                        "code" => "204",
                        "mnj" => "Hubo un problema al generar y guardar los archivos.",
                        'status' => 'error'
                    );
                }
            } else {
                $response = array(
                    "code" => "204",
                    "mnj" => "Los archivos no se pudieron guardar en la ubicación especificada.",
                    'status' => 'error'
                );
            }
        }

        if (file_exists($filePath)) {
            $fileCreationTime = filectime($filePath);
            if ($fileCreationTime > 0) {
                $formattedCreationTime = date('Y-m-d H:i:s', $fileCreationTime);
                $response = array(
                    "code" => "200",
                    'mnj' => 'Los archivos semanales ya habian sido procesados.',
                    'status' => 'success',
                    'week' => $targetW,
                    'file_url' => $filePath,
                    'creation_time' => $formattedCreationTime,
                    'resume' => $resumen,
                );
            } else {
                $response = array(
                    "code" => "204",
                    "mnj" => "Hubo un problema al generar y guardar los archivos.",
                    'status' => 'error'
                );
            }
        } else {
            $response = array(
                "code" => "204",
                "mnj" => "Los archivos no se pudieron guardar en la ubicación especificada.",
                'status' => 'error'
            );
        }


        /**Respuesta para el cliente */


        return $response;
    }
    /*********************************************************************************************************************************************************** */
    private function saveReportUnlocks($data, $targetW, $targetM)
    {
        $semanal = $data[0]['SEMANA'];

        $desbloqueos = array_filter($data, function ($item) {
            return $item['REPORTE'] === 'unlocks';
        });

        $totalMin = 0;
        $totalEnTiempo = 0;
        $totalVencido = 0;
        foreach ($data as $llamada) {
            $totalMin += (int) $llamada['minutos'];

            if ($llamada['cumplimiento'] === "En Tiempo") {
                $totalEnTiempo++;
            } else {
                $totalVencido++;
            }
        }

        $resumen = array(
            "totalDesvloqueos" => count($desbloqueos),
            "tiempoProm" => number_format(($totalMin / count($desbloqueos)), 0),
            "prccumplimiento" => number_format(($totalEnTiempo / count($desbloqueos)) * 100, 2),
            "Semana" => $semanal,
            "target" => $targetW
        );

        $anhio = date('Y');
        // /*

        // $targetFile = 'R://02 Semanales/SDKCAU/' . $anhio . '/' . $targetM . '/' . $targetW . '/';
        $targetFile = 'D://Reporteria/02 Semanales/SDKCAU/' . $anhio . '/' . $targetM . '/' . $targetW . '/';
        $saveFile = 'Desbloqueos ' . $semanal;
        if (!is_dir($targetFile)) {
            mkdir($targetFile, 0777, true);
        }

        $filePath = $targetFile . $saveFile . '.xlsx';
        if (!file_exists($filePath)) {
            $spreadsheet = new Spreadsheet();
            $activeSheet = $spreadsheet->getActiveSheet();
            $activeSheet->setTitle('Servicenow Desbloqueos');
            $activeSheet->setShowGridlines(false);

            $activeSheet->setCellValue('A1', "Tiempo de Solucion Semanal de Desbloqueos en ServiceNow");
            $activeSheet->setCellValue('A2', "Consulta del periodo " . date('Y') . " del " . $resumen['Semana']);
            $activeSheet->getStyle('A1:A2')->getFont()->setBold(true);

            $activeSheet->setCellValue('B4', 'Desbloqueos');
            $headerStyle = $activeSheet->getStyle('A4:D4');
            $headerStyle->getFont()->setBold(true);
            $headerStyle->getFont()->getColor()->setRGB('FF0000');

            $activeSheet->setCellValue('A5', 'Num Desbloqueos');
            $activeSheet->setCellValue('A6', 'Tiempo Promedio');
            $activeSheet->setCellValue('A7', '% Cumplimiento');
            $resumenStyle = $activeSheet->getStyle('A5:A7');
            $resumenStyle->getFont()->getColor()->setRGB('FFFFFF');
            $resumenStyle->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
            $resumenStyle = $activeSheet->getStyle('A5:D7');
            $resumenStyle->getFont()->setBold(true);
            $resumenStyle->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            $resumenStyle->getAlignment()->setVertical(Alignment::VERTICAL_CENTER);

            $activeSheet->setCellValue('B5', $resumen['totalDesvloqueos']);
            $activeSheet->setCellValue('B6', $resumen['tiempoProm']);
            $activeSheet->setCellValue('B7', $resumen['prccumplimiento']);

            // Fila de inicio
            $row = 9;
            $row++;

            // Agregar los encabezados a la primera tabla
            $activeSheet->setCellValue('A' . $row, 'Call ID');
            $activeSheet->setCellValue('B' . $row, 'Abierto');
            $activeSheet->setCellValue('C' . $row, 'Actualizado');
            $activeSheet->setCellValue('D' . $row, 'Tiempo');
            $activeSheet->setCellValue('E' . $row, 'Cumplimiento');
            $activeSheet->setCellValue('F' . $row, 'Categoria');
            $activeSheet->setCellValue('G' . $row, 'Descripcion');
            $activeSheet->setCellValue('H' . $row, 'Usuraio');
            $activeSheet->setCellValue('I' . $row, 'Nombre');

            // Aplicar formato a la fila de encabezados
            $headerStyle = $activeSheet->getStyle('A' . $row . ':K' . $row);
            $headerStyle->getFont()->setBold(true);
            $headerStyle->getFont()->getColor()->setRGB('FF0000');
            // Ajustar el ancho de la columna A al ancho de 95px
            $activeSheet->getColumnDimension('A')->setWidth(13);
            $activeSheet->getColumnDimension('I')->setWidth(24);

            // Llenar la primera tabla con los datos de Incidentes SDK
            $row++;
            foreach ($desbloqueos as $item) {
                $activeSheet->setCellValue('A' . $row, $item['call_id']);
                $activeSheet->setCellValue('B' . $row, $item['abierto']);
                $activeSheet->setCellValue('C' . $row, $item['actualizado']);
                $activeSheet->setCellValue('D' . $row, $item['minutos']);
                $activeSheet->setCellValue('E' . $row, $item['cumplimiento']);
                $activeSheet->setCellValue('F' . $row, $item['categoria']);
                $activeSheet->setCellValue('G' . $row, $item['descripcion']);
                $activeSheet->setCellValue('H' . $row, $item['usuario']);
                $activeSheet->setCellValue('I' . $row, $item['nombre']);
                $row++;
            }

            // Ajustar el ancho de las columnas al contenido
            $activeSheet->getColumnDimension('B')->setAutoSize(true);
            $activeSheet->getColumnDimension('C')->setAutoSize(true);
            $activeSheet->getColumnDimension('D')->setAutoSize(true);

            // Guardar el archivo
            $activeSheet = $spreadsheet->setActiveSheetIndex(0);
            $activeSheet->getStyle('A1');
            $writer = new Xlsx($spreadsheet);
            $writer->save($filePath);
        }
    }
    /*******************TABLEROS******************************************************************************************************************** */
    private function saveReportDash($dataSDK, $dataCAU, $targetW)
    {
        $semanal = $dataSDK[0]['SEMANA'];
        $mes = $dataSDK[0]['MES'];
        $numsemana = $dataSDK[0]['NUMSEM'];
        $columnas = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'AA', 'AB', 'AC', 'AD'];

        $saveFile = 'EUT Dashboards';
        // $ruta = 'R://02 Semanales/ServiceNow/';
        $ruta = 'D://Reporteria/02 Semanales/ServiceNow/';
        if (!is_dir($ruta)) {
            mkdir($ruta, 0777, true);
        }

        $filePath = $ruta . $saveFile . '.xlsx';
        $spreadsheet = new Spreadsheet();
        $spreadsheet->getProperties()->setTitle('Alignment');
        $sheet1 = $spreadsheet->getActiveSheet();
        $sheet1->setTitle('SDK');
        $sheet2 = $spreadsheet->createSheet();
        $sheet2->setTitle('CAU');
        $activeSheet = $spreadsheet->setActiveSheetIndex(0);
        $activeSheet->setShowGridlines(false);
        $activeSheet = $spreadsheet->setActiveSheetIndex(1);
        $activeSheet->setShowGridlines(false);

        $SDKSheet = $spreadsheet->setActiveSheetIndex(0);
        foreach ($columnas as $columna) {
            $SDKSheet->getColumnDimension($columna)->setWidth(15);
        }
        $SDKSheet->getStyle('A1:AD3')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
        $SDKSheet->getStyle('A1:AD2')->getFont()->setBold(true);
        $SDKSheet->getStyle('A1:AD1')->getFont()->getColor()->setRGB('FFFFFF');
        $SDKSheet->getStyle('A2:AD2')->getFont()->getColor()->setRGB('FF0000');
        $SDKSheet->mergeCells('A1:C1');
        $SDKSheet->mergeCells('D1:F1');
        $SDKSheet->mergeCells('G1:J1');
        $SDKSheet->mergeCells('K1:N1');
        $SDKSheet->mergeCells('O1:R1');
        $SDKSheet->mergeCells('S1:V1');
        $SDKSheet->mergeCells('W1:Z1');
        $SDKSheet->mergeCells('AA1:AC1');
        $SDKSheet->setCellValue('A1', 'SEMANAL');
        $SDKSheet->setCellValue('D1', 'DESBLOQUEOS');
        $SDKSheet->setCellValue('G1', 'SOLICITUDES');
        $SDKSheet->setCellValue('K1', 'INCIDENTES');
        $SDKSheet->setCellValue('O1', 'TELEFONICO');
        $SDKSheet->setCellValue('S1', 'RVSS INC');
        $SDKSheet->setCellValue('W1', 'RVSS SOL');
        $SDKSheet->setCellValue('AA1', 'VoDK');
        $SDKSheet->getStyle('A1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF7F7F');
        $SDKSheet->getStyle('D1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
        $SDKSheet->getStyle('G1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF7F7F');
        $SDKSheet->getStyle('K1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
        $SDKSheet->getStyle('O1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF7F7F');
        $SDKSheet->getStyle('S1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
        $SDKSheet->getStyle('W1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF7F7F');
        $SDKSheet->getStyle('AA1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
        $SDKSheet->setCellValue('A2', 'MES');
        $SDKSheet->setCellValue('B2', 'NUM SEM');
        $SDKSheet->setCellValue('C2', 'SEMANA');
        $SDKSheet->setCellValue('D2', 'LLAMADAS');
        $SDKSheet->setCellValue('E2', 'PROM');
        $SDKSheet->setCellValue('F2', 'ALCANCE');
        $SDKSheet->setCellValue('G2', 'SOL');
        $SDKSheet->setCellValue('H2', 'PROM');
        $SDKSheet->setCellValue('I2', 'ALCANCE');
        $SDKSheet->setCellValue('J2', 'NOTA');
        $SDKSheet->setCellValue('K2', 'INC');
        $SDKSheet->setCellValue('L2', 'PROM');
        $SDKSheet->setCellValue('M2', 'ALCANCE');
        $SDKSheet->setCellValue('N2', 'NOTA');
        $SDKSheet->setCellValue('O2', 'LLAMADAS');
        $SDKSheet->setCellValue('P2', 'ALCANCE');
        $SDKSheet->setCellValue('Q2', 'AHT');
        $SDKSheet->setCellValue('R2', 'NOTA');
        $SDKSheet->setCellValue('S2', 'INC_SDK');
        $SDKSheet->setCellValue('T2', '%INC_SDK');
        $SDKSheet->setCellValue('U2', 'INC_CAU');
        $SDKSheet->setCellValue('V2', '%INC_CAU');
        $SDKSheet->setCellValue('W2', 'SOL_SDK');
        $SDKSheet->setCellValue('X2', '%SOL_SDK');
        $SDKSheet->setCellValue('Y2', 'SOL_CAU');
        $SDKSheet->setCellValue('Z2', '%SOL_CAU');
        $SDKSheet->setCellValue('AA2', 'INC_SDKB');
        $SDKSheet->setCellValue('AB2', 'DENEGADOS');
        $SDKSheet->setCellValue('AC2', 'SDK K');
        $SDKSheet->setCellValue('A3', $dataSDK[0]['MES']);
        $SDKSheet->setCellValue('B3', $dataSDK[0]['NUMSEM']);
        $SDKSheet->setCellValue('C3', $dataSDK[0]['SEMANA']);
        $SDKSheet->setCellValue('D3', $dataSDK[0]['desbloqueos']);
        $SDKSheet->setCellValue('E3', $dataSDK[0]['promedio_unlocks']);
        $SDKSheet->setCellValue('F3', $dataSDK[0]['cumplimiento_unlocks']);
        $SDKSheet->setCellValue('G3', $dataSDK[0]['solicitudes']);
        $SDKSheet->setCellValue('H3', $dataSDK[0]['promedio_task']);
        $SDKSheet->setCellValue('I3', $dataSDK[0]['cumplimiento_task']);
        $SDKSheet->setCellValue('J3', $dataSDK[0]['nota_task']);
        $SDKSheet->setCellValue('K3', $dataSDK[0]['incidentes']);
        $SDKSheet->setCellValue('L3', $dataSDK[0]['promedio_inc']);
        $SDKSheet->setCellValue('M3', $dataSDK[0]['cumplimiento_inc']);
        $SDKSheet->setCellValue('N3', $dataSDK[0]['nota_inc']);
        $SDKSheet->setCellValue('O3', $dataSDK[0]['calls']);
        $SDKSheet->setCellValue('P3', $dataSDK[0]['%Abandono']);
        $SDKSheet->setCellValue('Q3', $dataSDK[0]['AHT']);
        $SDKSheet->setCellValue('R3', $dataSDK[0]['nota_calls']);
        $SDKSheet->setCellValue('S3', $dataSDK[0]['INC_SDK']);
        $SDKSheet->setCellValue('T3', $dataSDK[0]['%INC_SDK']);
        $SDKSheet->setCellValue('U3', $dataSDK[0]['INC_CAU']);
        $SDKSheet->setCellValue('V3', $dataSDK[0]['%INC_CAU']);
        $SDKSheet->setCellValue('W3', $dataSDK[0]['SOL_SDK']);
        $SDKSheet->setCellValue('X3', $dataSDK[0]['%SOL_SDK']);
        $SDKSheet->setCellValue('Y3', $dataSDK[0]['SOL_CAU']);
        $SDKSheet->setCellValue('Z3', $dataSDK[0]['%SOL_CAU']);
        $SDKSheet->setCellValue('AA3', $dataSDK[0]['INC_SDKB']);
        $SDKSheet->setCellValue('AB3', $dataSDK[0]['DENEGADOS']);
        $SDKSheet->setCellValue('AC3', $dataSDK[0]['SDK K']);
        $SDKSheet->setCellValue('AD1', $dataSDK[0]['NUMMES']);

        $CAUSheet = $spreadsheet->setActiveSheetIndex(1);
        $CAUSheet->getColumnDimension('A')->setWidth(23);
        $CAUSheet->getColumnDimension('B')->setWidth(15);
        $CAUSheet->getColumnDimension('C')->setWidth(12);
        $CAUSheet->getColumnDimension('D')->setWidth(20);
        $CAUSheet->getColumnDimension('E')->setWidth(20);
        $CAUSheet->getStyle('A1:E12')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
        $CAUSheet->getStyle('A1:E2')->getFont()->setBold(true);
        $CAUSheet->getStyle('A2:E2')->getFont()->getColor()->setRGB('FFFFFF');
        $CAUSheet->mergeCells('A1:E1');
        $CAUSheet->getStyle('A1:E2')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('A3A3A3');
        $CAUSheet->setCellValue('A1', $mes . ' ' . date("Y"));
        $CAUSheet->setCellValue('A2', $semanal);
        $CAUSheet->setCellValue('B2', 'Zone');
        $CAUSheet->setCellValue('C2', 'Scope');
        $CAUSheet->setCellValue('D2', 'Tickets Attended');
        $CAUSheet->setCellValue('E2', 'Records Served in time');
        $CAUSheet->fromArray($dataCAU, null, 'A3');

        $activeSheet = $spreadsheet->setActiveSheetIndex(0);
        $writer = new Xlsx($spreadsheet);
        $writer->save($filePath);

        $resumen = array(
            $dataSDK, $dataCAU, $numsemana
        );

        return $resumen;
    }

    /*******************TABLEROS Diarios******************************************************************************************************************** */
    private function saveReportDashDay($dataSDK, $dataCAU, $targetW)
    {
        $semanal = $dataSDK[0]['SEMANA'];
        $mes = $dataSDK[0]['MES'];
        $numsemana = $dataSDK[0]['NUMSEM'];
        $columnas = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'AA', 'AB', 'AC', 'AD'];

        $saveFile = 'EUT Dashboards_' . $semanal;
        $ruta = 'D://Reporteria/02 Semanales/ServiceNow/';
        $rutaText = 'R://02 Semanales/ServiceNow/' . $saveFile;
        if (!is_dir($ruta)) {
            mkdir($ruta, 0777, true);
        }

        $filePath = $ruta . $saveFile . '.xlsx';
        $spreadsheet = new Spreadsheet();
        $spreadsheet->getProperties()->setTitle('Alignment');
        $sheet1 = $spreadsheet->getActiveSheet();
        $sheet1->setTitle('SDK');
        $sheet2 = $spreadsheet->createSheet();
        $sheet2->setTitle('CAU');
        $activeSheet = $spreadsheet->setActiveSheetIndex(0);
        $activeSheet->setShowGridlines(false);
        $activeSheet = $spreadsheet->setActiveSheetIndex(1);
        $activeSheet->setShowGridlines(false);

        $SDKSheet = $spreadsheet->setActiveSheetIndex(0);
        foreach ($columnas as $columna) {
            $SDKSheet->getColumnDimension($columna)->setWidth(15);
        }
        $SDKSheet->getStyle('A1:AD3')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
        $SDKSheet->getStyle('A1:AD2')->getFont()->setBold(true);
        $SDKSheet->getStyle('A1:AD1')->getFont()->getColor()->setRGB('FFFFFF');
        $SDKSheet->getStyle('A2:AD2')->getFont()->getColor()->setRGB('FF0000');
        $SDKSheet->mergeCells('A1:C1');
        $SDKSheet->mergeCells('D1:F1');
        $SDKSheet->mergeCells('G1:J1');
        $SDKSheet->mergeCells('K1:N1');
        $SDKSheet->mergeCells('O1:R1');
        $SDKSheet->mergeCells('S1:V1');
        $SDKSheet->mergeCells('W1:Z1');
        $SDKSheet->mergeCells('AA1:AC1');
        $SDKSheet->setCellValue('A1', 'SEMANAL');
        $SDKSheet->setCellValue('D1', 'DESBLOQUEOS');
        $SDKSheet->setCellValue('G1', 'SOLICITUDES');
        $SDKSheet->setCellValue('K1', 'INCIDENTES');
        $SDKSheet->setCellValue('O1', 'TELEFONICO');
        $SDKSheet->setCellValue('S1', 'RVSS INC');
        $SDKSheet->setCellValue('W1', 'RVSS SOL');
        $SDKSheet->setCellValue('AA1', 'VoDK');
        $SDKSheet->getStyle('A1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF7F7F');
        $SDKSheet->getStyle('D1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
        $SDKSheet->getStyle('G1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF7F7F');
        $SDKSheet->getStyle('K1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
        $SDKSheet->getStyle('O1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF7F7F');
        $SDKSheet->getStyle('S1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
        $SDKSheet->getStyle('W1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF7F7F');
        $SDKSheet->getStyle('AA1')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('FF0000');
        $SDKSheet->setCellValue('A2', 'MES');
        $SDKSheet->setCellValue('B2', 'NUM SEM');
        $SDKSheet->setCellValue('C2', 'SEMANA');
        $SDKSheet->setCellValue('D2', 'LLAMADAS');
        $SDKSheet->setCellValue('E2', 'PROM');
        $SDKSheet->setCellValue('F2', 'ALCANCE');
        $SDKSheet->setCellValue('G2', 'SOL');
        $SDKSheet->setCellValue('H2', 'PROM');
        $SDKSheet->setCellValue('I2', 'ALCANCE');
        $SDKSheet->setCellValue('J2', 'NOTA');
        $SDKSheet->setCellValue('K2', 'INC');
        $SDKSheet->setCellValue('L2', 'PROM');
        $SDKSheet->setCellValue('M2', 'ALCANCE');
        $SDKSheet->setCellValue('N2', 'NOTA');
        $SDKSheet->setCellValue('O2', 'LLAMADAS');
        $SDKSheet->setCellValue('P2', 'ALCANCE');
        $SDKSheet->setCellValue('Q2', 'AHT');
        $SDKSheet->setCellValue('R2', 'NOTA');
        $SDKSheet->setCellValue('S2', 'INC_SDK');
        $SDKSheet->setCellValue('T2', '%INC_SDK');
        $SDKSheet->setCellValue('U2', 'INC_CAU');
        $SDKSheet->setCellValue('V2', '%INC_CAU');
        $SDKSheet->setCellValue('W2', 'SOL_SDK');
        $SDKSheet->setCellValue('X2', '%SOL_SDK');
        $SDKSheet->setCellValue('Y2', 'SOL_CAU');
        $SDKSheet->setCellValue('Z2', '%SOL_CAU');
        $SDKSheet->setCellValue('AA2', 'INC_SDKB');
        $SDKSheet->setCellValue('AB2', 'DENEGADOS');
        $SDKSheet->setCellValue('AC2', 'SDK K');
        $SDKSheet->setCellValue('A3', $dataSDK[0]['MES']);
        $SDKSheet->setCellValue('B3', $dataSDK[0]['NUMSEM']);
        $SDKSheet->setCellValue('C3', $dataSDK[0]['SEMANA']);
        $SDKSheet->setCellValue('D3', $dataSDK[0]['desbloqueos']);
        $SDKSheet->setCellValue('E3', $dataSDK[0]['promedio_unlocks']);
        $SDKSheet->setCellValue('F3', $dataSDK[0]['cumplimiento_unlocks']);
        $SDKSheet->setCellValue('G3', $dataSDK[0]['solicitudes']);
        $SDKSheet->setCellValue('H3', $dataSDK[0]['promedio_task']);
        $SDKSheet->setCellValue('I3', $dataSDK[0]['cumplimiento_task']);
        $SDKSheet->setCellValue('J3', $dataSDK[0]['nota_task']);
        $SDKSheet->setCellValue('K3', $dataSDK[0]['incidentes']);
        $SDKSheet->setCellValue('L3', $dataSDK[0]['promedio_inc']);
        $SDKSheet->setCellValue('M3', $dataSDK[0]['cumplimiento_inc']);
        $SDKSheet->setCellValue('N3', $dataSDK[0]['nota_inc']);
        $SDKSheet->setCellValue('O3', $dataSDK[0]['calls']);
        $SDKSheet->setCellValue('P3', $dataSDK[0]['%Abandono']);
        $SDKSheet->setCellValue('Q3', $dataSDK[0]['AHT']);
        $SDKSheet->setCellValue('R3', $dataSDK[0]['nota_calls']);
        $SDKSheet->setCellValue('S3', $dataSDK[0]['INC_SDK']);
        $SDKSheet->setCellValue('T3', $dataSDK[0]['%INC_SDK']);
        $SDKSheet->setCellValue('U3', $dataSDK[0]['INC_CAU']);
        $SDKSheet->setCellValue('V3', $dataSDK[0]['%INC_CAU']);
        $SDKSheet->setCellValue('W3', $dataSDK[0]['SOL_SDK']);
        $SDKSheet->setCellValue('X3', $dataSDK[0]['%SOL_SDK']);
        $SDKSheet->setCellValue('Y3', $dataSDK[0]['SOL_CAU']);
        $SDKSheet->setCellValue('Z3', $dataSDK[0]['%SOL_CAU']);
        $SDKSheet->setCellValue('AA3', $dataSDK[0]['INC_SDKB']);
        $SDKSheet->setCellValue('AB3', $dataSDK[0]['DENEGADOS']);
        $SDKSheet->setCellValue('AC3', $dataSDK[0]['SDK K']);
        $SDKSheet->setCellValue('AD1', $dataSDK[0]['NUMMES']);

        $CAUSheet = $spreadsheet->setActiveSheetIndex(1);
        $CAUSheet->getColumnDimension('A')->setWidth(23);
        $CAUSheet->getColumnDimension('B')->setWidth(15);
        $CAUSheet->getColumnDimension('C')->setWidth(12);
        $CAUSheet->getColumnDimension('D')->setWidth(20);
        $CAUSheet->getColumnDimension('E')->setWidth(20);
        $CAUSheet->getStyle('A1:E12')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
        $CAUSheet->getStyle('A1:E2')->getFont()->setBold(true);
        $CAUSheet->getStyle('A2:E2')->getFont()->getColor()->setRGB('FFFFFF');
        $CAUSheet->mergeCells('A1:E1');
        $CAUSheet->getStyle('A1:E2')->getFill()->setFillType(Fill::FILL_SOLID)->getStartColor()->setRGB('A3A3A3');
        $CAUSheet->setCellValue('A1', $mes . ' ' . date("Y"));
        $CAUSheet->setCellValue('A2', $semanal);
        $CAUSheet->setCellValue('B2', 'Zone');
        $CAUSheet->setCellValue('C2', 'Scope');
        $CAUSheet->setCellValue('D2', 'Tickets Attended');
        $CAUSheet->setCellValue('E2', 'Records Served in time');
        $CAUSheet->fromArray($dataCAU, null, 'A3');

        $activeSheet = $spreadsheet->setActiveSheetIndex(0);
        $writer = new Xlsx($spreadsheet);
        $writer->save($filePath);

        $resumen = array(
            $dataSDK, $dataCAU, $numsemana, $rutaText
        );

        return $resumen;
    }
    /*****Tableros******************************************************************************************************** */

    private function savePrevioSemnal($info)
    {
        $data = $info;
        foreach ($data as &$datas) {
            unset($datas['observaciones']);
            unset($datas['DIA']);
        }
        $namefile = 'previo_semanal_' . str_replace(" ", "", $data[0]['semanal']);

        $filePath = '../xlsx/' . $namefile . '.xlsx';
        if (file_exists($filePath)) {
            unlink($filePath);
        }
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('outTime_tickets_eut');
        $firstRecord = reset($data);
        $columns = array_keys($firstRecord);
        $columnIndex = 1;
        foreach ($columns as $column) {
            $cellCoordinate = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($columnIndex) . '1';
            $sheet->setCellValue($cellCoordinate, $column);
            $columnIndex++;
        }


        $sheet->getColumnDimension('A')->setWidth(14);
        $sheet->getColumnDimension('B')->setWidth(18);
        $sheet->getColumnDimension('C')->setWidth(8);
        $sheet->getColumnDimension('D')->setWidth(35);
        $sheet->getColumnDimension('E')->setWidth(24);
        $sheet->getColumnDimension('F')->setWidth(9);
        $sheet->getColumnDimension('G')->setWidth(12);
        $sheet->getColumnDimension('H')->setWidth(18);
        $sheet->getColumnDimension('I')->setWidth(14);
        $sheet->getColumnDimension('J')->setWidth(16);
        $sheet->getColumnDimension('K')->setWidth(24);
        $sheet->getColumnDimension('L')->setWidth(24);
        $sheet->getColumnDimension('M')->setWidth(24);
        $sheet->getColumnDimension('N')->setWidth(24);
        $sheet->getColumnDimension('O')->setWidth(24);

        // Establecer estilos para los encabezados (títulos)
        $headerStyle = [
            'font' => ['bold' => true, 'color' => ['rgb' => 'FF0000']],
            'alignment' => ['horizontal' => \PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER],
        ];
        $sheet->getStyle('A1:' . \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex(count($columns)) . '1')->applyFromArray($headerStyle);

        // Fijar la primera fila (encabezados) para que esté siempre visible mientras se desplaza por la hoja
        $sheet->freezePane('A2');

        // Activar autofiltro en la primera fila (encabezados)
        $sheet->setAutoFilter('A1:' . \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex(count($columns)) . '1');

        $rowIndex = 2; // Comenzar a partir de la segunda fila, ya que la primera fila contiene los encabezados
        foreach ($data as $record) {
            $columnIndex = 1;
            foreach ($record as $value) {
                $cellCoordinate = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($columnIndex) . $rowIndex;
                $sheet->setCellValue($cellCoordinate, $value);
                $statusCell = \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex(array_search('folio', $columns) + 1) . $rowIndex;

                // Aplicar formato a toda la fila cuando el campo "Estatus" sea "VENCIDO" (Color de fuente rojo)
                if ($sheet->getCell($statusCell)->getValue() === 'VENCIDO') {
                    $sheet->getStyle($cellCoordinate)->getFont()->getColor()->setRGB('FF0000');
                }

                $columnIndex++;
            }
            $rowIndex++;
        }

        $writer = new Xlsx($spreadsheet);
        $writer->save($filePath);

        if (file_exists($filePath)) {
            $fileCreationTime = filectime($filePath);
            if ($fileCreationTime > 0) {
                $formattedCreationTime = date('Y-m-d H:i:s', $fileCreationTime);
                $response = array(
                    "code" => "200",
                    'mnj' => 'El archivo se ha generado y guardado correctamente.',
                    'status' => 'success',
                    'file_url' => 'http://180.176.105.244/santecreportsapi/' . substr($filePath, 3),
                    'creation_time' => $formattedCreationTime,
                    'range' => $data[0]['semanal'],
                    'info' => $info
                );
            } else {
                $response = array(
                    "code" => "200",
                    "mnj" => "Hubo un problema al generar y guardar el archivo.",
                    'status' => 'error'
                );
            }
        } else {
            $response = array(
                "code" => "202",
                "mnj" => "El archivo no se pudo guardar en la ubicación especificada.",
                'status' => 'error'
            );
        }

        return $response;
    }

    private function sendWeeklyReports($datos, $semana, $mes)
    {
        // */
        // Crear una instancia de la aplicación Outlook
        $outlook = new COM('Outlook.Application') or die('Outlook no está instalado.');

        // Crear un nuevo objeto de correo electrónico
        $mail = $outlook->CreateItem(0);

        // Configurar el destinatario, asunto y cuerpo del correo
        $mail->Recipients->Add('C356882@produban.com.mx');
        $mail->Subject = 'PRELIMINAR: Seguimiento Sonda y Tablero de Control SDK ' . $mes . ' - SEMANA ' . $semana;

        // Adjuntar archivos desde una carpeta
        $adjuntosDir = $datos['targetFiles']; // Ruta a la carpeta que contiene los archivos
        $adjuntos = scandir($adjuntosDir); // Obtener la lista de archivos en la carpeta

        foreach ($adjuntos as $archivo) {
            if ($archivo !== '.' && $archivo !== '..') {
                $rutaArchivo = $adjuntosDir . '/' . $archivo;
                $attachment = $mail->Attachments->Add($rutaArchivo);
            }
        }

        // Utilizar HTMLBody para dar formato al contenido del correo, incluyendo la imagen de firma
        $mail->HTMLBody = '
                    <html>
                    <head>
                        <meta charset="UTF-8" />
                    </head>
                    <body style="font-family: Verdana, Geneva, Tahoma, sans-serif; font-size:12px;">
                        <p>Buen dia a todos;</p>
                        <br>
                        <p>Favor de enviar sus observaciones a mas tardar el <strong style="color: red;">Martes a las 10:00</strong>, para
                            realizar los ajustes correspondientes.</p>
                        <p style="color: red;">Nota: El reporte de remoto vs sitio se unifico en un solo libro que incluye los incidentes y tareas.</p>
                        <br>
                        <br>
                        <p>Sin mas por el momento, quedo a sus Ordenes.</p>
                        <p style="color: red; font-size:14px;"><strong>Rangel Diaz Luis Fernando.</strong></p>
                        <p>Control y Gestion EUT</p>
                        <p style="color: red;">luirangel@produban.com.mx</p>
                        <img src="../assets/firma.png" alt="Firma">
                    </body>

                    </html>';

        //         $mail->Body = "Buen día a todos;

        // Favor de enviar sus observaciones a más tardar el Martes a las 10:00, para realizar los ajustes correspondientes.
        // Nota: Los folios sombreados en 'gris' en los tiempos de solución de Resolutor y CAU, son las K's consideradas en la métrica por más de 2 días conforme a la ventana de servicio correspondiente.

        // Sin más por el momento, quedo a sus Ordenes

        // ";
        // Enviar el correo
        $mail->Send();
        // */
    }
}
