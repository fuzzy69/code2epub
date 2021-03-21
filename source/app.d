import std.algorithm.searching : endsWith, startsWith;
import std.array : join, split;
import std.datetime.systime : Clock;
import std.file : DirEntry, dirEntries, exists, isDir, read, readText,
    mkdirRecurse, SpanMode, write, getcwd, thisExePath;
import std.getopt : getopt, defaultGetoptPrinter, config, GetOptException;
import std.path : asRelativePath, baseName, buildPath, dirName;
import std.process : execute;
import std.regex : regex, replaceFirst;
import std.stdio : writeln, writefln, File, stderr;
import std.string : representation, strip, stripRight;
import std.net.curl : download;
import std.uni : toLower;
import std.utf : byChar;
import std.zip : ArchiveMember, ZipArchive;

import url : parseURL;

import config : PROJECT_URL, TITLE, TITLE_SHORT;
import data : containerText, mimetypeText, styleText, toc, content, nav;
import epub : createEpub;
import misc : ExitCode;
import text : getMatch;
import app_version : VERSION;

int main(string[] args)
{
    auto opt = getopt(args, config.bundling, config.passThrough);

    if (opt.helpWanted)
    {
        writefln("%s v.%s", TITLE, VERSION);
        writefln("Example usage: %s REPO_URL [OUTPUT_DIR] [EPUB_NAME]", TITLE_SHORT);
        defaultGetoptPrinter("Options:", opt.options);

        return ExitCode.SUCCESS;
    }

    if (args.length < 2)
    {
        writeln("Please provide URL to git repo!");

        return ExitCode.ERROR;
    }

    immutable(string) repoUrl = args[1];
    immutable(string) outputDir = (args.length > 2) ? args[2] : getcwd();
    string projectName = (args.length > 3) ? args[3] : "";
    string repoDirPath;
    string author = "";

    // Verify URL
    if (repoUrl.startsWith("http"))
    {
        auto url = parseURL(repoUrl);
        author = url.path.dirName.strip("/");
        projectName = url.path.baseName.stripRight(".git");
        auto match = getMatch(repoUrl, `github.com/[a-zA-Z0-9\-]+/(.*)$`);
        if (match == null)
        {
            writefln("Failed to extract project name from %s!", repoUrl);
            return ExitCode.ERROR;
        }
        projectName = (url.path.baseName.endsWith(".git")) ? url.path
            .baseName[0 .. $ - 4] : url.path.baseName;
        repoDirPath = buildPath(outputDir, projectName);

        // Clone repo
        if (!exists(repoDirPath))
        {
            auto cmd = execute([
                    "git", "clone", "--depth", "1", repoUrl, repoDirPath
                    ]);
            if (cmd.status != 0)
            {
                return ExitCode.ERROR;
            }
        }
    }
    else // Local repo
    {
        if (!exists(repoUrl))
        {
            writefln("Invalid path to project source directory %s!", repoUrl);
            return ExitCode.ERROR;
        }
        if (!isDir(repoUrl))
        {
            writefln("%s is not a directory!", repoUrl);
            return ExitCode.ERROR;
        }
        projectName = repoUrl.baseName;
        repoDirPath = repoUrl;
    }
    auto repoDirBase = dirName(repoDirPath);
    // File extensions
    string[] fileExtensions = [
        ".c", ".cc", ".cpp", ".cxx", ".hxx", ".cs", ".d", ".h", ".hh", ".hpp",
        ".py"
    ];
    immutable(string) fileExtensionsFilePath = buildPath(thisExePath.dirName, "file_extensions.txt");
    if (!fileExtensionsFilePath.exists)
    {
        fileExtensionsFilePath.write(fileExtensions.join(' '));
    }
    else
    {
        fileExtensions = fileExtensionsFilePath.readText().split(' ');
    }
    immutable(string) outputName = (args.length > 2) ? args[2] : null;
    // List files
    auto dFiles = dirEntries(repoDirPath, SpanMode.depth);
    string[] pages;
    string[] titles;
    foreach (DirEntry dirEntry; dFiles)
    {
        bool hasExtension = false;
        foreach (string fileExtension; fileExtensions)
        {
            hasExtension = dirEntry.name.toLower.endsWith(fileExtension);
            if (hasExtension)
                break;
        }
        if (hasExtension)
        {
            writeln(dirEntry.name);
            try
            {
                const string content = readText(dirEntry.name);
                // Strip license text
                // pages ~= replaceFirst(content, regex(`(?si)/\*(.*?)license(.*?)\*/`), "").strip;
                pages ~= content;
                titles ~= dirEntry.name[repoDirBase.length .. $];
            }
            catch (Exception e)
            {
                stderr.writefln("Failed to read file '%s'! Details: %s", dirEntry.name, e.msg);
            }
        }
    }
    if (pages.length == 0 || titles.length == 0)
    {
        writeln("Nothing to convert!");
        return ExitCode.SUCCESS;
    }
    immutable(string) outputFile = buildPath(outputDir, projectName ~ ".epub");
    createEpub(projectName, pages, titles, outputFile, author, repoUrl.stripRight(".git"));
    if (exists(outputFile))
        writefln("EPUB successfully saved to %s", outputFile);
    else
        writefln("Failed to save EPUB to %s", outputFile);
    writeln("Done.");

    return ExitCode.SUCCESS;
}
