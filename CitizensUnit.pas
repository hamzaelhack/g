unit CitizensUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.DBGrids, Vcl.Grids, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, System.DateUtils, Vcl.ExtDlgs, ComObj;

type
  TCitizensForm = class(TForm)
    pnlSearch: TPanel;
    pnlEdit: TPanel;
    pnlGrid: TPanel;
    lblSearchId: TLabel;
    lblSearchName: TLabel;
    edtSearchId: TEdit;
    edtSearchName: TEdit;
    btnSearch: TButton;
    btnClear: TButton;
    lblId: TLabel;
    lblName: TLabel;
    lblBirthDate: TLabel;
    lblGender: TLabel;
    lblMaritalStatus: TLabel;
    lblPhone: TLabel;
    lblAddress: TLabel;
    lblPhoto: TLabel;
    edtId: TEdit;
    edtName: TEdit;
    edtBirthDate: TEdit;
    cmbGender: TComboBox;
    cmbMaritalStatus: TComboBox;
    edtPhone: TEdit;
    edtAddress: TEdit;
    imgPhoto: TImage;
    btnLoadPhoto: TButton;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    dbgCitizens: TDBGrid;
    btnExportExcel: TButton;
    FDConnection: TFDConnection;
    qryCitizens: TFDQuery;
    dsCitizens: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSearchClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure dbgCitizensCellClick(Column: TColumn);
    procedure btnLoadPhotoClick(Sender: TObject);
    procedure btnExportExcelClick(Sender: TObject);
    procedure dbgCitizensDblClick(Sender: TObject);
  private
    procedure InitializeDatabase;
    procedure InitializeControls;
    procedure ClearFields;
    procedure LoadCitizen(AId: Integer);
    procedure LoadCitizens;
    procedure SavePhotoToDatabase(const PhotoPath: string);
    procedure LoadPhotoFromDatabase(CitizenId: Integer);
    procedure ConfigureGridColumns;
    function ValidateDate(const DateStr: string; var Date: TDateTime): Boolean;
    function FormatDateForDB(const DateStr: string): string;
  public
    { Public declarations }
  end;

var
  CitizensForm: TCitizensForm;

implementation

{$R *.dfm}

procedure TCitizensForm.FormCreate(Sender: TObject);
begin
  try
    Caption := 'Gestion des Citoyens';
    BiDiMode := bdLeftToRight;  
    Position := poScreenCenter;
    
    // Initialize database first
    InitializeDatabase;
    
    // Then initialize controls
    InitializeControls;
    
    // Configure grid columns
    ConfigureGridColumns;
    
    // Finally load data
    LoadCitizens;
  except
    on E: Exception do
      ShowMessage('Erreur lors de l''initialisation: ' + E.Message);
  end;
end;

procedure TCitizensForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    // Save any pending changes
    if FDConnection.Connected then
    begin
      if qryCitizens.State in [dsEdit, dsInsert] then
        qryCitizens.Post;
      FDConnection.Connected := False;
    end;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la fermeture: ' + E.Message);
  end;
end;

