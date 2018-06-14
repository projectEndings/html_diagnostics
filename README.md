# HTML Diagnostics

Building off of the work of the [TEI diagnostics](http://github.com/projectEndings/diagnostics), this repository offers a way to check a statically built project comprised of HTML documents for referential integrity. In other words, if your project is statically build and contained within one folder that is meant, for instance, to be deployed on an eXist server, then you can point this built at your project directory to ensure that all of your internal references are correct.

## Code

First, clone or download this directory.

This build can be run either using oXygen XML editor or at the command-line. If you run this in the command-line, you must have Ant installed.


This diagnostics takes the form of an ANT build that checks your HTML documents using XSLT. It can be run at the command line like so:

```
ant -lib utilities
```

If you know the path to your project directory, you can pass the project directory to it like so:

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

### Example

For an example of how the diagnostics work, see the [examples directory](/example) and test running the diagnostics by running this command:

```
ant -lib utilities -DprojectDir=example/test
```

You can see an older output in that directory as well.
    
## Assumptions / Known Issues

* All of your files are contained within one project directory
* `@xml:base` is *not* handled
* Only documents in the XHTML namespace are handled (http://www.w3.org/1999/xhtml)
* Java directory chooser is sometimes hidden behind oXygen (see issue #2)

### Why are only local files checked?

This build uses Saxon9He, which cannot use Java extensions (PE or EE only) and thus cannot take advantage of the file:exists function.

While you you could use the doc-available or unparsed-text-avaialble functions through Saxon to check for the existence of XML/text documents in the local file-system (as we do in the TEI diagnostics), this build uses a key and index system instead. As explained [here](https://www.saxonica.com/html/documentation/functions/fn/doc-available.html):
> Saxon effectively executes the doc() function and returns true if it succeeded; as a side-effect, the document will be available in memory for use when the doc() function is subsequently called with this URI.
    
While in many cases this is desirable, for projects of any significant size (for example, [*The Map of Early Modern London*](http://mapoflondon.uvic.ca/)) storing thousands of documents in memory requires a significant amount of memory, which can either result in poor performance or errors.
