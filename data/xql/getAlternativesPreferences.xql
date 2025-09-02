xquery version "3.1";

import module namespace request="http://exist-db.org/xquery/request";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: OPTION DECLARATIONS ===================================================== :)

declare option output:method "xml";
declare option output:media-type "text/xml";
declare option output:omit-xml-declaration "no";
declare option output:indent "yes";

let $edition := request:get-parameter("edition", ())
let $target := request:get-parameter("target", ())

let $preferences :=
    $edition
    => replace("/ediromEditions/.*$", "")
    || "/alternatives-preferences.xml"
    
return
  if (empty($target)) then
      doc($preferences)/files
  else
      doc($preferences)/files/file[@target=$target]