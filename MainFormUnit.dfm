object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Système de Gestion - Commune d''Ain Beida'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  
  object btnCitizens: TButton
    Left = 300
    Top = 50
    Width = 200
    Height = 80
    Caption = 'Gestion des Citoyens'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = btnCitizensClick
  end
  
  object btnDocuments: TButton
    Left = 300
    Top = 150
    Width = 200
    Height = 80
    Caption = 'Demandes de Documents'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnDocumentsClick
  end
  
  object btnComplaints: TButton
    Left = 300
    Top = 250
    Width = 200
    Height = 80
    Caption = 'Plaintes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btnComplaintsClick
  end
  
  object btnReports: TButton
    Left = 300
    Top = 350
    Width = 200
    Height = 80
    Caption = 'Rapports'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = btnReportsClick
  end
  
  object btnAdminDocs: TButton
    Left = 300
    Top = 450
    Width = 200
    Height = 80
    Caption = 'Documents Administratifs'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = btnAdminDocsClick
  end
  
  object btnAdminDashboard: TButton
    Left = 520
    Top = 50
    Width = 200
    Height = 80
    Caption = 'Tableau de Bord Admin'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnClick = btnAdminDashboardClick
  end
end
