unit CmdLine.Utils;

interface

function GetConsoleWidth: Integer;

/// <summary>
/// Split a given text into array of strings, each string not exceeding a
/// maximum number of characters.
/// </summary>
/// <param name="aText">
/// The given text.
/// </param>
/// <param name="aMaxLen">
/// Maximum number of characters of each string.
/// </param>
function SplitText(const aText: string; const aMaxLen: Integer): TArray<string>;

/// <summary>
/// Split a given string into array of strings; each string element not
/// exceeding maximum number of characters.
/// </summary>
/// <param name="aLen">
/// Length of the division.
/// </param>
/// <param name="aSrcStr">
/// Source string to be divided.
/// </param>
function SplitStringAt(const aLen: Integer; const aSrcStr: string): TArray<string>;

/// <summary>
/// Convert a Boolean compatible string to Boolean type.
/// </summary>
/// <param name="aValue">
/// A Boolean compatible string.
/// </param>
function StringToBoolean(const aValue: string): Boolean;

/// <summary>
/// Strip quote char from the given string. Quote char include single quote
/// or double quote.
/// </summary>
/// <param name="aString">
/// A string to strip quote char at two ends.
/// </param>
procedure StripQuotes(var aString: string);

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

function SplitStringAt(const aLen: Integer; const aSrcStr: string): TArray<string>;
var
  srcLen, idx, count: Integer;
begin
  SetLength(Result, 0);
  srcLen := Length(aSrcStr);

  if srcLen < aLen then
  begin
    SetLength(Result, 1);
    Result[0] := aSrcStr;
    Exit;
  end;

  idx := 1;
  count := 0;

  while idx <= srcLen do
  begin
    Inc(count);
    SetLength(Result, count);
    Result[count - 1] := Copy(aSrcStr, idx, aLen);
    Inc(idx, aLen);
  end;
end;

function SplitText(const aText: string; const aMaxLen: Integer): TArray<string>;
var
  strLines, lineSplitStrs: TArray<string>;
  text: string;
  I, J, K: Integer;
begin
  SetLength(Result, 0);

  // Otherwise a CRLF will result in two lines.
  text := StringReplace(aText, sLineBreak, #13, [rfReplaceAll]);

  // Splits at each CR *and* each LF! Delimiters denotes set of single characters used to
  // split string. Each character in Delimiters string will be used as one of possible
  // delimiters.
  strLines := TArray<string>(SplitString(text, #13#10));

  K := 0;

  for I := 0 to Length(strLines) - 1 do
  begin
    lineSplitStrs := SplitStringAt(aMaxLen, strLines[I]);

    Inc(K, Length(lineSplitStrs));
    SetLength(Result, K);

    for J := 0 to Length(lineSplitStrs) - 1 do
      Result[K - 1 + J] := lineSplitStrs[J];
  end;
end;

{$IFDEF MSWINDOWS}
function GetConsoleWidth: Integer;
var
  info: CONSOLE_SCREEN_BUFFER_INFO;
  hStdOut: THandle;
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

function StringToBoolean(const aValue: string): Boolean;
const
  sInvalidBooleanString = 'Invalid string, not Boolean compliant.';
begin
  if MatchText(aValue, TrueStrings) then
    Result := True
  else
    if MatchText(aValue, FalseStrings) then
      Result := False
    else
      raise Exception.Create(sInvalidBooleanString);
end;

procedure StripQuotes(var aString: string);
const
  minStrLen    = 2;
  quoteCharSet = ['''', '"'];
var
  strLen: Integer;
begin
  strLen := Length(aString);

  if strLen < minStrLen then
    Exit;

  if CharInSet(aString[1], quoteCharSet) and CharInSet(aString[strLen], quoteCharSet)
  then
  begin
    Delete(aString, strLen, 1);
    Delete(aString, 1, 1);
  end;
end;

end.
