#!/bin/ksh

TABLE=$1
sqlplus -s SYSADM/Sabbath#2014@bscs62p1 << EOF

--REGRA INTERNACIONAL
 
DECLARE
BEGIN

update $TABLE set linha = replace(linha,'  10  ','  0010') where linha like '1000%  10  %';

update $TABLE set linha = replace(linha,'202ASDASSINATURA DADOS','302ASDASSINATURA DADOS') ;

update $TABLE set linha = replace(linha,'301ASVASSINATURA VOZ           ','301PLVPLANO VOZ                ');

update $TABLE set linha = replace(linha,'302ASDASSINATURA DADOS         ','302PLDPLANO DADOS              ');

update $TABLE set linha = replace(linha,'000000000000000000000000MN302PLDPLANO DADOS','000000000000000000000000MB302PLDPLANO DADOS') ;

update $TABLE set linha = replace(linha,'301PLVASSINATURA VOZ           ','301PLVPLANO VOZ                ');

update $TABLE set linha = replace(linha,'301PLVASSINATURA VOZ           ','301PLVPLANO VOZ                ');
update $TABLE set linha = replace(linha,'301PLVASSINATURA VOZ           ','301PLVPLANO VOZ                ');update $TABLE set linha = replace(linha,'301PLVASSINATURA VOZ           ','301PLVPLANO VOZ                ');
update $TABLE set linha = replace(linha,'301PLVASSINATURA VOZ           ','301PLVPLANO VOZ                ');



update $TABLE set linha = replace(linha,'301PLDASSINATURA VOZ           ','302PLDPLANO DADOS              ');


   FOR rec
      IN 
      (
      SELECT /*+parallel(acc,4)*/
                rowid as row_id, acc.*
            FROM $TABLE acc
           WHERE (UPPER (linha) LIKE '%LDNLD NACIONAL ON NET%'
               OR  UPPER (linha) LIKE '%LOCLOCAL ON NET%')
             AND SUBSTR (acc.linha, 140, 2) = '00'
             )
   LOOP
      UPDATE /*+parallel (acc2,4) */
            $TABLE acc2
         SET linha        =
                REPLACE (
                   REPLACE (linha,
                            'LOCLOCAL ON NET             ',
                            'LDILD Internacional         '),
                   'LDNLD NACIONAL ON NET       ',
                   'LDILD Internacional         ')
       WHERE rowid = rec.row_id;
   END LOOP;

 
--REGRA 55
 --    011965774917 
 --    556131017410 
 --    6131017410   

   FOR rec
      IN (
      SELECT /*+parallel(acc,4)*/
                SUBSTR (acc.linha, 140, 2) v_internacional,
                SUBSTR (acc.linha, 160 ,17) v_numero,replace(SUBSTR (acc.linha, 160 ,17),'  55','  ') || '  ' v_numero_2 , rowid as row_id, acc.*
            FROM $TABLE acc
           WHERE  
             SUBSTR (acc.linha, 140, 2) <> '00'
             and (acc.linha like '30%')
             and length(trim(SUBSTR (acc.linha, 160 ,17))) > 11
             and acc.linha not like '%DESLOCAMENTO%' and trim(SUBSTR (acc.linha, 160 ,17)) like '55%'
      )
   LOOP
      UPDATE /*+parallel (acc2,4) */
            $TABLE acc2
         SET linha        =
                REPLACE (linha, rec.v_numero, rec.v_numero_2 )
       WHERE rowid = rec.row_id;
   END LOOP;



