program VKBotApp;

uses
  Vcl.Forms,
  VKBot.Main in 'VKBot.Main.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
