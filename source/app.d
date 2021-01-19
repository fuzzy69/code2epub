import std.algorithm.searching : endsWith, startsWith;
import std.array : split;
import std.datetime.systime : Clock;
import std.file : DirEntry, dirEntries, exists, read, readText, mkdirRecurse, SpanMode, write, getcwd;
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
    auto opt = getopt(
        args, 
        config.bundling, config.passThrough
    );

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
    immutable(string) outputDir = (args.length > 2)? args[2] : getcwd();
    string projectName = (args.length > 3)? args[3] : "";
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
        //projectName = match.stripRight(".git");
        projectName = (url.path.baseName.endsWith(".git"))? url.path.baseName[0 .. $-4] : url.path.baseName;
        repoDirPath = buildPath(outputDir, projectName);

        // Clone repo
        if (!exists(repoDirPath))
        {
            auto cmd = execute(["git", "clone", "--depth", "1", repoUrl, repoDirPath]);
            if (cmd.status != 0)
            {
                return ExitCode.ERROR;
            }
        }
        // Download archive
        // string repoArchiveUrl = repoUrl.stripRight(".git") ~ "/archive/master.zip";
        // string repoArchiveFilePath = outputDir ~ projectName ~ ".zip";
        // if (!exists(repoArchiveFilePath))
        // {
        //     writefln("Downloading %s to %s ...", repoArchiveUrl, repoArchiveFilePath);
        //     download(repoArchiveUrl, repoArchiveFilePath);
        //     repoDirPath = outputDir ~ projectName ~ "-master";
        //     // Unpack archive
        // }
    }
    else // Local repo
    {
        if (!exists(repoUrl))
        {
            writefln("Invalid path to project source directory %s!", repoUrl);
            return ExitCode.ERROR;
        }
        // auto chunks = repoUrl.split("/");
        // projectName = chunks[$ - 1];
        projectName = repoUrl.baseName;
        repoDirPath = repoUrl;
    }

     immutable(string) outputName = (args.length > 2)? args[2] : null;
     // List files
     auto dFiles = dirEntries(repoDirPath, SpanMode.depth);
     string[] pages;
     string[] titles;
     foreach (DirEntry dirEntry; dFiles)
     {
         if (dirEntry.name.toLower.endsWith(".c", ".cc", ".cpp", ".cxx", ".hxx", ".cs", ".d", ".h", ".hh", ".hpp", ".py"))
         {
             writeln(dirEntry.name);
             try
             {
                 const string content = readText(dirEntry.name);
                 // Strip license text
                 // pages ~= replaceFirst(content, regex(`(?si)/\*(.*?)license(.*?)\*/`), "").strip;
                 pages ~= content;
                 // auto startIndex = outputDir.length > 0? outputDir.length : 0;
                 titles ~= dirEntry.name[outputDir.length .. $];
                 // auto title = asRelativePath(dirEntry.name, outputDir).byChar.;
                 // writeln(title);
                 // titles ~= title.startsWith("/")? title : "/" ~ title;
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
     // if (outputName)
     //     createEpub(projectName, pages, titles, outputDir ~ outputName ~ ".epub", author, repoUrl.stripRight(".git"));
     // else
     // createEpub(projectName, pages, titles, outputDir ~ projectName ~ ".epub", author, repoUrl.stripRight(".git"));
     immutable(string) outputFile = buildPath(outputDir, projectName ~ ".epub");
     createEpub(projectName, pages, titles, outputFile, author, repoUrl.stripRight(".git"));
     if (exists(outputFile))
         writefln("EPUB successfully saved to %s", outputFile);
     else
         writefln("Failed to save EPUB to %s", outputFile);
     writeln("Done.");

     return ExitCode.SUCCESS;
}
