object mainUnit: TmainUnit
  Left = 0
  Top = 0
  Caption = 'LZ4 Streaming Tests'
  ClientHeight = 468
  ClientWidth = 706
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
  object Memo: TMemo
    Left = 0
    Top = 129
    Width = 706
    Height = 287
    Align = alClient
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    ExplicitTop = 112
    ExplicitHeight = 304
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 706
    Height = 129
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 7
      Width = 171
      Height = 13
      Caption = 'File (Maximum 2GB for these tests):'
    end
    object Label2: TLabel
      Left = 16
      Top = 58
      Width = 375
      Height = 13
      Caption = 
        'For details check original author website @https://github.com/Hu' +
        'gie/lz4-delphi'
    end
    object Label3: TLabel
      Left = 16
      Top = 77
      Width = 591
      Height = 26
      Caption = 
        'Now compatible with LZ4 r127. Added VS 2012 object files for 32-' +
        'bit and 64-bit. Alternatively, can compile without the .obj file' +
        's (100% Delphi + some Asm) but is a bit slower.'
      WordWrap = True
    end
    object edFilename: TEdit
      Left = 16
      Top = 26
      Width = 385
      Height = 21
      TabOrder = 0
    end
    object btSelect: TButton
      Left = 407
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Select File'
      TabOrder = 1
      OnClick = btSelectClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 416
    Width = 706
    Height = 52
    Align = alBottom
    TabOrder = 2
    object btGo: TButton
      Left = 606
      Top = 11
      Width = 75
      Height = 25
      Caption = 'GO'
      TabOrder = 0
      OnClick = btGoClick
    end
    object btClear: TButton
      Left = 16
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 1
      OnClick = btClearClick
    end
  end
  object FileOpenDlg: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'All Files'
        FileMask = '*.*'
      end>
    Options = []
    Left = 608
    Top = 24
  end
end
