unit uCommandSampleConfig;

interface

implementation

uses
  CmdLine.OptionsRegistry, uCommandSampleOptions;

procedure ConfigureOptions;
var
  LHelpCommand, LInstallCommand: TCommandDefinitionHelper;
  LOption: IOptionDefinition;
begin
  LOption := TOptionsRegistry.RegisterOption<boolean>('verbose','v','verbose output',
    procedure(const aValue: Boolean)
    begin
      TGlobalOptions.Verbose := aValue;
    end);
  LOption.RequiresValue := False;

  LOption := TOptionsRegistry.RegisterOption<string>('outputpath','out','The path to the exe to output',
    procedure(const aValue: string)
    begin
      TGlobalOptions.OutPath := aValue;
    end);
  LOption.Required := False;

  LHelpCommand := TOptionsRegistry.RegisterCommand('help','h','get some help','','commandsample help [command]');
  LHelpCommand.RegisterAnonymousOption<string>('The command you need help for',
    procedure(const aValue: string)
    begin
      THelpOptions.HelpCommand := aValue;
    end);

  LInstallCommand := TOptionsRegistry.RegisterCommand('install','','install something', '', 'commandsample install [options]');
  LOption := LInstallCommand.RegisterOption<string>('installpath','i','The path to the exe to install',
    procedure(const aValue: string)
    begin
      TInstallOptions.InstallPath := aValue;
    end);
  LOption.Required := true;

  LOption := LInstallCommand.RegisterOption<string>('outputpath','out','The path to the exe to output',
    procedure(const aValue: string)
    begin
      TInstallOptions.OutPath := aValue;
    end);
  LOption.Required := False;
end;

initialization
  ConfigureOptions;

end.
