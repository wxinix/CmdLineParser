unit CmdLine.Intf;

interface

uses
  System.Classes,
  System.TypInfo,
  Generics.Collections;

type
  TOptionValueParsedAction<T> = reference to procedure(const aValue: T);
  TPrintUsageAction = reference to procedure(const aText: string);

  IOptionDefinition = interface
    ['{1EAA06BA-8FBF-43F8-86D7-9F5DE26C4E86}']
    function GetAllowMultiple: Boolean;
    procedure SetAllowMultiple(const aValue: Boolean);
    function GetHasValue: Boolean;
    procedure SetHasValue(const aValue: Boolean);
    function GetHelpText: string;
    procedure SetHelpText(const aValue: string);
    function GetIsHidden: Boolean;
    procedure SetIsHidden(const aValue: Boolean);
    function GetIsAnonymous: Boolean;
    function GetIsOptionFile: Boolean;
    procedure SetIsOptionFile(const aValue: Boolean);
    function GetLongName: string;
    function GetRequired: Boolean;
    procedure SetRequired(const aValue: Boolean);
    function GetShortName: string;
    function GetValueRequired: Boolean;
    procedure SetValueRequired(const aValue: Boolean);
    {Properties}
    property AllowMultiple: Boolean read GetAllowMultiple write SetAllowMultiple;
    property HasValue: Boolean read GetHasValue write SetHasValue;
    property HelpText: string read GetHelpText write SetHelpText;
    property Hidden: Boolean read GetIsHidden write SetIsHidden;
    property IsAnonymous: Boolean read GetIsAnonymous;
    property IsOptionFile: Boolean read GetIsOptionFile write SetIsOptionFile;
    property LongName: string read GetLongName;
    property Required: Boolean read GetRequired write SetRequired;
    property ShortName: string read GetShortName;
    property ValueRequired: Boolean read GetValueRequired write SetValueRequired;
  end;

  TEnumerateCommandOptionsAction = reference to procedure(const aOptionDefinition: IOptionDefinition);

  ICommandDefinition = interface
    ['{58199FE2-19DF-4F9B-894F-BD1C5B62E0CB}']
    procedure AddOption(const aOption: IOptionDefinition);
    procedure Clear;
    procedure EnumerateCommandOptions(const aProc: TEnumerateCommandOptionsAction); overload;
    procedure GetAllRegisteredOptions(const aList: TList<IOptionDefinition>);
    function HasOption(const aOptionName: string): Boolean;
    function TryGetOption(const aName: string; var aOption: IOptionDefinition): Boolean;
    function GetAlias: string;
    function GetDescription: string;
    function GetHelpText: string;
    function GetIsDefault: Boolean;
    function GetName: string;
    function GetRegisteredAnonymousOptions: TList<IOptionDefinition>;
    function GetRegisteredOptions: TList<IOptionDefinition>;
    function GetUsage: string;
    function GetVisible: Boolean;
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

  TEnumerateCommandAction = reference to procedure(const aCommandDefinition: ICommandDefinition);

  IOptionDefinitionInvoke = interface
    ['{580B5B40-CD7B-41B8-AE53-2C6890141FF0}']
    function GetTypeInfo: PTypeInfo;
    procedure Invoke(const aValueStr: string);
    function WasFound: Boolean;
  end;

  ICmdlineParseResult = interface
    ['{1715B9FF-8A34-47C9-843E-619C5AEA3F32}']
    function GetCommandName: string;
    function GetErrorText: string;
    function GetHasErrors: Boolean;
    {Properties}
    property CommandName: string read GetCommandName;
    property ErrorText: string read GetErrorText;
    property HasErrors: Boolean read GetHasErrors;
  end;

  ICmdlineParser = interface
    ['{6F970026-D1EE-4A3E-8A99-300AD3EE9C33}']
    function Parse: ICmdlineParseResult; overload;
    function Parse(const aValues: TStrings): ICmdlineParseResult; overload;
  end;

  IInternalParseResult = interface
    ['{9EADABED-511B-4095-9ACA-A5E431AB653D}']
    procedure AddError(const aErrStr: string);
    procedure SetCommand(const aCommand: ICommandDefinition);
    function GetCommand: ICommandDefinition;
    {Properties}
    property Command: ICommandDefinition read GetCommand;
  end;

implementation

end.
