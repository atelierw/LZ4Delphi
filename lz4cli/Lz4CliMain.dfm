object LZ4Client: TLZ4Client
  Left = 0
  Top = 0
  Caption = 'LZ4Client'
  ClientHeight = 512
  ClientWidth = 851
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 851
    Height = 105
    Align = alTop
    TabOrder = 0
    object lblFiletoCompress: TLabel
      Left = 16
      Top = 5
      Width = 120
      Height = 13
      Caption = 'Uncompressed file name:'
    end
    object Label3: TLabel
      Left = 16
      Top = 56
      Width = 109
      Height = 13
      Caption = 'Compressed file name:'
    end
    object edUncompressedFilename: TEdit
      Left = 16
      Top = 24
      Width = 385
      Height = 21
      TabOrder = 0
      Text = '..\..\..\filesfortest\singlecolor.bmp'
    end
    object btInputSelect: TButton
      Left = 407
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Select File'
      TabOrder = 1
      OnClick = btInputSelectClick
    end
    object edCompressedFilename: TEdit
      Left = 16
      Top = 75
      Width = 385
      Height = 21
      TabOrder = 2
      Text = '..\..\..\filesfortest\singlecolor.bmp.lz4'
    end
    object btOutputSelect: TButton
      Left = 407
      Top = 74
      Width = 75
      Height = 25
      Caption = 'Select File'
      TabOrder = 3
      OnClick = btOutputSelectClick
    end
  end
  object Memo: TMemo
    Left = 0
    Top = 105
    Width = 851
    Height = 199
    Align = alClient
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 0
    Top = 304
    Width = 851
    Height = 208
    Align = alBottom
    TabOrder = 2
    object lblBlockSize: TLabel
      Left = 288
      Top = 44
      Width = 50
      Height = 13
      Caption = 'Block Size:'
    end
    object Label2: TLabel
      Left = 128
      Top = 67
      Width = 93
      Height = 13
      Caption = 'Compression Level:'
    end
    object btClear: TButton
      Left = 0
      Top = -2
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 0
      OnClick = btClearClick
    end
    object chkDisableStreamChksum: TCheckBox
      Left = 128
      Top = 40
      Width = 154
      Height = 17
      Caption = 'Disable Stream checksum'
      TabOrder = 1
      OnClick = chkDisableStreamChksumClick
    end
    object cbBlockSize: TComboBox
      Left = 344
      Top = 39
      Width = 67
      Height = 21
      Style = csDropDownList
      ItemIndex = 3
      TabOrder = 2
      Text = '7'
      OnSelect = cbBlockSizeSelect
      Items.Strings = (
        '4'
        '5'
        '6'
        '7')
    end
    object btVersion: TButton
      Left = 32
      Top = 152
      Width = 75
      Height = 25
      Caption = 'Version'
      TabOrder = 3
      OnClick = btVersionClick
    end
    object chkOverwriteOutput: TCheckBox
      Left = 433
      Top = 41
      Width = 217
      Height = 17
      Caption = 'Overwrite output without prompting'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = chkOverwriteOutputClick
    end
    object btCompress: TButton
      Left = 383
      Top = 136
      Width = 129
      Height = 40
      Caption = 'Compress'
      TabOrder = 5
      OnClick = btCompressClick
    end
    object chkLegacy: TCheckBox
      Left = 648
      Top = 41
      Width = 185
      Height = 17
      Caption = 'Compress using legacy format'
      TabOrder = 6
    end
    object cbCompressionLevel: TComboBox
      Left = 227
      Top = 63
      Width = 67
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 7
      Text = '1'
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9')
    end
    object chkBlockMode: TCheckBox
      Left = 328
      Top = 66
      Width = 145
      Height = 17
      Caption = 'Block Independence'
      Checked = True
      State = cbChecked
      TabOrder = 8
      OnClick = chkBlockModeClick
    end
    object btDecompress: TButton
      Left = 551
      Top = 136
      Width = 129
      Height = 40
      Caption = 'Decompress'
      TabOrder = 9
      OnClick = btDecompressClick
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
