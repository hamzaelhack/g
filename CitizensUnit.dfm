object CitizensForm: TCitizensForm
  Left = 0
  Top = 0
  Caption = 'Gestion des Citoyens'
  ClientHeight = 600
  ClientWidth = 900
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
  object pnlSearch: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 65
    Align = alTop
    TabOrder = 0
    object lblSearchId: TLabel
      Left = 16
      Top = 24
      Width = 89
      Caption = 'Rechercher par ID:'
    end
    object lblSearchName: TLabel
      Left = 208
      Top = 24
      Width = 97
      Caption = 'Rechercher par Nom:'
    end
    object edtSearchId: TEdit
      Left = 111
      Top = 21
      Width = 80
      Height = 21
      TabOrder = 0
    end
    object edtSearchName: TEdit
      Left = 311
      Top = 21
      Width = 160
      Height = 21
      TabOrder = 1
    end
    object btnSearch: TButton
      Left = 487
      Top = 19
      Width = 75
      Height = 25
      Caption = 'Rechercher'
      TabOrder = 2
      OnClick = btnSearchClick
    end
    object btnClear: TButton
      Left = 568
      Top = 19
      Width = 75
      Height = 25
      Caption = 'Effacer'
      TabOrder = 3
      OnClick = btnClearClick
    end
  end
  object pnlEdit: TPanel
    Left = 0
    Top = 65
    Width = 300
    Height = 535
    Align = alLeft
    TabOrder = 1
    object lblId: TLabel
      Left = 16
      Top = 16
      Width = 16
      Caption = 'ID:'
    end
    object lblName: TLabel
      Left = 16
      Top = 56
      Width = 28
      Caption = 'Nom:'
    end
    object lblBirthDate: TLabel
      Left = 16
      Top = 88
      Width = 180
      Height = 16
      Caption = 'Date de Naissance (JJ/MM/AAAA):'
    end
    object lblGender: TLabel
      Left = 16
      Top = 136
      Width = 35
      Caption = 'Genre:'
    end
    object lblMaritalStatus: TLabel
      Left = 16
      Top = 176
      Width = 51
      Caption = 'État Civil:'
    end
    object lblPhone: TLabel
      Left = 16
      Top = 216
      Width = 58
      Caption = 'Téléphone:'
    end
    object lblAddress: TLabel
      Left = 16
      Top = 256
      Width = 45
      Caption = 'Adresse:'
    end
    object lblPhoto: TLabel
      Left = 16
      Top = 336
      Width = 31
      Caption = 'Photo:'
    end
    object edtId: TEdit
      Left = 120
      Top = 13
      Width = 160
      Height = 21
      Enabled = False
      TabOrder = 0
    end
    object edtName: TEdit
      Left = 120
      Top = 53
      Width = 160
      Height = 21
      TabOrder = 1
    end
    object edtBirthDate: TEdit
      Left = 16
      Top = 104
      Width = 120
      Height = 24
      MaxLength = 10
      TabOrder = 2
      TextHint = 'JJ/MM/AAAA'
    end
    object cmbGender: TComboBox
      Left = 120
      Top = 133
      Width = 160
      Height = 21
      Style = csDropDownList
      TabOrder = 3
    end
    object cmbMaritalStatus: TComboBox
      Left = 120
      Top = 173
      Width = 160
      Height = 21
      Style = csDropDownList
      TabOrder = 4
    end
    object edtPhone: TEdit
      Left = 120
      Top = 213
      Width = 160
      Height = 21
      TabOrder = 5
    end
    object edtAddress: TEdit
      Left = 120
      Top = 253
      Width = 160
      Height = 21
      TabOrder = 6
    end
    object imgPhoto: TImage
      Left = 120
      Top = 336
      Width = 160
      Height = 120
      Stretch = True
    end
    object btnLoadPhoto: TButton
      Left = 120
      Top = 462
      Width = 160
      Height = 25
      Caption = 'Charger Photo'
      TabOrder = 7
      OnClick = btnLoadPhotoClick
    end
    object btnAdd: TButton
      Left = 16
      Top = 496
      Width = 75
      Height = 25
      Caption = 'Ajouter'
      TabOrder = 8
      OnClick = btnAddClick
    end
    object btnEdit: TButton
      Left = 112
      Top = 496
      Width = 75
      Height = 25
      Caption = 'Modifier'
      TabOrder = 9
      OnClick = btnEditClick
    end
    object btnDelete: TButton
      Left = 208
      Top = 496
      Width = 75
      Height = 25
      Caption = 'Supprimer'
      TabOrder = 10
      OnClick = btnDeleteClick
    end
  end
  object pnlGrid: TPanel
    Left = 300
    Top = 65
    Width = 600
    Height = 535
    Align = alClient
    TabOrder = 2
    object dbgCitizens: TDBGrid
      Left = 1
      Top = 1
      Width = 598
      Height = 498
      Align = alClient
      DataSource = dsCitizens
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnCellClick = dbgCitizensCellClick
      Columns = <
        item
          Expanded = False
          FieldName = 'id'
          Title.Caption = 'ID'
          Width = 50
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'name'
          Title.Caption = 'Nom'
          Width = 150
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'birth_date'
          Title.Caption = 'Date de Naissance'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'gender'
          Title.Caption = 'Genre'
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'marital_status'
          Title.Caption = 'État Civil'
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'phone'
          Title.Caption = 'Téléphone'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'address'
          Title.Caption = 'Adresse'
          Width = 150
          Visible = True
        end>
    end
    object btnExportExcel: TButton
      Left = 488
      Top = 505
      Width = 105
      Height = 25
      Caption = 'Exporter vers Excel'
      TabOrder = 1
      OnClick = btnExportExcelClick
    end
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 40
    Top = 544
  end
  object qryCitizens: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM citizens ORDER BY id')
    Left = 112
    Top = 544
  end
  object dsCitizens: TDataSource
    DataSet = qryCitizens
    Left = 184
    Top = 544
  end
end