procedure TCitizensForm.InitializeDatabase;
begin
  try
    // Configuration de la base de données
    FDConnection.Params.Clear;
    FDConnection.Params.Add('Database=citizens.db');
    FDConnection.Params.Add('DriverID=SQLite');
    FDConnection.Params.Add('OpenMode=CreateUTF8');
    FDConnection.Params.Add('LockingMode=Normal');
    FDConnection.Params.Add('SharedCache=False');
    FDConnection.Params.Add('UpdateOptions.LockWait=True');
    
    // Fermer la connexion si elle est ouverte
    if FDConnection.Connected then
      FDConnection.Connected := False;
      
    // Établir la connexion
    FDConnection.Connected := True;
    
    // Désactiver temporairement les contraintes de clé étrangère
    FDConnection.ExecSQL('PRAGMA foreign_keys = OFF');
    
    // Supprimer les tables existantes
    FDConnection.ExecSQL('DROP TABLE IF EXISTS documents');
    FDConnection.ExecSQL('DROP TABLE IF EXISTS requests');
    FDConnection.ExecSQL('DROP TABLE IF EXISTS complaints');
    FDConnection.ExecSQL('DROP TABLE IF EXISTS citizens');
    
    // Créer la table citizens
    FDConnection.ExecSQL(
      'CREATE TABLE citizens (' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'name TEXT NOT NULL, ' +
      'birth_date TEXT, ' +
      'gender INTEGER DEFAULT 0, ' +
      'marital_status INTEGER DEFAULT 0, ' +
      'phone TEXT, ' +
      'address TEXT, ' +
      'photo BLOB)'
    );
    
    // Insérer des données d''exemple
    FDConnection.ExecSQL(
      'INSERT INTO citizens (name, birth_date, gender, marital_status, phone, address) VALUES ' +
      '(''hamza hafid'', ''1992-11-12'', 0, 1, ''0659582838'', ''oum el bouaghi ''), ' +
      '(''adouali latifa'', ''1992-08-22'', 1, 0, ''0655667788'', ''ain beida''), ' +
      '(''sofian mekiii'', ''1975-03-10'', 0, 1, ''0633445566'', ''ain beida''), ' +
      '(''samira hind'', ''1988-11-30'', 1, 2, ''0622334455'', ''ain beida''), ' +
      '(''salima sali'', ''1995-07-25'', 0, 0, ''0666778899'', ''ain beida test'')'
    );
    
    // Réactiver les contraintes de clé étrangère
    FDConnection.ExecSQL('PRAGMA foreign_keys = ON');
    
    // Configurer la requête principale
    qryCitizens.SQL.Text := 
      'SELECT ' +
      'id, name, ' +
      'strftime(''%d/%m/%Y'', birth_date) as birth_date, ' +
      'gender, marital_status, phone, address, ' +
      'CASE gender ' +
      '  WHEN 0 THEN ''Homme'' ' +
      '  WHEN 1 THEN ''Femme'' ' +
      'END as gender_text, ' +
      'CASE marital_status ' +
      '  WHEN 0 THEN ''Célibataire'' ' +
      '  WHEN 1 THEN ''Marié(e)'' ' +
      '  WHEN 2 THEN ''Divorcé(e)'' ' +
      '  WHEN 3 THEN ''Veuf(ve)'' ' +
      'END as marital_status_text ' +
      'FROM citizens ' +
      'ORDER BY id DESC';
      
    ShowMessage('Base de données initialisée avec succès');
  except
    on E: Exception do
    begin
      ShowMessage('Erreur lors de l''initialisation de la base de données: ' + E.Message);
      if FDConnection.Connected then
        FDConnection.Connected := False;
    end;
  end;
end;

procedure TCitizensForm.InitializeControls;
begin
  // Initialisation des listes déroulantes
  with cmbGender do
  begin
    Clear;
    Items.Add('Homme');
    Items.Add('Femme');
    ItemIndex := 0;
  end;
  
  with cmbMaritalStatus do
  begin
    Clear;
    Items.Add('Célibataire');
    Items.Add('Marié(e)');
    Items.Add('Divorcé(e)');
    Items.Add('Veuf(ve)');
    ItemIndex := 0;
  end;
  
  // Configuration du champ de date
  edtBirthDate.Text := '';
  edtBirthDate.TextHint := 'JJ/MM/AAAA';
  
  // Configuration des boutons
  btnAdd.Caption := 'Ajouter';
  btnEdit.Caption := 'Modifier';
  btnDelete.Caption := 'Supprimer';
  btnSearch.Caption := 'Rechercher';
  btnClear.Caption := 'Effacer';
  btnLoadPhoto.Caption := 'Charger Photo';
  btnExportExcel.Caption := 'Exporter Excel';
  
  // Configuration des étiquettes
  lblSearchId.Caption := 'ID:';
  lblSearchName.Caption := 'Nom:';
  lblId.Caption := 'ID:';
  lblName.Caption := 'Nom:';
  lblBirthDate.Caption := 'Date de Naissance (JJ/MM/AAAA):';
  lblGender.Caption := 'Genre:';
  lblMaritalStatus.Caption := 'État Civil:';
  lblPhone.Caption := 'Téléphone:';
  lblAddress.Caption := 'Adresse:';
  lblPhoto.Caption := 'Photo:';
  
  // Effacer les champs
  ClearFields;
end;

procedure TCitizensForm.ConfigureGridColumns;
begin
  with dbgCitizens do
  begin
    // Configuration des colonnes en français
    Columns[0].Title.Caption := 'ID';
    Columns[1].Title.Caption := 'Nom';
    Columns[2].Title.Caption := 'Date de Naissance';
    Columns[3].Title.Caption := 'Genre';
    Columns[4].Title.Caption := 'État Civil';
    Columns[5].Title.Caption := 'Téléphone';
    Columns[6].Title.Caption := 'Adresse';
    
    // Ajustement des largeurs de colonnes
    Columns[0].Width := 70;  // ID
    Columns[1].Width := 150; // Nom
    Columns[2].Width := 100; // Date de Naissance
    Columns[3].Width := 80;  // Genre
    Columns[4].Width := 100; // État Civil
    Columns[5].Width := 100; // Téléphone
    Columns[6].Width := 200; // Adresse
  end;
