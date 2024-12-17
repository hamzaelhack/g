unit MainFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, CitizensUnit, 
  RequestsUnit, ComplaintsUnit, AdminDocsUnit, AdminDashboardUnit, ReportsUnit;

type
  TMainForm = class(TForm)
    btnCitizens: TButton;
    btnDocuments: TButton;
    btnComplaints: TButton;
    btnReports: TButton;
    btnAdminDocs: TButton;
    btnAdminDashboard: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCitizensClick(Sender: TObject);
    procedure btnDocumentsClick(Sender: TObject);
    procedure btnReportsClick(Sender: TObject);
    procedure btnComplaintsClick(Sender: TObject);
    procedure btnAdminDocsClick(Sender: TObject);
    procedure btnAdminDashboardClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;
  ComplaintsForm: TComplaintsForm;
  AdminDocsForm: TAdminDocsForm;
  AdminDashboardForm: TAdminDashboardForm;
  ReportsForm: TReportsForm;
  RequestsForm: TRequestsForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  try
    // Configuration de la fenêtre principale
    Caption := 'Système de Gestion - Commune d''Ain Beida';
    Position := poScreenCenter;
    BiDiMode := bdLeftToRight;
    
    // Configuration des propriétés de la fenêtre
    Width := 800;
    Height := 600;
    
    // Configuration de la police
    Font.Name := 'Tahoma';
    Font.Size := 10;
    Font.Charset := DEFAULT_CHARSET;

    // Création et positionnement des boutons
    if not Assigned(btnCitizens) then
    begin
      btnCitizens := TButton.Create(Self);
      with btnCitizens do
      begin
        Parent := Self;
        Left := 300;
        Top := 50;
        Width := 200;
        Height := 80;
        Caption := 'Gestion des Citoyens';
        Font.Size := 12;
        Font.Name := 'Tahoma';
        OnClick := btnCitizensClick;
      end;
    end;
    
    if not Assigned(btnDocuments) then
    begin
      btnDocuments := TButton.Create(Self);
      with btnDocuments do
      begin
        Parent := Self;
        Left := 300;
        Top := 150;
        Width := 200;
        Height := 80;
        Caption := 'Demandes de Documents';
        Font.Size := 12;
        Font.Name := 'Tahoma';
        OnClick := btnDocumentsClick;
      end;
    end;
    
    if not Assigned(btnComplaints) then
    begin
      btnComplaints := TButton.Create(Self);
      with btnComplaints do
      begin
        Parent := Self;
        Left := 300;
        Top := 250;
        Width := 200;
        Height := 80;
        Caption := 'Plaintes';
        Font.Size := 12;
        Font.Name := 'Tahoma';
        OnClick := btnComplaintsClick;
      end;
    end;
    
    if not Assigned(btnReports) then
    begin
      btnReports := TButton.Create(Self);
      with btnReports do
      begin
        Parent := Self;
        Left := 300;
        Top := 350;
        Width := 200;
        Height := 80;
        Caption := 'Rapports';
        Font.Size := 12;
        Font.Name := 'Tahoma';
        OnClick := btnReportsClick;
      end;
    end;
    
    if not Assigned(btnAdminDocs) then
    begin
      btnAdminDocs := TButton.Create(Self);
      with btnAdminDocs do
      begin
        Parent := Self;
        Left := 300;
        Top := 450;
        Width := 200;
        Height := 80;
        Caption := 'Documents Administratifs';
        Font.Size := 12;
        Font.Name := 'Tahoma';
        OnClick := btnAdminDocsClick;
      end;
    end;

    if not Assigned(btnAdminDashboard) then
    begin
      btnAdminDashboard := TButton.Create(Self);
      with btnAdminDashboard do
      begin
        Parent := Self;
        Left := 520;
        Top := 50;
        Width := 200;
        Height := 80;
        Caption := 'Tableau de Bord Admin';
        Font.Size := 12;
        Font.Name := 'Tahoma';
        Font.Style := [fsBold];
        OnClick := btnAdminDashboardClick;
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Erreur d''initialisation: ' + E.Message);
  end;
end;

procedure TMainForm.btnCitizensClick(Sender: TObject);
begin
  // Ouvrir le formulaire des citoyens
  CitizensForm := TCitizensForm.Create(Application);
  try
    CitizensForm.ShowModal;
  finally
    CitizensForm.Free;
  end;
end;

procedure TMainForm.btnDocumentsClick(Sender: TObject);
begin
  // Ouvrir le formulaire des demandes de documents
  RequestsForm := TRequestsForm.Create(Application);
  try
    RequestsForm.ShowModal;
  finally
    RequestsForm.Free;
  end;
end;

procedure TMainForm.btnReportsClick(Sender: TObject);
begin
  ReportsForm := TReportsForm.Create(Application);
  try
    ReportsForm.ShowModal;
  finally
    ReportsForm.Free;
  end;
end;

procedure TMainForm.btnComplaintsClick(Sender: TObject);
begin
  ComplaintsForm := TComplaintsForm.Create(Application);
  try
    ComplaintsForm.ShowModal;
  finally
    ComplaintsForm.Free;
  end;
end;

procedure TMainForm.btnAdminDocsClick(Sender: TObject);
begin
  AdminDocsForm := TAdminDocsForm.Create(Application);
  try
    AdminDocsForm.ShowModal;
  finally
    AdminDocsForm.Free;
  end;
end;

procedure TMainForm.btnAdminDashboardClick(Sender: TObject);
begin
  AdminDashboardForm := TAdminDashboardForm.Create(Application);
  try
    AdminDashboardForm.ShowModal;
  finally
    AdminDashboardForm.Free;
  end;
end;

end.
