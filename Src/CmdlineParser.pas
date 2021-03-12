{***************************************************************************}
{                                                                           }
{           Command Line Parser                                             }
{           Copyright (C) 2019-2021 Wuping Xin                              }
{                                                                           }
{           Based on VSoft.CommandLine                                      }
{           Copyright (C) 2014 Vincent Parrett                              }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit CmdlineParser;

interface

uses
  System.Classes, System.TypInfo, Generics.Collections;

type
  {$REGION 'Forward Declaration'}
  ICommandDefinition = interface;
  IOptionDefinition  = interface;
  {$ENDREGION}

  TEnumerateCommandAction
    = reference to procedure(const ACommand: ICommandDefinition);

  TEnumerateCommandOptionsAction
    = reference to procedure(const AOption: IOptionDefinition);

  TOptionParsedAction<T>
    = reference to procedure(const AValue: T);

  TPrintUsageAction
    = reference to procedure(const AText: String);

  IOptionDefinition = interface
    ['{1EAA06BA-8FBF-43F8-86D7-9F5DE26C4E86}']
    {$REGION 'Property Gettors and Settors'}
    function Get_HelpText: String;
    procedure Set_HelpText(const AValue: String);
    function Get_IsAnonymous: Boolean;
    function Get_IsOptionFile: Boolean;
    procedure Set_IsOptionFile(const AValue: Boolean);
    function Get_LongName: String;
    function Get_Name: String;
    function Get_Required: Boolean;
    procedure Set_Required(const AValue: Boolean);
    function Get_RequiresValue: Boolean;
    procedure Set_RequiresValue(const AValue: Boolean);
    function Get_ShortName: String;
    {$ENDREGION}
    property HelpText: String read Get_HelpText write Set_HelpText;
    property IsAnonymous: Boolean read Get_IsAnonymous;
    property IsOptionFile: Boolean read Get_IsOptionFile write Set_IsOptionFile;
    property LongName: String read Get_LongName;
    property Name: String read Get_Name;
    property Required: Boolean read Get_Required write Set_Required;
    property RequiresValue: Boolean read Get_RequiresValue write Set_RequiresValue;
    property ShortName: String read Get_ShortName;
  end;

  IOptionDefinitionInvoke = interface
    ['{580B5B40-CD7B-41B8-AE53-2C6890141FF0}']
    function GetTypeInfo: PTypeInfo;
    procedure Invoke(const AValue: String);
    function WasFound: Boolean;
  end;

  ICommandDefinition = interface
    ['{58199FE2-19DF-4F9B-894F-BD1C5B62E0CB}']
    {$REGION 'Property Gettors and Settors'}
    function Get_Alias: String;
    function Get_Description: String;
    function Get_HelpText: String;
    function Get_IsDefault: Boolean;
    function Get_Name: String;
    function Get_RegisteredAnonymousOptions: TList<IOptionDefinition>;
    function Get_RegisteredNamedOptions: TList<IOptionDefinition>;
    function Get_Usage: String;
    function Get_Visible: Boolean;
    {$ENDREGION}
    procedure AddOption(const aOption: IOptionDefinition);
    procedure Clear;
    procedure EnumerateNamedOptions(const AProc: TEnumerateCommandOptionsAction); overload;
    procedure GetAllRegisteredOptions(const AResult: TList<IOptionDefinition>);
    function HasOption(const AName: String): Boolean;
    function TryGetOption(const AName: String; var aOption: IOptionDefinition): Boolean;
    { Properties }
    property Alias: String read Get_Alias;
    property Description: String read Get_Description;
    property HelpText: String read Get_HelpText;
    property IsDefault: Boolean read Get_IsDefault;
    property Name: String read Get_Name;
    property RegisteredAnonymousOptions: TList<IOptionDefinition> read Get_RegisteredAnonymousOptions;
    property RegisteredNamedOptions: TList<IOptionDefinition> read Get_RegisteredNamedOptions;
    property Usage: String read Get_Usage;
    property Visible: Boolean read Get_Visible;
  end;

  ICmdlineParseResult = interface
    ['{1715B9FF-8A34-47C9-843E-619C5AEA3F32}']
    {$REGION 'Property Gettors and Settors'}
    function Get_CommandName: String;
    function Get_ErrorText: String;
    function Get_HasErrors: Boolean;
    {$ENDREGION}
    { Properties }
    property CommandName: String read Get_CommandName;
    property ErrorText: String read Get_ErrorText;
    property HasErrors: Boolean read Get_HasErrors;
  end;

  TCommandDefinitionHelper = record
  strict private
    FCommand: ICommandDefinition;
    {$REGION 'Property Gettors and Settors'}
    function Get_Alias: String;
    function Get_Description: String;
    function Get_Name: String;
    function Get_Usage: String;
    {$ENDREGION}
  public
    constructor Create(const ACommand: ICommandDefinition);
    function HasOption(const AOptionName: String): Boolean;

    function RegisterAnonymousOption<T>(const AHelp: String; const AAction: TOptionParsedAction<T>): IOptionDefinition; overload;
    function RegisterOption<T>(const ALongName, AShortName, AHelp: String; const AAction: TOptionParsedAction<T>): IOptionDefinition; overload;
    function RegisterOption<T>(const ALongName, AShortName: String; const AAction: TOptionParsedAction<T>): IOptionDefinition; overload;
    function RegisterOption<T>(const ALongName: String; const AAction: TOptionParsedAction<T>): IOptionDefinition; overload;

    { Properties }
    property Alias: String read Get_Alias;
    property Command: ICommandDefinition read FCommand;
    property Description: String read Get_Description;
    property Name: String read Get_Name;
    property Usage: String read Get_Usage;
  end;

  TOptionDefinition<T> = class(TInterfacedObject, IOptionDefinition, IOptionDefinitionInvoke)
  strict private
    FDefault: T;
    FHelpText: String;
    FIsOptionFile: Boolean;
    FLongName: String;
    FProc: TOptionParsedAction<T>;
    FRequired: Boolean;
    FRequiresValue: Boolean;
    FShortName: String;
    FTypeInfo: PTypeInfo;
    FWasFound: Boolean;
    {$REGION 'Property Gettors and Settors'}
    function Get_HelpText: String;
    procedure Set_HelpText(const AValue: String);
    function Get_IsAnonymous: Boolean;
    function Get_IsOptionFile: Boolean;
    procedure Set_IsOptionFile(const AValue: Boolean);
    function Get_LongName: String;
    function Get_Name: String;
    function Get_Required: Boolean;
    procedure Set_Required(const AValue: Boolean);
    function Get_RequiresValue: Boolean;
    procedure Set_RequiresValue(const AValue: Boolean);
    function Get_ShortName: String;
    {$ENDREGION}
  strict private
    function OptionValueStrToTypedValue(const AValueStr: String): T;
    procedure InitOptionDefaultValue;
  strict protected
    function GetTypeInfo: PTypeInfo;
    procedure Invoke(const AValueStr: String);
    function WasFound: Boolean;
  public
    constructor Create(const ALongName, AShortName, AHelp: String; const AProc: TOptionParsedAction<T>); overload;
    constructor Create(const ALongName, AShortName: String; const AProc: TOptionParsedAction<T>); overload;

    { Properties }
    property HelpText: String read Get_HelpText write Set_HelpText;
    property IsAnonymous: Boolean read Get_IsAnonymous;
    property IsOptionFile: Boolean read Get_IsOptionFile write Set_IsOptionFile;
    property LongName: String read Get_LongName;
    property Name: String read Get_Name;
    property Required: Boolean read Get_Required write Set_Required;
    property RequiresValue: Boolean read Get_RequiresValue write Set_RequiresValue;
    property ShortName: String read Get_ShortName;
  end;

  TOptionsRegistry = class
  strict private class var
    FCommands: TDictionary<String, ICommandDefinition>;
    FConsoleWidth: Integer;
    FDefaultCommandHelper: TCommandDefinitionHelper;
    FDescriptionTabSize: Integer;
    FNameValueSeparator: String;
  strict private
    class constructor Create;
    class destructor Destroy;
    {$REGION 'Property Gettors and Settors'}
    class function Get_DefaultCommand: ICommandDefinition; static;
    {$ENDREGION}
  public
    class procedure Clear;
    class procedure EmumerateCommandOptions(const ACommandName: String; const AProc: TEnumerateCommandOptionsAction); overload;
    class procedure EnumerateCommands(const AProc: TEnumerateCommandAction); overload;
    class function GetCommandByName(const AName: String): ICommandDefinition;

    class function Parse: ICmdLineParseResult; overload;
    class function Parse(const ACmdLine: TStrings): ICmdLineParseResult; overload;

    class procedure PrintUsage(const ACommandName: String; const AProc: TPrintUsageAction); overload;
    class procedure PrintUsage(const ACommand: ICommandDefinition; const AProc: TPrintUsageAction); overload;
    class procedure PrintUsage(const AProc: TPrintUsageAction); overload;

    class function RegisterCommand(const AName: String; const AAlias: String; const ADescription: String; const AHelpText: String;
      const AUsage: String; const AVisible: Boolean = True): TCommandDefinitionHelper;

    class function RegisterAnonymousOption<T>(const AHelpText: String; const AAction: TOptionParsedAction<T>): IOptionDefinition;

    class function RegisterOption<T>(const ALongName: String; const AShortName: String; const AHelp: String;
      const AAction: TOptionParsedAction<T>): IOptionDefinition; overload;

    class function RegisterOption<T>(const ALongName: String; const AShortName: String;
      const AAction: TOptionParsedAction<T>): IOptionDefinition; overload;

    class function RegisterOption<T>(const ALongName: String; const AAction: TOptionParsedAction<T>): IOptionDefinition; overload;

    { Properties }
    class property DefaultCommand: ICommandDefinition read Get_DefaultCommand;
    class property DescriptionTabSize: Integer read FDescriptionTabSize write FDescriptionTabSize;
    class property NameValueSeparator: String read FNameValueSeparator write FNameValueSeparator;
    class property RegisteredCommands: TDictionary<String, ICommandDefinition> read FCommands;
  end;

