xquery version "3.1";

import module namespace request="http://exist-db.org/xquery/request";

let $edition := request:get-parameter("edition", ())
let $target := request:get-parameter("target", ())

return
  if (empty($target)) then
      doc("/db/myapp/files.xml")/files
  else
      doc("/db/myapp/files.xml")/files/file[@target=$target]