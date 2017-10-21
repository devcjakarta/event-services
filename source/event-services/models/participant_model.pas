unit participant_model;

{$mode objfpc}{$H+}

interface

uses
  common,
  Classes, SysUtils, database_lib;

type

  { TParticipantModel }

  TParticipantModel = class(TSimpleModel)
  private
    FCountryCode: string;
    FParticipantID: integer;
    function verifyPhoneNumber(APhone: string): string;
  public
    constructor Create(const DefaultTableName: string = '');
    function Add(AEmail, AName, APhone, AInstitution, AOccupation: string): boolean;
  published
    property ParticipantID: integer read FParticipantID;
    property CountryCode: string read FCountryCode write FCountryCode;
  end;

implementation

function TParticipantModel.verifyPhoneNumber(APhone: string): string;
begin
  //TODO: verify phone number
  Result := APhone;
  if Pos('0', APhone) = 1 then
  begin
    Result := FCountryCode + Copy(APhone, 2);
  end;
  Result := ReplaceAll(APhone, ['-', ' ', '.', '(', ')'], '');
end;

constructor TParticipantModel.Create(const DefaultTableName: string = '');
begin
  inherited Create(DefaultTableName); // table name = participants
  FCountryCode := '62';
end;

function TParticipantModel.Add(AEmail, AName, APhone, AInstitution,
  AOccupation: string): boolean;
var
  i: integer;
  sql: string;
begin
  Result := False;
  if not isEmail(AEmail) then
    Exit;

  FParticipantID := 0;
  sql := 'INSERT INTO participants (post_date,email,name,phone,institution,occupation,status_id)';
  sql := sql +
    ' VALUES (now(),''{{email}}'',''{{name}}'',''{{phone}}'',''{{institution}}'',''{{occupation}}'',2)';
  sql := sql +
    ' ON DUPLICATE KEY UPDATE name=''{{name}}'', phone=''{{phone}}'', institution=''{{institution}}'', occupation=''{{occupation}}'', reg_counter=reg_counter+1';
  sql := StringReplace(sql, '{{email}}', AEmail, [rfReplaceAll]);
  sql := StringReplace(sql, '{{name}}', UpperCase(AName), [rfReplaceAll]);
  sql := StringReplace(sql, '{{institution}}', UpperCase(AInstitution), [rfReplaceAll]);
  sql := StringReplace(sql, '{{occupation}}', UpperCase(AOccupation), [rfReplaceAll]);
  sql := StringReplace(sql, '{{phone}}', verifyPhoneNumber(APhone), [rfReplaceAll]);

  if Exec(sql) then
  begin
    if FindFirst('email=''' + AEmail + '''') then
    begin
      FParticipantID := Data['pid'];
      Result := True;
    end;

  end;

end;

end.

