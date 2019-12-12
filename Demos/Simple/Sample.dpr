{ *************************************************************************** }
{ }
{ VSoft.CommandLine }
{ }
{ Copyright (C) 2014 Vincent Parrett }
{ }
{ vincent@finalbuilder.com }
{ http://www.finalbuilder.com }
{ }
{ }
{ *************************************************************************** }
{ }
{ Licensed under the Apache License, Version 2.0 (the "License"); }
{ you may not use this file except in compliance with the License. }
{ You may obtain a copy of the License at }
{ }
{ http://www.apache.org/licenses/LICENSE-2.0 }
{ }
{ Unless required by applicable law or agreed to in writing, software }
{ distributed under the License is distributed on an "AS IS" BASIS, }
{ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{ See the License for the specific language governing permissions and }
{ limitations under the License. }
{ }
{ *************************************************************************** }

program Sample;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  CmdLine.Intf,
  CmdLine.OptionsRegistry,
  uSampleConfig in 'uSampleConfig.pas',
  uSampleOptions in 'uSampleOptions.pas';

var
  parseresult: ICmdLineParseResult;

begin
  try
    //parse the command line options
    parseresult := TOptionsRegistry.Parse;

    if parseresult.HasErrors then
    begin
      Writeln('Invalid command line :');
      Writeln;
      Writeln(parseresult.ErrorText);
      TOptionsRegistry.DescriptionTabSize := 20;
      TOptionsRegistry.PrintUsage(
          procedure(const value: string)
        begin
          Writeln(value);
        end);
    end
    else
    begin
      Writeln('Input : ' + TSampleOptions.InputFile);
      Writeln('Output : ' + TSampleOptions.OutputFile);
      Writeln('Mangle : ' + BoolToStr(TSampleOptions.MangleFile, true));
    end;
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.