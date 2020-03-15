unit CmdLine.Parser;

interface

uses
  System.Classes,
  CmdLine.Intf;

type
  TCmdLineParseResult = class(TInterfacedObject, ICmdLineParseResult, IInternalParseResult)
  private
    FCommand: ICommandDefinition;
    FErrors: TStringList;
    procedure AddError(const aErrStr: string);
    procedure SetCommand(const ACmd: ICommandDefinition);
    function get_Command: ICommandDefinition;
    function get_CommandName: string;
    function get_ErrorText: string;
    function get_HasErrors: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    property Command: ICommandDefinition read get_Command;
    property CommandName: string read get_CommandName;
    property ErrorText: string read get_ErrorText;
    property HasErrors: Boolean read get_HasErrors;
  end;

  /// <summary>Parse the command line. The command line always has a default
  ///  command that owns global options. There may also include one and only one
  ///  extra non-default command. After the non-default command is hit, all items
  ///  after it will be treated as its options. Anonymous options will be searched
  ///  only within this non-default command's registered  anonymous options. Named
  ///  options will be search within this non-default command, if not found, the
  ///  search will continue within the default command,i.e., global options.
  /// </summary>
  TCmdLineParser = class(TInterfacedObject, ICmdLineParser)
  private
    FAnonymousIndex: Integer;
    FNameValueSeparator: string;

    /// <summary> Checks if a command line string itme has prefixed one of the four
    /// option token, e.g., --, -, /, and @
    /// </summary>
    /// <returns> True, when the item has option token, False otherwise.
    /// </returns>
    /// <param name="aCmdLineStrItem"> (string) A command line string item. </param>
    function HasOptionToken(var ACmdLineStrItem: string): Boolean;

    function InternalInvokeOption(AOption: IOptionDefinition; const AName, AValue: string; AUseNameAsValue: Boolean; out AErrMsg: string): Boolean;
    procedure InternalParse(const ACmdLineStrs: TStrings; const AParseResult: IInternalParseResult);
    procedure InternalParseFile(const AFileName: string; const AParseResult: IInternalParseResult);
    procedure InternalValidate(const AParseResult: IInternalParseResult);
    function TryGetCommand(const ACmdName: string; var ACmd: ICommandDefinition): Boolean;
    function TryGetOption(const ACurCmd, ADefCmd: ICommandDefinition; const AOptionName: string; var AOption: IOptionDefinition): Boolean;
  protected
    function Parse: ICmdLineParseResult; overload;
    function Parse(const ACmdLineStrs: TStrings): ICmdLineParseResult; overload;
  public
    constructor Create(const aNameValueSeparator: string);
    destructor Destroy; override;
  end;

implementation

uses
  Generics.Collections,
  System.StrUtils,
  System.SysUtils,
  CmdLine.Consts,
  CmdLine.OptionDefinition,
  CmdLine.OptionsRegistry,
  CmdLine.Utils;

constructor TCmdLineParser.Create(const aNameValueSeparator: string);
begin
  inherited Create;
  FAnonymousIndex := 0;
  FNameValueSeparator := aNameValueSeparator;
end;

destructor TCmdLineParser.Destroy;
begin
  inherited;
end;

function TCmdLineParser.HasOptionToken(var ACmdLineStrItem: string): Boolean;
var
  token: string;
begin
  Result := False;

  for token in OptionTokens do
  begin
    if StartsStr(token, ACmdLineStrItem) then
    begin
      Delete(ACmdLineStrItem, 1, Length(token));
      Result := True;
      Break;
    end;
  end;
end;

function TCmdLineParser.InternalInvokeOption(AOption: IOptionDefinition; const AName, AValue: string; AUseNameAsValue: Boolean; out AErrMsg: string): Boolean;
begin
  Result := True;
  AErrMsg := EmptyStr;

  try
    if AUseNameAsValue then
      (AOption as IOptionDefinitionInvoke).Invoke(AName)
    else
      (AOption as IOptionDefinitionInvoke).Invoke(AValue);
  except
    on E: Exception do
    begin
      Result := False;
      AErrMsg := Format(SErrSettingOpt, [AName, AValue, E.Message]);
    end;
  end;
