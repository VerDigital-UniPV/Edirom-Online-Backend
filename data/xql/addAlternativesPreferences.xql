xquery version "3.1";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace util="http://exist-db.org/xquery/util";

(: --- Parameters --- :)
let $edition := request:get-parameter("edition", ())
let $target  := request:get-parameter("target", ())
let $name    := request:get-parameter("name", ())
let $query   := request:get-parameter("query", ())

(: --- Resolve doc path --- :)
let $doc-path :=
  $edition => replace("/ediromEditions/.*$", "") || "/alternatives-preferences.xml"

(: --- Validation --- :)
let $valid := $target and $name

(: --- Ensure document exists (root <files/>) --- :)
let $ensure-doc :=
  if (doc-available($doc-path)) then ()
  else xmldb:store(
         util:collection-name($doc-path),
         util:document-name($doc-path),
         <files/>
       )

(: --- Reusable node to insert --- :)
let $preference :=
  <preference>
    <name>{$name}</name>
    <query>{$query}</query>
  </preference>

(: --- Apply updates when valid --- :)
let $apply :=
  if ($valid) then (
    let $doc  := doc($doc-path)
    let $file := $doc/files/file[@target = $target]
    return (
      (: upsert <file target="..."> :)
      if (empty($file)) then
        update insert <file target="{$target}"/> into $doc/files
      else (),
      (: insert preference :)
      update insert $preference into $doc/files/file[@target = $target]
    )
  ) else ()

(: --- Response --- :)
return
  if ($valid) then <response status="ok">Preference added</response>
  else <error>Missing target or name</error>
