# SaveFilesToDisk
Oracle APEX plugin that saves files uploaded with file browse item to disk

PLUGIN INSTALLATION

First your DBA should grant:grant EXECUTE on "SYS"."UTL_FILE" to <schema>;grant EXECUTE on "SYS"."DBMS_CRYPTO" to <schema>;Next you need to create SaveToDisk and optionally SaveToDiskWithLog function (*.fnc create scripts) to some schema available to APEX workspace. Most usually this would-be APEX parsing schema. We reference this schema as <schema>.Prerequisite for creating SaveToDiskWithLog is installed Logger (https://github.com/OraOpenSource/Logger) on <schema>.
Import plugin to your app. Execution Function Name is by default #OWNER#.SaveToDisk. If <schema> is not APEX parsing schema change it to <schema>.SaveToDisk.If you want to use extensive login with Logger (https://github.com/OraOpenSource/Logger) change it to #OWNER#.SaveToDiskWithLog or <schema>.SaveToDiskWithLog.
  
PLUGIN USE

Create File Browse page item on APEX app page and choose APEX_APPLICATION_TEMP_FILES for storage.Create page process of type plugin.Choose process Point: On Submit - After Computations and Validations (default)
File Browse Item: Name of File Browse item (e.g. P1_UPLOAD) which holds filenames of uploaded files. Storage must be APEX_APPLICATION_TEMP_FILES table. Plugin move files from APEX_APPLICATION_TEMP_FILES table to server disk.
Destination Linebreak: Line break in text files after text move. Can be CR LF (Windows) or LF (Linux, MAC) 
Max Filesize: Maximum allowed size in bytes. Abbreviations K,KB,M,MB,G,GB are allowed. Examples of valid formats: 100000, 150 K, 3,76 M, 1,5 GB, 1.5G.
Move format:database directory#source filename#regexp_pattern#regexp_replace#Overwrite old file(Y/N)#Binary or text move(B/T)#Charset#plsql blockdatabase directory#source filename#regexp_pattern#regexp_replace#Overwrite old file(Y/N)#Binary or text move(B/T)#Charset#plsql block....User <schema> needs read, write privileges on each database directory. (e.g. grant READ, WRITE on directory "DIR" to <schema>);See Move format plugin attribute help or move_format_help.txt for more info.
Item with Filenames: Select page item which will save filename(s) of uploaded file(s) separated with colon. Usually you want to use this item value in process after SaveToDisk process.
Item with Hash values: Select page item to store Hash value(s) of type RAW separated with colon. This is useful when you want to track file(s) changes.
Text area item with log: Select item which will hold plugin log. Display Only or read only Text Area is usual choice. It's highly recommended to display plugin log if you have multiple files and/or complex move format.
Conditions: Select Condition Type "Value of Item/Column in Expression Is NOT NULL" and for Expression1 set the same File Browse item you set at Plug-in settings (e.g. P1_UPLOAD). This step is optional. 
For the rest you can left defaults.
  
SAMPLE APPLICATION

Install sample application f102.sql, change SaveToDiskMulti plugin process attribute "Move Format" to suit your configuration. You can change also "Destination Linebreak" and "Max Filesize" attributes.Similarly change SaveToDisk plugin process attribute Database directory and possibly "Filename" and "Max Filesize".

