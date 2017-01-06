Unit MoverHelper;

interface


type 
 TMoverHelper = class
 private
  function ValidateMovement(X, Y : Word) : Boolean;
 public
  function MoveToSpot(X, Y : Word) : Boolean;
  function MoveToSpotThroughDoor(X, Y, DoorX, DoorY : Word) : Boolean;
 end;

implementation

function TMoverHelper.MoveToSpot(X, Y: Word): Boolean;
begin
  Result := False;
  
  if not ValidateMovement(X, Y) then
    AddToSystemJournal('Some problem with point: X=' + X.ToString + ', Y=' + Y.ToString)
  else
   begin
    newMoveXY(X, Y, true, 1, true);
    Result := True;
   end;
end;

function TMoverHelper.ValidateMovement(X, Y: Word): Boolean;
begin
  Result := True;
end;

function TMoverHelper.MoveToSpotThroughDoor(X, Y, DoorX, DoorY: Word): Boolean;
begin
  ClearBadLocationList;
  ClearBadObjectList;
  newMoveXY(DoorX, DoorY, true, 1, true);
  Wait(500);
  newMoveXY(X, Y, true, 1, true);
  Result := True;
end;

end.