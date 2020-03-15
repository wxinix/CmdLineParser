{***************************************************************************}
{                                                                           }
{           Command Line Parser                                             }
{           Copyright (C) 2020 Wuping Xin                                   }
{           KLD Engineering, P. C.                                          }
{           http://www.kldcompanies.com                                     }
{                                                                           }
{           VSoft.CommandLine                                               }
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

unit CmdLine.Consts;

interface

const
  DefaultDescriptionTabSize = 15;
  ShortNameExtraSpaceSize   = 5;

const
  OptionTokens: array [1 .. 4] of string = ('--', '-', '/', '@');

const
  SErrParsingParamFile    = 'Error parsing parameter file [%s]: %s';
  SErrSettingOpt          = 'Error setting option: %s to %s: %s';
  SGlobalOptText          = 'global optoins: ';
  SInvalidEnumValue       = 'Invalid enum value: %s.';
  SOptNameDuplicated      = 'Option: %s already registered';
  SOptions                = 'options: ';
  SParamFileMissing       = 'Parameter File[%s] does not exist.';
  SReqOptMissing          = 'Required option missing: [%s].';
  SReqAnonymousOptMissing = 'Required anonymous option missing.';
  StrBoolean              = 'Boolean';
  SUnknownCommand         = 'Unknown command: %s.';
  SUnknownOpt             = 'Unknown option: %s.';
  SUnknownAnonymousOpt    = 'Unknown anonymous option: %s.';
  SUsage                  = 'usage: ';

  SOptNameMissing =
    'Option name required - use RegisterUnNamed for un-named options.';

  SInvalidOptType =
    'Invalid option type: only string, integer, float, boolean, enum and ' +
    'set types are supported.';

  SOptValueMissing =
    'Option[%s] expects a following %s <value>, but none was found.';

implementation

end.
