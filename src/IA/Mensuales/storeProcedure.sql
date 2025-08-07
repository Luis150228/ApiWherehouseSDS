CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_mensualesDetalle`(var_reporte VARCHAR(150), var_idRange VARCHAR(6))
BEGIN
DECLARE diaInicio DATETIME;
DECLARE diaFin DATETIME;
DECLARE let_rango VARCHAR(150);

SET let_rango = (SELECT MONTH(now())-1 as `range` LIMIT 1);
-- SET let_rango = ('03 NOV - 09 NOV');
SET diaInicio = (SELECT date_sub(date_format(now(), '%Y-%m-01 00:00:00'), interval 1 month));
SET diaFin = (SELECT date_sub(date_format(now(), '%Y-%m-01 23:59:59'), interval 1 day));

	IF var_reporte = 'CAU_INC' THEN
        SELECT `Ticket`, `id Externo`, `Fecha de Envio`, `Fecha resolucion`, `Tiempo`, `Nivel 1`, `Nivel 2`, `Nivel 3`, `Grupo Asignado`, `Usuario Asignado`, `Localidad`, `Zona`, `Observaciones`, `Fecha de Cierre`, `Estatus`, `Inhibidor`, `Ubicacion`, `Localizacion`, `INHIBIDOR_CODIGO`, `CodigoDescripcion`, `Descripcion_Resolutor`, `Comentarios_Resolutor`, `Regional`, `Procede`, `CCG`, CONCAT(YEAR(diaInicio),'-',month(diaInicio)) AS `SEMANAL` FROM eut_weeklyreportsinc where (`Fecha resolucion` between diaInicio AND diaFin) AND REPORTE = var_reporte;
	
    ELSEIF var_reporte = 'CAU_INCK' THEN
        SELECT `Ticket`, `id Externo`, `Fecha de Envio`, `Fecha resolucion`, `Tiempo`, `Nivel 1`, `Nivel 2`, `Nivel 3`, `Grupo Asignado`, `Usuario Asignado`, `Localidad`, `Zona`, `Observaciones`, `Fecha de Cierre`, `Estatus`, `Inhibidor`, `Ubicacion`, `Localizacion`, `INHIBIDOR_CODIGO`, `CodigoDescripcion`, `Descripcion_Resolutor`, `Comentarios_Resolutor`, `Regional`, `Procede`, `CCG`, CONCAT(YEAR(diaInicio),'-',month(diaInicio)) AS `SEMANAL`  FROM eut_weeklyreportsinc where (`Fecha resolucion` between diaInicio AND diaFin) AND REPORTE = var_reporte;
	
    ELSEIF var_reporte = 'CAU_SOL' THEN
        SELECT `Solicitud`, `Id Externo`, `Envio`, `Resolucion`, `Tiempo`, `Nivel 1`, `Nivel 2`, `Nivel 3`, `Grupo Asignado`, `Usuario Asignado`, `Localidad`, `Zona`, `Ubicacion`, `Localizacion`, `Observaciones`, `Cierre`, `Estatus`, `Id Caso Proveedor`, `INHIBIDOR_CODIGO`, `CODIGO`, `CAUSA`, `OBSERVACIONES`, `REGIONAL`, `PROCEDE`, `CCG`, CONCAT(YEAR(diaInicio),'-',month(diaInicio)) AS `SEMANAL` FROM eut_weeklyreportssol where (`Resolucion` between diaInicio AND diaFin) AND REPORTE = var_reporte;
	
    ELSEIF var_reporte = 'SDK_INC' THEN
        SELECT `Ticket`, `id Externo`, `Fecha de Envio`, `Fecha resolucion`, `Tiempo`, `Nivel 1`, `Nivel 2`, `Nivel 3`, `Grupo Asignado`, `Usuario Asignado`, `Localidad`, `Zona`, `Observaciones`, `Fecha de Cierre`, `Estatus`, `Inhibidor`, `Ubicacion`, `Localizacion`, `INHIBIDOR_CODIGO`, `CodigoDescripcion`, `Descripcion_Resolutor`, `Comentarios_Resolutor`, `Regional`, `Procede`, `CCG`, CONCAT(YEAR(diaInicio),'-',month(diaInicio)) AS `SEMANAL` FROM eut_weeklyreportsinc where (`Fecha resolucion` between diaInicio AND diaFin) AND REPORTE = var_reporte;
	
    ELSEIF var_reporte = 'SDK_INCK' THEN
        SELECT `Ticket`, `id Externo`, `Fecha de Envio`, `Fecha resolucion`, `Tiempo`, `Nivel 1`, `Nivel 2`, `Nivel 3`, `Grupo Asignado`, `Usuario Asignado`, `Localidad`, `Zona`, `Observaciones`, `Fecha de Cierre`, `Estatus`, `Inhibidor`, `Ubicacion`, `Localizacion`, `Codigo`, `Descripcion`, `INHIBIDOR_CODIGO`, `CodigoDescripcion`, `Descripcion_Resolutor`, `Comentarios_Resolutor`, `Regional`, `Procede`, `CCG`, CONCAT(YEAR(diaInicio),'-',month(diaInicio)) AS `SEMANAL` FROM eut_weeklyreportsinc where (`Fecha resolucion` between diaInicio AND diaFin) AND REPORTE = var_reporte;
	
    ELSEIF var_reporte = 'SDK_SOL' THEN
        SELECT `Solicitud`, `Id Externo`, `Envio`, `Resolucion`, `Tiempo`, `Nivel 1`, `Nivel 2`, `Nivel 3`, `Grupo Asignado`, `Usuario Asignado`, `Localidad`, `Zona`, `Ubicacion`, `Localizacion`, `Observaciones`, `Cierre`, `Estatus`, `Id Caso Proveedor`, `INHIBIDOR_CODIGO`, `CODIGO`, `CAUSA`, `OBSERVACIONES`, `REGIONAL`, `PROCEDE`, `CCG`, CONCAT(YEAR(diaInicio),'-',month(diaInicio)) AS `SEMANAL` FROM eut_weeklyreportssol where (`Resolucion` between diaInicio AND diaFin) AND REPORTE = var_reporte;
	END iF;
END