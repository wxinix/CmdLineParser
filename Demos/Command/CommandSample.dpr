program CommandSample;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  CmdLine.Intf,
  CmdLine.OptionsRegistry,
  uCommandSampleConfig in 'uCommandSampleConfig.pas',
  uCommandSampleOptions in 'uCommandSampleOptions.pas';

var
  parseresult: ICmdLineParseResult;

begin
  try
    //parse the command line options
    parseresult := TOptionsRegistry.Parse;
    if parseresult.HasErrors then
    begin
      Writeln('Invalid options :');
      Writeln;
      Writeln(parseresult.ErrorText);
      Writeln;
      Writeln('Usage : commandsample [command] [options]');
      TOptionsRegistry.PrintUsage(
          procedure(const value: string)
        begin
          Writeln(value);
        end);
    end
    else
    begin
      if parseresult.CommandName = '' then
      begin
        Writeln;
        Writeln('Usage : commandsample [command] [options]');
        TOptionsRegistry.PrintUsage(
          procedure(const value: string)
          begin
            Writeln(value);
          end);
      end
      else
      begin
        Writeln('Command : ' + parseresult.CommandName);
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
