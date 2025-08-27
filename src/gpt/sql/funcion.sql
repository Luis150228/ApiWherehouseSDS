INSERT INTO sdkanalyst (
  analyst_expediente,
  analyst_name,
  analyst_workday,
  analyst_corp,
  analyst_mail,
  analyst_upn,
  analyst_type,
  analyst_status,
) VALUES (
  :expediente,
  :name,
  :workday,
  :corp,
  :mail,
  :upn,
  :type,
  COALESCE(:status, 1),  -- default 1 si viene null
)
ON DUPLICATE KEY UPDATE
  analyst_name    = COALESCE(NULLIF(TRIM(VALUES(analyst_name)), ''), analyst_name),
  analyst_workday = COALESCE(NULLIF(TRIM(VALUES(analyst_workday)), ''), analyst_workday),
  analyst_corp    = COALESCE(NULLIF(TRIM(VALUES(analyst_corp)), ''), analyst_corp),
  analyst_mail    = COALESCE(NULLIF(TRIM(VALUES(analyst_mail)), ''), analyst_mail),
  analyst_upn     = COALESCE(NULLIF(TRIM(VALUES(analyst_upn)), ''), analyst_upn),
  analyst_type    = COALESCE(NULLIF(TRIM(VALUES(analyst_type)), ''), analyst_type),
  analyst_status  = COALESCE(VALUES(analyst_status), analyst_status);