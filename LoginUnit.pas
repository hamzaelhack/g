unit LoginUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TLoginForm = class(TForm)
    edtUsername: TEdit;
    edtPassword: TEdit;
    lblUsername: TLabel;
    lblPassword: TLabel;
    btnLogin: TButton;
    rgRole: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LoginForm: TLoginForm;

implementation

{$R *.dfm}

procedure TLoginForm.FormCreate(Sender: TObject);
begin
  // Set Windows to support Arabic text
  Application.BiDiMode := bdRightToLeft;
  
  // Set form properties
  Caption := 'تسجيل الدخول';
  Position := poScreenCenter;
  Width := 300;
  Height := 250;
  
  // Set global font for better Arabic support
  Font.Name := 'Tahoma';
  Font.Size := 10;
  Font.Charset := ARABIC_CHARSET;
  
  // Initialize components if not created in design-time
  if not Assigned(lblUsername) then
  begin
    lblUsername := TLabel.Create(Self);
    lblUsername.Parent := Self;
    lblUsername.Caption := 'اسم المستخدم:';
    lblUsername.Left := 190;
    lblUsername.Top := 20;
    lblUsername.BiDiMode := bdRightToLeft;
    lblUsername.ParentBiDiMode := False;
    lblUsername.Font.Charset := ARABIC_CHARSET;
  end;

  if not Assigned(edtUsername) then
  begin
    edtUsername := TEdit.Create(Self);
    edtUsername.Parent := Self;
    edtUsername.Left := 20;
    edtUsername.Top := 20;
    edtUsername.Width := 150;
    edtUsername.Height := 25;
    edtUsername.BiDiMode := bdRightToLeft;
    edtUsername.ParentBiDiMode := False;
    edtUsername.Font.Charset := ARABIC_CHARSET;
  end;

  if not Assigned(lblPassword) then
  begin
    lblPassword := TLabel.Create(Self);
    lblPassword.Parent := Self;
    lblPassword.Caption := 'كلمة المرور:';
    lblPassword.Left := 190;
    lblPassword.Top := 50;
    lblPassword.BiDiMode := bdRightToLeft;
    lblPassword.ParentBiDiMode := False;
    lblPassword.Font.Charset := ARABIC_CHARSET;
  end;

  if not Assigned(edtPassword) then
  begin
    edtPassword := TEdit.Create(Self);
    edtPassword.Parent := Self;
    edtPassword.Left := 20;
    edtPassword.Top := 50;
    edtPassword.Width := 150;
    edtPassword.Height := 25;
    edtPassword.PasswordChar := '*';
    edtPassword.BiDiMode := bdRightToLeft;
    edtPassword.ParentBiDiMode := False;
    edtPassword.Font.Charset := ARABIC_CHARSET;
  end;

  if not Assigned(rgRole) then
  begin
    rgRole := TRadioGroup.Create(Self);
    rgRole.Parent := Self;
    rgRole.Caption := 'نوع المستخدم';
    rgRole.Items.Add('موظف');
    rgRole.Items.Add('مدير');
    rgRole.Left := 20;
    rgRole.Top := 90;
    rgRole.Width := 245;
    rgRole.Height := 60;
    rgRole.ItemIndex := 0;
    rgRole.BiDiMode := bdRightToLeft;
    rgRole.ParentBiDiMode := False;
    rgRole.Font.Charset := ARABIC_CHARSET;
  end;

  if not Assigned(btnLogin) then
  begin
    btnLogin := TButton.Create(Self);
    btnLogin.Parent := Self;
    btnLogin.Caption := 'دخول';
    btnLogin.Left := 92;
    btnLogin.Top := 160;
    btnLogin.Width := 100;
    btnLogin.Height := 30;
    btnLogin.BiDiMode := bdRightToLeft;
    btnLogin.ParentBiDiMode := False;
    btnLogin.Font.Charset := ARABIC_CHARSET;
  end;
end;

procedure TLoginForm.btnLoginClick(Sender: TObject);
var
  username, password, role: string;
  Msg: array[0..255] of Char;
begin
  username := edtUsername.Text;
  password := edtPassword.Text;
  
  if rgRole.ItemIndex = 0 then
    role := 'موظف'
  else
    role := 'مدير';

  // Basic validation
  if (username = '') or (password = '') then
  begin
    StrPCopy(Msg, 'الرجاء إدخال اسم المستخدم وكلمة المرور');
    Application.MessageBox(Msg, 'تنبيه', MB_OK or MB_ICONWARNING or MB_RTLREADING or MB_RIGHT);
    Exit;
  end;

  // Demo login check - replace with your actual authentication logic
  if (username = 'admin') and (password = 'admin') then
  begin
    StrPCopy(Msg, 'تم تسجيل الدخول بنجاح' + #13#10 + 'نوع المستخدم: ' + role);
    Application.MessageBox(Msg, 'نجاح', MB_OK or MB_ICONINFORMATION or MB_RTLREADING or MB_RIGHT);
    // Add your code here to open the appropriate form based on role
  end
  else
  begin
    StrPCopy(Msg, 'اسم المستخدم أو كلمة المرور غير صحيحة');
    Application.MessageBox(Msg, 'خطأ', MB_OK or MB_ICONERROR or MB_RTLREADING or MB_RIGHT);
  end;
end;

end.