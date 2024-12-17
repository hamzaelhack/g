unit LoginForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmLogin = class(TForm)
    edtUsername: TEdit;
    edtPassword: TEdit;
    lblUsername: TLabel;
    lblPassword: TLabel;
    btnLogin: TButton;
    rgRole: TRadioGroup;
    procedure btnLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  // Set initial form properties
  Caption := 'Connexion';
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  
  // Create and setup username components
  lblUsername := TLabel.Create(Self);
  lblUsername.Parent := Self;
  lblUsername.Left := 20;
  lblUsername.Top := 20;
  lblUsername.Caption := 'Nom d''utilisateur:';

  edtUsername := TEdit.Create(Self);
  edtUsername.Parent := Self;
  edtUsername.Left := 100;
  edtUsername.Top := 20;
  edtUsername.Width := 150;

  // Create and setup password components
  lblPassword := TLabel.Create(Self);
  lblPassword.Parent := Self;
  lblPassword.Left := 20;
  lblPassword.Top := 50;
  lblPassword.Caption := 'Mot de passe:';

  edtPassword := TEdit.Create(Self);
  edtPassword.Parent := Self;
  edtPassword.Left := 100;
  edtPassword.Top := 50;
  edtPassword.Width := 150;
  edtPassword.PasswordChar := '*';

  // Create and setup role selection
  rgRole := TRadioGroup.Create(Self);
  rgRole.Parent := Self;
  rgRole.Left := 20;
  rgRole.Top := 90;
  rgRole.Width := 230;
  rgRole.Height := 50;
  rgRole.Caption := ' Rôle de l''utilisateur ';
  rgRole.Items.Add('Employé');
  rgRole.Items.Add('Gestionnaire');
  rgRole.ItemIndex := 0;

  // Create and setup login button
  btnLogin := TButton.Create(Self);
  btnLogin.Parent := Self;
  btnLogin.Left := 100;
  btnLogin.Top := 150;
  btnLogin.Width := 80;
  btnLogin.Caption := 'Connexion';
  btnLogin.OnClick := btnLoginClick;

  // Set form size
  ClientHeight := 200;
  ClientWidth := 280;
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  username, password, role: string;
begin
  username := edtUsername.Text;
  password := edtPassword.Text;
  
  if rgRole.ItemIndex = 0 then
    role := 'Employé'
  else
    role := 'Gestionnaire';

  // Basic validation
  if (username = '') or (password = '') then
  begin
    ShowMessage('Veuillez entrer le nom d''utilisateur et le mot de passe');
    Exit;
  end;

  // Here you would typically check against a database
  // This is just a simple demo
  if (username = 'admin') and (password = 'admin') then
  begin
    ShowMessage('Connexion réussie en tant que ' + role);
    // Add your code here to open the appropriate form based on role
  end
  else
    ShowMessage('Nom d''utilisateur ou mot de passe incorrect');
end;

end.
