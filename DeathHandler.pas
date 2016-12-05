Unit DeathHandler;

interface

type 
 TResurrecterBase = class
  function Resurrect : Boolean; virtual;
 end;

type
 TZuluHotelResurrecter = class(TResurrecterBase)
  public 
   LastTimeDead : TDateTime;
   LastJournalLine : String;
   function Resurrect : Boolean;
 end;

implementation

function TResurrecterBase.Resurrect: Boolean;
begin
  Result := False;
  if not Dead then 
   begin
     Result := True;
     Exit;
   end;
end;

//ZH Resurrecter

//* Info * : Quantity: 1 X: 1475 Y: 1645 Z: 20
//* Info * : Tooltip: Gate of Life
//* Info * : ID: $71837C32 Name: You see: Gate of Life Type: $1FE7 Color: $0000 

const
 __ZULUHOTEL_SHARD_COMMAND = '.rescue'; 
 __ZULUHOTEL_GATEOFLIFE_ID = $71837C32;

function TZuluHotelResurrecter.Resurrect: Boolean;
var 
 oldMoveThrouhNPCValue : Word;
begin  
  inherited;

   UOSay(__ZULUHOTEL_SHARD_COMMAND);
   Wait(3000);

   if not Dead then
    begin
     LastTimeDead := Now;
     Result := True;
     AddToSystemJournal('Successfully resurrected!');
     Exit;
   end;

   if not IsObjectExists($71837C32) then
    begin
      Result := False;
      AddToSystemJournal('Gate of life not found WTF!');
    end;
   
   oldMoveThrouhNPCValue:= MoveThroughNPC;
   MoveThroughNPC := 0;

   newMoveXY(1477, 1645, true, 0, true);
   newMoveXY(1472, 1645, true, 0, true);

   Wait(3000);
   if Dead then
    Resurrect();

   MoveThroughNPC := oldMoveThrouhNPCValue;
end;



var 
 testInstance : TZuluHotelResurrecter;
 res : Boolean;
begin
 testInstance := TZuluHotelResurrecter.Create;
 res := testInstance.Resurrect;
 testInstance.Free;
end.