unit event_controller;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, event_model, participant_model, participantblacklist_model,
  fpcgi, fpjson, HTTPDefs, fastplaz_handler, database_lib;

const
  LBL_FAILED = 'FAILED';
  LBL_OK = 'OK';
  LBL_INVALID_COMMAND = 'INVALID COMMAND';
  LBL_CANNOT_REGISTER = 'CANNOT REGISTER';
  LBL_BLACKLISTED = 'BLACKLISTED';
  LBL_SUSPENDED = 'SUSPENDED';
  LBL_EVENT_NOT_FOUND = 'EVENT NOT FOUND';

type

  { TEventModule }

  TEventModule = class(TMyCustomWebModule)
  private
    FEventID: integer;
    function getOpenEvent: string;
    function registration: string;
    function setResult(ACode: integer; AMessage, AStatus: string): string;
    function IsBlackListed(AEmail: string): boolean;
  public
    Event: TEventModel;
    constructor CreateNew(AOwner: TComponent; CreateMode: integer); override;
    destructor Destroy; override;

    procedure Get; override;
    procedure Post; override;
  end;

implementation

uses common, json_lib;

function TEventModule.getOpenEvent: string;
var
  json: TJSONUtil;
begin
  json := TJSONUtil.Create;
  Event := TEventModel.Create();

  DataBaseInit();
  Event.FindFirst(['status_id=0']);
  if Event.RecordCount = 0 then
  begin
    json['code'] := Int16(1);
    json['msg'] := 'NODATA';
    Result := json.AsJSON;
    Event.Free;
    json.Free;
    Exit;
  end;

  json['code'] := Int16(0);
  json['data/event/id'] := i2s(Event['eid']);
  json['data/event/title'] := Event['name'];
  json['data/event/subtitle'] := Event['sub_title'];
  json['data/event/date_start'] := FormatDateTime('dd mmmm yyyy', Event['date_start']);
  json['data/event/time_start'] := FormatDateTime('HH:nn', Event['date_start']);
  json['data/event/date_finish'] := FormatDateTime('dd  yyyy', Event['date_finish']);
  json['data/event/time_finish'] := FormatDateTime('HH:nn', Event['date_finish']);
  json['data/event/description'] := Event['description'];
  json['data/event/location'] := Event['location'];
  json['data/event/location_map'] := Event['location_map'];
  json['data/event/url'] := Event['url'];
  json['data/event/image_url'] := Event['image_url'];
  json['data/event/quota'] := Event['quota'];
  json['status'] := 'OK';

  Result := json.AsJSON;
  json.Free;
end;

function TEventModule.registration: string;
begin
  Result := setResult(1, LBL_CANNOT_REGISTER, LBL_FAILED);

  if ((_POST['email'] = '') or (_POST['name'] = '') or (_POST['phone'] = '')) then
  begin
    Exit;
  end;

  if not DataBaseInit() then
    Exit;

  Event := TEventModel.Create();
  Event.FindFirst(['status_id=0']);
  if Event.RecordCount = 0 then
  begin
    Result := setResult(1, LBL_EVENT_NOT_FOUND, LBL_FAILED);
    Event.Free;
    Exit;
  end;
  FEventID := Event['eid'];

  if IsBlackListed(_POST['email']) then
  begin
    Result := setResult(1, LBL_SUSPENDED, LBL_FAILED);
    Event.Free;
    Exit;
  end;

  with TParticipantModel.Create() do
  begin
    if Add(_POST['email'], _POST['name'], _POST['phone'], _POST['institution'], _POST['occupation']) then
    begin

      // add participant to event
      if Event.AddParticipant(FEventID, ParticipantID) <> 0 then
      begin
        with TJSONUtil.Create do
        begin
          Value['post_date'] := FormatDateTime('yyyy-mm-dd HH:nn:ss', now);
          Value['code'] := 0;
          Value['data/id'] := ParticipantID;
          Value['status'] := 'OK';
          Result := AsJSON;
          Free;
        end;

      end
      else
        Result := setResult(1, Event.Message, LBL_FAILED);

    end;

    Free;
  end;

  Event.Free;
end;

function TEventModule.setResult(ACode: integer; AMessage, AStatus: string): string;
begin
  Result := '{"code": ' + i2s(ACode) + ', "msg": "' + AMessage +
    '", "status": "' + AStatus + '"}';
end;

function TEventModule.IsBlackListed(AEmail: string): boolean;
begin
  Result := False;
  with TParticipantblacklistModel.Create() do
  begin
    Result := FindFirst(['email=''' + AEmail + '''', 'status_id=0']);
    Free;
  end;
end;

constructor TEventModule.CreateNew(AOwner: TComponent; CreateMode: integer);
begin
  inherited CreateNew(AOwner, CreateMode);
end;

destructor TEventModule.Destroy;
begin
  inherited Destroy;
end;

// GET Method Handler
procedure TEventModule.Get;
var
  sCmd: string;
begin
  //TODO: Securing Access

  sCmd := ExcludeTrailingBackslash(_GET['$1']);
  Response.ContentType := 'application/json';
  case sCmd of
    'open':
    begin
      Response.Content := getOpenEvent;
    end;
    else
    begin
      Response.Content := setResult(1, LBL_INVALID_COMMAND, LBL_FAILED);
    end;
  end;

end;

// POST Method Handler
procedure TEventModule.Post;
var
  sCmd: string;
begin
  //TODO: Securing Access

  sCmd := ExcludeTrailingBackslash(_GET['$1']);
  //Response.ContentType := 'application/json'; //TODO: uncomment
  case sCmd of
    'registration':
    begin
      Response.Content := registration;

    end;
    else
    begin
      Response.Content := setResult(1, LBL_INVALID_COMMAND, LBL_FAILED);
    end;
  end;
end;




initialization
  // -> http://yourdomainname/event
  // The following line should be moved to a file "routes.pas"
  //Route.Add('event', TEventModule);
  Route.Add('event', '^event/(.*)', TEventModule);   // $1

end.
