xquery version "3.1";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: OPTION DECLARATIONS ===================================================== :)

declare option output:method "xml";
declare option output:media-type "text/xml";
declare option output:omit-xml-declaration "no";
declare option output:indent "yes";

let $edition := request:get-parameter("edition", ())
let $target := request:get-parameter("target", ())
let $name   := request:get-parameter("name", ())

(: --- Resolve doc path --- :)
let $doc-path :=
  $edition => replace("/ediromEditions/.*$", "") || "/alternatives-preferences.xml"

(: --- Validation --- :)
let $valid := $target and $name

(: --- Apply updates when valid --- :)
let $apply :=
  if ($valid) then (
    let $doc  := doc($doc-path)
    return (
      update delete $doc/files/file[@target=$target]/preference[name=$name]
    )
  ) else ()

(: --- Response --- :)
return
  if ($valid) then <response status="ok">The preference has been removed or it was never present</response>
  else <error>Missing target or name</error>