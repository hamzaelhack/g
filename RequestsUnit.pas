unit RequestsUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.DBGrids, Vcl.Grids, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, System.DateUtils, ComObj, ShellAPI;

type
  TRequestStatus = (rsEnAttente, rsEnCours, rsTermine, rsRejete);
  
  TRequestsForm = class(TForm)
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    lblTitle: TLabel;
    grpNewRequest: TGroupBox;
    lblCitizenId: TLabel;
    lblRequestType: TLabel;
    lblRequestDate: TLabel;
    lblUrgent: TLabel;
    edtCitizenId: TEdit;
    cmbRequestType: TComboBox;
    edtRequestDate: TEdit;
    chkUrgent: TCheckBox;
    btnSubmit: TButton;
    btnClear: TButton;
    btnGeneratePDF: TButton;
    dbgRequests: TDBGrid;
    FDConnection: TFDConnection;
    qryRequests: TFDQuery;
    dsRequests: TDataSource;
    
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSubmitClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnGeneratePDFClick(Sender: TObject);
    procedure edtCitizenIdChange(Sender: TObject);
    
  private
    procedure InitializeDatabase;
    procedure InitializeControls;
    procedure LoadRequests;
    procedure ClearFields;
    procedure GeneratePDF(RequestId: Integer);
    function GetCitizenName(CitizenId: Integer): string;
    function ValidateDate(const DateStr: string; var Date: TDateTime): Boolean;
    function FormatDateForDB(const DateStr: string): string;
    
  public
    { Déclarations publiques }
  end;

var
  RequestsForm: TRequestsForm;

implementation

{$R *.dfm}

procedure TRequestsForm.FormCreate(Sender: TObject);
begin
  Caption := 'Gestion des Demandes de Documents';
  Position := poScreenCenter;
  
  InitializeDatabase;
  InitializeControls;
  LoadRequests;
end;

procedure TRequestsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    if FDConnection.Connected then
      FDConnection.Connected := False;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la fermeture: ' + E.Message);
  end;
end;

procedure TRequestsForm.InitializeDatabase;
begin
  try
    // Configuration de la base de données
    FDConnection.Params.Clear;
    FDConnection.Params.Add('Database=citizens.db');
    FDConnection.Params.Add('DriverID=SQLite');
    FDConnection.Params.Add('OpenMode=CreateUTF8');
    
    if FDConnection.Connected then
      FDConnection.Connected := False;
      
    FDConnection.Connected := True;
    
    // Créer la table des demandes si elle n'existe pas
    FDConnection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS requests (' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'citizen_id INTEGER NOT NULL, ' +
      'request_type TEXT NOT NULL, ' +
      'request_date TEXT NOT NULL, ' +
      'urgent BOOLEAN DEFAULT 0, ' +
      'status INTEGER DEFAULT 0, ' +
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP, ' +
      'FOREIGN KEY (citizen_id) REFERENCES citizens(id))'
    );
    
    // Configurer la requête principale
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
      'ORDER BY r.created_at DESC';
  except
    on E: Exception do
      ShowMessage('Erreur d''initialisation de la base de données: ' + E.Message);
  end;
end;

procedure TRequestsForm.InitializeControls;
begin
  // Configuration des étiquettes
  lblTitle.Caption := 'Gestion des Demandes de Documents';
  lblCitizenId.Caption := 'ID Citoyen:';
  lblRequestType.Caption := 'Type de Document:';
  lblRequestDate.Caption := 'Date de Demande (JJ/MM/AAAA):';
  lblUrgent.Caption := 'Urgent:';
  
  // Configuration des boutons
  btnSubmit.Caption := 'Soumettre';
  btnClear.Caption := 'Effacer';
  btnGeneratePDF.Caption := 'Générer PDF';
  
  // Types de documents
  with cmbRequestType do
  begin
    Clear;
    Items.Add('Extrait de Naissance');
    Items.Add('Certificat de Résidence');
    Items.Add('Certificat de Nationalité');
    Items.Add('Carte d''Identité');
    Items.Add('Passeport');
    ItemIndex := -1;
  end;
  
  // Configuration de la grille
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
      FieldName := 'citizen_id';
      Title.Caption := 'ID Citoyen';
      Width := 80;
    end;
    
    with Columns.Add do
    begin
      FieldName := 'citizen_name';
      Title.Caption := 'Nom du Citoyen';
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
      Title.Caption := 'Date de Demande';
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
  
  // Date par défaut
  edtRequestDate.Text := FormatDateTime('dd/mm/yyyy', Now);
  edtRequestDate.TextHint := 'JJ/MM/AAAA';
  
  ClearFields;
