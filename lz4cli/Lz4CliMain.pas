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


unit Lz4CliMain;
{$WARN SYMBOL_PLATFORM OFF}
interface

{$I lz4AppDefines.inc}


uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, lz4io,
{$IFDEF USE_EXTERNAL_OBJ_LIBS}
    LZ4Externals;
{$ELSE}
lz4, lz4frame, lz4HC;
{$ENDIF}


type
    TLZ4Client = class(TForm)
        Panel1: TPanel;
        lblFiletoCompress: TLabel;
        edUncompressedFilename: TEdit;
        btInputSelect: TButton;
        Memo: TMemo;
        Panel2: TPanel;
        btClear: TButton;

        chkDisableStreamChksum: TCheckBox;
        lblBlockSize: TLabel;
        cbBlockSize: TComboBox;
        btVersion: TButton;
        chkOverwriteOutput: TCheckBox;
        btCompress: TButton;
        edCompressedFilename: TEdit;
        btOutputSelect: TButton;
        FileOpenDlg: TFileOpenDialog;
        chkLegacy: TCheckBox;
        cbCompressionLevel: TComboBox;
        Label2: TLabel;
        chkBlockMode: TCheckBox;
        btDecompress: TButton;
        Label3: TLabel;
        procedure btVersionClick(Sender: TObject);
        procedure chkOverwriteOutputClick(Sender: TObject);
        procedure btInputSelectClick(Sender: TObject);
        procedure btOutputSelectClick(Sender: TObject);
        procedure btCompressClick(Sender: TObject);
        procedure cbBlockSizeSelect(Sender: TObject);
        procedure chkBlockModeClick(Sender: TObject);
        procedure chkDisableStreamChksumClick(Sender: TObject);
        procedure btClearClick(Sender: TObject);
        procedure btDecompressClick(Sender: TObject);
    private
        function checkInfileExists(inFile: string): boolean;
        function resolveFilename(compressed: boolean): string;
    public
        { Public declarations }
    end;

const
    LZA_VERSION = 'r127';
    COMPRESSOR_NAME = 'LZ4 window interface';
    AUTHOR = 'Jose Pascoa';
    // DEFAULT_COMPRESSOR = LZ4IO_compressFilename;

var
    LZ4Client: TLZ4Client;

implementation

{$R *.dfm}


procedure TLZ4Client.cbBlockSizeSelect(Sender: TObject);
begin
    globalBlockSizeID := strtoint(cbBlockSize.Text);
end;

function TLZ4Client.checkInfileExists(inFile: string): boolean;
begin
    result := false;
    if inFile = '' then
    begin
        Memo.Lines.Add('Source file needed.');
        exit;
    end;
    if not FileExists(inFile) then
    begin
        Memo.Lines.Add('File not found. Please use valid file.');
        exit();
    end;
    result := true;
end;

function TLZ4Client.resolveFilename(compressed: boolean): string;
    function CanCreateFile(const FileName: string): boolean; // Can a file be created in this directory?
    var
        H: THandle;
    begin
        H := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
          CREATE_NEW, FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE, 0);

        result := H <> INVALID_HANDLE_VALUE;
        if H <> INVALID_HANDLE_VALUE then
            closeHandle(H);
        DeleteFile(FileName);
    end;

var
    FileName: string;
begin
    if compressed then
        FileName := edCompressedFilename.Text
    else
        FileName := edUncompressedFilename.Text;

    if (FileName <> '') and DirectoryExists(ExtractFilePath(FileName)) and
      CanCreateFile(FileName + '.tmp')
    then
        result := FileName
    else
    begin
        if compressed then
            FileName := edUncompressedFilename.Text + '.lz4'
        else
            FileName := copy(edCompressedFilename.Text, 1, pos(extractFileExt(edCompressedFilename.Text), edCompressedFilename.Text )-1);

        if CanCreateFile(FileName + '.tmp') then
        begin
            if compressed then
                edCompressedFilename.Text := FileName
            else
                edUncompressedFilename.Text := FileName;
            result := FileName;
        end
        else
        begin
            Memo.Lines.Add('Can not create file');
            result := '';
        end;
    end;

end;

procedure TLZ4Client.btOutputSelectClick(Sender: TObject);
begin
    With FileOpenDlg do
    begin
        Title := 'Select File';
        with FileOpenDlg.fileTypes.Add do
        begin
            DisplayName := 'LZ4 Files';
            FileMask := '*.lz4';
        end;
        FileOpenDlg.FileTypeIndex := 2;
        DefaultFolder := ExtractFilePath(application.ExeName);
        Execute;
        edCompressedFilename.Text := FileName;
    end;
end;

procedure TLZ4Client.btClearClick(Sender: TObject);
begin
    Memo.Lines.Clear;
end;

procedure TLZ4Client.btCompressClick(Sender: TObject);
var
    input_filename: string;
    output_filename: string;
    cLevel: integer;
begin
    cLevel := cbCompressionLevel.ItemIndex;
    if not checkInfileExists(edUncompressedFilename.Text) then
        exit;
    input_filename := edUncompressedFilename.Text;
    output_filename := resolveFilename(true);
    if output_filename = '' then
        exit;
    if chkLegacy.Checked then
        LZ4IO_compressFilename_Legacy(input_filename, output_filename, cLevel)
    else
         LZ4IO_compressFilename(input_filename, output_filename, cLevel);
end;

procedure TLZ4Client.btDecompressClick(Sender: TObject);
var
    input_filename: string;
    output_filename: string;
begin
    if not checkInfileExists(edCompressedFilename.Text) then
        exit;
    input_filename := edCompressedFilename.Text;
    output_filename := resolveFilename(false);

    LZ4IO_decompressFilename(input_filename, output_filename);
end;

procedure TLZ4Client.btInputSelectClick(Sender: TObject);
begin
    With FileOpenDlg do
    begin
        Title := 'Select File';
        DefaultFolder := ExtractFilePath(application.ExeName);
        Execute;
        edUncompressedFilename.Text := FileName;
    end;
end;

procedure TLZ4Client.btVersionClick(Sender: TObject);
begin
    Memo.Lines.Add(format('%s %d-bits %s, by %s (%s)', [COMPRESSOR_NAME, sizeof(pointer) * 8, LZA_VERSION, AUTHOR, dateToStr(now)]));
end;

procedure TLZ4Client.chkBlockModeClick(Sender: TObject);
begin
    blockindependence := integer(chkBlockMode.Checked);
end;

procedure TLZ4Client.chkDisableStreamChksumClick(Sender: TObject);
begin
    streamCheckSum := integer(not chkDisableStreamChksum.Checked);
end;

procedure TLZ4Client.chkOverwriteOutputClick(Sender: TObject);
begin
    lz4_overwrite_file := chkOverwriteOutput.Checked;
end;

end.
