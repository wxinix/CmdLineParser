program CmdlineParserTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  CmdlineParserTests.TestObject in 'CmdlineParserTests.TestObject.pas';

var
  logger: ITestLogger;
  nunitLogger: ITestLogger;
  results: IRunResults;
  runner: ITestRunner;

begin
  try
    ReportMemoryLeaksOnShutdown := True;
    TDUnitX.CheckCommandLine;
    // Create the runner
    runner := TDUnitX.CreateRunner;
    runner.UseRTTI := True;
    // Tell the runner how we will log things
    logger := TDUnitXConsoleLogger.Create(false);
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create;
    runner.AddLogger(logger);
    runner.AddLogger(nunitLogger);
    // Run tests
    results := runner.Execute;
{$IFNDEF CI}
    // We don't want this happening when running under CI.
    Write('Done.. press <Enter> key to quit.');
    ReadLn;
{$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;

end.