end;

procedure TRequestsForm.LoadRequests;
begin
  try
    qryRequests.Close;
    qryRequests.Open;
  except
    on E: Exception do
      ShowMessage('Erreur de chargement des demandes: ' + E.Message);
  end;
end;

procedure TRequestsForm.btnSubmitClick(Sender: TObject);
var
  ValidDate: TDateTime;
  DateStr: string;
begin
  // Validation
  if Trim(edtCitizenId.Text) = '' then
  begin
    ShowMessage('Veuillez entrer l''ID du citoyen');
    edtCitizenId.SetFocus;
    Exit;
  end;
  
  if cmbRequestType.ItemIndex = -1 then
  begin
    ShowMessage('Veuillez sélectionner un type de document');
    cmbRequestType.SetFocus;
    Exit;
  end;
  
  if not ValidateDate(edtRequestDate.Text, ValidDate) then
  begin
    ShowMessage('Format de date invalide. Utilisez le format JJ/MM/AAAA');
    edtRequestDate.SetFocus;
    Exit;
  end;
  
  try
    DateStr := FormatDateForDB(edtRequestDate.Text);
    
    // Insérer la demande
    FDConnection.ExecSQL(
      'INSERT INTO requests (citizen_id, request_type, request_date, urgent) ' +
      'VALUES (:citizen_id, :request_type, :request_date, :urgent)',
      [StrToInt(edtCitizenId.Text),
       cmbRequestType.Text,
       DateStr,
       chkUrgent.Checked]
    );
    
    LoadRequests;
    ShowMessage('Demande soumise avec succès');
    ClearFields;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la soumission: ' + E.Message);
  end;
end;

procedure TRequestsForm.btnGeneratePDFClick(Sender: TObject);
var
  RequestId: Integer;
begin
  if not qryRequests.IsEmpty then
  begin
    RequestId := qryRequests.FieldByName('id').AsInteger;
    GeneratePDF(RequestId);
  end
  else
    ShowMessage('Veuillez sélectionner une demande');
end;

procedure TRequestsForm.GeneratePDF(RequestId: Integer);
var
  Word: Variant;
  Doc: Variant;
  CitizenName, RequestType, RequestDate: string;
