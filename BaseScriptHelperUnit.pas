unit BaseScriptHelperUnit;

interface

uses 
  BaseScriptUnit;

type
  TBaseScriptHelperUnit = class(TBaseScriptUnit)
   constructor Create;
  end;

implementation

constructor TBaseScriptHelperUnit.Create;
begin
  AddToSystemJournal(Version);
end;

end.