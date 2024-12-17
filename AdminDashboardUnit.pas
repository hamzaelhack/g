unit AdminDashboardUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  System.DateUtils, Vcl.Grids, Vcl.DBGrids, System.ImageList, Vcl.ImgList,
  Vcl.Buttons, System.Notification;

type
  TAdminDashboardForm = class(TForm)
    pnlTop: TPanel;
    lblTitle: TLabel;
    pcMain: TPageControl;
    tsRequests: TTabSheet;
    tsComplaints: TTabSheet;
    pnlNotifications: TPanel;
    dbgRequests: TDBGrid;
    dbgComplaints: TDBGrid;
    FDConnection: TFDConnection;
    qryRequests: TFDQuery;
    qryComplaints: TFDQuery;
    dsRequests: TDataSource;
    dsComplaints: TDataSource;
    btnRefresh: TSpeedButton;
    tmrRefresh: TTimer;
    NotificationCenter: TNotificationCenter;
    pnlRequestActions: TPanel;
    btnApproveRequest: TButton;
    btnRejectRequest: TButton;
    pnlComplaintActions: TPanel;
    btnProcessComplaint: TButton;
    btnCloseComplaint: TButton;
    lblNewCount: TLabel;
    
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure tmrRefreshTimer(Sender: TObject);
    procedure btnApproveRequestClick(Sender: TObject);
    procedure btnRejectRequestClick(Sender: TObject);
    procedure btnProcessComplaintClick(Sender: TObject);
    procedure btnCloseComplaintClick(Sender: TObject);
    procedure pcMainChange(Sender: TObject);
    
  private
    FLastRequestId: Integer;
    FLastComplaintId: Integer;
    procedure InitializeDatabase;
    procedure InitializeControls;
    procedure LoadRequests;
    procedure LoadComplaints;
    procedure CheckForNewItems;
    procedure ShowNotification(const Title, Message: string);
    procedure UpdateRequestStatus(RequestId: Integer; NewStatus: Integer);
    procedure UpdateComplaintStatus(ComplaintId: Integer; NewStatus: Integer);
    
  public
    { Déclarations publiques }
  end;

var
  AdminDashboardForm: TAdminDashboardForm;

implementation

{$R *.dfm}

procedure TAdminDashboardForm.FormCreate(Sender: TObject);
begin
  Caption := 'Tableau de Bord Administrateur';
  Position := poScreenCenter;
  
  InitializeDatabase;
  InitializeControls;
  
  FLastRequestId := 0;
  FLastComplaintId := 0;
  
  LoadRequests;
  LoadComplaints;
  
  // Démarrer le minuteur de rafraîchissement (toutes les 30 secondes)
  tmrRefresh.Interval := 30000;
  tmrRefresh.Enabled := True;
end;

procedure TAdminDashboardForm.InitializeDatabase;
begin
  try
    FDConnection.Params.Clear;
    FDConnection.Params.Add('Database=citizens.db');
    FDConnection.Params.Add('DriverID=SQLite');
    
    if FDConnection.Connected then
      FDConnection.Connected := False;
      
    FDConnection.Connected := True;
    
    // Configurer la requête des demandes
    qryRequests.SQL.Text :=
      'SELECT r.id, r.citizen_id, c.name as citizen_name, ' +
      'r.request_type, r.request_date, r.urgent, r.status, ' +
      'CASE r.status ' +
      '  WHEN 0 THEN ''En Attente'' ' +
      '  WHEN 1 THEN ''En Cours'' ' +
      '  WHEN 2 THEN ''Terminé'' ' +
      '  WHEN 3 THEN ''Rejeté'' ' +
      'END as status_text ' +
      'FROM requests r ' +
      'LEFT JOIN citizens c ON r.citizen_id = c.id ' +
      'ORDER BY r.urgent DESC, r.created_at DESC';
      
    // Configurer la requête des plaintes
    qryComplaints.SQL.Text :=
      'SELECT c.id, c.citizen_id, ct.name as citizen_name, ' +
      'c.subject, c.description, c.complaint_date, c.status, ' +
      'CASE c.status ' +
      '  WHEN 0 THEN ''Nouvelle'' ' +
      '  WHEN 1 THEN ''En Traitement'' ' +
      '  WHEN 2 THEN ''Résolue'' ' +
      '  WHEN 3 THEN ''Fermée'' ' +
      'END as status_text ' +
      'FROM complaints c ' +
      'LEFT JOIN citizens ct ON c.citizen_id = ct.id ' +
      'ORDER BY c.status ASC, c.complaint_date DESC';
  except
    on E: Exception do
      ShowMessage('Erreur d''initialisation de la base de données: ' + E.Message);
  end;
