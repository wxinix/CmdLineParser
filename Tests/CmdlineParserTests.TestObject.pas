{***************************************************************************}
{***************************************************************************}
{                                                                           }
{           Command Line Parser                                             }
{           Copyright (C) 2021 Wuping Xin                                   }
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

unit CmdLineParserTests.TestObject;

interface

uses
  DUnitX.TestFramework, CmdLine.OptionsRegistry;

type
  TExampleEnum = (enOne, enTwo, enThree);
  TExampleSet = set of TExampleEnum;

  [TestFixture]
  TCmdLineParserTests = class
  public
  {$REGION 'Setup and Teardown'}
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  {$ENDREGION}

    [Test]
    procedure Can_Parse_ColonEqualNameValueSeparator;
    [Test]
    procedure Can_Parse_Enum_Parameter;
    [Test]
    procedure Can_Parse_EqualNameValueSeparator;
    [Test]
    procedure Can_Parse_Multiple_Anonymous_Parameters;
    [Test]
    procedure Can_Parse_Quoted_Value;
    [Test]
    procedure Can_Parse_Set_Parameter;
    [Test]
    procedure Can_Parse_Anonymous_Parameter;
    [Test]
    procedure Can_Register_Anonymous_Parameter;
    [Test]
    procedure Test_Single_Option;
    [Test]
    procedure Will_Generate_Error_For_Extra_Unamed_Parameter;
    [Test]
    procedure Will_Generate_Error_For_Invalid_Enum;
    [Test]
    procedure Will_Generate_Error_For_Invalid_Set;
    [Test]
    procedure Will_Generate_Error_For_Missing_Value;
    [Test]
    procedure Will_Generate_Error_For_Unknown_Option;
    [Test]
    procedure Will_Raise_For_Missing_Param_File;
    [Test]
    procedure Will_Raise_On_Registering_Duplicate_Options;
    [Test]
    procedure Will_Raise_On_Registering_Anonymous_Option;
    [Test]
    procedure Can_Parse_Command_Options;
  end;

implementation

uses
  System.Classes;

procedure TCmdLineParserTests.Can_Parse_ColonEqualNameValueSeparator;
var
  LTestStr: string;
begin
  TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(const aValue: string)
    begin
      LTestStr := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('--test:=hello');

  try
    TOptionsRegistry.NameValueSeparator := ':=';
    TOptionsRegistry.Parse(LCmdline);
  finally
    LCmdline.Free;
  end;

  Assert.AreEqual('hello', LTestStr);
end;

procedure TCmdLineParserTests.Can_Parse_Enum_Parameter;
var
  LTestEnum: TExampleEnum;
