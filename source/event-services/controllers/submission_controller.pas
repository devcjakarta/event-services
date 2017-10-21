unit submission_controller;

{$mode objfpc}{$H+}

interface

uses
  submission_model, logutil_lib, http_lib,
  Classes, SysUtils, fpcgi, fpjson, HTTPDefs, fastplaz_handler, database_lib;

type

  { TUserModule }

  TUserModule = class(TMyCustomWebModule)
  private
    function SendEmailNotification(AName, AEmail, APhone, ASubject,
      ABody: string): boolean;
  public
    Submission: TSubmissionModel;
    constructor CreateNew(AOwner: TComponent; CreateMode: integer); override;
    destructor Destroy; override;

    procedure Get; override;
    procedure Post; override;
  end;

implementation

uses common, json_lib;

const
  FIELD_DATE_POST = 'date_post';
  FIELD_NAME = 'name';
  FIELD_EMAIL = 'email';
  FIELD_PHONE = 'phone';
  FIELD_TITLE = 'title';
  FIELD_SUBJECT = 'subject';
  FIELD_BODY = 'body';
  FIELD_DESCRIPTION = 'description';
  FIELD_ORIGIN = 'origin';
  FIELD_TECH = 'tech';
  FIELD_URL = 'url';
  FIELD_FILENAME = 'filename';
  FIELD_STATUS_ID = 'status_id';

  STORAGE_PATH = 'files/hackaton/';
  CONFIG_REFERER = 'systems/referer';
  CONFIG_EMAIL_SERVICE = 'systems/email_service';

  SUBMISSION_STATUS_NEW = 9;
  SUBMISSION_STATUS_REVIEWED = 8;
  SUBMISSION_STATUS_FINALIS = 8;
  SUBMISSION_STATUS_DELETE = 1;

constructor TUserModule.CreateNew(AOwner: TComponent; CreateMode: integer);
begin
  inherited CreateNew(AOwner, CreateMode);
end;

destructor TUserModule.Destroy;
begin
  inherited Destroy;
end;

// GET Method Handler
procedure TUserModule.Get;
begin
  Response.ContentType := 'application/json';
  Response.Content := '{}';
end;

// POST Method Handler
procedure TUserModule.Post;
var
  i: integer;
  s, fileName, authString: string;
  json: TJSONUtil;
begin
  authString := Header['Authorization'];
  //TODO: secure post

  s := Config[CONFIG_REFERER];
  if s <> '' then
  begin
    if s <> Request.Referer then
    begin
      Response.ContentType := 'application/json';
      Response.Content := '{}';
      Exit;
    end;
  end;

  json := TJSONUtil.Create;

  if not IsJsonValid(Application.Request.Content) then
  begin
    if ((isEmpty(_POST[FIELD_NAME])) or (isEmpty(_POST[FIELD_PHONE])) or
      (isEmpty(_POST[FIELD_EMAIL]))) then
    begin
      json['code'] := Int16(1);
      Response.Content := json.AsJSON;
      json.Free;
      Exit;
    end;

    json[FIELD_NAME] := _POST[FIELD_NAME];
    json[FIELD_EMAIL] := _POST[FIELD_EMAIL];
    json[FIELD_PHONE] := _POST[FIELD_PHONE];
    json[FIELD_TITLE] := _POST[FIELD_TITLE];
    json[FIELD_DESCRIPTION] := _POST[FIELD_DESCRIPTION];
    json[FIELD_URL] := _POST[FIELD_URL];
    //json[FIELD_TECH] := _POST[FIELD_TECH];
    json[FIELD_ORIGIN] := _POST[FIELD_ORIGIN];
  end
  else
    json.LoadFromJsonString(Application.Request.Content);

  //TODO: validation

  //Save To Database
  DataBaseInit();
  Submission := TSubmissionModel.Create();
  Submission[FIELD_DATE_POST] := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
  Submission[FIELD_NAME] := json[FIELD_NAME];
  Submission[FIELD_EMAIL] := json[FIELD_EMAIL];
  Submission[FIELD_PHONE] := json[FIELD_PHONE];
  Submission[FIELD_TITLE] := json[FIELD_TITLE];
  Submission[FIELD_DESCRIPTION] := json[FIELD_DESCRIPTION];
  Submission[FIELD_ORIGIN] := json[FIELD_ORIGIN];
  //Submission[FIELD_TECH] := json[FIELD_TECH];
  Submission[FIELD_URL] := json[FIELD_URL];
  if Application.Request.Files.Count > 0 then
    Submission[FIELD_FILENAME] := Application.Request.Files[0].FileName
  else
    Submission[FIELD_FILENAME] := '';
  Submission[FIELD_STATUS_ID] := SUBMISSION_STATUS_NEW;
  Submission.Save();

  //Save File
  if Application.Request.Files.Count > 0 then
  begin
    try
      for i := 0 to Application.Request.Files.Count - 1 do
      begin
        fileName := i2s(Submission.LastInsertID) + '-' + LowerCase(
          json[FIELD_EMAIL]) + '-' + LowerCase(json[FIELD_TITLE]) +
          '-' + Application.Request.Files[i].FileName;
        FileCopy(Application.Request.Files[i].LocalFileName, STORAGE_PATH + fileName);
        DeleteFile(Application.Request.Files[i].LocalFileName);
      end;
      json['files'] := 'y';
    except
    end;
  end;
  Submission.Free;

  //Send Email Notification
  SendEmailNotification(json[FIELD_NAME], json[FIELD_EMAIL],
    json[FIELD_PHONE], json[FIELD_TITLE], '');

  json['code'] := Int16(0);
  json['status'] := 'OK';

  //Result
  CustomHeader['fb'] := 'hackaton';
  Response.Content := json.AsJSON;
  json.Free;
end;

function TUserModule.SendEmailNotification(AName, AEmail, APhone,
  ASubject, ABody: string): boolean;
var
  urlTarget: string;
  responseHttp: IHTTPResponse;
begin
  Result := False;
  urlTarget := Config[CONFIG_EMAIL_SERVICE];
  if urlTarget = '' then
    Exit;
  with THTTPLib.Create(urlTarget) do
  begin
    FormData[FIELD_NAME] := AName;
    FormData[FIELD_EMAIL] := AEmail;
    FormData[FIELD_PHONE] := APhone;
    FormData[FIELD_TITLE] := ASubject;   // TODO: remove
    FormData[FIELD_SUBJECT] := ASubject;
    FormData[FIELD_BODY] := ABody;
    FormData['type'] := 'notification';

    responseHttp := Post;
    if responseHttp.ResultCode <> 200 then
    begin
      LogUtil.Add('ERR: ' + responseHttp.ResultText, 'MAIL');
    end
    else
      Result := True;
    Free;
  end;
end;




initialization
  // -> http://yourdomainname/user
  // The following line should be moved to a file "routes.pas"
  Route.Add('submission', TUserModule);

end.
