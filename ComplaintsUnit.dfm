object ComplaintsForm: TComplaintsForm
  Left = 0
  Top = 0
  Caption = 'Gestion des Plaintes'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnClose = FormClose
  TextHeight = 13
  object pnlNew: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 280
    Align = alTop
    TabOrder = 0
    object lblCitizenId: TLabel
      Left = 16
      Top = 16
      Width = 65
      Height = 13
      Caption = 'ID du Citoyen'
    end
    object lblDescription: TLabel
      Left = 16
      Top = 64
      Width = 53
      Height = 13
      Caption = 'Description'
    end
    object lblStatus: TLabel
      Left = 400
      Top = 16
      Width = 29
      Height = 13
      Caption = 'Statut'
    end
    object lblDate: TLabel
      Left = 400
      Top = 64
      Width = 84
      Height = 13
      Caption = 'Date de la Plainte'
    end
    object edtCitizenId: TEdit
      Left = 16
      Top = 32
      Width = 121
      Height = 21
      TabOrder = 0
      OnChange = edtCitizenIdChange
    end
    object memDescription: TMemo
      Left = 16
      Top = 80
      Width = 361
      Height = 89
      ScrollBars = ssVertical
      TabOrder = 1
    end
    object cmbStatus: TComboBox
      Left = 400
      Top = 32
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 2
    end
    object dtComplaintDate: TDateTimePicker
      Left = 400
      Top = 80
      Width = 145
      Height = 21
      Date = 45276.000000000000000000
      Time = 0.677002314814815000
      TabOrder = 3
    end
    object btnAdd: TButton
      Left = 584
      Top = 32
      Width = 75
      Height = 25
      Caption = 'Ajouter'
      TabOrder = 4
      OnClick = btnAddClick
    end
    object btnUpdate: TButton
      Left = 584
      Top = 80
      Width = 75
      Height = 25
      Caption = 'Mettre '#224' jour'
      TabOrder = 5
      OnClick = btnUpdateClick
    end
    object btnClear: TButton
      Left = 584
      Top = 128
      Width = 75
      Height = 25
      Caption = 'Effacer'
      TabOrder = 6
      OnClick = btnClearClick
    end
    object grpCitizenInfo: TGroupBox
      Left = 400
      Top = 120
      Width = 361
      Height = 120
      Caption = 'Informations du Citoyen'
      TabOrder = 7
      object lblCitizenName: TLabel
        Left = 16
        Top = 24
        Width = 28
        Height = 13
        Caption = 'Nom: '
      end
      object lblCitizenPhone: TLabel
        Left = 16
        Top = 48
        Width = 58
        Height = 13
        Caption = 'T'#233'l'#233'phone: '
      end
      object lblCitizenAddress: TLabel
        Left = 16
        Top = 72
        Width = 47
        Height = 13
        Caption = 'Adresse: '
      end
    end
  end
  object pnlGrid: TPanel
    Left = 0
    Top = 280
    Width = 800
    Height = 320
    Align = alClient
    TabOrder = 1
    object dbgComplaints: TDBGrid
      Left = 1
      Top = 1
      Width = 798
      Height = 318
      Align = alClient
      DataSource = dsComplaints
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnCellClick = dbgComplaintsCellClick
    end
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=citizens.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 728
    Top = 24
  end
  object qryComplaints: TFDQuery
    Connection = FDConnection
    Left = 728
    Top = 80
  end
  object dsComplaints: TDataSource
    DataSet = qryComplaints
    Left = 728
    Top = 136
  end
end
