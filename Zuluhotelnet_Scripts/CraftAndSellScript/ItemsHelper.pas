unit ItemsHelper;

interface

type TCardinalArray = Array of Cardinal;

type
  TItemsHelper = class
  public
    function GetFoundItems(ItemType: Word; Container : Cardinal) : TCardinalArray; overload;
    function GetFoundItems(ItemType, ItemColour: Word; Container : Cardinal) : TCardinalArray; overload;
    function CheckNotorietyArea(NotorietyLevel : Byte) : Boolean;
  end;

implementation

function TItemsHelper.GetFoundItems(ItemType: Word; Container : Cardinal): TCardinalArray;
var 
 res : TCardinalArray;
 List: TStringList; 
 i: Integer;
begin
  if (FindType(ItemType, Container) <= 0) then
    Exit;
    
  List := TStringList.Create;
  if GetFindedList(List) then
   begin
    SetLength(res, List.Count);
    for i := 0 to Length(res)-1 do 
      res[i] := StrToInt('$'+List.Strings[i]);
   end;

  List.Free; 

  Result := res;
end;

function TItemsHelper.GetFoundItems(ItemType, ItemColour: Word; Container : Cardinal): TCardinalArray;
var 
 res : TCardinalArray;
 List: TStringList; 
 i: Integer;
begin
  if (FindTypeEx(ItemType, ItemColour, Container, False) <= 0) then
    Exit;
    
  List := TStringList.Create;
  if GetFindedList(List) then
   begin
    SetLength(res, List.Count);
    for i := 0 to Length(res)-1 do 
      res[i] := StrToInt('$'+List.Strings[i]);
   end;

  List.Free; 

  Result := res;
end;

function TItemsHelper.CheckNotorietyArea(NotorietyLevel : Byte): Boolean;
var 
 founded : TCardinalArray;
 i : Integer;
begin
  Result := False;
  founded := GetFoundItems($FFFF, Ground);
  for i := 0 to High(founded) do
    if (GetNotoriety(founded[i]) >= NotorietyLevel) then
      begin
       Result := True;
       Exit;
      end;
end;

end.