Unit RunebookHelper;

interface

type
 TRuneEntry = record
  Title : String;
  ButtonId : Integer;
  constructor Create(Title : String; ButtonId : Integer);
 end;

type TRuneEntryArray = Array of TRuneEntry;

type
 TRunebook = class
 private
  LatestGumpInfo : TGumpInfo;
  Id : Cardinal;

  MaxCharges : Integer;

  function Open : Boolean; 
  function ParseCharges(Str : String) : Integer;    
 public
  Runes : TRuneEntryArray;
  Charges : Integer;

  function Initialize : Boolean;

  function Recall(Rune : TRuneEntry) : Boolean; overload;
  function Recall(RuneTitle : String) : Boolean; overload;
  function Recall(ButtonId : Integer) : Boolean; overload;
  
  function Restock(ScrollChest : Cardinal) : Boolean;
  
  function SearchForHomeRune : Integer;
  function SearchRunesByKey(Key : String) : TRuneEntryArray;

  procedure SayAllDestinations;
  
  constructor Create; overload;
  constructor Create(Id : Cardinal); overload;
 end;

implementation

const
 __STANDARTLAG = 1000;
 __RUNEBOOK_TYPE = $0EFA;

constructor TRuneEntry.Create(Title: String; ButtonId: Integer);
begin
  Self.Title := Title;
  Self.ButtonId := ButtonId;
end;

constructor TRunebook.Create;
begin
  if (FindType(__RUNEBOOK_TYPE, Backpack) > 0) then
    Self.Id := FindItem
  else
    begin
      AddToSystemJournal('Runebook not found in pack!');
      Self.Id := 0;      
    end;

  Initialize;
end;

constructor TRunebook.Create(Id: Cardinal);
begin
  Self.Id := Id;
end;


function TRunebook.ParseCharges(Str : String) : Integer;
begin
  Result := -1;
  if(Pos('Charges:', Str) <= 0) then
    Exit;

  Result := StrToInt(Copy(Str, Pos(':', Str) + 1, Length(Str) - Pos(':', Str)));
end;


function TRunebook.Initialize : Boolean;
var
 i, runeCount, gumpsCount : Integer;
 tmpRuneEntry : TRuneEntry;
begin
  if not Connected then
    Exit;

  SetLength(Runes, 0);

  Open;
  Wait(2000);

  if (GetGumpsCount = 0) then
   begin
    AddToSystemJournal('Could not open runebook!');
    Initialize;
   end;
  
 gumpsCount := GetGumpsCount-1;
 if not (gumpsCount >= 0) then
   gumpsCount := 0;

  GetGumpInfo(gumpsCount, LatestGumpInfo);

  runeCount := 0;
  
  if(Length(LatestGumpInfo.Text) <= 0) then
   begin
    Result := False;
    AddToSystemJournal('Wrong runebook gump info data!');
    Exit;  
   end;

   Charges := ParseCharges(LatestGumpInfo.Text[0]);
   MaxCharges := ParseCharges(LatestGumpInfo.Text[1]);

   for i := 0 to High(LatestGumpInfo.Text) do
    if(LatestGumpInfo.Text[i] = 'Drop rune') then
      begin
         tmpRuneEntry.Title := LatestGumpInfo.Text[i+1];
         tmpRuneEntry.ButtonId := 1025 + runeCount;
         Inc(runeCount);

         SetLength(Runes, Length(Runes) + 1);
         Runes[High(Runes)] := tmpRuneEntry;
       end;
  Result := True;
end;

function TRunebook.Open: Boolean;
begin
  if TargetPresent then 
   begin
    CancelTarget;
    Wait(1000);
  end;

  UseObject(Self.Id);
  Wait(1000);
  Result := True;  
end;

function TRunebook.Recall(ButtonId: Integer): Boolean;
var 
 x, y : Word;
 i, count : Integer;
