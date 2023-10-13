(*
 * Copyright (c) 2023 XXIV
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *)
unit zip;

{$ifdef fpc}
{$packrecords c}
{$endif}

interface

uses ctypes;

type
   zip_t  = record
	    end; 
   Pzip_t = ^zip_t;
   on_entry_extract_callback = function (arg:pointer; offset:cuint64; data:pointer; size:csize_t):csize_t;cdecl;
   on_stream_extract_callback = function (filename:Pchar; arg:pointer):longint;cdecl;
   on_extract_callback = function (filename:Pchar; arg:pointer):longint;cdecl;


const
    ZIP_DEFAULT_COMPRESSION_LEVEL = 6;
    // Error codes
    ZIP_ENOINIT = -(1);    { not initialized }
    ZIP_EINVENTNAME = -(2);    { invalid entry name }
    ZIP_ENOENT = -(3);    { entry not found }
    ZIP_EINVMODE = -(4);    { invalid zip mode }
    ZIP_EINVLVL = -(5);    { invalid compression level }
    ZIP_ENOSUP64 = -(6);    { no zip 64 support }
    ZIP_EMEMSET = -(7);    { memset error }
    ZIP_EWRTENT = -(8);    { cannot write data to entry }
    ZIP_ETDEFLINIT = -(9);    { cannot initialize tdefl compressor }
    ZIP_EINVIDX = -(10);    { invalid index }
    ZIP_ENOHDR = -(11);    { header not found }
    ZIP_ETDEFLBUF = -(12);    { cannot flush tdefl buffer }
    ZIP_ECRTHDR = -(13);    { cannot create entry header }
    ZIP_EWRTHDR = -(14);    { cannot write entry header }
    ZIP_EWRTDIR = -(15);    { cannot write to central dir }
    ZIP_EOPNFILE = -(16);    { cannot open file }
    ZIP_EINVENTTYPE = -(17);    { invalid entry type }
    ZIP_EMEMNOALLOC = -(18);    { extracting data using no memory allocation }
    ZIP_ENOFILE = -(19);    { file not found }
    ZIP_ENOPERM = -(20);    { no permission }
    ZIP_EOOMEM = -(21);    { out of memory }
    ZIP_EINVZIPNAME = -(22);    { invalid zip archive name }
    ZIP_EMKDIR = -(23);    { make dir error }
    ZIP_ESYMLINK = -(24);    { symlink error }
    ZIP_ECLSZIP = -(25);    { close archive error }
    ZIP_ECAPSIZE = -(26);    { capacity size too small }
    ZIP_EFSEEK = -(27);    { fseek error }
    ZIP_EFREAD = -(28);    { fread error }
    ZIP_EFWRITE = -(29);    { fwrite error }
    ZIP_ERINIT = -(30);    { cannot initialize reader }
    ZIP_EWINIT = -(31);    { cannot initialize writer }
    ZIP_EWRINIT = -(32);    { cannot initialize writer from reader }

(*
* Looks up the error message string corresponding to an error number.
* @param errnum error number
* @return error message string corresponding to errnum or NULL if error is not
* found.
*)
function zip_strerror(errnum:longint):Pchar;cdecl;external;

(*
* Opens zip archive with compression level using the given mode.
*
* @param zipname zip archive file name.
* @param level compression level (0-9 are the standard zlib-style levels).
* @param mode file access mode.
*        - 'r': opens a file for reading/extracting (the file must exists).
*        - 'w': creates an empty file for writing.
*        - 'a': appends to an existing archive.
*
* @return the zip archive handler or NULL on error
*)
function zip_open(zipname:Pchar; level:longint; mode:char):Pzip_t;cdecl;external;

(*
* Opens zip archive with compression level using the given mode.
* The function additionally returns @param errnum -
*
* @param zipname zip archive file name.
* @param level compression level (0-9 are the standard zlib-style levels).
* @param mode file access mode.
*        - 'r': opens a file for reading/extracting (the file must exists).
*        - 'w': creates an empty file for writing.
*        - 'a': appends to an existing archive.
* @param errnum 0 on success, negative number (< 0) on error.
*
* @return the zip archive handler or NULL on error
*)
function zip_openwitherror(zipname:Pchar; level:longint; mode:char; errnum:Plongint):Pzip_t;cdecl;external;

(*
* Closes the zip archive, releases resources - always finalize.
*
* @param zip zip archive handler.
*)
procedure zip_close(zip:Pzip_t);cdecl;external;

(*
* Determines if the archive has a zip64 end of central directory headers.
*
* @param zip zip archive handler.
*
* @return the return code - 1 (true), 0 (false), negative number (< 0) on
*         error.
*)
function zip_is64(zip:Pzip_t):longint;cdecl;external;

