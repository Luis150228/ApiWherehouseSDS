DELIMITER $$

CREATE OR REPLACE FUNCTION make_branch_email(host_in VARCHAR(64))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE s        VARCHAR(64);
  DECLARE cc_raw   VARCHAR(8);
  DECLARE cc       CHAR(4);
  DECLARE code     VARCHAR(8);
  DECLARE num_part VARCHAR(8);
  DECLARE prefix   VARCHAR(64);
  DECLARE domain   VARCHAR(64) DEFAULT 'santander.com.mx';

  -- 1) Sanitiza: solo A-Z0-9 y a MAYÚSCULAS
  SET s = UPPER(REGEXP_REPLACE(host_in, '[^0-9A-Z]', ''));

  -- 2) Debe tener al menos 7 chars (4 + 3)
  IF LENGTH(s) < 7 THEN
    RETURN NULL;
  END IF;

  -- 3) CC y código
  SET cc_raw = SUBSTRING(s, 1, 4);
  SET cc     = LPAD(REGEXP_REPLACE(cc_raw, '[^0-9]', ''), 4, '0'); -- fuerza dígitos
  SET code   = SUBSTRING(s, 5); -- típicamente 3 chars (p.ej. SBD, DRC, PL1, EC3, VT2)

  -- 4) Mapeo
  IF code = 'DRC' THEN
    SET prefix = CONCAT('directorsuc', cc);

  ELSEIF code = 'SBD' THEN
    SET prefix = CONCAT('subdirsuc', cc);

  ELSEIF code = 'OFC' THEN
    SET prefix = CONCAT('oficialsuc', cc);

  ELSEIF code = 'AFN' THEN
    SET prefix = CONCAT('anfitrionsuc', cc);

  ELSEIF code LIKE 'VT%' THEN
    -- Todos los VT: contactar al oficial -> usar oficialsucXXXX@
    -- Si quieres que VT>3 regrese NULL, descomenta lo de abajo:
    -- IF REGEXP_REPLACE(code, '[^0-9]', '') REGEXP '^[4-9][0-9]*$' THEN
    --   RETURN NULL;
    -- END IF;
    SET prefix = CONCAT('oficialsuc', cc);

  ELSEIF code LIKE 'PL%' THEN
    SET num_part = REGEXP_REPLACE(code, '[^0-9]', '');
    IF num_part = '' THEN SET num_part = '1'; END IF;
    SET prefix = CONCAT('cuenta', num_part, 'suc', cc);

  ELSEIF code LIKE 'EC%' THEN
    SET num_part = REGEXP_REPLACE(code, '[^0-9]', '');
    IF num_part = '' THEN SET num_part = '1'; END IF;
    SET prefix = CONCAT('ecuenta', num_part, 'suc', cc);

  ELSE
    RETURN NULL;
  END IF;

  RETURN CONCAT(prefix, '@', domain);
END$$

DELIMITER ;
