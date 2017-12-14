SAS Forum: Dosubl Macros to select Max Value of a column at datastep execution time

see
https://goo.gl/ornVo2
https://communities.sas.com/t5/Base-SAS-Programming/Help-getting-the-Max-Value-from-a-table/m-p/421253

Academic exercise (there are many other ways to do this. ie FCMP/ DOW loop)
Note DOSUBL is inherently more powerful because DOSUBL allows proc SQL, datasteps and procs can be executed.
FCMP basically only allows datastep code.


Three solutions

    1. Common storage
    2. Shared macro variables
    3. compilation time if _n_=0

Problem: How much taller is the tallest student than I.

INPUT
=====


 WORK.WANT            |        RULES
                      |
                      |   HEIGHT_ INCHES_
   NAME       HEIGHT  |    MAX    TALLER
                      |
   Philip      72.0   |     72     0.0      * 72 - 72   = 0
                      |
   Alfred      69.0   |     72     3.0      * 72 -   69 = 3
   Alice       56.5   |     72    15.5      * 72 - 56.5 = 3
   Barbara     65.3   |     72     6.7
   Carol       62.8   |     72     9.2
   Henry       63.5   |     72     8.5
   James       57.3   |     72    14.7
   Jane        59.8   |     72    12.2
   Janet       62.5   |     72     9.5
   Jeffrey     62.5   |     72     9.5
   John        59.0   |     72    13.0
   Joyce       51.3   |     72    20.7
   Judy        64.3   |     72     7.7
   Louise      56.3   |     72    15.7
   Mary        66.5   |     72     5.5
   Robert      64.8   |     72     7.2
   Ronald      67.0   |     72     5.0
   Thomas      57.5   |     72    14.5
   William     66.5   |     72     5.5


WORKING CODE
============

  1. Shared storage;

     data want;

        %common(height_max);

        set sashelp.class(keep=name height);
        %height_max;

        inches_taller=height_max-height;
        keep name height height_max inches_taller;

     run;quit;

  2. Shared macro variables

     data want;

        set sashelp.class(keep=name height);
        %height_max;
        height_max=symget('height_max');

        inches_taller=height_max-height;
        keep name height height_max inches_taller;

     run;quit;

   3. Compile time

     data want;

        If _n_=0 then do;
            %height_max;
        end;

        set sashelp.class(keep=name height);
        height_max=symget('height_max');

        inches_taller=height_max-height;
        keep name height height_max inches_taller;

     run;quit;

OUTPUT
======

  WORK.WANT total obs=19

                                 HEIGHT_  INCHES_
   Obs      NAME       HEIGHT       MAX   TALLER

    15      Philip      72.0        72      0.0

     1      Alfred      69.0        72      3.0
     2      Alice       56.5        72     15.5
     3      Barbara     65.3        72      6.7
     4      Carol       62.8        72      9.2
     5      Henry       63.5        72      8.5
     6      James       57.3        72     14.7
     7      Jane        59.8        72     12.2
     8      Janet       62.5        72      9.5
     9      Jeffrey     62.5        72      9.5
    10      John        59.0        72     13.0
    11      Joyce       51.3        72     20.7
    12      Judy        64.3        72      7.7
    13      Louise      56.3        72     15.7
    14      Mary        66.5        72      5.5

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

 use sashelp.class


*    _                        _       _
 ___| |__   __ _ _ __ ___  __| |  ___| |_ ___  _ __ __ _  __ _  ___
/ __| '_ \ / _` | '__/ _ \/ _` | / __| __/ _ \| '__/ _` |/ _` |/ _ \
\__ \ | | | (_| | | |  __/ (_| | \__ \ || (_) | | | (_| | (_| |  __/
|___/_| |_|\__,_|_|  \___|\__,_| |___/\__\___/|_|  \__,_|\__, |\___|
                                                         |___/
;

%macro height_max;
   if _n_=1 then do;
     rc=dosubl('
      data _null_;
         retain height_max .;
         length adAry $40;
         do until (dne);
            set sashelp.class end=dne;
            if height > height_max then height_max=height;
         end;
         adAry = input(symget("adAry"),$hex40.);
         call pokelong(put(height_max,rb8.),adAry,8,1);
      run;quit;
     ');
   end;
%mend height_max;


%macro common(height_max);
   retain height_max .;
   adAry=put(addrlong(height_max),$hex40.);
   call symputx('adAry',adAry,"G");
%mend common;

data want;
   %common(height_max);

   set sashelp.class(keep=name height);
   %height_max;

   inches_taller=height_max-height;
   keep name height height_max inches_taller;

run;quit;

*    _                        _
 ___| |__   __ _ _ __ ___  __| |  _ __ ___   __ _  ___ _ __ ___  ___
/ __| '_ \ / _` | '__/ _ \/ _` | | '_ ` _ \ / _` |/ __| '__/ _ \/ __|
\__ \ | | | (_| | | |  __/ (_| | | | | | | | (_| | (__| | | (_) \__ \
|___/_| |_|\__,_|_|  \___|\__,_| |_| |_| |_|\__,_|\___|_|  \___/|___/

;

* SAS 9.4M3 or later;
%macro height_max;
  if _n_=1 then do;
    rc=dosubl('
      proc sql;
         select max(height) into :height_max trimmed
         from sashelp.class
      ;quit;
    ');
  end;
%mend height_max;

data want;

   set sashelp.class(keep=name height);
   %height_max;
   height_max=symgetn('height_max');

   inches_taller=height_max-height;
   keep name height height_max inches_taller;

run;quit;

*                          _ _        _   _
  ___ ___  _ __ ___  _ __ (_) | ___  | |_(_)_ __ ___   ___
 / __/ _ \| '_ ` _ \| '_ \| | |/ _ \ | __| | '_ ` _ \ / _ \
| (_| (_) | | | | | | |_) | | |  __/ | |_| | | | | | |  __/
 \___\___/|_| |_| |_| .__/|_|_|\___|  \__|_|_| |_| |_|\___|
                    |_|
;

%macro height_max;
  if _n_=1 then do;
    rc=dosubl('
      proc sql;
         select max(height) into :height_max trimmed
         from sashelp.class
      ;quit;
    ');
  end;
%mend height_max;

data want;

   If _n_=0 then do;
       %height_max;
   end;

   set sashelp.class(keep=name height);
   height_max=symgetn('height_max');

   inches_taller=height_max-height;
   keep name height height_max inches_taller;

run;quit;


