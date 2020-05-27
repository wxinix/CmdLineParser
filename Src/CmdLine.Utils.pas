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
begin
  SetLength(Result, 0);

  // Otherwise a CRLF will result in two lines.
  var text := StringReplace(AText, sLineBreak, #13, [rfReplaceAll]);

  // Splits at each CR *and* each LF! Delimiters denotes set of single characters used to
  // split string. Each character in Delimiters string will be used as one of possible
  // delimiters.
  var lines := SplitString(text, #13#10);

  var K := 0;

  for var I := 0 to Length(lines) - 1 do
  begin
    var strs := SplitStringAt(AMaxLen, lines[I]);

    Inc(K, Length(strs));
    SetLength(Result, K);

    for var J := 0 to Length(strs) - 1 do
      Result[K - Length(strs) + J] := strs[J];
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
