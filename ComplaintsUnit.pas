unit ComplaintsUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.DBGrids, Vcl.Grids, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef;

type
  TComplaintsForm = class(TForm)
    pnlNew: TPanel;
    pnlGrid: TPanel;
    lblCitizenId: TLabel;
    lblDescription: TLabel;
    lblStatus: TLabel;
    edtCitizenId: TEdit;
    memDescription: TMemo;
    cmbStatus: TComboBox;
    btnAdd: TButton;
    btnUpdate: TButton;
    btnClear: TButton;
    dbgComplaints: TDBGrid;
    FDConnection: TFDConnection;
    qryComplaints: TFDQuery;
    dsComplaints: TDataSource;
    dtComplaintDate: TDateTimePicker;
    lblDate: TLabel;
    grpCitizenInfo: TGroupBox;
    lblCitizenName: TLabel;
    lblCitizenPhone: TLabel;
    lblCitizenAddress: TLabel;
    lblType: TLabel;
    cmbType: TComboBox;
    lblPriority: TLabel;
    cmbPriority: TComboBox;
    lblAssignedTo: TLabel;
    cmbAssignedTo: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure dbgComplaintsCellClick(Column: TColumn);
    procedure edtCitizenIdChange(Sender: TObject);
  private
    procedure InitializeDatabase;
    procedure InitializeControls;
    procedure ClearFields;
    procedure LoadComplaints;
    procedure ConfigureGridColumns;
    procedure LoadCitizenInfo(CitizenId: Integer);
  public
    { Public declarations }
  end;

var
  ComplaintsForm: TComplaintsForm;

implementation

{$R *.dfm}

procedure TComplaintsForm.FormCreate(Sender: TObject);
begin
  Caption := 'Gestion des Plaintes';
  Position := poScreenCenter;
  
  // Initialize database
  InitializeDatabase;
  
  // Initialize controls
  InitializeControls;
  
  // Configure grid columns
  ConfigureGridColumns;
  
  // Load complaints
  LoadComplaints;
end;

procedure TComplaintsForm.InitializeDatabase;
begin
  try
    // Set database parameters
    FDConnection.Params.Clear;
    FDConnection.Params.Add('Database=citizens.db');
    FDConnection.Params.Add('DriverID=SQLite');
    
    // Create complaints table if not exists with new fields
    FDConnection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS complaints (' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'citizen_id INTEGER NOT NULL,' +
      'description TEXT NOT NULL,' +
      'status TEXT NOT NULL,' +
      'complaint_date DATE NOT NULL,' +
      'complaint_type TEXT NOT NULL,' +
      'priority TEXT NOT NULL,' +
      'assigned_to TEXT,' +
      'resolution_notes TEXT,' +
      'resolution_date DATE,' +
      'FOREIGN KEY(citizen_id) REFERENCES citizens(id))');
  except
    on E: Exception do
      ShowMessage('Erreur de base de données: ' + E.Message);
  end;
end;

