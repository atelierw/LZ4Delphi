(*
  LZ4DElphi
  Copyright (C) 2015, Jose Pascoa (atelierwebgm@gmail.com)

  BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above
  copyright notice, this list of conditions and the following disclaimer
  in the documentation and/or other materials provided with the
  distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  Lz4 and xxHash by Yann Collet: https://github.com/Cyan4973
*)

{$Z4}
unit LZ4Externals;

{$I lz4AppDefines.inc}

interface

// bind necessary object files
{$IFDEF USE_EXTERNAL_OBJ_LIBS}

// * Visual Studio * //
{$IFDEF VS_LIB}
{$IFDEF WIN32}
{$L ..\lib\win_vs\w32\lz4frame.obj}
{$L ..\lib\win_vs\w32\lz4hc.obj}
{$L ..\lib\win_vs\w32\lz4.obj}
{$L ..\lib\win_vs\w32\xxhash.obj}
{$ELSE}
{$L ..\lib\win_vs\w64\lz4frame.obj}
{$L ..\lib\win_vs\w64\lz4hc.obj}
{$L ..\lib\win_vs\w64\lz4.obj}
{$L ..\lib\win_vs\w64\xxhash.obj}
{$ENDIF}
{$ENDIF}


uses
    Windows;

const
    LZ4_VERSION_MAJOR = 1;
    LZ4_VERSION_MINOR = 5;
    LZ4_VERSION_RELEASE = 0;
    LZ4_MEMORY_USAGE = 14;
    LZ4_STREAMSIZE_U64 = (1 shl (LZ4_MEMORY_USAGE - 3)) + 4;
    LZ4_STREAMSIZE = LZ4_STREAMSIZE_U64 * sizeof(int64);
    LZ4_MAX_INPUT_SIZE = $7E000000;
    LZ4_UNALIGNED_ACCESS = 1;
    LZ4_STREAMDECODESIZE_U64 = 4;

type
    PLZ4_stream_t = ^LZ4_stream_t;

    LZ4_stream_t = record
        table: array [0 .. LZ4_STREAMSIZE_U64 - 1] of int64;
    end;

    PLZ4_streamDecode_t = ^LZ4_streamDecode_t;

    LZ4_streamDecode_t = record
        table: array [0 .. LZ4_STREAMDECODESIZE_U64 - 1] of int64;
    end;
{$IFDEF WIN32}
const  _PU = '_';
  {$ELSE}
const  _PU = '';
  {$ENDIF}


function LZ4_versionNumber: integer; cdecl; external name _PU+'LZ4_versionNumber';
function LZ4_compressBound(iSize: cardinal): cardinal; cdecl; external name _PU+'LZ4_compressBound';
function LZ4_create(inputBuffer: pAnsiChar): pointer; cdecl; external name _PU+'LZ4_create';
function LZ4_createStream: PLZ4_stream_t; cdecl; external name _PU+'LZ4_createStream';
procedure LZ4_freeStream(LZ4_streamPtr: PLZ4_stream_t); cdecl; external name _PU+'LZ4_freeStream';
function LZ4_createStreamDecode: PLZ4_streamDecode_t; cdecl; external name _PU+'LZ4_createStreamDecode';
procedure LZ4_freeStreamDecode(LZ4_stream: PLZ4_streamDecode_t); cdecl; external name _PU+'LZ4_freeStreamDecode';
function LZ4_compress(source: pAnsiChar; dest: pAnsiChar; sourceSize: integer): integer; cdecl; external name _PU+'LZ4_compress';
function LZ4_decompress_safe(source: pAnsiChar; dest: pAnsiChar; compressedSize: integer; maxDecompressedSize: integer): integer; cdecl;
  external name _PU+'LZ4_decompress_safe';
function LZ4_compress_continue(LZ4_stream: pointer; const ASource: pointer; ADestination: pointer; AInputSize: integer): integer; cdecl;
  external name _PU+'LZ4_compress_continue';
function LZ4_saveDict(LZ4_streamPtr: PLZ4_stream_t; safeBuffer: pointer; dictSize: integer): integer; cdecl; external name _PU+'LZ4_saveDict';
function LZ4_decompress_safe_continue(LZ4_streamDecode: PLZ4_streamDecode_t; source: pointer; dest: pointer; compressedSize: integer;
  maxDecompressedSize: integer): integer; cdecl; external name _PU+'LZ4_decompress_safe_continue';
