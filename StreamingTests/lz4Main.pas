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

unit lz4Main;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, lz4d.test, Vcl.ExtCtrls;

type
    TmainUnit = class(TForm)
        FileOpenDlg: TFileOpenDialog;
        Memo: TMemo;
        Panel1: TPanel;
        Label1: TLabel;
        edFilename: TEdit;
        btSelect: TButton;
        Panel2: TPanel;
        btGo: TButton;
        btClear: TButton;
    Label2: TLabel;
    Label3: TLabel;
        procedure btSelectClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure btGoClick(Sender: TObject);
        procedure btClearClick(Sender: TObject);
    private
        { Private declarations }
    public
        { Public declarations }
    end;

var
    mainUnit: TmainUnit;

implementation

{$R *.dfm}


procedure TmainUnit.btClearClick(Sender: TObject);
begin
    Memo.Clear;
end;


procedure TmainUnit.btGoClick(Sender: TObject);
var
    LFileStream: TFileStream;
    LMemStream: TMemoryStream;
begin
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
    try
        try
            // create file stream of test data
            LFileStream := TFileStream.Create(edFilename.Text, fmOpenRead);

            // read data into memory
            LMemStream := TMemoryStream.Create();
            LMemStream.CopyFrom(LFileStream, 0);


            LFileStream.Free;
            lz4dtest(LMemStream);

            LMemStream.Free;
        except

        end;
    finally

    end;
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

procedure TmainUnit.FormCreate(Sender: TObject);
begin
    SetMinimumBlockAlignment(mba16Byte);
end;

end.