begin
  TOptionsRegistry.RegisterOption<TExampleEnum>('test', 't',
    procedure(const aValue: TExampleEnum)
    begin
      LTestEnum := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('--test:enTwo');

  try
    TOptionsRegistry.NameValueSeparator := ':';
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    Assert.IsFalse(LParseResult.HasErrors);
    Assert.AreEqual<TExampleEnum>(TExampleEnum.enTwo, LTestEnum);
  finally
    LCmdline.Free;
  end
end;

procedure TCmdLineParserTests.Can_Parse_EqualNameValueSeparator;
var
  LTestStr: string;
begin
  TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(const aValue: string)
    begin
      LTestStr := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('--test=hello');

  try
    TOptionsRegistry.NameValueSeparator := '=';
    TOptionsRegistry.Parse(LCmdline);
  finally
    LCmdline.Free;
  end;

  Assert.AreEqual('hello', LTestStr);
end;

procedure TCmdLineParserTests.Can_Parse_Multiple_Anonymous_Parameters;
var
  LFileName_1, LFileName_2: string;
  LTestBool: Boolean;
begin
  TOptionsRegistry.RegisterAnonymousOption<string>
    ('the file we want to process',
    procedure(const aValue: string)
    begin
      LFileName_1 := aValue;
    end);

  TOptionsRegistry.RegisterAnonymousOption<string>
    ('the second file we want to process',
    procedure(const aValue: string)
    begin
      LFileName_2 := aValue;
    end);

  var LOption := TOptionsRegistry.RegisterOption<Boolean>('test', 't',
    procedure(const aValue: Boolean)
    begin
      LTestBool := aValue;
    end);

  LOption.RequiresValue:= False;

  var LCmdline := TStringList.Create;
  LCmdline.Add('c:\file1.txt');
  LCmdline.Add('--test');
  LCmdline.Add('c:\file2.txt');

  try
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    Assert.IsFalse(LParseResult.HasErrors);
    Assert.AreEqual('c:\file1.txt', LFileName_1);
    Assert.AreEqual('c:\file2.txt', LFileName_2);
  finally
    LCmdline.Free;
  end
end;

procedure TCmdLineParserTests.Can_Parse_Quoted_Value;
var
  LTestStr_1, LTestStr_2: string;
begin
  TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(const aValue: string)
    begin
      LTestStr_1 := aValue;
    end);

  TOptionsRegistry.RegisterOption<string>('test2', 't2',
    procedure(const aValue: string)
    begin
      LTestStr_2 := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('--test:"hello world"');
  LCmdline.Add('--test2:''hello world''');

  try
    TOptionsRegistry.NameValueSeparator := ':';
    TOptionsRegistry.Parse(LCmdline);
  finally
    LCmdline.Free;
  end;

  Assert.AreEqual('hello world', LTestStr_1);
  Assert.AreEqual('hello world', LTestStr_2);
end;

procedure TCmdLineParserTests.Can_Parse_Set_Parameter;
var
  LTestSet: TExampleSet;
begin
  TOptionsRegistry.RegisterOption<TExampleSet>('test', 't',
    procedure(const aValue: TExampleSet)
    begin
      LTestSet := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('--test:[enOne,enThree]');

  try
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    Assert.IsFalse(LParseResult.HasErrors);
    Assert.AreEqual<TExampleSet>(LTestSet, [enOne, enThree]);
  finally
    LCmdline.Free;
  end
end;

procedure TCmdLineParserTests.Can_Parse_Anonymous_Parameter;
var
  LTestStr: string;
begin
  TOptionsRegistry.RegisterAnonymousOption<string>
    ('the file we want to process',
    procedure(const aValue: string)
    begin
      LTestStr := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('c:\test.txt');

  try
    TOptionsRegistry.Parse(LCmdline);
  finally
    LCmdline.Free;
  end;

  Assert.AreEqual('c:\test.txt', LTestStr);
end;

procedure TCmdLineParserTests.Can_Parse_Command_Options;
var
  LTestEnum: TExampleEnum;
  LTestBool: Boolean;
begin
  TOptionsRegistry
  .RegisterCommand('test','t','Test Command', 'Test [Options]','Test Usage')
  .RegisterOption<TExampleEnum>('verbose', 'v',
    procedure(const aValue: TExampleEnum)
    begin
      LTestEnum := aValue;
    end);

  // Global options that go with the default command.
  TOptionsRegistry.RegisterOption<Boolean>('autosave', 'as',
    procedure(const aValue: Boolean)
    begin
      LTestBool := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('-as:true'); // Appear the first time, it goes by the global check.
  LCmdline.Add('test'); // The registered command, current command now swap to it from default command.
  LCmdline.Add('-v:enTwo');
  // The command has no option named "as" registered. So the search will look up the global options.
  LCmdline.Add('-as:false'); // Appear the second time, it goes by current command check first, if fails, then global check.

  try
    TOptionsRegistry.NameValueSeparator := ':';
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    WriteLn(LParseResult.ErrorText);

    Assert.IsFalse(LParseResult.HasErrors);
    // LTestBool was first set to True, then the second time it was set to False. This is
    // because -as appeared twice in the command line.
    Assert.IsFalse(LTestBool);
    Assert.AreEqual<TExampleEnum>(enTwo, LTestEnum);
  finally
    LCmdline.Free;
  end
end;

procedure TCmdLineParserTests.Can_Register_Anonymous_Parameter;
begin
  var LOption := TOptionsRegistry.RegisterAnonymousOption<string>('the file we want to process',
    procedure(const value: string)
    begin
    end);

  Assert.IsTrue(LOption.IsAnonymous);
end;

procedure TCmdLineParserTests.Setup;
begin
  TOptionsRegistry.Clear;
end;

procedure TCmdLineParserTests.TearDown;
begin
  TOptionsRegistry.Clear;
end;

procedure TCmdLineParserTests.Test_Single_Option;
var
  TTestBool: Boolean;
begin
  var LOption := TOptionsRegistry.RegisterOption<Boolean>('test', 't',
    procedure(const aValue: Boolean)
    begin
      TTestBool := aValue;
    end);

  LOption.RequiresValue := False;

  var LCmdline := TStringList.Create;
  LCmdline.Add('--test');

  try
    TOptionsRegistry.Parse(LCmdline);
  finally
    LCmdline.Free;
  end;

  Assert.IsTrue(TTestBool);
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Extra_Unamed_Parameter;
var
  LFileName, LTestStr: string;
begin
  TOptionsRegistry.RegisterAnonymousOption<string>
    ('the file we want to process',
    procedure(const aValue: string)
    begin
      LFileName := aValue;
    end);

  TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(const aValue: string)
    begin
      LTestStr := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('c:\file1.txt');
  LCmdline.Add('--test:hello');
  LCmdline.Add('c:\file2.txt');

  try
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    WriteLn(LParseResult.ErrorText);
    Assert.IsTrue(LParseResult.HasErrors);
    Assert.AreEqual('c:\file1.txt', LFileName);
    Assert.AreEqual('hello', LTestStr)
  finally
    LCmdline.Free;
  end
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Invalid_Enum;
var
  LTestEnum: TExampleEnum;
begin
  TOptionsRegistry.RegisterOption<TExampleEnum>('test', 't',
    procedure(const aValue: TExampleEnum)
    begin
      LTestEnum := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('--test:enbBlah');

  try
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    WriteLn(LParseResult.ErrorText);
    Assert.IsTrue(LParseResult.HasErrors);
  finally
    LCmdline.Free;
  end;
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Invalid_Set;
var
  LTestSet: TExampleSet;
begin
  TOptionsRegistry.RegisterOption<TExampleSet>('test', 't',
    procedure(const aValue: TExampleSet)
    begin
      LTestSet := aValue;
    end);

  var LCmdline := TStringList.Create;
  LCmdline.Add('--test:[enOne,enFoo]');

  try
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    WriteLn(LParseResult.ErrorText);
    Assert.IsTrue(LParseResult.HasErrors);
  finally
    LCmdline.Free;
  end;
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Missing_Value;
var
  LTestBool: Boolean;
begin
  var LOption := TOptionsRegistry.RegisterOption<Boolean>('test', 't',
    procedure(const aValue: Boolean)
    begin
      LTestBool := aValue;
    end);

  LOption.RequiresValue := True;

  var LCmdline := TStringList.Create;
  LCmdline.Add('--test');

  try
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    WriteLn(LParseResult.ErrorText);
    Assert.IsTrue(LParseResult.HasErrors);
  finally
    LCmdline.Free;
  end;
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Unknown_Option;
begin
  var LCmdline := TStringList.Create;
  LCmdline.Add('--blah');

  try
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    WriteLn(LParseResult.ErrorText);
    Assert.IsTrue(LParseResult.HasErrors);
  finally
    LCmdline.Free;
  end;
end;

procedure TCmdLineParserTests.Will_Raise_For_Missing_Param_File;
begin
  var LOption := TOptionsRegistry.RegisterOption<Boolean>('options', 'o', nil);
  LOption.IsOptionFile := True; // Set IsOptionFile True
  var LCmdline := TStringList.Create;
  LCmdline.Add('--options:"x:\blah blah.txt"');

  try
    var LParseResult := TOptionsRegistry.Parse(LCmdline);
    WriteLn(LParseResult.ErrorText);
    Assert.IsTrue(LParseResult.HasErrors);
  finally
    LCmdline.Free;
  end;
end;

procedure TCmdLineParserTests.Will_Raise_On_Registering_Duplicate_Options;
var
  LTestBool: Boolean;
begin
  // same long names
  Assert.WillRaise(
    procedure
    begin
      TOptionsRegistry.RegisterOption<Boolean>('test', 't',
          procedure(const aValue: Boolean)
        begin
          LTestBool := aValue;
        end);

      TOptionsRegistry.RegisterOption<Boolean>('test', 't',
        procedure(const aValue: Boolean)
        begin
          LTestBool := aValue;
        end);
    end);

  // same short names
  Assert.WillRaise(
    procedure
    begin
      TOptionsRegistry.RegisterOption<Boolean>('test', 't',
        procedure(const aValue: Boolean)
        begin
          LTestBool := aValue;
        end);

      TOptionsRegistry.RegisterOption<Boolean>('t', 'blah',
        procedure(const aValue: Boolean)
        begin
          LTestBool := aValue;
        end);
    end);
end;

procedure TCmdLineParserTests.Will_Raise_On_Registering_Anonymous_Option;
begin
  // same long names
  Assert.WillRaise(
    procedure
    begin
      TOptionsRegistry.RegisterOption<Boolean>('', 't',
        procedure(const aValue: Boolean)
        begin
        //
        end);
    end);
end;

initialization

TDUnitX.RegisterTestFixture(TCmdLineParserTests);

end.
