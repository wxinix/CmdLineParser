unit uCommandSampleConfig;

interface

implementation


uses
  CmdLine.Intf, CmdLine.OptionsRegistry, uCommandSampleOptions;

procedure ConfigureOptions;
var
  cmd    : TCommandDefinitionRecord;
  option : IOptionDefinition;
begin
  option := TOptionsRegistry.RegisterOption<boolean>('verbose','v','verbose output',
    procedure(const value : boolean)
    begin
        TGlobalOptions.Verbose := value;
    end);
  option.HasValue := false;

  option := TOptionsRegistry.RegisterOption<string>('outputpath','out','The path to the exe to output',
                  procedure(const value : string)
                  begin
                      TGlobalOptions.OutPath := value;
                  end);

  option.Required := False;


  cmd := TOptionsRegistry.RegisterCommand('help','h','get some help','','commandsample help [command]');
  option := cmd.RegisterAnonymousOption<string>('The command you need help for',
                  procedure(const value : string)
                  begin
                      THelpOptions.HelpCommand := value;
                  end);

  cmd := TOptionsRegistry.RegisterCommand('install','','install something', '', 'commandsample install [options]');
  option := cmd.RegisterOption<string>('installpath','i','The path to the exe to install',
                  procedure(const value : string)
                  begin
                      TInstallOptions.InstallPath := value;
                  end);
  option.Required := true;

  option := cmd.RegisterOption<string>('outputpath','out','The path to the exe to output',
                  procedure(const value : string)
                  begin
                      TInstallOptions.OutPath := value;
                  end);
  option.Required := False;
end;



initialization
  ConfigureOptions;

end.