end;

// Note: all the command line arguments are separated by a space, but if argument
// itself has a space then use double quotes “” or single quotes ”.
// Anonyous option will be checked within current command only. Because, to check
// further within default command, we would need maintain two anonymous index, for
// default and current command respective. That is uncessarily complicated. Hence we
// don't do that.
procedure TCmdLineParser.InternalParse(const ACmdLineStrs: TStrings; const AParseResult: IInternalParseResult);
var
  I, optionNameValueSeperatorPos: Integer;
  optionName, optionValue, cmdLineStrItem, errStr: string;
  option: IOptionDefinition;
  curCommand, newCommand: ICommandDefinition;
  bSeekValue, bUseNameAsValue: Boolean;
begin
  curCommand := TOptionsRegistry.DefaultCommand;

  for I := 0 to ACmdLineStrs.Count - 1 do
  begin
    optionNameValueSeperatorPos := 0;
    option := nil;
    bSeekValue := True;
    bUseNameAsValue := False;
    cmdLineStrItem := ACmdLineStrs.Strings[I];

    if cmdLineStrItem.IsEmpty then //Possible, if inside quotes.
      Continue;

    if not HasOptionToken(cmdLineStrItem) then
    begin
      if curCommand.IsDefault and TryGetCommand(cmdLineStrItem, newCommand) then
      begin
        curCommand := newCommand;
        newCommand := nil;
        AParseResult.SetCommand(curCommand); //Set only once, i.e. only one command is allowed.
        FAnonymousIndex := 0;
        Continue;
      end
      else //Anonymous option only checked within current command.
        if FAnonymousIndex < curCommand.RegisteredAnonymousOptions.Count then
        begin
          option := curCommand.RegisteredAnonymousOptions.Items[FAnonymousIndex];
          Inc(FAnonymousIndex);
          bSeekValue := False;
          bUseNameAsValue := True;
        end
        else
        begin
          AParseResult.AddError(Format(SUnknownAnonymousOpt, [ACmdLineStrs.Strings[I]]));
          Continue;
        end;
    end;

    if bSeekValue then
      optionNameValueSeperatorPos := Pos(FNameValueSeparator, cmdLineStrItem);

    if optionNameValueSeperatorPos > 0 then
    begin
      optionName := Copy(cmdLineStrItem, 1, optionNameValueSeperatorPos - 1);
      optionValue := Copy(cmdLineStrItem, optionNameValueSeperatorPos + Length(FNameValueSeparator), MaxInt);
      StripQuotes(optionValue);
    end
    else
    begin
      optionName := cmdLineStrItem;
      optionValue := EmptyStr;
    end;

    // if at this point, option is nil, then will try get it
    if not TryGetOption(curCommand, TOptionsRegistry.DefaultCommand, optionName, option) then
    begin
      AParseResult.AddError(Format(SUnknownOpt, [optionName]));
      Continue;
    end;

    if option.HasValue and optionValue.IsEmpty then
    begin
      AParseResult.AddError(
        Format(SOptValueMissing, [optionName, FNameValueSeparator]));
      Continue;
    end;

    if option.IsOptionFile then
    begin
      if not option.HasValue then
        optionValue := optionName;

      if not FileExists(optionValue) then
      begin
        AParseResult.AddError(Format(SParamFileMissing, [optionValue]));
        Continue;
      end
      else
      begin
        InternalParseFile(optionValue, AParseResult);
        Break; //Option file override all other options; and will stop the parsing.
      end;
    end;

    if not InternalInvokeOption(option, optionName, optionValue, bUseNameAsValue, errStr) then
      AParseResult.AddError(errStr);
  end;
end;

