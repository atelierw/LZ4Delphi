object bigFileUnit: TbigFileUnit
  Left = 0
  Top = 0
  Caption = 'Big File Generator'
  ClientHeight = 87
  ClientWidth = 362
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
  object lblFileSize: TLabel
    Left = 39
    Top = 16
    Width = 67
    Height = 13
    Caption = 'File Size (MB):'
  end
  object Label1: TLabel
    Left = 167
    Top = 16
    Width = 70
    Height = 13
    Caption = '(aproximately)'
  end
  object btGenerate: TButton
    Left = 176
    Top = 54
    Width = 161
    Height = 25
    Caption = 'Generate Big File'
    TabOrder = 0
    OnClick = btGenerateClick
  end
  object edFileSize: TEdit
    Left = 120
    Top = 13
    Width = 41
    Height = 21
    TabOrder = 1
    Text = '10'
  end
end