function LZ4_compress_limitedOutput(const source: pAnsiChar; dest: pAnsiChar; inputSize: integer; maxOutputSize: integer): integer; cdecl;
  external name _PU+'LZ4_compress_limitedOutput';
function LZ4_compress_withState(state: pointer; const source: pAnsiChar; dest: pAnsiChar; inputSize: integer): integer; cdecl;
  external name _PU+'LZ4_compress_withState';
function LZ4_compress_limitedOutput_withState(state: pointer; const source: pAnsiChar; dest: pAnsiChar; inputSize: integer;
  maxOutputSize: integer): integer; cdecl; external name _PU+'LZ4_compress_limitedOutput_withState';
function LZ4_compress_limitedOutput_continue(LZ4_stream: PLZ4_stream_t; const source: pAnsiChar; dest: pAnsiChar; inputSize: integer;
  maxOutputSize: integer): integer; cdecl; external name _PU+'LZ4_compress_limitedOutput_continue';
procedure LZ4_resetStream(LZ4_stream: PLZ4_stream_t); cdecl; external name _PU+'LZ4_resetStream';
function LZ4_loadDict(LZ4_dict: PLZ4_stream_t; dictionary: pAnsiChar; dictSize: integer): integer; cdecl; external name _PU+'LZ4_loadDict';
// debug function
function LZ4_compress_forceExtDict(LZ4_dict: PLZ4_stream_t; const source: pAnsiChar; dest: pAnsiChar; inputSize: integer): integer; cdecl;
  external name _PU+'LZ4_compress_forceExtDict';
function LZ4_decompress_fast(source: pAnsiChar; dest: pAnsiChar; originalSize: integer): integer; cdecl;
  external name _PU+'LZ4_decompress_fast';
function LZ4_decompress_fast_withPrefix64k(source: pAnsiChar; dest: pAnsiChar; originalSize: integer): integer; cdecl;
  external name _PU+'LZ4_decompress_fast_withPrefix64k';
function LZ4_decompress_fast_usingDict(source: pAnsiChar; dest: pAnsiChar; originalSize: integer; const dictStart: pAnsiChar;
  dictSize: integer): integer; cdecl; external name _PU+'LZ4_decompress_fast_usingDict';
function LZ4_decompress_safe_withPrefix64k(source: pAnsiChar; dest: pAnsiChar; compressedSize: integer; maxOutputSize: integer): integer;
  cdecl; external name _PU+'LZ4_decompress_safe_withPrefix64k';
function LZ4_decompress_safe_usingDict(const source: pAnsiChar; dest: pAnsiChar; compressedSize: integer; maxOutputSize: integer;
  const dictStart: pAnsiChar; dictSize: integer): integer; cdecl; external name _PU+'LZ4_decompress_safe_usingDict';
function LZ4_decompress_safe_partial(const source: pAnsiChar; dest: pAnsiChar; compressedSize: integer; targetOutputSize: integer;
  maxDecompressedSize: integer): integer; cdecl; external name _PU+'LZ4_decompress_safe_partial';
function LZ4_decompress_safe_forceExtDict(source: pAnsiChar; dest: pAnsiChar; compressedSize: integer; maxOutputSize: integer;
  const dictStart: pAnsiChar; dictSize: integer): integer; cdecl; external name _PU+'LZ4_decompress_safe_forceExtDict';

// LZ4HC
const
    LZ4_STREAMHCSIZE_U64 = 32774;

type
    PLZ4_streamHC_t = ^LZ4_streamHC_t;

    LZ4_streamHC_t = record
        table: array [0 .. LZ4_STREAMHCSIZE_U64 - 1] of uint64;
    end;


function LZ4_createStreamHC: PLZ4_streamHC_t; cdecl; external name _PU+'LZ4_createStreamHC';
procedure LZ4_freeStreamHC(LZ4_streamHCPtr: PLZ4_streamHC_t); cdecl; external name _PU+'LZ4_freeStreamHC';
function LZ4_compressHC(source: pAnsiChar; dest: pAnsiChar; inputSize: integer): integer; cdecl; external name _PU+'LZ4_compressHC';
function LZ4_compressHC_limitedOutput(const source: pAnsiChar; dest: pAnsiChar; inputSize: integer; maxOutputSize: integer): integer; cdecl;
  external name _PU+'LZ4_compressHC_limitedOutput';
function LZ4_compressHC_withStateHC(state: pointer; const source: pAnsiChar; dest: pAnsiChar; inputSize: integer): integer; cdecl;
  external name _PU+'LZ4_compressHC_withStateHC';