begin
  if Dead then 
   Exit;
  
  if not IsObjectExists(Self.Id) then
    UseObject(Backpack);
  
  if not Self.Open then
  begin
    UseObject(Backpack);
    Result := False;
    Exit;
  end;

  Step(1, true);
  Wait(1000);

  x := GetX(SelfID);
  y := GetY(SelfID);

  count := GetGumpsCount;
  if(count > 0) then
   NumGumpButton(count - 1, ButtonId)
  else
   Recall(ButtonId);

  Wait(__STANDARTLAG);
  Charges := Charges - 1;
  
  for i := 0 to 5 do
    begin
      //AddToSystemJournal('Change position seq: ' + i.ToString);
      Wait(__STANDARTLAG*2);
      if ((GetX(SelfID) <> x) or (GetY(SelfID) <> y)) then
       begin
         Result := True;
         Exit;
       end;
    end;
end;

function TRunebook.Recall(Rune: TRuneEntry): Boolean;
begin
  AddToSystemJournal('Recalling to ' + Rune.Title);
  Result := Recall(Rune.ButtonId);  
end;

function TRunebook.Recall(RuneTitle: String): Boolean;
var
 i : Integer;
 tmpRuneEntry : TRuneEntry;
begin
  Result := False;
  for i := 0 to High(Runes) do
    if(Runes[i].Title = RuneTitle) then
     begin
      AddToSystemJournal(Runes[i].Title + ' ' + RuneTitle);
      tmpRuneEntry := Runes[i];
      Break;
     end;
  AddToSystemJournal('bla ' + tmpRuneEntry.Title);
  Result := Recall(tmpRuneEntry);
end;

procedure TRunebook.SayAllDestinations;
var
 i : Integer;
begin
  for i := 0 to High(Runes) do
    AddToSystemJournal(Runes[i].Title);  
end;

function TRunebook.Restock(ScrollChest: Cardinal): Boolean;
begin
  if (Charges = MaxCharges) then
    Exit;
  
  //if not IsObjectExists(ScrollChest) then
  //  begin
  //    Result := False;
  //    AddToSystemJournal('Restock chest not found!');
  //    Exit;
  //  end;

  newMoveXY(GetX(ScrollChest), GetY(ScrollChest), true, 1, true);

  UseObject(ScrollChest);
  Wait(__STANDARTLAG);
  
  if not (FindType($1F4C, Ground) > 0) then
    FindType($1F4C, ScrollChest);
  
  //AddToSystemJournal('Recall scrolls in chest left: ' + FindFullQuantity.ToString + ' ' + MaxCharges.ToString + ' z: ' + GetZ(FindItem).ToString + ' id: 0x' + IntToHex(FindItem, 8));

  if (FindFullQuantity > 0) then
   begin
     MoveItem(FindItem, MaxCharges - Charges, Id, 0,0,0);
     Wait(__STANDARTLAG);
     if(FindFullQuantity > (MaxCharges - Charges)) then
      Charges := MaxCharges
     else
      Charges := Charges + FindFullQuantity;      
   end;

   if (FindType($1F4C, Backpack) > 0) then
     begin
       MoveItem(FindItem, 0, ScrollChest, 0,0,0);
       Wait(__STANDARTLAG);
     end;

   Result := True;
end;

function TRunebook.SearchForHomeRune: Integer;
var 
 i : Integer;
begin
  Result := -1;
  if(Length(Runes) = 0) then
    Initialize;

  if(Length(Runes) = 0)then
    Exit;

  for i := 0 to High(Runes) do 
   //AddToSystemJournal(Runes[i].Title);
   if (Pos('Home', Runes[i].Title) > 0) then        
     begin
       Result := Runes[i].ButtonId;
       Break;
     end;
    //end;
end;

function TRunebook.SearchRunesByKey(Key: String): TRuneEntryArray
var 
 i : Integer;
 OutRunes : TRuneEntryArray;
begin
 //Result := -1;

 for i := 0 to High(Runes) do
  if (Pos(Key, Runes[i].Title) > 0) then
   begin
     SetLength(OutRunes, Length(OutRunes) + 1);
     //OutRunes[High(OutRunes)] := Runes[i];
     OutRunes[High(OutRunes)] := TRuneEntry.Create(Runes[i].Title, Runes[i].ButtonId);
   end;

  Result := OutRunes;
end;




end.
 