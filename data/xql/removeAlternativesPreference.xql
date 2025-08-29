xquery version "3.1";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

let $edition := request:get-parameter("edition", ())
let $target := request:get-parameter("target", ())
let $name   := request:get-parameter("name", ())

return
  if (empty($target) or empty($name)) then
      <error>Missing target or name</error>
  else (
      xmldb:update("/db/myapp/files.xml",
        update delete /files/file[@target=$target]/preference[name=$name]
      ),
      <response status="ok">Preference removed</response>
  )