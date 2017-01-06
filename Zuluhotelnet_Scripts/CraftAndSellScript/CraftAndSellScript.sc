Program CraftAndSellScript;

uses
  CraftAndSellScriptEngine, CraftingEngine, RunebookHelper, LocationsHolder;

const
  Version = '103';

var
  crafter : TCraftingEngine;
  locations : TLocationsHolder;

  engine : TCraftAndSellScriptEngine;

  UnloadChest, TargetContainer : Cardinal;
  HomePoint, DoorPoint : TPoint;
  Colours : Array of Word;
  craftItems : TCraftItemArray;
  ItemToMake : String;
  CountToMakeOnce : Integer;

function ReadConfigSection(Section : String; IniFile : TIniFile) : Boolean;
var 
 //IniFile : TIniFile;
 i : Integer;
 SL : TStringList;
 coloursString : String;
begin
  Result := False;
  UnloadChest := IniFile.ReadInteger(Section,'UnloadChest', 0);      
  TargetContainer := IniFile.ReadInteger(Section,'TargetContainer', 0); 
  
  if (TargetContainer = 0) then
    TargetContainer := Backpack
  else
    TargetContainer := FindType(TargetContainer, Backpack);

  CountToMakeOnce := IniFile.ReadInteger(Section,'CountToMakeOnce', 0);    
  HomePoint.X := IniFile.ReadInteger(Section,'HomeX', 0);
  HomePoint.Y := IniFile.ReadInteger(Section,'HomeY', 0);
  DoorPoint.X := IniFile.ReadInteger(Section,'DoorX', 0);
  DoorPoint.Y := IniFile.ReadInteger(Section,'DoorY', 0);  
  ItemToMake := IniFile.ReadString(Section,'ItemToMake', '');    

  if (HomePoint.X = 0) or (HomePoint.Y = 0) or (UnloadChest = 0) then
    begin
      AddToSystemJournal('Wrong CraftAndSellScriptConfig.ini path! You should place it to \Scripts\Verana\CraftAndSellScriptConfig.ini');
      Halt;
    end;  
  coloursString := IniFile.ReadString(Section, 'Colours', '');
  AddToSystemJournal('Colours priorities: ' + coloursString);
  if coloursString > '' then
    begin
      SL := TStringList.Create;
      SL.CommaText := coloursString;
      SetLength(Colours, SL.Count);  
      for i := 0 to SL.Count-1 do
        begin
          //AddToSystemJournal(SL[i]);
          Colours[i] := StrToInt(SL[i]);
        end;
      SL.Free;
    end;

end;

procedure InitConstants;
var
  IniFile : TIniFile;  
  SLNames, SLItems : TStringList;
  i : Integer;  
begin
  AddToSystemJournal('Reading constants...');
  IniFile := TIniFile.Create(StealthPath + '\Scripts\Verana\CraftAndSellScriptConfig.ini');
  
  //Reading of CraftItems
  SLNames := TStringList.Create;
  SLNames.Commatext := IniFile.ReadString('CraftItems', 'ItemsNames', '');
  if SLNames.Count > 0 then
    begin
      SetLength(craftItems, SLNames.Count);
      for i := 0 to SLNames.Count-1 do
        begin
          SLItems := TStringList.Create;
          SLItems.StrictDelimiter := True;
          SLItems.Delimiter := ',';
          SLItems.DelimitedText := IniFile.ReadString('CraftItems', SLNames[i], '');
          if SLItems.Count = 6 then
            begin
              craftItems[i] := TCraftItem.Create(StrToInt(SLItems[0]), StrToInt(SLItems[1]), StrToInt(SLItems[2]), StrToInt(SLItems[3]), SLItems[4], SLItems[5]); 
              AddToSystemJournal(craftItems[i].MenuString +  ' ' + craftItems[i].CategoryString);
            end;
          SLItems.Free;
        end;
    end;
  SLNames.Free;

  if IniFile.SectionExists(CharName) then
    ReadConfigSection(CharName, IniFile)
  else
    ReadConfigSection('Constants', IniFile);

  IniFile.Free;
end;


begin  
  AddToSystemJournal('Version ' + Version);
  InitConstants;
  
  SetARStatus (True);
  SetPauseScriptOnDisconnectStatus(True);

  MoveOpenDoor := True;
  MoveThroughNPC := 0;

  locations := TLocationsHolder.Create;  
  locations.AddLocation('Home', HomePoint);
  locations.AddLocation('Door', DoorPoint);
  //AddToSystemJournal(craftItems[0].MenuString +  ' ' + craftItems[0].CategoryString);
  crafter := TCraftingEngine.Create(craftItems);
  
  engine := TCraftAndSellScriptEngine.Create;
  engine.Locations := locations;
  engine.Colours := Colours;
  engine.UnloadChest := UnloadChest;
  engine.TargetContainer := TargetContainer;
  engine.ItemToMake := ItemToMake;
  engine.CountToMakeOnce := CountToMakeOnce;
  engine.Crafter := crafter;

  engine.StartWorker;
end.