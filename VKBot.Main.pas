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
    procedure VKLog(Sender: TObject; const Value: string);
    procedure VKError(Sender: TObject; E: Exception; Code: Integer; Text: string);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure SendStart(PeerId: Integer);
    procedure FindAndSendPic(Path: string; PeerId: Integer);
    function FindRandomPic(Path: string; var FileName: string): Boolean;
    procedure SendPic(FileName: string; PeerId: Integer);
    procedure FindAndSendHashtagPic(Path, Tag: string; PeerId: Integer);
    function FindPic(Path, Tag: string; var FileName: string): Boolean;
  public
    procedure Quit;
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.IOUtils, VK.Entity.Keyboard, VK.Entity.Photo.Upload, VK.Entity.Photo, VK.Entity.Group;

{$R *.dfm}

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Quit;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  VkGroupEvents.GroupID := -145962568;
  VK.Login;
end;

procedure TFormMain.Quit;
begin
  Application.Terminate;
end;

procedure TFormMain.VKLog(Sender: TObject; const Value: string);
begin
  Memo1.Lines.Add(Value);
end;

procedure TFormMain.VKLogin(Sender: TObject);
var
  Status: TVkGroupStatus;
begin
  VkGroupEvents.Start;      {
  if VK.Groups.GetOnlineStatus(Status, VkGroupEvents.GroupID) then
  begin
    if Status.Status = gsNone then
      VK.Groups.EnableOnline(VkGroupEvents.GroupID);
    Status.Free;
  end; }
end;

procedure TFormMain.VKAuth(Sender: TObject; var Token: string; var TokenExpiry: Int64; var ChangePasswordHash: string);
begin
  {$INCLUDE token.inc}
  //Token := '<здесь токен>';
end;

procedure TFormMain.VKError(Sender: TObject; E: Exception; Code: Integer; Text: string);
begin
  Memo1.Lines.Add('Error ' + E.Message);
end;

procedure TFormMain.SendStart(PeerId: Integer);
var
  Keys: TVkKeyboardConstructor;
begin
  Keys.SetOneTime(True);
  Keys.AddButtonText(0, 'Погода', 'weather', 'positive');
  Keys.AddButtonText(0, 'Отмена', 'cancel', 'negative');
  Keys.AddButtonText(1, 'Информация', 'info', 'primary');
  Keys.AddButtonText(1, 'Команды', 'commands', 'secondary');
  Vk.Messages.
    Send.
    PeerId(PeerId).
    Keyboard(Keys).
    Message('Выбери вариант').
    Send.Free;
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

procedure TFormMain.SendPic(FileName: string; PeerId: Integer);
var
  Url: string;
  Response: TVkPhotoUploadResponse;
  Photos: TVkPhotos;
begin
  if VK.Photos.GetMessagesUploadServer(Url, PeerId) then
  begin
    if VK.Uploader.UploadPhotos(Url, FileName, Response) then
    begin
      if VK.Photos.SaveMessagesPhoto(Response, Photos) then
      begin
        FileName := CreateAttachment('photo', Photos.Items[0].OwnerId, Photos.Items[0].Id, Photos.Items[0].AccessKey);
        Vk.Messages.
          Send.
          PeerId(PeerId).
          Attachemt([FileName]).
          Send.Free;
        Photos.Free;
      end;
      Response.Free;
    end;
  end;
end;

procedure TFormMain.FindAndSendPic(Path: string; PeerId: Integer);
var
  attPic: string;
begin
  if FindRandomPic(Path, attPic) then
    SendPic(attPic, PeerId);
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

procedure TFormMain.VkGroupEventsMessageNew(Sender: TObject; GroupId: Integer; Message: TVkMessage;
  ClientInfo: TVkClientInfo; EventId: string);
var
  User, Member: TVkUser;
  FAnswer: string;
begin
  if not VK.Users.Get(User, Message.FromId, 'domain') then
    User := TVkUser.Create
  else
    Memo1.Lines.Add(User.ToJsonString);

  if Assigned(Message.action) then
  begin
    if (Message.action.&type = 'chat_invite_user') or (Message.action.&type = 'chat_invite_user_by_link')
      then
    begin
      if VK.Users.Get(Member, Message.Action.MemberId, 'domain') then
      begin
        VK.Messages.Send.PeerId(Message.PeerId).Message('Встречайте новичка, черти!').Send.Free;
        VK.Messages.Send.PeerId(Message.PeerId).UserId(Member.Id).Message('Здравствуй, ' + Member.FirstName).Send.Free;
        Member.Free;
      end;
    end;
  end;

  if Assigned(Message.PayloadButton) then
  begin
    FAnswer := '';
    if Message.PayloadButton.button = 'weather' then
      FAnswer := 'Ты хочешь знать погоду? А я вот пока не умею';
    if Message.PayloadButton.button = 'info' then
      FAnswer := 'Я туповатый бот, но это временно';
    if Message.PayloadButton.button = 'commands' then
      FAnswer := 'Че? Хз, я могу только на /start ответить';
    if Message.PayloadButton.button = 'cancel' then
      FAnswer := 'А че звал?';

    if not FAnswer.IsEmpty then
    begin
      FAnswer := User.Refer + ', ' + FAnswer;
      Vk.Messages.Send.PeerId(Message.PeerId).Message(FAnswer).Send.Free;
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
      FindAndSendPic('D:\Мультимедиа\Картинки\Аниме', Message.PeerId);
    end;

    if Message.text = '/wantPicAbstract' then
    begin
      FindAndSendPic('D:\Мультимедиа\Картинки\HQ 1920х1440 1600х1200 (2009) (1)', Message.PeerId);
    end;

    if Message.text = '/wantPic' then
    begin
      FindAndSendPic('D:\Мультимедиа\Картинки\HQ 2010\2560х1600', Message.PeerId);
    end;

    if Message.text = '/wantPicErotic' then
    begin
      FindAndSendPic('D:\Мультимедиа\Картинки\HQ 1680x1050 1920x1200 (2)', Message.PeerId);
    end;

    if Message.text[1] = '#' then
      FindAndSendHashtagPic('H:\Data\files\VkBot\', Message.text, Message.PeerId);
  end;

  Memo1.Lines.Add(Message.PeerId.ToString + ' ' + Message.Text);
  User.Free;
end;

end.