--REGRA 0

   FOR rec
      IN (
      SELECT /*+parallel(acc,4)*/
                SUBSTR (acc.linha, 108, 2) v_internacional,
                SUBSTR (acc.linha, 110 ,17) v_numero,
                regexp_replace(SUBSTR (acc.linha, 110 ,17), '^0*')||' ' v_numero_2,
                 rowid as row_id, acc.*
            FROM $TABLE acc
           WHERE  
             SUBSTR (acc.linha, 108, 2) <> '00'
             and (acc.linha like '40%')
                and trim(SUBSTR (acc.linha, 110 ,17)) like '0%'
      )
   LOOP
      UPDATE /*+parallel (acc2,4) */
            $TABLE acc2
         SET linha        =
                REPLACE (linha, rec.v_numero, rec.v_numero_2 )
       WHERE rowid = rec.row_id;
   END LOOP;

  


   FOR rec
      IN (
             SELECT /*+parallel(acc,4)*/
                SUBSTR (acc.linha, 140, 2),
                SUBSTR (acc.linha, 164 ,17) v_numero, rowid as row_id, 
                regexp_replace(SUBSTR (acc.linha, 164 ,17), '^0*')||' ' v_numero_2,acc.*
            FROM $TABLE acc
           WHERE  
             SUBSTR (acc.linha, 140, 2) <> '00'
             and (acc.linha like '30%')
             and trim(SUBSTR (acc.linha, 160 ,17)) like '0%'
             and trim(SUBSTR (acc.linha, 160 ,17)) not like '0300%'
             and trim(SUBSTR (acc.linha, 160 ,17)) not like '0500%'
             and trim(SUBSTR (acc.linha, 160 ,17)) not like '0800%' and acc.linha not like '%DESLOCAMENTO%'
      )
   LOOP
      UPDATE /*+parallel (acc2,4) */
            $TABLE acc2
         SET linha        =
                REPLACE (linha, rec.v_numero, rec.v_numero_2 )
       WHERE rowid = rec.row_id;
   END LOOP;

 
   FOR rec
      IN (
                             SELECT /*+parallel(acc,4)*/
                SUBSTR (acc.linha, 79, 16),
                SUBSTR (acc.linha, 79 ,16) v_numero, rowid as row_id, 
                regexp_replace(SUBSTR (acc.linha, 79 ,16), '^0*')||' ' v_numero_2,acc.*
            FROM $TABLE acc
           WHERE  
              (acc.linha like '60%')
              and SUBSTR (acc.linha, 79, 16) like '0%'
      )
   LOOP
      UPDATE /*+parallel (acc2,4) */
            $TABLE acc2
         SET linha        =
                REPLACE (linha, rec.v_numero, rec.v_numero_2 )
       WHERE rowid = rec.row_id;
   END LOOP;
 
--REGRA VC2
 

   FOR rec
      IN (SELECT /*+parallel(acc,4)*/
                rowid as row_id, acc.*
            FROM $TABLE acc
           WHERE UPPER (linha) LIKE '%LDNLD NACIONAL ON NET%'
             AND SUBSTR (TRIM (LEADING '0' FROM SUBSTR (acc.linha, 164, 17)),
                         1,
                         1) =
                    SUBSTR (
                       TRIM (LEADING '0' FROM SUBSTR (acc.linha, 79, 5)),
                       1,
                       1)
             AND SUBSTR (TRIM (LEADING '0' FROM SUBSTR (acc.linha, 164, 17)),
                         2,
                         1) !=
                    SUBSTR (
                       TRIM (LEADING '0' FROM SUBSTR (acc.linha, 79, 5)),
                       2,
                       1))
   LOOP
      UPDATE /*+parallel (acc2,4) */
            $TABLE acc2
         SET linha        =
                REPLACE (linha,
                         'LDNLD NACIONAL ON NET       ',
                         'VC2MOVEL DENTRO DA AREA ON N')
       WHERE rowid = rec.row_id;
   END LOOP;

 
 
 
--REGRA VC3
 

   FOR rec
      IN (SELECT /*+parallel(acc,4)*/
                rowid as row_id, acc.*
            FROM $TABLE acc
           WHERE UPPER (linha) LIKE '%LDNLD NACIONAL ON NET%'
             AND SUBSTR (TRIM (LEADING '0' FROM SUBSTR (acc.linha, 164, 17)),
                         1,
                         1) !=
                    SUBSTR (
                       TRIM (LEADING '0' FROM SUBSTR (acc.linha, 79, 5)),
                       1,
                       1))
   LOOP
      UPDATE /*+parallel (acc2,4) */
            $TABLE acc2
         SET linha        =
                REPLACE (linha,
                         'LDNLD NACIONAL ON NET       ',
                         'VC3MOVEL FORA DA AREA ON NET')
       WHERE rowid = rec.row_id;
   END LOOP;

 
 
 
 
--REGRA VC1ON
 

   UPDATE /*+parallel (acc2,4) */
         $TABLE acc2
      SET linha        =
             REPLACE (linha,
                      'LOCLOCAL ON NET             ',
                      'VC1MOVEL LOCAL ON NET       ')
    WHERE linha LIKE '%LOCLOCAL ON NET%';

 
 
 
 
--REGRA VC1OFF
 

   UPDATE /*+parallel (acc2,4) */
         $TABLE acc2
      SET linha        =
             REPLACE (linha,
                      'LOCLOCAL OFF NET            ',
                      'VC1MOVEL LOCAL OFF NET      ')
    WHERE linha LIKE '%LOCLOCAL OFF NET%';


commit;
end;


/
EOF


