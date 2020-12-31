module text;

import std.regex : ctRegex, matchFirst;


string getMatch(string text, string regexPattern)
{
    // auto regexp = ctRegex!(regexPattern);
    // auto match = matchFirst(text, regexp);
    auto match = matchFirst(text, regexPattern);

    return (match.empty) ? null : match[1];
}
