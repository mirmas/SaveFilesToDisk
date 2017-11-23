# SaveFilesToDisk
Oracle APEX plugin that saves files uploaded with file browse item to disk

<b>PLUGIN INSTALLATION</b>

First your DBA should grant:<br/>
grant EXECUTE on "SYS"."UTL_FILE" to &lt;schema&gt;;<br/>
grant EXECUTE on "SYS"."DBMS_CRYPTO" to &lt;schema&gt;;<br/>
Next you need to create SaveToDisk and optionally SaveToDiskWithLog function (*.fnc create scripts) to some schema available to APEX workspace. Most usually this would-be APEX parsing schema.<br/> 
We reference this schema as &lt;schema&gt;.<br/>
Prerequisite for creating SaveToDiskWithLog is installed Logger (https://github.com/OraOpenSource/Logger) on &lt;schema&gt;.<br/><br/>
Import plugin to your app. Execution Function Name is by default #OWNER#.SaveToDisk. If &lt;schema&gt; is not APEX parsing schema change it to &lt;schema&gt;.SaveToDisk. If you want to use extensive login with Logger (https://github.com/OraOpenSource/Logger) change it to #OWNER#.SaveToDiskWithLog or &lt;schema&gt;.SaveToDiskWithLog.
  
<b>PLUGIN USE</b>

Create File Browse page item on APEX app page and choose APEX_APPLICATION_TEMP_FILES for storage.</br>
Create page process of type plugin.</br>
Choose process Point: On Submit - After Computations and Validations (default).

<b>File Browse Item:</b> Name of File Browse item (e.g. P1_UPLOAD) which holds filenames of uploaded files. Storage must be APEX_APPLICATION_TEMP_FILES table. Plugin move files from APEX_APPLICATION_TEMP_FILES table to server disk.

<b>Destination Linebreak:</b> Line break in text files after text move. Can be CR LF (Windows) or LF (Linux, MAC) 

<b>Max Filesize:</b> Maximum allowed size in bytes. Abbreviations K,KB,M,MB,G,GB are allowed. Examples of valid formats: 100000, 150 K, 3,76 M, 1,5 GB, 1.5G.

<b>Move format:</b></br>
database directory#source filename#regexp_pattern#regexp_replace#Overwrite old file(Y/N)#Binary or text move(B/T)#Charset#plsqlblock</br>
database directory#source filename#regexp_pattern#regexp_replace#Overwrite old file(Y/N)#Binary or text move(B/T)#Charset#plsqlblock</br>
....</br>
User &lt;schema&gt; needs read, write privileges on each database directory. (e.g. grant READ, WRITE on directory "DIR" to &lt;schema&gt;);<br/> 
See Move format plugin attribute help or move_format_help.md for more info.

<b>Item with Filenames:</b> Select page item which will save filenames of uploaded files separated with colon. Usually you want to use this item value in process after SaveFilesToDisk process.

<b>Item with Hash values:</b> Select page item to store Hash values of type RAW separated with colon. This is useful when you want to track files changes.

<b>Text area item with log:</b> Select item which will hold plugin log. Display Only or read only Text Area is usual choice. It's highly recommended to display plugin log if you have multiple files and/or complex move format.

<b>Conditions:</b> Select Condition Type "Value of Item/Column in Expression Is NOT NULL" and for Expression1 set the same File Browse item you set at Plug-in settings (e.g. P1_UPLOAD). This step is optional. 

For the rest you can left defaults.
  
<b>SAMPLE APPLICATION</b>

<b>Please note there is no demo at apex.oracle.com. Obvious reason is you need access to server file system to make the plugin works.</b><br/> 
Install sample application f102.sql, change SaveToDiskMulti plugin process attribute "Move Format" to suit your configuration. You can change also "Destination Linebreak" and "Max Filesize" attributes. Similarly change SaveToDisk plugin process attribute Database directory and possibly "Filename" and "Max Filesize".

