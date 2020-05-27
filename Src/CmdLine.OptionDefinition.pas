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

unit CmdLine.OptionDefinition;

interface

uses
  System.TypInfo,
  CmdLine.Intf;

type
  TOptionDefinition<T> = class(TInterfacedObject, IOptionDefinition, IOptionDefinitionInvoke)
  private
    FAllowMultiple: Boolean;
    FDefault: T;
    FHasValue: Boolean;
    FHelpText: string;
    FHidden: Boolean;
    FIsOptionFile: Boolean;
    FLongName: string;
    FProc: TOptionValueParsedAction<T>;
    FRequired: Boolean;
    FShortName: string;
    FTypeInfo: PTypeInfo;
    FValueRequired: Boolean;
    FWasFound: Boolean;
    function OptionValueToType(const AValue: string): T;
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
  protected
    function GetTypeInfo: PTypeInfo;
    procedure InitDefault;
    procedure Invoke(const AValueStr: string);
    function WasFound: Boolean;
  public
    constructor Create(const ALongName, AShortName, AHelp: string; const AProc: TOptionValueParsedAction<T>); overload;
    constructor Create(const ALongName, AShortName: string; const AProc: TOptionValueParsedAction<T>); overload;
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

implementation

uses
  System.Rtti,
  System.StrUtils,
  System.SysUtils,
  CmdLine.Consts,
  CmdLine.Utils;

constructor TOptionDefinition<T>.Create(const ALongName, AShortName, AHelp: string; const AProc: TOptionValueParsedAction<T>);
begin
  Self.Create(ALongName, AShortName, AProc);
  FHelpText := AHelp;
end;

constructor TOptionDefinition<T>.Create(const ALongName, AShortName: string; const AProc: TOptionValueParsedAction<T>);
const
  allowedTypeKinds: set of TTypeKind = [tkInteger, tkEnumeration, tkFloat, tkString,
    tkSet, tkLString, tkWString, tkInt64, tkUString];
begin
  FTypeInfo := TypeInfo(T);

  if not (FTypeInfo.Kind in allowedTypeKinds) then
    raise Exception.Create(SInvalidOptType);

  FLongName := ALongName;
  FShortName := AShortName;
  FHasValue := True;
  FProc := AProc;
  // Explicitly initialize these boolean properties.
  FIsOptionFile := False;
  FRequired := False;

  FAllowMultiple := False; // Not used at all.
  FHidden := False; // Not used at all.
  FValueRequired := False; // Not used, duplicate with FHasValue?
  // Initialize the default value.
  InitDefault;
end;

function TOptionDefinition<T>.GetTypeInfo: PTypeInfo;
begin
  Result := FTypeInfo;
end;

function TOptionDefinition<T>.Get_AllowMultiple: Boolean;
begin
  Result := FAllowMultiple;
end;

function TOptionDefinition<T>.Get_HasValue: Boolean;
begin
  Result := FHasValue;
end;

function TOptionDefinition<T>.Get_HelpText: string;
begin
  Result := FHelpText;
end;

function TOptionDefinition<T>.Get_IsAnonymous: Boolean;
begin
  Result := FLongName.IsEmpty;
end;

function TOptionDefinition<T>.Get_IsHidden: Boolean;
begin
  Result := FHidden;
end;

function TOptionDefinition<T>.Get_IsOptionFile: Boolean;
begin
  Result := FIsOptionFile;
end;

function TOptionDefinition<T>.Get_LongName: string;
begin
  Result := FLongName;
end;

function TOptionDefinition<T>.Get_Required: Boolean;
begin
  Result := FRequired;
end;

function TOptionDefinition<T>.Get_ShortName: string;
begin
  Result := FShortName;
end;

function TOptionDefinition<T>.Get_ValueRequired: Boolean;
begin
  Result := FValueRequired;
end;

procedure TOptionDefinition<T>.InitDefault;
begin
  FDefault := Default (T);

  if not FHasValue and (FTypeInfo.Name = StrBoolean) then
    FDefault := TValue.FromVariant(True).AsType<T>;
end;

procedure TOptionDefinition<T>.Invoke(const AValueStr: string);
var
  v: T;
begin
  FWasFound := True;

  if not Assigned(FProc) then
    Exit;

  if AValueStr.IsEmpty then
  begin
    FProc(FDefault);
    Exit;
  end;

  v := OptionValueToType(AValueStr);
  FProc(v);
end;

function TOptionDefinition<T>.OptionValueToType(const AValue: string): T;
var
  floatVal: Double;
  int64Val: Int64;
  intVal: Integer;
  ptr: Pointer;
  v: TValue;
begin
  case FTypeInfo.Kind of
    tkInteger:
      begin
        intVal := StrToInt(AValue);
        v := TValue.From<Integer>(intVal);
      end;
    tkInt64:
      begin
        int64Val := StrToInt64(AValue);
        v := TValue.From<Int64>(int64Val);
      end;
    tkString, tkLString, tkWString, tkUString:
      begin
        v := TValue.From<string>(AValue);
      end;
    tkSet:
      begin
        intVal := StringToSet(FTypeInfo, AValue);
        ptr := @intVal;
        v := TValue.From<T>(T(ptr^));
      end;
    tkEnumeration:
      begin
        if FTypeInfo.Name = StrBoolean then
        begin
          v := TValue.From<Boolean>(StringToBoolean(AValue));
        end
        else
        begin
          intVal := GetEnumValue(FTypeInfo, AValue);
          if intVal < 0 then
            raise Exception.Create(Format(SInvalidEnumValue, [AValue]));
          v := TValue.FromOrdinal(FTypeInfo, intVal);
        end;
      end;
    tkFloat:
      begin
        floatVal := StrToFloat(AValue);
        v := TValue.From<Double>(floatVal);
      end;
  else
    raise Exception.Create(SInvalidOptType);
  end;

  Result := v.AsType<T>;
end;

procedure TOptionDefinition<T>.Set_AllowMultiple(const AValue: Boolean);
begin
  FAllowMultiple := AValue;
end;

procedure TOptionDefinition<T>.Set_HasValue(const AValue: Boolean);
begin
  FHasValue := AValue;
  InitDefault;
end;

procedure TOptionDefinition<T>.Set_HelpText(const AValue: string);
begin
  FHelpText := AValue;
end;

procedure TOptionDefinition<T>.Set_IsHidden(const AValue: Boolean);
begin
  FHidden := AValue;
end;

procedure TOptionDefinition<T>.Set_IsOptionFile(const AValue: Boolean);
begin
  FIsOptionFile := AValue;
end;

procedure TOptionDefinition<T>.Set_Required(const AValue: Boolean);
begin
  FRequired := AValue;
end;

procedure TOptionDefinition<T>.Set_ValueRequired(const AValue: Boolean);
begin
  FValueRequired := AValue;
end;

function TOptionDefinition<T>.WasFound: Boolean;
begin
  Result := FWasFound;
end;

end.