{$REGION 'Utility Functions'}
function GetConsoleWidth: Integer;

/// <summary>
///   Split a given text into array of strings, each string not exceeding a maximum number of characters.
/// </summary>
/// <param name="AText">
///   The given text.
/// </param>
/// <param name="AMaxLen">
///   Maximum number of characters of each string.
/// </param>
function SplitText(const AText: String; const AMaxLen: Integer): TArray<String>;

/// <summary>
///   Split a given string into array of strings; each string element not exceeding maximum number of
///   characters.
/// </summary>
/// <param name="ALen">
///   Length of the division.
/// </param>
/// <param name="ASrcStr">
///   Source string to be divided.
/// </param>
function SplitStringAt(const ALen: Integer; const ASrcStr: String): TArray<String>;

/// <summary>
///   Convert a Boolean compatible string to Boolean type.
/// </summary>
/// <param name="AValue">
///   A Boolean compatible string.
/// </param>
function StringToBoolean(const AValue: String): Boolean;

/// <summary>
///   Strip quote char from the given string. Quote char include single quote or double quote.
/// </summary>
/// <param name="AStr">
///   A string to strip quote char at two ends.
/// </param>
procedure StripQuotes(var AStr: String);
{$ENDREGION}

const
  DefaultDescriptionTabSize = 15;
  ShortNameExtraSpaceSize   = 5;

const
  OptionTokens: array [1 .. 4] of String = ('--', '-', '/', '@');

const
  SErrParsingParamFile
    = 'Error parsing parameter file [%s]: %s';
  SErrSettingOption
    = 'Error setting option: %s to %s: %s';
  SGlobalOptionText
    = 'global optoins: ';
  SInvalidEnumValue
    = 'Invalid enum value: %s.';
  SOptionNameDuplicated
    = 'Option: %s already registered';
  SOptions
    = 'options: ';
  SParamFileMissing
    = 'Parameter file [%s] does not exist.';
  SRequiredNamedOptionMissing
    = 'Required option missing: [%s].';
  SRequiredAnonymousOptionMissing
    = 'Required anonymous option missing.';
  StrBoolean
    = 'Boolean';
  SUnknownCommand
    = 'Unknown command: %s.';
  SUnknownOption
    = 'Unknown option: %s.';
  SUnknownAnonymousOption
    = 'Unknown anonymous option: %s.';
  SUsage
    = 'usage: ';
  SCommandNameMissing
    = 'Command name required';
  SOptionNameMissing
    = 'Option name required - use RegisterAnonymousOption for unnamed options.';
  SInvalidOptionType
    = 'Invalid option type: only string, integer, float, boolean, enum and set types are supported.';
  SOptionValueMissing
    = 'Option [%s] expects a <value> following %s, but none was found.';

