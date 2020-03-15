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
    function get_Alias: string;
    function get_Description: string;
    function get_HelpText: string;
    function get_IsDefault: Boolean;
    function get_Name: string;
    function get_RegisteredAnonymousOptions: TList<IOptionDefinition>;
    function get_RegisteredOptions: TList<IOptionDefinition>;
    function get_Usage: string;
    function get_Visible: Boolean;
  protected
    procedure AddOption(const AOption: IOptionDefinition);
    procedure Clear;
    procedure EnumerateCommandOptions(const AProc: TEnumerateCommandOptionsAction);
    procedure GetAllRegisteredOptions(const AResult: TList<IOptionDefinition>);
    function HasOption(const AName: string): Boolean;
    function TryGetOption(const AName: string; var AOption: IOptionDefinition): Boolean;
  public
    constructor Create(const AParams: TCommandDefinitionCreateParams);
    constructor CreateDefault(AVisible: Boolean);
    destructor Destroy; override;
    { Properties }
    property Alias: string read get_Alias;
    property Description: string read get_Description;
    property HelpText: string read get_HelpText;
    property IsDefault: Boolean read get_IsDefault;
    property Name: string read get_Name;
    property RegisteredAnonymousOptions: TList<IOptionDefinition> read get_RegisteredAnonymousOptions;
    property RegisteredOptions: TList<IOptionDefinition> read get_RegisteredOptions;
    property Usage: string read get_Usage;
    property Visible: Boolean read get_Visible;
  end;

implementation

uses
  Generics.Defaults,
  System.SysUtils;

constructor TCommandDefinition.Create(const AParams: TCommandDefinitionCreateParams);
begin
  inherited Create;

  with AParams do
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

constructor TCommandDefinition.CreateDefault(AVisible: Boolean);
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
    Visible := AVisible;
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
procedure TCommandDefinition.AddOption(const AOption: IOptionDefinition);
begin
  if AOption.IsAnonymous then
  begin
    FAnonymousOptions.Add(AOption);
  end
  else
  begin
    FRegisteredOptions.Add(AOption);
    FOptionsLookup.AddOrSetValue(LowerCase(AOption.LongName), AOption);

    if not AOption.ShortName.IsEmpty then
      FOptionsLookup.AddOrSetValue(LowerCase(AOption.ShortName), AOption);
  end;
end;

procedure TCommandDefinition.Clear;
begin
  FOptionsLookup.Clear;
  FRegisteredOptions.Clear;
  FAnonymousOptions.Clear;
end;

procedure TCommandDefinition.EnumerateCommandOptions(const AProc: TEnumerateCommandOptionsAction);
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
      AProc(opt);
  finally
    optionList.Free;
  end;
end;

procedure TCommandDefinition.GetAllRegisteredOptions(const AResult: TList<IOptionDefinition>);
begin
  AResult.AddRange(FAnonymousOptions);
  AResult.AddRange(FRegisteredOptions);
end;

function TCommandDefinition.get_Alias: string;
begin
  Result := FAlias;
end;

function TCommandDefinition.get_Description: string;
begin
  Result := FDescription;
end;

function TCommandDefinition.get_HelpText: string;
begin
  Result := FHelpText;
end;

function TCommandDefinition.get_IsDefault: Boolean;
begin
  Result := FIsDefault;
end;

function TCommandDefinition.get_Name: string;
begin
  Result := FName;
end;

function TCommandDefinition.get_RegisteredAnonymousOptions: TList<IOptionDefinition>;
begin
  Result := FAnonymousOptions;
end;

function TCommandDefinition.get_RegisteredOptions: TList<IOptionDefinition>;
begin
  Result := FRegisteredOptions;
end;

function TCommandDefinition.get_Usage: string;
begin
  Result := FUsage;
end;

function TCommandDefinition.get_Visible: Boolean;
begin
  Result := FVisible;
end;

function TCommandDefinition.HasOption(const AName: string): Boolean;
begin
  Result := FOptionsLookup.ContainsKey(LowerCase(AName));
end;

function TCommandDefinition.TryGetOption(
const AName: string;
var AOption: IOptionDefinition): Boolean;
begin
  Result := FOptionsLookup.TryGetValue(LowerCase(AName), AOption);
end;

end.
