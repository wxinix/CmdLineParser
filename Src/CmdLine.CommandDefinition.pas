unit CmdLine.CommandDefinition;

interface

uses
  Generics.Collections,
  CmdLine.Intf;

type
  TCommandDefinitionCreateParams = record
    Alias: string;
    Description: string;
    HelpText: string;
    IsDefault: Boolean;
    Name: string;
    Usage: string;
    Visible: Boolean;
  end;

  TCommandDefinition = class(TInterfacedObject, ICommandDefinition)
  private
    FAlias: string;
    FAnonymousOptions: TList<IOptionDefinition>;
    FDescription: string;
    FHelpText: string;
    FIsDefault: Boolean;
    FName: string;
    FOptionsLookup: TDictionary<string, IOptionDefinition>;
    FRegisteredOptions: TList<IOptionDefinition>;
    FUsage: string;
    FVisible: Boolean;
    function GetAlias: string;
    function GetDescription: string;
    function GetHelpText: string;
    function GetIsDefault: Boolean;
    function GetName: string;
    function GetRegisteredAnonymousOptions: TList<IOptionDefinition>;
    function GetRegisteredOptions: TList<IOptionDefinition>;
    function GetUsage: string;
    function GetVisible: Boolean;
  protected
    procedure AddOption(const aOption: IOptionDefinition);
    procedure Clear;
    procedure EnumerateCommandOptions(const aProc: TEnumerateCommandOptionsAction);
    procedure GetAllRegisteredOptions(const aList: TList<IOptionDefinition>);
    function HasOption(const aOptionName: string): Boolean;
    function TryGetOption(const aName: string; var aOption: IOptionDefinition): Boolean;
  public
    constructor Create(const aParams: TCommandDefinitionCreateParams);
    constructor CreateDefault(aVisible: Boolean);
    destructor Destroy; override;
    {Properties}
    property Alias: string read GetAlias;
    property Description: string read GetDescription;
    property HelpText: string read GetHelpText;
    property IsDefault: Boolean read GetIsDefault;
    property Name: string read GetName;
    property RegisteredAnonymousOptions: TList<IOptionDefinition> read GetRegisteredAnonymousOptions;
    property RegisteredOptions: TList<IOptionDefinition> read GetRegisteredOptions;
    property Usage: string read GetUsage;
    property Visible: Boolean read GetVisible;
  end;

implementation

uses
  Generics.Defaults,
  System.SysUtils;

constructor TCommandDefinition.Create(const aParams: TCommandDefinitionCreateParams);
begin
  inherited Create;

  with aParams do
  begin
    FAlias := Alias;
    FDescription := Description;
    FHelpText := HelpText;
    FIsDefault := IsDefault;
    FName := Name;
    FUsage := Usage;
    FVisible := Visible;
  end;

  FOptionsLookup := TDictionary<string, IOptionDefinition>.Create;
  FRegisteredOptions := TList<IOptionDefinition>.Create;
  FAnonymousOptions := TList<IOptionDefinition>.Create;
end;

constructor TCommandDefinition.CreateDefault(aVisible: Boolean);
var
  params: TCommandDefinitionCreateParams;
begin
  with params do
  begin
    Alias := EmptyStr;
    Description := EmptyStr;
    HelpText := EmptyStr;
    IsDefault := True; // Default is always True.
    Name := EmptyStr;
    Usage := EmptyStr;
    Visible := aVisible;
  end;

  Create(params);
end;

destructor TCommandDefinition.Destroy;
begin
  FOptionsLookup.Free;
  FAnonymousOptions.Free;
  FRegisteredOptions.Free;
  inherited;
end;

// Will be called only after HasOption is checked by TCommandDefintionRecord.
// HasOption must return False before proceeding to AddOption.
procedure TCommandDefinition.AddOption(const aOption: IOptionDefinition);
begin
  if aOption.IsAnonymous then
    FAnonymousOptions.Add(aOption)
  else
  begin
    FRegisteredOptions.Add(aOption);
    FOptionsLookup.AddOrSetValue(LowerCase(aOption.LongName), aOption);

    if not aOption.ShortName.IsEmpty then
      FOptionsLookup.AddOrSetValue(LowerCase(aOption.ShortName), aOption);
  end;
end;

procedure TCommandDefinition.Clear;
begin
  FOptionsLookup.Clear;
  FRegisteredOptions.Clear;
  FAnonymousOptions.Clear;
end;

procedure TCommandDefinition.EnumerateCommandOptions(const aProc: TEnumerateCommandOptionsAction);
var
  opt: IOptionDefinition;
  optionList: TList<IOptionDefinition>;
begin
  optionList := TList<IOptionDefinition>.Create;

  try
    optionList.AddRange(FRegisteredOptions);

    optionList.Sort(TComparer<IOptionDefinition>.Construct(
      function(const L, R: IOptionDefinition): Integer
      begin
        Result := CompareText(L.LongName, R.LongName);
      end));

    for opt in optionList do
      aProc(opt);
  finally
    optionList.Free;
  end;
end;

function TCommandDefinition.GetAlias: string;
begin
  Result := FAlias;
end;

procedure TCommandDefinition.GetAllRegisteredOptions(const aList: TList<IOptionDefinition>);
begin
  aList.AddRange(FAnonymousOptions);
  aList.AddRange(FRegisteredOptions);
end;

function TCommandDefinition.GetDescription: string;
begin
  Result := FDescription;
end;

function TCommandDefinition.GetHelpText: string;
begin
  Result := FHelpText;
end;

function TCommandDefinition.GetIsDefault: Boolean;
begin
  Result := FIsDefault;
end;

function TCommandDefinition.GetName: string;
begin
  Result := FName;
end;

function TCommandDefinition.GetRegisteredAnonymousOptions: TList<IOptionDefinition>;
begin
  Result := FAnonymousOptions;
end;

function TCommandDefinition.GetRegisteredOptions: TList<IOptionDefinition>;
begin
  Result := FRegisteredOptions;
end;

function TCommandDefinition.GetUsage: string;
begin
  Result := FUsage;
end;

function TCommandDefinition.GetVisible: Boolean;
begin
  Result := FVisible;
end;

function TCommandDefinition.HasOption(const aOptionName: string): Boolean;
begin
  Result := FOptionsLookup.ContainsKey(LowerCase(aOptionName));
end;

function TCommandDefinition.TryGetOption(const aName: string; var aOption:
  IOptionDefinition): Boolean;
begin
  Result := FOptionsLookup.TryGetValue(LowerCase(aName), aOption);
end;

end.
