CREATE OR REPLACE FUNCTION BK_APEX_MANUAL_CMS.SaveToDisk(
    p_process in apex_plugin.t_process,
    p_plugin  in apex_plugin.t_plugin )
    return apex_plugin.t_process_exec_result 
  AS
  TYPE StringMatrix IS VARRAY(100) OF APEX_APPLICATION_GLOBAL.vc_arr2;
  gc_scope_prefix CONSTANT VARCHAR2(100) := 'SaveToDisk';
  l_blob BLOB;
  l_filebrowse varchar2(32767);
  l_filebrowse_ok number default 0;
  l_dbdirectory varchar2(1000);
  l_file_names APEX_APPLICATION_GLOBAL.vc_arr2;
  l_filename varchar2(1000);
  l_filename_orig varchar2(1000);
  l_linebreak varchar2(5);
  l_move_format_matrix StringMatrix;
  l_overwrite boolean;
  l_binary boolean;
  l_binary_text varchar2(100);
  l_regexp_pattern varchar2(1000);
  l_regexp_replace varchar2(1000); 
  l_max_file_size integer;
  l_doc_size integer;
  l_filename_item varchar2(100);
  l_hash_item varchar2(100);
  l_plugin_log_item varchar2(100);
  l_charset varchar2(100);
  l_hashes varchar2(32767);
  l_filenames varchar2(32767);
  l_plugin_log varchar2(32767);
  l_plsql_command varchar2(4000);
  l_plsql_command_text varchar2(4000);
  l_file_moved boolean := false;
  l_ret apex_plugin.t_process_exec_result; 
  
  function AddTimeStampToFilename(P_FILENAME VARCHAR2)
  return varchar2
  AS
  l_ret varchar2(4000);
  l_string VARCHAR2(100) := to_char(systimestamp, 'YYYY-MM-DD-HH24-mi-ss-ff');
  BEGIN  
    if INSTR(P_FILENAME, '.') > 0 then
        l_ret := SUBSTR(P_FILENAME, 1, INSTR(P_FILENAME, '.', -1, 1)-1)|| 
        '_'||l_string|| 
        SUBSTR(P_FILENAME, INSTR(P_FILENAME, '.', -1, 1));
    else
        l_ret := P_FILENAME||'_'||l_string;
    end if; 
    return l_ret;
  exception    
    when others then  
    --log error
    raise;                           
  END AddTimeStampToFilename;
  
  /** Converts whole BLOB to CLOB 
  * 
  * @param p_blob BLOB to convert 
  * @param p_file_charset BLOB charset. Use Oracle format. E.g 'EEMSWIN1250' instead of 'windows-1250' 
  * @return CLOB 
  */ 
    function BLOB2CLOB 
    ( 
      p_blob  BLOB 
      ,p_clob_csid number default NLS_CHARSET_ID('UTF8') 
    ) return CLOB 
    as 
     
    l_length NUMBER; 
    l_Clob CLOB; 
    l_warning NUMBER; 
    l_lang_context number default 0; 
    l_src_offset number default 1; 
    l_dest_offset number default 1; 
     
    begin 
      --convert blob to clob 
      dbms_lob.createtemporary(l_Clob, false); 
     
      DBMS_LOB.CONVERTTOCLOB( 
       l_Clob, 
       p_Blob, 
       DBMS_LOB.LOBMAXSIZE, 
       l_dest_offset, 
       l_src_offset, 
       nvl(p_clob_csid, NLS_CHARSET_ID('UTF8')), 
       l_lang_context, 
       l_warning 
      ); 
     
      return l_Clob; 
     
    exception 
      when others then 
      --log error
      raise; 
end BLOB2CLOB; 

/** Converts whole CLOB to BLOB 
  * 
  * @param p_clob CLOB to convert 
  * @param p_file_charset CLOB charset 
  * @return CLOB 
  */ 
function CLOB2BLOB 
( 
  p_clob  CLOB, 
  p_clob_csid number default NLS_CHARSET_ID('UTF8') 
) return BLOB 
as 
 
l_blob BLOB; 
l_warning NUMBER; 
l_lang_context number default 0; 
l_src_offset number default 1; 
l_dest_offset number default 1; 
 
