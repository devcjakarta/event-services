unit submission_model;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, database_lib;

type
  TSubmissionModel = class(TSimpleModel)
  private
  public
    constructor Create(const DefaultTableName: string = '');
  end;

implementation

constructor TSubmissionModel.Create(const DefaultTableName: string = '');
begin
  inherited Create( DefaultTableName); // table name = users
end;

end.

