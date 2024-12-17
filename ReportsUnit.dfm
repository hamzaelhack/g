object ReportsForm: TReportsForm
  Left = 0
  Top = 0
  Caption = 'Rapports et Statistiques'
  ClientHeight = 500
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnClose = FormClose
  
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 41
    Align = alTop
    TabOrder = 0
    
    object lblTitle: TLabel
      Left = 16
      Top = 8
      Width = 300
      Height = 24
      Caption = 'Rapports et Statistiques'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    
    object btnRefresh: TSpeedButton
      Left = 744
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
  end
  
  object pcReports: TPageControl
    Left = 0
    Top = 41
    Width = 800
    Height = 459
    ActivePage = tsRequests
    Align = alClient
    TabOrder = 1
    
    object tsRequests: TTabSheet
      Caption = 'Statistiques des Demandes'
      
      object pnlRequestStats: TPanel
        Left = 0
        Top = 0
        Width = 792
        Height = 200
        Align = alTop
        TabOrder = 0
        
        object lblTotalRequests: TLabel
          Left = 16
          Top = 16
          Width = 300
          Height = 30
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        
        object lblPendingRequests: TLabel
          Left = 16
          Top = 56
          Width = 300
          Height = 30
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        
        object lblApprovedRequests: TLabel
          Left = 16
          Top = 96
          Width = 300
          Height = 30
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        
        object lblRejectedRequests: TLabel
          Left = 16
          Top = 136
          Width = 300
          Height = 30
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        
        object btnExportRequests: TButton
          Left = 600
          Top = 16
          Width = 169
          Height = 41
          Caption = 'Exporter en CSV'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnExportRequestsClick
        end
      end
    end
    
    object tsComplaints: TTabSheet
      Caption = 'Statistiques des Plaintes'
      ImageIndex = 1
      
      object pnlComplaintStats: TPanel
        Left = 0
        Top = 0
        Width = 792
        Height = 200
        Align = alTop
        TabOrder = 0
        
        object lblTotalComplaints: TLabel
          Left = 16
          Top = 16
          Width = 300
          Height = 30
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        
        object lblPendingComplaints: TLabel
          Left = 16
          Top = 56
          Width = 300
          Height = 30
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        
        object lblProcessedComplaints: TLabel
          Left = 16
          Top = 96
          Width = 300
          Height = 30
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        
        object lblClosedComplaints: TLabel
          Left = 16
          Top = 136
          Width = 300
          Height = 30
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        
        object btnExportComplaints: TButton
          Left = 600
          Top = 16
          Width = 169
          Height = 41
          Caption = 'Exporter en CSV'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = btnExportComplaintsClick
        end
      end
    end
  end
  
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=citizens.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 728
    Top = 384
  end
  
  object qryStats: TFDQuery
    Connection = FDConnection
    Left = 728
    Top = 432
  end
end