const
  TrueStrings: array [0 .. 10] of String = ('True', 'T', '+', 'Yes', 'Y', 'On',
    'Enable', 'Enabled', '1', '-1', '');
  FalseStrings: array [0 .. 8] of String = ('False', 'F', '-', 'No', 'N', 'Off',
    'Disable', 'Disabled', '0');

implementation

uses
{$IFDEF MSWINDOWS}
  WinApi.Windows,
{$ENDIF}
  Generics.Defaults,
  System.Rtti,
  System.StrUtils,
  System.SysUtils;

function SplitStringAt(const ALen: Integer; const ASrcStr: String): TArray<String>;
begin
  SetLength(Result, 0);
  var LSrcLen := Length(ASrcStr);

  if LSrcLen < ALen then
  begin
    SetLength(Result, 1);
    Result[0] := ASrcStr;
    Exit;
  end;

  var LIndex := 1;
  var LCount := 0;

  while LIndex <= LSrcLen do
  begin
    Inc(LCount);
    SetLength(Result, LCount);
    Result[LCount - 1] := Copy(ASrcStr, LIndex, ALen);
    Inc(LIndex, ALen);
  end;
end;

function SplitText(const AText: String; const AMaxLen: Integer): TArray<String>;
begin
  SetLength(Result, 0);

  // Otherwise a CRLF will result in two lines.
  var LText := StringReplace(AText, sLineBreak, #13, [rfReplaceAll]);

  // Splits at each CR *and* each LF! Delimiters denotes set of single characters used to
  // split string. Each character in Delimiters string will be used as one of possible
  // delimiters.
  var LLines := SplitString(LText, #13#10);
  var K := 0;

  for var I := 0 to Length(LLines) - 1 do
  begin
    var LStrs := SplitStringAt(AMaxLen, LLines[I]);

    Inc(K, Length(LStrs));
    SetLength(Result, K);

    for var J := 0 to Length(LStrs) - 1 do
      Result[K - Length(LStrs) + J] := LStrs[J];
  end;
end;

{$IFDEF MSWINDOWS}
function GetConsoleWidth: Integer;
var
  LStdOutputHandle: THandle;
  LConcoleScreenInfo: CONSOLE_SCREEN_BUFFER_INFO;
begin
  // Default is unlimited width
  Result := High(Integer);
  LStdOutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);

  if GetConsoleScreenBufferInfo(LStdOutputHandle, LConcoleScreenInfo) then
    Result := LConcoleScreenInfo.dwSize.X;
end;
{$ENDIF}

{$IFDEF MACOS}
function GetConsoleWidth: Integer;
const
  kDefaultWidth = 80;
begin
  Result := kDefaultWidth;
end;
{$ENDIF}

function StringToBoolean(const AValue: String): Boolean;
const
  sInvalidBooleanStr = 'Invalid string, not Boolean compliant.';
begin
  if MatchText(AValue, TrueStrings) then
    Result := True
  else if MatchText(AValue, FalseStrings) then
    Result := False
  else
    raise Exception.Create(sInvalidBooleanStr);
end;

procedure StripQuotes(var AStr: String);
const
  kMinStrLen    = 2;
  kQuoteCharSet = ['''', '"'];
begin
  var LStrLen := Length(AStr);

  if LStrLen < kMinStrLen then
    Exit;

  if CharInSet(AStr[1], kQuoteCharSet) and CharInSet(AStr[LStrLen], kQuoteCharSet) then
  begin
    Delete(AStr, LStrLen, 1);
    Delete(AStr, 1, 1);
  end;
end;

type
  ICmdlineParser = interface
    ['{6F970026-D1EE-4A3E-8A99-300AD3EE9C33}']
    function Parse: ICmdlineParseResult; overload;
    function Parse(const AValues: TStrings): ICmdlineParseResult; overload;
  end;

  IInternalParseResult = interface
    ['{9EADABED-511B-4095-9ACA-A5E431AB653D}']
    procedure AddError(const AError: String);
    procedure SetCommand(const ACommand: ICommandDefinition);
    function Get_Command: ICommandDefinition;
    { Properties }
    property Command: ICommandDefinition read Get_Command;
  end;

  TCommandDefinitionCreateParams = record
    Alias: String;
    Description: String;
    HelpText: String;
    IsDefault: Boolean;
    Name: String;
    Usage: String;
    Visible: Boolean;
  end;

  TCommandDefinition = class(TInterfacedObject, ICommandDefinition)
  private
    FAlias: String;
    FDescription: String;
    FHelpText: String;
    FIsDefault: Boolean;
    FName: String;
    FRegisteredAnonymousOptions: TList<IOptionDefinition>;
    FRegisteredNamedOptions: TList<IOptionDefinition>;
    FRegisteredNamedOptionsDictionary: TDictionary<String, IOptionDefinition>;
    FUsage: String;
    FVisible: Boolean;
    {$REGION 'Property Gettors and Settors'}
    function Get_Alias: String;
    function Get_Description: String;
    function Get_HelpText: String;
    function Get_IsDefault: Boolean;
    function Get_Name: String;
    function Get_RegisteredAnonymousOptions: TList<IOptionDefinition>;
    function Get_RegisteredNamedOptions: TList<IOptionDefinition>;
    function Get_Usage: String;
    function Get_Visible: Boolean;
    {$ENDREGION}
  protected
    procedure AddOption(const AOption: IOptionDefinition);
    procedure Clear;
    procedure EnumerateNamedOptions(const AProc: TEnumerateCommandOptionsAction);
    procedure GetAllRegisteredOptions(const AResult: TList<IOptionDefinition>);
    function HasOption(const AName: String): Boolean;
    function TryGetOption(const AName: String; var AOption: IOptionDefinition): Boolean;
  public
    constructor Create(const AParams: TCommandDefinitionCreateParams);
    constructor CreateDefault;
    destructor Destroy; override;
    { Properties }
    property Alias: String read Get_Alias;
    property Description: String read Get_Description;
    property HelpText: String read Get_HelpText;
    property IsDefault: Boolean read Get_IsDefault;
    property Name: String read Get_Name;
    property RegisteredAnonymousOptions: TList<IOptionDefinition> read Get_RegisteredAnonymousOptions;
    property RegisteredOptions: TList<IOptionDefinition> read Get_RegisteredNamedOptions;
    property Usage: String read Get_Usage;
    property Visible: Boolean read Get_Visible;
  end;

  TCmdlineParseResult = class(TInterfacedObject, ICmdlineParseResult, IInternalParseResult)
  private
    FCommand: ICommandDefinition;
    FErrors: TStringList;
    {$REGION 'Property Gettors and Settors'}
    procedure AddError(const AError: String);
    procedure SetCommand(const ACommand: ICommandDefinition);
    function Get_Command: ICommandDefinition;
    function Get_CommandName: String;
    function Get_ErrorText: String;
    function Get_HasErrors: Boolean;
    {$ENDREGION}
  public
    constructor Create;
    destructor Destroy; override;

    property Command: ICommandDefinition read Get_Command;
    property CommandName: String read Get_CommandName;
    property ErrorText: String read Get_ErrorText;
    property HasErrors: Boolean read Get_HasErrors;
  end;

  TCmdlineParser = class(TInterfacedObject, ICmdLineParser)
  strict private
    FAnonymousIndex: Integer;
    FNameValueSeparator: String;
    {$REGION 'Private Helper Methods'}
    function ParseCommand(const ACmdlineItem: String; var AActiveCommand: ICommandDefinition;
      const AParseResult: IInternalParseResult): Boolean;

    function ParseOption(const ACmdlineItem: String; const AActiveCommand: ICommandDefinition; out AOption: IOptionDefinition;
      out AOptionValue: String; const AParseResult: IInternalParseResult): Boolean;

    procedure ParseOptionFile(const AFileName: String; const AParseResult: IInternalParseResult);
    function InvokeOption(AOption: IOptionDefinition; const AValue: String; out AErrMsg: String): Boolean;
    function HasOptionToken(var ACmdlineItem: String): Boolean;
    function TryGetCommand(const AName: String; out ACommand: ICommandDefinition): Boolean;

    function TryGetOption(const ACommand, ADefaultCommand: ICommandDefinition; const AOptionName: String;
      out AOption: IOptionDefinition): Boolean;
    {$ENDREGIOn}
  strict protected
    procedure DoParse(const ACmdlineItems: TStrings; const AParseResult: IInternalParseResult); virtual;
    procedure ValidateParseResult(const AParseResult: IInternalParseResult); virtual;
  public
    constructor Create(const aNameValueSeparator: String);
    destructor Destroy; override;
    function Parse: ICmdlineParseResult; overload;
    function Parse(const ACmdlineItems: TStrings): ICmdlineParseResult; overload;
  end;

class constructor TOptionsRegistry.Create;
begin
  FDefaultCommandHelper := TCommandDefinitionHelper.Create(TCommandDefinition.CreateDefault);
  FCommands := TDictionary<String, ICommandDefinition>.Create;
  FNameValueSeparator := ':';  // Default separator.
  FDescriptionTabSize := DefaultDescriptionTabSize;
  FConsoleWidth := GetConsoleWidth; // This is a system function.
end;

class destructor TOptionsRegistry.Destroy;
begin
  FCommands.Free;
end;

class procedure TOptionsRegistry.Clear;
begin
  FDefaultCommandHelper.Command.Clear;
  FCommands.Clear;
end;

class procedure TOptionsRegistry.EmumerateCommandOptions(const ACommandName: String; const AProc: TEnumerateCommandOptionsAction);
var
  LCommand: ICommandDefinition;
begin
  if not FCommands.TryGetValue(ACommandName, LCommand) then
    raise Exception.Create(Format(SUnknownCommand, [ACommandName]));

  LCommand.EnumerateNamedOptions(AProc);
end;

class procedure TOptionsRegistry.EnumerateCommands(const AProc: TEnumerateCommandAction);
var
  LCommand: ICommandDefinition;
begin
  var LCommands := TList<ICommandDefinition>.Create;

  try
    for LCommand in FCommands.Values do
      if LCommand.Visible then LCommands.Add(LCommand);

    LCommands.Sort(TComparer<ICommandDefinition>.Construct(
      function(const L, R: ICommandDefinition): Integer
      begin
        Result := CompareText(L.Name, R.Name);
      end)
    );

    for LCommand in LCommands do AProc(LCommand);
  finally
    LCommands.Free;
  end;
end;

class function TOptionsRegistry.GetCommandByName(const AName: String): ICommandDefinition;
begin
  Result := nil;
  FCommands.TryGetValue(AName.ToLower, Result);
end;

class function TOptionsRegistry.Get_DefaultCommand: ICommandDefinition;
begin
  Result := TOptionsRegistry.FDefaultCommandHelper.Command;
end;

class function TOptionsRegistry.Parse: ICmdLineParseResult;
begin
  var LParser: ICmdlineParser := TCmdlineParser.Create(NameValueSeparator);
  Result := LParser.Parse;
end;

class function TOptionsRegistry.Parse(const ACmdLine: TStrings): ICmdLineParseResult;
begin
  var LParser: ICmdlineParser := TCmdlineParser.Create(NameValueSeparator);
  Result := LParser.Parse(ACmdLine);
end;

class procedure TOptionsRegistry.PrintUsage(const ACommandName: String; const AProc: TPrintUsageAction);
begin
  if ACommandName = '' then
  begin
    PrintUsage(AProc);
    Exit;
  end;

  var LCommand: ICommandDefinition;

  if not FCommands.TryGetValue(LowerCase(ACommandName), LCommand) then
  begin
    AProc(Format(SUnknownCommand, [ACommandName]));
    Exit;
  end;

  PrintUsage(LCommand, AProc);
end;

class procedure TOptionsRegistry.PrintUsage(const ACommand: ICommandDefinition; const AProc: TPrintUsageAction);
begin
  if not ACommand.IsDefault then
  begin
    AProc(SUsage + ACommand.Usage);
    AProc('');
    AProc(ACommand.Description);

    if ACommand.HelpText <> '' then
    begin
      AProc('');
      AProc('   ' + ACommand.HelpText);
    end;

    AProc('');
    AProc(SOptions);
    AProc('');
  end else
  begin
    AProc('');

    if FCommands.Count > 0 then
      AProc(SGlobalOptionText)
    else
      AProc(SOptions);

    AProc('');
  end;

  var LMaxDescWidth: Integer;
  if FConsoleWidth < High(Integer) then
    LMaxDescWidth := FConsoleWidth
  else
    LMaxDescWidth := High(Integer);

  LMaxDescWidth := LMaxDescWidth - FDescriptionTabSize;

  ACommand.EnumerateNamedOptions(
    procedure(const aOption: IOptionDefinition)
    begin
      var al := Length(aOption.ShortName);
      if al <> 0 then
        Inc(al, ShortNameExtraSpaceSize); // add brackets (- ) and 2 spaces;

      var s := ' -' + aOption.LongName.PadRight(DescriptionTabSize - 1 - al);
      if al > 0 then
        s := s + '(-' + aOption.ShortName + ')' + '  ';

      var descStrings := SplitText(aOption.HelpText, LMaxDescWidth);
      s := s + descStrings[0];
      AProc(s);

      var numDescStrings := Length(descStrings);
      if numDescStrings > 1 then
        for var I := 1 to numDescStrings - 1 do
          AProc(''.PadRight(DescriptionTabSize + 1) + descStrings[I]);
    end
  );
end;

class procedure TOptionsRegistry.PrintUsage(const AProc: TPrintUsageAction);
begin
  AProc('');

  if FCommands.Count > 0 then
  begin
    var LMaxDescWidth: Integer;
    if FConsoleWidth < High(Integer) then
      LMaxDescWidth := FConsoleWidth
    else
      LMaxDescWidth := High(Integer);

    LMaxDescWidth := LMaxDescWidth - FDescriptionTabSize;

    for var LCommand in FCommands.Values do
    begin
      if LCommand.Visible then
      begin
        var LDescStrings := SplitText(LCommand.Description, LMaxDescWidth);
        AProc(' ' + LCommand.Name.PadRight(DescriptionTabSize - 1) + LDescStrings[0]);

        var LNumDescStrings := Length(LDescStrings);
        if LNumDescStrings > 1 then
          for var I := 1 to LNumDescStrings - 1 do
            AProc(''.PadRight(DescriptionTabSize) + LDescStrings[I]);

        AProc('');
      end;
    end;
  end;

  PrintUsage(FDefaultCommandHelper.Command, AProc);
end;

class function TOptionsRegistry.RegisterAnonymousOption<T>(const AHelpText: String; const AAction: TOptionParsedAction<T>): IOptionDefinition;
begin
  Result := FDefaultCommandHelper.RegisterAnonymousOption<T>(AHelpText, AAction);
end;

class function TOptionsRegistry.RegisterCommand(const AName, AAlias, ADescription, AHelpText, AUsage: String;
  const AVisible: Boolean = True): TCommandDefinitionHelper;
begin
  if Aname.IsEmpty then
    raise EArgumentException.Create(SCommandNameMissing);

  var LParams: TCommandDefinitionCreateParams;
  with LParams do
  begin
    Alias := AAlias;
    Description := ADescription;
    HelpText := AHelpText;
    IsDefault := False; // Always false.  Only one default command.
    Name := AName;
    Usage := AUsage;
    Visible := AVisible;
  end;

  var LCommand: ICommandDefinition := TCommandDefinition.Create(LParams);
  FCommands.Add(AName.ToLower, LCommand);
  Result := TCommandDefinitionHelper.Create(LCommand);
end;

class function TOptionsRegistry.RegisterOption<T>(const ALongName, AShortName, AHelp: String; const AAction: TOptionParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(ALongName, AShortName, AAction);
  Result.HelpText := AHelp;
end;

class function TOptionsRegistry.RegisterOption<T>(const ALongName, AShortName: String; const AAction: TOptionParsedAction<T>): IOptionDefinition;
begin
  Result := FDefaultCommandHelper.RegisterOption<T>(ALongName, AShortName, AAction);
end;

class function TOptionsRegistry.RegisterOption<T>(const ALongName: String; const AAction: TOptionParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(ALongName, '', AAction);
end;

constructor TCommandDefinitionHelper.Create(const ACommand: ICommandDefinition);
begin
  FCommand := ACommand;
end;

function TCommandDefinitionHelper.Get_Alias: String;
begin
  Result := FCommand.Alias;
end;

function TCommandDefinitionHelper.Get_Description: String;
begin
  Result := FCommand.Description;
end;

function TCommandDefinitionHelper.Get_Name: String;
begin
  Result := FCommand.Name;
end;

function TCommandDefinitionHelper.Get_Usage: String;
begin
  Result := FCommand.Usage;
end;

function TCommandDefinitionHelper.HasOption(const AOptionName: String): Boolean;
begin
  Result := FCommand.HasOption(AOptionName);
end;

function TCommandDefinitionHelper.RegisterAnonymousOption<T>(const AHelp: String; const AAction: TOptionParsedAction<T>): IOptionDefinition;
begin
  Result := TOptionDefinition<T>.Create('', '', AHelp, AAction);
  Result.RequiresValue := False;
  FCommand.AddOption(Result);
end;

function TCommandDefinitionHelper.RegisterOption<T>(const ALongName, AShortName, AHelp: String; const AAction: TOptionParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(ALongName, AShortName, AAction);
  Result.HelpText := AHelp;
end;

function TCommandDefinitionHelper.RegisterOption<T>(const ALongName, AShortName: String; const AAction: TOptionParsedAction<T>): IOptionDefinition;
begin
  if ALongName.IsEmpty then
    raise EArgumentException.Create(SOptionNameMissing);

  if FCommand.HasOption(LowerCase(ALongName)) then
    raise EArgumentException.Create(Format(SOptionNameDuplicated, [ALongName]));

  if FCommand.HasOption(LowerCase(AShortName)) then
    raise EArgumentException.Create(Format(SOptionNameDuplicated, [AShortName]));

  Result := TOptionDefinition<T>.Create(ALongName, AShortName, AAction);
  FCommand.AddOption(Result);
end;

function TCommandDefinitionHelper.RegisterOption<T>(const ALongName: String; const AAction: TOptionParsedAction<T>): IOptionDefinition;
begin
  Result := RegisterOption<T>(ALongName, '', AAction);
end;

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

  FRegisteredNamedOptionsDictionary := TDictionary<String, IOptionDefinition>.Create;
  FRegisteredNamedOptions := TList<IOptionDefinition>.Create;
  FRegisteredAnonymousOptions := TList<IOptionDefinition>.Create;
end;

constructor TCommandDefinition.CreateDefault;
var
  LParams: TCommandDefinitionCreateParams;
begin
  with LParams do
  begin
    Alias := EmptyStr;        // Empty
    Description := EmptyStr;  // Empty
    HelpText := EmptyStr;     // Empty
    IsDefault := True;        // Default is always True.
    Name := EmptyStr;         // Anonymous command, as default.
    Usage := EmptyStr;        // Global default commdn, no usage string.
    Visible := False;         // Always invisible.
  end;

  Create(LParams);
end;

destructor TCommandDefinition.Destroy;
begin
  FRegisteredNamedOptionsDictionary.Free;
  FRegisteredAnonymousOptions.Free;
  FRegisteredNamedOptions.Free;
  inherited;
end;

// Will be called only after HasOption is checked by TCommandDefintionHelper.
// HasOption must return False before proceeding to AddOption.
procedure TCommandDefinition.AddOption(const AOption: IOptionDefinition);
begin
  if AOption.IsAnonymous then
  begin
    FRegisteredAnonymousOptions.Add(AOption);
  end else
  begin
    FRegisteredNamedOptions.Add(AOption);
    FRegisteredNamedOptionsDictionary.AddOrSetValue(LowerCase(AOption.LongName), AOption);
    // Add short name to the dictionary too, if not empty.
    if not AOption.ShortName.IsEmpty then
      FRegisteredNamedOptionsDictionary.AddOrSetValue(LowerCase(AOption.ShortName), AOption);
  end;
end;

procedure TCommandDefinition.Clear;
begin
  FRegisteredNamedOptionsDictionary.Clear;
  FRegisteredNamedOptions.Clear;
  FRegisteredAnonymousOptions.Clear;
end;

procedure TCommandDefinition.EnumerateNamedOptions(const AProc: TEnumerateCommandOptionsAction);
begin
  var LNamedOptions := TList<IOptionDefinition>.Create(FRegisteredNamedOptions);

  try
    LNamedOptions.Sort(TComparer<IOptionDefinition>.Construct(
      function(const L, R: IOptionDefinition): Integer
      begin
        Result := CompareText(L.LongName, R.LongName); // Longname is garantteed to be not empty.
      end)
    );

    for var o in LNamedOptions do
      AProc(o);
  finally
    LNamedOptions.Free;
  end;
end;

procedure TCommandDefinition.GetAllRegisteredOptions(const AResult: TList<IOptionDefinition>);
begin
  AResult.AddRange(FRegisteredAnonymousOptions);
  AResult.AddRange(FRegisteredNamedOptions);
end;

function TCommandDefinition.Get_Alias: String;
begin
  Result := FAlias;
end;

function TCommandDefinition.Get_Description: String;
begin
  Result := FDescription;
end;

function TCommandDefinition.Get_HelpText: String;
begin
  Result := FHelpText;
end;

function TCommandDefinition.Get_IsDefault: Boolean;
begin
  Result := FIsDefault;
end;

function TCommandDefinition.Get_Name: String;
begin
  Result := FName;
end;

function TCommandDefinition.Get_RegisteredAnonymousOptions: TList<IOptionDefinition>;
begin
  Result := FRegisteredAnonymousOptions;
end;

function TCommandDefinition.Get_RegisteredNamedOptions: TList<IOptionDefinition>;
begin
  Result := FRegisteredNamedOptions;
end;

function TCommandDefinition.Get_Usage: String;
begin
  Result := FUsage;
end;

function TCommandDefinition.Get_Visible: Boolean;
begin
  Result := FVisible;
end;

function TCommandDefinition.HasOption(const AName: String): Boolean;
begin
  Result := FRegisteredNamedOptionsDictionary.ContainsKey(LowerCase(AName));
end;

function TCommandDefinition.TryGetOption(const AName: String; var AOption: IOptionDefinition): Boolean;
begin
  Result := FRegisteredNamedOptionsDictionary.TryGetValue(LowerCase(AName), AOption);
end;

constructor TOptionDefinition<T>.Create(const ALongName, AShortName, AHelp: String; const AProc: TOptionParsedAction<T>);
begin
  Create(ALongName, AShortName, AProc);
  FHelpText := AHelp;
end;

constructor TOptionDefinition<T>.Create(const ALongName, AShortName: String; const AProc: TOptionParsedAction<T>);
const
  kAllowedTypeKinds: set of TTypeKind = [tkInteger, tkEnumeration, tkFloat, tkString, tkSet,
    tkLString, tkWString, tkInt64, tkUString];
begin
  FTypeInfo := TypeInfo(T);

  if not (FTypeInfo.Kind in kAllowedTypeKinds) then
    raise EArgumentException.Create(SInvalidOptionType);

  FLongName := ALongName;   // If long name is empty, then the option is anonymous.
  FShortName := AShortName;
  FProc := AProc;
  FRequiresValue := True;   // Default is True, a value is required.
  FIsOptionFile := False;   // Default is False, not an option file.
  FRequired := False;       // Default is False, not a required option.
  // Initialize the default value.
  InitOptionDefaultValue;
end;

function TOptionDefinition<T>.GetTypeInfo: PTypeInfo;
begin
  Result := FTypeInfo;
end;

function TOptionDefinition<T>.Get_RequiresValue: Boolean;
begin
  Result := FRequiresValue;
end;

function TOptionDefinition<T>.Get_HelpText: String;
begin
  Result := FHelpText;
end;

function TOptionDefinition<T>.Get_IsAnonymous: Boolean;
begin
  Result := FLongName.IsEmpty;
end;

function TOptionDefinition<T>.Get_IsOptionFile: Boolean;
begin
  Result := FIsOptionFile;
end;

function TOptionDefinition<T>.Get_LongName: String;
begin
  Result := FLongName;
end;

function TOptionDefinition<T>.Get_Name: String;
const
  sAnonymousOptionName = 'unnamed';
begin
  if IsAnonymous then
    Result := sAnonymousOptionName
  else
    Result := Format('%s(%s)', [LongName, ShortName]);
end;

function TOptionDefinition<T>.Get_Required: Boolean;
begin
  // Anonymous option always required in order to enforce their positions.
  Result := FRequired or IsAnonymous;
end;

function TOptionDefinition<T>.Get_ShortName: String;
begin
  Result := FShortName;
end;

procedure TOptionDefinition<T>.InitOptionDefaultValue;
begin
  FDefault := Default (T);
  // Note - the default value for Boolean option is True. If the option name (the flag)
  // appears without a value, by default it will be treated as True.
  if not FRequiresValue and (FTypeInfo.Name = StrBoolean) then
    FDefault := TValue.FromVariant(True).AsType<T>;
end;

procedure TOptionDefinition<T>.Invoke(const AValueStr: String);
begin
  FWasFound := True;

  if not Assigned(FProc) then
    Exit;

  if AValueStr.IsEmpty then
  begin
    FProc(FDefault);
  end else
  begin
    var LValue:T := OptionValueStrToTypedValue(AValueStr);
    FProc(LValue);
  end;
end;

function TOptionDefinition<T>.OptionValueStrToTypedValue(const AValueStr: String): T;
var
  LValue: TValue;
begin
  case FTypeInfo.Kind of
    tkInteger:
      begin
        var LIntVal := StrToInt(AValueStr);
        LValue := TValue.From<Integer>(LIntVal);
      end;

    tkInt64:
      begin
        var LInt64Val := StrToInt64(AValueStr);
        LValue := TValue.From<Int64>(LInt64Val);
      end;

    tkString, tkLString, tkWString, tkUString:
      begin
        LValue := TValue.From<String>(AValueStr);
      end;

    tkSet:
      begin
        var LIntVal := StringToSet(FTypeInfo, AValueStr);
        var LPtr := @LIntVal;
        LValue := TValue.From<T>(T(LPtr^));
      end;

    tkEnumeration:
      begin
        if FTypeInfo.Name = StrBoolean then
        begin
          LValue := TValue.From<Boolean>(StringToBoolean(AValueStr));
        end else
        begin
          var LIntVal := GetEnumValue(FTypeInfo, AValueStr);

          if LIntVal < 0 then
            raise EArgumentException.Create(Format(SInvalidEnumValue, [AValueStr]));

          LValue := TValue.FromOrdinal(FTypeInfo, LIntVal);
        end;
      end;

    tkFloat:
      begin
        var LFloatVal := StrToFloat(AValueStr);
        LValue := TValue.From<Double>(LFloatVal);
      end;
  else
    raise EArgumentException.Create(SInvalidOptionType);
  end;

  Result := LValue.AsType<T>;
end;

procedure TOptionDefinition<T>.Set_RequiresValue(const AValue: Boolean);
begin
  FRequiresValue := AValue;
  InitOptionDefaultValue;
end;

procedure TOptionDefinition<T>.Set_HelpText(const AValue: String);
begin
  FHelpText := AValue;
end;

procedure TOptionDefinition<T>.Set_IsOptionFile(const AValue: Boolean);
begin
  FIsOptionFile := AValue;
end;

procedure TOptionDefinition<T>.Set_Required(const AValue: Boolean);
begin
  FRequired := AValue;
end;

function TOptionDefinition<T>.WasFound: Boolean;
begin
  Result := FWasFound;
end;

constructor TCmdlineParser.Create(const aNameValueSeparator: String);
begin
  inherited Create;
  FAnonymousIndex := 0;
  FNameValueSeparator := aNameValueSeparator;
end;

destructor TCmdlineParser.Destroy;
begin
  inherited;
end;

procedure TCmdlineParser.DoParse(const ACmdlineItems: TStrings; const AParseResult: IInternalParseResult);
begin
  var LActiveCommand := TOptionsRegistry.DefaultCommand;

  for var I := 0 to ACmdlineItems.Count - 1 do
  begin
    var LCmdlineItem := ACmdlineItems.Strings[I];

    // LCmdlineItem possibly empty, if inside quotes.
    if LCmdlineItem.IsEmpty then
      Continue;

    // Find if a new command appears, if so, set it as currently active command. Returns true if a new command
    // is set as currently active command. And if a new command is found, skip the rest.
    if ParseCommand(LCmdlineItem, LActiveCommand, AParseResult) then
      Continue;

    var LOption: IOptionDefinition;
    var LOptionValue: String;
    if not ParseOption(LCmdlineItem, LActiveCommand, LOption, LOptionValue, AParseResult) then
      Continue;

    if LOption.RequiresValue and LOptionValue.IsEmpty then
    begin
      AParseResult.AddError(Format(SOptionValueMissing, [LOption.Name, FNameValueSeparator]));
      Continue;
    end;

    if LOption.IsOptionFile then
    begin
      if not FileExists(LOptionValue) then
      begin
        AParseResult.AddError(Format(SParamFileMissing, [LOptionValue]));
        Continue;
      end else
      begin
        ParseOptionFile(LOptionValue, AParseResult);
        Break;   // Option file override all other in-line options.
      end;
    end;

    var LErrStr: String;
    if not InvokeOption(LOption, LOptionValue, LErrStr) then
      AParseResult.AddError(LErrStr);
  end;
end;

function TCmdlineParser.HasOptionToken(var ACmdlineItem: String): Boolean;
begin
  Result := False;

  for var token in OptionTokens do
  begin
    if StartsStr(token, ACmdlineItem) then
    begin
      Delete(ACmdlineItem, 1, Length(token));
      Result := True;
      Break;
    end;
  end;
end;

function TCmdlineParser.InvokeOption(AOption: IOptionDefinition; const AValue: String; out AErrMsg: String): Boolean;
begin
  try
    (AOption as IOptionDefinitionInvoke).Invoke(AValue);
    Result := True;
  except
    on E: Exception do
    begin
      Result := False;
      AErrMsg := Format(SErrSettingOption, [AOption.Name, AValue, E.Message]);
    end;
  end;
end;

function TCmdlineParser.Parse: ICmdlineParseResult;
begin
  FAnonymousIndex := 0; // Reset anonymous option position to 0.
  var LCmdlineItems := TStringList.Create;

  try
    if ParamCount > 0 then
    begin
      for var I := 1 to ParamCount do
        LCmdlineItems.Add(ParamStr(I)); // Excluding ParamStr(0)
    end;

    Result := Parse(LCmdlineItems);
  finally
    LCmdlineItems.Free;
  end;
end;

function TCmdlineParser.Parse(const ACmdlineItems: TStrings): ICmdlineParseResult;
begin
  Result := TCmdlineParseResult.Create;
  DoParse(ACmdlineItems, Result as IInternalParseResult);
  ValidateParseResult(Result as IInternalParseResult);
end;

function TCmdlineParser.ParseCommand(const ACmdlineItem: String; var AActiveCommand: ICommandDefinition;
  const AParseResult: IInternalParseResult): Boolean;
begin
  var LCmdlineItem := ACmdlineItem;
  // Check if there is any option token, and strip off if any.
  if HasOptionToken(LCmdlineItem) then
    Exit(False);

  var LNewCommand: ICommandDefinition;
  Result := AActiveCommand.IsDefault and TryGetCommand(ACmdlineItem, LNewCommand);

  if Result then
  begin
    AActiveCommand := LNewCommand;
    FAnonymousIndex := 0;
    AParseResult.SetCommand(AActiveCommand);
  end;
end;

function TCmdlineParser.ParseOption(const ACmdlineItem: String; const AActiveCommand: ICommandDefinition;
  out AOption: IOptionDefinition; out AOptionValue: String; const AParseResult: IInternalParseResult): Boolean;
begin
  var LCmdlineItem := ACmdlineItem;
  // Check if there is any option token, and strip off if any.
  if not HasOptionToken(LCmdlineItem) then
  begin
    // The command line item represents an anonymous option of the currently active command.
    if FAnonymousIndex < AActiveCommand.RegisteredAnonymousOptions.Count then
    begin
      AOption := AActiveCommand.RegisteredAnonymousOptions[FAnonymousIndex];
      Inc(FAnonymousIndex);
      AOptionValue := LCmdlineItem;
      Result := True;
    end else
    begin
      AParseResult.AddError(Format(SUnknownAnonymousOption, [LCmdlineItem]));
      Result := False;
    end;
  end else
  begin
    // The command line item represents a named option
    var LNameValueSeparatorPos := Pos(FNameValueSeparator, LCmdlineItem);
    var LOptionName: String;

    if LNameValueSeparatorPos > 0 then
    begin
      // The named option has a name, and a value.
      LOptionName  := Copy(LCmdlineItem, 1, LNameValueSeparatorPos - 1).Trim;
      AOptionValue := Copy(LCmdlineItem, LNameValueSeparatorPos + Length(FNameValueSeparator), MaxInt).Trim;
      StripQuotes(AOptionValue);
    end else
    begin
      // The named option has a name, without a value.
      LOptionName  := LCmdlineItem;
      AOptionValue := EmptyStr;
    end;

    Result := TryGetOption(AActiveCommand, TOptionsRegistry.DefaultCommand, LOptionName, AOption);

    if not Result then
      AParseResult.AddError(Format(SUnknownOption, [LOptionName]));
  end;
end;

procedure TCmdlineParser.ParseOptionFile(const AFileName: String; const AParseResult: IInternalParseResult);
begin
  var LCmdline := TStringList.Create;

  try
    LCmdline.LoadFromFile(AFileName);
    DoParse(LCmdline, AParseResult);
  finally
    LCmdline.Free;
  end;
end;

function TCmdlineParser.TryGetCommand(const AName: String; out ACommand: ICommandDefinition): Boolean;
begin
  Result := TOptionsRegistry.RegisteredCommands.TryGetValue(LowerCase(AName), ACommand);
end;

function TCmdlineParser.TryGetOption(const ACommand, ADefaultCommand: ICommandDefinition; const AOptionName: String;
  out AOption: IOptionDefinition): Boolean;
begin
  if not ACommand.TryGetOption(LowerCase(AOptionName), AOption) then
  begin
    // Continue to search the option in defaul command.
    if not ACommand.IsDefault then
      ADefaultCommand.TryGetOption(LowerCase(AOptionName), AOption);
  end;

  Result := Assigned(AOption);
end;

procedure TCmdlineParser.ValidateParseResult(const AParseResult: IInternalParseResult);
begin
  for var LOption in TOptionsRegistry.DefaultCommand.RegisteredNamedOptions do
  begin
    if LOption.Required then
    begin
      if not (LOption as IOptionDefinitionInvoke).WasFound then
        AParseResult.AddError(Format(SRequiredNamedOptionMissing, [LOption.LongName]));
    end;
  end;

  for var LOption in TOptionsRegistry.DefaultCommand.RegisteredAnonymousOptions do
  begin
    if LOption.Required then
    begin
      if not (LOption as IOptionDefinitionInvoke).WasFound then
      begin
        AParseResult.AddError(SRequiredAnonymousOptionMissing);
        Break;
      end;
    end;
  end;

  if Assigned(AParseResult.Command) then
  begin
    for var LOption in AParseResult.Command.RegisteredNamedOptions do
    begin
      if LOption.Required then
      begin
        if not (LOption as IOptionDefinitionInvoke).WasFound then
          AParseResult.AddError(Format(SRequiredNamedOptionMissing, [LOption.LongName]));
      end;
    end;
  end;
end;

constructor TCmdlineParseResult.Create;
begin
  FErrors := TStringList.Create;
  FCommand := nil;
end;

destructor TCmdlineParseResult.Destroy;
begin
  FErrors.Free;
  inherited;
end;

procedure TCmdlineParseResult.AddError(const AError: String);
begin
  FErrors.Add(AError)
end;

function TCmdlineParseResult.Get_Command: ICommandDefinition;
begin
  Result := FCommand;
end;

function TCmdlineParseResult.Get_CommandName: String;
begin
  if Assigned(FCommand) then
    Result := FCommand.Name
  else
    Result := EmptyStr;
end;

function TCmdlineParseResult.Get_ErrorText: String;
begin
  Result := FErrors.Text;
end;

function TCmdlineParseResult.Get_HasErrors: Boolean;
begin
  Result := FErrors.Count > 0;
end;

procedure TCmdlineParseResult.SetCommand(const ACommand: ICommandDefinition);
begin
  FCommand := ACommand;
end;

initialization

end.
