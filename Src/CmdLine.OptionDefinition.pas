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

    /// <summary>Convert loaded option value string to proper type.
    /// </summary>
    /// <returns> T
    /// </returns>
    /// <param name="aValueStr"> (string) </param>
    function OptionValueStrToType(const aValueStr: string): T;

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
  protected
    function GetTypeInfo: PTypeInfo;
    procedure InitDefault;
    procedure Invoke(const aValueStr: string);
    function WasFound: Boolean;
  public
    constructor Create(
      const aLongName: string;
      const aShortName: string;
      const aHelpText: string;
      const aProc: TOptionValueParsedAction<T>); overload;

    constructor Create(
      const aLongName: string;
      const aShortName: string;
      const aProc: TOptionValueParsedAction<T>); overload;
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

implementation

uses
  System.Rtti,
  System.StrUtils,
  System.SysUtils,
  CmdLine.Consts,
  CmdLine.Utils;

constructor TOptionDefinition<T>.Create(const aLongName: string;
  const aShortName: string; const aHelpText: string;
  const aProc: TOptionValueParsedAction<T>);
begin
  Self.Create(aLongName, aShortName, aProc);
  FHelpText := aHelpText;
end;

constructor TOptionDefinition<T>.Create(const aLongName: string;
  const aShortName: string; const aProc: TOptionValueParsedAction<T>);
const
  allowedTypeKinds: set of TTypeKind = [tkInteger, tkEnumeration, tkFloat, tkString,
    tkSet, tkLString, tkWString, tkInt64, tkUString];
begin
  FTypeInfo := TypeInfo(T);

  if not (FTypeInfo.Kind in allowedTypeKinds) then
    raise Exception.Create(SInvalidOptType);

  FLongName := aLongName;
  FShortName := aShortName;
  FHasValue := True;
  FProc := aProc;
  // Explicitly initialize these boolean properties.
  FIsOptionFile := False;
  FRequired := False;

  FAllowMultiple := False; // Not used at all.
  FHidden := False;        // Not used at all.
  FValueRequired := False; // Not used, duplicate with FHasValue?
  // Initialize the default value.
  InitDefault;
end;

function TOptionDefinition<T>.GetAllowMultiple: Boolean;
begin
  Result := FAllowMultiple;
end;

function TOptionDefinition<T>.GetHasValue: Boolean;
begin
  Result := FHasValue;
end;

function TOptionDefinition<T>.GetHelpText: string;
begin
  Result := FHelpText;
end;

function TOptionDefinition<T>.GetIsAnonymous: Boolean;
begin
  Result := FLongName.IsEmpty;
end;

function TOptionDefinition<T>.GetIsHidden: Boolean;
begin
  Result := FHidden;
end;

function TOptionDefinition<T>.GetIsOptionFile: Boolean;
begin
  Result := FIsOptionFile;
end;

function TOptionDefinition<T>.GetLongName: string;
begin
  Result := FLongName;
end;

function TOptionDefinition<T>.GetRequired: Boolean;
begin
  Result := FRequired;
end;

function TOptionDefinition<T>.GetShortName: string;
begin
  Result := FShortName;
end;

function TOptionDefinition<T>.GetTypeInfo: PTypeInfo;
begin
  Result := FTypeInfo;
end;

function TOptionDefinition<T>.GetValueRequired: Boolean;
begin
  Result := FValueRequired;
end;

procedure TOptionDefinition<T>.InitDefault;
begin
  FDefault := Default(T);

  if not FHasValue and (FTypeInfo.Name = StrBoolean) then
    FDefault := TValue.FromVariant(True).AsType<T>;
end;

procedure TOptionDefinition<T>.Invoke(const aValueStr: string);
var
  v: T;
begin
  FWasFound := True;

  if not Assigned(FProc) then
    Exit;

  if aValueStr.IsEmpty then
  begin
    FProc(FDefault);
    Exit;
  end;

  v := OptionValueStrToType(aValueStr);
  FProc(v);
end;

function TOptionDefinition<T>.OptionValueStrToType(const aValueStr: string): T;
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
        intVal := StrToInt(aValueStr);
        v := TValue.From<Integer>(intVal);
      end;
    tkInt64:
      begin
        int64Val := StrToInt64(aValueStr);
        v := TValue.From<Int64>(int64Val);
      end;
    tkString, tkLString, tkWString, tkUString:
      begin
        v := TValue.From<string>(aValueStr);
      end;
    tkSet:
      begin
        intVal := StringToSet(FTypeInfo, aValueStr);
        ptr := @intVal;
        v := TValue.From<T>(T(ptr^));
      end;
    tkEnumeration:
      begin
        if FTypeInfo.Name = StrBoolean then
        begin
          v := TValue.From<Boolean>(StringToBoolean(aValueStr));
        end
        else
        begin
          intVal := GetEnumValue(FTypeInfo, aValueStr);
          if intVal < 0 then
            raise Exception.Create(Format(SInvalidEnumValue, [aValueStr]));
          v := TValue.FromOrdinal(FTypeInfo, intVal);
        end;
      end;
    tkFloat:
      begin
        floatVal := StrToFloat(aValueStr);
        v := TValue.From<Double>(floatVal);
      end;
  else
    raise Exception.Create(SInvalidOptType);
  end;

  Result := v.AsType<T>;
end;

procedure TOptionDefinition<T>.SetAllowMultiple(const aValue: Boolean);
begin
  FAllowMultiple := aValue;
end;

procedure TOptionDefinition<T>.SetHasValue(const aValue: Boolean);
begin
  FHasValue := aValue;
  InitDefault;
end;

procedure TOptionDefinition<T>.SetHelpText(const aValue: string);
begin
  FHelpText := aValue;
end;

procedure TOptionDefinition<T>.SetIsHidden(const aValue: Boolean);
begin
  FHidden := aValue;
end;

procedure TOptionDefinition<T>.SetIsOptionFile(const aValue: Boolean);
begin
  FIsOptionFile := aValue;
end;

procedure TOptionDefinition<T>.SetRequired(const aValue: Boolean);
begin
  FRequired := aValue;
end;

procedure TOptionDefinition<T>.SetValueRequired(const aValue: Boolean);
begin
  FValueRequired := aValue;
end;

function TOptionDefinition<T>.WasFound: Boolean;
begin
  Result := FWasFound;
end;

end.
