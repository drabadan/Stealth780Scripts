Unit RunebookHelper;

interface

type
 TRuneEntry = record
  Title : String;
  ButtonId : Integer;
 end;

type
 TRunebook = class
 private
  LatestGumpInfo : TGumpInfo;
  Id : Cardinal;
  function Open : Boolean;  
 public
  Runes : Array of TRuneEntry;
  function Recall(Rune : TRuneEntry) : Boolean;
  function Initialize(Id : Cardinal) : Boolean;
 end;

implementation

function TRunebook.Initialize(Id: Cardinal) : Boolean;
var
 i, runeCount : Integer;
 tmpRuneEntry : TRuneEntry;
begin
  Self.Id := Id;

  UseObject(Id);
  Wait(1000);

  if (GetGumpsCount = 0) then
   begin
    AddToSystemJournal('Could not open runebook!');
   end;
  
  GetGumpInfo(GetGumpsCount-1, LatestGumpInfo);

  runeCount := 0;
  
  if(Length(LatestGumpInfo.Text) > 0) then
   for i := 0 to High(LatestGumpInfo.Text) do
     if(LatestGumpInfo.Text[i] = 'Drop rune') then
       begin
         tmpRuneEntry.Title := LatestGumpInfo.Text[i+1];
         tmpRuneEntry.ButtonId := 1025 + runeCount;

         AddToSystemJournal(tmpRuneEntry.Title + ' ' + tmpRuneEntry.ButtonId.ToString);
         Inc(runeCount);

         SetLength(Runes, Length(Runes) + 1);
         Runes[High(Runes)] := tmpRuneEntry;
       end;

  AddToSystemJournal('Initialized ' + Length(Runes).ToString() + ' runes');
end;

function TRunebook.Recall(Rune: TRuneEntry): Boolean;
begin
  if not Self.Open then
  begin
    Result := False;
    Exit;
  end;

  AddToSystemJournal('Recalling to ' + Rune.Title);

  GetGumpInfo(GetGumpsCount-1, LatestGumpInfo);
  if(Length(LatestGumpInfo.GumpButtons) > 0)then
    NumGumpButton(GetGumpsCount-1, Rune.ButtonId);
end;

function TRunebook.Open: Boolean;
begin
  UseObject(Self.Id);
  Wait(1000);
  Result := True;
end;

var
 testInstance : TRunebook;
begin
 testInstance := TRunebook.Create;
 
 testInstance.Initialize($41054C9D);
end.