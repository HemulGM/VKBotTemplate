object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 417
  ClientWidth = 626
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 610
    Height = 329
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 16
    Top = 352
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
  end
  object VK: TVK
    EndPoint = 'https://oauth.vk.com/authorize'
    Permissions = 'groups,friends,wall,photos,video,docs,notes,market'
    APIVersion = '5.103'
    BaseURL = 'https://api.vk.com/method'
    OnAuth = VKAuth
    OnLogin = VKLogin
    Left = 288
    Top = 160
  end
  object VkGroupEvents: TVkGroupEvents
    VK = VK
    OnMessageNew = VkGroupEventsMessageNew
    Left = 344
    Top = 160
  end
  object VkUserEvents: TVkUserEvents
    VK = VK
    Left = 232
    Top = 160
  end
end
