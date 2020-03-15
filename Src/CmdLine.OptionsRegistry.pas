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
    constructor Create(const ACmdDef: ICommandDefinition);
    function HasOption(const AName: string): Boolean;
    function RegisterAnonymousOption<T>(const AHelpText: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    function RegisterOption<T>(const ALongName, AShortName, AHelpText: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    function RegisterOption<T>(const ALongName, AShortName: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    function RegisterOption<T>(const ALongName: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    { Properties }
    property Alias: string read get_Alias;
    property Description: string read get_Description;
    property Name: string read get_Name;
    property Usage: string read get_Usage;
  end;

  TOptionsRegistry = class
  private
    class var FCommandDefs: TDictionary<string, ICommandDefinition>;
    class var FConsoleWidth: Integer;
    class var FDefaultCommand: TCommandDefinitionRecord;
    class var FDescriptionTabSize: Integer;
    class var FNameValueSeparator: string;
    class constructor Create;
    class destructor Destroy;
    class function get_DefaultCommand: ICommandDefinition; static;
  public
    class procedure Clear;
    class procedure EmumerateCommandOptions(const ACmdName: string; const AProc: TEnumerateCommandOptionsAction); overload;
    class procedure EnumerateCommands(const AProc: TEnumerateCommandAction); overload;
    class function GetCommandByName(const AName: string): ICommandDefinition;
    class function Parse: ICmdLineParseResult; overload;
    class function Parse(const ACmdLine: TStrings): ICmdLineParseResult; overload;
    class procedure PrintUsage(const ACmdName: string; const AProc: TPrintUsageAction); overload;
    class procedure PrintUsage(const aCmd: ICommandDefinition; const AProc: TPrintUsageAction); overload;
    class procedure PrintUsage(const AProc: TPrintUsageAction); overload;
    class function RegisterAnonymousOption<T>(const AHelpText: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    class function RegisterCommand(const AName, AAlias, ADescription, AHelpStr, AUsage: string; const AVisible: Boolean = True): TCommandDefinitionRecord;
    class function RegisterOption<T>(const ALongName, AShortName, AHelpText: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    class function RegisterOption<T>(const ALongName, AShortName: string; AAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    class function RegisterOption<T>(const ALongName: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition; overload;
    { Properties }
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

class procedure TOptionsRegistry.EmumerateCommandOptions(const ACmdName: string; const AProc: TEnumerateCommandOptionsAction);
var
  cmd: ICommandDefinition;
begin
  if not FCommandDefs.TryGetValue(ACmdName, cmd) then
    raise Exception.Create(Format(SUnknownCommand, [ACmdName]));

  cmd.EnumerateCommandOptions(AProc);
end;

class procedure TOptionsRegistry.EnumerateCommands(const AProc: TEnumerateCommandAction);
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
      function(const L, R: ICommandDefinition): Integer
      begin
        Result := CompareText(L.Name, R.Name);
      end));

    for cmd in cmdList do
      AProc(cmd);
  finally
    cmdList.Free;
  end;
end;

class function TOptionsRegistry.GetCommandByName(const AName: string): ICommandDefinition;
begin
  Result := nil;
  FCommandDefs.TryGetValue(AName.ToLower, Result);
end;

class function TOptionsRegistry.get_DefaultCommand: ICommandDefinition;
begin
  Result := TOptionsRegistry.FDefaultCommand.FCommandDef;
end;

class function TOptionsRegistry.Parse: ICmdLineParseResult;
var
  parser: ICmdLineParser;
begin
  parser := TCmdLineParser.Create(NameValueSeparator);
  Result := parser.Parse;
end;

class function TOptionsRegistry.Parse(const ACmdLine: TStrings): ICmdLineParseResult;
var
  parser: ICmdLineParser;
begin
  parser := TCmdLineParser.Create(NameValueSeparator);
  Result := parser.Parse(ACmdLine);
end;

class procedure TOptionsRegistry.PrintUsage(const ACmdName: string; const AProc: TPrintUsageAction);
var
  cmd: ICommandDefinition;
begin
  if ACmdName = '' then
  begin
    PrintUsage(AProc);
    Exit;
  end;

  if not FCommandDefs.TryGetValue(LowerCase(ACmdName), cmd) then
  begin
    AProc(Format(SUnknownCommand, [ACmdName]));
    Exit;
  end;
  PrintUsage(cmd, AProc);
end;

class procedure TOptionsRegistry.PrintUsage(const aCmd: ICommandDefinition; const AProc: TPrintUsageAction);
var
  maxDescW: Integer;
begin
  if not aCmd.IsDefault then
  begin
    AProc(SUsage + aCmd.Usage);
    AProc('');
    AProc(aCmd.Description);

    if aCmd.HelpText <> '' then
    begin
      AProc('');
      AProc('   ' + aCmd.HelpText);
    end;

    AProc('');
    AProc(SOptions);
    AProc('');
  end
  else
  begin
    AProc('');
    if FCommandDefs.Count > 0 then
      AProc(SGlobalOptText)
    else
      AProc(SOptions);
    AProc('');
  end;

  if FConsoleWidth < High(Integer) then
    maxDescW := FConsoleWidth
  else
    maxDescW := High(Integer);

  maxDescW := maxDescW - FDescriptionTabSize;

  aCmd.EnumerateCommandOptions(
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
      AProc(s);
      numDescStrings := Length(descStrings);
      if numDescStrings > 1 then
      begin
        for I := 1 to numDescStrings - 1 do
          AProc(''.PadRight(DescriptionTabSize + 1) + descStrings[I]);
      end;
    end
  );
end;

class procedure TOptionsRegistry.PrintUsage(const AProc: TPrintUsageAction);
var
  cmd: ICommandDefinition;
  descStrings: TArray<string>;
  I: Integer;
  maxDescW: Integer;
  numDescStrings: Integer;
begin
  AProc('');
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
        AProc(' ' + cmd.Name.PadRight(DescriptionTabSize - 1) + descStrings[0]);
        numDescStrings := Length(descStrings);
        if numDescStrings > 1 then
        begin
          for I := 1 to numDescStrings - 1 do
            AProc(''.PadRight(DescriptionTabSize) + descStrings[I]);
        end;
        AProc('');
      end;
    end;
  end;

  PrintUsage(FDefaultCommand.FCommandDef, AProc);
end;

class function TOptionsRegistry.RegisterAnonymousOption<T>(const AHelpText: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := FDefaultCommand.RegisterAnonymousOption<T>(AHelpText, AAction);
end;

class function TOptionsRegistry.RegisterCommand(const AName, AAlias, ADescription, AHelpStr, AUsage: string; const AVisible: Boolean = True): TCommandDefinitionRecord;
var
  cmdDef: ICommandDefinition;
  params: TCommandDefinitionCreateParams;
begin
  with params do
  begin
    Alias := AAlias;
    Description := ADescription;
    HelpText := AHelpStr;
    IsDefault := False; // Always false.  Only one default command.
    Name := AName;
    Usage := AUsage;
    Visible := AVisible;
  end;

  cmdDef := TCommandDefinition.Create(params);
  Result := TCommandDefinitionRecord.Create(cmdDef);
  FCommandDefs.Add(AName.ToLower, cmdDef);
end;

class function TOptionsRegistry.RegisterOption<T>(const ALongName, AShortName, AHelpText: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(ALongName, AShortName, AAction);
  Result.HelpText := AHelpText;
end;

class function TOptionsRegistry.RegisterOption<T>(const ALongName, AShortName: string; AAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := FDefaultCommand.RegisterOption<T>(ALongName, AShortName, AAction);
end;

class function TOptionsRegistry.RegisterOption<T>(const ALongName: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(ALongName, '', AAction);
end;

{ TCommandDef }
constructor TCommandDefinitionRecord.Create(const ACmdDef: ICommandDefinition);
begin
  FCommandDef := ACmdDef;
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

function TCommandDefinitionRecord.HasOption(const AName: string): Boolean;
begin
  Result := FCommandDef.HasOption(AName);
end;

function TCommandDefinitionRecord.RegisterAnonymousOption<T>(const AHelpText: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := TOptionDefinition<T>.Create('', '', AHelpText, AAction);
  Result.HasValue := False;
  FCommandDef.AddOption(Result);
end;

function TCommandDefinitionRecord.RegisterOption<T>(const ALongName, AShortName, AHelpText: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(ALongName, AShortName, AAction);
  Result.HelpText := AHelpText;
end;

function TCommandDefinitionRecord.RegisterOption<T>(const ALongName, AShortName: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  if ALongName.IsEmpty then
    raise Exception.Create(SOptNameMissing);

  if FCommandDef.HasOption(LowerCase(ALongName)) then
    raise Exception.Create(Format(SOptNameDuplicated, [ALongName]));

  if FCommandDef.HasOption(LowerCase(AShortName)) then
    raise Exception.Create(Format(SOptNameDuplicated, [AShortName]));

  Result := TOptionDefinition<T>.Create(ALongName, AShortName, AAction);
  FCommandDef.AddOption(Result);
end;

function TCommandDefinitionRecord.RegisterOption<T>(const ALongName: string; const AAction: TOptionValueParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(ALongName, '', AAction);
end;

initialization

end.
