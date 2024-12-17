object AdminDocsForm: TAdminDocsForm
  Left = 0
  Top = 0
  Caption = 'Système de Gestion des Documents'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnClose = FormClose
  TextHeight = 13
  
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 80
    Align = alTop
    TabOrder = 0
    object lblTitle: TLabel
      Left = 24
      Top = 16
      Width = 400
      Height = 25
      Caption = 'Système de Gestion des Documents Administratifs'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  
  object pnlLeft: TPanel
    Left = 0
    Top = 80
    Width = 400
    Height = 520
    Align = alLeft
    TabOrder = 1
    
    object grpNewDoc: TGroupBox
      Left = 16
      Top = 16
      Width = 368
      Height = 240
      Caption = 'Nouveau Document'
      TabOrder = 0
      
      object lblDocType: TLabel
        Left = 16
        Top = 32
        Width = 120
        Height = 16
        Caption = 'Type de Document:'
      end
      
      object lblCitizenId: TLabel
        Left = 16
        Top = 88
        Width = 80
        Height = 16
        Caption = 'ID Citoyen:'
      end
      
      object lblRequestDate: TLabel
        Left = 16
        Top = 144
        Width = 120
        Height = 16
        Caption = 'Date de Demande:'
      end
      
      object cmbDocType: TComboBox
        Left = 16
        Top = 48
        Width = 329
        Height = 21
        Style = csDropDownList
        TabOrder = 0
      end
      
      object edtCitizenId: TEdit
        Left = 16
        Top = 104
        Width = 121
        Height = 21
        TabOrder = 1
        OnChange = edtCitizenIdChange
      end
      
      object dtRequestDate: TDateTimePicker
        Left = 16
        Top = 160
        Width = 186
        Height = 21
        Date = 44906.000000000000000000
        Time = 0.677066203703484300
        TabOrder = 2
      end
      
      object btnGenerate: TButton
        Left = 16
        Top = 200
        Width = 105
        Height = 33
        Caption = 'Générer PDF'
        TabOrder = 3
        OnClick = btnGenerateClick
      end
      
      object btnPrint: TButton
        Left = 136
        Top = 200
        Width = 105
        Height = 33
        Caption = 'Imprimer'
        TabOrder = 4
        OnClick = btnPrintClick
      end
      
      object btnArchive: TButton
        Left = 256
        Top = 200
        Width = 89
        Height = 33
        Caption = 'Archiver'
        TabOrder = 5
        OnClick = btnArchiveClick
      end
    end
    
    object grpCitizenInfo: TGroupBox
      Left = 16
      Top = 272
      Width = 368
      Height = 121
      Caption = 'Information du Citoyen'
      TabOrder = 1
      
      object lblCitizenName: TLabel
        Left = 16
        Top = 32
        Width = 28
        Height = 13
        Caption = 'Nom:'
      end
      
      object lblCitizenBirthDate: TLabel
        Left = 16
        Top = 64
        Width = 93
        Height = 13
        Caption = 'Date de Naissance:'
      end
    end
  end
  
  object pnlRight: TPanel
    Left = 400
    Top = 80
    Width = 500
    Height = 520
    Align = alClient
    TabOrder = 2
    
    object dbgDocuments: TDBGrid
      Left = 1
      Top = 1
      Width = 498
      Height = 518
      Align = alClient
      DataSource = dsDocuments
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
  end
  
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=citizens.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 48
    Top = 456
  end
  
  object qryDocuments: TFDQuery
    Connection = FDConnection
    Left = 136
    Top = 456
  end
  
  object dsDocuments: TDataSource
    DataSet = qryDocuments
    Left = 224
    Top = 456
  end
end
