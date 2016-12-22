-- This is an AppleScript to extract metadata from files in EagleFiler.
--
-- Adapted from: http://c-command.com/scripts/eaglefiler/export-csv
--
-- Main changes from above:
--   * UTF-8 output
--   * More fields

on run
	set _fileName to choose file name with prompt "Export CSV" default name "Metadata.csv"
	tell application "EagleFiler"
		set _records to selected records of browser window 1
		set _file to open for access _fileName with write permission
		set _headerFields to {"File Name", "File Path", "Record Kind", "Title", "From", "Source URL", "Date Created", "Date Added", "Date Modified", "Label Index", "Tags", "Notes"}
		set _headerLine to my lineFromFields(_headerFields)
		write _headerLine as Çclass utf8È to _file
		repeat with _record in _records
			set _line to my lineFromFields(my fieldsFromRecord(_record))
			write _line as Çclass utf8È to _file
		end repeat
		close access _file
	end tell
end run

on lineFromFields(_fields)
	set _quotedFields to {}
	repeat with _field in _fields
		copy my quoteCSV(_field) to end of _quotedFields
	end repeat
	set lf to ASCII character 10
	return my join(_quotedFields, ",") & lf
end lineFromFields

on fieldsFromRecord(_record)
	tell application "EagleFiler"
		set _fields to {}
		-- File Name
		copy _record's filename to end of _fields
		-- File Path
		set _file to _record's file
		set _path to _file's POSIX path
		copy _path to end of _fields
		-- Record Kind
		copy _record's kind to end of _fields
		-- Title
		copy _record's title to end of _fields
		-- From
		copy _record's from name to end of _fields
		-- Source URL
		copy _record's source URL to end of _fields
		-- Date Created
		copy my iso8601_date_time(_record's creation date) to end of _fields
		-- Date Added
		copy my iso8601_date_time(_record's added date) to end of _fields
		-- Date Modified
		copy my iso8601_date_time(_record's modification date) to end of _fields
		-- Label Index
		copy _record's label index as text to end of _fields
		-- Tags
		set _tagNames to {}
		set _tags to _record's assigned tags
		repeat with _tag in _tags
			copy _tag's name to end of _tagNames
		end repeat
		copy my join(_tagNames, ",") to end of _fields
		-- Notes
		copy _record's note text to end of _fields
		return _fields
	end tell
end fieldsFromRecord

on quoteCSV(_string)
	set dq to "\""
	return dq & my replace(_string, dq, dq & dq) & dq
end quoteCSV

on replace(_string, _source, _replacement)
	set AppleScript's text item delimiters to _source
	set _items to every text item of _string
	set AppleScript's text item delimiters to _replacement
	return _items as Unicode text
end replace

on join(_list, _sep)
	set _temp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to _sep
	set _result to _list as text
	set AppleScript's text item delimiters to _temp
	return _result
end join

on iso8601_date(_dt)
	set {year:_y, month:_m, day:_d} to _dt
	set _y to text 2 through -1 of ((_y + 10000) as text)
	set _m to text 2 through -1 of ((_m + 100) as text)
	set _d to text 2 through -1 of ((_d + 100) as text)
	return _y & "-" & _m & "-" & _d
end iso8601_date

on iso8601_date_time(_dt)
	set {hours:_h, minutes:_m, seconds:_s} to _dt
	set _h to text 2 through -1 of ((_h + 100) as text)
	set _m to text 2 through -1 of ((_m + 100) as text)
	set _s to text 2 through -1 of ((_s + 100) as text)
	return my iso8601_date(_dt) & "T" & _h & ":" & _m & ":" & _s
end iso8601_date_time
