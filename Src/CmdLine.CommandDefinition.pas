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

unit CmdLine.CommandDefinition;

interface

uses
  Generics.Collections,
  CmdLine.Intf;

type
  TCommandDefinitionCreateParams = record
    Alias: string;
    Description: string;
    Help: string;
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
    FHelp: string;
    FIsDefault: Boolean;
    FName: string;
    FOptions: TDictionary<string, IOptionDefinition>;
    FRegisteredOptions: TList<IOptionDefinition>;
    FUsage: string;
    FVisible: Boolean;
    function Get_Alias: string;
    function Get_Description: string;
    function Get_Help: string;
    function Get_IsDefault: Boolean;
    function Get_Name: string;
    function Get_RegisteredAnonymousOptions: TList<IOptionDefinition>;
    function Get_RegisteredOptions: TList<IOptionDefinition>;
    function Get_Usage: string;
    function Get_Visible: Boolean;
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
    FHelp := Help;
    FIsDefault := IsDefault;
    FName := Name;
    FUsage := Usage;
    FVisible := Visible;
  end;

  FOptions := TDictionary<string, IOptionDefinition>.Create;
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
    Help := EmptyStr;
    IsDefault := True; // Default is always True.
    Name := EmptyStr;
    Usage := EmptyStr;
    Visible := AVisible;
  end;

  Create(params);
end;

destructor TCommandDefinition.Destroy;
begin
  FOptions.Free;
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
    FOptions.AddOrSetValue(LowerCase(AOption.LongName), AOption);

    if not AOption.ShortName.IsEmpty then
      FOptions.AddOrSetValue(LowerCase(AOption.ShortName), AOption);
  end;
end;

procedure TCommandDefinition.Clear;
begin
  FOptions.Clear;
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

function TCommandDefinition.Get_Alias: string;
begin
  Result := FAlias;
end;

function TCommandDefinition.Get_Description: string;
begin
  Result := FDescription;
end;

function TCommandDefinition.Get_Help: string;
begin
  Result := FHelp;
end;

function TCommandDefinition.Get_IsDefault: Boolean;
begin
  Result := FIsDefault;
end;

function TCommandDefinition.Get_Name: string;
begin
  Result := FName;
end;

function TCommandDefinition.Get_RegisteredAnonymousOptions: TList<IOptionDefinition>;
begin
  Result := FAnonymousOptions;
end;

function TCommandDefinition.Get_RegisteredOptions: TList<IOptionDefinition>;
begin
  Result := FRegisteredOptions;
end;

function TCommandDefinition.Get_Usage: string;
begin
  Result := FUsage;
end;

function TCommandDefinition.Get_Visible: Boolean;
begin
  Result := FVisible;
end;

function TCommandDefinition.HasOption(const AName: string): Boolean;
begin
  Result := FOptions.ContainsKey(LowerCase(AName));
end;

function TCommandDefinition.TryGetOption(const AName: string; var AOption: IOptionDefinition): Boolean;
begin
  Result := FOptions.TryGetValue(LowerCase(AName), AOption);
end;

end.
