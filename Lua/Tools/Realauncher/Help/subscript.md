## Escaping Semicolons

Semicolons should be placed inside quotes in order to be recognized as being part of subscript. The quotes will be removed from the string before writing to file.

In order to preserve the semicolon's quotes in the subscript, they need to be escaped with a backsslash "\".

**Examples:**

- subscript l "itemvolume 0 ; itempitch 0 ; "

*result =* `itemvolume 0 ; itempitch 0 ; `

- subscript l "marker This \; marker \; has \; semicolons \; on \; the \; name \;"

*result =* `marker This ";" marker ";" has ";" semicolons ";" on ";" the ";" name ";"`