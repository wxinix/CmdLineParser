unit CmdLineTests.TestFixture;

interface

uses
  DUnitX.TestFramework,
  CmdLine.OptionsRegistry,
  CmdLine.Parser;

type
  TExampleEnum = (enOne, enTwo, enThree);
  TExampleSet = set of TExampleEnum;

  [TestFixture]
  TCmdLineParserTests = class
  public
{$REGION}
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
{$ENDREGION}
{$REGION 'Global Options Tests'}
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
{$ENDREGION}
{$REGION 'Command Tests'}
    [Test]
    procedure Can_Parse_Command_Options;
{$ENDREGION}
  end;

implementation

uses
  System.Classes,
  CmdLine.Intf,
  CmdLine.OptionDefinition;

procedure TCmdLineParserTests.Can_Parse_ColonEqualNameValueSeparator;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  Test: string;
begin
  def := TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(const value: string)
    begin
      Test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:=hello');

  try
    TOptionsRegistry.NameValueSeparator := ':=';
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.AreEqual('hello', Test);
end;

procedure TCmdLineParserTests.Can_Parse_Enum_Parameter;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  test: TExampleEnum;
begin
  def := TOptionsRegistry.RegisterOption<TExampleEnum>('test', 't',
    procedure(const value: TExampleEnum)
    begin
      test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:enTwo');

  try
    TOptionsRegistry.NameValueSeparator := ':';
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.IsFalse(parseResult.HasErrors);
  Assert.AreEqual<TExampleEnum>(enTwo, test);
end;

procedure TCmdLineParserTests.Can_Parse_EqualNameValueSeparator;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  Test: string;
begin
  def := TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(const value: string)
    begin
      Test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test=hello');

  try
    TOptionsRegistry.NameValueSeparator := '=';
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.AreEqual('hello', Test);
end;

procedure TCmdLineParserTests.Can_Parse_Multiple_Anonymous_Parameters;
var
  def: IOptionDefinition;
  file1: string;
  file2: string;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  Test: Boolean;
begin
  def := TOptionsRegistry.RegisterAnonymousOption<string>
    ('the file we want to process',
    procedure(const value: string)
    begin
      file1 := value;
    end);

  def := TOptionsRegistry.RegisterAnonymousOption<string>
    ('the second file we want to process',
    procedure(const value: string)
    begin
      file2 := value;
    end);

  def := TOptionsRegistry.RegisterOption<Boolean>('test', 't',
    procedure(const value: Boolean)
    begin
      Test := value;
    end);

  def.HasValue := False;

  sList := TStringList.Create;
  sList.Add('c:\file1.txt');
  sList.Add('--test');
  sList.Add('c:\file2.txt');

  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.IsFalse(parseResult.HasErrors);
  Assert.AreEqual('c:\file1.txt', file1);
  Assert.AreEqual('c:\file2.txt', file2);
end;

procedure TCmdLineParserTests.Can_Parse_Quoted_Value;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  test1: string;
  test2: string;
begin
  def := TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(const value: string)
    begin
      test1 := value;
    end);

  def := TOptionsRegistry.RegisterOption<string>('test2', 't2',
    procedure(const value: string)
    begin
      test2 := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:"hello world"');
  sList.Add('--test2:''hello world''');

  try
    TOptionsRegistry.NameValueSeparator := ':';
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.AreEqual('hello world', test1);
  Assert.AreEqual('hello world', test2);
end;

procedure TCmdLineParserTests.Can_Parse_Set_Parameter;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  Test: TExampleSet;
begin
  def := TOptionsRegistry.RegisterOption<TExampleSet>('test', 't',
    procedure(const value: TExampleSet)
    begin
      Test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:[enOne,enThree]');

  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.IsFalse(parseResult.HasErrors);
  Assert.AreEqual<TExampleSet>(Test, [enOne, enThree]);
end;

procedure TCmdLineParserTests.Can_Parse_Anonymous_Parameter;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  Test: string;
begin
  def := TOptionsRegistry.RegisterAnonymousOption<string>
    ('the file we want to process',
    procedure(const value: string)
    begin
      Test := value;
    end);

  sList := TStringList.Create;
  sList.Add('c:\test.txt');

  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.AreEqual('c:\test.txt', Test);
end;

procedure TCmdLineParserTests.Can_Parse_Command_Options;
var
  def: IOptionDefinition;
  cmd: TCommandDefinitionRecord;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  test: TExampleEnum;
  test1: Boolean;
begin
  cmd := TOptionsRegistry.RegisterCommand('test','t','Test Command',
    'Test [Options]','Test Usage');

  def := cmd.RegisterOption<TExampleEnum>('verbose', 'v',
    procedure(const value: TExampleEnum)
    begin
      test := value;
    end);

  // Global options that go with the default commdn.
  def := TOptionsRegistry.RegisterOption<Boolean>('autosave', 'as',
     procedure(const value: Boolean)
    begin
      test1 := value;
    end);

  sList := TStringList.Create;
  sList.Add('-as:true'); // Appear the first time, it goes the global check.
  sList.Add('test'); // The registered command, current command now swap to it from default command.
  sList.Add('-v:enTwo');
  // The command has no option named "as" registered. So the search will look up the global options.
  sList.Add('-as:false'); // Appear the second time, it goes current command check first, if fails, then global check.

  try
    TOptionsRegistry.NameValueSeparator := ':';
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;

  Assert.IsFalse(parseResult.HasErrors);

  // test1 was first set to True, then the second time it was set to False. This is
  // because -as appeared twice in the command line.
  Assert.IsFalse(test1);
  Assert.AreEqual<TExampleEnum>(enTwo, test);
end;

procedure TCmdLineParserTests.Can_Register_Anonymous_Parameter;
var
  def: IOptionDefinition;
begin
  def := TOptionsRegistry.RegisterAnonymousOption<string>
    ('the file we want to process',
    procedure(const value: string)
    begin
    end);

  Assert.IsTrue(def.IsAnonymous);
end;

procedure TCmdLineParserTests.Setup;
begin
  // TOptionsRegistry.DefaultCommand.Clear;
  TOptionsRegistry.Clear;
end;

procedure TCmdLineParserTests.TearDown;
begin
  // TOptionsRegistry.DefaultCommand.Clear;
  TOptionsRegistry.Clear;
end;

procedure TCmdLineParserTests.Test_Single_Option;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  Test: Boolean;
begin
  def := TOptionsRegistry.RegisterOption<Boolean>('test', 't',
    procedure(const value: Boolean)
    begin
      Test := value;
    end);

  def.HasValue := False;

  sList := TStringList.Create;
  sList.Add('--test');

  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.IsTrue(Test);
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Extra_Unamed_Parameter;
var
  def: IOptionDefinition;
  file1: string;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  Test: string;
begin
  def := TOptionsRegistry.RegisterAnonymousOption<string>
    ('the file we want to process',
    procedure(const value: string)
    begin
      file1 := value;
    end);

  def := TOptionsRegistry.RegisterOption<string>('test', 't',
    procedure(const value: string)
    begin
      Test := value;
    end);

  sList := TStringList.Create;
  sList.Add('c:\file1.txt');
  sList.Add('--test:hello');
  sList.Add('c:\file2.txt');

  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;

  Assert.IsTrue(parseResult.HasErrors);
  Assert.AreEqual('c:\file1.txt', file1);
  Assert.AreEqual('hello', Test);
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Invalid_Enum;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  test: TExampleEnum;
begin
  def := TOptionsRegistry.RegisterOption<TExampleEnum>('test', 't',
    procedure(const value: TExampleEnum)
    begin
      test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:enbBlah');

  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;

  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Invalid_Set;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  test: TExampleSet;
begin
  def := TOptionsRegistry.RegisterOption<TExampleSet>('test', 't',
    procedure(const value: TExampleSet)
    begin
      test := value;
    end);

  sList := TStringList.Create;
  sList.Add('--test:[enOne,enFoo]');

  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;

  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Missing_Value;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
  Test: Boolean;
begin
  def := TOptionsRegistry.RegisterOption<Boolean>('test', 't',
    procedure(const value: Boolean)
    begin
      Test := value;
    end);

  def.HasValue := True;

  sList := TStringList.Create;
  sList.Add('--test');

  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;

  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCmdLineParserTests.Will_Generate_Error_For_Unknown_Option;
var
  parseResult: ICmdLineParseResult;
  sList: TStringList;
begin
  sList := TStringList.Create;
  sList.Add('--blah');

  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;

  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCmdLineParserTests.Will_Raise_For_Missing_Param_File;
var
  def: IOptionDefinition;
  parseResult: ICmdLineParseResult;
  sList: TStringList;
begin
  def := TOptionsRegistry.RegisterOption<Boolean>('options', 'o', nil);
  def.IsOptionFile := True; // Set IsOptionFile True
  sList := TStringList.Create;
  sList.Add('--options:"x:\blah blah.txt"');

  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;

  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCmdLineParserTests.Will_Raise_On_Registering_Duplicate_Options;
var
  Test: Boolean;
begin
  // same long names
  Assert.WillRaise(
    procedure
    begin
      TOptionsRegistry.RegisterOption<Boolean>('test', 't',
          procedure(const value: Boolean)
        begin
          Test := value;
        end);

      TOptionsRegistry.RegisterOption<Boolean>('test', 't',
        procedure(const value: Boolean)
        begin
          Test := value;
        end);
    end);

  // same short names
  Assert.WillRaise(
    procedure
    begin
      TOptionsRegistry.RegisterOption<Boolean>('test', 't',
          procedure(const value: Boolean)
        begin
          Test := value;
        end);

      TOptionsRegistry.RegisterOption<Boolean>('t', 'blah',
        procedure(const value: Boolean)
        begin
          Test := value;
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
          procedure(const value: Boolean)
        begin
        end);
    end);
end;

initialization

TDUnitX.RegisterTestFixture(TCmdLineParserTests);

end.
