# HTML Diagnostics

Building off of the work of the TEI diagnostics, this repository offers a way to check statically built HTML output for referential intergrity.

The big assumption of this code is that the entirety of your site is contained within one central project folder.

## Code

This diagnostics takes the form of an ANT build that checks your HTML documents using XSLT. It can be run at the command line like so:

```
ant -lib utilities -Dsuffix=htm|html
```

Ensure that you use the -suffix parameter to set which suffix to check (either htm or html).