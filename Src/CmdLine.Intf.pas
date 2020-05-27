{***************************************************************************}
{                                                                           }
{           Command Line Parser                                             }
{           Copyright (C) 2020 Wuping Xin                                   }
{           KLD Engineering, P. C.                                          }
{           http://www.kldcompanies.com                                     }
{                                                                           }
{           VSoft.CommandLine                                               }
{           Copyright (C) 2014 Vincent Parrett                              }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
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

unit CmdLine.Intf;

interface

uses
  System.Classes,
  System.TypInfo,
  Generics.Collections;

type
  TOptionValueParsedAction<T> = reference to procedure(const AValue: T);
  TPrintUsageAction = reference to procedure(const aText: string);

  IOptionDefinition = interface
    ['{1EAA06BA-8FBF-43F8-86D7-9F5DE26C4E86}']
    function Get_AllowMultiple: Boolean;
    procedure Set_AllowMultiple(const AValue: Boolean);
    function Get_HasValue: Boolean;
    procedure Set_HasValue(const AValue: Boolean);
    function Get_HelpText: string;
    procedure Set_HelpText(const AValue: string);
    function Get_IsHidden: Boolean;
    procedure Set_IsHidden(const AValue: Boolean);
    function Get_IsAnonymous: Boolean;
    function Get_IsOptionFile: Boolean;
    procedure Set_IsOptionFile(const AValue: Boolean);
    function Get_LongName: string;
    function Get_Required: Boolean;
    procedure Set_Required(const AValue: Boolean);
    function Get_ShortName: string;
    function Get_ValueRequired: Boolean;
    procedure Set_ValueRequired(const AValue: Boolean);
    { Properties }
    property AllowMultiple: Boolean read Get_AllowMultiple write Set_AllowMultiple;
    property HasValue: Boolean read Get_HasValue write Set_HasValue;
    property HelpText: string read Get_HelpText write Set_HelpText;
    property Hidden: Boolean read Get_IsHidden write Set_IsHidden;
    property IsAnonymous: Boolean read Get_IsAnonymous;
    property IsOptionFile: Boolean read Get_IsOptionFile write Set_IsOptionFile;
    property LongName: string read Get_LongName;
    property Required: Boolean read Get_Required write Set_Required;
    property ShortName: string read Get_ShortName;
    property ValueRequired: Boolean read Get_ValueRequired write Set_ValueRequired;
  end;

  TEnumerateCommandOptionsAction = reference to procedure(const AOptionDefinition: IOptionDefinition);

  ICommandDefinition = interface
    ['{58199FE2-19DF-4F9B-894F-BD1C5B62E0CB}']
    procedure AddOption(const aOption: IOptionDefinition);
    procedure Clear;
    procedure EnumerateCommandOptions(const AProc: TEnumerateCommandOptionsAction); overload;
    procedure GetAllRegisteredOptions(const AResult: TList<IOptionDefinition>);
    function HasOption(const AName: string): Boolean;
    function TryGetOption(const AName: string; var aOption: IOptionDefinition): Boolean;
    function Get_Alias: string;
    function Get_Description: string;
    function Get_Help: string;
    function Get_IsDefault: Boolean;
    function Get_Name: string;
    function Get_RegisteredAnonymousOptions: TList<IOptionDefinition>;
    function Get_RegisteredOptions: TList<IOptionDefinition>;
    function Get_Usage: string;
    function Get_Visible: Boolean;
    { Properties }
    property Alias: string read Get_Alias;
    property Description: string read Get_Description;
    property Help: string read Get_Help;
    property IsDefault: Boolean read Get_IsDefault;
    property Name: string read Get_Name;
    property RegisteredAnonymousOptions: TList<IOptionDefinition> read Get_RegisteredAnonymousOptions;
    property RegisteredOptions: TList<IOptionDefinition> read Get_RegisteredOptions;
    property Usage: string read Get_Usage;
    property Visible: Boolean read Get_Visible;
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
    function Get_CommandName: string;
    function Get_ErrorText: string;
    function Get_HasErrors: Boolean;
    { Properties }
    property CommandName: string read Get_CommandName;
    property ErrorText: string read Get_ErrorText;
    property HasErrors: Boolean read Get_HasErrors;
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
    function Get_Command: ICommandDefinition;
    { Properties }
    property Command: ICommandDefinition read Get_Command;
  end;

implementation

end.
