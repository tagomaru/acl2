; FTY -- Kestrel Extensions
;
; Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "FTY")

(include-book "bit-list")
(include-book "byte")
(include-book "byte-list")
(include-book "byte-list20")
(include-book "byte-list32")
(include-book "byte-list64")
(include-book "defbyte")
(include-book "defbyte-standard-instances")
(include-book "defbytelist")
(include-book "defbytelist-standard-instances")
(include-book "deffixtype-alias")
(include-book "deflist-of-len")
(include-book "defomap")
(include-book "defset")
(include-book "map")
(include-book "nibble")
(include-book "nibble-list")
(include-book "nati")
(include-book "set")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc fty-extensions
  :parents (acl2::kestrel-books fty)
  :short
  (xdoc::topstring "Extensions of "
                   (xdoc::seetopic "fty" "FTY")
                   " in the "
                   (xdoc::seetopic "acl2::kestrel-books" "Kestrel Books")
                   ".")
  :long
  (xdoc::topstring-p
   "These could be merged with FTY at some point."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc specific-types
  :parents (fty-extensions fty)
  :short
  (xdoc::topstring "Various specific "
                   (xdoc::seetopic "fty" "fixtypes")
                   ".")
  :long
  (xdoc::topstring-p
   "These complement the "
   (xdoc::seetopic "basetypes" "base types")
   " and the "
   (xdoc::seetopic "baselists" "base list types")
   "."))
