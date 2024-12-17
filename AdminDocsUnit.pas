unit AdminDocsUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.DBGrids, Vcl.Grids, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, System.DateUtils, Vcl.ExtDlgs, ComObj, ActiveX, ShellAPI;

type
  TAdminDocsForm = class(TForm)
    { Composants de l'interface }
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    dbgDocuments: TDBGrid;
    grpNewDoc: TGroupBox;
    lblDocType: TLabel;
    cmbDocType: TComboBox;
    lblCitizenId: TLabel;
    edtCitizenId: TEdit;
    lblRequestDate: TLabel;
    dtRequestDate: TDateTimePicker;
    btnGenerate: TButton;
    btnPrint: TButton;
    btnArchive: TButton;
    grpCitizenInfo: TGroupBox;
    lblCitizenName: TLabel;
    lblCitizenBirthDate: TLabel;
    FDConnection: TFDConnection;
    qryDocuments: TFDQuery;
    dsDocuments: TDataSource;
    
    { Événements }
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnGenerateClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnArchiveClick(Sender: TObject);
    procedure edtCitizenIdChange(Sender: TObject);
    
  private
    { Variables privées }
    DefaultFont: string;
    DefaultFontSize: Integer;
    DocDir: string;
    FlagPath: string;
    
    { Méthodes privées }
    procedure InitializeDatabase;
    procedure InitializeControls;
    procedure LoadCitizenInfo(CitizenId: Integer);
    procedure SetDefaultAppearance;
    procedure ConfigureGridColumns;
    procedure LoadDocuments;
    procedure GeneratePDF(DocType: string; CitizenId: Integer);
    procedure OpenPDF(const FilePath: string);
  public
    { Méthodes publiques }
  end;

var
  AdminDocsForm: TAdminDocsForm;

implementation

{$R *.dfm}

procedure TAdminDocsForm.FormCreate(Sender: TObject);
begin
  SetDefaultAppearance;
  InitializeDatabase;
  InitializeControls;
  ConfigureGridColumns;
  LoadDocuments;
  
  // Création du dossier documents si nécessaire
  if not DirectoryExists(ExtractFilePath(Application.ExeName) + 'documents') then
    ForceDirectories(ExtractFilePath(Application.ExeName) + 'documents');
    
  // Création du dossier resources si nécessaire
  if not DirectoryExists(ExtractFilePath(Application.ExeName) + 'resources') then
    ForceDirectories(ExtractFilePath(Application.ExeName) + 'resources');
end;

procedure TAdminDocsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Nettoyage des ressources
  if Assigned(qryDocuments) then
  begin
    qryDocuments.Close;
  end;
  
  if Assigned(FDConnection) then
  begin
    if FDConnection.Connected then
      FDConnection.Close;
  end;
end;

procedure TAdminDocsForm.SetDefaultAppearance;
begin
  // Configuration des paramètres par défaut
  Self.Font.Name := 'Arial';
  Self.Font.Size := 10;
  
  // Mise à jour des polices pour tous les composants
  pnlTop.Font.Name := 'Arial';
  pnlTop.Font.Size := 10;
  grpNewDoc.Font.Name := 'Arial';
  grpNewDoc.Font.Size := 10;
  grpCitizenInfo.Font.Name := 'Arial';
  grpCitizenInfo.Font.Size := 10;
  
  // Mise à jour des titres
  Self.Caption := 'Système de Gestion des Documents';
  grpNewDoc.Caption := 'Nouveau Document';
  grpCitizenInfo.Caption := 'Informations du Citoyen';
  
  // Mise à jour des labels
  lblDocType.Caption := 'Type de Document:';
  lblCitizenId.Caption := 'ID Citoyen:';
  lblRequestDate.Caption := 'Date de Demande:';
  lblCitizenName.Caption := 'Nom:';
  lblCitizenBirthDate.Caption := 'Date de Naissance:';
  
  // Mise à jour des boutons
  btnGenerate.Caption := 'Générer';
  btnPrint.Caption := 'Imprimer';
  btnArchive.Caption := 'Archiver';
  
  // Configuration de la grille
  with dbgDocuments do
  begin
    Font.Name := 'Arial';
    Font.Size := 9;
    TitleFont.Name := 'Arial';
    TitleFont.Size := 9;
    TitleFont.Style := [fsBold];
  end;
end;

procedure TAdminDocsForm.InitializeDatabase;
begin
  try
    FDConnection.Params.Clear;
    FDConnection.Params.Add('Database=citizens.db');
    FDConnection.Params.Add('DriverID=SQLite');
    
    // Création de la table des documents si elle n'existe pas
    FDConnection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS admin_documents (' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'citizen_id INTEGER NOT NULL,' +
      'doc_type TEXT NOT NULL,' +
      'request_date DATE NOT NULL,' +
      'status TEXT NOT NULL,' +
      'file_path TEXT,' +
      'FOREIGN KEY(citizen_id) REFERENCES citizens(id))');
  except
    on E: Exception do
      ShowMessage('Erreur de base de données: ' + E.Message);
  end;
end;

procedure TAdminDocsForm.InitializeControls;
begin
  // Configuration des polices
  grpNewDoc.Font.Name := 'Arial';
  grpNewDoc.Font.Size := 10;
  grpCitizenInfo.Font.Name := 'Arial';
  grpCitizenInfo.Font.Size := 10;
  
  // Configuration des libellés
  grpNewDoc.Caption := 'Nouveau Document';
  grpCitizenInfo.Caption := 'Informations du Citoyen';
  
  lblDocType.Caption := 'Type de Document:';
  lblCitizenId.Caption := 'ID Citoyen:';
  lblRequestDate.Caption := 'Date de Demande:';
  
  // Configuration de la liste déroulante
  cmbDocType.Font.Name := 'Arial';
  cmbDocType.Font.Size := 10;
  cmbDocType.Items.Clear;
  cmbDocType.Items.Add('Certificat de Naissance');
  cmbDocType.Items.Add('Certificat de Résidence');
  cmbDocType.Items.Add('Certificat de Décès');
  cmbDocType.Items.Add('Certificat de Nationalité');
  cmbDocType.Items.Add('Fiche Familiale');
  cmbDocType.Style := csDropDownList;
  
  // Configuration des boutons
  btnGenerate.Font.Name := 'Arial';
  btnGenerate.Font.Size := 10;
  btnGenerate.Caption := 'Générer';
  
  btnPrint.Font.Name := 'Arial';
  btnPrint.Font.Size := 10;
  btnPrint.Caption := 'Imprimer';
  
  btnArchive.Font.Name := 'Arial';
  btnArchive.Font.Size := 10;
  btnArchive.Caption := 'Archiver';
  
  // Date par défaut
  dtRequestDate.Date := Date;
end;

procedure TAdminDocsForm.ConfigureGridColumns;
begin
  with dbgDocuments do
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
      FieldName := 'doc_type';
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
      FieldName := 'status';
      Title.Caption := 'État';
      Width := 80;
    end;
  end;
end;

procedure TAdminDocsForm.LoadDocuments;
begin
  qryDocuments.Close;
  qryDocuments.SQL.Text := 
    'SELECT d.*, c.name as citizen_name ' +
    'FROM admin_documents d ' +
    'LEFT JOIN citizens c ON d.citizen_id = c.id ' +
    'ORDER BY d.request_date DESC';
  qryDocuments.Open;
end;

procedure TAdminDocsForm.btnGenerateClick(Sender: TObject);
var
  CitizenId: Integer;
begin
  if edtCitizenId.Text = '' then
  begin
    ShowMessage('Veuillez saisir un ID de citoyen.');
    Exit;
  end;
  
  if TryStrToInt(edtCitizenId.Text, CitizenId) then
  begin
    if cmbDocType.ItemIndex >= 0 then
    begin
      GeneratePDF(cmbDocType.Text, CitizenId);
    end
    else
      ShowMessage('Veuillez sélectionner un type de document');
  end
  else
    ShowMessage('ID Citoyen invalide');
end;

procedure TAdminDocsForm.OpenPDF(const FilePath: string);
var
  ExecInfo: TShellExecuteInfo;
begin
  if FileExists(FilePath) then
  begin
    FillChar(ExecInfo, SizeOf(ExecInfo), 0);
    with ExecInfo do
    begin
      cbSize := SizeOf(ExecInfo);
      fMask := SEE_MASK_NOCLOSEPROCESS;
      lpVerb := 'open';
      lpFile := PChar(FilePath);
      nShow := SW_SHOWNORMAL;
    end;
    if not ShellExecuteEx(@ExecInfo) then
      ShowMessage('Erreur lors de l''ouverture du fichier PDF. Code: ' + IntToStr(GetLastError));
  end
  else
    ShowMessage('Le fichier PDF n''existe pas: ' + FilePath);
end;

procedure TAdminDocsForm.btnPrintClick(Sender: TObject);
var
  FilePath: string;
begin
  if not qryDocuments.IsEmpty then
  begin
    FilePath := qryDocuments.FieldByName('file_path').AsString;
    if FileExists(FilePath) then
    begin
      // Impression du fichier PDF
      ShellExecute(0, 'print', PChar(FilePath), nil, nil, SW_HIDE);
      ShowMessage('Document envoyé à l''imprimante.');
    end
    else
      ShowMessage('Le fichier PDF n''existe pas.');
  end
  else
    ShowMessage('Veuillez sélectionner un document à imprimer.');
end;

procedure TAdminDocsForm.GeneratePDF(DocType: string; CitizenId: Integer);
var
  qry: TFDQuery;
  FilePath, FlagPath: string;
  Word: OleVariant;
  Doc: OleVariant;
  Selection: OleVariant;
  CitizenName, BirthDate: string;
  DocDir: string;
  Shape: OleVariant;
  DefaultFont: string;
  DefaultFontSize: Integer;
begin
  DefaultFont := 'Times New Roman';
  DefaultFontSize := 12;
  DocDir := ExtractFilePath(Application.ExeName) + 'documents';
  FlagPath := ExtractFilePath(Application.ExeName) + 'resources\flag.png';
  
  // Vérification des dossiers et fichiers nécessaires
  if not DirectoryExists(DocDir) then
  begin
    try
      ForceDirectories(DocDir);
    except
      on E: Exception do
      begin
        ShowMessage('Erreur lors de la création du dossier documents: ' + E.Message);
        Exit;
      end;
    end;
  end;
    
  if not FileExists(FlagPath) then
  begin
    ShowMessage('Le drapeau algérien n''a pas été trouvé. Veuillez placer l''image "flag.png" dans le dossier "resources".');
    Exit;
  end;
  
  FilePath := DocDir + '\' + FormatDateTime('yyyymmddhhnnss', Now) + '_' + 
    IntToStr(CitizenId) + '.pdf';

  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConnection;
    qry.SQL.Text := 'SELECT name, birth_date FROM citizens WHERE id = :id';
    qry.ParamByName('id').AsInteger := CitizenId;
    qry.Open;
    
    if not qry.IsEmpty then
    begin
      CitizenName := qry.FieldByName('name').AsString;
      BirthDate := qry.FieldByName('birth_date').AsString;
      
      try
        Word := Unassigned;
        Doc := Unassigned;
        Selection := Unassigned;
        Shape := Unassigned;
        
        try
          Word := CreateOleObject('Word.Application');
          Word.Visible := False;
          Doc := Word.Documents.Add;
          Selection := Word.Selection;
          
          // Configuration de la page
          Doc.PageSetup.TopMargin := 30;
          Doc.PageSetup.BottomMargin := 30;
          Doc.PageSetup.LeftMargin := 50;
          Doc.PageSetup.RightMargin := 50;
          Doc.PageSetup.Orientation := 1; // Portrait
          
          // Configuration de la police par défaut pour tout le document
          Doc.Content.Font.Name := DefaultFont;
          Doc.Content.Font.Size := DefaultFontSize;
          
          try
            // Ajout du drapeau algérien
            Shape := Doc.Shapes.AddPicture(
              Filename := FlagPath,
              LinkToFile := False,
              SaveWithDocument := True,
              Left := Doc.PageSetup.LeftMargin,
              Top := 30,
              Width := 100,
              Height := 67
            );
            Shape.WrapFormat.Type := 3;
          except
            on E: Exception do
            begin
              ShowMessage('Erreur lors de l''ajout du drapeau: ' + E.Message);
              // Continue sans le drapeau
            end;
          end;
          
          // Espacement après le drapeau
          Selection.TypeParagraph;
          Selection.TypeParagraph;
          
          // En-tête
          Selection.Font.Name := DefaultFont;
          Selection.Font.Size := 16;
          Selection.Font.Bold := 1;
          Selection.ParagraphFormat.Alignment := 1; // Centré
          Selection.ParagraphFormat.SpaceAfter := 6;
          
          Selection.TypeText('RÉPUBLIQUE ALGÉRIENNE DÉMOCRATIQUE ET POPULAIRE');
          Selection.TypeParagraph;
          Selection.Font.Size := 14;
          Selection.TypeText('WILAYA D''OUM EL BOUAGHI');
          Selection.TypeParagraph;
          Selection.TypeText('DAIRA D''AIN BEIDA');
          Selection.TypeParagraph;
          Selection.TypeText('COMMUNE D''AIN BEIDA');
          Selection.TypeParagraph;
          Selection.TypeText('ÉTAT CIVIL');
          Selection.TypeParagraph;
          Selection.TypeParagraph;
          
          // Type de document
          Selection.Font.Size := 18;
          Selection.Font.Bold := 1;
          Selection.Font.Name := DefaultFont;
          Selection.TypeText(UpperCase(DocType));
          Selection.TypeParagraph;
          Selection.TypeParagraph;
          
          // Contenu du document
          Selection.Font.Name := DefaultFont;
          Selection.Font.Size := DefaultFontSize;
          Selection.Font.Bold := 0;
          Selection.ParagraphFormat.Alignment := 0; // Gauche
          Selection.ParagraphFormat.SpaceAfter := 12;
          Selection.ParagraphFormat.LineSpacing := 15; // Interligne 1.5
          
          Selection.TypeText('Je soussigné, Officier de l''État Civil de la Commune d''Ain Beida, ');
          Selection.TypeText('certifie que ' + CitizenName);
          if BirthDate <> '' then
            Selection.TypeText(', né(e) le ' + BirthDate);
          Selection.TypeText('.');
          Selection.TypeParagraph;
          Selection.TypeParagraph;
          
          // Date et signature
          Selection.Font.Name := DefaultFont;
          Selection.Font.Size := DefaultFontSize;
          Selection.TypeText('Fait à Ain Beida, le ' + FormatDateTime('dd/mm/yyyy', Date));
          Selection.TypeParagraph;
          Selection.TypeParagraph;
          
          // Signature
          Selection.Font.Name := DefaultFont;
          Selection.Font.Bold := 1;
          Selection.ParagraphFormat.Alignment := 2; // Droite
          Selection.TypeText('L''Officier de l''État Civil');
          Selection.TypeParagraph;
          Selection.Font.Italic := 1;
          Selection.TypeText('(Signature et cachet)');
          
          // Sauvegarde en PDF
          Application.ProcessMessages;
          Doc.SaveAs2(FilePath, 17); // wdFormatPDF = 17
          
          // Enregistrement dans la base de données
          qry.Close;
          qry.SQL.Text := 
            'INSERT INTO admin_documents (citizen_id, doc_type, request_date, status, file_path) ' +
            'VALUES (:citizen_id, :doc_type, :request_date, :status, :file_path)';
          qry.ParamByName('citizen_id').AsInteger := CitizenId;
          qry.ParamByName('doc_type').AsString := DocType;
          qry.ParamByName('request_date').AsDate := dtRequestDate.Date;
          qry.ParamByName('status').AsString := 'Généré';
          qry.ParamByName('file_path').AsString := FilePath;
          qry.ExecSQL;
          
          LoadDocuments;
          ShowMessage('Le document a été généré avec succès.');
          
          // Ouverture automatique du PDF
          Sleep(500);
          OpenPDF(FilePath);
          
        finally
          // Nettoyage des objets COM
          if not VarIsEmpty(Shape) and not VarIsNull(Shape) then
            Shape := Unassigned;
            
          if not VarIsEmpty(Doc) and not VarIsNull(Doc) then
          begin
            Doc.Close(False);
            Doc := Unassigned;
          end;
          
          if not VarIsEmpty(Word) and not VarIsNull(Word) then
          begin
            Word.Quit;
            Word := Unassigned;
          end;
        end;
        
      except
        on E: Exception do
        begin
          ShowMessage('Erreur lors de la génération du PDF: ' + E.Message + #13#10 +
                     'Assurez-vous que Microsoft Word est installé et fonctionne correctement.');
          Exit;
        end;
      end;
    end
    else
      ShowMessage('Citoyen non trouvé dans la base de données.');
      
  finally
    Screen.Cursor := crDefault;
    qry.Free;
  end;
end;

procedure TAdminDocsForm.edtCitizenIdChange(Sender: TObject);
var
  CitizenId: Integer;
begin
  if TryStrToInt(edtCitizenId.Text, CitizenId) then
    LoadCitizenInfo(CitizenId)
  else
    grpCitizenInfo.Visible := False;
end;

procedure TAdminDocsForm.btnArchiveClick(Sender: TObject);
begin
  if not qryDocuments.IsEmpty then
  begin
    if MessageDlg('Voulez-vous archiver ce document?', 
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      qryDocuments.Edit;
      qryDocuments.FieldByName('status').AsString := 'Archivé';
      qryDocuments.Post;
      ShowMessage('Document archivé avec succès.');
    end;
  end
  else
    ShowMessage('Veuillez sélectionner un document à archiver.');
end;

procedure TAdminDocsForm.LoadCitizenInfo(CitizenId: Integer);
var
  qry: TFDQuery;
  birthDateStr: string;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConnection;
    qry.SQL.Text := 'SELECT name, birth_date FROM citizens WHERE id = :id';
    qry.ParamByName('id').AsInteger := CitizenId;
    qry.Open;
    
    if not qry.IsEmpty then
    begin
      lblCitizenName.Caption := 'Nom: ' + qry.FieldByName('name').AsString;
      
      // Traitement de la date de naissance
      birthDateStr := qry.FieldByName('birth_date').AsString;
      if birthDateStr <> '' then
        lblCitizenBirthDate.Caption := 'Date de Naissance: ' + birthDateStr
      else
        lblCitizenBirthDate.Caption := 'Date de Naissance: Non spécifiée';
        
      grpCitizenInfo.Visible := True;
    end
    else
    begin
      lblCitizenName.Caption := 'Citoyen non trouvé';
      lblCitizenBirthDate.Caption := '';
      grpCitizenInfo.Visible := True;
    end;
  finally
    qry.Free;
  end;
end;

end.
