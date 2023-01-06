object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 435
  ClientWidth = 672
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 394
    Width = 672
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 8
      Top = 7
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 672
    Height = 394
    Align = alClient
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object VK: TVK
    BaseURL = 'https://api.vk.com/method'
    EndPoint = 'https://oauth.vk.com/authorize'
    OnAuth = VKAuth
    OnError = VKError
    OnLog = VKLog
    OnLogin = VKLogin
    Permissions = [Friends, Photos, Video, Notes, Wall, Docs, Groups, Market]
    Proxy.Port = 0
    Left = 248
    Top = 161
  end
  object VkGroupEvents: TVkGroupEvents
    OnMessageNew = VkGroupEventsMessageNew
    Version = '3'
    VK = VK
    Left = 344
    Top = 161
  end
end
