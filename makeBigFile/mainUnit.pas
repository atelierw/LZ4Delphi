(*
  LZ4Delphi
  Copyright (C) 2015, Jose Pascoa (atelierwebgm@gmail.com)
  BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

  *************************************************************************
  
  Text for the file gibberish.txt' taken from:
  https://github.com/vickytnz/who-ipsum/blob/gh-pages/js/ipsum.js
  Not sure who is the original author of the text.

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

unit mainUnit;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
    TbigFileUnit = class(TForm)
        btGenerate: TButton;
        edFileSize: TEdit;
        lblFileSize: TLabel;
    Label1: TLabel;
        procedure btGenerateClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
    private
        { Private declarations }
    public
        { Public declarations }
    end;

var
    bigFileUnit: TbigFileUnit;

implementation

{$R *.dfm}


procedure TbigFileUnit.btGenerateClick(Sender: TObject);
var
    fileSize: int64;
    strList: TStringList;
    fStream: TFileStream;
    paraLen: integer;
    lineNum: integer;
    lineStr: Ansistring;
    countofLines: integer;
begin
    //
    fStream := TFileStream.Create('..\..\..\filesfortest\bigFile.txt', fmCreate);
    strList := TStringList.Create;
    strList.LoadFromFile('..\..\gibberish\gibberish.txt');
    countofLines := strList.Count;
    try
        fileSize := int64(strtointdef(edFileSize.Text, 10))* 1024 * 1024;
        while fileSize > 0 do
        begin
            lineNum := random(countoflines);
            lineStr := Ansistring(strList[lineNum] + #13#10);;
            paraLen := length(lineStr);
            fStream.Write(pointer(lineStr)^, paralen);
            dec(fileSize, paralen);
        end;
    finally
        strList.Free;
    end;
    showmessage('done');
end;

procedure TbigFileUnit.FormCreate(Sender: TObject);
begin
    randomize;
end;

end.
