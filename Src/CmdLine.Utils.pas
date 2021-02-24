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

unit Cmdline.Utils;

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
begin
  SetLength(Result, 0);
  var LSrcLen := Length(ASrcStr);

  if LSrcLen < ALen then begin
    SetLength(Result, 1);
    Result[0] := ASrcStr;
    Exit;
  end;

  var LIndex := 1;
  var LCount := 0;

  while LIndex <= LSrcLen do begin
    Inc(LCount);
    SetLength(Result, LCount);
    Result[LCount - 1] := Copy(ASrcStr, LIndex, ALen);
    Inc(LIndex, ALen);
  end;
end;

function SplitText(const AText: string; const AMaxLen: Integer): TArray<string>;
begin
  SetLength(Result, 0);

  // Otherwise a CRLF will result in two lines.
  var LText := StringReplace(AText, sLineBreak, #13, [rfReplaceAll]);

  // Splits at each CR *and* each LF! Delimiters denotes set of single characters used to
  // split string. Each character in Delimiters string will be used as one of possible
  // delimiters.
  var LLines := SplitString(LText, #13#10);
  var K := 0;

  for var I := 0 to Length(LLines) - 1 do begin
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

end.
