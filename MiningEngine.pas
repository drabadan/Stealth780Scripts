Unit MiningEngine;

interface

type
 TSpot = class
  Tile : Word;
  X, Y : Word;
  LastDig : TDateTime;

  function ToString : String; overload;
  function ValidateSpot : Boolean;
  constructor Create(Tile, X,Y : Word);
 end;

type TSpotArray = Array of TSpot;

type 
 TMoverHelper = class
 private
  function ValidateMovement(X, Y : Integer) : Boolean;
 public
  function MoveToSpot(X, Y : Integer) : Boolean;
 end;

type
 TMiningEngine = class
 private
   Spots : TSpotArray;
   MoverHelper : TMoverHelper;
 public
   function SetMiningArea(X1, Y1, X2, Y2 : Word) : Integer;
   function StartWorker : Integer;
   procedure SpotActions(Spot : TSpot);

   constructor Create;
 end;

implementation

function TSpot.ToString: String;
begin
  Result := 'Spot info: X = ' + Self.X.ToString() + ', Y = ' + Self.Y.ToString() + ', LastDig = ' + Self.LastDig.ToString();
end;

constructor TSpot.Create(Tile, X, Y: Word);
begin
 Self.Tile := Tile;
 Self.X := X;
 Self.Y := Y; 
end;

function TSpot.ValidateSpot: Boolean;
var 
 PathArray : TPathArray;
 len : Integer;
begin
  Result := True;

  //validate by if the spot is reachable
  if((Self.X > 0) and (Self.Y > 0)) then
    begin
      len := GetPathArray(Self.X, Self.Y, true, 1, PathArray);
      if(len <= 0) then
        Result := False;
    end;
end;

constructor TMiningEngine.Create;
begin
  MoverHelper := TMoverHelper.Create;
end;

function TMiningEngine.SetMiningArea(X1, Y1, X2, Y2 : Word): Integer;
var
 MountainTiles : Array of Word;
 LandTilesArray : TFoundTilesArray;
 foundLength, i : Integer;
 tmpSpot : TSpot;
begin
  MountainTiles := [1339,1340,1341,1342,1343,1344,1345,1346,1347,1348,1349,1350,1351,1352,1353,1354,1355,1356,1357,1358,1359];
  foundLength := GetStaticTilesArrayEx(X1, Y1, X2, Y2, WorldNum, MountainTiles, LandTilesArray);

  if(foundLength = 0)then
    begin
      Result := 0;
      Exit;
    end;

    //AddToSystemJournal(foundLength.ToString());
   for i := 0 to High(LandTilesArray) do
    begin
     tmpSpot := TSpot.Create(LandTilesArray[i].Tile, LandTilesArray[i].X, LandTilesArray[i].Y);
     if(tmpSpot.ValidateSpot) then
       begin
         SetLength(Spots, Length(Spots) + 1);
         Spots[High(Spots)] := tmpSpot;
       end;
    end;
   Result := foundLength;
end;

function TMiningEngine.StartWorker: Integer;
var
 i : Integer;
begin
 AddToSystemJournal('Script starting.');
 if (Length(Spots) = 0) then
  SetMiningArea(2559, 433, 2603, 440);

 for i := Low(Spots) to High(Spots) do
   if((Spots[i].X > 0) and (Spots[i].Y > 0)) then
    begin
     SpotActions(Spots[i]);
    end; 

  AddToSystemJournal('Script stopped.');
end;

procedure TMiningEngine.SpotActions(Spot: TSpot);
begin
  if not MoverHelper.MoveToSpot(Spot.X, Spot.Y) then 
    Exit;
end;


function TMoverHelper.MoveToSpot(X, Y: Integer): Boolean;
begin
  Result := False;

  if not ValidateMovement(X, Y) then
    Exit;
end;

function TMoverHelper.ValidateMovement(X, Y: Integer): Boolean;
begin
  Result := False;
end;

var
 METest : TMiningEngine;
 len : Integer; 
begin
 METest := TMiningEngine.Create;
 
 //len := METest.SetMiningArea(2559, 433, 2603, 440);
 //AddToSystemJournal(len.ToString());
 //METest.StartWorker; 

 METest.Free;
end.