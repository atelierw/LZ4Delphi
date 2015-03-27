(*
  LZ4DElphi
  Copyright (C) 2015, Jose Pascoa (atelierwebgm@gmail.com)
  BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

  *************************************************************************
  LZ4 - Fast LZ compression algorithm
  xxHash - Fast Hash algorithm
  LZ4 source repository : http://code.google.com/p/lz4/
  xxHash source repository : http://code.google.com/p/xxhash/
  Copyright (c) 2011-2014, Yann Collet
  BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

  LZ4StreamingTest
  A modification of lz4-delphi - Delphi - bindings for [lz4]
  Project repository: https://github.com/Hugie/lz4-delphi
  Copyright (c) 2014, Hanno Hugenberg
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


unit lz4d.test;
{$I lz4AppDefines.inc}
// - include speed comparism to SynLZ
{.$Define WithSynLZTest}

// - write out temp results to files, to be compare and tesable with external Lz4 tools
{.$Define WriteOutResults}

interface

uses
  System.Classes,
  System.Diagnostics,
  {$IFDEF WithSynLZTest}
  SynLZ,
  {$ENDIF}
  lz4d,
{$ifdef USE_EXTERNAL_OBJ_LIBS}
 LZ4Externals;
{$else}
  lz4;
{$endif}

procedure lz4dtest( AMemStream: TMemoryStream);

implementation

uses
  System.Math,
  System.SysUtils,
  lz4Main;

const
  CIterCount = 6;

//test data
type
  TTestResult = record
    SizeRaw:      Int64;
    SizeEnc:      Int64;
    TimeEncMs:    Int64;
    TimeDecMs:    Int64;
  end;

//test function code
type TTestMemoryFunc = procedure( AInPtr, AOutPtr: PByte; AInSize, AOutSize: Int64; var ATestData: TTestResult);
type TTestStreamFunc = procedure( AInStream, AOutStream: TStream; var ATestData: TTestResult);

//output results
procedure WriteResults(  AName: String;  AResult: TTestResult; AEncoding: Boolean = True );
var
  LMBSecC, LMBSecD: Double;
begin
  if (AEncoding) then
  begin

    // * Encoding * ///
    If ( AResult.TimeEncMs > 0 ) then
      LMBSecC := (AResult.SizeRaw / (1024*1024)) / (AResult.TimeEncMs / 1000)
    else
      LMBSecC := 0;
    mainUnit.Memo.Lines.Add(Format( #13 + '%10s: %12d -> %12d (%6.2f%%), %12.2f MB/s', [ AName, AResult.SizeRaw, AResult.SizeEnc, (AResult.SizeEnc / AResult.SizeRaw) * 100, LMBSecC]));
//    System.Write(Format( #13 + '%10s: %12d -> %12d (%6.2f%%), %12.2f MB/s', [ AName, AResult.SizeRaw, AResult.SizeEnc, (AResult.SizeEnc / AResult.SizeRaw) * 100, LMBSecC]));
  end else
  begin
    // * Decoding * ///
    If ( AResult.TimeDecMs > 0 ) then
      LMBSecD := (AResult.SizeRaw / (1024*1024)) / (AResult.TimeDecMs / 1000)
    else
      LMBSecD := 0;
     mainUnit.Memo.Lines.Add(Format( #13 + '%10s: %12d <- %12d (%6.2f%%), %12.2f MB/s', [ AName, AResult.SizeRaw, AResult.SizeEnc, (AResult.SizeEnc / AResult.SizeRaw) * 100, LMBSecD]));
//    System.Write(Format( #13 + '%10s: %12d <- %12d (%6.2f%%), %12.2f MB/s', [ AName, AResult.SizeRaw, AResult.SizeEnc, (AResult.SizeEnc / AResult.SizeRaw) * 100, LMBSecD]));
  end;
end;

procedure TestRun( AFunc: TTestMemoryFunc;  AFuncName: String;  AInPtr, AOutPtr: PByte; AInSize, AOutSize: Int64; var ATestData: TTestResult; AEncode: Boolean); overload;
var
  LCounter: Integer;
begin
  //reset time value to max to allow min(timeA, timeB) for fastest run
  if (AEncode) then ATestData.TimeEncMs := $7FFFFFFFFFFFFF else ATestData.TimeDecMs := $7FFFFFFFFFFFFF;

  for LCounter := 1 to CIterCount do
  begin
    AFunc ( AInPtr, AOutPtr, AInSize, AOutSize, ATestData );
    if (LCounter < CIterCount) then
      WriteResults( Format( '%3d %6s',  [LCounter, AFuncName] ), ATestData, AEncode )
    else
      WriteResults( Format( '%10s',     [AFuncName] ), ATestData, AEncode )
  end;
end;


procedure TestRun( AFunc: TTestStreamFunc;  AFuncName: String;  AInStream, AOutStream: TStream; var ATestData: TTestResult; AEncode: Boolean); overload;
var
  LCounter: Integer;
begin
  for LCounter := 1 to CIterCount do
  begin
    AFunc ( AInStream, AOutStream, ATestData );
    if (LCounter < CIterCount) then
      WriteResults( Format( '%3d %6s',  [LCounter, AFuncName] ), ATestData, AEncode )
    else
      WriteResults( Format( '%10s',     [AFuncName] ), ATestData, AEncode )
  end;
end;

////////// * test functions * ///////////////

{$IFDEF WithSynLZTest}

procedure Test_SynLZ_Encode( AInPtr, AOutPtr: PByte; AInSize, AOutSize: Int64; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  try
    LTimer := TStopwatch.StartNew();
    ATestData.SizeRaw   := AInSize;
    ATestData.SizeEnc   := SynLZcompress1asm( PAnsiChar(AInPtr), AOutSize, PAnsiChar(AOutPtr) );
    ATestData.TimeEncMs := Min(LTimer.ElapsedMilliseconds, ATestData.TimeEncMs);
  except
    on E: Exception do
      mainUnit.Memo.Lines.Add(E.ClassName, ': ', E.Message);
  end;
end;

procedure Test_SynLZ_Decode( AInPtr, AOutPtr: PByte; AInSize, AOutSize: Int64; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  try
    LTimer := TStopwatch.StartNew();
    ATestData.SizeRaw   := SynLZdecompress1asm( PAnsiChar(AInPtr), AInSize, PAnsiChar(AOutPtr));
    ATestData.SizeEnc   := AInSize;
    ATestData.TimeDecMs := Min(LTimer.ElapsedMilliseconds, ATestData.TimeDecMs);
  except
    on E: Exception do
      mainUnit.Memo.Lines.Add(E.ClassName, ': ', E.Message);
  end;
end;

{$ENDIF}


procedure Test_lz4_Encode( AInPtr, AOutPtr: PByte; AInSize, AOutSize: Int64; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  try
    LTimer := TStopwatch.StartNew();
    ATestData.SizeRaw     := AInSize;
    ATestData.SizeEnc     := TLZ4.Encode( AInPtr, AOutPtr, AInSize, AOutSize );
    ATestData.TimeEncMs   := Min(LTimer.ElapsedMilliseconds, ATestData.TimeEncMs);

  except
    on E: Exception do
      mainUnit.Memo.Lines.Add(E.ClassName+ ': '+ E.Message);
  end;
end;

procedure Test_lz4_Decode( AInPtr, AOutPtr: PByte; AInSize, AOutSize: Int64; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  try
    LTimer := TStopwatch.StartNew();
    ATestData.SizeRaw   := TLZ4.Decode(AInPtr, AOutPtr, AInSize, AOutSize );
    ATestData.SizeEnc   := AInSize;
    ATestData.TimeDecMs := Min(LTimer.ElapsedMilliseconds, ATestData.TimeDecMs);
  except
    on E: Exception do
      mainUnit.Memo.Lines.Add(E.ClassName+ ': '+ E.Message);
  end;
end;


procedure Test_lz4s_Encode_Memory( AInPtr, AOutPtr: PByte; AInSize, AOutSize: Int64; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  try
    LTimer := TStopwatch.StartNew();
    ATestData.SizeRaw     := AInSize;
    ATestData.SizeEnc     := TLZ4.Stream_Encode( AInPtr, AOutPtr, AInSize, AOutSize );
    ATestData.TimeEncMs   := Min(LTimer.ElapsedMilliseconds, ATestData.TimeEncMs);

  except
    on E: Exception do
      mainUnit.Memo.Lines.Add(E.ClassName+ ': '+ E.Message);
  end;
end;

procedure Test_lz4s_Encode_Memory_NoCheck( AInPtr, AOutPtr: PByte; AInSize, AOutSize: Int64; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  try
    LTimer := TStopwatch.StartNew();
    ATestData.SizeRaw     := AInSize;
    ATestData.SizeEnc     := TLZ4.Stream_Encode( AInPtr, AOutPtr, AInSize, AOutSize, sbs4MB, False );
    ATestData.TimeEncMs   := Min(LTimer.ElapsedMilliseconds, ATestData.TimeEncMs);

  except
    on E: Exception do
      mainUnit.Memo.Lines.Add(E.ClassName+ ': '+ E.Message);
  end;
end;

procedure Test_lz4s_Encode_Stream( ASourceStream, ATargetStream: TStream; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  ASourceStream.Position := 0;
  ATargetStream.Position := 0;

  LTimer := TStopwatch.StartNew();
  ATestData.SizeRaw   := ASourceStream.Size;
  ATestData.SizeEnc   := TLZ4.Stream_Encode( ASourceStream, ATargetStream );
  ATestData.TimeEncMs := Min(LTimer.ElapsedMilliseconds, ATestData.TimeEncMs);
end;

procedure Test_lz4s_Encode_Stream_NoCheck( ASourceStream, ATargetStream: TStream; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  ASourceStream.Position := 0;
  ATargetStream.Position := 0;

  LTimer := TStopwatch.StartNew();
  ATestData.SizeRaw   := ASourceStream.Size;
  ATestData.SizeEnc   := TLZ4.Stream_Encode( ASourceStream, ATargetStream, sbs4MB, False );
  ATestData.TimeEncMs := Min(LTimer.ElapsedMilliseconds, ATestData.TimeEncMs);
end;

procedure Test_lz4s_Decode_Stream( ASourceStream, ATargetStream: TStream; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  ASourceStream.Position := 0;
  ATargetStream.Position := 0;

  LTimer := TStopwatch.StartNew();
  ATestData.SizeRaw    := TLZ4.Stream_Decode( ASourceStream, ATargetStream );
  //ATestData.SizeEnc    := ASourceStream.Size; we can not see how large the input data is, Source is always max size - keep previous data
  ATestData.TimeDecMs  := LTimer.ElapsedMilliseconds;
end;

procedure Test_lz4s_Decode_Memory( AInPtr, AOutPtr: PByte; AInSize, AOutSize: Int64; var ATestData: TTestResult);
var
  LTimer: TStopwatch;
begin
  try
    LTimer := TStopwatch.StartNew();
    ATestData.SizeRaw     := TLZ4.Stream_Decode( AInPtr, AOutPtr, AInSize, AOutSize );
    ATestData.SizeEnc     := AInSize;
    ATestData.TimeDecMs := Min(LTimer.ElapsedMilliseconds, ATestData.TimeDecMs);

  except
    on E: Exception do
      mainUnit.Memo.Lines.Add(E.ClassName+ ': '+ E.Message);
  end;
end;

procedure lz4dtest( AMemStream: TMemoryStream );
var
  LSource:  TMemoryStream;
  LTarget:  TMemoryStream;
  LResult : TTestResult;

  LInSize: Int64;
begin
  try
    LTarget      := TMemoryStream.Create();
    LTarget.Size := LZ4_compressBound( AMemStream.Size );

    LSource      := TMemoryStream.Create();
    LSource.CopyFrom( AMemStream, 0 );
  except
    on E:Exception do
    begin
      mainUnit.Memo.Lines.Add('Could not create destination memory: ' + E.ToString());
      Exit();
    end;
  end;

  /// * LZ4 standard * ///

  TestRun( Test_lz4_Encode, 'LZ4', LSource.Memory, LTarget.Memory, LSource.Size, LTarget.Size, LResult, true );
   mainUnit.Memo.Lines.Add('');

  {$IFDEF WriteOutResults}
  LTarget.Position := 0;
  LOutFile := TFileStream.Create('LZ4.enc', fmCreate);
  LOutFile.CopyFrom( LTarget, LResult.SizeEnc );
  LOutFile.Free;
  {$Endif}

  LInSize := LResult.SizeEnc;
  TestRun( Test_lz4_Decode, 'LZ4', LTarget.Memory, LSource.Memory, LInSize, LSource.Size, LResult, false );
   mainUnit.Memo.Lines.Add(#10#13);

  {$IFDEF WriteOutResults}
  LSource.Position := 0;
  LOutFile := TFileStream.Create('LZ4.dec', fmCreate);
  LOutFile.CopyFrom( LSource, LResult.SizeRaw );
  LOutFile.Free;
  {$ENDIF}

  //compare Data:
  if not CompareMem( AMemStream.Memory, LSource.Memory, AMemstream.Size ) then
    mainUnit.Memo.Lines.Add('LZ4   input != (input->enc->dec)  <== bad output data');
  //newline
   mainUnit.Memo.Lines.Add('');

  //copy original source data back
  LSource.Clear();
  LSource.CopyFrom( AMemStream, 0 );

  TestRun( Test_lz4s_Encode_Stream, 'LZ4SS', LSource, LTarget, LResult, true );
  mainUnit.Memo.Lines.Add('');

  {$IFDEF WriteOutResults}
  LTarget.Position := 0;
  LOutFile := TFileStream.Create('LZ4SS.enc', fmCreate);
  LOutFile.CopyFrom( LTarget, LResult.SizeEnc );
  LOutFile.Free;
  {$ENDIF}

  TestRun( Test_lz4s_Decode_Stream, 'LZ4SS', LTarget, LSource, LResult, false );
  mainUnit.Memo.Lines.Add(#10#13);

  {$IFDEF WriteOutResults}
  LSource.Position := 0;
  LOutFile := TFileStream.Create('LZ4SS.dec', fmCreate);
  LOutFile.CopyFrom( LSource, LResult.SizeRaw );
  LOutFile.Free;
  {$ENDIF}

  //compare Data:
  if not CompareMem( AMemStream.Memory, LSource.Memory, AMemstream.Size ) then
   mainUnit.Memo.Lines.Add('LZ4SS input != (input->enc->dec)  <== bad output data');

  //newline
  mainUnit.Memo.Lines.Add('');

  //copy original source data back
  LSource.Clear();
  LSource.CopyFrom( AMemStream, 0 );

  TestRun( Test_lz4s_Encode_Stream_NoCheck, 'LZ4SSN', LSource, LTarget, LResult, true );
  mainUnit.Memo.Lines.Add('');

  {$IFDEF WriteOutResults}
  LTarget.Position := 0;
  LOutFile := TFileStream.Create('LZ4SSN.enc', fmCreate);
  LOutFile.CopyFrom( LTarget, LResult.SizeEnc );
  LOutFile.Free;
  {$ENDIF}

  TestRun( Test_lz4s_Decode_Stream, 'LZ4SSN', LTarget, LSource, LResult, false );
  mainUnit.Memo.Lines.Add(#10#13);

  {$IFDEF WriteOutResults}
  LSource.Position := 0;
  LOutFile := TFileStream.Create('LZ4SSN.dec', fmCreate);
  LOutFile.CopyFrom( LSource, LResult.SizeRaw );
  LOutFile.Free;
  {$ENDIF}

  //compare Data:
  if not CompareMem( AMemStream.Memory, LSource.Memory, AMemstream.Size ) then
    mainUnit.Memo.Lines.Add('LZ4SSN input != (input->enc->dec)  <== bad output data');
  //newline
  mainUnit.Memo.Lines.Add('');

  //copy original source data back
  LSource.Clear();
  LSource.CopyFrom( AMemStream, 0 );

  TestRun( Test_lz4s_Encode_Memory, 'LZ4SM', LSource.Memory, LTarget.Memory, LSource.Size, LTarget.Size, LResult, true );
  mainUnit.Memo.Lines.Add('');

  {$IFDEF WriteOutResults}
  LTarget.Position := 0;
  LOutFile := TFileStream.Create('LZ4SM.enc', fmCreate);
  LOutFile.CopyFrom( LTarget, LResult.SizeEnc );
  LOutFile.Free;
  {$ENDIF}

  LInSize := LResult.SizeEnc;
  TestRun( Test_lz4s_Decode_Memory, 'LZ4SM', LTarget.Memory, LSource.Memory, LInSize, LSource.Size, LResult, false );
  mainUnit.Memo.Lines.Add(#10#13);

  {$IFDEF WriteOutResults}
  LSource.Position := 0;
  LOutFile := TFileStream.Create('LZ4SM.dec', fmCreate);
  LOutFile.CopyFrom( LSource, LResult.SizeRaw );
  LOutFile.Free;
  {$ENDIF}

  //compare Data:
  if not CompareMem( AMemStream.Memory, LSource.Memory, AMemstream.Size ) then
    mainUnit.Memo.Lines.Add('LZ4SM input != (input->enc->dec)  <== bad output data');
  //newline
  mainUnit.Memo.Lines.Add('');

  //copy original source data back
  LSource.Clear();
  LSource.CopyFrom( AMemStream, 0 );

  TestRun( Test_lz4s_Encode_Memory_NoCheck, 'LZ4SMN', LSource.Memory, LTarget.Memory, LSource.Size, LTarget.Size, LResult, true );
   mainUnit.Memo.Lines.Add('');

  {$IFDEF WriteOutResults}
  LTarget.Position := 0;
  LOutFile := TFileStream.Create('LZ4SMN.enc', fmCreate);
  LOutFile.CopyFrom( LTarget, LResult.SizeEnc );
  LOutFile.Free;
  {$ENDIF}

  //use standard decode function - since this is handled by stream header info
  LInSize := LResult.SizeEnc;
  TestRun( Test_lz4s_Decode_Memory, 'LZ4SMN', LTarget.Memory, LSource.Memory, LInSize, LSource.Size, LResult, false );
    mainUnit.Memo.Lines.Add(#10#13);

  {$IFDEF WriteOutResults}
  LSource.Position := 0;
  LOutFile := TFileStream.Create('LZ4SMN.dec', fmCreate);
  LOutFile.CopyFrom( LSource, LResult.SizeRaw );
  LOutFile.Free;
  {$ENDIF}

  //compare Data:
  if not CompareMem( AMemStream.Memory, LSource.Memory, AMemstream.Size ) then
    mainUnit.Memo.Lines.Add('LZ4SMN input != (input->enc->dec)  <== bad output data');
  //newline
  mainUnit.Memo.Lines.Add('');


  {$IFDEF WithSynLZTest}
  TestRun( Test_SynLZ_Encode, 'SynLZ', LSource.Memory, LTarget.Memory, LSource.Size, LTarget.Size, LResult, true );
  mainUnit.Memo.Lines.Add('');

  LInSize := LResult.SizeEnc;
  TestRun( Test_SynLZ_Decode, 'SynLZ', LTarget.Memory, LSource.Memory, LInSize, LSource.Size, LResult, false );
  mainUnit.Memo.Lines.Add(#10#13);
  {$ENDIF}

  //cleanup
  LSource.Free;
  LTarget.Free;
end;

end.
