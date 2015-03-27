program Lz4Cli;

uses
  Vcl.Forms,
  Lz4CliMain in 'Lz4CliMain.pas' {LZ4Client};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TLZ4Client, LZ4Client);
  Application.Run;
end.
