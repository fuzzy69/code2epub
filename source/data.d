module data;

string mimetypeText = "application/epub+zip";
string containerText = `<?xml version='1.0' encoding='utf-8'?>
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
<rootfiles>
<rootfile media-type="application/oebps-package+xml" full-path="EPUB/content.opf"/>
</rootfiles>
</container>`;
string styleText = `
.title {
display: block;
font-size: 1em;
line-height: 1.2;
margin-bottom: 0;
margin-left: 5pt;
margin-right: 5pt;
margin-top: 0;
padding-left: 0;
padding-right: 0
}
.calibre1 {
display: block;
font-size: 1.375em;
font-weight: bold;
line-height: 1.2;
margin-bottom: 25pt;
margin-left: 0;
margin-right: 0;
margin-top: 7pt;
page-break-after: avoid;
text-align: left
}
.calibre2 {
line-height: 1.2
}
.calibre3 {
display: block
}
.calibre4 {
font-weight: bold
}
.noindent {
display: block;
margin-bottom: 4pt;
margin-left: 0;
margin-right: 0;
margin-top: 4pt;
text-indent: 0.002pt
}
.pd_skyblue {
color: #027095;
line-height: 1.2
}

@page {
margin-bottom: 5pt;
margin-top: 5pt
}

.programlisting1 {
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -webkit-font-smoothing: antialiased;
    -webkit-hyphens: none;
    -webkit-tap-highlight-color: transparent;
    background-color: #fbfbfb;
    box-sizing: border-box;
    clear: both;
    color: blue;
    display: block;
    font-family: "Droid Sans Mono", Courier, monospace;
    font-size: 1em;
    line-height: 1.5em;
    overflow: auto;
    overflow-x: unset;
    overflow-y: unset;
    text-indent: 0;
    white-space: pre-wrap;
    word-break: keep-all;
    word-wrap: break-word;
    padding: 0.5em 2em;
    border-top: #DDD solid 1px;
    border-bottom: #DDD solid 1px;
    margin: 0.5em 2em
}
`;
// Page template
immutable(string) pageTemplate = `<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" epub:prefix="z3998: http://www.daisy.org/z3998/2012/vocab/structure/#" lang="en" xml:lang="en">
  <head>
    <title>%s</title>
  </head>
  <body>
    <h1 class="title">%s</h1>
    <pre class="programlisting1">
%s
    </pre>
  </body>
</html>

`;

// EPUB/content.opf
immutable(string) content = `<?xml version='1.0' encoding='utf-8'?>
<package unique-identifier="id" version="3.0" xmlns="http://www.idpf.org/2007/opf" prefix="rendition: http://www.idpf.org/vocab/rendition/#">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
    <meta property="dcterms:modified">2019-08-14T12:24:50Z</meta>
    <meta content="Ebook-lib 0.17.1" name="generator"/>
    <dc:identifier id="id">%s</dc:identifier>
    <dc:title>%s</dc:title>
    <dc:language>en</dc:language>
    <dc:creator id="creator">%s</dc:creator>
    <dc:creator id="coauthor">source code</dc:creator>
    <dc:creator id="url">%s</dc:creator>
    <meta property="file-as" refines="#coauthor" scheme="marc:relators">source code</meta>
    <meta property="role" refines="#coauthor" scheme="marc:relators">ill</meta>
  </metadata>
  <manifest>
  %s
    <item href="toc.ncx" id="ncx" media-type="application/x-dtbncx+xml"/>
    <item href="nav.xhtml" id="nav" media-type="application/xhtml+xml" properties="nav"/>
    <item href="style/nav.css" id="style_nav" media-type="text/css"/>
  </manifest>
  <spine toc="ncx">
    <itemref idref="nav"/>
%s
  </spine>
</package>
`;

// EPUB/toc.ncx
immutable(string) toc = `<?xml version='1.0' encoding='utf-8'?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <head>
    <meta content="containers" name="dtb:uid"/>
    <meta content="0" name="dtb:depth"/>
    <meta content="0" name="dtb:totalPageCount"/>
    <meta content="0" name="dtb:maxPageNumber"/>
  </head>
  <docTitle>
    <text>containers</text>
  </docTitle>
  <navMap>
%s
  </navMap>
</ncx>
`;
// EPUB/nav.xhtml
immutable(string) nav = `<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="en" xml:lang="en">
  <head>
    <title>%s</title>
  </head>
  <body>
    <nav id="id" role="doc-toc" epub:type="toc">
      <h2>%s</h2>
      <ol>
%s
      </ol>
    </nav>
  </body>
</html>
`;
