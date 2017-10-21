unit eventparticipant_model;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, database_lib;

const
  LBL_PARTICIPANT_EXISTS = 'PARTICIPANT EXISTS';

type
  TEventParticipantModel = class(TSimpleModel)
  private
  public
    constructor Create(const DefaultTableName: string = '');
  end;

implementation

constructor TEventParticipantModel.Create(const DefaultTableName: string = '');
begin
  inherited Create(DefaultTableName); // table name = eventparticipants
  //inherited Create('yourtablename'); // if use custom tablename
end;

end.

