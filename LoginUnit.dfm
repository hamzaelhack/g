object LoginForm: TLoginForm
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  Caption = 'تسجيل الدخول'
  ClientHeight = 211
  ClientWidth = 284
  Color = clBtnFace
  Font.Charset = ARABIC_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentBiDiMode = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 17
  object lblUsername: TLabel
    Left = 190
    Top = 20
    Width = 75
    Height = 17
    BiDiMode = bdRightToLeft
    Caption = 'اسم المستخدم:'
    Font.Charset = ARABIC_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
  end
  object lblPassword: TLabel
    Left = 190
    Top = 50
    Width = 65
    Height = 17
    BiDiMode = bdRightToLeft
    Caption = 'كلمة المرور:'
    Font.Charset = ARABIC_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
  end
  object edtUsername: TEdit
    Left = 20
    Top = 20
    Width = 150
    Height = 25
    BiDiMode = bdRightToLeft
    Font.Charset = ARABIC_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
    TabOrder = 0
  end
  object edtPassword: TEdit
    Left = 20
    Top = 50
    Width = 150
    Height = 25
    BiDiMode = bdRightToLeft
    Font.Charset = ARABIC_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 1
  end
  object rgRole: TRadioGroup
    Left = 20
    Top = 90
    Width = 245
    Height = 60
    BiDiMode = bdRightToLeft
    Caption = 'نوع المستخدم'
    Font.Charset = ARABIC_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Items.Strings = (
      'موظف'
      'مدير')
    ParentBiDiMode = False
    ParentFont = False
    TabOrder = 2
  end
  object btnLogin: TButton
    Left = 92
    Top = 160
    Width = 100
    Height = 30
    BiDiMode = bdRightToLeft
    Caption = 'دخول'
    Font.Charset = ARABIC_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
    TabOrder = 3
    OnClick = btnLoginClick
  end
end
