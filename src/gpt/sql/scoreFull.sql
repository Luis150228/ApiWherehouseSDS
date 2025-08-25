DELIMITER $$

DROP PROCEDURE IF EXISTS stp_generic_tickets_QualityScore_full $$
CREATE PROCEDURE stp_generic_tickets_QualityScore_full2_0()
BEGIN
  /* Total de checks (12 campos) */
  WITH
  base AS (
    SELECT
      r.abierto_por,
      r.folio,
      IF(r.incidencia_principal <> '', r.incidencia_principal, r.folio) AS incidencia_principal,
      r.abierto,
      CONCAT(r.descripcion, '\n', r.obs_notasresolucion) AS bloque,

      /* Campos de la plantilla (case-insensitive, vienen de tu parser) */
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
    WHERE (r.incidencia_principal <> '' OR r.incidencia_secundarias >= 1)
      AND r.origen = 'SNGlobal Incidentes'
      AND r.abierto >= NOW() - INTERVAL 30 DAY
      AND (r.descripcion LIKE '%**Gener%' OR r.obs_notasresolucion LIKE '%**Gener%')
  ),
  norm AS (
    /* Normaliza: '' o 'SIN DATOS' -> NULL (no presente) */
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
  flags AS (
    SELECT
      n.*,

      /* ========= “Usuario no proporciona” (robusto) =========
         Quitamos *, espacios, puntos y guiones y comparamos.
         Soporta: "usuario no proporciona", "**Usuario no proporciona**", etc. */
      (n.expediente_n  IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.expediente_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')  AS unp_exp,
      (n.ext_contacto_n IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.ext_contacto_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%') AS unp_ext1,
      (n.cel_contacto_n IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.cel_contacto_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%') AS unp_cel1,
      (n.ext2_contacto_n IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.ext2_contacto_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%') AS unp_ext2,
      (n.cel2_contacto_n IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.cel2_contacto_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%') AS unp_cel2,
      (n.correo_n      IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.correo_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')       AS unp_correo,
      (n.cc_n          IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.cc_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')           AS unp_cc,
      (n.region_n      IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.region_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')       AS unp_region,
      (n.upn_n         IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.upn_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')          AS unp_upn,
      (n.ip_n          IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.ip_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')           AS unp_ip,
      (n.hostname_n    IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.hostname_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')     AS unp_hostname,
      (n.numero_afectados_n IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.numero_afectados_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%') AS unp_numaf,
      (n.ip_carrier_n  IS NOT NULL AND REPLACE(REPLACE(REPLACE(REPLACE(UPPER(n.ip_carrier_n),'*',''),' ',''),'.',''),'-','') LIKE '%USUARIONOPROPORCIONA%')   AS unp_ipcar,

      /* ========= Presencia (requeridos) =========
         “Usuario no proporciona” cuenta como presente porque no es NULL */
      IF(n.expediente_n   IS NOT NULL, 1, 0) AS req_exp,
      IF(n.correo_n       IS NOT NULL, 1, 0) AS req_correo,
      IF(n.cc_n           IS NOT NULL, 1, 0) AS req_cc,
      IF(n.region_n       IS NOT NULL, 1, 0) AS req_region,
      IF(n.upn_n          IS NOT NULL, 1, 0) AS req_upn,
      IF(n.ip_n           IS NOT NULL, 1, 0) AS req_ip,
      IF(n.hostname_n     IS NOT NULL, 1, 0) AS req_hostname,
      IF(n.cel_contacto_n IS NOT NULL, 1, 0) AS req_cel,

      /* ========= Válidos (formato) =========
         Regla clave: si es “usuario no proporciona”, lo tomamos como OK. */
      IF( unp_exp     OR (UPPER(n.expediente_n) REGEXP '^[A-Z][0-9]{6}$'), 1, 0) AS ok_exp,
      IF( unp_correo  OR (n.correo_n REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'), 1, 0) AS ok_correo,
      IF( unp_cc      OR (REPLACE(n.cc_n,' ','')            REGEXP '^[0-9]{3,5}$'), 1, 0) AS ok_cc,

      /* Opcionales: NULL -> OK; “usuario no proporciona” -> OK; si no, validar */
      IF( n.ext_contacto_n IS NULL OR unp_ext1 OR (REPLACE(n.ext_contacto_n,' ','')  REGEXP '^[0-9]{3,5}$'), 1, 0) AS ok_ext1,
      IF( n.ext2_contacto_n IS NULL OR unp_ext2 OR (REPLACE(n.ext2_contacto_n,' ','') REGEXP '^[0-9]{3,5}$'), 1, 0) AS ok_ext2,
      IF( unp_cel1 OR (REPLACE(n.cel_contacto_n,' ','')     REGEXP '^[0-9]{10}$'), 1, 0) AS ok_cel1,             -- requerido
      IF( n.cel2_contacto_n IS NULL OR unp_cel2 OR (REPLACE(n.cel2_contacto_n,' ','') REGEXP '^[0-9]{10}$'), 1, 0) AS ok_cel2,

      IF( unp_ip OR (n.ip_n REGEXP '^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$'), 1, 0) AS ok_ip,
      IF( unp_hostname OR (n.hostname_n REGEXP '^[A-Za-z0-9][A-Za-z0-9-]{0,62}(\\.[A-Za-z0-9-]{1,63})*$'), 1, 0) AS ok_hostname,

      /* UPN ≈ dominio de correo; si cualquiera es “usuario no proporciona” → OK */
      IF( unp_upn OR unp_correo
          OR (n.upn_n IS NOT NULL AND n.correo_n IS NOT NULL AND n.upn_n LIKE CONCAT('%', SUBSTRING_INDEX(n.correo_n,'@',-1))), 1, 0
      ) AS ok_upn_dom,

      /* Número afectados / IP carrier: NULL, “SIN DATOS” o “usuario no proporciona” → OK */
      IF( n.numero_afectados_n IS NULL OR n.numero_afectados_n='SIN DATOS' OR unp_numaf
          OR (n.numero_afectados_n REGEXP '^[0-9]+(-[0-9]+)?$'), 1, 0
      ) AS ok_numaf,

      IF( n.ip_carrier_n IS NULL OR unp_ipcar
          OR (n.ip_carrier_n REGEXP '^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$'), 1, 0
      ) AS ok_ip_carrier
    FROM norm n
  )
  SELECT
    f.abierto_por,
    f.folio,
    f.incidencia_principal,
    f.abierto,

    /* Valores capturados (originales) */
    f.expediente,
    f.ext_contacto,
    f.cel_contacto,
    f.nombre2_contacto,
    f.ext2_contacto,
    f.cel2_contacto,
    f.correo,
    f.puesto,
    f.cc,
    f.region,
    f.upn,
    f.usuario_n,
    f.ip,
    f.hostname,
    f.tipo_usuario,
    f.descripcion_incidente,
    f.numero_afectados,
    f.carrier,
    f.ip_carrier,

    /* ===== Métricas ===== */
    12                                           AS total_fields,
    /* score = válidos */
    (
      12
      - (1 - f.ok_exp)
      - (1 - f.ok_correo)
      - (1 - f.ok_cc)
      - (1 - f.ok_ext1)
      - (1 - f.ok_ext2)
      - (1 - f.ok_cel1)
      - (1 - f.ok_cel2)
      - (1 - f.ok_ip)
      - (1 - f.ok_hostname)
      - (1 - f.ok_upn_dom)
      - (1 - f.ok_numaf)
      - (1 - f.ok_ip_carrier)
    )                                             AS valid_count,
    /* inválidos = total - válidos */
    (
      (1 - f.ok_exp)
      + (1 - f.ok_correo)
      + (1 - f.ok_cc)
      + (1 - f.ok_ext1)
      + (1 - f.ok_ext2)
      + (1 - f.ok_cel1)
      + (1 - f.ok_cel2)
      + (1 - f.ok_ip)
      + (1 - f.ok_hostname)
      + (1 - f.ok_upn_dom)
      + (1 - f.ok_numaf)
      + (1 - f.ok_ip_carrier)
    )                                             AS invalid_count,
    /* % completitud */
    ROUND(100 * (
      12
      - (1 - f.ok_exp)
      - (1 - f.ok_correo)
      - (1 - f.ok_cc)
      - (1 - f.ok_ext1)
      - (1 - f.ok_ext2)
      - (1 - f.ok_cel1)
      - (1 - f.ok_cel2)
      - (1 - f.ok_ip)
      - (1 - f.ok_hostname)
      - (1 - f.ok_upn_dom)
      - (1 - f.ok_numaf)
      - (1 - f.ok_ip_carrier)
    ) / 12, 1)                                    AS completion_pct,

    /* Faltantes (requeridos no presentes) */
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

    /* Presentes pero inválidos */
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
  ORDER BY valid_count DESC, f.abierto DESC;
END $$

DELIMITER ;