procedure TCmdLineParser.InternalParseFile(const AFileName: string; const AParseResult: IInternalParseResult);
var
  strList: TStringList;
begin
  strList := TStringList.Create;

  try
    strList.LoadFromFile(AFileName);
    InternalParse(strList, AParseResult);
  finally
    strList.Free;
  end;
end;

procedure TCmdLineParser.InternalValidate(const AParseResult: IInternalParseResult);
var
  option: IOptionDefinition;
begin
  for option in TOptionsRegistry.DefaultCommand.RegisteredOptions do
  begin
    if option.Required then
      if not (option as IOptionDefinitionInvoke).WasFound then
        AParseResult.AddError(Format(SReqOptMissing, [option.LongName]));
  end;

  for option in TOptionsRegistry.DefaultCommand.RegisteredAnonymousOptions do
  begin
    if option.Required then
    begin
      if not (option as IOptionDefinitionInvoke).WasFound then
      begin
        AParseResult.AddError(SReqAnonymousOptMissing);
        Break;
      end;
    end;
  end;

  if Assigned(AParseResult.Command) then
  begin
    for option in AParseResult.Command.RegisteredOptions do
    begin
      if option.Required then
      begin
        if not (option as IOptionDefinitionInvoke).WasFound then
          AParseResult.AddError(Format(SReqOptMissing, [option.LongName]));
      end;
    end;
  end;
end;

function TCmdLineParser.Parse: ICmdLineParseResult;
var
  strList: TStringList;
  I: Integer;
begin
  strList := TStringList.Create;
  FAnonymousIndex := 0;

  try
    if ParamCount > 0 then
    begin
      for I := 1 to ParamCount do
        strList.Add(ParamStr(I)); // Excluding ParamStr(0)
    end;

    Result := Self.Parse(strList);
  finally
    strList.Free;
  end;
end;

function TCmdLineParser.Parse(const ACmdLineStrs: TStrings): ICmdLineParseResult;
begin
  Result := TCmdLineParseResult.Create;
  InternalParse(ACmdLineStrs, Result as IInternalParseResult);
  InternalValidate(Result as IInternalParseResult);
end;

function TCmdLineParser.TryGetCommand(const ACmdName: string; var ACmd: ICommandDefinition): Boolean;
begin
  Result := TOptionsRegistry.RegisteredCommands.TryGetValue(LowerCase(ACmdName), ACmd);
end;

function TCmdLineParser.TryGetOption(const ACurCmd: ICommandDefinition; const ADefCmd: ICommandDefinition; const AOptionName: string; var AOption: IOptionDefinition): Boolean;
begin
  if not Assigned(AOption) then
  begin
    if not ACurCmd.TryGetOption(LowerCase(AOptionName), AOption) then
    begin
      if not ACurCmd.IsDefault then
        // Last resort to find an option.
        ADefCmd.TryGetOption(LowerCase(AOptionName), AOption)
    end;
  end;

  Result := Assigned(AOption);
end;

constructor TCmdLineParseResult.Create;
begin
  FErrors := TStringList.Create;
  FCommand := nil;
end;

destructor TCmdLineParseResult.Destroy;
begin
  FErrors.Free;
  inherited;
end;

procedure TCmdLineParseResult.AddError(const aErrStr: string);
begin
  FErrors.Add(aErrStr)
end;

function TCmdLineParseResult.get_Command: ICommandDefinition;
begin
  Result := FCommand;
end;

function TCmdLineParseResult.get_CommandName: string;
begin
  if Assigned(FCommand) then
    Result := FCommand.Name
  else
    Result := EmptyStr;
end;

function TCmdLineParseResult.get_ErrorText: string;
begin
  Result := FErrors.Text;
end;

function TCmdLineParseResult.get_HasErrors: Boolean;
begin
  Result := FErrors.Count > 0;
end;

procedure TCmdLineParseResult.SetCommand(const ACmd: ICommandDefinition);
begin
  FCommand := ACmd;
end;

end.
