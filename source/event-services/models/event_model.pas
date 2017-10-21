unit event_model;

{$mode objfpc}{$H+}

interface

uses
  common,fastplaz_handler, logutil_lib,
  Classes, SysUtils, eventparticipant_model, database_lib;

type

  { TEventModel }

  TEventModel = class(TSimpleModel)
  private
    FMessage: string;
  public
    constructor Create(const DefaultTableName: string = '');
    function AddParticipant(AEventID: integer; AParticipantID: integer): integer;
  published
    property Message: string read FMessage write FMessage;
  end;

implementation

{ TEventParticipantModel }

constructor TEventModel.Create(const DefaultTableName: string = '');
begin
  inherited Create(DefaultTableName); // table name = events
  //inherited Create('yourtablename'); // if use custom tablename
  FMessage := '';
end;

function TEventModel.AddParticipant(AEventID: integer; AParticipantID: integer
  ): integer;
var
  eventParticipant: TEventParticipantModel;
begin
  Result := 0;
  FMessage := '';

  eventParticipant := TEventParticipantModel.Create();
  if eventParticipant.FindFirst(
    ['event_id=' + i2s(AEventID), 'participant_id=' + i2s(AParticipantID)]) then
  begin
    Result := eventParticipant['epid'];
    FMessage := LBL_PARTICIPANT_EXISTS;
    eventParticipant.Free;
    Exit;
  end;
  eventParticipant.Clear;
  eventParticipant['event_id'] := AEventID;
  eventParticipant['participant_id'] := AParticipantID;
  eventParticipant['status_id'] := 2;
  try
    if eventParticipant.Save() then
    begin
      Result := eventParticipant.LastInsertID;
    end;

  except
    on E: Exception do
    begin
      FMessage := E.Message;
      if AppData.debug then
        LogUtil.Add( E.Message, 'EVENTDB');
    end;
  end;

  eventParticipant.Free;
end;

end.
