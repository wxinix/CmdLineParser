unit CmdLine.Utils;

interface

function GetConsoleWidth: Integer;

/// <summary>
/// Split a given text into array of strings, each string not exceeding a
/// maximum number of characters.
/// </summary>
/// <param name="AText">
/// The given text.
/// </param>
/// <param name="AMaxLen">
/// Maximum number of characters of each string.
/// </param>
function SplitText(const AText: string; const AMaxLen: Integer): TArray<string>;

/// <summary>
/// Split a given string into array of strings; each string element not
/// exceeding maximum number of characters.
/// </summary>
/// <param name="ALen">
/// Length of the division.
/// </param>
/// <param name="ASrcStr">
/// Source string to be divided.
/// </param>
function SplitStringAt(const ALen: Integer; const ASrcStr: string): TArray<string>;

/// <summary>
/// Convert a Boolean compatible string to Boolean type.
/// </summary>
/// <param name="AValue">
/// A Boolean compatible string.
/// </param>
function StringToBoolean(const AValue: string): Boolean;

/// <summary>
/// Strip quote char from the given string. Quote char include single quote
/// or double quote.
/// </summary>
/// <param name="AStr">
/// A string to strip quote char at two ends.
/// </param>
procedure StripQuotes(var AStr: string);

const
  TrueStrings: array [0 .. 10] of string = ('True', 'T', '+', 'Yes', 'Y', 'On',
    'Enable', 'Enabled', '1', '-1', '');
  FalseStrings: array [0 .. 8] of string = ('False', 'F', '-', 'No', 'N', 'Off',
    'Disable', 'Disabled', '0');

implementation

uses
{$IFDEF MSWINDOWS}
  WinApi.Windows,
{$ENDIF}
  System.StrUtils,
  System.SysUtils;

function SplitStringAt(const ALen: Integer; const ASrcStr: string): TArray<string>;
var
  count: Integer;
  idx: Integer;
  srcLen: Integer;
begin
  SetLength(Result, 0);
  srcLen := Length(ASrcStr);

  if srcLen < ALen then
  begin
    SetLength(Result, 1);
    Result[0] := ASrcStr;
    Exit;
  end;

  idx := 1;
  count := 0;

  while idx <= srcLen do
  begin
    Inc(count);
    SetLength(Result, count);
    Result[count - 1] := Copy(ASrcStr, idx, ALen);
    Inc(idx, ALen);
  end;
end;

function SplitText(const AText: string; const AMaxLen: Integer): TArray<string>;
var
  I, J, K: Integer;
  lineSplitStrs, strLines: TArray<string>;
  text: string;
begin
  SetLength(Result, 0);

  // Otherwise a CRLF will result in two lines.
  text := StringReplace(AText, sLineBreak, #13, [rfReplaceAll]);

  // Splits at each CR *and* each LF! Delimiters denotes set of single characters used to
  // split string. Each character in Delimiters string will be used as one of possible
  // delimiters.
  strLines := SplitString(text, #13#10);

  K := 0;

  for I := 0 to Length(strLines) - 1 do
  begin
    lineSplitStrs := SplitStringAt(AMaxLen, strLines[I]);

    Inc(K, Length(lineSplitStrs));
    SetLength(Result, K);

    for J := 0 to Length(lineSplitStrs) - 1 do
      Result[K - Length(lineSplitStrs) + J] := lineSplitStrs[J];
  end;
end;

{$IFDEF MSWINDOWS}
function GetConsoleWidth: Integer;
var
  hStdOut: THandle;
  info: CONSOLE_SCREEN_BUFFER_INFO;
begin
  // Default is unlimited width
  Result := High(Integer);
  hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

  if GetConsoleScreenBufferInfo(hStdOut, info) then
    Result := info.dwSize.X;
end;
{$ENDIF}

{$IFDEF MACOS}
function GetConsoleWidth: Integer;
const
  defaultWidth = 80;
begin
  Result := defaultWidth;
  // TODO : Find a way to get the console width on osx
end;
{$ENDIF}

function StringToBoolean(const AValue: string): Boolean;
const
  sInvalidBooleanStr = 'Invalid string, not Boolean compliant.';
begin
  if MatchText(AValue, TrueStrings) then
    Result := True
  else
    if MatchText(AValue, FalseStrings) then
      Result := False
    else
      raise Exception.Create(sInvalidBooleanStr);
end;

procedure StripQuotes(var AStr: string);
const
  minStrLen    = 2;
  quoteCharSet = ['''', '"'];
var
  strLen: Integer;
begin
  strLen := Length(AStr);

  if strLen < minStrLen then
    Exit;

  if CharInSet(AStr[1], quoteCharSet) and CharInSet(AStr[strLen], quoteCharSet) then
  begin
    Delete(AStr, strLen, 1);
    Delete(AStr, 1, 1);
  end;
end;

end.
