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
