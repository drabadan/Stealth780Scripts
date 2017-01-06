unit CraftingEngine;


interface

uses
  ItemsHelper;

type 
 TCraftItem = record
  ToolType, ReagentType, RegColour, ResultItem : Word;
  RegsCount : Integer;
  MenuString, CategoryString : String;

  constructor Create(ToolType, ReagentType, ResultItem : Word; RegsCount : Integer; MenuString, CategoryString : String);
 end;

type TCraftItemArray = Array of TCraftItem;

type
  TCraftingEngine = class
   private
     CraftItems : TCraftItemArray;
     procedure InitializeCraftItems;
     
   public    
     IHelper : TItemsHelper;
     RestockChest : Cardinal;

     //function Restock : Boolean;
     function Checkregs(CraftItem : TCraftItem; Count : Integer) : Cardinal;
     function CheckTool(CraftItem : TCraftItem) : Cardinal;
     function MakeItem(CraftItem : TCraftItem; TargetContainer : Cardinal; Count : Integer = 1) : Boolean; overload;
     function MakeItem(CraftItem : TCraftItem; Count : Integer = 1) : Boolean; overload;

     function CraftItem(ItemTitle : String; TargetContainer : Cardinal; Count : Integer = 1) : Boolean; overload;
     function CraftItem(ItemTitle: String; Colour : Cardinal; TargetContainer : Cardinal; Count : Integer = 1): Boolean; overload;
     function CraftItem(ItemTitle: String; Colours : Array of Word; TargetContainer : Cardinal; Count : Integer = 1): Boolean; overload;

     constructor Create; overload;
     constructor Create(CraftItemsLoaded : TCraftItemArray); overload;
  end;


implementation

constructor TCraftItem.Create(ToolType, ReagentType, ResultItem: Word; RegsCount : Integer; MenuString, CategoryString: String);
begin
  Self.ToolType := ToolType;
  Self.ReagentType := ReagentType;
  Self.RegColour := $0000;
  Self.ResultItem := ResultItem;
  Self.RegsCount := RegsCount;
  Self.MenuString := MenuString;
  Self.CategoryString := CategoryString;
end;


procedure TCraftingEngine.InitializeCraftItems;  
begin
  SetLength(CraftItems, 1);

  CraftItems[0] := TCraftItem.Create($1EBC, $1BF2, $DF2, 7, 'Wand', 'Deadly Tools');
end;

constructor TCraftingEngine.Create(CraftItemsLoaded: TCraftItemArray);
//var
  //i : Integer;
begin
  
  //for i := 0 to High(CraftItemsLoaded) do
    //AddToSystemJournal(CraftItemsLoaded[i].CategoryString + ' ' + CraftItemsLoaded[i].MenuString);
  Self.CraftItems := CraftItemsLoaded;  
end;

constructor TCraftingEngine.Create;
begin
  InitializeCraftItems;  
end;

function TCraftingEngine.Checkregs(CraftItem: TCraftItem; Count: Integer) : Cardinal;
var
  tmpRegs : Cardinal;
  tmpStacks : TCardinalArray;
  i : Integer;
begin   
  tmpStacks := IHelper.GetFoundItems(CraftItem.ReagentType, CraftItem.RegColour, Backpack);
  for i := 1 to High(tmpStacks) do
    begin
      MoveItem(tmpStacks[i], 0, tmpStacks[i-1], 0,0,0);
      Wait(300);
      CheckLag(30000);
    end;

  FindTypeEx(CraftItem.ReagentType, CraftItem.RegColour, Backpack, false);
  //AddToSystemJournal(GetQuantity(FindItem).ToString + ' cat: ' + CraftItem.CategoryString);
  if GetQuantity(FindItem) >= CraftItem.RegsCount then
    begin
      Result := FindItem;
      Exit;
    end;
  //if RestockChest = 0 then
    //Exit;
  if RestockChest > 0 then
    begin
      UseObject(RestockChest);
      Wait(300);  
      CheckLag(30000);
    end;

  tmpRegs := FindTypeEx(CraftItem.ReagentType, CraftItem.RegColour, RestockChest, false);

  if tmpRegs = 0 then
    begin
      AddToSystemJournal('Regs not found!');
      Wait(30000);
      Result := Checkregs(CraftItem, Count);
      Exit;
    end;

  //if (FindFullQuantity >= Count) then
  MoveItem(FindItem, Count, Backpack, 0,0,0);
  Wait(300);
  CheckLag(30000);

  Result := Checkregs(CraftItem, Count);//FindTypeEx(CraftItem.ReagentType, CraftItem.RegColour, Backpack, false);
