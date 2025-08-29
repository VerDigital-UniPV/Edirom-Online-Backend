xquery version "3.1";

import module namespace request="http://exist-db.org/xquery/request";

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