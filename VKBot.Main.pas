unit VKBot.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VK.UserEvents, VK.Components, VK.GroupEvents, VK.API,
  VK.Entity.Message, VK.Entity.ClientInfo, Vcl.StdCtrls, VK.Types, VK.Entity.User;

type
  TFormMain = class(TForm)
    VK: TVK;
    VkGroupEvents: TVkGroupEvents;
    VkUserEvents: TVkUserEvents;
    Memo1: TMemo;
    Button1: TButton;
    procedure VKAuth(Sender: TObject; var Token: string; var TokenExpiry: Int64; var ChangePasswordHash: string);
    procedure FormCreate(Sender: TObject);
    procedure VkGroupEventsMessageNew(Sender: TObject; GroupId: Integer; Message: TVkMessage;
      ClientInfo: TVkClientInfo; EventId: string);
    procedure VKLogin(Sender: TObject);
  private
    procedure SendStart(PeerId: Integer);
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  VK.Entity.Keyboard;

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  VkGroupEvents.GroupID := -145962568;
  VK.Login;
end;

procedure TFormMain.VKLogin(Sender: TObject);
begin
  VkGroupEvents.Start;
end;

procedure TFormMain.VKAuth(Sender: TObject; var Token: string; var TokenExpiry: Int64; var ChangePasswordHash: string);
begin
  {$INCLUDE token.inc}
  //Token := '<����� �����>';
end;

procedure TFormMain.SendStart(PeerId: Integer);
var
  Keys: TVkKeyboardConstructor;
begin
  Keys.SetOneTime(True);
  Keys.AddButtonText(0, '������', 'weather', 'positive');
  Keys.AddButtonText(0, '������', 'cancel', 'negative');
  Keys.AddButtonText(1, '����������', 'info', 'primary');
  Keys.AddButtonText(1, '�������', 'commands', 'secondary');
  Vk.Messages.
    Send.
    PeerId(PeerId).
    Keyboard(Keys).
    Message('������ �������').
    Send.Free;
end;

procedure TFormMain.VkGroupEventsMessageNew(Sender: TObject; GroupId: Integer; Message: TVkMessage;
  ClientInfo: TVkClientInfo; EventId: string);
var
  User: TVkUser;
  FAnswer: string;
begin
  if not VK.Users.Get(User, Message.FromId, 'domain') then
    User := TVkUser.Create;
  if Assigned(Message.action) then
  begin
    if (Message.action.&type = 'chat_invite_user') or (Message.action.&type = 'chat_invite_user_by_link')
      then
    begin
      VK.Messages.Send.PeerId(Message.PeerId).Message('���������� �������, �����!'#13#10'����������, '
        + User.FirstName).Send.Free;
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
      Vk.Messages.Send.PeerId(Message.PeerId).Message(FAnswer).Send.Free;
    end;
  end;

  if Message.text = '/start' then
  begin
    SendStart(Message.PeerId);
  end;
  Memo1.Lines.Add(Message.Text);
  User.Free;
end;

end.