begin 
  DBMS_LOB.CREATETEMPORARY(l_blob, true); 
 
  DBMS_LOB.OPEN (l_blob, DBMS_LOB.LOB_READWRITE); 
 
  DBMS_LOB.CONVERTTOBLOB( 
    l_blob, 
    p_clob, 
    DBMS_LOB.LOBMAXSIZE, 
    l_src_offset, 
    l_dest_offset, 
    nvl(p_clob_csid, NLS_CHARSET_ID('UTF8')), 
    l_lang_context, 
    l_warning 
  ); 
  return l_blob; 
 
exception 
  when others then 
  --log error
  raise; 
end CLOB2BLOB; 


  
  PROCEDURE Blob2File
  ( 
    P_DIRECTORY      IN VARCHAR2,
    P_FILENAME       IN VARCHAR2,  
    p_blob           IN BLOB, 
    p_overwrite      IN BOOLEAN,
    p_binary         IN BOOLEAN,
    p_linebreak      IN VARCHAR2,
    p_charset        IN VARCHAR2
  ) 
  IS
    c_amount         BINARY_INTEGER := 32767;
    l_buffer         RAW(32767);
    l_blobLen        PLS_INTEGER;
    l_fHandler       utl_file.file_type;
    l_pos            PLS_INTEGER    := 1;
    l_filename varchar2(200);
    l_exists boolean default true; 
    l_file_length number default 10;
    l_number number default 0;
    l_blocksize number;
    l_clob CLOB;
    l_blob BLOB;
    
  BEGIN
  
    
    if not p_overwrite then
      UTL_FILE.FGETATTR(
      P_DIRECTORY,
      P_FILENAME,
      l_exists, 
      l_file_length, 
      l_blocksize);
         
      if l_exists then 
         l_filename := AddTimeStampToFilename(p_filename);     
      
          --rename existing p_filename to l_filename
          UTL_FILE.FRENAME (P_DIRECTORY, P_FILENAME, P_DIRECTORY, L_FILENAME); 
      end if;
    end if;
    
    l_fHandler := UTL_FILE.FOPEN(P_DIRECTORY, P_FILENAME, 'wb', 32767);
    
    if p_binary then
        l_blob := p_blob;
    else
        l_clob := Blob2Clob(p_blob, NLS_CHARSET_ID(p_charset));
        if p_linebreak = 'LF' then
            l_clob := replace(l_clob, chr(13)||chr(10), chr(10));
        elsif p_linebreak = 'CR LF' and nvl(instr(l_clob, chr(13)||chr(10)), 0) = 0 then 
            l_clob := replace(l_clob, chr(10), chr(13)||chr(10));
        end if;
        l_blob := Clob2Blob(l_clob, NLS_CHARSET_ID(p_charset));
    end if;
    
    l_blobLen  := DBMS_LOB.GETLENGTH(l_blob);
    
    LOOP
      DBMS_LOB.READ(l_blob, c_amount, l_pos, l_buffer);     
      UTL_FILE.PUT_RAW(l_fHandler, l_buffer, true);
      l_pos := l_pos + c_amount;
    END LOOP;
  
    UTL_FILE.FCLOSE(l_fHandler);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    UTL_FILE.FCLOSE(l_fHandler);
    
  WHEN OTHERS THEN
    if utl_file.is_open(l_fHandler) then
      UTL_FILE.FCLOSE(l_fHandler);
    end if;
    
   --Log error
   raise; 
  END Blob2File;
  
  function FileSizeInBytes(p_filesize varchar2)
  return integer
  as
  l_filesize varchar2(20);
  l_faktor integer default 1;
  l_posK integer default 0;
  l_posM integer default 0;
  l_posG integer default 0;
  l_pos integer default 0;
  l_ret number;
  begin
    if p_filesize is null then return null; end if;
    
    l_filesize := replace(upper(substr(p_filesize,1,20)),'.',',');
    l_posK := instr(l_filesize,'K');
    l_posM := instr(l_filesize,'M');
    l_posG := instr(l_filesize,'G');
  
    l_pos := least   (case l_posK when 0 then 99 else l_posK end, 
                      case l_posM when 0 then 99 else l_posM end,  
                      case l_posG when 0 then 99 else l_posG end);
                      
    if l_pos = 99 then l_faktor := 1; 
    elsif l_pos = l_posK then l_faktor := 1024; 
    elsif l_pos = l_posM then l_faktor := 1024*1024; 
    elsif l_pos = l_posG then l_faktor := 1024*1024*1024; 
    end if;
    
    if l_pos > 0 then 
      l_ret := to_number(trim(substr(l_filesize, 1,l_pos-1)));
      l_ret := l_ret * l_faktor;
    else
      l_ret := to_number(l_filesize);
    end if;
    return trunc(l_ret);
    exception    
      when others then  
      --Error loging
       return null;
  end FileSizeInBytes;
  
  function GetStringMatrix(p_string varchar2, p_line_delimiter varchar2, p_col_delimiter varchar2, p_num_of_cols number)
  return StringMatrix
  as
  l_lines APEX_APPLICATION_GLOBAL.vc_arr2;
  l_cols APEX_APPLICATION_GLOBAL.vc_arr2;
  l_line varchar2(4000);
  l_ret StringMatrix := StringMatrix(); 
  begin
    l_lines := apex_util.string_to_table(p_string, p_line_delimiter);
    for i in 1..l_lines.count loop
        l_line := rtrim(l_lines(i), chr(13));
        l_cols := apex_util.string_to_table(l_line, p_col_delimiter);
        for j in l_cols.count+1..p_num_of_cols loop
            l_cols(j) := null;
        end loop;
        l_ret.extend(1);
        l_ret(i) := l_cols;
    end loop; 
    return l_ret;
  end;
  
  function PreparePlSql(p_plsql_command varchar2)
  return varchar2
  as
  l_ret varchar2(4000) := trim(p_plsql_command);
  begin
    if l_ret is not null then 
        if substr(lower(l_ret), 1,6) != 'begin ' then
            l_ret := 'BEGIN '||l_ret;
        end if;
        
        if substr(lower(l_ret), length(l_ret) - 5, 5) != ' end;' then
            l_ret := rtrim(l_ret,';')||'; END;';
        end if;
    end if;
    return l_ret;
  end;
  
  function FullPath(p_dbdirectory varchar2, p_filename varchar2)
  return varchar2
  as
  l_separator varchar2(1) := '/';
  l_ret varchar2(4000);
  begin
    select nvl(directory_path, p_dbdirectory)
    into  l_ret
    from all_directories where directory_name = p_dbdirectory;
    
    if p_filename is not null then
        if  nvl(instr(l_ret, '\'),0) > 0 then
            l_separator := '\';
        end if;
        l_ret := l_ret||l_separator||p_filename;
    end if;
    return l_ret;
  end;
  

  begin
    l_filebrowse := V(p_process.attribute_01);
    l_linebreak:= p_process.attribute_02;
    l_max_file_size:= FileSizeInBytes(p_process.attribute_03);
    l_move_format_matrix:= GetStringMatrix(p_process.attribute_04, chr(10), '#', 8);
    l_filename_item := p_process.attribute_05;
    l_hash_item:= p_process.attribute_06;
    l_plugin_log_item:= p_process.attribute_07;
    
    if l_filebrowse is null then  --do nothing when submit   
      return l_ret;
    end if;
    
    select count(*) into l_filebrowse_ok 
    from apex_application_page_items 
    where display_as_code = 'NATIVE_FILE' 
    and attribute_01 = 'APEX_APPLICATION_TEMP_FILES' 
    and application_id = V('APP_ID')
    and page_id = V('APP_PAGE_ID') 
    and item_name = p_process.attribute_01;
    
    if l_filebrowse_ok <> 1 then
      l_ret.success_message := 'Item '||p_process.attribute_01||' is not File Browse item or dosen''t have defined APEX_APPLICATION_TEMP_FILES for storage.';
      return l_ret;
    end if;
    
    l_file_names := apex_util.string_to_table(l_filebrowse);
    for i in 1 .. l_file_names.count loop
        select blob_content, dbms_lob.getlength(blob_content) doc_size 
        into l_blob, l_doc_size 
        from APEX_APPLICATION_TEMP_FILES where name = l_file_names(i);
        
        
        
        if l_doc_size > nvl(l_max_file_size, l_doc_size) then
            l_ret.success_message := 'File size too big. Maximum allowed size is '||l_max_file_size||' bytes.';
            delete from APEX_APPLICATION_TEMP_FILES where name = l_file_names(i); 
        else
            --Find the right file
            l_filename := substr(l_file_names(i), instr(replace(l_file_names(i),'\','/'),'/',-1) + 1);
            l_filename_orig := l_filename;
            l_file_moved := false;
            for j in 1..l_move_format_matrix.count loop                        
                if l_filename like replace(l_move_format_matrix(j)(2), '*', '%') or l_move_format_matrix(j)(2) is null then
                    --parse l_dbdirectory, l_filename, l_overwrite, l_regexp_pattern, l_binary_text from line in move format
                    l_dbdirectory := l_move_format_matrix(j)(1);
                            
                    l_regexp_pattern := l_move_format_matrix(j)(3); 
                    l_regexp_replace := l_move_format_matrix(j)(4);
                    l_overwrite := upper(nvl(l_move_format_matrix(j)(5),'Y')) = 'Y';
                    l_binary := upper(nvl(l_move_format_matrix(j)(6),'B')) = 'B';
                    l_charset := upper(nvl(l_move_format_matrix(j)(7),'UTF8'));
                    l_plsql_command := PreparePlSql(l_move_format_matrix(j)(8));
                    
                    if l_regexp_pattern is not null then
                      l_filename := regexp_replace(l_filename, l_regexp_pattern, l_regexp_replace);
                    end if; 
                    
                    if l_hash_item is not null then
                      l_hashes := l_hashes||DBMS_CRYPTO.Hash(l_blob, DBMS_CRYPTO.HASH_SH1)||':';
                    end if;
                  
                    Blob2File(l_dbdirectory, l_filename, l_blob, l_overwrite, l_binary, l_linebreak, l_charset);
                    delete from APEX_APPLICATION_TEMP_FILES where name = l_file_names(i);
                    if l_filename_item is not null then
                      l_filenames := l_filenames||l_dbdirectory||'\'||l_filename||':';
                    end if;
                    
                    if l_plsql_command is not null then
                       l_plsql_command_text := ' Block '||l_move_format_matrix(j)(8)||' executed.'; 
                       EXECUTE IMMEDIATE l_plsql_command;
                    else
                        l_plsql_command_text := null; 
                    end if;
                                
                    if l_binary then
                        l_binary_text := 'binary';
                    else
                        l_binary_text := 'text ('||l_charset||')';
                    end if;
                     
                    l_plugin_log := l_plugin_log||'File '||l_filename_orig||' was '||l_binary_text||' moved to '||FullPath(l_dbdirectory,l_filename)||'.'||l_plsql_command_text||chr(10);
                    l_file_moved := true;
                    exit;                               
                end if;             
            end loop;
            if not l_file_moved then
                l_plugin_log := l_plugin_log||' Don''t know how to process file '||l_filename_orig||'.'||chr(10);
            end if;
        end if;
        commit;
    end loop;  
    
    if l_hashes is not null and l_hash_item is not null then
        apex_util.set_session_state(l_hash_item, rtrim(l_hashes,':'));
    end if;
    
    if l_filenames is not null and l_filename_item is not null then
        apex_util.set_session_state(l_filename_item, rtrim(l_filenames,':'));
    end if;
    
    if l_plugin_log is not null and l_plugin_log_item is not null then
        apex_util.set_session_state(l_plugin_log_item, l_plugin_log);
    end if;
      
    l_ret.success_message := p_process.success_message;
    commit;
    return l_ret;
exception    
    when others then  
    l_ret.success_message := 'Error when moving file '||l_filename_orig||' from APEX_APPLICATION_TEMP_FILES table to server disk '||
                             'on location (Oracle DB directory) '||l_dbdirectory||'\'||l_filename||' . SQLERR: '||sqlerrm;
    --log error(l_ret.success_message)                           
                  
    return l_ret;
    rollback;
  END SaveToDisk;
 --; //!@}
/