end;

procedure TAdminDashboardForm.InitializeControls;
begin
  // Configuration des onglets
  tsRequests.Caption := 'Demandes de Documents';
  tsComplaints.Caption := 'Plaintes';
  
  // Configuration du titre
  lblTitle.Caption := 'Tableau de Bord Administrateur';
  
  // Configuration des boutons
  btnApproveRequest.Caption := 'Approuver';
  btnRejectRequest.Caption := 'Rejeter';
  btnProcessComplaint.Caption := 'Traiter';
  btnCloseComplaint.Caption := 'Fermer';
  btnRefresh.Caption := 'Actualiser';
  
  // Configuration de la grille des demandes
  with dbgRequests do
  begin
    Columns.Clear;
    
    with Columns.Add do
    begin
      FieldName := 'id';
      Title.Caption := 'ID';
      Width := 50;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'citizen_name';
      Title.Caption := 'Citoyen';
      Width := 150;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'request_type';
      Title.Caption := 'Type de Document';
      Width := 150;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'request_date';
      Title.Caption := 'Date';
      Width := 100;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'urgent';
      Title.Caption := 'Urgent';
      Width := 60;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'status_text';
      Title.Caption := 'Statut';
      Width := 100;
    end;
  end;
  
  // Configuration de la grille des plaintes
  with dbgComplaints do
  begin
    Columns.Clear;
    
    with Columns.Add do
    begin
      FieldName := 'id';
      Title.Caption := 'ID';
      Width := 50;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'citizen_name';
      Title.Caption := 'Citoyen';
      Width := 150;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'subject';
      Title.Caption := 'Sujet';
      Width := 200;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'complaint_date';
      Title.Caption := 'Date';
      Width := 100;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'status_text';
      Title.Caption := 'Statut';
      Width := 100;
    end;
  end;
  
  // Initialiser le compteur
  lblNewCount.Caption := '';
end;

procedure TAdminDashboardForm.LoadRequests;
begin
  try
    qryRequests.Close;
    qryRequests.Open;
  except
    on E: Exception do
      ShowMessage('Erreur de chargement des demandes: ' + E.Message);
  end;
end;

procedure TAdminDashboardForm.LoadComplaints;
begin
  try
    qryComplaints.Close;
    qryComplaints.Open;
  except
    on E: Exception do
      ShowMessage('Erreur de chargement des plaintes: ' + E.Message);
  end;
end;

procedure TAdminDashboardForm.CheckForNewItems;
var
  NewRequestCount, NewComplaintCount: Integer;
