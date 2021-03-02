program Sample;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  CmdlineParser,
  uSampleConfig in 'uSampleConfig.pas',
  uSampleOptions in 'uSampleOptions.pas';

var
  ParseResult: ICmdLineParseResult;

begin
  try
    //parse the command line options
    ParseResult := TOptionsRegistry.Parse;

    if ParseResult.HasErrors then begin
      Writeln('Invalid command line :');
      Writeln;
      Writeln(ParseResult.ErrorText);
      TOptionsRegistry.DescriptionTabSize := 20;

      TOptionsRegistry.PrintUsage(
        procedure(const value: string)
        begin
          Writeln(value);
        end);
    end else begin
      Writeln('Input  : ' + TSampleOptions.InputFile);
      Writeln('Output : ' + TSampleOptions.OutputFile);
      Writeln('Mangle : ' + BoolToStr(TSampleOptions.MangleFile, true));
    end;

    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
