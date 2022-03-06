USE job_manage;

SET NAMES utf8mb4;

DROP PROCEDURE IF EXISTS job_schema_update;

DELIMITER <JOB_UBF>

CREATE PROCEDURE job_schema_update()
BEGIN

    DECLARE db VARCHAR(100);
    SET AUTOCOMMIT = 0;
    SELECT DATABASE() INTO db;
	
    IF NOT EXISTS(SELECT 1
                  FROM information_schema.columns
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'application'
                    AND COLUMN_NAME = 'bk_scope_type') THEN
        ALTER TABLE application ADD COLUMN bk_scope_type VARCHAR(32) NOT NULL DEFAULT '';
    END IF;
	
	IF NOT EXISTS(SELECT 1
                  FROM information_schema.columns
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'application'
                    AND COLUMN_NAME = 'bk_scope_id') THEN
        ALTER TABLE application ADD COLUMN bk_scope_id VARCHAR(32) NOT NULL DEFAULT '';
    END IF;
	
	IF NOT EXISTS(SELECT 1
                  FROM information_schema.columns
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'application'
                    AND COLUMN_NAME = 'is_deleted') THEN
        ALTER TABLE application ADD COLUMN is_deleted tinyint(1) UNSIGNED NOT NULL DEFAULT 0;
    END IF;
    
	UPDATE application SET bk_scope_type = 'biz' WHERE app_type = 1;
	UPDATE application SET bk_scope_type = 'biz_set' WHERE app_type in (2,3);
	UPDATE application SET bk_scope_id = app_id;
	
	IF NOT EXISTS(SELECT 1
                  FROM information_schema.statistics
                  WHERE TABLE_SCHEMA = db
                    AND TABLE_NAME = 'application'
                    AND INDEX_NAME = 'uk_scope_id_scope_type') THEN
        ALTER TABLE application ADD UNIQUE INDEX uk_scope_id_scope_type(`bk_scope_id`,`bk_scope_type`);
    END IF;
	
    COMMIT;
END <JOB_UBF>
DELIMITER ;
COMMIT;
CALL job_schema_update();

DROP PROCEDURE IF EXISTS job_schema_update;