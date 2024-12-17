unit ReportsUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids,
  Vcl.DBGrids, Vcl.Buttons, System.DateUtils, ShellAPI;

type
  TReportsForm = class(TForm)
    FDConnection: TFDConnection;
    qryStats: TFDQuery;
    pnlTop: TPanel;
    lblTitle: TLabel;
    pcReports: TPageControl;
    tsRequests: TTabSheet;
    tsComplaints: TTabSheet;
    pnlRequestStats: TPanel;
    lblTotalRequests: TLabel;
    lblPendingRequests: TLabel;
    lblApprovedRequests: TLabel;
    lblRejectedRequests: TLabel;
    pnlComplaintStats: TPanel;
    lblTotalComplaints: TLabel;
    lblPendingComplaints: TLabel;
    lblProcessedComplaints: TLabel;
    lblClosedComplaints: TLabel;
    btnExportRequests: TButton;
    btnExportComplaints: TButton;
    btnRefresh: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnExportRequestsClick(Sender: TObject);
    procedure btnExportComplaintsClick(Sender: TObject);
  private
    procedure ConnectToDatabase;
    procedure LoadRequestStats;
    procedure LoadComplaintStats;
    procedure ExportToCSV(const Query: string; const FileName: string);
  public
    { Public declarations }
  end;

var
  ReportsForm: TReportsForm;

implementation

{$R *.dfm}

procedure TReportsForm.FormCreate(Sender: TObject);
begin
  ConnectToDatabase;
  LoadRequestStats;
  LoadComplaintStats;
end;

procedure TReportsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FDConnection.Connected then
    FDConnection.Close;
end;

procedure TReportsForm.ConnectToDatabase;
begin
  try
    FDConnection.Params.Database := 'citizens.db';
    FDConnection.Params.DriverID := 'SQLite';
    FDConnection.LoginPrompt := False;
    FDConnection.Connected := True;
  except
    on E: Exception do
      ShowMessage('Erreur de connexion à la base de données: ' + E.Message);
  end;
end;

procedure TReportsForm.LoadRequestStats;
var
  Total, Pending, Approved, Rejected: Integer;
begin
  try
    with qryStats do
    begin
      // Total des demandes
      SQL.Text := 'SELECT COUNT(*) FROM requests';
      Open;
      Total := Fields[0].AsInteger;
      Close;

      // Demandes en attente
      SQL.Text := 'SELECT COUNT(*) FROM requests WHERE status = ''En attente''';
      Open;
      Pending := Fields[0].AsInteger;
      Close;

      // Demandes approuvées
      SQL.Text := 'SELECT COUNT(*) FROM requests WHERE status = ''Approuvé''';
      Open;
      Approved := Fields[0].AsInteger;
      Close;

      // Demandes rejetées
      SQL.Text := 'SELECT COUNT(*) FROM requests WHERE status = ''Rejeté''';
      Open;
      Rejected := Fields[0].AsInteger;
      Close;
    end;

    lblTotalRequests.Caption := 'Total des demandes: ' + IntToStr(Total);
    lblPendingRequests.Caption := 'Demandes en attente: ' + IntToStr(Pending);
    lblApprovedRequests.Caption := 'Demandes approuvées: ' + IntToStr(Approved);
    lblRejectedRequests.Caption := 'Demandes rejetées: ' + IntToStr(Rejected);
  except
    on E: Exception do
      ShowMessage('Erreur lors du chargement des statistiques des demandes: ' + E.Message);
  end;
end;

procedure TReportsForm.LoadComplaintStats;
var
  Total, Pending, Processed, Closed: Integer;
begin
  try
    with qryStats do
    begin
      // Total des plaintes
      SQL.Text := 'SELECT COUNT(*) FROM complaints';
      Open;
      Total := Fields[0].AsInteger;
      Close;

      // Plaintes en attente
      SQL.Text := 'SELECT COUNT(*) FROM complaints WHERE status = ''En attente''';
      Open;
      Pending := Fields[0].AsInteger;
      Close;

      // Plaintes en cours de traitement
      SQL.Text := 'SELECT COUNT(*) FROM complaints WHERE status = ''En traitement''';
      Open;
      Processed := Fields[0].AsInteger;
      Close;

      // Plaintes clôturées
      SQL.Text := 'SELECT COUNT(*) FROM complaints WHERE status = ''Clôturé''';
      Open;
      Closed := Fields[0].AsInteger;
      Close;
    end;

    lblTotalComplaints.Caption := 'Total des plaintes: ' + IntToStr(Total);
    lblPendingComplaints.Caption := 'Plaintes en attente: ' + IntToStr(Pending);
    lblProcessedComplaints.Caption := 'Plaintes en traitement: ' + IntToStr(Processed);
    lblClosedComplaints.Caption := 'Plaintes clôturées: ' + IntToStr(Closed);
  except
    on E: Exception do
      ShowMessage('Erreur lors du chargement des statistiques des plaintes: ' + E.Message);
  end;
end;

procedure TReportsForm.btnRefreshClick(Sender: TObject);
begin
  LoadRequestStats;
  LoadComplaintStats;
end;

procedure TReportsForm.ExportToCSV(const Query: string; const FileName: string);
var
  ExportQuery: TFDQuery;
  CSVFile: TextFile;
  i: Integer;
  Line: string;
  FullPath: string;
begin
  FullPath := ExtractFilePath(Application.ExeName) + FileName;
  ExportQuery := TFDQuery.Create(nil);
  try
    ExportQuery.Connection := FDConnection;
    ExportQuery.SQL.Text := Query;
    ExportQuery.Open;

    AssignFile(CSVFile, FullPath);
    Rewrite(CSVFile);

    // En-têtes
    Line := '';
    for i := 0 to ExportQuery.FieldCount - 1 do
    begin
      if i > 0 then Line := Line + ';';
      Line := Line + ExportQuery.Fields[i].FieldName;
    end;
    WriteLn(CSVFile, Line);

    // Données
    while not ExportQuery.Eof do
    begin
      Line := '';
      for i := 0 to ExportQuery.FieldCount - 1 do
      begin
        if i > 0 then Line := Line + ';';
        Line := Line + ExportQuery.Fields[i].AsString;
      end;
      WriteLn(CSVFile, Line);
      ExportQuery.Next;
    end;

    CloseFile(CSVFile);
    ShowMessage('Export terminé avec succès: ' + FullPath);
    
    // Ouvrir le fichier avec l'application par défaut
    ShellExecute(0, 'open', PChar(FullPath), nil, nil, SW_SHOWNORMAL);
  finally
    ExportQuery.Free;
  end;
end;

procedure TReportsForm.btnExportRequestsClick(Sender: TObject);
begin
  ExportToCSV(
    'SELECT citizen_id, request_type, request_date, status, urgent ' +
    'FROM requests ORDER BY request_date DESC',
    'rapports_demandes_' + FormatDateTime('yyyy-mm-dd', Now) + '.csv'
  );
end;

procedure TReportsForm.btnExportComplaintsClick(Sender: TObject);
begin
  ExportToCSV(
    'SELECT citizen_id, complaint_type, complaint_date, status, description ' +
    'FROM complaints ORDER BY complaint_date DESC',
    'rapports_plaintes_' + FormatDateTime('yyyy-mm-dd', Now) + '.csv'
  );
end;

end.
