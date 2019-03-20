--log
spool system_Majer5.log


--Vytvoreni noveho tablespace
 create tablespace bar5 datafile 'C:\USERS\PAVELMA\DOCUMENTS\ORADATA\PAMATEST\BAR_05.DBF' size 100M autoextend on  next 100M maxsize 2G;

--Vytvoreni role - pridani prav teto roli (create table, create view…)
 create role BAR_ADMIN_ROLE5;
 GRANT CONNECT TO BAR_ADMIN_ROLE5;
 grant create table to BAR_ADMIN_ROLE5;
 grant create session to BAR_ADMIN_ROLE5;
 grant create sequence to BAR_ADMIN_ROLE5;
 grant create trigger to BAR_ADMIN_ROLE5;
 grant create view to BAR_ADMIN_ROLE5; 
 grant create synonym to BAR_ADMIN_ROLE5; 


--vytvoreni uzivatele 
 create user pavel5 identified by pavel5 default tablespace bar5 temporary tablespace TEMP;
 grant BAR_ADMIN_ROLE5 to pavel5;
 alter user pavel5 quota unlimited on bar5;  
 commit;
spool off;



