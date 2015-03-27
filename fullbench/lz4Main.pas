(*
  LZ4Delphi
  Copyright (C) 2015, Jose Pascoa (atelierwebgm@gmail.com)
  BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

  *************************************************************************
  LZ4 - Fast LZ compression algorithm
  xxHash - Fast Hash algorithm
  LZ4 source repository : http://code.google.com/p/lz4/
  xxHash source repository : http://code.google.com/p/xxhash/
  Copyright (c) 2011-2014, Yann Collet
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

 ******************************************************************************
*)

unit lz4Main;
{$WARN SYMBOL_PLATFORM OFF}
{$POINTERMATH ON}

interface

{$I lz4AppDefines.inc}


uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
{$IFDEF USE_EXTERNAL_OBJ_LIBS}
    LZ4Externals;
{$ELSE}
xxHash, lz4, lz4frame, lz4HC;
{$ENDIF}


type
    TmainUnit = class(TForm)
        FileOpenDlg: TFileOpenDialog;
        Memo: TMemo;
        Panel1: TPanel;
        lblFiletoCompress: TLabel;
        edFilename: TEdit;
        btSelect: TButton;
        Panel2: TPanel;
        btClear: TButton;
        cbCompressionFunction: TComboBoxEx;
        lblCompressionFunction: TLabel;
        btTestCompFunctions: TButton;
        cbDecompressionFunction: TComboBox;
        lblDecompressionFunction: TLabel;
        btTestDecompFunctions: TButton;
        btHash32: TButton;
        btHash64: TButton;
        lblBlockSize: TLabel;
        cbBlockSize: TComboBox;
        Label1: TLabel;
        cbIterations: TComboBox;
        procedure btSelectClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure btGoClick(Sender: TObject);
        procedure btClearClick(Sender: TObject);
        procedure btHash32Click(Sender: TObject);
        procedure btHash64Click(Sender: TObject);
        procedure btTestCompFunctionsClick(Sender: TObject);
        procedure btTestDecompFunctionsClick(Sender: TObject);
        procedure cbBlockSizeSelect(Sender: TObject);
        procedure cbIterationsSelect(Sender: TObject);
    private
        function checkInfileexists: boolean;
        function BMK_findMaxMem(requiredMem: uint64): size_t;
    public
        { Public declarations }
    end;

    PchunkParameters = ^chunkParameters;

    chunkParameters = record
        id: cardinal;
        origBuffer: pAnsiChar;
        compressedBuffer: pAnsiChar;
        origSize: integer;
        compressedSize: integer;
    end;

const
    DEFAULT_CHUNKSIZE = 4 shl 20;
    TIMELOOP = 2500;
    NBLOOPS = 6;

var
    mainUnit: TmainUnit;
    g_dCtx: PLZ4F_decompressionContext_t;
    stateLZ4: pointer;
    stateLZ4HC: pointer;
    chunkSize: integer = DEFAULT_CHUNKSIZE;
    nbIterations: integer = NBLOOPS;
    ctx: pLZ4_stream_t;

implementation

uses Diagnostics, TimeSpan;

var
    Stopwatch: TStopwatch;
    Elapsed: TTimeSpan;
{$R *.dfm}


