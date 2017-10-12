unit submission_controller;

{$mode objfpc}{$H+}

interface

uses
  submission_model,
  Classes, SysUtils, fpcgi, fpjson, HTTPDefs, fastplaz_handler, database_lib;

type
  TUserModule = class(TMyCustomWebModule)
  private
    //FName, FEmail, FPhone, FTitle, FURL, FDescription, FFile, FTech: string;
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
  FIELD_DESCRIPTION = 'description';
  FIELD_TECH = 'tech';
  FIELD_URL = 'url';
  FIELD_FILENAME = 'filename';
  FIELD_STATUS_ID = 'status_id';

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
  authstring: string;
  json: TJSONUtil;
begin
  authstring := Header['Authorization'];
  //TODO: secure post

  json := TJSONUtil.Create;

  if Application.Request.Content = '' then
  begin
    json[FIELD_NAME] := _POST[FIELD_NAME];
    json[FIELD_EMAIL] := _POST[FIELD_EMAIL];
    json[FIELD_PHONE] := _POST[FIELD_PHONE];
    json[FIELD_TITLE] := _POST[FIELD_TITLE];
    json[FIELD_DESCRIPTION] := _POST[FIELD_DESCRIPTION];
    json[FIELD_URL] := _POST[FIELD_URL];
    json[FIELD_TECH] := _POST[FIELD_TECH];

    if (isEmpty(_POST[FIELD_NAME]) or isEmpty(_POST[FIELD_EMAIL]) or
      isEmpty(json[FIELD_PHONE])) then
    begin
      json['code'] := Int16(1);
      Response.Content := json.AsJSON;
      json.Free;
      Exit;
    end;

    // may be

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
  Submission[FIELD_TECH] := json[FIELD_TECH];
  Submission[FIELD_URL] := json[FIELD_URL];
  Submission[FIELD_FILENAME] := '';  //TODO: prepare if file is required
  Submission[FIELD_STATUS_ID] := SUBMISSION_STATUS_NEW;
  Submission.Save();
  Submission.Free;

  //TODO: Send Email Notification

  json['code'] := Int16(0);
  json['status'] := 'OK';

  //Result
  CustomHeader['fb'] := 'hackaton';
  Response.Content := json.AsJSON;
  json.Free;
end;




initialization
  // -> http://yourdomainname/user
  // The following line should be moved to a file "routes.pas"
  Route.Add('user', TUserModule);

end.
