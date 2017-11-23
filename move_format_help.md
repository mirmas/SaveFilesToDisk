<b>Format:<b><br/>
database directory#source filename#regexp_pattern#regexp_replace#Overwrite old file(Y/N)#Binary or text move(B/T)#Charset#plsql block<br/>
database directory#source filename#regexp_pattern#regexp_replace#Overwrite old file(Y/N)#Binary or text move(B/T)#Charset#plsql block<br/>
....<br/>

<b>database directory:</b> Database directory where you want to move uploaded file. Cannot be empty! 
Owner of SaveToDisk(WithLog) function needs read, write privileges on each database directory. (e.g. grant READ, WRITE on directory "DIR" to &lt;schema&gt;);

<b>source filename:</b> Source filename. Star wildcard can be used. If empty, all uploaded files will be moved to Database directory defined before. 

<b>regexp_pattern:</b> If empty, destination filename is equal to source name. 
If not empty, source filename is equal to regexp_replace(source_filename, regexp_pattern, regexp_replace).

<b>regexp_replace:</b> See previous line. Can be empty. See docs of regexp_replace built in function.

<b>Overwrite old file:</b> If choose Y old file will be overwritten. If choose N old file [filename].[extension] will be renamed to [filename]_[to_char(systimestamp, 'YYYY-MM-DD-HH24-mi-ss-ff')].[extension].<br/>
E.g. Let's say you want to save file test.txt. On server disk already exists files test.txt.
Old file test.txt will be renamed to something like test_2017-11-07-13-59-40-556247.txt and new file test.txt will be created. If empty, then Y (overwrite) is assumed.

<b>Binary or text move:</b> With text move, line breaks are replaced with line break defined in "Destination Linebreak" plugin attribute. If empty, then B (binary) is assumed.  

<b>Charset:</b> Oracle parameter of NLS_CHARSET_ID function. If empty UTF8 is used. Examples of valid values: UTF8, EE8MSWIN1250. It's only applicable when text move is used.

<b>plsql block:</b> PLSQL block to execute after file move. Can be empty.

<b>EXAMPLES:</b>

<b>ex1:</b><br/>
MY_ORA_DIR

All uploaded files will be binary moved to MY_ORA_DIR with the same filenames.

<b>ex2:</b><br/>
MY_ORA_TXT_DIR#*.txt###N#T#EE8MSWIN1250
MY_ORA_BIN_DIR

All *.txt files will be text (linebreaks could be replaced with linebreak defined in Linebreak plugin attribute) moved to MY_ORA_TXT_DIR with the same filename. 
Possible old files won't be overwritten just renamed. It's expected that all *.txt files are win-1250 encoded. 
The rest of files will be binary moved to MY_ORA_BIN_DIR directory.

<b>ex3:</b><br/>
DIR1#TEST1*###Y#T##pak_my_package.DoSomething('abc')
DIR2#ORIG_TEST*#ORIG_##Y#T##pak_my_package.DosomethingNew
DIR3

This is more complex example.
All files started with TEST1 will be text moved to DIR1 directory. Procedure pak_my_package.DoSomething('abc') will be executed after move.
All files started with ORIG_TEST will be text moved to DIR2 directory. Also, files will be renamed from ORIG_TEST* to TEST*. More exactly function
destination filename := regexp_replace(source filename, 'ORIG_')
is executed before moving.
Procedure pak_my_package.DoSomethingNew will be executed after move.
The rest of files will be binary moved to DIR3 directory.

