program VKBotApp;

uses
  Vcl.Forms,
  VKBot.Main in 'VKBot.Main.pas' {FormMain},
  VK.Entity.Video.Save in '..\VK_API\Entity\VK.Entity.Video.Save.pas';

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