function LZ4_compressHC_limitedOutput_withStateHC(state: pointer; const source: pAnsiChar; dest: pAnsiChar; inputSize: integer;
  maxOutputSize: integer): integer; cdecl; external name _PU+'LZ4_compressHC_limitedOutput_withStateHC';
function LZ4_createHC(inputBuffer: pAnsiChar): pointer; cdecl; external name _PU+'LZ4_createHC';
function LZ4_compressHC_continue(LZ4_streamHCPtr: PLZ4_streamHC_t; const source: pAnsiChar; dest: pAnsiChar; inputSize: integer): integer;
  cdecl; external name _PU+'LZ4_compressHC_continue';
function LZ4_loadDictHC(LZ4_streamHCPtr: PLZ4_streamHC_t; dictionary: pAnsiChar; dictSize: integer): integer; cdecl;
  external name _PU+'LZ4_loadDictHC';
function LZ4_compressHC_limitedOutput_continue(LZ4_streamHCPtr: PLZ4_streamHC_t; const source: pAnsiChar; dest: pAnsiChar;
  inputSize: integer; maxOutputSize: integer): integer; cdecl; external name _PU+'LZ4_compressHC_limitedOutput_continue';
procedure LZ4_resetStreamHC(LZ4_streamHCPtr: PLZ4_streamHC_t; compressionLevel: integer); cdecl; external name _PU+'LZ4_resetStreamHC';
function LZ4_saveDictHC(LZ4_streamHCPtr: PLZ4_streamHC_t; safeBuffer: pAnsiChar; dictSize: integer): integer; cdecl;
  external name _PU+'LZ4_saveDictHC';
//function LZ4_compressHC2(const source: pAnsiChar; dest: pAnsiChar; inputSize: integer; compressionLevel: integer): integer; cdecl;
  //external name _PU+'LZ4_compressHC2';
//function LZ4_compressHC2_limitedOutput(const source: pAnsiChar; dest: pAnsiChar; inputSize: integer; maxOutputSize: integer;
  //compressionLevel: integer): integer; cdecl; external name _PU+'LZ4_compressHC2_limitedOutput';
//function LZ4_compressHC2_withStateHC(state: pointer; const source: pAnsiChar; dest: pAnsiChar; inputSize: integer;
  //compressionLevel: integer): integer; cdecl; external name _PU+'LZ4_compressHC2_withStateHC';
//function LZ4_compressHC2_limitedOutput_withStateHC(state: pointer; const source: pAnsiChar; dest: pAnsiChar; inputSize: integer;
  //maxOutputSize: integer; compressionLevel: integer): integer; cdecl; external name _PU+'LZ4_compressHC2_limitedOutput_withStateHC';


// LZ4Frame
const
    LZ4F_VERSION = 100;

type
    PLZ4F_decompressionContext_t = pointer;
    PLZ4F_compressionContext_t = pointer;
    LZ4F_errorCode_t = size_t;
    blockSizeID_t = (LZ4F_default = 0, max64KB = 4, max256KB = 5, max1MB = 6, max4MB = 7);
    blockMode_t = (blockLinked = 0, blockIndependent);
    contentChecksum_t = (noContentChecksum = 0, contentChecksumEnabled);
    LZ4F_lastBlockStatus = (notDone, fromTmpBuffer, fromSrcBuffer);

    PLZ4F_frameInfo_t = ^LZ4F_frameInfo_t;

    LZ4F_frameInfo_t = record
        blockSizeID: blockSizeID_t;
        blockMode: blockMode_t;
        contentChecksumFlag: contentChecksum_t;
        reserved: array [0 .. 4] of cardinal;
    end;

    PLZ4F_preferences_t = ^LZ4F_preferences_t;

    LZ4F_preferences_t = record
        frameInfo: LZ4F_frameInfo_t;
        compressionLevel: cardinal;
        autoFlush: cardinal;
        reserved: array [0 .. 3] of cardinal;
    end;

    PLZ4F_compressOptions_t = ^LZ4F_compressOptions_t;

    LZ4F_compressOptions_t = record
        stableSrc: cardinal;
        reserved: array [0 .. 2] of cardinal;
    end;

    PLZ4F_decompressOptions_t = ^LZ4F_decompressOptions_t;

    LZ4F_decompressOptions_t = record
        stableDst: cardinal;
        reserved: array [0 .. 2] of cardinal;
    end;

function LZ4F_createDecompressionContext(var LZ4F_decompressionContextPtr: PLZ4F_compressionContext_t; versionNumber: cardinal)
  : LZ4F_errorCode_t; cdecl; external name _PU+'LZ4F_createDecompressionContext';