function local_LZ4_compress_continue(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compress_continue(ctx, _in, _out, inSize);
end;

function local_LZ4_compress_limitedOutput(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compress_limitedOutput(_in, _out, inSize, LZ4_compressBound(inSize));
end;

function local_LZ4_compress(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compress(_in, _out, inSize);
end;

function local_LZ4_compress_withState(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compress_withState(stateLZ4, _in, _out, inSize);
end;

function local_LZ4_compress_limitedOutput_withState(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compress_limitedOutput_withState(stateLZ4, _in, _out, inSize, LZ4_compressBound(inSize));
end;

function local_LZ4_compress_limitedOutput_continue(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compress_limitedOutput_continue(ctx, _in, _out, inSize, LZ4_compressBound(inSize));
end;

function local_LZ4_compressHC(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compressHC(_in, _out, inSize);
end;

function local_LZ4_compressHC_limitedOutput(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compressHC_limitedOutput(_in, _out, inSize, LZ4_compressBound(inSize));
end;

function local_LZ4_compressHC_withStateHC(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compressHC_withStateHC(stateLZ4HC, _in, _out, inSize);
end;

function local_LZ4_compressHC_limitedOutput_withStateHC(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compressHC_limitedOutput_withStateHC(stateLZ4HC, _in, _out, inSize, LZ4_compressBound(inSize));
end;

function local_LZ4_compressHC_continue(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compressHC_continue(PLZ4_streamHC_t(ctx), _in, _out, inSize);
end;

function local_LZ4_compressHC_limitedOutput_continue(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compressHC_limitedOutput_continue(PLZ4_streamHC_t(ctx), _in, _out, inSize, LZ4_compressBound(inSize));
end;

var
    LZ4_dict: LZ4_stream_t;

{$IFDEF USE_EXTERNAL_OBJ_LIBS}
function local_LZ4_resetDictT(fake: pAnsiChar): pointer; cdecl;
{$ELSE}
function local_LZ4_resetDictT(fake: pAnsiChar): pointer;
{$ENDIF}
begin
    fillchar(LZ4_dict, sizeof(LZ4_stream_t), 0);
    result := nil;
end;

function local_LZ4_compress_forceDict(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_compress_forceExtDict(@LZ4_dict, _in, _out, inSize);
end;

function local_LZ4F_compressFrame(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := integer(LZ4F_compressFrame(_out, 2 * inSize + 16, _in, inSize, Nil));
end;

function local_LZ4_saveDict(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_saveDict(@LZ4_dict, _out, inSize);
end;

var
    LZ4_dictHC: LZ4_streamHC_t;

function local_LZ4_saveDictHC(_in: pAnsiChar; _out: pAnsiChar; inSize: integer): integer;
begin
    result := LZ4_saveDictHC(@LZ4_dictHC, _out, inSize);
end;

function local_LZ4_decompress_fast(_in: pAnsiChar; _out: pAnsiChar; inSize: integer; outSize: integer): integer;
begin
    LZ4_decompress_fast(_in, _out, outSize);
    result := outSize;
end;

function local_LZ4_decompress_fast_withPrefix64k(_in: pAnsiChar; _out: pAnsiChar; inSize: integer; outSize: integer): integer;
begin
    LZ4_decompress_fast_withPrefix64k(_in, _out, outSize);
    result := outSize;
end;

function local_LZ4_decompress_fast_usingDict(_in: pAnsiChar; _out: pAnsiChar; inSize: integer; outSize: integer): integer;
begin
    LZ4_decompress_fast_usingDict(_in, _out, outSize, _out - 65536, 65536);
    result := outSize;
end;

function local_LZ4_decompress_safe_usingDict(_in: pAnsiChar; _out: pAnsiChar; inSize: integer; outSize: integer): integer;
begin
    LZ4_decompress_safe_usingDict(_in, _out, inSize, outSize, _out - 65536, 65536);
    result := outSize;
end;

function local_LZ4_decompress_safe(_in: pAnsiChar; _out: pAnsiChar; inSize: integer; outSize: integer): integer;
begin
    LZ4_decompress_safe(_in, _out, inSize, outSize);
    result := outSize;
end;

function local_LZ4_decompress_safe_withPrefix64k(_in: pAnsiChar; _out: pAnsiChar; inSize: integer; outSize: integer): integer;
begin
    LZ4_decompress_safe_withPrefix64k(_in, _out, inSize, outSize);
    result := outSize;
end;

function local_LZ4_decompress_safe_partial(_in: pAnsiChar; _out: pAnsiChar; inSize: integer; outSize: integer): integer;
begin
    result := LZ4_decompress_safe_partial(_in, _out, inSize, outSize - 5, outSize);
end;

function local_LZ4_decompress_safe_forceExtDict(_in: pAnsiChar; _out: pAnsiChar; inSize: integer; outSize: integer): integer;
begin
    LZ4_decompress_safe_forceExtDict(_in, _out, inSize, outSize, _out - 65536, 65536);
    result := outSize;
end;

function local_LZ4F_decompress(_in: pAnsiChar; _out: pAnsiChar; inSize: integer; outSize: integer): integer;
var
    srcSize: size_t;
    dstSize: size_t;
    res: size_t;
begin
    result := 0;
    srcSize := inSize;
    dstSize := outSize;
    res := LZ4F_decompress(g_dCtx, _out, @dstSize, _in, @srcSize, Nil);
    if res <> 0 then
    begin
        mainUnit.Memo.Lines.Add('Error decompressing frame : unfinished frame');
        exit;
    end;
    if srcSize <> size_t(inSize) then
    begin
        mainUnit.Memo.Lines.Add('Error decompressing frame : read size incorrect');
        exit;
    end;
    result := integer(dstSize);
end;

function TmainUnit.BMK_findMaxMem(requiredMem: uint64): size_t;
const
    MAX_MEM = (1984 shl 20);
var
    step: size_t;
    testmem: pByte;
begin
    step := 64 shl 20;
    testmem := nil;
    requiredMem := ((requiredMem shr 25) + 1) shl 26;
    if requiredMem > MAX_MEM then
        requiredMem := MAX_MEM;
    inc(requiredMem, 2 * step);
    while true do
    begin
        dec(requiredMem, step);
        testmem := allocmem(requiredMem);
        if testmem <> nil then
            break;
    end;
    freemem(testmem);
    result := requiredMem - step;
end;

procedure TmainUnit.btClearClick(Sender: TObject);
begin
    Memo.Clear;
end;

procedure TmainUnit.btGoClick(Sender: TObject);
var
    LFileStream: TFileStream;
    LMemStream: TMemoryStream;
begin
    if not checkInfileexists then
        exit;
    try
        try
            // create file stream of test data
            LFileStream := TFileStream.Create(edFilename.Text, fmOpenRead);

            // read data into memory
            LMemStream := TMemoryStream.Create();
            LMemStream.CopyFrom(LFileStream, 0);

            LFileStream.Free;
            // lz4dtest(LMemStream);

            LMemStream.Free;
        except

        end;
    finally

    end;
end;

procedure TmainUnit.btHash32Click(Sender: TObject);
const
    blockSize: size_t = 64 * 1024;
var
    buffer: pAnsiChar;
    LFileStream: TFileStream;
    state: XXH64_state_t;
    bytesRead: cardinal;
    h32: cardinal;
begin
    if not checkInfileexists then
        exit;
    XXH32_reset(PXXH32_state_t(@state), 0);
    buffer := allocmem(blockSize);
    LFileStream := TFileStream.Create(edFilename.Text, fmOpenRead);
    bytesRead := LFileStream.Read(buffer^, blockSize);
    while bytesRead > 0 do
    begin
        XXH32_update(PXXH32_state_t(@state), buffer, bytesRead);
        bytesRead := LFileStream.Read(buffer^, blockSize);
    end;
    LFileStream.Free;

    h32 := XXH32_digest(PXXH32_state_t(@state));

    Memo.Lines.Add(format('%x', [h32]));
end;

procedure TmainUnit.btHash64Click(Sender: TObject);
const
    blockSize: size_t = 64 * 1024;
var
    buffer: pAnsiChar;
    LFileStream: TFileStream;
    state: XXH64_state_t;
    bytesRead: cardinal;
    h64: uint64;
begin
    if not checkInfileexists then
        exit;

    XXH64_reset(@state, 0);
    buffer := allocmem(blockSize);
    LFileStream := TFileStream.Create(edFilename.Text, fmOpenRead);
    bytesRead := LFileStream.Read(buffer^, blockSize);
    while bytesRead > 0 do
    begin
        XXH64_update(@state, buffer, bytesRead);
        bytesRead := LFileStream.Read(buffer^, blockSize);
    end;
    LFileStream.Free;

    h64 := XXH64_digest(@state);

    Memo.Lines.Add(format('%x', [h64]));
end;

procedure TmainUnit.btSelectClick(Sender: TObject);
var
    auxstr: string;
begin
    auxstr := 'All Files (*.*)|*.*';
    With FileOpenDlg do
    begin
        Title := 'Select File';
        DefaultFolder := extractFilePath(application.ExeName);
        Execute;
        edFilename.Text := Filename;
    end;
end;

procedure TmainUnit.btTestCompFunctionsClick(Sender: TObject);
type
    TcompressionFunction = function(c1: pAnsiChar; c2: pAnsiChar; d: integer): integer;
{$IFDEF USE_EXTERNAL_OBJ_LIBS}
    TInitFunction = function(c1: pAnsiChar): pointer; cdecl;
{$ELSE}
    TInitFunction = function(c1: pAnsiChar): pointer;
{$ENDIF}
var
    LFileStream: TFileStream;
    fileIdx: integer;
    orig_buff: pAnsiChar;
    inFileSize: uint64;
    benchedSize: size_t;
    inFileName: string;
    chunkP: PchunkParameters;
    nbChunks: integer;
    maxCompressedChunkSize: integer;
    compressedBuffSize: integer;
    compressed_buff: pAnsiChar;
    readSize: size_t;
    loopNb, nb_loops, chunkNb: integer;
    cSize: size_t;
    ratio: double;
    compressorName: string;
    bestTime: double;
    i: integer;
    remaining: size_t;
    _in, _out: pAnsiChar;
    compressionFunction: TcompressionFunction;
    InitFunction: TInitFunction;
    averageTime: double;
    milliTime1, millitime2: double;
    ii: size_t;
begin
    fileIdx := 0;
    compressionFunction := nil;
    stateLZ4 := LZ4_createStream();
    stateLZ4HC := LZ4_createStreamHC();
    if not checkInfileexists then
        exit;
    if cbCompressionFunction.ItemIndex <= 0 then
    begin
        Memo.Lines.Add('No compression function selected');
        exit;
    end;
    inFileName := edFilename.Text;
    LFileStream := TFileStream.Create(inFileName, fmOpenRead);
    inFileSize := LFileStream.Size;
    benchedSize := BMK_findMaxMem(inFileSize) div 2;
    if (benchedSize > inFileSize) then
        benchedSize := inFileSize;
    if (benchedSize < inFileSize) then
        Memo.Lines.Add(format('Not enough memory for %s full size; testing %i MB only', [inFileName, benchedSize shr 20]));

    chunkP := allocmem(((benchedSize div size_t(chunkSize)) + 1) * sizeof(chunkParameters));
    orig_buff := allocmem(size_t(benchedSize));
    nbChunks := integer((integer(benchedSize) + (chunkSize - 1)) div chunkSize);
    maxCompressedChunkSize := LZ4_compressBound(chunkSize);
    compressedBuffSize := nbChunks * maxCompressedChunkSize;
    compressed_buff := allocmem(size_t(compressedBuffSize));
    if (orig_buff = nil) or (compressed_buff = nil) then
    begin
        Memo.Lines.Add('Error: not enough memory!');
        if orig_buff <> nil then
            freemem(orig_buff);
        if compressed_buff <> nil then
            freemem(compressed_buff);
        freemem(chunkP);
        LFileStream.Free;
        exit;
    end;
    Memo.Lines.Add(format('Loading %s...       ', [inFileName]));
    readSize := LFileStream.Read(orig_buff^, benchedSize);
    LFileStream.Free;
    if (readSize <> benchedSize) then
    begin
        Memo.Lines.Add(format('Error: problem reading file %s !!', [inFileName]));
        if orig_buff <> nil then
            freemem(orig_buff);
        if compressed_buff <> nil then
            freemem(compressed_buff);
        freemem(chunkP);
    end;

    bestTime := 100000000.;
    remaining := benchedSize;
    _in := orig_buff;
    _out := compressed_buff;
    nbChunks := integer((integer(benchedSize) + (chunkSize - 1)) div chunkSize);
    for i := 0 to nbChunks - 1 do
    begin
        chunkP[i].id := i;
        chunkP[i].origBuffer := _in;
        inc(_in, chunkSize);
        if (integer(remaining) > chunkSize) then
        begin
            chunkP[i].origSize := chunkSize;
            dec(remaining, chunkSize);
        end
        else
        begin
            chunkP[i].origSize := integer(remaining);
            remaining := 0;
        end;
        chunkP[i].compressedBuffer := _out;
        inc(_out, maxCompressedChunkSize);
        chunkP[i].compressedSize := 0;
    end;
    InitFunction := nil;

    if cbCompressionFunction.ItemIndex = 1 then // LZ4_compress
    begin
        compressorName := 'LZ4_compress';
        compressionFunction := local_LZ4_compress;
    end
    else if cbCompressionFunction.ItemIndex = 2 then // LZ4_compress_limitedOutput
    begin
        compressorName := 'LZ4_compress_limitedOutput';
        compressionFunction := local_LZ4_compress_limitedOutput;
    end
    else if cbCompressionFunction.ItemIndex = 3 then // LZ4_compress_withState
    begin
        compressorName := 'LZ4_compress_withState';
        compressionFunction := local_LZ4_compress_withState;
    end
    else if cbCompressionFunction.ItemIndex = 4 then // LZ4_compress_withState
    begin
        compressorName := 'LZ4_compress_limitedOutput_withState';
        compressionFunction := local_LZ4_compress_withState;
    end
    else if cbCompressionFunction.ItemIndex = 5 then // LZ4_compress_continue
    begin
        compressorName := 'LZ4_compress_continue';
        InitFunction := LZ4_create;
        compressionFunction := local_LZ4_compress_continue;
    end
    else if cbCompressionFunction.ItemIndex = 6 then // LZ4_compress_limitedOutput_continue
    begin
        compressorName := 'LZ4_compress_limitedOutput_continue';
        InitFunction := LZ4_create;
        compressionFunction := local_LZ4_compress_limitedOutput_continue;
    end
    else if cbCompressionFunction.ItemIndex = 7 then // LZ4_compressHC
    begin
        compressorName := 'LZ4_compressHC';
        compressionFunction := local_LZ4_compressHC;
    end
    else if cbCompressionFunction.ItemIndex = 8 then // LZ4_compressHC_limitedOutput
    begin
        compressorName := 'LZ4_compressHC_limitedOutput';
        compressionFunction := local_LZ4_compressHC_limitedOutput;
    end
    else if cbCompressionFunction.ItemIndex = 9 then // LZ4_compressHC_withStateHC
    begin
        compressorName := 'LZ4_compressHC_withStateHC';
        compressionFunction := local_LZ4_compressHC_withStateHC;
    end
    else if cbCompressionFunction.ItemIndex = 10 then // LZ4_compressHC_withStateHC
    begin
        compressorName := 'LZ4_compressHC_limitedOutput_withStateHC';
        compressionFunction := local_LZ4_compressHC_limitedOutput_withStateHC;
    end
    else if cbCompressionFunction.ItemIndex = 11 then // LZ4_compressHC_continue
    begin
        compressorName := 'LZ4_compressHC_continue';
        compressionFunction := local_LZ4_compressHC_continue;
        InitFunction := LZ4_createHC;
    end
    else if cbCompressionFunction.ItemIndex = 12 then // LZ4_compressHC_limitedOutput_continue
    begin
        compressorName := 'LZ4_compressHC_limitedOutput_continue';
        compressionFunction := local_LZ4_compressHC_limitedOutput_continue;
        InitFunction := LZ4_createHC;
    end
    else if cbCompressionFunction.ItemIndex = 13 then // LZ4_compress_forceDict
    begin
        compressorName := 'LZ4_compress_forceDict';
        compressionFunction := local_LZ4_compress_forceDict;

        InitFunction := local_LZ4_resetDictT;
    end
    else if cbCompressionFunction.ItemIndex = 14 then // LZ4F_compressFrame
    begin
        compressorName := 'LZ4F_compressFrame';
        compressionFunction := local_LZ4F_compressFrame;
        chunkP[0].origSize := integer(benchedSize);
        nbChunks := 1;
    end
    else if cbCompressionFunction.ItemIndex = 15 then // LZ4_saveDict
    begin
        compressorName := 'LZ4_saveDict';
        compressionFunction := local_LZ4_saveDict;
        LZ4_loadDict(@LZ4_dict, chunkP[0].origBuffer, chunkP[0].origSize);
    end
    else if cbCompressionFunction.ItemIndex = 16 then // LZ4_saveDictHC
    begin
        compressorName := 'LZ4_saveDictHC';
        compressionFunction := local_LZ4_saveDictHC;
        LZ4_loadDictHC(@LZ4_dictHC, chunkP[0].origBuffer, chunkP[0].origSize);
    end;

    for ii := 0 to benchedSize - 1 do
        compressed_buff[ii] := Ansichar(ii);

    for loopNb := 1 to nbIterations do
    begin
        nb_loops := 0;
        Stopwatch.start;
        Elapsed := Stopwatch.Elapsed;
        milliTime1 := Elapsed.TotalMilliseconds;

        while true do
        begin
            Elapsed := Stopwatch.Elapsed;
            if Elapsed.TotalMilliseconds - milliTime1 > TIMELOOP then
                break;
            if (@InitFunction <> Nil) then
                ctx := InitFunction(chunkP[0].origBuffer);
            for chunkNb := 0 to nbChunks - 1 do
            begin
                chunkP[chunkNb].compressedSize := compressionFunction(chunkP[chunkNb].origBuffer, chunkP[chunkNb].compressedBuffer,
                  chunkP[chunkNb].origSize);
                if (chunkP[chunkNb].compressedSize = 0) then
                begin
                    Memo.Lines.Add(format('ERROR ! %s() = 0 !!', [compressorName]));
                    exit;
                end;
            end;
            if (@InitFunction <> Nil) then
{$IFDEF USE_EXTERNAL_OBJ_LIBS}
                LZ4_freeStream(ctx);
{$ELSE}
                freemem(ctx);
{$ENDIF}
            inc(nb_loops);
        end;
        Elapsed := Stopwatch.Elapsed;
        Stopwatch.stop;
        millitime2 := Elapsed.TotalMilliseconds;
        averageTime := (millitime2 - milliTime1) / nb_loops;
        if (averageTime < bestTime) then
            bestTime := averageTime;
        cSize := 0;
        for chunkNb := 0 to nbChunks - 1 do
            inc(cSize, chunkP[chunkNb].compressedSize);
        ratio := cSize / benchedSize * 100.;
        Memo.Lines.Add(format('%s %d ->%d %f, %f MB/s', [compressorName, integer(benchedSize), integer(cSize), ratio,
          (benchedSize / bestTime) / 1000.]));
    end;
    LZ4_freeStream(stateLZ4);
    LZ4_freeStreamHC(stateLZ4HC);

    freemem(orig_buff);
    freemem(compressed_buff);
    freemem(chunkP);
    Memo.Lines.Add(format('%s test ended', [compressorName]));
end;

procedure TmainUnit.btTestDecompFunctionsClick(Sender: TObject);
type
    TDecompressionFunction = function(c1: pAnsiChar; c2: pAnsiChar; d1: integer; d2: integer): integer;

var
    LFileStream: TFileStream;
    fileIdx: integer;
    orig_buff: pAnsiChar;
    errorCode: size_t;
    inFileSize: uint64;
    benchedSize: size_t;
    inFileName: string;
    chunkP: PchunkParameters;
    nbChunks: integer;
    maxCompressedChunkSize: integer;
    compressedBuffSize: integer;
    compressed_buff: pAnsiChar;
    readSize: size_t;
    crcOriginal: cardinal;
    loopNb, nb_loops, chunkNb : integer;
    cSize: size_t;
    ratio: double;
    compressorName: string;
    bestTime: double;
    i: integer;
    remaining: size_t;
    _in, _out: pAnsiChar;
    decompressionFunction: TDecompressionFunction;
    averageTime: double;
    milliTime1, millitime2: double;
    ii: size_t;
    dName: string;
    decodedSize: integer;
    crcDecoded: cardinal;
begin
    fileIdx := 0;
    decompressionFunction := nil;
    errorCode := LZ4F_createDecompressionContext(g_dCtx, LZ4F_VERSION);
    if (LZ4F_isError(errorCode)) then
    begin
        Memo.Lines.Add('dctx allocation issue');
        exit;
    end;
    if not checkInfileexists then
        exit;
    if cbDecompressionFunction.ItemIndex <= 0 then
    begin
        Memo.Lines.Add('No decompression function selected');
        exit;
    end;
    inFileName := edFilename.Text;
    LFileStream := TFileStream.Create(inFileName, fmOpenRead);
    inFileSize := LFileStream.Size;
    benchedSize := BMK_findMaxMem(inFileSize) div 2;
    if (benchedSize > inFileSize) then
        benchedSize := inFileSize;
    if (benchedSize < inFileSize) then
        Memo.Lines.Add(format('Not enough memory for %s full size; testing %i MB only', [inFileName, benchedSize shr 20]));

    chunkP := allocmem(((benchedSize div size_t(chunkSize)) + 1) * sizeof(chunkParameters));
    orig_buff := allocmem(size_t(benchedSize));
    nbChunks := integer((integer(benchedSize) + (chunkSize - 1)) div chunkSize);
    maxCompressedChunkSize := LZ4_compressBound(chunkSize);
    compressedBuffSize := nbChunks * maxCompressedChunkSize;
    compressed_buff := allocmem(size_t(compressedBuffSize));
    if (orig_buff = nil) or (compressed_buff = nil) then
    begin
        Memo.Lines.Add('Error: not enough memory!');
        if orig_buff <> nil then
            freemem(orig_buff);
        if compressed_buff <> nil then
            freemem(compressed_buff);
        freemem(chunkP);
        LFileStream.Free;
        exit;
    end;
    Memo.Lines.Add(format('Loading %s...       ', [inFileName]));
    readSize := LFileStream.Read(orig_buff^, benchedSize);
    LFileStream.Free;
    if (readSize <> benchedSize) then
    begin
        Memo.Lines.Add(format('Error: problem reading file %s !!', [inFileName]));
        if orig_buff <> nil then
            freemem(orig_buff);
        if compressed_buff <> nil then
            freemem(compressed_buff);
        freemem(chunkP);
    end;
    crcOriginal := XXH32(orig_buff, cardinal(benchedSize), 0);

    cSize := 0;
    ratio := 0.;
    bestTime := 100000000.;
    remaining := benchedSize;
    _in := orig_buff;
    _out := compressed_buff;
    nbChunks := integer((integer(benchedSize) + (chunkSize - 1)) div chunkSize);
    for i := 0 to nbChunks - 1 do
    begin
        chunkP[i].id := i;
        chunkP[i].origBuffer := _in;
        inc(_in, chunkSize);
        if (integer(remaining) > chunkSize) then
        begin
            chunkP[i].origSize := chunkSize;
            dec(remaining, chunkSize);
        end
        else
        begin
            chunkP[i].origSize := integer(remaining);
            remaining := 0;
        end;
        chunkP[i].compressedBuffer := _out;
        inc(_out, maxCompressedChunkSize);
        chunkP[i].compressedSize := 0;
    end;

    for chunkNb := 0 to nbChunks - 1 do
    begin
        chunkP[chunkNb].compressedSize := LZ4_compress(chunkP[chunkNb].origBuffer, chunkP[chunkNb].compressedBuffer,
          chunkP[chunkNb].origSize);
        if (chunkP[chunkNb].compressedSize = 0) then
        begin
            Memo.Lines.Add(format('ERROR ! %s() = 0 !! ', ['LZ4_compress']));
            exit;
        end;
    end;
    if cbDecompressionFunction.ItemIndex = 1 then // LZ4_decompress_fast
    begin
        dName := 'LZ4_decompress_fast';
        decompressionFunction := local_LZ4_decompress_fast;
    end
    else if cbDecompressionFunction.ItemIndex = 2 then // LZ4_decompress_fast_withPrefix64k
    begin
        dName := 'LZ4_decompress_fast_withPrefix64k';
        decompressionFunction := local_LZ4_decompress_fast_withPrefix64k;
    end
    else if cbDecompressionFunction.ItemIndex = 3 then // LZ4_decompress_fast_usingDict
    begin
        dName := 'LZ4_decompress_fast_usingDict';
        decompressionFunction := local_LZ4_decompress_fast_usingDict;
    end
    else if cbDecompressionFunction.ItemIndex = 4 then // LZ4_decompress_safe
    begin
        dName := 'LZ4_decompress_safe';
        decompressionFunction := local_LZ4_decompress_safe;
    end
    else if cbDecompressionFunction.ItemIndex = 5 then // LZ4_decompress_safe_withPrefix64k
    begin
        dName := 'LZ4_decompress_safe_withPrefix64k';
        decompressionFunction := local_LZ4_decompress_safe_withPrefix64k;
    end
    else if cbDecompressionFunction.ItemIndex = 6 then // LZ4_decompress_safe_usingDict
    begin
        dName := 'LZ4_decompress_safe_usingDict';
        decompressionFunction := local_LZ4_decompress_safe_usingDict;
    end
    else if cbDecompressionFunction.ItemIndex = 7 then // LZ4_decompress_safe_partial
    begin
        dName := 'LZ4_decompress_safe_partial';
        decompressionFunction := local_LZ4_decompress_safe_partial;
    end
    else if cbDecompressionFunction.ItemIndex = 8 then // LZ4_decompress_safe_forceExtDict
    begin
        dName := 'LZ4_decompress_safe_forceExtDict';
        decompressionFunction := local_LZ4_decompress_safe_forceExtDict;
    end
    else if cbDecompressionFunction.ItemIndex = 9 then // LZ4F_decompress
    begin
        dName := 'LZ4F_decompress';
        decompressionFunction := local_LZ4F_decompress;
        errorCode := LZ4F_compressFrame(compressed_buff, compressedBuffSize, orig_buff, benchedSize, Nil);
        if LZ4F_isError(errorCode) then
        begin
            Memo.Lines.Add('Preparation error compressing frame');
            exit;
        end;
        chunkP[0].origSize := integer(benchedSize);
        chunkP[0].compressedSize := integer(errorCode);
        nbChunks := 1;
    end;

    for ii := 0 to benchedSize - 1 do
        orig_buff[ii] := #0; // zeroing source area, for CRC checking
    for loopNb := 1 to nbIterations do
    begin
        nb_loops := 0;
        Stopwatch.start;
        Elapsed := Stopwatch.Elapsed;
        milliTime1 := Elapsed.TotalMilliseconds;

        while true do
        begin
            Elapsed := Stopwatch.Elapsed;
            if Elapsed.TotalMilliseconds - milliTime1 > TIMELOOP then
                break;
            for chunkNb := 0 to nbChunks - 1 do
            begin
                decodedSize := decompressionFunction(chunkP[chunkNb].compressedBuffer, chunkP[chunkNb].origBuffer,
                  chunkP[chunkNb].compressedSize, chunkP[chunkNb].origSize);
                if (chunkP[chunkNb].origSize <> decodedSize) then
                begin
                    Memo.Lines.Add(format('ERROR ! %s() == %d != %d !!', [dName, decodedSize, chunkP[chunkNb].origSize]));
                    exit;
                end;
            end;
            inc(nb_loops);
        end;
        Elapsed := Stopwatch.Elapsed;
        Stopwatch.stop;
        millitime2 := Elapsed.TotalMilliseconds;
        averageTime := (millitime2 - milliTime1) / nb_loops;
        if (averageTime < bestTime) then
            bestTime := averageTime;

        Memo.Lines.Add(format('%s :%d -> %f MB/s', [dName, integer(benchedSize),
          (benchedSize / bestTime) / 1000.]));

        crcDecoded := XXH32(orig_buff, integer(benchedSize), 0);
        if (crcOriginal <> crcDecoded) then
            Memo.Lines.Add('WARNING !!! %14s : Invalid Checksum');
    end;
    freemem(orig_buff);
    freemem(compressed_buff);
    freemem(chunkP);
    Memo.Lines.Add(format('%s test ended', [compressorName]));
end;

procedure TmainUnit.cbBlockSizeSelect(Sender: TObject);
var
    B: integer;
begin
    B := cbBlockSize.ItemIndex + 4;
    chunkSize := 1 shl (8 + 2 * B);
    Memo.Lines.Add(format('Using Block Size of %d KB', [chunkSize shr 10]));
end;

procedure TmainUnit.cbIterationsSelect(Sender: TObject);
begin
    nbIterations := cbIterations.ItemIndex + 1;
    Memo.Lines.Add(format('%d iterations', [nbIterations]));
end;

function TmainUnit.checkInfileexists: boolean;
begin
    result := false;
    if edFilename.Text = '' then
    begin
        Memo.Lines.Add('Source file needed for test.');
        exit;
    end;
    if not FileExists(edFilename.Text) then
    begin
        Memo.Lines.Add('File not found. Please use valid test file.');
        exit();
    end;
    result := true;
end;

procedure TmainUnit.FormCreate(Sender: TObject);
begin
    SetMinimumBlockAlignment(mba16Byte);
    Memo.Lines.Add('LZ4 Delphi Binding Library Test');
    Stopwatch := TStopwatch.StartNew;
    Stopwatch.reset;
    cbCompressionFunction.ItemIndex := 1;
    cbDecompressionFunction.ItemIndex := 1;
end;

end.
