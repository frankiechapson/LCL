/************************************************************
    Author  :   Ferenc Toth
    Remark  :   This solution restrict the logon. Run it under SYS!
    Date    :   2019.07.16
************************************************************/



Prompt ***************************************************
Prompt **         I N S T A L L I N G   L C L           **
Prompt ***************************************************


/*============================================================================================*/
CREATE TABLE LCL_TABLE  (
/*============================================================================================*/
  ORACLE_USER             VARCHAR2 (   400 )
        CONSTRAINT LCL_TABLE_NN01                       NOT NULL,      
  OS_USER                 VARCHAR2 (   400 )
        CONSTRAINT LCL_TABLE_NN02                       NOT NULL,      
  IP_ADDRESS              VARCHAR2 (   400 )
        CONSTRAINT LCL_TABLE_NN03                       NOT NULL,      
  PROGRAM                 VARCHAR2 (   400 )
        CONSTRAINT LCL_TABLE_NN04                       NOT NULL,      
  ENABLED                 CHAR     (     1 )            DEFAULT 'Y'
        CONSTRAINT LCL_TABLE_NN05                       NOT NULL,      
        CONSTRAINT LCL_TABLE_CH01                       CHECK ( ENABLED IN ( 'Y', 'N' ) )
    );

comment on table  LCL_TABLE               is 'Login Control List';
comment on column LCL_TABLE.ORACLE_USER   is 'It will use in LIKE, so you can use pattern, so "%" means everbody (case insensitive)';
comment on column LCL_TABLE.OS_USER       is 'It will use in LIKE, so you can use pattern, so "%" means everbody (case insensitive)';
comment on column LCL_TABLE.IP_ADDRESS    is 'It will use in LIKE, so you can use pattern, so "%" means "from anywhere" ';
comment on column LCL_TABLE.PROGRAM       is 'It will use in LIKE, so you can use pattern, so "%" means "by any program" ';
comment on column LCL_TABLE.ENABLED       is ' Y = login enabled / N = login disabled for this';



/*============================================================================================*/
CREATE TABLE LCL_LOG  (
/*============================================================================================*/
  LOGON_TIME              DATE
        CONSTRAINT LCL_LOG_LOGON_TIME_NN                NOT NULL,      
  ORACLE_USER             VARCHAR2 (   400 )
        CONSTRAINT LCL_LOG_ORACLE_USER_NN               NOT NULL,      
  OS_USER                 VARCHAR2 (   400 ) 
        CONSTRAINT LCL_LOG_OS_USER_NN                   NOT NULL,      
  IP_ADDRESS              VARCHAR2 (   400 )
        CONSTRAINT LCL_TABLE_IP_ADDRESS_NN              NOT NULL,      
  PROGRAM                 VARCHAR2 (   400 )
        CONSTRAINT LCL_TABLE_PROGRAM_NN                 NOT NULL
    );

comment on table  LCL_LOG               is 'Login Control List LOG. The log of refused logins';
comment on column LCL_LOG.LOGON_TIME    is 'The time of login';
comment on column LCL_LOG.ORACLE_USER   is 'The name of the Oracel user';
comment on column LCL_LOG.OS_USER       is 'The name of OS user';
comment on column LCL_LOG.IP_ADDRESS    is 'The IP address of the client';
comment on column LCL_LOG.PROGRAM       is 'The name of application what was used';



/*============================================================================================*/
CREATE OR REPLACE TRIGGER  TRG_LCL_LOGON
/*============================================================================================*/
AFTER LOGON ON DATABASE
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_CNT       NUMBER;
    V_LOG       LCL_LOG%ROWTYPE;
BEGIN
    V_LOG.LOGON_TIME  := SYSDATE;
    V_LOG.ORACLE_USER := SYS_CONTEXT('USERENV', 'SESSION_USER' );
    V_LOG.OS_USER     := SYS_CONTEXT('USERENV', 'OS_USER'      );
    V_LOG.IP_ADDRESS  := SYS_CONTEXT('USERENV', 'IP_ADDRESS'   );
    V_LOG.PROGRAM     := SYS_CONTEXT('USERENV', 'MODULE'       );
    -- Is it allowed?
    SELECT COUNT(*)
      INTO V_CNT
      FROM LCL_TABLE
     WHERE UPPER( V_LOG.ORACLE_USER ) like UPPER( ORACLE_USER )  
       AND UPPER( V_LOG.OS_USER     ) like UPPER( OS_USER     ) 
       AND UPPER( V_LOG.IP_ADDRESS  ) like UPPER( IP_ADDRESS  ) 
       AND UPPER( V_LOG.PROGRAM     ) like UPPER( PROGRAM     ) 
       AND ENABLED = 'Y';
    IF V_CNT = 0 THEN
        -- No. Is it DBA?
        SELECT COUNT(*)
          INTO V_CNT
          FROM DBA_ROLE_PRIVS 
         WHERE GRANTED_ROLE     = 'DBA' 
           AND UPPER( GRANTEE ) = UPPER( V_LOG.ORACLE_USER );
        if V_CNT = 0 then
            -- No, so "Logon failed"
            INSERT INTO LCL_LOG VALUES V_LOG;
            COMMIT;
            RAISE_APPLICATION_ERROR( -20000, 'Good bye!' );
        END IF;
    END IF;
    ROLLBACK;
END;