begin
  try
    // Vérifier les nouvelles demandes
    with TFDQuery.Create(nil) do
    try
      Connection := FDConnection;
      SQL.Text := 'SELECT COUNT(*) FROM requests WHERE id > :last_id AND status = 0';
      ParamByName('last_id').AsInteger := FLastRequestId;
      Open;
      NewRequestCount := Fields[0].AsInteger;
      
      if NewRequestCount > 0 then
      begin
        ShowNotification('Nouvelles Demandes',
          Format('Vous avez %d nouvelle(s) demande(s) de documents', [NewRequestCount]));
        
        // Mettre à jour le dernier ID
        SQL.Text := 'SELECT MAX(id) FROM requests';
        Open;
        FLastRequestId := Fields[0].AsInteger;
      end;
    finally
      Free;
    end;
    
    // Vérifier les nouvelles plaintes
    with TFDQuery.Create(nil) do
    try
      Connection := FDConnection;
      SQL.Text := 'SELECT COUNT(*) FROM complaints WHERE id > :last_id AND status = 0';
      ParamByName('last_id').AsInteger := FLastComplaintId;
      Open;
      NewComplaintCount := Fields[0].AsInteger;
      
      if NewComplaintCount > 0 then
      begin
        ShowNotification('Nouvelles Plaintes',
          Format('Vous avez %d nouvelle(s) plainte(s)', [NewComplaintCount]));
        
        // Mettre à jour le dernier ID
        SQL.Text := 'SELECT MAX(id) FROM complaints';
        Open;
        FLastComplaintId := Fields[0].AsInteger;
      end;
    finally
      Free;
    end;
    
    // Mettre à jour le compteur
    if (NewRequestCount > 0) or (NewComplaintCount > 0) then
    begin
      lblNewCount.Caption := Format('Nouveaux: %d demande(s), %d plainte(s)',
        [NewRequestCount, NewComplaintCount]);
      LoadRequests;
      LoadComplaints;
    end;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la vérification des nouveaux éléments: ' + E.Message);
  end;
end;

procedure TAdminDashboardForm.ShowNotification(const Title, Message: string);
var
  Notification: TNotification;
begin
  Notification := NotificationCenter.CreateNotification;
  try
    Notification.Name := 'AdminNotification';
    Notification.Title := Title;
    Notification.AlertBody := Message;
    
    NotificationCenter.PresentNotification(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TAdminDashboardForm.UpdateRequestStatus(RequestId: Integer; NewStatus: Integer);
begin
  try
    if not qryRequests.IsEmpty then
    begin
      FDConnection.ExecSQL(
        'UPDATE requests SET status = :status WHERE id = :id',
        [NewStatus, RequestId]
      );
      
      LoadRequests;
      ShowMessage('Statut de la demande mis à jour avec succès');
    end;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la mise à jour du statut: ' + E.Message);
  end;
end;

procedure TAdminDashboardForm.UpdateComplaintStatus(ComplaintId: Integer; NewStatus: Integer);
begin
  try
    if not qryComplaints.IsEmpty then
    begin
      FDConnection.ExecSQL(
        'UPDATE complaints SET status = :status WHERE id = :id',
        [NewStatus, ComplaintId]
      );
      
      LoadComplaints;
      ShowMessage('Statut de la plainte mis à jour avec succès');
    end;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la mise à jour du statut: ' + E.Message);
  end;
end;

procedure TAdminDashboardForm.btnApproveRequestClick(Sender: TObject);
begin
  if not qryRequests.IsEmpty then
    UpdateRequestStatus(qryRequests.FieldByName('id').AsInteger, 2); // Terminé
end;

procedure TAdminDashboardForm.btnRejectRequestClick(Sender: TObject);
begin
  if not qryRequests.IsEmpty then
    UpdateRequestStatus(qryRequests.FieldByName('id').AsInteger, 3); // Rejeté
end;

procedure TAdminDashboardForm.btnProcessComplaintClick(Sender: TObject);
begin
  if not qryComplaints.IsEmpty then
    UpdateComplaintStatus(qryComplaints.FieldByName('id').AsInteger, 1); // En Traitement
end;

procedure TAdminDashboardForm.btnCloseComplaintClick(Sender: TObject);
begin
  if not qryComplaints.IsEmpty then
    UpdateComplaintStatus(qryComplaints.FieldByName('id').AsInteger, 3); // Fermée
end;

procedure TAdminDashboardForm.btnRefreshClick(Sender: TObject);
begin
  LoadRequests;
  LoadComplaints;
  CheckForNewItems;
end;

procedure TAdminDashboardForm.tmrRefreshTimer(Sender: TObject);
begin
  CheckForNewItems;
end;

procedure TAdminDashboardForm.pcMainChange(Sender: TObject);
begin
  // Actualiser l'onglet actif
  case pcMain.ActivePageIndex of
    0: LoadRequests;
    1: LoadComplaints;
  end;
end;

procedure TAdminDashboardForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    if FDConnection.Connected then
      FDConnection.Connected := False;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la fermeture: ' + E.Message);
  end;
end;

end.
