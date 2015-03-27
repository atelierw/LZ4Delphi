program fullbench;

uses
  Vcl.Forms,
  lz4Main in 'lz4Main.pas' {mainUnit};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TmainUnit, mainUnit);
  Application.Run;
end.
