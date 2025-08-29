xquery version "3.1";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

let $edition   := request:get-parameter("edition", ())
let $target   := request:get-parameter("target", ())
let $name     := request:get-parameter("name", ())
let $query    := request:get-parameter("query", ())

return
  if (empty($target) or empty($name)) then
      <error>Missing target or name</error>
  else (
      xmldb:update("/db/myapp/files.xml",
        let $file := /files/file[@target=$target]
        return
          if (empty($file)) then
              (: Create a new <file> entry if missing :)
              update insert
                <file target="{$target}">
                  <preference>
                    <name>{$name}</name>
                    <query>{$query}</query>
                  </preference>
                </file>
              into /files
          else
              update insert
                <preference>
                  <name>{$name}</name>
                  <query>{$query}</query>
                </preference>
              into $file
      ),
      <response status="ok">Preference added</response>
  )