function LZ4F_isError(code: LZ4F_errorCode_t): boolean; cdecl; external name _PU+'LZ4F_isError';
function LZ4F_compressFrame(dstBuffer: pointer; dstMaxSize: size_t; const srcBuffer: pointer; srcSize: size_t;
  const preferencesPtr: PLZ4F_preferences_t): size_t; cdecl; external name _PU+'LZ4F_compressFrame';
function LZ4F_compressBound(srcSize: size_t; const preferencesPtr: PLZ4F_preferences_t): size_t; cdecl; external name _PU+'LZ4F_compressBound';
function LZ4F_compressFrameBound(srcSize: size_t; const preferencesPtr: PLZ4F_preferences_t): size_t; cdecl;
  external name _PU+'LZ4F_compressFrameBound';
function LZ4F_compressBegin(compressionContext: PLZ4F_compressionContext_t; dstBuffer: pointer; dstMaxSize: size_t;
  preferencesPtr: PLZ4F_preferences_t): size_t; cdecl; external name _PU+'LZ4F_compressBegin';
function LZ4F_compressUpdate(compressionContext: PLZ4F_compressionContext_t; dstBuffer: pointer; dstMaxSize: size_t;
  const srcBuffer: pointer; srcSize: size_t; compressOptionsPtr: PLZ4F_compressOptions_t): size_t; cdecl;
  external name _PU+'LZ4F_compressUpdate';
function LZ4F_compressEnd(compressionContext: PLZ4F_compressionContext_t; dstBuffer: pointer; dstMaxSize: size_t;
  const compressOptionsPtr: PLZ4F_compressOptions_t): size_t; cdecl; external name _PU+'LZ4F_compressEnd';
function LZ4F_flush(compressionContext: PLZ4F_compressionContext_t; dstBuffer: pointer; dstMaxSize: size_t;
  compressOptionsPtr: PLZ4F_compressOptions_t): size_t; cdecl; external name _PU+'LZ4F_flush';
function LZ4F_decompress(decompressionContext: PLZ4F_decompressionContext_t;
  dstBuffer: pointer; dstSizePtr: psize_t; const srcBuffer: pointer; srcSizePtr: psize_t;
  decompressOptionsPtr: PLZ4F_decompressOptions_t): size_t; cdecl; external name _PU+'LZ4F_decompress';
function LZ4F_createCompressionContext(var LZ4F_compressionContextPtr: pointer; version: cardinal): LZ4F_errorCode_t; cdecl;
  external name _PU+'LZ4F_createCompressionContext';
function LZ4F_freeCompressionContext(LZ4F_compressionContext: pointer): LZ4F_errorCode_t; cdecl;
  external name _PU+'LZ4F_freeCompressionContext';
function LZ4F_getFrameInfo(decompressionContext: PLZ4F_decompressionContext_t; frameInfoPtr: PLZ4F_frameInfo_t; const srcBuffer: pointer;
  srcSizePtr: psize_t): LZ4F_errorCode_t; cdecl; external name _PU+'LZ4F_getFrameInfo';
function LZ4F_freeDecompressionContext(LZ4F_decompressionContext: PLZ4F_decompressionContext_t): LZ4F_errorCode_t; cdecl;
  external name _PU+'LZ4F_freeDecompressionContext';
function LZ4F_getErrorName(code: LZ4F_errorCode_t): pAnsiChar; cdecl; external name _PU+'LZ4F_getErrorName';

type
    XXH_errorcode = (XXH_OK = 0, XXH_ERROR);

    PXXH64_state_t = ^XXH64_state_t;

    XXH64_state_t = record
        ll: array [0 .. 10] of int64;
    end;

    PXXH32_state_t = ^XXH32_state_t;

    XXH32_state_t = record
        ll: array [0 .. 5] of int64;
    end;

function XXH32(input: pointer; len: size_t; seed: cardinal): cardinal; cdecl; external name _PU+'XXH32';
function XXH32_reset(statePtr: PXXH32_state_t; seed: cardinal): XXH_errorcode; cdecl; external name _PU+'XXH32_reset';
function XXH32_update(statePtr: PXXH32_state_t; Ainput: pointer; ALength: size_t): XXH_errorcode; cdecl; external name _PU+'XXH32_update';
function XXH32_digest(statePtr: PXXH32_state_t): cardinal; cdecl; external name _PU+'XXH32_digest';
function XXH32_createState: PXXH32_state_t; cdecl; external name _PU+'XXH32_createState';
function XXH32_freeState(statePtr: PXXH32_state_t):XXH_errorcode;cdecl; external name _PU+'XXH32_freeState';

