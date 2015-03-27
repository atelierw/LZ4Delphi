object mainUnit: TmainUnit
  Left = 0
  Top = 0
  Caption = 'LZ4 Bench'
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
    Top = 73
    Width = 706
    Height = 232
    Align = alClient
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 706
    Height = 73
    Align = alTop
    TabOrder = 1
    object lblFiletoCompress: TLabel
      Left = 16
      Top = 7
      Width = 20
      Height = 13
      Caption = 'File:'
    end
    object edFilename: TEdit
      Left = 16
      Top = 24
      Width = 385
      Height = 21
      TabOrder = 0
    end
    object btSelect: TButton
      Left = 407
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Select File'
      TabOrder = 1
      OnClick = btSelectClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 305
    Width = 706
    Height = 163
    Align = alBottom
    TabOrder = 2
    object lblCompressionFunction: TLabel
      Left = 288
      Top = 53
      Width = 129
      Height = 13
      Caption = 'Test compression function:'
    end
    object lblDecompressionFunction: TLabel
      Left = 288
      Top = 101
      Width = 142
      Height = 13
      Caption = 'Test Decompression function:'
    end
    object lblBlockSize: TLabel
      Left = 16
      Top = 104
      Width = 50
      Height = 13
      Caption = 'Block Size:'
    end
    object Label1: TLabel
      Left = 24
      Top = 136
      Width = 51
      Height = 13
      Caption = 'Iterations:'
    end
    object btClear: TButton
      Left = 16
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 0
      OnClick = btClearClick
    end
    object cbCompressionFunction: TComboBoxEx
      Left = 288
      Top = 72
      Width = 220
      Height = 22
      ItemsEx = <
        item
          Caption = 'none'
        end
        item
          Caption = 'LZ4_compress'
        end
        item
          Caption = 'LZ4_compress_limitedOutput'
        end
        item
          Caption = 'LZ4_compress_withState'
        end
        item
          Caption = 'LZ4_compress_limitedOutput_withState'
        end
        item
          Caption = 'LZ4_compress_continue'
        end
        item
          Caption = 'LZ4_compress_limitedOutput_continue'
        end
        item
          Caption = 'LZ4_compressHC'
        end
        item
          Caption = 'LZ4_compressHC_limitedOutput'
        end
        item
          Caption = '"LZ4_compressHC_withStateHC'
        end
        item
          Caption = 'LZ4_compressHC_limitedOutput_withStateHC'
        end
        item
          Caption = 'LZ4_compressHC_continue'
        end
        item
          Caption = 'LZ4_compressHC_limitedOutput_continue'
        end
        item
          Caption = 'LZ4_compress_forceDict'
        end
        item
          Caption = 'LZ4F_compressFrame'
        end
        item
          Caption = 'LZ4_saveDict'
        end
        item
          Caption = 'LZ4_saveDictHC'
        end>
      Style = csExDropDownList
      TabOrder = 1
    end
    object btTestCompFunctions: TButton
      Left = 520
      Top = 72
      Width = 169
      Height = 25
      Caption = 'Test Compression'
      TabOrder = 2
      OnClick = btTestCompFunctionsClick
    end
    object cbDecompressionFunction: TComboBox
      Left = 288
      Top = 120
      Width = 220
      Height = 21
      Style = csDropDownList
      TabOrder = 3
      Items.Strings = (
        'none'
        'LZ4_decompress_fast'
        'LZ4_decompress_fast_withPrefix64k'
        'LZ4_decompress_fast_usingDict'
        'LZ4_decompress_safe'
        'LZ4_decompress_safe_withPrefix64k'
        'LZ4_decompress_safe_usingDict'
        'LZ4_decompress_safe_partial'
        'LZ4_decompress_safe_forceExtDict'
        'LZ4F_decompress')
    end
    object btTestDecompFunctions: TButton
      Left = 514
      Top = 120
      Width = 169
      Height = 25
      Caption = 'Test Decompression'
      TabOrder = 4
      OnClick = btTestDecompFunctionsClick
    end
    object btHash32: TButton
      Left = 16
      Top = 61
      Width = 75
      Height = 25
      Caption = 'Hash 32'
      TabOrder = 5
      OnClick = btHash32Click
    end
    object btHash64: TButton
      Left = 97
      Top = 61
      Width = 75
      Height = 25
      Caption = 'Hash 64'
      TabOrder = 6
      OnClick = btHash64Click
    end
    object cbBlockSize: TComboBox
      Left = 81
      Top = 100
      Width = 67
      Height = 21
      Style = csDropDownList
      ItemIndex = 3
      TabOrder = 7
      Text = '7'
      OnSelect = cbBlockSizeSelect
      Items.Strings = (
        '4'
        '5'
        '6'
        '7')
    end
    object cbIterations: TComboBox
      Left = 81
      Top = 132
      Width = 67
      Height = 21
      Style = csDropDownList
      ItemIndex = 5
      TabOrder = 8
      Text = '6'
      OnSelect = cbIterationsSelect
      Items.Strings = (
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
