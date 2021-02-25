# CmdlineParser
Light-weight and flexible command line parser for Delphi applications

The command line string should start with global options (named or unnamed), then a named command, followed by the named command's options (named or unnamed). Multiple named commands can be registered, but only one can show up in the command line. Note, all command line arguments are separated by a space, but if the argument itself has a space then use double quotes or single quotes.

Some rules:
* Default name value separator is colon, i.e., ':'.
* A command line option can be prefixed by one of the four option token, e.g., --, -, /, and @. For example: --autosave:true, autosave is the option's name, true is its value.
* Command should not be prefixed by the token.
* Global anonymous options must appear before any named command in the command line.
* An invisible command owns global options. This command is the default command, and has no name.
* Once the parser encounters a named command (new command), all items after it will be treated as its options. Anonymous options will be searched only within the encountered command's registered anonymous options. Named options will be searched first within the encountered command's named options, and if nothing found, the search will continue with global options.
* Anonymous options must appear in the same order when registered. They can be mixed with named options, but the appearing order of all anonymous options must be in the same order as they are registered.
* Anonymous option is always required. A newly created option, unless explicitly specified, by default always requires value, but itself is not required (unless it is an unnamed option).

Check the unit test cases and samples for usages. Note - only the latest Delphi version is supported (currently 10.4.2 Sydney).