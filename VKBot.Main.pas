unit VKBot.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  VK.UserEvents, VK.Components, VK.GroupEvents, VK.API, VK.Entity.Message,
  VK.Entity.ClientInfo, Vcl.StdCtrls, VK.Types, VK.Entity.Profile, Vcl.ExtCtrls,
  System.Generics.Collections;

type
  TCommandProc = reference to function(VK: TVK; Message: TVkMessage): Boolean;

  TCommand = record
    Value: string;
    Proc: TCommandProc;
    class function New(Value: string; Proc: TCommandProc): TCommand; static;
  end;

  TCommands = class(TList<TCommand>)
  end;

  TFormMain = class(TForm)
    VK: TVK;
    VkGroupEvents: TVkGroupEvents;
    Panel1: TPanel;
    Button1: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure VkGroupEventsMessageNew(Sender: TObject; GroupId: Integer; Message: TVkMessage; ClientInfo: TVkClientInfo; EventId: string);
    procedure VKLogin(Sender: TObject);
    procedure VKLog(Sender: TObject; const Value: string);
    procedure VKError(Sender: TObject; E: Exception; Code: Integer; Text: string);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure VKAuth(Sender: TObject; Url: string; var Token: string; var TokenExpiry: Int64; var ChangePasswordHash: string);
  private
    FCommands: TCommands;
    procedure SendStart(PeerId: Integer);
    procedure FindAndSendPic(Path: string; PeerId: Integer; ReplyTo: Integer = 0);
    function FindRandomPic(Path: string; var FileName: string): Boolean;
    procedure SendPic(FileName: string; PeerId: Integer; ReplyTo: Integer = 0);
    procedure FindAndSendHashtagPic(Path, Tag: string; PeerId: Integer);
    function FindPic(Path, Tag: string; var FileName: string): Boolean;
  public
    procedure Quit;
  end;

const
  PathPicCommon = 'D:\�����������\��������\HQ 2010\2560�1600';

var
  FormMain: TFormMain;

implementation

uses
  System.IOUtils, VK.Entity.Keyboard, VK.Entity.Photo.Upload, VK.Entity.Photo,
  VK.Entity.Group;

{$R *.dfm}

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Quit;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FCommands := TCommands.Create;

  FCommands.Add(TCommand.New('wantPic',
    function(VK: TVK; Message: TVkMessage): Boolean
    begin
      FindAndSendPic(PathPicCommon, Message.PeerId);
    end));

  VkGroupEvents.GroupID := 145962568;
  VK.Login;
end;

procedure TFormMain.VKLogin(Sender: TObject);
begin
  VkGroupEvents.Start;
end;

procedure TFormMain.VkGroupEventsMessageNew(Sender: TObject; GroupId: Integer; Message: TVkMessage; ClientInfo: TVkClientInfo; EventId: string);
var
  User, Member: TVkProfile;
  FAnswer: string;
