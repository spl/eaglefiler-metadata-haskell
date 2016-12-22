This is a simple library for extracting and modeling the metadata of records in
[EagleFiler](https://c-command.com/eaglefiler/), a document management
application for Mac OS X.

To use this library, you must first extract the metadata for records you select
in EagleFiler using the included AppleScript,
[`eaglefiler-export-csv.applescript`](./eaglefiler-export-csv.applescript). You
can follow [these installation instructions](https://c-command.com/scripts/),
which are the same as [this
script](https://c-command.com/scripts/eaglefiler/export-csv), the basis for the
included script.

After extracting the metadata CSV, read the file into a lazy `ByteString` and
use the `EagleFiler.Metadata.decodeMetadata` function to parse the CSV into
meaningful types. Hopefully, you can then do something useful with the data.