procedure TComplaintsForm.InitializeControls;
begin
  // Configure panels
  pnlNew.Align := alTop;
  pnlNew.Height := 320;  // Increased height for citizen info and new fields
  pnlGrid.Align := alClient;
  
  // Create and configure citizen info group box
  grpCitizenInfo := TGroupBox.Create(Self);
  with grpCitizenInfo do
  begin
    Parent := pnlNew;
    Left := 400;
    Top := 120;
    Width := 361;
    Height := 120;
    Caption := 'Information du Citoyen';
  end;
  
  // Create labels for citizen info
  lblCitizenName := TLabel.Create(Self);
  with lblCitizenName do
  begin
    Parent := grpCitizenInfo;
    Left := 16;
    Top := 24;
    Caption := 'Nom:';
  end;
  
  lblCitizenPhone := TLabel.Create(Self);
  with lblCitizenPhone do
  begin
    Parent := grpCitizenInfo;
    Left := 16;
    Top := 48;
    Caption := 'Téléphone:';
  end;
  
  lblCitizenAddress := TLabel.Create(Self);
  with lblCitizenAddress do
  begin
    Parent := grpCitizenInfo;
    Left := 16;
    Top := 72;
    Caption := 'Adresse:';
  end;
  
  // Configure status combo box
  cmbStatus.Items.Clear;
  cmbStatus.Items.Add('Nouveau');
  cmbStatus.Items.Add('En cours');
  cmbStatus.Items.Add('Résolu');
  cmbStatus.Items.Add('Fermé');
  cmbStatus.ItemIndex := 0;
  
  // Configure date picker
  dtComplaintDate.Date := Date;
  
  // Configure description memo
  memDescription.ScrollBars := ssVertical;
  
  // Set labels
  lblCitizenId.Caption := 'ID du Citoyen:';
  lblDescription.Caption := 'Description:';
  lblStatus.Caption := 'Statut:';
  lblDate.Caption := 'Date:';
  
  // Set button captions
  btnAdd.Caption := 'Ajouter';
  btnUpdate.Caption := 'Modifier';
  btnClear.Caption := 'Effacer';
  
  // Add change event for citizen ID
  edtCitizenId.OnChange := edtCitizenIdChange;
  
  // Add complaint type combo box
  lblType := TLabel.Create(Self);
  with lblType do
  begin
    Parent := pnlNew;
    Left := 16;
    Top := 180;
    Caption := 'Type:';
  end;
  
  cmbType := TComboBox.Create(Self);
  with cmbType do
  begin
    Parent := pnlNew;
    Left := 16;
    Top := 196;
    Width := 180;
    Style := csDropDownList;
    Items.Add('Demande');
    Items.Add('Plainte');
    Items.Add('Suggestion');
    ItemIndex := 0;
  end;
  
  // Add priority combo box
  lblPriority := TLabel.Create(Self);
  with lblPriority do
  begin
    Parent := pnlNew;
    Left := 210;
    Top := 180;
    Caption := 'Priorité:';
  end;
  
  cmbPriority := TComboBox.Create(Self);
  with cmbPriority do
  begin
    Parent := pnlNew;
    Left := 210;
    Top := 196;
    Width := 120;
    Style := csDropDownList;
    Items.Add('Haute');
    Items.Add('Moyenne');
    Items.Add('Basse');
    ItemIndex := 0;
  end;
  
  // Add assigned to combo box
  lblAssignedTo := TLabel.Create(Self);
  with lblAssignedTo do
  begin
    Parent := pnlNew;
    Left := 16;
    Top := 228;
    Caption := 'Assigné à:';
  end;
  
  cmbAssignedTo := TComboBox.Create(Self);
  with cmbAssignedTo do
  begin
    Parent := pnlNew;
    Left := 16;
    Top := 244;
    Width := 180;
    Style := csDropDownList;
    Items.Add('Service Social');
    Items.Add('Service Technique');
    Items.Add('Service Administratif');
    ItemIndex := 0;
  end;
end;

procedure TComplaintsForm.LoadCitizenInfo(CitizenId: Integer);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConnection;
    qry.SQL.Text := 'SELECT name, phone, address FROM citizens WHERE id = :id';
    qry.ParamByName('id').AsInteger := CitizenId;
    qry.Open;
    
    if not qry.IsEmpty then
    begin
      lblCitizenName.Caption := 'Nom: ' + qry.FieldByName('name').AsString;
      lblCitizenPhone.Caption := 'Téléphone: ' + qry.FieldByName('phone').AsString;
      lblCitizenAddress.Caption := 'Adresse: ' + qry.FieldByName('address').AsString;
      grpCitizenInfo.Visible := True;
    end
    else
    begin
      lblCitizenName.Caption := 'Nom: Non trouvé';
      lblCitizenPhone.Caption := 'Téléphone: -';
      lblCitizenAddress.Caption := 'Adresse: -';
      grpCitizenInfo.Visible := True;
    end;
  finally
    qry.Free;
  end;
end;

procedure TComplaintsForm.edtCitizenIdChange(Sender: TObject);
var
  CitizenId: Integer;
begin
  if TryStrToInt(edtCitizenId.Text, CitizenId) then
  begin
    LoadCitizenInfo(CitizenId);
  end
  else
  begin
    grpCitizenInfo.Visible := False;
  end;
end;

procedure TComplaintsForm.ConfigureGridColumns;
begin
  with dbgComplaints do
  begin
    Columns.Clear;
    
    with Columns.Add do
    begin
      FieldName := 'id';
      Title.Caption := 'N°';
      Width := 50;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'citizen_id';
      Title.Caption := 'ID Citoyen';
      Width := 80;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'description';
      Title.Caption := 'Description';
      Width := 200;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'complaint_type';
      Title.Caption := 'Type';
      Width := 100;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'priority';
      Title.Caption := 'Priorité';
      Width := 80;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'status';
      Title.Caption := 'Statut';
      Width := 100;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'assigned_to';
      Title.Caption := 'Assigné à';
      Width := 100;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'complaint_date';
      Title.Caption := 'Date';
      Width := 100;
    end;
  end;
