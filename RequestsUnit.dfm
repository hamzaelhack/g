object RequestsForm: TRequestsForm
  Left = 0
  Top = 0
  Caption = 'Gestion des Demandes de Documents'
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
  
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 41
    Align = alTop
    TabOrder = 0
    
    object lblTitle: TLabel
      Left = 16
      Top = 8
      Width = 300
      Height = 24
      Caption = 'Gestion des Demandes de Documents'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  
  object pnlLeft: TPanel
    Left = 0
    Top = 41
    Width = 350
    Height = 559
    Align = alLeft
    TabOrder = 1
    
    object grpNewRequest: TGroupBox
      Left = 8
      Top = 8
      Width = 334
      Height = 543
      Caption = 'Nouvelle Demande'
      TabOrder = 0
      
      object lblCitizenId: TLabel
        Left = 16
        Top = 32
        Width = 60
        Height = 16
        Caption = 'ID Citoyen:'
      end
      
      object lblRequestType: TLabel
        Left = 16
        Top = 88
        Width = 110
        Height = 16
        Caption = 'Type de Document:'
      end
      
      object lblRequestDate: TLabel
        Left = 16
        Top = 144
        Width = 180
        Height = 16
        Caption = 'Date de Demande (JJ/MM/AAAA):'
      end
      
      object lblUrgent: TLabel
        Left = 16
        Top = 200
        Width = 45
        Height = 16
        Caption = 'Urgent:'
      end
      
      object edtCitizenId: TEdit
        Left = 16
        Top = 48
        Width = 121
        Height = 24
        TabOrder = 0
        OnChange = edtCitizenIdChange
      end
      
      object cmbRequestType: TComboBox
        Left = 16
        Top = 104
        Width = 300
        Height = 24
        Style = csDropDownList
        TabOrder = 1
      end
      
      object edtRequestDate: TEdit
        Left = 16
        Top = 160
        Width = 121
        Height = 24
        TabOrder = 2
        TextHint = 'JJ/MM/AAAA'
      end
      
      object chkUrgent: TCheckBox
        Left = 16
        Top = 216
        Width = 97
        Height = 17
        TabOrder = 3
      end
      
      object btnSubmit: TButton
        Left = 16
        Top = 272
        Width = 300
        Height = 40
        Caption = 'Soumettre'
        TabOrder = 4
        OnClick = btnSubmitClick
      end
      
      object btnClear: TButton
        Left = 16
        Top = 328
        Width = 300
        Height = 40
        Caption = 'Effacer'
        TabOrder = 5
        OnClick = btnClearClick
      end
      
      object btnGeneratePDF: TButton
        Left = 16
        Top = 384
        Width = 300
        Height = 40
        Caption = 'Générer PDF'
        TabOrder = 6
        OnClick = btnGeneratePDFClick
      end
    end
  end
  
  object pnlRight: TPanel
    Left = 350
    Top = 41
    Width = 550
    Height = 559
    Align = alClient
    TabOrder = 2
    
    object dbgRequests: TDBGrid
      Left = 1
      Top = 1
      Width = 548
      Height = 557
      Align = alClient
      DataSource = dsRequests
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = 'Arial'
      TitleFont.Style = []
    end
  end
  
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=citizens.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 824
    Top = 8
  end
  
  object qryRequests: TFDQuery
    Connection = FDConnection
    Left = 824
    Top = 56
  end
  
  object dsRequests: TDataSource
    DataSet = qryRequests
    Left = 824
    Top = 104
  end
end
