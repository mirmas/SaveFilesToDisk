set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_release=>'5.1.3.00.05'
,p_default_workspace_id=>38413852719975596423
,p_default_application_id=>60886
,p_default_owner=>'ICJT'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/process_type/is_mirmas_savefilestodisk
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(37002609176027578397)
,p_plugin_type=>'PROCESS TYPE'
,p_name=>'IS.MIRMAS.SAVEFILESTODISK'
,p_display_name=>'SaveFilesToDisk'
,p_supported_ui_types=>'DESKTOP'
,p_api_version=>2
,p_execution_function=>'#OWNER#.SaveToDisk'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'This process plugin moves files (BLOBs in fact) from APEX_APPLICATION_TEMP_FILES table to files on server file system. Plugin deletes rows from APEX_APPLICATION_TEMP_FILES. ',
'This way you can save files to server file system rather than into table.',
'',
'Plugin can be useful when you want to save DB space (e.g. Oracle XE) or when you deal with Oracle COM automation feature. ',
'',
'To use this process plugin you must have at least APEX 5.1 and File Browse item on page with chosen APEX_APPLICATION_TEMP_FILES storage. ',
'You define destination for file (directory and filename) and maximum allowed file size. ',
'On submit plugin moves files (BLOB in fact) from APEX_APPLICATION_TEMP_FILES table to files on server file system. ',
'After move plugin delete row from APEX_APPLICATION_TEMP_FILES and then commits. ',
'',
'Custom attributes of this plugin are:',
'Name of File Browse item',
'Linebreak: Destination line break. Can be CR LF (Windows) or LF (non Windows) ',
'Maximum allowed file size,',
'Item with Filenames,',
'Item with hashes of uploaded files.',
'Move format: String defining files move. See help for this plugin parameter form more details.',
'Binary or text move,',
'',
'With this process plugin you can upload files "directly" to server file system.',
'',
'Special Requirements',
' Schema with SaveToDisk (usually workspace parsing schema) function must have privilege to UTL_FILE and DBMS_CRYPTO package and read/write privilege to destination folders.'))
,p_version_identifier=>'1.0'
,p_about_url=>'www.mirmas.si'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37002609655287601339)
,p_plugin_id=>wwv_flow_api.id(37002609176027578397)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'File Browse Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'P1_UPLOAD'
,p_help_text=>'Name of File Browse item (e.g. P1_UPLOAD) which holds uploaded files. Storage must be APEX_APPLICATION_TEMP_FILES table.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37002609976303610321)
,p_plugin_id=>wwv_flow_api.id(37002609176027578397)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Destination Linebreak'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'LF'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Line break in text files after text move. Can be CR LF (Windows) or LF (Linux, MAC).'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37002610258553614458)
,p_plugin_attribute_id=>wwv_flow_api.id(37002609976303610321)
,p_display_sequence=>10
,p_display_value=>'Windows (CR LF)'
,p_return_value=>'CR LF'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37002610629938617494)
,p_plugin_attribute_id=>wwv_flow_api.id(37002609976303610321)
,p_display_sequence=>20
,p_display_value=>'Linux Mac (LF)'
,p_return_value=>'LF'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37002611473562678671)
,p_plugin_id=>wwv_flow_api.id(37002609176027578397)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Max Filesize'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>20
,p_is_translatable=>false
,p_examples=>'Examples of valid formats: 100000, 150 K, 3,76 M, 1,5 GB, 1.5G.'
,p_help_text=>'Maximum allowed size in bytes. Abrreviations K,KB,M,MB,G,GB are allowed.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37002611705737807664)
,p_plugin_id=>wwv_flow_api.id(37002609176027578397)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Move format'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'All uploaded files will be binary moved to MY_ORA_DIR with the same filename:<br>',
'<br>',
'MY_ORA_DIR<br>',
'<br>',
'All *.txt files will be text (linebreaks could be replaced with linebreak defined in Linebreak plugin attribute) moved to MY_ORA_TXT_DIR with the same filename. ',
'Possible old files won''t be overwritten just renamed. It''s expected that all *.txt files are win-1250 encoded.<br> ',
'The rest of files will be binary moved to MY_ORA_BIN_DIR directory:<br>',
'<br>',
'MY_ORA_TXT_DIR#*.txt###N#T#EE8MSWIN1250<br>',
'MY_ORA_BIN_DIR<br>',
'<br>',
'More complex example:<br>',
'All files started with TEST1 will be text moved to DIR1 directory. Procedure pak_my_package.DoSomething(''abc'') will be executed after move.<br>',
'All files started with ORIG_TEST will be text moved to DIR2 directory. Also files will be renamed from ORIG_TEST* to TEST*. More exactly function<br>',
'destination filename := regexp_replace(source filename, ''ORIG_'')<br>',
'is executed before move.<br>',
'Procedure pak_my_package.DoSomethingNew will be executed after move.<br>',
'The rest of files will be binary moved to DIR3 directory:<br>',
'<br>',
'DIR1#TEST1*###Y#T##pak_my_package.DoSomething(''abc'')<br>',
'DIR2#ORIG_TEST*#ORIG_##Y#T##pak_my_package.DosomethingNew<br>',
'DIR3<br>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Format:<br>',
'database directory#source filename#regexp_pattern#regexp_replace#Overwrite old file(Y/N)#Binary or text move(B/T)#Charset#plsql block<br>',
'database directory#source filename#regexp_pattern#regexp_replace#Overwrite old file(Y/N)#Binary or text move(B/T)#Charset#plsql block<br>',
'....<br>',
'<br>',
'<b>database directory:</b> Database directory where you want to move uploaded file. Cannot be empty! Owner of SaveToDisk(WithLog) function needs read, write privileges on each database directory. (e.g. grant READ, WRITE on directory "DIR" to <schema>'
||');<br>',
'<b>source filename:</b> Source filename. Star Wildcard can be used. If empty, all uploaded files will be moved to Database directory defined before .<br> ',
'<b>regexp_pattern:</b> If empty, destination filename is equal to source name. ',
'If not empty, source filename is equal to regexp_replace(source_filename, regexp_pattern, regexp_replace).<br>',
'<b>regexp_replace:</b> See previous line. Can be empty. See docs of regexp_replace built in function.<br>',
'<b>Overwrite old file:</b> If choose Y old file will be overwrited. If choose N old file [filename].[extension] will be renamed to [filename]_[to_char(systimestamp, ''YYYY-MM-DD-HH24-mi-ss-ff'')].[extension].',
'E.g. Let''s say you want to save file test.txt. On server disk already exists files test.txt.',
'Old file test.txt will be renamed to something like test_2017-11-07-13-59-40-556247.txt and new file test.txt will be created. If empty then Y (overwrite) is assumed.<br>',
'<b>Binary or text move:</b> With text move, line breaks are replaced with line break defined in "Destination Linebreak" plugin attribute.<br>  ',
'<b>Charset:</b> Oracle parameter of NLS_CHARSET_ID function. If empty UTF8 is used. Examples of valid values: UTF8, EE8MSWIN1250. It''s only apliable when text move is used.<br>',
'<b>plsql block:</b> PLSQL block to execute after file move.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37002611988049821939)
,p_plugin_id=>wwv_flow_api.id(37002609176027578397)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Item with Filenames'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Select page item which will save filename(s) of uploaded file(s) separated with colon. ',
'Usually you want to use this item value in process after SaveToDisk process.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37002612351153825656)
,p_plugin_id=>wwv_flow_api.id(37002609176027578397)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Item with Hash values'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Select page item to store Hash value(s) of type RAW separated with colon. This is useful when you want to track file(s) changes.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37002628263163219185)
,p_plugin_id=>wwv_flow_api.id(37002609176027578397)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Text area item with log'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Select item which will hold plugin log. Display Only or read only Text Area is usual choice. It''s highly recommended to display plugin log if you have multiple files and/or complex move format.'
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
