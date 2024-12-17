program Project1_UTF8;

uses
  Vcl.Forms,
  LoginUnit_UTF8 in 'LoginUnit_UTF8.pas' {LoginForm},
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  CitizensUnit in 'CitizensUnit.pas' {CitizensForm},
  ComplaintsUnit in 'ComplaintsUnit.pas' {ComplaintsForm},
  ReportsUnit in 'ReportsUnit.pas' {ReportsForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'نظام إدارة المواطنين';
  Application.CreateForm(TLoginForm, LoginForm);
  Application.Run;
end.
