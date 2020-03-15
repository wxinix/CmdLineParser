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
    function get_AllowMultiple: Boolean;
    procedure set_AllowMultiple(const aValue: Boolean);
    function get_HasValue: Boolean;
    procedure set_HasValue(const aValue: Boolean);
    function get_HelpText: string;
    procedure set_HelpText(const aValue: string);
    function get_IsHidden: Boolean;
    procedure set_IsHidden(const aValue: Boolean);
    function get_IsAnonymous: Boolean;
    function get_IsOptionFile: Boolean;
    procedure set_IsOptionFile(const aValue: Boolean);
    function get_LongName: string;
    function get_Required: Boolean;
    procedure set_Required(const aValue: Boolean);
    function get_ShortName: string;
    function get_ValueRequired: Boolean;
    procedure set_ValueRequired(const aValue: Boolean);
    { Properties }
    property AllowMultiple: Boolean read get_AllowMultiple write set_AllowMultiple;
    property HasValue: Boolean read get_HasValue write set_HasValue;
    property HelpText: string read get_HelpText write set_HelpText;
    property Hidden: Boolean read get_IsHidden write set_IsHidden;
    property IsAnonymous: Boolean read get_IsAnonymous;
    property IsOptionFile: Boolean read get_IsOptionFile write set_IsOptionFile;
    property LongName: string read get_LongName;
    property Required: Boolean read get_Required write set_Required;
    property ShortName: string read get_ShortName;
    property ValueRequired: Boolean read get_ValueRequired write set_ValueRequired;
  end;

  TEnumerateCommandOptionsAction = reference to procedure(const aOptionDefinition: IOptionDefinition);

  ICommandDefinition = interface
    ['{58199FE2-19DF-4F9B-894F-BD1C5B62E0CB}']
    procedure AddOption(const aOption: IOptionDefinition);
    procedure Clear;
    procedure EnumerateCommandOptions(const AProc: TEnumerateCommandOptionsAction); overload;
    procedure GetAllRegisteredOptions(const AResult: TList<IOptionDefinition>);
    function HasOption(const AName: string): Boolean;
    function TryGetOption(const AName: string; var aOption: IOptionDefinition): Boolean;
    function get_Alias: string;
    function get_Description: string;
    function get_HelpText: string;
    function get_IsDefault: Boolean;
    function get_Name: string;
    function get_RegisteredAnonymousOptions: TList<IOptionDefinition>;
    function get_RegisteredOptions: TList<IOptionDefinition>;
    function get_Usage: string;
    function get_Visible: Boolean;
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

  TEnumerateCommandAction = reference to procedure(const aCommandDefinition: ICommandDefinition);

  IOptionDefinitionInvoke = interface
    ['{580B5B40-CD7B-41B8-AE53-2C6890141FF0}']
    function GetTypeInfo: PTypeInfo;
    procedure Invoke(const AValue: string);
    function WasFound: Boolean;
  end;

  ICmdlineParseResult = interface
    ['{1715B9FF-8A34-47C9-843E-619C5AEA3F32}']
    function get_CommandName: string;
    function get_ErrorText: string;
    function get_HasErrors: Boolean;
    { Properties }
    property CommandName: string read get_CommandName;
    property ErrorText: string read get_ErrorText;
    property HasErrors: Boolean read get_HasErrors;
  end;

  ICmdlineParser = interface
    ['{6F970026-D1EE-4A3E-8A99-300AD3EE9C33}']
    function Parse: ICmdlineParseResult; overload;
    function Parse(const AValues: TStrings): ICmdlineParseResult; overload;
  end;

  IInternalParseResult = interface
    ['{9EADABED-511B-4095-9ACA-A5E431AB653D}']
    procedure AddError(const AError: string);
    procedure SetCommand(const ACmd: ICommandDefinition);
    function get_Command: ICommandDefinition;
    { Properties }
    property Command: ICommandDefinition read get_Command;
  end;

implementation

end.