end;

function TCraftingEngine.CheckTool(CraftItem: TCraftItem) : Cardinal;
begin
  Result := FindType(CraftItem.ToolType, Backpack);
end;

function TCraftingEngine.MakeItem(CraftItem: TCraftItem; TargetContainer: Cardinal; Count: Integer): Boolean;
var
  tmpRegs : Cardinal;  
  tmpCount : Integer;
begin
  //AddToSystemJournal(IntToHex(TargetContainer, 8));
  UseObject(TargetContainer);
  CheckLag(30000);
  FindType(CraftItem.ResultItem, TargetContainer);
  tmpCount := FindCount;
  //AddToSystemJournal(FindCount.ToString);
  if (FindFullQuantity >= Count) then
    begin
      while FindType(CraftItem.ReagentType, Backpack) > 0 do
        begin
          MoveItem(FindItem, 0, Ground, 0,0,0);
          Wait(1000);
        end;
      Result := True;
      Exit;
    end;
  //AddToSystemJournal(((CraftItem.RegsCount * Count) - (CraftItem.RegsCount * tmpCount)).ToString + ' regsCount');
  tmpRegs := Checkregs(CraftItem, (CraftItem.RegsCount * Count) - (CraftItem.RegsCount * tmpCount));//FindTypeEx(CraftItem.ReagentType, $050C , Backpack, false);
  if (tmpRegs = 0) then
    begin
      AddToSystemJournal('No regs');
      Result := False;
      Exit;
    end;
    
  WaitMenu('What would you like to make?', CraftItem.CategoryString);
  WaitMenu('What would you like to make?', CraftItem.MenuString);

  if FindType(CraftItem.ToolType, Backpack) = 0 then
    if FindType(CraftItem.ToolType, Ground) = 0 then
      if FindType(CraftItem.ToolType, RestockChest) = 0 then
        begin
          AddToSystemJournal('Tools not found!');
          Result := False;
          Wait(30000);
          Result := MakeItem(CraftItem, TargetContainer, Count);
          Exit;
        end;

  UseObject(FindItem);
  if WaitForTarget(10000) then
    TargetToObject(tmpRegs);
  if not WaitJournalLineSystem(Now, 'Success|Fail|You destroyed', 30000) then
    AddToSystemJournal('Something wrong with waiting craft result')
  else if(TargetContainer <> Backpack) and (FoundedParamID = 0) then
    begin
      while (FindType(CraftItem.ResultItem, Backpack) > 0) do
        begin
          MoveItem(FindItem, 0, TargetContainer, 0,0,0);
          Wait(300);
          CheckLag(30000);
        end;
    end;

  Result := MakeItem(CraftItem, TargetContainer, Count);
end;

function TCraftingEngine.MakeItem(CraftItem: TCraftItem; Count : Integer = 1) : Boolean;
begin
  Result := MakeItem(CraftItem, Backpack, Count);
end;

function TCraftingEngine.CraftItem(ItemTitle: String; TargetContainer : Cardinal; Count : Integer = 1): Boolean;
var 
  i : Integer;
begin
  for i := 0 to High(CraftItems) do
    if(ItemTitle = CraftItems[i].MenuString) then
      begin
        Result := MakeItem(CraftItems[i], TargetContainer, Count);
        Exit;
      end;
end;

function TCraftingEngine.CraftItem(ItemTitle: String; Colour : Cardinal; TargetContainer : Cardinal; Count : Integer = 1): Boolean;
var 
  i : Integer;
begin
  for i := 0 to High(CraftItems) do
    if(ItemTitle = CraftItems[i].MenuString) then
      begin
        CraftItems[i].RegColour := Colour;
        Result := MakeItem(CraftItems[i], TargetContainer, Count);
        CraftItems[i].RegColour := $0;
        Exit;
      end;
end;

function TCraftingEngine.CraftItem(ItemTitle: String; Colours: Array of Word; TargetContainer: Cardinal; Count: Integer): Boolean;
var
  i : Integer;
begin
  for i := 0 to High(Colours) do
    Result := CraftItem(ItemTitle, Colours[i], TargetContainer, Count);
end;


end.