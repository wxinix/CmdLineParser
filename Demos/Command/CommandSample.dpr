program CommandSample;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  CmdLine.OptionsRegistry,
  uCommandSampleConfig in 'uCommandSampleConfig.pas',
  uCommandSampleOptions in 'uCommandSampleOptions.pas';

var
  Parseresult: ICmdlineParseResult;

begin
  try
    //parse the command line options
    ParseResult := TOptionsRegistry.Parse;

    if ParseResult.HasErrors then begin
      Writeln('Invalid options :');
      Writeln;
      Writeln(ParseResult.ErrorText);
      Writeln;
      Writeln('Usage : commandsample [command] [options]');

      TOptionsRegistry.PrintUsage(
        procedure(const aValue: string)
        begin
          Writeln(aValue);
        end);
    end else begin
      if ParseResult.CommandName = '' then begin
        Writeln;
        Writeln('Usage : commandsample [command] [options]');
        TOptionsRegistry.PrintUsage(
          procedure(const aValue: string)
          begin
            Writeln(aValue);
          end);
      end else begin
        Writeln('Command : ' + ParseResult.CommandName);
        Writeln('Install Path : ' + TInstallOptions.InstallPath);
        Writeln('Help Command : ' + THelpOptions.HelpCommand);
        Writeln('Output Path : ' + TInstallOptions.OutPath);
        Writeln('Global Output Path : ' + TGlobalOptions.OutPath);
      end;
    end;

    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