end;

procedure TComplaintsForm.LoadComplaints;
begin
  try
    qryComplaints.Close;
    qryComplaints.SQL.Text := 
      'SELECT c.*, cit.name as citizen_name ' +
      'FROM complaints c ' +
      'LEFT JOIN citizens cit ON c.citizen_id = cit.id ' +
      'ORDER BY c.complaint_date DESC, c.priority DESC';
    qryComplaints.Open;
  except
    on E: Exception do
      ShowMessage('Erreur de chargement des plaintes: ' + E.Message);
  end;
end;

procedure TComplaintsForm.btnAddClick(Sender: TObject);
begin
  if edtCitizenId.Text = '' then
  begin
    ShowMessage('Veuillez entrer l''ID du citoyen');
    Exit;
  end;
  
  if memDescription.Text = '' then
  begin
    ShowMessage('Veuillez entrer une description');
    Exit;
  end;
  
  try
    FDConnection.ExecSQL(
      'INSERT INTO complaints (citizen_id, description, status, complaint_date, ' +
      'complaint_type, priority, assigned_to) ' +
      'VALUES (:citizen_id, :description, :status, :complaint_date, ' +
      ':complaint_type, :priority, :assigned_to)',
      [StrToInt(edtCitizenId.Text), memDescription.Text, cmbStatus.Text, 
       FormatDateTime('yyyy-mm-dd', dtComplaintDate.Date),
       cmbType.Text, cmbPriority.Text, cmbAssignedTo.Text]);
       
    ShowMessage('Plainte ajoutée avec succès');
    ClearFields;
    LoadComplaints;
  except
    on E: Exception do
      ShowMessage('Erreur d''ajout de la plainte: ' + E.Message);
  end;
end;

procedure TComplaintsForm.btnUpdateClick(Sender: TObject);
var
  complaintId: Integer;
begin
  if not Assigned(dbgComplaints.SelectedField) then
  begin
    ShowMessage('Veuillez sélectionner une plainte à mettre à jour');
    Exit;
  end;
  
  complaintId := qryComplaints.FieldByName('id').AsInteger;
  
  try
    FDConnection.ExecSQL(
      'UPDATE complaints SET status = :status WHERE id = :id',
      [cmbStatus.Text, complaintId]);
      
    ShowMessage('Statut mis à jour avec succès');
    LoadComplaints;
  except
    on E: Exception do
      ShowMessage('Erreur de mise à jour: ' + E.Message);
  end;
end;

procedure TComplaintsForm.btnClearClick(Sender: TObject);
begin
  ClearFields;
end;

procedure TComplaintsForm.ClearFields;
begin
  edtCitizenId.Clear;
  memDescription.Clear;
  cmbStatus.ItemIndex := 0;
  cmbType.ItemIndex := 0;
  cmbPriority.ItemIndex := 0;
  cmbAssignedTo.ItemIndex := 0;
  dtComplaintDate.Date := Date;
  lblCitizenName.Caption := 'Nom:';
  lblCitizenPhone.Caption := 'Téléphone:';
  lblCitizenAddress.Caption := 'Adresse:';
  grpCitizenInfo.Visible := False;
end;

procedure TComplaintsForm.dbgComplaintsCellClick(Column: TColumn);
begin
  if not qryComplaints.IsEmpty then
  begin
    edtCitizenId.Text := qryComplaints.FieldByName('citizen_id').AsString;
    memDescription.Text := qryComplaints.FieldByName('description').AsString;
    cmbStatus.Text := qryComplaints.FieldByName('status').AsString;
    cmbType.Text := qryComplaints.FieldByName('complaint_type').AsString;
    cmbPriority.Text := qryComplaints.FieldByName('priority').AsString;
    cmbAssignedTo.Text := qryComplaints.FieldByName('assigned_to').AsString;
    dtComplaintDate.Date := qryComplaints.FieldByName('complaint_date').AsDateTime;
  end;
end;

procedure TComplaintsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  qryComplaints.Close;
  FDConnection.Close;
end;

end.
