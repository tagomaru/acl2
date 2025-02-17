; System Utilities -- Event Forms
;
; Copyright (C) 2018 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "std/util/define" :dir :system)
(include-book "std/util/defrule" :dir :system)
(include-book "xdoc/constructors" :dir :system)

(include-book "kestrel/std/system/pseudo-event-formp" :dir :system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc event-forms
  :parents (system-utilities-non-built-in)
  :short "Utilities for event forms.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define maybe-pseudo-event-formp (x)
  :returns (yes/no booleanp)
  :parents (event-forms)
  :short "Recognize @(tsee pseudo-event-formp) values and @('nil')."
  (or (pseudo-event-formp x)
      (null x))
  ///
  (defrule maybe-pseudo-event-formp-when-pseudo-event-formp
    (implies (pseudo-event-formp x)
             (maybe-pseudo-event-formp x))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define function-intro-macro
  ((enable booleanp "Enable function or not.")
   (non-executable booleanp "Make function non-executable or not."))
  :returns (macro (member-eq macro '(defun defund defun-nx defund-nx)))
  :parents (event-forms)
  :short "Macro (name) for introducing a function
          with given enablement and non-executability."
  (if enable
      (if non-executable
          'defun-nx
        'defun)
    (if non-executable
        'defund-nx
      'defund)))

(define theorem-intro-macro ((enable booleanp "Enable theorem or not."))
  :returns (macro (member-eq macro '(defthm defthmd)))
  :parents (event-forms)
  :short "Macro (name) for introducing a theorem with a given enablement."
  (if enable
      'defthm
    'defthmd))