(*
* Opens an entry by name in the zip archive.
*
* For zip archive opened in 'w' or 'a' mode the function will append
* a new entry. In readonly mode the function tries to locate the entry
* in global dictionary.
*
* @param zip zip archive handler.
* @param entryname an entry name in local dictionary.
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_entry_open(zip:Pzip_t; entryname:Pchar):longint;cdecl;external;

(*
* Opens an entry by name in the zip archive.
*
* For zip archive opened in 'w' or 'a' mode the function will append
* a new entry. In readonly mode the function tries to locate the entry
* in global dictionary (case sensitive).
*
* @param zip zip archive handler.
* @param entryname an entry name in local dictionary (case sensitive).
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_entry_opencasesensitive(zip:Pzip_t; entryname:Pchar):longint;cdecl;external;

(*
* Opens a new entry by index in the zip archive.
*
* This function is only valid if zip archive was opened in 'r' (readonly) mode.
*
* @param zip zip archive handler.
* @param index index in local dictionary.
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_entry_openbyindex(zip:Pzip_t; index:csize_t):longint;cdecl;external;

(*
* Closes a zip entry, flushes buffer and releases resources.
*
* @param zip zip archive handler.
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_entry_close(zip:Pzip_t):longint;cdecl;external;

(*
* Returns a local name of the current zip entry.
*
* The main difference between user's entry name and local entry name
* is optional relative path.
* Following .ZIP File Format Specification - the path stored MUST not contain
* a drive or device letter, or a leading slash.
* All slashes MUST be forward slashes '/' as opposed to backwards slashes '\'
* for compatibility with Amiga and UNIX file systems etc.
*
* @param zip: zip archive handler.
*
* @return the pointer to the current zip entry name, or NULL on error.
*)
function zip_entry_name(zip:Pzip_t):Pchar;cdecl;external;

(*
* Returns an index of the current zip entry.
*
* @param zip zip archive handler.
*
* @return the index on success, negative number (< 0) on error.
*)
function zip_entry_index(zip:Pzip_t):cslonglong;cdecl;external;

(*
* Determines if the current zip entry is a directory entry.
*
* @param zip zip archive handler.
*
* @return the return code - 1 (true), 0 (false), negative number (< 0) on
*         error.
*)
function zip_entry_isdir(zip:Pzip_t):longint;cdecl;external;

(*
* Returns the uncompressed size of the current zip entry.
* Alias for zip_entry_uncomp_size (for backward compatibility).
*
* @param zip zip archive handler.
*
* @return the uncompressed size in bytes.
*)
function zip_entry_size(zip:Pzip_t):qword;cdecl;external;

(*
* Returns the uncompressed size of the current zip entry.
*
* @param zip zip archive handler.
*
* @return the uncompressed size in bytes.
*)
function zip_entry_uncomp_size(zip:Pzip_t):qword;cdecl;external;

(*
* Returns the compressed size of the current zip entry.
*
* @param zip zip archive handler.
*
* @return the compressed size in bytes.
*)
function zip_entry_comp_size(zip:Pzip_t):qword;cdecl;external;

(*
* Returns CRC-32 checksum of the current zip entry.
*
* @param zip zip archive handler.
*
* @return the CRC-32 checksum.
*)
function zip_entry_crc32(zip:Pzip_t):dword;cdecl;external;

(*
* Compresses an input buffer for the current zip entry.
*
* @param zip zip archive handler.
* @param buf input buffer.
* @param bufsize input buffer size (in bytes).
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_entry_write(zip:Pzip_t; buf:pointer; bufsize:csize_t):longint;cdecl;external;

(*
* Compresses a file for the current zip entry.
*
* @param zip zip archive handler.
* @param filename input file.
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_entry_fwrite(zip:Pzip_t; filename:Pchar):longint;cdecl;external;

(*
* Extracts the current zip entry into output buffer.
*
* The function allocates sufficient memory for a output buffer.
*
* @param zip zip archive handler.
* @param buf output buffer.
* @param bufsize output buffer size (in bytes).
*
* @note remember to release memory allocated for a output buffer.
*       for large entries, please take a look at zip_entry_extract function.
*
* @return the return code - the number of bytes actually read on success.
*         Otherwise a negative number (< 0) on error.
*)
function zip_entry_read(zip:Pzip_t; buf:Ppointer; bufsize:Pcsize_t):cslonglong;cdecl;external;

(*
* Extracts the current zip entry into a memory buffer using no memory
* allocation.
*
* @param zip zip archive handler.
* @param buf preallocated output buffer.
* @param bufsize output buffer size (in bytes).
*
* @note ensure supplied output buffer is large enough.
*       zip_entry_size function (returns uncompressed size for the current
*       entry) can be handy to estimate how big buffer is needed.
*       For large entries, please take a look at zip_entry_extract function.
*
* @return the return code - the number of bytes actually read on success.
*         Otherwise a negative number (< 0) on error (e.g. bufsize is not large
* enough).
*)
function zip_entry_noallocread(zip:Pzip_t; buf:pointer; bufsize:csize_t):cslonglong;cdecl;external;

(*
* Extracts the current zip entry into output file.
*
* @param zip zip archive handler.
* @param filename output file.
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_entry_fread(zip:Pzip_t; filename:Pchar):longint;cdecl;external;

(*
* Extracts the current zip entry using a callback function (on_extract).
*
* @param zip zip archive handler.
* @param on_extract callback function.
* @param arg opaque pointer (optional argument, which you can pass to the
*        on_extract callback)
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_entry_extract(zip:Pzip_t; on_extract: on_entry_extract_callback; arg:pointer):longint;cdecl;external;

(*
* Returns the number of all entries (files and directories) in the zip archive.
*
* @param zip zip archive handler.
*
* @return the return code - the number of entries on success, negative number
*         (< 0) on error.
*)
function zip_entries_total(zip:Pzip_t):cslonglong;cdecl;external;

(*
* Deletes zip archive entries.
*
* @param zip zip archive handler.
* @param entries array of zip archive entries to be deleted.
* @param len the number of entries to be deleted.
* @return the number of deleted entries, or negative number (< 0) on error.
*)
function zip_entries_delete(zip:Pzip_t; entries:PPchar; len:csize_t):cslonglong;cdecl;external;

(*
* Extracts a zip archive stream into directory.
*
* If on_extract is not NULL, the callback will be called after
* successfully extracted each zip entry.
* Returning a negative value from the callback will cause abort and return an
* error. The last argument (void *arg) is optional, which you can use to pass
* data to the on_extract callback.
*
* @param stream zip archive stream.
* @param size stream size.
* @param dir output directory.
* @param on_extract on extract callback.
* @param arg opaque pointer.
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_stream_extract(stream:Pchar; size:csize_t; dir:Pchar; on_extract: on_stream_extract_callback; arg:pointer):longint;cdecl;external;

(*
* Opens zip archive stream into memory.
*
* @param stream zip archive stream.
* @param size stream size.
* @param level compression level (0-9 are the standard zlib-style levels).
* @param mode file access mode.
*        - 'r': opens a file for reading/extracting (the file must exists).
*        - 'w': creates an empty file for writing.
*        - 'a': appends to an existing archive.
*
* @return the zip archive handler or NULL on error
*)
function zip_stream_open(stream:Pchar; size:csize_t; level:longint; mode:char):Pzip_t;cdecl;external;

(*
* Opens zip archive stream into memory.
* The function additionally returns @param errnum -
*
* @param stream zip archive stream.
* @param size stream size.*
* @param level compression level (0-9 are the standard zlib-style levels).
* @param mode file access mode.
*        - 'r': opens a file for reading/extracting (the file must exists).
*        - 'w': creates an empty file for writing.
*        - 'a': appends to an existing archive.
* @param errnum 0 on success, negative number (< 0) on error.
*
* @return the zip archive handler or NULL on error
*)
function zip_stream_openwitherror(stream:Pchar; size:csize_t; level:longint; mode:char; errnum:Plongint):Pzip_t;cdecl;external;

(*
* Copy zip archive stream output buffer.
*
* @param zip zip archive handler.
* @param buf output buffer. User should free buf.
* @param bufsize output buffer size (in bytes).
*
* @return copy size
*)
function zip_stream_copy(zip:Pzip_t; buf:Ppointer; bufsize:Pcsize_t):cslonglong;cdecl;external;

(*
* Close zip archive releases resources.
*
* @param zip zip archive handler.
*
* @return
*)
procedure zip_stream_close(zip:Pzip_t);cdecl;external;

(*
* Creates a new archive and puts files into a single zip archive.
*
* @param zipname zip archive file.
* @param filenames input files.
* @param len: number of input files.
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_create(zipname:Pchar; filenames:PPchar; len:csize_t):longint;cdecl;external;

(*
* Extracts a zip archive file into directory.
*
* If on_extract_entry is not NULL, the callback will be called after
* successfully extracted each zip entry.
* Returning a negative value from the callback will cause abort and return an
* error. The last argument (void *arg) is optional, which you can use to pass
* data to the on_extract_entry callback.
*
* @param zipname zip archive file.
* @param dir output directory.
* @param on_extract_entry on extract callback.
* @param arg opaque pointer.
*
* @return the return code - 0 on success, negative number (< 0) on error.
*)
function zip_extract(zipname:Pchar; dir:Pchar; on_extract_entry: on_extract_callback; arg:pointer):longint;cdecl;external;

implementation

end.
