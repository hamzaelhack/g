object AdminDashboardForm: TAdminDashboardForm
  Left = 0
  Top = 0
  Caption = 'Tableau de Bord Administrateur'
  ClientHeight = 600
  ClientWidth = 1000
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
    Width = 1000
    Height = 41
    Align = alTop
    TabOrder = 0
    
    object lblTitle: TLabel
      Left = 16
      Top = 8
      Width = 400
      Height = 24
      Caption = 'Tableau de Bord Administrateur'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    
    object btnRefresh: TSpeedButton
      Left = 944
      Top = 8
      Width = 25
      Height = 25
      Caption = '↻'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI Symbol'
      Font.Style = []
      ParentFont = False
      OnClick = btnRefreshClick
    end
    
    object lblNewCount: TLabel
      Left = 600
      Top = 12
      Width = 300
      Height = 16
      Alignment = taRightJustify
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  
  object pcMain: TPageControl
    Left = 0
    Top = 41
    Width = 1000
    Height = 559
    ActivePage = tsRequests
    Align = alClient
    TabOrder = 1
    OnChange = pcMainChange
    
    object tsRequests: TTabSheet
      Caption = 'Demandes de Documents'
      
      object pnlRequestActions: TPanel
        Left = 0
        Top = 0
        Width = 992
        Height = 41
        Align = alTop
        TabOrder = 0
        
        object btnApproveRequest: TButton
          Left = 8
          Top = 8
          Width = 120
          Height = 25
          Caption = 'Approuver'
          TabOrder = 0
          OnClick = btnApproveRequestClick
        end
        
        object btnRejectRequest: TButton
          Left = 144
          Top = 8
          Width = 120
          Height = 25
          Caption = 'Rejeter'
          TabOrder = 1
          OnClick = btnRejectRequestClick
        end
      end
      
      object dbgRequests: TDBGrid
        Left = 0
        Top = 41
        Width = 992
        Height = 490
        Align = alClient
        DataSource = dsRequests
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        ReadOnly = True
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Arial'
        TitleFont.Style = []
      end
    end
    
    object tsComplaints: TTabSheet
      Caption = 'Plaintes'
      ImageIndex = 1
      
      object pnlComplaintActions: TPanel
        Left = 0
        Top = 0
        Width = 992
        Height = 41
        Align = alTop
        TabOrder = 0
        
        object btnProcessComplaint: TButton
          Left = 8
          Top = 8
          Width = 120
          Height = 25
          Caption = 'Traiter'
          TabOrder = 0
          OnClick = btnProcessComplaintClick
        end
        
        object btnCloseComplaint: TButton
          Left = 144
          Top = 8
          Width = 120
          Height = 25
          Caption = 'Fermer'
          TabOrder = 1
          OnClick = btnCloseComplaintClick
        end
      end
      
      object dbgComplaints: TDBGrid
        Left = 0
        Top = 41
        Width = 992
        Height = 490
        Align = alClient
        DataSource = dsComplaints
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        ReadOnly = True
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Arial'
        TitleFont.Style = []
      end
    end
  end
  
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=citizens.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 920
    Top = 8
  end
  
  object qryRequests: TFDQuery
    Connection = FDConnection
    Left = 920
    Top = 56
  end
  
  object qryComplaints: TFDQuery
    Connection = FDConnection
    Left = 920
    Top = 104
  end
  
  object dsRequests: TDataSource
    DataSet = qryRequests
    Left = 920
    Top = 152
  end
  
  object dsComplaints: TDataSource
    DataSet = qryComplaints
    Left = 920
    Top = 200
  end
  
  object tmrRefresh: TTimer
    Enabled = False
    OnTimer = tmrRefreshTimer
    Left = 920
    Top = 248
  end
  
  object NotificationCenter: TNotificationCenter
    Left = 920
    Top = 296
  end
end
