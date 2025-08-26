DELIMITER $$

DROP PROCEDURE IF EXISTS stp_generic_tickets_QualityScore_full2_1 $$
CREATE PROCEDURE stp_generic_tickets_QualityScore_full2_1()
BEGIN

DECLARE set_total_fields INT;
SET set_total_fields = 12;
  WITH
  base AS (
  SELECT * FROM eut_genericactive a LEFT JOIN
    (SELECT
	  LEFT(mail_creador, 7) AS 'creator',
      r.folio,
      IF(r.incidencia_principal <> '', r.incidencia_principal, r.folio) AS incidencia_principal,
      r.abierto,
      CONCAT(r.descripcion, '\n', r.obs_notasresolucion) AS bloque,

      -- Campos de plantilla (case-insensitive)
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'EXPEDIENTE')            AS expediente,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'EXT_CONTACTO')          AS ext_contacto,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'CEL_CONTACTO')          AS cel_contacto,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'NOMBRE2_CONTACTO')      AS nombre2_contacto,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'EXT2_CONTACTO')         AS ext2_contacto,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'CEL2_CONTACTO')         AS cel2_contacto,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'CORREO')                AS correo,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'PUESTO')                AS puesto,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'CC')                    AS cc,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'REGION')                AS region,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'UPN')                   AS upn,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'USUARIO_N')             AS usuario_n,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'IP')                    AS ip,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'HOSTNAME')              AS hostname,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'TIPO_USUARIO')          AS tipo_usuario,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'DESCRIPCION_INCIDENTE') AS descripcion_incidente,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'NUMERO_AFECTADOS')      AS numero_afectados,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'CARRIER')               AS carrier,
      fn_parseItemGenericQuality_ci(CONCAT(r.descripcion, '\n', r.obs_notasresolucion), 'IP DEL CARRIER')        AS ip_carrier
    FROM servicenow_reportes r 
    WHERE 1)g
      ON a.report = g.folio OR a.report = g.incidencia_principal WHERE a.estatus_active = 1
  ),
  norm AS (
    -- Normaliza: '' o 'SIN DATOS' -> NULL (no presente)
    SELECT
      b.*,
      NULLIF(NULLIF(TRIM(b.expediente),''),'SIN DATOS')              AS expediente_n,
      NULLIF(NULLIF(TRIM(b.ext_contacto),''),'SIN DATOS')            AS ext_contacto_n,
      NULLIF(NULLIF(TRIM(b.cel_contacto),''),'SIN DATOS')            AS cel_contacto_n,
      NULLIF(NULLIF(TRIM(b.nombre2_contacto),''),'SIN DATOS')        AS nombre2_contacto_n,
      NULLIF(NULLIF(TRIM(b.ext2_contacto),''),'SIN DATOS')           AS ext2_contacto_n,
      NULLIF(NULLIF(TRIM(b.cel2_contacto),''),'SIN DATOS')           AS cel2_contacto_n,
      NULLIF(NULLIF(TRIM(b.correo),''),'SIN DATOS')                  AS correo_n,
      NULLIF(NULLIF(TRIM(b.puesto),''),'SIN DATOS')                  AS puesto_n,
      NULLIF(NULLIF(TRIM(b.cc),''),'SIN DATOS')                      AS cc_n,
      NULLIF(NULLIF(TRIM(b.region),''),'SIN DATOS')                  AS region_n,
      NULLIF(NULLIF(TRIM(b.upn),''),'SIN DATOS')                     AS upn_n,
      NULLIF(NULLIF(TRIM(b.usuario_n),''),'SIN DATOS')               AS usuario_n_n,
      NULLIF(NULLIF(TRIM(b.ip),''),'SIN DATOS')                      AS ip_n,
      NULLIF(NULLIF(TRIM(b.hostname),''),'SIN DATOS')                AS hostname_n,
      NULLIF(NULLIF(TRIM(b.tipo_usuario),''),'SIN DATOS')            AS tipo_usuario_n,
      NULLIF(NULLIF(TRIM(b.descripcion_incidente),''),'SIN DATOS')   AS descripcion_incidente_n,
      NULLIF(NULLIF(TRIM(b.numero_afectados),''),'SIN DATOS')        AS numero_afectados_n,
      NULLIF(NULLIF(TRIM(b.carrier),''),'SIN DATOS')                 AS carrier_n,
      NULLIF(NULLIF(TRIM(b.ip_carrier),''),'SIN DATOS')              AS ip_carrier_n
    FROM base b
  ),
  unp AS (
    -- Construye flags “usuario no proporciona” (UNP) por campo
    SELECT
      n.*,
      (n.expediente_n      IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.expediente_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')       AS unp_exp,
      (n.ext_contacto_n    IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.ext_contacto_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')    AS unp_ext1,
      (n.cel_contacto_n    IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.cel_contacto_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')    AS unp_cel1,
      (n.ext2_contacto_n   IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.ext2_contacto_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')   AS unp_ext2,
      (n.cel2_contacto_n   IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.cel2_contacto_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')   AS unp_cel2,
      (n.correo_n          IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.correo_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')           AS unp_correo,
      (n.cc_n              IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.cc_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')               AS unp_cc,
      (n.region_n          IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.region_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')           AS unp_region,
      (n.upn_n             IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.upn_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')              AS unp_upn,
      (n.ip_n              IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.ip_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')               AS unp_ip,
      (n.hostname_n        IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.hostname_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')         AS unp_hostname,
      (n.numero_afectados_n IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.numero_afectados_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%') AS unp_numaf,
      (n.ip_carrier_n      IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.ip_carrier_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')       AS unp_ipcar
    FROM norm n
  ),
  flags AS (
    SELECT
      u.*,

      -- Presencia (requeridos): UNP cuenta como presente porque no es NULL
      IF(u.expediente_n   IS NOT NULL, 1, 0) AS req_exp,
      IF(u.correo_n       IS NOT NULL, 1, 0) AS req_correo,
      IF(u.cc_n           IS NOT NULL, 1, 0) AS req_cc,
      IF(u.region_n       IS NOT NULL, 1, 0) AS req_region,
      IF(u.upn_n          IS NOT NULL, 1, 0) AS req_upn,
      IF(u.ip_n           IS NOT NULL, 1, 0) AS req_ip,
      IF(u.hostname_n     IS NOT NULL, 1, 0) AS req_hostname,
      IF(u.cel_contacto_n IS NOT NULL, 1, 0) AS req_cel,

      -- Válidos (formato). Si es UNP -> OK
      IF( u.unp_exp    OR (UPPER(u.expediente_n) REGEXP '^[A-Z][0-9]{6}$'), 1, 0) AS ok_exp,
      IF( u.unp_correo OR (u.correo_n REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'), 1, 0) AS ok_correo,
      IF( u.unp_cc     OR (REPLACE(u.cc_n,' ','') REGEXP '^[0-9]{3,5}$'), 1, 0) AS ok_cc,

      -- Opcionales: NULL -> OK; UNP -> OK; si no, validar
      IF( u.ext_contacto_n IS NULL OR u.unp_ext1 OR (REPLACE(u.ext_contacto_n,' ','') REGEXP '^[0-9]{3,5}$'), 1, 0) AS ok_ext1,
      IF( u.ext2_contacto_n IS NULL OR u.unp_ext2 OR (REPLACE(u.ext2_contacto_n,' ','') REGEXP '^[0-9]{3,5}$'), 1, 0) AS ok_ext2,
      IF(                 u.unp_cel1 OR (REPLACE(u.cel_contacto_n,' ','')  REGEXP '^[0-9]{10}$'), 1, 0) AS ok_cel1, -- requerido
      IF( u.cel2_contacto_n IS NULL OR u.unp_cel2 OR (REPLACE(u.cel2_contacto_n,' ','') REGEXP '^[0-9]{10}$'), 1, 0) AS ok_cel2,

      IF( u.unp_ip OR (u.ip_n REGEXP '^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$'), 1, 0) AS ok_ip,
      IF( u.unp_hostname OR (u.hostname_n REGEXP '^[A-Za-z0-9][A-Za-z0-9-]{0,62}(\\.[A-Za-z0-9-]{1,63})*$'), 1, 0) AS ok_hostname,

      IF( u.unp_upn OR u.unp_correo
          OR (u.upn_n IS NOT NULL AND u.correo_n IS NOT NULL AND u.upn_n LIKE CONCAT('%', SUBSTRING_INDEX(u.correo_n,'@',-1))), 1, 0
      ) AS ok_upn_dom,

      IF( u.numero_afectados_n IS NULL OR u.numero_afectados_n='SIN DATOS' OR u.unp_numaf
          OR (u.numero_afectados_n REGEXP '^[0-9]+(-[0-9]+)?$'), 1, 0
      ) AS ok_numaf,

      IF( u.ip_carrier_n IS NULL OR u.unp_ipcar
          OR (u.ip_carrier_n REGEXP '^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$'), 1, 0
      ) AS ok_ip_carrier
    FROM unp u
  )
  SELECT
    f.folio,
    incidencia_principal,
    f.creator,
    IFNULL(IFNULL(u.analyst, a.analyst_name), w.nombre_full) as 'analyst_name',
    -- Métricas (12 checks)
    set_total_fields AS total_fields,

    (  f.ok_exp + f.ok_correo + f.ok_cc + f.ok_ext1 + f.ok_ext2
     + f.ok_cel1 + f.ok_cel2 + f.ok_ip + f.ok_hostname
     + f.ok_upn_dom + f.ok_numaf + f.ok_ip_carrier ) AS valid_count,

    (  (1 - f.ok_exp) + (1 - f.ok_correo) + (1 - f.ok_cc) + (1 - f.ok_ext1) + (1 - f.ok_ext2)
     + (1 - f.ok_cel1) + (1 - f.ok_cel2) + (1 - f.ok_ip) + (1 - f.ok_hostname)
     + (1 - f.ok_upn_dom) + (1 - f.ok_numaf) + (1 - f.ok_ip_carrier) ) AS invalid_count,

    ROUND(100 * (
      (  f.ok_exp + f.ok_correo + f.ok_cc + f.ok_ext1 + f.ok_ext2
       + f.ok_cel1 + f.ok_cel2 + f.ok_ip + f.ok_hostname
       + f.ok_upn_dom + f.ok_numaf + f.ok_ip_carrier ) / set_total_fields
    ), 1) AS completion_pct,
	IF((( f.ok_exp + f.ok_correo + f.ok_cc + f.ok_ext1 + f.ok_ext2 + f.ok_cel1 + f.ok_cel2 + f.ok_ip + f.ok_hostname + f.ok_upn_dom + f.ok_numaf + f.ok_ip_carrier ) / set_total_fields) <1, 'Incompleto', 'Correctamente') AS asCompleted,
    -- Faltantes (requeridos no presentes)
    TRIM(BOTH ', ' FROM CONCAT_WS(', ',
      IF(f.req_exp=1,    NULL, 'EXPEDIENTE'),
      IF(f.req_correo=1, NULL, 'CORREO'),
      IF(f.req_cc=1,     NULL, 'CC'),
      IF(f.req_region=1, NULL, 'REGION'),
      IF(f.req_upn=1,    NULL, 'UPN'),
      IF(f.req_ip=1,     NULL, 'IP'),
      IF(f.req_hostname=1,NULL, 'HOSTNAME'),
      IF(f.req_cel=1,    NULL, 'CEL_CONTACTO')
    )) AS missing_fields,

    -- Presentes pero inválidos
    TRIM(BOTH ', ' FROM CONCAT_WS(', ',
      IF(f.req_exp=1       AND f.ok_exp=0,        'EXPEDIENTE (letra+6 dígitos)', NULL),
      IF(f.req_correo=1    AND f.ok_correo=0,     'CORREO (formato)', NULL),
      IF(f.req_cc=1        AND f.ok_cc=0,         'CC (3-5 dígitos)', NULL),
      IF(f.ext_contacto_n IS NOT NULL AND f.ok_ext1=0, 'EXT_CONTACTO (3-5 dígitos)', NULL),
      IF(f.ext2_contacto_n IS NOT NULL AND f.ok_ext2=0, 'EXT2_CONTACTO (3-5 dígitos)', NULL),
      IF(f.cel_contacto_n IS NOT NULL AND f.ok_cel1=0, 'CEL_CONTACTO (10 dígitos)', NULL),
      IF(f.cel2_contacto_n IS NOT NULL AND f.ok_cel2=0, 'CEL2_CONTACTO (10 dígitos)', NULL),
      IF(f.req_ip=1        AND f.ok_ip=0,         'IP (IPv4 inválida)', NULL),
      IF(f.req_hostname=1  AND f.ok_hostname=0,   'HOSTNAME (inválido)', NULL),
      IF(f.req_upn=1       AND f.ok_upn_dom=0,    'UPN (dominio ≠ CORREO)', NULL),
      IF(f.numero_afectados_n IS NOT NULL AND f.ok_numaf=0, 'NUMERO_AFECTADOS (n o n-m)', NULL),
      IF(f.ip_carrier_n    IS NOT NULL AND f.ok_ip_carrier=0, 'IP DEL CARRIER (IPv4 inválida)', NULL)
    )) AS invalid_fields

  FROM flags f 
  LEFT JOIN (SELECT abierto_por AS 'analyst', LEFT(actualizado_por, 7) AS 'analyst_expedient', 'SDK' AS 'typeAnalyst' FROM servicenow_unlock group by abierto_por order by abierto_por ASC limit 400)u
    ON f.creator = u.analyst_expedient
  LEFT JOIN (SELECT analyst_expediente, analyst_name FROM sdkanalyst)a
    ON f.creator = a.analyst_expediente
  LEFT JOIN (SELECT usuario, nombre_full FROM eut_toolmovil.workday where usuario LIKE 'Z%' ORDER BY usuario desc limit 8000)w
    ON f.creator = w.usuario
  ORDER BY valid_count DESC, f.abierto DESC;
END $$

DELIMITER ;

/*
call eut_reportesbk.stp_generic_tickets_QualityScore_full2_1();
folio, incidencia_principal, creator, analyst_name, total_fields, valid_count, invalid_count, completion_pct, asCompleted, missing_fields, invalid_fields
'INC057672909', 'INC057666803', 'Z945591', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057670240', 'INC057666803', 'S789173', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057670221', 'INC057666803', 'S020225', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057670041', 'INC057666803', 'Z949981', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669995', 'INC057666803', 'Z936829', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669968', 'INC057666803', 'Z946606', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669897', 'INC057666803', 'Z945589', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669886', 'INC057666803', 'Z921067', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669794', 'INC057666803', 'Z923414', 'ISRAEL ASCENCIO CONTRERAS', '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669718', 'INC057666803', 'Z949981', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669710', 'INC057666803', 'S027210', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669690', 'INC057666803', 'Z934089', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669658', 'INC057666803', 'S617107', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669621', 'INC057666803', 'S071504', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669589', 'INC057666803', 'Z942058', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669457', 'INC057666803', 'Z934089', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669453', 'INC057666803', 'Z949981', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669205', 'INC057666803', 'S014663', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669062', 'INC057666803', 'Z949981', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057669024', 'INC057666803', 'S108622', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057668668', 'INC057666803', 'Z945586', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057667981', 'INC057666803', 'S110937', NULL, '12', '9', '3', '75.0', 'Incompleto', 'CORREO, UPN, IP', ''
'INC057670253', 'INC057666803', 'Z923414', 'ISRAEL ASCENCIO CONTRERAS', '12', '8', '4', '66.7', 'Incompleto', 'CORREO, UPN, IP', 'CEL_CONTACTO (10 dígitos)'
'INC057669587', 'INC057666803', 'Z921067', NULL, '12', '8', '4', '66.7', 'Incompleto', 'CORREO, UPN, IP', 'HOSTNAME (inválido)'
'INC057669501', 'INC057666803', 'Z923414', 'ISRAEL ASCENCIO CONTRERAS', '12', '8', '4', '66.7', 'Incompleto', 'CORREO, UPN, IP', 'CEL_CONTACTO (10 dígitos)'
'INC057669336', 'INC057666803', 'Z948940', NULL, '12', '8', '4', '66.7', 'Incompleto', 'CORREO, UPN, IP, CEL_CONTACTO', ''
'INC057668373', 'INC057666803', 'Z927706', 'MARIA ESTHELA LOPEZ ROSALES', '12', '8', '4', '66.7', 'Incompleto', 'CORREO, UPN, IP', 'EXT_CONTACTO (3-5 dígitos)'
'INC057667973', 'INC057666803', 'Z949976', NULL, '12', '8', '4', '66.7', 'Incompleto', 'CORREO, UPN, IP', 'CEL_CONTACTO (10 dígitos)'
'INC057670052', 'INC057666803', 'Z936831', NULL, '12', '7', '5', '58.3', 'Incompleto', 'CORREO, UPN, IP', 'EXPEDIENTE (letra+6 dígitos), EXT_CONTACTO (3-5 dígitos)'
'INC057669887', 'INC057666803', 'Z946609', NULL, '12', '7', '5', '58.3', 'Incompleto', 'CORREO, UPN, IP', 'EXT_CONTACTO (3-5 dígitos), CEL_CONTACTO (10 dígitos)'
'INC057666803', 'INC057666803', 'Z936830', NULL, '12', '7', '5', '58.3', 'Incompleto', '', 'CORREO (formato), EXT2_CONTACTO (3-5 dígitos), CEL_CONTACTO (10 dígitos), CEL2_CONTACTO (10 dígitos), IP DEL CARRIER (IPv4 inválida)'
'INC057670219', 'INC057666803', 'S034638', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057670011', 'INC057666803', 'S029861', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057669974', 'INC057666803', 'S029277', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057669882', 'INC057666803', 'S262446', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057669636', 'INC057666803', 'S267159', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057669436', 'INC057666803', 'S677408', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057036745', 'INC057033837', 'Z949981', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057035957', 'INC057033837', 'Z949981', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057035934', 'INC057033837', 'Z948940', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057035829', 'INC057033837', 'Z949981', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057035356', 'INC057033837', 'Z932614', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057035109', 'INC057033837', 'Z949981', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057035099', 'INC057033837', 'S359716', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034958', 'INC057033837', 'Z945589', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034683', 'INC057033837', 'S342636', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034639', 'INC057033837', 'S029245', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034559', 'INC057033837', 'Z948938', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034556', 'INC057033837', 'Z936831', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034484', 'INC057033837', 'Z927707', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034297', 'INC057033837', 'Z934090', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034290', 'INC057033837', 'S013914', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034197', 'INC057033837', 'C243104', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034138', 'INC057033837', 'S269812', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034040', 'INC057033837', 'S768600', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057034023', 'INC057033837', 'S273777', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'INC057033837', 'INC057033837', 'S029277', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''
'', 'INC057033837', '', NULL, '12', '5', '7', '41.7', 'Incompleto', 'EXPEDIENTE, CORREO, CC, REGION, UPN, IP, HOSTNAME, CEL_CONTACTO', ''

*/