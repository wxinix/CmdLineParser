unit CmdLine.OptionsRegistry;

interface

uses
  System.Classes,
  Generics.Collections,
  CmdLine.Intf;

type
  // Using a record here because non generic interfaces cannot have generic methods.
  // The actual command implementation is elsewhere.
  TCommandDefinitionRecord = record
  private
    FCommandDef: ICommandDefinition;
    function get_Alias: string;
    function get_Description: string;
    function get_Name: string;
    function get_Usage: string;
  public
    constructor Create(const aCommandDef: ICommandDefinition);
    function HasOption(const aName: string): Boolean;
    function RegisterAnonymousOption<T>(const aHelpText: string;
      const aAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    function RegisterOption<T>(const aLongName, aShortName, aHelpText: string;
      const aAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    function RegisterOption<T>(const aLongName, aShortName: string;
      const aAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    function RegisterOption<T>(const aLongName: string;
      const aAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    {Properties}
    property Alias: string read get_Alias;
    property Description: string read get_Description;
    property Name: string read get_Name;
    property Usage: string read get_Usage;
  end;

  TOptionsRegistry = class
  private
    {$REGION 'class var'}
    class var FCommandDefs: TDictionary<string, ICommandDefinition>;
    class var FConsoleWidth: Integer;
    class var FDefaultCommand: TCommandDefinitionRecord;
    class var FDescriptionTabSize: Integer;
    class var FNameValueSeparator: string;
    {$ENDREGION}
  private
    {Class Constructor}
    class constructor Create;
    class destructor Destroy;
    class function get_DefaultCommand: ICommandDefinition; static;
  public
    class procedure Clear;

    class procedure EmumerateCommandOptions(const aCommandName: string;
      const aProc: TEnumerateCommandOptionsAction); overload;

    class procedure EnumerateCommands(const aProc: TEnumerateCommandAction); overload;

    class function GetCommandByName(const aName: string): ICommandDefinition;

    class function Parse: ICmdLineParseResult; overload;
    class function Parse(const aCmdLine: TStrings): ICmdLineParseResult; overload;

    class procedure PrintUsage(const aCommandName: string;
      const aProc: TPrintUsageAction); overload;

    class procedure PrintUsage(const aCommand: ICommandDefinition;
      const aProc: TPrintUsageAction); overload;

    class procedure PrintUsage(const aProc: TPrintUsageAction); overload;

    class function RegisterCommand(
      const aName: string;
      const aAlias: string;
      const aDescription: string;
      const aHelpString: string;
      const aUsage: string;
      const aVisible: Boolean = True): TCommandDefinitionRecord;

    class function RegisterAnonymousOption<T>(const aHelpText: string;
      const aAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;

    class function RegisterOption<T>(
      const aLongName: string;
      const aShortName: string;
      const aHelpText: string;
      const aAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;

    class function RegisterOption<T>(
      const aLongName: string;
      const aShortName: string;
      const aAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;

    class function RegisterOption<T>(const aLongName: string;
      const aAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    {Properties}
    class property DefaultCommand: ICommandDefinition read get_DefaultCommand;
    class property DescriptionTabSize: Integer read FDescriptionTabSize write FDescriptionTabSize;
    class property NameValueSeparator: string read FNameValueSeparator write FNameValueSeparator;
    class property RegisteredCommands: TDictionary<string, ICommandDefinition> read FCommandDefs;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils,
  Generics.Defaults,
  CmdLine.Consts,
  CmdLine.CommandDefinition,
  CmdLine.OptionDefinition,
  CmdLine.Parser,
  CmdLine.Utils;

class constructor TOptionsRegistry.Create;
var
  cmdDef: ICommandDefinition;
begin
  cmdDef := TCommandDefinition.CreateDefault(False);
  FDefaultCommand := TCommandDefinitionRecord.Create(cmdDef);
  FCommandDefs := TDictionary<string, ICommandDefinition>.Create;
  FNameValueSeparator := ':';
  FDescriptionTabSize := DefaultDescriptionTabSize;
  FConsoleWidth := GetConsoleWidth;
end;

class destructor TOptionsRegistry.Destroy;
begin
  FCommandDefs.Free;
end;

class procedure TOptionsRegistry.Clear;
begin
  FDefaultCommand.FCommandDef.Clear;
  FCommandDefs.Clear;
end;

class procedure TOptionsRegistry.EmumerateCommandOptions(const aCommandName: string;
  const aProc: TEnumerateCommandOptionsAction);
var
  cmd: ICommandDefinition;
begin
  if not FCommandDefs.TryGetValue(aCommandName, cmd) then
    raise Exception.Create(Format(SUnknownCommand, [aCommandName]));

  cmd.EnumerateCommandOptions(aProc);
end;

class function TOptionsRegistry.GetCommandByName(const aName: string): ICommandDefinition;
begin
  Result := nil;
  FCommandDefs.TryGetValue(aName.ToLower, Result);
end;

class function TOptionsRegistry.get_DefaultCommand: ICommandDefinition;
begin
  Result := TOptionsRegistry.FDefaultCommand.FCommandDef;
end;

class function TOptionsRegistry.Parse: ICmdLineParseResult;
var
  Parser: ICmdLineParser;
begin
  Parser := TCmdLineParser.Create(NameValueSeparator);
  Result := Parser.Parse;
end;

class function TOptionsRegistry.Parse(const aCmdLine: TStrings): ICmdLineParseResult;
var
  Parser: ICmdLineParser;
begin
  Parser := TCmdLineParser.Create(NameValueSeparator);
  Result := Parser.Parse(aCmdLine);
end;

class procedure TOptionsRegistry.PrintUsage(const aCommandName: string; const aProc:
  TPrintUsageAction);
var
  cmd: ICommandDefinition;
begin
  if aCommandName = '' then
  begin
    PrintUsage(aProc);
    Exit;
  end;

  if not FCommandDefs.TryGetValue(LowerCase(aCommandName), cmd) then
  begin
    aProc(Format(SUnknownCommand, [aCommandName]));
    Exit;
  end;
  PrintUsage(cmd, aProc);
end;

class procedure TOptionsRegistry.PrintUsage(const aProc: TPrintUsageAction);
var
  cmd: ICommandDefinition;
  descStrings: TArray<string>;
  I: Integer;
  maxDescW: Integer;
  numDescStrings: Integer;
begin
  aProc('');
  if FCommandDefs.Count > 0 then
  begin
    if FConsoleWidth < High(Integer) then
      maxDescW := FConsoleWidth
    else
      maxDescW := High(Integer);

    maxDescW := maxDescW - FDescriptionTabSize;

    for cmd in FCommandDefs.Values do
    begin
      if cmd.Visible then
      begin
        descStrings := SplitText(cmd.Description, maxDescW);
        aProc(' ' + cmd.Name.PadRight(DescriptionTabSize - 1) + descStrings[0]);
        numDescStrings := Length(descStrings);
        if numDescStrings > 1 then
        begin
          for I := 1 to numDescStrings - 1 do
            aProc(''.PadRight(DescriptionTabSize) + descStrings[I]);
        end;
        aProc('');
      end;
    end;
  end;
  
  PrintUsage(FDefaultCommand.FCommandDef, aProc);
end;

class function TOptionsRegistry.RegisterAnonymousOption<T>(const aHelpText: string;
  const aAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := FDefaultCommand.RegisterAnonymousOption<T>(aHelpText, aAction);
end;

class function TOptionsRegistry.RegisterCommand(const aName, aAlias, aDescription,
  aHelpString, aUsage: string; const aVisible: Boolean = True): TCommandDefinitionRecord;
var
  cmdDef: ICommandDefinition;
  params: TCommandDefinitionCreateParams;
begin
  with params do
  begin
    Alias := aAlias;
    Description := aDescription;
    HelpText := aHelpString;
    IsDefault := False; // Always false.  Only one default command.
    Name := aName;
    Usage := aUsage;
    Visible := aVisible;
  end;

  cmdDef := TCommandDefinition.Create(params);
  Result := TCommandDefinitionRecord.Create(cmdDef);
  FCommandDefs.Add(aName.ToLower, cmdDef);
end;

class function TOptionsRegistry.RegisterOption<T>(const aLongName, aShortName,
  aHelpText: string; const aAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(aLongName, aShortName, aAction);
  Result.HelpText := aHelpText;
end;

class function TOptionsRegistry.RegisterOption<T>(const aLongName,
  aShortName: string; const aAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := FDefaultCommand.RegisterOption<T>(aLongName, aShortName, aAction);
end;

class function TOptionsRegistry.RegisterOption<T>(const aLongName: string;
  const aAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(aLongName, '', aAction);
end;

class procedure TOptionsRegistry.EnumerateCommands(const aProc: TEnumerateCommandAction);
var
  cmd: ICommandDefinition;
  cmdList: TList<ICommandDefinition>;
begin
  // The commandDefs are stored in a dictionary, so we need to sort them ourselves.
  cmdList := TList<ICommandDefinition>.Create;
  try
    for cmd in FCommandDefs.Values do
    begin
      if cmd.Visible then
        cmdList.Add(cmd);
    end;

    cmdList.Sort(TComparer<ICommandDefinition>.Construct(
{$REGION 'Comparer'}
      function(const L, R: ICommandDefinition): Integer
      begin
        Result := CompareText(L.Name, R.Name);
      end)
{$ENDREGION}
    );

    for cmd in cmdList do
      aProc(cmd);
  finally
    cmdList.Free;
  end;
end;

class procedure TOptionsRegistry.PrintUsage(const aCommand: ICommandDefinition;
  const aProc: TPrintUsageAction);
var
  maxDescW: Integer;
begin
  if not aCommand.IsDefault then
  begin
    aProc(SUsage + aCommand.Usage);
    aProc('');
    aProc(aCommand.Description);

    if aCommand.HelpText <> '' then
    begin
      aProc('');
      aProc('   ' + aCommand.HelpText);
    end;

    aProc('');
    aProc(SOptions);
    aProc('');
  end
  else
  begin
    aProc('');
    if FCommandDefs.Count > 0 then
      aProc(SGlobalOptText)
    else
      aProc(SOptions);
    aProc('');
  end;

  if FConsoleWidth < High(Integer) then
    maxDescW := FConsoleWidth
  else
    maxDescW := High(Integer);

  maxDescW := maxDescW - FDescriptionTabSize;

  aCommand.EnumerateCommandOptions(
{$REGION 'TEnumerateCommandOptionsAction'}
    procedure(const aOption: IOptionDefinition)
    var
      al: Integer;
      descStrings: TArray<string>;
      I: Integer;
      numDescStrings: Integer;
      s: string;
    begin
      descStrings := SplitText(aOption.HelpText, maxDescW);
      al := Length(aOption.ShortName);

      if al <> 0 then
        Inc(al, ShortNameExtraSpaceSize); // add brackets (- ) and 2 spaces;

      s := ' -' + aOption.LongName.PadRight(DescriptionTabSize - 1 - al);

      if al > 0 then
        s := s + '(-' + aOption.ShortName + ')' + '  ';

      s := s + descStrings[0];
      aProc(s);
      numDescStrings := Length(descStrings);
      if numDescStrings > 1 then
      begin
        for I := 1 to numDescStrings - 1 do
          aProc(''.PadRight(DescriptionTabSize + 1) + descStrings[I]);
      end;
    end
{$ENDREGION}
  );
end;

{ TCommandDef }
constructor TCommandDefinitionRecord.Create(const aCommandDef: ICommandDefinition);
begin
  FCommandDef := aCommandDef;
end;

function TCommandDefinitionRecord.get_Alias: string;
begin
  Result := FCommandDef.Alias;
end;

function TCommandDefinitionRecord.get_Description: string;
begin
  Result := FCommandDef.Description;
end;

function TCommandDefinitionRecord.get_Name: string;
begin
  Result := FCommandDef.Name;
end;

function TCommandDefinitionRecord.get_Usage: string;
begin
  Result := FCommandDef.Usage;
end;

function TCommandDefinitionRecord.HasOption(const aName: string): Boolean;
begin
  Result := FCommandDef.HasOption(aName);
end;

function TCommandDefinitionRecord.RegisterAnonymousOption<T>(const aHelpText: string;
  const aAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := TOptionDefinition<T>.Create('', '', aHelpText, aAction);
  Result.HasValue := False;
  FCommandDef.AddOption(Result);
end;

function TCommandDefinitionRecord.RegisterOption<T>(const aLongName, aShortName,
  aHelpText: string; const aAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(aLongName, aShortName, aAction);
  Result.HelpText := aHelpText;
end;

function TCommandDefinitionRecord.RegisterOption<T>(const aLongName, aShortName: string;
  const aAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  if aLongName.IsEmpty then
    raise Exception.Create(SOptNameMissing);

  if FCommandDef.HasOption(LowerCase(aLongName)) then
    raise Exception.Create(Format(SOptNameDuplicated, [aLongName]));

  if FCommandDef.HasOption(LowerCase(aShortName)) then
    raise Exception.Create(Format(SOptNameDuplicated, [aShortName]));

  Result := TOptionDefinition<T>.Create(aLongName, aShortName, aAction);
  FCommandDef.AddOption(Result);
end;

function TCommandDefinitionRecord.RegisterOption<T>(const aLongName: string;
  const aAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(aLongName, '', aAction);
end;

initialization

end.
