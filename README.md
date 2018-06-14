# HTML Diagnostics

Building off of the work of the TEI diagnostics, this repository offers a way to check statically built HTML output for referential intergrity.

The big assumption of this code is that the entirety of your site is contained within one central project folder.

## Code

This diagnostics takes the form of an ANT build that checks your HTML documents using XSLT. It can be run at the command line like so:

```
ant -lib utilities
```

If you already know your project directory, you can pass the project directory to it like so:

```
ant -lib utilities -DprojectDir=../path/to/your/directory
```

## How it works

1. A project directory is chosen, which should contain all of the (X)HTM(L) files that you want to check
1. A diagnostics directory is created *at the same level as the chosen project directory*
1. A file called `system_files.xml` is created in the temporary diagnostics directory; it is a simple XML file that lists the absolute URIs for all of the files in the selected project directory
1. The [create_indexes.xsl](xsl/create_indexes.xsl) creates three index files for each document:
    * An internalRefs document, which lists all of the internal pointers (i.e. hash pointers)
    * An externalRefs document, which lists all of the external references
    * An ids document, which lists all of the `@id`s in the document
1.  All of the internal references are checked. An XSLT iterates through all of the internalRefs documents and checks to see whether that internalRef is declared as an id in the corresponding ids document
1. All of the external references are checked. An XSLT iterates through all of the distinct references, grouping first by base-uri (i.e. just to the document) and evaluating whether or not that document exists. If it does exist, then the XSLT iterates through all of the references to ids within that document (i.e. doc.html#pointer) and checks whether or not that document's id index contains that fragment (i.e. whether or not `doc_ids.xml` contains `pointer`)
1. An HTML report page is created that lists some statistics and returns all of the errors grouped by document. You can set the `-DgroupByDoc` parameter to `false` if you would prefer to see the list of errors with the documents as a sublist of each error.
    
## Assumptions / Known Issues

* @xml:base is *not* handled
* Only XHTML namespace is handled (http://www.w3.org/1999/xhtml)
* Java directory chooser displays behind oXygen sometimes (see issue #2)
* Only local files are checked
   * This only check local files as it uses Saxon9He, which cannot use java extensions (PE or EE only)
   * This also doesn't use the functions document-available or unparsed-text-available as those functions store the documents in memory, which for projects of any considerable size is not only inefficient, but also requires a significant amount of memory.