end;

procedure TCitizensForm.LoadCitizens;
begin
  try
    qryCitizens.Close;
    qryCitizens.Open;
  except
    on E: Exception do
      ShowMessage('Erreur lors du chargement des citoyens: ' + E.Message);
  end;
end;

procedure TCitizensForm.btnSearchClick(Sender: TObject);
var
  SQL: string;
begin
  try
    SQL := 'SELECT ' +
           'c.id, ' +
           'c.name, ' +
           'strftime(''%d/%m/%Y'', c.birth_date) as birth_date, ' +
           'c.gender, ' +
           'c.marital_status, ' +
           'c.phone, ' +
           'c.address, ' +
           'CASE c.gender ' +
           '  WHEN 0 THEN ''Homme'' ' +
           '  WHEN 1 THEN ''Femme'' ' +
           'END as gender_text, ' +
           'CASE c.marital_status ' +
           '  WHEN 0 THEN ''Célibataire'' ' +
           '  WHEN 1 THEN ''Marié(e)'' ' +
           '  WHEN 2 THEN ''Divorcé(e)'' ' +
           '  WHEN 3 THEN ''Veuf(ve)'' ' +
           'END as marital_status_text ' +
           'FROM citizens c WHERE 1=1';

    if Trim(edtSearchId.Text) <> '' then
      SQL := SQL + ' AND c.id = ' + QuotedStr(Trim(edtSearchId.Text));

    if Trim(edtSearchName.Text) <> '' then
      SQL := SQL + ' AND c.name LIKE ' + QuotedStr('%' + Trim(edtSearchName.Text) + '%');

    SQL := SQL + ' ORDER BY c.id DESC';

    qryCitizens.Close;
    qryCitizens.SQL.Text := SQL;
    qryCitizens.Open;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la recherche: ' + E.Message);
  end;
end;

procedure TCitizensForm.btnAddClick(Sender: TObject);
var
  LastId: Integer;
  ValidDate: TDateTime;
  DateStr: string;
