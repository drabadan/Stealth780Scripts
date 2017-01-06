unit CraftAndSellScriptEngine;

interface

uses 
  ItemsHelper, RunebookHelper, LocationsHolder, CraftingEngine, MoverHelper;

type
  TCraftAndSellScriptEngine = class
  private 
    
    HomeRuneIdx, SellRuneIdx : Integer;
    IHelper : TItemsHelper;
    procedure InitializeSelf;
    function Unload : Boolean;
    function GoSellAll : Boolean;
    function WorkerWork : Boolean;    
  public
    Locations : TLocationsHolder;    
    Runebook : TRunebook;
    Mover : TMoverHelper;
    Crafter : TCraftingEngine;

    UnloadChest, TargetContainer : Cardinal;
    Colours : Array of Word;
    ItemToMake : String;
    CountToMakeOnce : Integer;

    procedure StartWorker;
    constructor Create;
end;

implementation

procedure TCraftAndSellScriptEngine.InitializeSelf;
begin
  IHelper := TItemsHelper.Create;
  Mover := TMoverHelper.Create;
  Runebook := TRunebook.Create;  
  HomeRuneIdx := Runebook.SearchForHomeRune;
  SellRuneIdx := Runebook.SearchRunesByKey('Prodaja')[0].ButtonId;
end;

constructor TCraftAndSellScriptEngine.Create;
begin
  InitializeSelf;
end;

function TCraftAndSellScriptEngine.WorkerWork: Boolean;
begin
  Unload;

  if Crafter.CraftItem(ItemToMake, Colours, TargetContainer, CountToMakeOnce) then
    GoSellAll;

  Result := True;
end;

procedure TCraftAndSellScriptEngine.StartWorker;
begin
  while True do
    begin
      WorkerWork;
      Wait(1000);
    end;
end;

function TCraftAndSellScriptEngine.Unload: Boolean;
begin
  Result := True;
  if (Dist(GetX(SelfId), GetY(SelfId), Locations.GetLocation('Home').X, Locations.GetLocation('Home').Y) > 20) then
    Runebook.Recall(HomeRuneIdx);

  Mover.MoveToSpotThroughDoor(Locations.GetLocation('Home').X, Locations.GetLocation('Home').Y, Locations.GetLocation('Door').X, Locations.GetLocation('Door').Y); 
  UseObject(UnloadChest);  
  CheckLag(30000);
  while (FindType($0EED, Backpack) > 0) do
    begin
      MoveItem(FindItem, 0, UnloadChest, 0,0,0);
      Wait(300);
      CheckLag(30000);
    end;

  Runebook.Restock(UnloadChest);
end;

function TCraftAndSellScriptEngine.GoSellAll: Boolean;
begin  
  Runebook.Recall(SellRuneIdx);
  FindDistance := 6;
  if (FindType($0190, Ground) > 0) or (FindType($0191, Ground) > 0) then
    newMoveXY(GetX(FindItem),  GetY(FindItem), true, 0, true)
  else
    begin
      AddToSystemJournal('Vendor not found!');
      Result := False;
      Exit;
    end;
  
  UOSay('Sell Bag');
  if WaitForTarget(10000) then
    TargetToObject(TargetContainer);

  Wait(1000);
  CheckLag(30000);
  Result := True;
end;

end.


