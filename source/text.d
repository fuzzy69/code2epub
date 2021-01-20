module text;

import std.regex : ctRegex, matchFirst;


/// Returns string from text that matches provided regular expression
string getMatch(string text, string regexPattern)
{
    auto match = matchFirst(text, regexPattern);

    return (match.empty) ? null : match[1];
}
