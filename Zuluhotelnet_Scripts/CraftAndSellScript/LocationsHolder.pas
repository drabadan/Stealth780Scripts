unit LocationsHolder;

interface

type 
 TLocation = record
  X, Y : Word;
  Title : String;
 end;

type TLocationsArray = Array of TLocation;

type
  TLocationsHolder = class
   private
    AllLocations : TLocationsArray;
   public
    function GetLocation(Key : String) : TLocation; //search for location in AllLocations
    function HasLocation(Key : String) : Boolean; //search for location in AllLocations
    function AddLocation(Title : String; X, Y : Word) : Integer; overload;//returns current length of AllLocations
    function AddLocation(Title : String; LocationPoint : TPoint) : Integer; overload;//returns current length of AllLocations

    function MoveToLocation(Key : String; Precision : Integer = 1) : Boolean;  
  end;

implementation

function TLocationsHolder.GetLocation(Key: String): TLocation;
var 
  i : Integer;
begin
  for i := 0 to High(AllLocations) do
    if (AllLocations[i].Title = Key) then
      begin
        Result := AllLocations[i];
        Exit;
      end;
  
  AddToSystemJournal('Location with title: ' + Key + ' not found!');
end;

function TLocationsHolder.HasLocation(Key: String): Boolean;
var 
  i : Integer;
begin
  Result := False;
  for i := 0 to High(AllLocations) do
    if (AllLocations[i].Title = Key) then
      begin
        Result := True;
        Exit;
      end;
end;


function TLocationsHolder.AddLocation(Title: String; X, Y: Word): Integer;
var
  tmpLoc : TLocation;
begin
  if HasLocation(Title) then
    begin
      Result := -1;
      Exit;
    end;
  
  tmpLoc.Title := Title;
  tmpLoc.X := X;
  tmpLoc.Y := Y;

  SetLength(AllLocations, Length(AllLocations) + 1);
  AllLocations[High(AllLocations)] := tmpLoc;
  Result := High(AllLocations);
end;

function TLocationsHolder.AddLocation(Title: String; LocationPoint: TPoint): Integer;
begin
  Result := AddLocation(Title, LocationPoint.X, LocationPoint.Y);  
end;


function TLocationsHolder.MoveToLocation(Key: String; Precision: Integer = 1): Boolean;
begin
  //AddToSystemJournal('Precision is: ' + Precision.ToString);
  ClearBadLocationList;
  Result := newMoveXY(GetLocation(Key).X,  GetLocation(Key).Y, true, Precision, true);
end;

end.