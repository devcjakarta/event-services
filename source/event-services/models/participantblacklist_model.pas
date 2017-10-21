unit participantblacklist_model;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, database_lib;

type
  TParticipantBlacklistModel = class(TSimpleModel)
  private
  public
    constructor Create(const DefaultTableName: string = '');
  end;

implementation

constructor TParticipantBlacklistModel.Create(const DefaultTableName: string = '');
begin
  inherited Create(DefaultTableName); // table name = participantblacklists
  //inherited Create('yourtablename'); // if use custom tablename
end;

end.