begin
  try
    if Trim(edtName.Text) = '' then
    begin
      ShowMessage('Veuillez entrer le nom du citoyen');
      edtName.SetFocus;
      Exit;
    end;

    if not ValidateDate(edtBirthDate.Text, ValidDate) then
    begin
      ShowMessage('Format de date invalide. Utilisez le format JJ/MM/AAAA');
      edtBirthDate.SetFocus;
      Exit;
    end;

    DateStr := FormatDateForDB(edtBirthDate.Text);
    if DateStr = '' then
    begin
      ShowMessage('Erreur de format de date');
      Exit;
    end;

    // Add citizen with auto-generated ID
    FDConnection.ExecSQL(
      'INSERT INTO citizens (name, birth_date, gender, marital_status, phone, address) ' +
      'VALUES (:name, :birth_date, :gender, :marital_status, :phone, :address)',
      [Trim(edtName.Text), DateStr, cmbGender.ItemIndex,
       cmbMaritalStatus.ItemIndex, Trim(edtPhone.Text), Trim(edtAddress.Text)]
    );
    
    // Get the last inserted ID
    with TFDQuery.Create(nil) do
    try
      Connection := FDConnection;
      SQL.Text := 'SELECT last_insert_rowid() as last_id';
      Open;
      LastId := FieldByName('last_id').AsInteger;
    finally
      Free;
    end;

    // Refresh grid and select the new record
    LoadCitizens;
    qryCitizens.Locate('id', LastId, []);
    
    ShowMessage('Citoyen ajouté avec succès' + #13#10 + 'ID: ' + IntToStr(LastId));
    ClearFields;
  except
    on E: Exception do
      ShowMessage('Erreur lors de l''ajout: ' + E.Message);
  end;
end;

procedure TCitizensForm.btnEditClick(Sender: TObject);
var
  ValidDate: TDateTime;
  DateStr: string;
begin
  try
    if Trim(edtId.Text) = '' then
    begin
      ShowMessage('Veuillez sélectionner un citoyen à modifier');
      Exit;
    end;

    if not ValidateDate(edtBirthDate.Text, ValidDate) then
    begin
      ShowMessage('Format de date invalide. Utilisez le format JJ/MM/AAAA');
      edtBirthDate.SetFocus;
      Exit;
    end;

    DateStr := FormatDateForDB(edtBirthDate.Text);
    if DateStr = '' then
    begin
      ShowMessage('Erreur de format de date');
      Exit;
    end;

    FDConnection.ExecSQL(
      'UPDATE citizens SET ' +
      'name = :name, ' +
      'birth_date = :birth_date, ' +
      'gender = :gender, ' +
      'marital_status = :marital_status, ' +
      'phone = :phone, ' +
      'address = :address ' +
      'WHERE id = :id',
      [Trim(edtName.Text),
       DateStr,
       cmbGender.ItemIndex,
       cmbMaritalStatus.ItemIndex,
       Trim(edtPhone.Text),
       Trim(edtAddress.Text),
       StrToInt(edtId.Text)]
    );
    
    LoadCitizens;
    ShowMessage('Citoyen modifié avec succès');
    ClearFields;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la modification: ' + E.Message);
  end;
end;

procedure TCitizensForm.btnDeleteClick(Sender: TObject);
begin
  try
    if Trim(edtId.Text) = '' then
    begin
      ShowMessage('Veuillez sélectionner un citoyen à supprimer');
      Exit;
    end;

    if MessageDlg('Êtes-vous sûr de vouloir supprimer ce citoyen ?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      FDConnection.ExecSQL(
        'DELETE FROM citizens WHERE id = :id',
        [StrToInt(edtId.Text)]
      );

      LoadCitizens;
      ShowMessage('Citoyen supprimé avec succès');
      ClearFields;
    end;
  except
    on E: Exception do
      ShowMessage('Erreur lors de la suppression: ' + E.Message);
  end;
end;

procedure TCitizensForm.btnClearClick(Sender: TObject);
begin
  edtSearchId.Clear;
  edtSearchName.Clear;
  LoadCitizens;
end;

procedure TCitizensForm.ClearFields;
begin
  edtId.Clear;
  edtName.Clear;
  edtBirthDate.Clear;
  cmbGender.ItemIndex := -1;
  cmbMaritalStatus.ItemIndex := -1;
  edtPhone.Clear;
  edtAddress.Clear;
  edtSearchId.Clear;
  edtSearchName.Clear;
  imgPhoto.Picture := nil;
end;

procedure TCitizensForm.dbgCitizensCellClick(Column: TColumn);
begin
  if not qryCitizens.IsEmpty then
    LoadCitizen(qryCitizens.FieldByName('id').AsInteger);
end;

procedure TCitizensForm.LoadCitizen(AId: Integer);
var
  qry: TFDQuery;
  DateStr: string;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConnection;
    qry.SQL.Text := 'SELECT * FROM citizens WHERE id = :id';
    qry.ParamByName('id').AsInteger := AId;
    qry.Open;
    
    if not qry.IsEmpty then
    begin
      edtId.Text := qry.FieldByName('id').AsString;
      edtName.Text := qry.FieldByName('name').AsString;
      
      // تحويل التاريخ من صيغة قاعدة البيانات إلى الصيغة المعروضة
      DateStr := qry.FieldByName('birth_date').AsString;
      if DateStr <> '' then
      begin
        try
          edtBirthDate.Text := FormatDateTime('dd/mm/yyyy', 
            StrToDateTime(DateStr));
        except
          edtBirthDate.Text := '';
        end;
      end;
      
      cmbGender.ItemIndex := qry.FieldByName('gender').AsInteger;
      cmbMaritalStatus.ItemIndex := qry.FieldByName('marital_status').AsInteger;
      edtPhone.Text := qry.FieldByName('phone').AsString;
      edtAddress.Text := qry.FieldByName('address').AsString;
      LoadPhotoFromDatabase(AId);
    end;
  finally
    qry.Free;
  end;
end;

procedure TCitizensForm.btnLoadPhotoClick(Sender: TObject);
var
  OpenDialog: TOpenPictureDialog;
begin
  OpenDialog := TOpenPictureDialog.Create(nil);
  try
    OpenDialog.Filter := 'Images|*.jpg;*.jpeg;*.png;*.bmp';
    if OpenDialog.Execute then
    begin
      imgPhoto.Picture.LoadFromFile(OpenDialog.FileName);
      if edtId.Text <> '' then
        SavePhotoToDatabase(OpenDialog.FileName);
    end;
  finally
    OpenDialog.Free;
  end;
end;

procedure TCitizensForm.SavePhotoToDatabase(const PhotoPath: string);
var
  Stream: TMemoryStream;
  qry: TFDQuery;
begin
  if edtId.Text = '' then Exit;
  
  Stream := TMemoryStream.Create;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConnection;
    qry.SQL.Text := 'UPDATE citizens SET photo = :photo WHERE id = :id';
    
    imgPhoto.Picture.SaveToStream(Stream);
    Stream.Position := 0;
    
    qry.ParamByName('photo').LoadFromStream(Stream, ftBlob);
    qry.ParamByName('id').AsInteger := StrToInt(edtId.Text);
    qry.ExecSQL;
  finally
    Stream.Free;
    qry.Free;
  end;
end;

procedure TCitizensForm.LoadPhotoFromDatabase(CitizenId: Integer);
var
  qry: TFDQuery;
  Stream: TMemoryStream;
begin
  qry := TFDQuery.Create(nil);
  Stream := TMemoryStream.Create;
  try
    qry.Connection := FDConnection;
    qry.SQL.Text := 'SELECT photo FROM citizens WHERE id = :id';
    qry.ParamByName('id').AsInteger := CitizenId;
    qry.Open;
    
    if not qry.Fields[0].IsNull then
    begin
      TBlobField(qry.Fields[0]).SaveToStream(Stream);
      Stream.Position := 0;
      imgPhoto.Picture.LoadFromStream(Stream);
    end
    else
      imgPhoto.Picture := nil;
  finally
    qry.Free;
    Stream.Free;
  end;
end;

procedure TCitizensForm.btnExportExcelClick(Sender: TObject);
var
  Excel: Variant;
  Sheet: Variant;
  Row: Integer;
begin
  try
    Excel := CreateOleObject('Excel.Application');
    Excel.Visible := False;
    Excel.Workbooks.Add;
    Sheet := Excel.ActiveSheet;

    // Add headers
    Sheet.Cells[1, 1] := 'ID';
    Sheet.Cells[1, 2] := 'Nom';
    Sheet.Cells[1, 3] := 'Date de Naissance';
    Sheet.Cells[1, 4] := 'Genre';
    Sheet.Cells[1, 5] := 'État Civil';
    Sheet.Cells[1, 6] := 'Téléphone';
    Sheet.Cells[1, 7] := 'Adresse';

    // Format header
    Sheet.Range['A1:G1'].Font.Bold := True;
    Sheet.Range['A1:G1'].Interior.Color := RGB(200, 200, 200);

    // Add data
    Row := 2;
    qryCitizens.First;
    while not qryCitizens.Eof do
    begin
      Sheet.Cells[Row, 1] := qryCitizens.FieldByName('id').AsInteger;
      Sheet.Cells[Row, 2] := qryCitizens.FieldByName('name').AsString;
      Sheet.Cells[Row, 3] := qryCitizens.FieldByName('birth_date').AsString;
      Sheet.Cells[Row, 4] := qryCitizens.FieldByName('gender_text').AsString;
      Sheet.Cells[Row, 5] := qryCitizens.FieldByName('marital_status_text').AsString;
      Sheet.Cells[Row, 6] := qryCitizens.FieldByName('phone').AsString;
      Sheet.Cells[Row, 7] := qryCitizens.FieldByName('address').AsString;
      
      Inc(Row);
      qryCitizens.Next;
    end;

    // Auto-fit columns
    Sheet.Range['A1:G' + IntToStr(Row-1)].Columns.AutoFit;

    // Save and close
    Excel.Visible := True;
    ShowMessage('Export terminé avec succès');
  except
    on E: Exception do
    begin
      ShowMessage('Erreur lors de l''export: ' + E.Message);
      Excel.Quit;
    end;
  end;
end;

procedure TCitizensForm.dbgCitizensDblClick(Sender: TObject);
begin
  if not qryCitizens.IsEmpty then
  begin
    edtId.Text := qryCitizens.FieldByName('id').AsString;
    edtName.Text := qryCitizens.FieldByName('name').AsString;
    edtBirthDate.Text := qryCitizens.FieldByName('birth_date').AsString;
    cmbGender.ItemIndex := qryCitizens.FieldByName('gender').AsInteger;
    cmbMaritalStatus.ItemIndex := qryCitizens.FieldByName('marital_status').AsInteger;
    edtPhone.Text := qryCitizens.FieldByName('phone').AsString;
    edtAddress.Text := qryCitizens.FieldByName('address').AsString;
  end;
end;

function TCitizensForm.ValidateDate(const DateStr: string; var Date: TDateTime): Boolean;
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

function TCitizensForm.FormatDateForDB(const DateStr: string): string;
var
  Parts: TArray<string>;
begin
  Parts := DateStr.Split(['/']);
  if Length(Parts) = 3 then
    Result := Parts[2] + '-' + Parts[1] + '-' + Parts[0]
  else
    Result := '';
end;

end.