function XXH64_reset(statePtr: PXXH64_state_t; seed: uint64): XXH_errorcode; cdecl; external name _PU+'XXH64_reset';
function XXH64_update(statePtr: PXXH64_state_t; Ainput: pointer; ALength: size_t): XXH_errorcode; cdecl; external name _PU+'XXH64_update';
function XXH64_digest(statePtr: PXXH64_state_t): uint64; cdecl; external name _PU+'XXH64_digest';
function XXH64_createState: PXXH32_state_t; cdecl; external name _PU+'XXH64_createState';
function XXH64_freeState(statePtr: PXXH32_state_t):XXH_errorcode;cdecl; external name _PU+'XXH64_freeState';

{$IFDEF WIN32}
function _calloc(count, size: cardinal): pointer; cdecl; external 'msvcrt.dll' name 'calloc';
procedure _free(P: pointer); cdecl; external 'msvcrt.dll' name 'free';
function _malloc(size: cardinal): pointer; cdecl; external 'msvcrt.dll' name 'malloc';
procedure _memmove(dest, source: pointer; count: integer); cdecl; external 'msvcrt.dll' name 'memmove';
procedure _memcpy(dest, source: pointer; count: integer); cdecl; external 'msvcrt.dll' name 'memcpy';
function _memset(P: pointer; B: integer; count: integer): pointer; cdecl; external 'msvcrt.dll' name 'memset';
procedure __allmul;
{$ELSE}
function calloc(count, size: cardinal): pointer; external 'msvcrt.dll' name 'calloc';
procedure free(P: pointer); external 'msvcrt.dll' name 'free';
function malloc(size: cardinal): pointer; external 'msvcrt.dll' name 'malloc';
procedure memcpy(dest, source: pointer; count: integer); external 'msvcrt.dll' name 'memcpy';
procedure memmove(dest, source: pointer; count: integer); external 'msvcrt.dll' name 'memmove';
function memset(P: pointer; B: integer; count: integer): pointer; external 'msvcrt.dll' name 'memset';
{$ENDIF}

implementation

{$IFDEF WIN32}


procedure __allmul;  // Visual Studio 2012 (may not work with different versions)
asm
    mov     eax, dword ptr [esp+8]
    mov     ecx, dword ptr [esp+16]
    or      ecx,eax
    mov     ecx, dword ptr [esp +12]
    jnz     @hard
    mov     eax,dword ptr [esp+4]
    mul     ecx

    ret     16

@hard:
    push    ebx

    mul     ecx
    mov     ebx,eax

    mov     eax, dword ptr [esp + 8]
    mul     dword ptr [esp+20]
    add     ebx,eax

    mov     eax, dword ptr [esp+8]
    mul     ecx
    add     edx,ebx
    pop     ebx
    ret     16
end;

procedure __chkstk;  // Visual Studio 2012 (may not work with different versions)
asm
    push ecx
    lea   ecx, [esp] + 4
    sub   ecx, eax
    sbb   eax, eax
    not   eax
    and   ecx, eax
    mov   eax, esp
    and   eax, 0FFFFF000h
@cs10:
    cmp  ecx, eax
    jb   @cs20
    mov  eax, ecx
    pop  ecx
    xchg esp, eax
    mov  eax, dword ptr [eax]
    mov  dword ptr [esp], eax
    ret
@cs20:
    sub  eax, 1000h
    test dword ptr [eax],eax
    jmp @cs10
end;

{$ELSE}

procedure __chkstk;   // Visual Studio 2012 (may not work with different versions)
asm
    sub  rsp,10h
    mov  qword ptr [rsp],r14
    mov  qword ptr [rsp+8],r15
    xor  r15,r15
    lea  r14,[rsp+18h]
    sub  r14,rax
    cmovb r14,r15
    mov  r15,qword ptr gs:[abs 10h]
    cmp  r14,r15
    jae @cs20
    and r14w,0F000h
@cs10:
    lea r15,[r15-1000h]
    mov byte ptr [r15],0
    cmp r14,r15
    jne @cs10
@cs20:
    mov r14,qword ptr [rsp]
    mov r15,qword ptr [rsp+8]
    add rsp,10h
    ret
end;
{$ENDIF}
{$ELSE}

implementation


{$ENDIF} // USE_EXTERNAL_OBJ_LIBS

end.
