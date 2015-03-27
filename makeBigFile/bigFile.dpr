program bigFile;

uses
  Vcl.Forms,
  mainUnit in 'mainUnit.pas' {bigFileUnit};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TbigFileUnit, bigFileUnit);
  Application.Run;
end.
