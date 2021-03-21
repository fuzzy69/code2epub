module epub;

import std.array : join, replace;
import std.datetime.systime : Clock;
import std.file : DirEntry, dirEntries, exists, read, readText, mkdirRecurse, SpanMode, write;
import std.format : format;
import std.range : enumerate;
import std.regex : regex, replaceFirst;
import std.string : representation, strip, stripRight;
import std.stdio : writeln;
import std.zip : ArchiveMember, ZipArchive;

import data : containerText, content, mimetypeText, nav, pageTemplate, styleText, toc;

/// Returns string with a safe representation of HTML entities
string replaceHtmlEntities(string text)
{
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
}

/// Returns formatted string ready for including in pre tag
string formatPage(string text)
{
    // auto re = regex(r"/\*.*[GNU Library General Public License|MIT|BSD].*\*/", "is");
    // return text.replaceHtmlEntities.replace("\n", "\n ").replaceFirst(re, "").strip;
    return text.replaceHtmlEntities.replace("\n", "\n ").strip;
}

/// Creates an EPUB file
void createEpub(string title, string[] pages, string[] titles,
        string outputFilePath, string author, string repoUrl)
{
    // Create Epub
    auto currentDateTime = Clock.currTime();
    auto zip = new ZipArchive();
    auto am = new ArchiveMember();
    // Mimetype
    am = new ArchiveMember();
    am.name = "mimetype";
    am.expandedData(mimetypeText.dup.representation);
    am.time(currentDateTime);
    zip.addMember(am);
    // Container
    am = new ArchiveMember();
    am.name = "META-INF/container.xml";
    am.expandedData(containerText.dup.representation);
    am.time(currentDateTime);
    zip.addMember(am);
    // Styles
    am = new ArchiveMember();
    am.name = "EPUB/style/nav.css";
    am.expandedData(styleText.dup.representation);
    am.time(currentDateTime);
    zip.addMember(am);
    string pageTitle;
    string pageFileName;
    // int i;
    // string page;
    string[] navPages;
    string[] contentPages;
    string[] tocPages;
    string[] manifestItems;
    string[] spineItems;
    string[] navMapItems;
    foreach (i, page; pages.enumerate())
    {
        // writeln(page);
        pageTitle = titles[i];
        pageFileName = format!"chap_%04d.xhtml"(i);
        am = new ArchiveMember();
        am.name = "EPUB/" ~ pageFileName;
        // Format page
        // page = replaceHtmlEntities(page);
        page = formatPage(page);
        string pageHtml = format!pageTemplate(pageTitle, pageTitle, page);
        am.expandedData(pageHtml.dup.representation);
        // am.expandedData(page.dup.representation);
        am.time(currentDateTime);
        zip.addMember(am);
        // Nav
        navPages ~= format!`<li>
          <a href="%s">%s</a>
        </li>`(pageFileName, pageTitle);
        // Content
        manifestItems ~= format!`    <item href="chap_%04d.xhtml" id="chapter_%04d" media-type="application/xhtml+xml"/>`(
                i, i);
        spineItems ~= format!`   <itemref idref="chapter_%04d"/>`(i);
        // TOC
        navMapItems ~= format!`    <navPoint id="%s">
      <navLabel>
        <text>%s</text>
      </navLabel>
      <content src="%s"/>
    </navPoint>`(pageTitle, pageTitle, pageFileName);
    }
    // Nav
    immutable(string) navText = format!nav(title, title, navPages.join("\n"));
    am = new ArchiveMember();
    am.name = "EPUB/nav.xhtml";
    am.expandedData(navText.dup.representation);
    am.time(currentDateTime);
    zip.addMember(am);
    // Content
    immutable(string) contentText = format!content(title, title, author,
            repoUrl, manifestItems.join("\n"), spineItems.join("\n"));
    am = new ArchiveMember();
    am.name = "EPUB/content.opf";
    am.expandedData(contentText.dup.representation);
    am.time(currentDateTime);
    zip.addMember(am);
    // TOC
    immutable(string) tocText = format!toc(navMapItems.join("\n"));
    am = new ArchiveMember();
    am.name = "EPUB/toc.ncx";
    am.expandedData(tocText.dup.representation);
    am.time(currentDateTime);
    zip.addMember(am);
    // Build the archive
    void[] compressed_data = zip.build();
    // Write to a file
    write(outputFilePath, compressed_data);
}
