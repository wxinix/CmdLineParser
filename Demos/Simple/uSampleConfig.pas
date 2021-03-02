unit uSampleConfig;

interface

implementation

uses
  CmdlineParser, uSampleOptions;

procedure ConfigureOptions;
var
  LOption: IOptionDefinition;
begin
  LOption := TOptionsRegistry.RegisterOption<string>('inputfile', 'i', 'The file to be processed' + sLineBreak + 'if you dare!',
    procedure(const aValue: string)
    begin
      TSampleOptions.InputFile := aValue;
    end);
  LOption.Required := True;

  LOption := TOptionsRegistry.RegisterOption<string>('outputfile', 'out', 'The processed output file',
    procedure(const aValue: string)
    begin
      TSampleOptions.OutputFile := aValue;
    end);
  LOption.Required := True;

  LOption := TOptionsRegistry.RegisterOption<Boolean>('mangle', 'm', 'Mangle the file!',
    procedure(const aValue: Boolean)
    begin
      TSampleOptions.MangleFile := aValue;
    end);
  LOption.RequiresValue := False;

  LOption := TOptionsRegistry.RegisterOption<Boolean>('options', '', 'Options file', nil);
  LOption.IsOptionFile := True;  // Not required, default is false.
end;

initialization

ConfigureOptions;

end.