begin
  if not VK.Users.Get(User, Message.FromId, [TVkProfileField.Domain]) then
    User := TVkProfile.Create
  else
    Memo1.Lines.Add(User.ToJsonString);

  if Assigned(Message.action) then
  begin
    if Message.action.&type in [TVkMessageActionType.ChatInviteUser, TVkMessageActionType.ChatInviteUserByLink] then
    begin
      if VK.Users.Get(Member, Message.Action.MemberId, [TVkProfileField.Domain]) then
      begin
        VK.Messages.New.PeerId(Message.PeerId).Message('���������� �������, �����!').Send.Free;

        VK.Messages.New.PeerId(Message.PeerId).UserId(Member.Id).Message('����������, ' + Member.FirstName).Send.Free;
        Member.Free;
      end;
    end;
  end;

  if Assigned(Message.PayloadButton) then
  begin
    FAnswer := '';
    if Message.PayloadButton.button = 'weather' then
      FAnswer := '�� ������ ����� ������? � � ��� ���� �� ����';
    if Message.PayloadButton.button = 'info' then
      FAnswer := '� ��������� ���, �� ��� ��������';
    if Message.PayloadButton.button = 'commands' then
      FAnswer := '��? ��, � ���� ������ �� /start ��������';
    if Message.PayloadButton.button = 'cancel' then
      FAnswer := '� �� ����?';

    if not FAnswer.IsEmpty then
    begin
      FAnswer := User.Refer + ', ' + FAnswer;
      VK.Messages.New.PeerId(Message.PeerId).Message(FAnswer).Send.Free;
    end;
  end;

  if not Message.text.IsEmpty then
  begin
    if Message.text = '/start' then
    begin
      SendStart(Message.PeerId);
    end;

    if Message.text = '/wantPicAnime' then
    begin
      FindAndSendPic('D:\�����������\��������\�����', Message.PeerId);
    end;

    if Message.text = '/wantPicAbstract' then
    begin
      FindAndSendPic('D:\�����������\��������\HQ 1920�1440 1600�1200 (2009) (1)', Message.PeerId);
    end;

    if Message.text = '/wantPic' then
    begin
      FindAndSendPic('D:\�����������\��������\HQ 2010\2560�1600', Message.PeerId);
    end;

    if Message.text = '/wantPicErotic' then
    begin
      FindAndSendPic('D:\�����������\��������\HQ 1680x1050 1920x1200 (2)', Message.PeerId);
    end;

    if Message.text[1] = '#' then
      FindAndSendHashtagPic('H:\Data\files\VkBot\', Message.text, Message.PeerId);
  end;

  Memo1.Lines.Add(Message.PeerId.ToString + ' ' + Message.Text);
  User.Free;
end;

procedure TFormMain.Quit;
begin
  Application.Terminate;
end;

procedure TFormMain.VKLog(Sender: TObject; const Value: string);
begin
  Memo1.Lines.Add(Value);
end;

procedure TFormMain.VKAuth(Sender: TObject; Url: string; var Token: string; var TokenExpiry: Int64; var ChangePasswordHash: string);
begin
  //{$INCLUDE token.inc}
  //Token := '<����� �����>';
end;

procedure TFormMain.VKError(Sender: TObject; E: Exception; Code: Integer; Text: string);
begin
  Memo1.Lines.Add('Error ' + E.Message);
end;

procedure TFormMain.SendStart(PeerId: Integer);
var
  Keys: TVkKeyboard;
begin
 { Keys.OneTime := True;
  Keys.AddButtonLine;
  Keys.AddButtonLine;
  Keys.Buttons[0].CreateText('������', 'weather', 'positive');
  Keys.Buttons[0].CreateText('������', 'cancel', 'negative');
  Keys.Buttons[1].CreateText('����������', 'info', 'primary');
  Keys.Buttons[1].CreateText('�������', 'commands', 'secondary');
  VK.Messages.New.PeerId(PeerId).Keyboard(Keys).Message('������ �������').Send.Free;   }
end;

function TFormMain.FindRandomPic(Path: string; var FileName: string): Boolean;
var
  Files: TArray<string>;
  R: Integer;
begin
  Files := TDirectory.GetFiles(Path, '*.jpg');
  R := Random(Length(Files));
  try
    FileName := Files[R];
    Result := True;
  except
    Result := False;
  end;
  SetLength(Files, 0);
end;

function TFormMain.FindPic(Path, Tag: string; var FileName: string): Boolean;
var
  Files: TArray<string>;
begin
  try
    Files := TDirectory.GetFiles(Path, Tag + '.jpg');
  except
    Exit(False);
  end;
  if Length(Files) <= 0 then
    Exit(False)
  else
  begin
    FileName := Files[0];
    SetLength(Files, 0);
    Result := True;
  end;
end;

procedure TFormMain.SendPic(FileName: string; PeerId: Integer; ReplyTo: Integer = 0);
var
  Url: string;
  Response: TVkPhotoUploadResponse;
  Photos: TVkPhotos;
  Attach: TAttachment;
begin
  if VK.Photos.UploadForMessage(Photos, PeerId, [FileName]) then
  begin
    Attach := TAttachment.Photo(Photos.Items[0].OwnerId, Photos.Items[0].Id, Photos.Items[0].AccessKey);
    if ReplyTo <> 0 then
    begin
      VK.Messages.New.PeerId(PeerId).ReplyTo(ReplyTo).Attachment(Attach).Send.Free;
    end
    else
    begin
      VK.Messages.New.PeerId(PeerId).Attachment(Attach).Send.Free;
    end;
    Photos.Free;
  end;
end;

procedure TFormMain.FindAndSendPic(Path: string; PeerId: Integer; ReplyTo: Integer = 0);
var
  attPic: string;
begin
  if FindRandomPic(Path, attPic) then
    SendPic(attPic, PeerId, ReplyTo);
end;

procedure TFormMain.FindAndSendHashtagPic(Path, Tag: string; PeerId: Integer);
var
  attPic: string;
begin
  if Tag[1] = '#' then
    Delete(Tag, 1, 1);
  if FindPic(Path, Tag, attPic) then
    SendPic(attPic, PeerId);
end;

{ TCommand }

class function TCommand.New(Value: string; Proc: TCommandProc): TCommand;
begin
  Result.Value := Value;
  Result.Proc := Proc;
end;

end.

