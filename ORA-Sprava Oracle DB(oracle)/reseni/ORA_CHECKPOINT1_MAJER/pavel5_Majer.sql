spool pavel5_Majer.log
--4. Založení (pod novì vytvoøeným uživatelem)
--min. 2 tabulky
show user
prompt "drop tables" ;
drop table stul;
drop table katalog;
drop table objednavka;
drop sequence objednavka_seq;
drop sequence stul_seq;
drop sequence katalog_seq;
drop synonym obj;
drop view aktualni_objednavky;

prompt "create tables";
create table STUL (id integer, nazev varchar2(30) );
create table KATALOG (id integer, nazev varchar2(30), cena integer );
create table OBJEDNAVKA (id integer, vytvoreno date, stul integer, polozka integer );

prompt "create seq"
--4a) sequence
create sequence objednavka_seq nocache; 
create sequence katalog_seq nocache;  
create sequence stul_seq nocache; 
commit;

prompt "create triggers"
CREATE OR REPLACE TRIGGER stul_trg 
BEFORE INSERT ON stul 
FOR EACH ROW
BEGIN
  :NEW.ID := stul_seq.nextval;
END;
/



CREATE OR REPLACE TRIGGER katalog_trg 
BEFORE INSERT ON katalog
FOR EACH ROW
BEGIN
  :NEW.ID := katalog_seq.nextval;
END;
/

CREATE OR REPLACE TRIGGER objednavka_trg 
BEFORE INSERT ON objednavka 
FOR EACH ROW
BEGIN
  :NEW.ID := objednavka_seq.nextval;
  :NEW.VYTVORENO := sysdate;
END;
/

prompt "create synonym"
-- 4c)synonymum
  CREATE SYNONYM obj FOR objednavka;

prompt "create view"
-- 4d) view
  CREATE VIEW aktualni_objednavky AS
  select to_char (vytvoreno, 'DD/MM/YYYY HH24:MI:SS') vytvoreno, round ((sysdate - vytvoreno)*24*60 ) ceka_min , s.nazev stul, k.nazev polozka, k.cena
  from objednavka o, stul s, katalog k
  where o.STUL=s.id and o.polozka=k.ID;
  commit;

--data
 prompt "insert data"; 
  insert into katalog (nazev,cena) values ('Svíèková' , 130 );
  insert into katalog (nazev,cena) values ('Rajská' , 120 );
  insert into katalog (nazev,cena) values ('Frankfurtská' , 105 );
  select * from katalog;
  
  insert into stul (nazev) values ('Salonek 1'); 
  insert into stul (nazev) values ('Salonek 2'); 
  insert into stul (nazev) values ('Salonek 3'); 
  insert into stul (nazev) values ('Bar 1'); 
  insert into stul (nazev) values ('Bar 2'); 
  select * from stul;
  
  select * from objednavka;
  insert into objednavka (stul, polozka) values (1,1);
  insert into objednavka (stul, polozka) values (1,2);
  insert into objednavka (stul, polozka) values (2,2);
  insert into objednavka (stul, polozka) values (3,3);
  insert into objednavka (stul, polozka) values (3,2);
  commit;

  set linesize 200;
  select * from aktualni_objednavky;
  
  commit;
  spool off