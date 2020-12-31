# Code2Epub


## Requirements

Compile-time dependencies:

- D language compiler (tested  on DMD64 D Compiler v2.083.0)
- DUB

Run-time dependencies:

- git

## Compilation

Navigate to a project directory and execute:
```
dmd build
```

## Usage

```
code2epub REPO_URL [OUTPUT_DIR] [EPUB_NAME]
```

Save repo as EPUB document:
```
code2epub https://github.com/fuzzy69/code2epub.git
```

Save EPUB from local code project directory
```
code2epub /home/user/code2epub
```

Choose output directory and EPUB document name:
```
code2epub https://github.com/fuzzy69/code2epub.git /home/user/Documents Code2Epub
```

## TODO

Noticed issues:
- fix occasional project file path parsing which generates invalid file/project names 
- improve source code formatting