begin
  try
    // Récupérer les informations de la demande
    with TFDQuery.Create(nil) do
    try
      Connection := FDConnection;
      SQL.Text := 
        'SELECT c.name, r.request_type, r.request_date ' +
        'FROM requests r ' +
        'JOIN citizens c ON r.citizen_id = c.id ' +
        'WHERE r.id = :id';
      ParamByName('id').AsInteger := RequestId;
      Open;
      
      if not IsEmpty then
      begin
        CitizenName := FieldByName('name').AsString;
        RequestType := FieldByName('request_type').AsString;
        RequestDate := FormatDateTime('dd/mm/yyyy', 
          StrToDateTime(FieldByName('request_date').AsString));
      end
      else
      begin
        ShowMessage('Demande non trouvée');
        Exit;
      end;
    finally
      Free;
    end;
    
    // Créer le document Word
    Word := CreateOleObject('Word.Application');
    Word.Visible := False;
    Doc := Word.Documents.Add;
    
    // Ajouter le contenu
    Doc.Content.Font.Name := 'Arial';
    Doc.Content.Font.Size := 12;
    
    // En-tête
    Doc.Content.Text := 'RÉPUBLIQUE FRANÇAISE' + #13#10 + #13#10;
    Doc.Content.Text := Doc.Content.Text + 'DEMANDE DE DOCUMENT OFFICIEL' + #13#10 + #13#10;
    
    // Corps du document
    Doc.Content.Text := Doc.Content.Text + 'Date: ' + RequestDate + #13#10;
    Doc.Content.Text := Doc.Content.Text + 'Nom du Citoyen: ' + CitizenName + #13#10;
    Doc.Content.Text := Doc.Content.Text + 'Type de Document: ' + RequestType + #13#10#13#10;
    
    Doc.Content.Text := Doc.Content.Text + 
      'Je soussigné(e) ' + CitizenName + ' demande par la présente ' +
      'la délivrance du document mentionné ci-dessus.' + #13#10#13#10;
    
    Doc.Content.Text := Doc.Content.Text + 
      'Signature du Demandeur:' + #13#10#13#10 +
      '_____________________' + #13#10#13#10;
    
    Doc.Content.Text := Doc.Content.Text + 
      'Cachet de l''Administration:' + #13#10#13#10 +
      '____________________';
    
    // Sauvegarder et ouvrir le PDF
    Doc.SaveAs(ExtractFilePath(Application.ExeName) + 
      'Demande_' + IntToStr(RequestId) + '.pdf', 17);
    Doc.Close;
    Word.Quit;
    
    // Ouvrir le PDF
    ShellExecute(0, 'open', 
      PChar(ExtractFilePath(Application.ExeName) + 
      'Demande_' + IntToStr(RequestId) + '.pdf'),
      nil, nil, SW_SHOWNORMAL);
      
    ShowMessage('Document PDF généré avec succès');
  except
    on E: Exception do
    begin
      ShowMessage('Erreur lors de la génération du PDF: ' + E.Message);
      if not VarIsEmpty(Word) then Word.Quit;
    end;
  end;
end;

function TRequestsForm.ValidateDate(const DateStr: string; var Date: TDateTime): Boolean;
var
  Day, Month, Year: Integer;
  Parts: TArray<string>;
begin
  Result := False;
  Parts := DateStr.Split(['/']);
  
  if Length(Parts) = 3 then
  begin
    if TryStrToInt(Parts[0], Day) and
       TryStrToInt(Parts[1], Month) and
       TryStrToInt(Parts[2], Year) then
    begin
      try
        Date := EncodeDate(Year, Month, Day);
        Result := True;
      except
        Result := False;
      end;
    end;
  end;
end;

function TRequestsForm.FormatDateForDB(const DateStr: string): string;
var
  Parts: TArray<string>;
begin
  Parts := DateStr.Split(['/']);
  if Length(Parts) = 3 then
    Result := Parts[2] + '-' + Parts[1] + '-' + Parts[0]
  else
    Result := '';
end;

procedure TRequestsForm.ClearFields;
begin
  edtCitizenId.Clear;
  cmbRequestType.ItemIndex := -1;
  edtRequestDate.Text := FormatDateTime('dd/mm/yyyy', Now);
  chkUrgent.Checked := False;
end;

procedure TRequestsForm.btnClearClick(Sender: TObject);
begin
  ClearFields;
end;

function TRequestsForm.GetCitizenName(CitizenId: Integer): string;
begin
  Result := '';
  with TFDQuery.Create(nil) do
  try
    Connection := FDConnection;
    SQL.Text := 'SELECT name FROM citizens WHERE id = :id';
    ParamByName('id').AsInteger := CitizenId;
    Open;
    if not IsEmpty then
      Result := FieldByName('name').AsString;
  finally
    Free;
  end;
end;

procedure TRequestsForm.edtCitizenIdChange(Sender: TObject);
var
  CitizenName: string;
begin
  if Trim(edtCitizenId.Text) <> '' then
  begin
    CitizenName := GetCitizenName(StrToIntDef(edtCitizenId.Text, 0));
    if CitizenName = '' then
      ShowMessage('Citoyen non trouvé')
    else
      lblCitizenId.Caption := 'ID Citoyen: ' + CitizenName;
  end
  else
    lblCitizenId.Caption := 'ID Citoyen:';
end;

end.
