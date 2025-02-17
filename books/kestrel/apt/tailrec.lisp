; APT (Automated Program Transformations) Library
;
; Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "APT")

(include-book "kestrel/utilities/error-checking/top" :dir :system)
(include-book "kestrel/utilities/event-macros/input-processing" :dir :system)
(include-book "kestrel/utilities/system/install-not-norm-event" :dir :system)
(include-book "kestrel/utilities/keyword-value-lists" :dir :system)
(include-book "kestrel/utilities/system/named-formulas" :dir :system)
(include-book "kestrel/utilities/orelse" :dir :system)
(include-book "kestrel/utilities/system/paired-names" :dir :system)
(include-book "kestrel/utilities/user-interface" :dir :system)
(include-book "kestrel/utilities/xdoc/defxdoc-plus" :dir :system)
(include-book "utilities/transformation-table")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc+ tailrec-implementation
  :parents (implementation tailrec)
  :short "Implementation of @(tsee tailrec)."
  :long
  "<p>
   The implementation functions have formal parameters
   consistently named as follows:
   </p>
   <ul>
     <li>
     @('state') is the ACL2 @(see state).
     </li>
     <li>
     @('wrld') is the ACL2 @(see world).
     </li>
     <li>
     @('ctx') is the context used for errors.
     </li>
     <li>
     @('old'),
     @('variant'),
     @('domain'),
     @('new-name'),
     @('new-enable'),
     @('wrapper'),
     @('wrapper-name'),
     @('wrapper-enable'),
     @('thm-name'),
     @('thm-enable'),
     @('non-executable'),
     @('verify-guards'),
     @('hints'),
     @('print'), and
     @('show-only')
     are the homonymous inputs to @(tsee tailrec),
     before being processed.
     These formal parameters have no types because they may be any values.
     </li>
     <li>
     @('wrapper-name-present') and
     @('wrapper-enable-present')
     are boolean flags indicating whether the corresponding inputs
     (whose name is obtained by removing @('-present') from these)
     are present (i.e. supplied by the user) or not.
     </li>
     <li>
     @('call') is the call to @(tsee tailrec) supplied by the user.
     </li>
     <li>
     @('old$'),
     @('variant$'),
     @('domain$'),
     @('new-name$'),
     @('new-enable$'),
     @('wrapper$'),
     @('wrapper-name$'),
     @('wrapper-enable$'),
     @('thm-name$'),
     @('thm-enable$'),
     @('non-executable$'),
     @('verify-guards$'),
     @('hints$'),
     @('print$'), and
     @('show-only$')
     are the results of processing
     the homonymous inputs (without the @('$')) to @(tsee tailrec).
     Some are identical to the corresponding inputs,
     but they have types implied by their successful validation,
     performed when they are processed.
     </li>
     <li>
     @('test') is the term @('test<x1,...,xn>') described in the documentation.
     </li>
     <li>
     @('base') is the term @('base<x1,...,xn>') described in the documentation.
     </li>
     <li>
     @('rec-branch') is the recursive branch of the target function,
     namely the term @('combine<nonrec<x1,...,xn>,
                                (old update-x1<x1,...,xn>
                                     ...
                                     update-xn<x1,...,xn>)>')
     described in the documentation.
     </li>
     <li>
     @('nonrec') is the term @('nonrec<x1,...,xn>')
     described in the documentation.
     </li>
     <li>
     @('updates') is the list of terms
     @('update-x1<x1,...,xn>'), ..., @('update-xn<x1,...,xn>')
     described in the documentation.
     </li>
     <li>
     @('r') is the homonymous fresh variable described in the documentation.
     </li>
     <li>
     @('q') is the homonymous fresh variable described in the documentation.
     </li>
     <li>
     @('combine-nonrec') is the term @('combine<nonrec<x1,...,xn>,r>')
     described in the documentation.
     </li>
     <li>
     @('combine') is the term @('combine<q,r>') described in the documentation.
     </li>
     <li>
     @('verbose') is a flag saying
     whether to print certain informative messages or not.
     </li>
     <li>
     @('app-cond-present-names') is the list of the names (keywords) of
     the applicability conditions that are present.
     </li>
     <li>
     @('app-cond-thm-names') is an alist
     from the keywords that identify the applicability conditions
     to the corresponding generated theorem names.
     </li>
     <li>
     @('old-unnorm-name') is the name of the generated theorem
     that installs the non-normalized definition of the target function.
     </li>
     <li>
     @('new-unnorm-name') is the name of the generated theorem
     that installs the non-normalized definition of the new function.
     </li>
     <li>
     @('wrapper-unnorm-name') is the name of the generated theorem
     that installs the non-normalized definition of the wrapper function.
     </li>
     <li>
     @('new-formals') are the formal parameters of the new function.
     </li>
     <li>
     @('domain-of-old-name') is the name of the theorem
     generated by @(tsee tailrec-gen-new-to-old-thm).
     </li>
     <li>
     @('alpha-name') is the name of the function
     generated by @(tsee tailrec-gen-alpha-fn).
     </li>
     <li>
     @('test-of-alpha-name') is the name of the theorem
     generated by @(tsee tailrec-gen-test-of-alpha-thm).
     </li>
     <li>
     @('old-guard-of-alpha-name') is the name of the theorem
     generated by @(tsee tailrec-gen-old-guard-of-alpha-thm).
     </li>
     <li>
     @('domain-of-ground-base-name') is the name of the theorem
     generated by @(tsee tailrec-gen-domain-of-ground-base-thm).
     </li>
     <li>
     @('combine-left-identity-ground-name') is the name of the theorem
     generated by @(tsee tailrec-gen-combine-left-identity-ground-thm).
     </li>
     <li>
     @('new-to-old-name') is the name of the theorem
     generated by @(tsee tailrec-gen-new-to-old-thm).
     </li>
     <li>
     @('base-guard-name') is the name of the theorem
     generated by @(tsee tailrec-gen-base-guard-thm).
     </li>
     <li>
     @('old-to-new-name') is the name of the theorem
     generated by @(tsee tailrec-gen-old-to-new-thm).
     </li>
     <li>
     @('names-to-avoid') is a cumulative list of names of generated events,
     used to ensure the absence of name clashes in the generated events.
     </li>
   </ul>
   <p>
   The parameters of implementation functions that are not listed above
   are described in, or clear from, those functions' documentation.
   </p>"
  :order-subtopics t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc+ tailrec-input-processing
  :parents (tailrec-implementation)
  :short "Input processing performed by @(tsee tailrec)."
  :long
  "<p>
   This involves validating the inputs.
   When validation fails, <see topic='@(url er)'>soft errors</see> occur.
   Thus, generally the input processing functions return
   <see topic='@(url acl2::error-triple)'>error triples</see>.
   </p>"
  :order-subtopics t
  :default-parent t)

(define tailrec-check-nonrec-conditions
  ((combine-nonrec pseudo-termp)
   (nonrec? pseudo-termp "Candidate @('nonrec<x1,...,xn>') to check.")
   (r symbolp)
   (q symbolp))
  :returns
  (mv (yes/no booleanp)
      (combine "The @(tsee pseudo-termp) @('combine<q,r>')
                described in the documentation,
                if @('yes/no') is @('t');
                otherwise @('nil')."))
  :verify-guards nil
  :short "Check whether @('nonrec?') satisfies the conditions
          for @('nonrec<x1,...,xn>') described in the documentation."
  :long
  "<p>
   The conditions are that
   @('r') does not occur in @('nonrec?')
   and that replacing every occurrence of @('nonrec?')
   in @('combine<nonrec<x1,...,xn>,r>') with @('q')
   yields a term whose only free variables are @('q') and @('r').
   </p>"
  (if (member-eq r (all-vars nonrec?))
      (mv nil nil)
    (let ((combine (subst-expr1 q nonrec? combine-nonrec)))
      (if (set-equiv (all-vars combine) (list q r))
          (mv t combine)
        (mv nil nil)))))

(defines tailrec-find-nonrec-term-in-term/terms
  :short "Decompose @('combine<nonrec<x1,...,xn>,r>') into
          @('nonrec<x1,...,xn>') and @('combine<q,r>'),
          as described in the documentation."
  :verify-guards nil

  (define tailrec-find-nonrec-term
    ((combine-nonrec pseudo-termp)
     (term-to-try pseudo-termp "Subterm of @('combine<nonrec<x1,...,xn>,r>')
                                to examine next.")
     (r symbolp)
     (q symbolp))
    :returns (mv (success "A @(tsee booleanp).")
                 (nonrec "The @(tsee pseudo-termp) @('nonrec<x1,...,xn>')
                          described in the documentation,
                          if @('success') is @('t');
                          otherwise @('nil').")
                 (combine "The @(tsee pseudo-termp) @('combine<q,r>')
                           described in the documentation,
                           if @('success') is @('t');
                           otherwise @('nil')."))
    :parents (tailrec-find-nonrec-term-in-term/terms)
    :short "Find the maximal and leftmost subterm of @('term-to-try')
            that satisfies the conditions for @('nonrec<x1,...,xn>')
            described in the documentation."
    :long
    "<p>
     When initially invoked
     on @('combine<nonrec<x1,...,xn>,r>') as @('term-to-try'),
     attempt to recursively finds @('nonrec<x1,...,xn>')
     as described in the documentation.
     </p>"
    (b* (((mv found combine) (tailrec-check-nonrec-conditions
                              combine-nonrec term-to-try r q))
         ((when found) (mv t term-to-try combine))
         ((when (or (variablep term-to-try)
                    (fquotep term-to-try)))
          (mv nil nil nil)))
      (tailrec-find-nonrec-terms combine-nonrec (fargs term-to-try) r q)))

  (define tailrec-find-nonrec-terms
    ((combine-nonrec pseudo-termp)
     (terms-to-try pseudo-term-listp "Subterms of @('combine-nonrec')
                                      to examine next.")
     (r symbolp)
     (q symbolp))
    :returns (mv (success "A @(tsee booleanp).")
                 (nonrec "The @(tsee pseudo-termp) @('nonrec<x1,...,xn>')
                          described in the documentation,
                          if @('success') is @('t');
                          otherwise @('nil').")
                 (combine "The @(tsee pseudo-termp) @('combine<q,r>')
                           described in the documentation,
                           if @('success') is @('t');
                           otherwise @('nil')."))
    :parents (tailrec-find-nonrec-term-in-term/terms)
    :short "Find the maximal and leftmost subterm of @('terms-to-try')
            that satisfies the conditions for @('nonrec<x1,...,xn>')
            described in the documentation."
    :long
    "<p>
     This is the companion function to @(tsee tailrec-find-nonrec-term),
     used to recursively process arguments of function calls.
     </p>"
    (cond ((endp terms-to-try) (mv nil nil nil))
          (t (b* (((mv found nonrec combine)
                   (tailrec-find-nonrec-term
                    combine-nonrec (car terms-to-try) r q))
                  ((when found) (mv t nonrec combine)))
               (tailrec-find-nonrec-terms
                combine-nonrec (cdr terms-to-try) r q))))))

(define tailrec-decompose-recursive-branch ((old$ symbolp)
                                            (rec-branch pseudo-termp)
                                            ctx
                                            state)
  :returns (mv erp
               (result "A tuple @('(nonrec<x1,...,xn>
                                    (... update-xi<x1...,xn> ...)
                                    combine<q,r>
                                    q
                                    r)'),
                        whose components are described in the documentation,
                        satisfying
                        @('(typed-tuplep pseudo-termp
                                         pseudo-term-listp
                                         pseudo-termp
                                         symbolp
                                         symbolp
                                         result)').")
               state)
  :mode :program
  :short "Decompose the recursive branch of the target function
          into its components,
          as described in the documentation."
  (b* ((rec-calls (all-calls (list old$) rec-branch nil nil))
       (rec-calls (remove-duplicates-equal rec-calls))
       ((when (/= (len rec-calls) 1))
        (er-soft+ ctx t nil
                  "After translation and LET expansion, ~
                   the recursive branch ~x0 of the target function ~x1 ~
                   must not contain different calls to ~x1."
                  rec-branch old$))
       (rec-call (car rec-calls))
       ((when (equal rec-call rec-branch))
        (er-soft+ ctx t nil
                  "The target function ~x0 is already tail-recursive."
                  old$))
       (updates (fargs rec-call))
       (formals (formals old$ (w state)))
       (r (genvar old$ "R" nil formals))
       (q (genvar old$ "Q" nil formals))
       (combine-nonrec (subst-expr r rec-call rec-branch))
       ((er &) (ensure-term-not-call-of$
                combine-nonrec
                'if
                (msg "After translation and LET expansion, ~
                      and after replacing the calls to ~x0 ~
                      with a fresh variable ~x1, ~
                      the recursive branch ~x2 of the target function ~x0"
                     old$ r combine-nonrec)
                t nil))
       ((mv found nonrec combine)
        (tailrec-find-nonrec-term combine-nonrec combine-nonrec r q))
       ((unless found)
        (er-soft+ ctx t nil
                  "Unable to decompose the recursive branch ~x0 ~
                   of the target function ~x1." rec-branch old$)))
    (value (list nonrec updates combine q r))))

(define tailrec-process-old (old
                             variant
                             verify-guards
                             (verbose booleanp)
                             ctx
                             state)
  :returns (mv erp
               (result "A tuple @('(old$
                                    test<x1,...,xn>
                                    base<x1,...,xn>
                                    nonrec<x1,...,xn>
                                    (... update-xi<x1...,xn> ...)
                                    combine<q,r>
                                    q
                                    r)'),
                        satisfying
                        @('(typed-tuplep symbolp
                                         pseudo-termp
                                         pseudo-termp
                                         pseudo-termp
                                         pseudo-term-listp
                                         pseudo-termp
                                         symbolp
                                         symbolp
                                         result)'),
                        where @('old$') is the name
                        of the target function of the transformation
                        (denoted by the @('old') input)
                        and the other components
                        are described in the documentation.")
               state)
  :mode :program
  :short "Process the @('old') input."
  :long
  "<p>
   Show the components of the function denoted by @('old')
   if @('verbose') is @('t').
   </p>"
  (b* ((wrld (w state))
       ((er old$) (ensure-function-name-or-numbered-wildcard$
                   old "The first input" t nil))
       (description (msg "The target function ~x0" old$))
       ((er &) (ensure-function-logic-mode$ old$ description t nil))
       ((er &) (ensure-function-defined$ old$ description t nil))
       ((er &) (ensure-function-number-of-results$ old$ 1
                                                   description t nil))
       ((er &) (ensure-function-no-stobjs$ old$ description t nil))
       ((er &) (ensure-function-singly-recursive$ old$
                                                  description t nil))
       ((er &) (ensure-function-known-measure$ old$ description t nil))
       (body (if (non-executablep old$ wrld)
                 (unwrapped-nonexec-body old$ wrld)
               (ubody old$ wrld)))
       (body (remove-lambdas body))
       ((er (list test base combine-nonrec-reccall))
        (ensure-term-if-call$ body
                              (msg "After translation and LET expansion, ~
                                    the body ~x0 of the target function ~x1"
                                   body old$)
                              t nil))
       ((er &) (ensure-term-does-not-call$
                test old$
                (msg "After translation and LET expansion, ~
                      the exit test ~x0 ~
                      of the target function ~x1"
                     test old$)
                t nil))
       ((er &) (ensure-term-does-not-call$
                base old$
                (msg "After translation and LET expansion, ~
                      the first branch ~x0 ~
                      of the target function ~x1"
                     base old$)
                t nil))
       ((er &) (if (member-eq variant '(:monoid :monoid-alt))
                   (ensure-term-ground$
                    base
                    (msg "Since the :VARIANT input is ~s0~x1, ~
                          after translation and LET expansion, ~
                          the first branch ~x2 ~
                          of the target function ~x3"
                         (if (eq variant :monoid)
                             "(perhaps by default) "
                           "")
                         variant
                         base
                         old$)
                    t nil)
                 (value nil)))
       ((er (list nonrec updates combine q r))
        (tailrec-decompose-recursive-branch
         old$ combine-nonrec-reccall ctx state))
       ((er &) (if (eq verify-guards t)
                   (ensure-function-guard-verified$
                    old$
                    (msg "Since the :VERIFY-GUARDS input is T, ~
                          the target function ~x0" old$)
                    t nil)
                 (value nil)))
       ((run-when verbose)
        (cw "~%")
        (cw "Components of the target function ~x0:~%" old$)
        (cw "- Exit test: ~x0.~%" (untranslate test nil wrld))
        (cw "- Base value: ~x0.~%" (untranslate base nil wrld))
        (cw "- Non-recursive computation: ~x0.~%" (untranslate nonrec nil wrld))
        (cw "- Argument updates: ~x0.~%" (untranslate-lst updates nil wrld))
        (cw "- Combination operator: ~x0.~%" (untranslate combine nil wrld))
        (cw "- Fresh variable for non-recursive computation: ~x0.~%" q)
        (cw "- Fresh variable for recursive call: ~x0.~%" r)))
    (value (list old$ test base nonrec updates combine q r))))

(std::defenum tailrec-variantp (:assoc :monoid :monoid-alt)
  :short "Variants of the tail recursion transformation.")

(def-error-checker tailrec-process-variant
  (variant)
  "Process the @('variant') input."
  (((tailrec-variantp variant)
    "~@0 must be :MONOID, :MONOID-ALT, or :ASSOC." description)))

(define tailrec-infer-domain ((combine pseudo-termp)
                              (q symbolp)
                              (r symbolp)
                              (variant$ tailrec-variantp)
                              (verbose booleanp)
                              (wrld plist-worldp))
  :returns (domain "A @(tsee pseudo-termfnp).")
  :verify-guards nil
  :short "Infer the domain over which some applicability conditions must hold."
  :long
  "<p>
   This is used when the @(':domain') input is @(':auto').
   A domain is inferred as described in the documentation.
   </p>"
  (b* ((default '(lambda (x) 't))
       (domain
        (if (member-eq variant$ '(:monoid :monoid-alt))
            (case-match combine
              ((op . args)
               (b* (((unless (symbolp op)) default)
                    ((unless (or (equal args (list q r))
                                 (equal args (list r q))))
                     default)
                    ((list y1 y2) (formals op wrld))
                    (guard (uguard op wrld)))
                 (case-match guard
                   (('if (dom !y1) (dom !y2) *nil*)
                    (if (symbolp dom)
                        dom
                      default))
                   (& default))))
              (& default))
          default))
       ((run-when verbose)
        (cw "~%")
        (cw "Inferred domain for the applicability conditions: ~x0.~%" domain)))
    domain))

(define tailrec-process-domain (domain
                                (old$ symbolp)
                                (combine pseudo-termp)
                                (q symbolp)
                                (r symbolp)
                                (variant$ tailrec-variantp)
                                (verify-guards$ booleanp)
                                (verbose booleanp)
                                ctx
                                state)
  :returns (mv erp
               (domain$ "A @(tsee pseudo-termfnp) that is
                         the predicate denoted by @('domain').")
               state)
  :mode :program
  :short "Process the @(':domain') input."
  :long
  "<p>
   If successful, return:
   the input itself, if it is a function name;
   the translated lambda expression denoted by the input,
   if the input is a macro name;
   the translation of the input,
   if the input is a lambda expression;
   the inferred function name
   or the default translated lambda expression that holds for every value,
   if the input is @(':auto').
   </p>"
  (b* ((wrld (w state))
       ((when (eq domain :auto))
        (value (tailrec-infer-domain combine q r variant$ verbose wrld)))
       (description "The :DOMAIN input")
       ((er (list fn/lambda stobjs-in stobjs-out description))
        (cond ((function-namep domain wrld)
               (value (list domain
                            (stobjs-in domain wrld)
                            (stobjs-out domain wrld)
                            (msg "~@0, which is the function ~x1,"
                                 description domain))))
              ((macro-namep domain wrld)
               (b* ((args (macro-required-args domain wrld))
                    (ulambda `(lambda ,args (,domain ,@args)))
                    ((mv tlambda stobjs-out) (check-user-lambda ulambda wrld))
                    (stobjs-in (compute-stobj-flags args t wrld)))
                 (value
                  (list tlambda
                        stobjs-in
                        stobjs-out
                        (msg "~@0, which is the lambda expression ~x1 ~
                              denoted by the macro ~x2,"
                             description ulambda domain)))))
              ((symbolp domain)
               (er-soft+ ctx t nil "~@0 must be :AUTO, ~
                                    a function name, ~
                                    a macro name, ~
                                    or a lambda expression.  ~
                                    The symbol ~x1 is not :AUTO or ~
                                    the name of a function or macro."
                         description domain))
              (t (b* (((mv tlambda/msg stobjs-out)
                       (check-user-lambda domain wrld))
                      ((when (msgp tlambda/msg))
                       (er-soft+ ctx t nil
                                 "~@0 must be :AUTO, ~
                                  a function name, ~
                                  a macro name, ~
                                  or a lambda expression.  ~
                                  Since ~x1 is not a symbol, ~
                                  it must be a lambda expression.  ~
                                  ~@2"
                                 description domain tlambda/msg))
                      (tlambda tlambda/msg)
                      (stobjs-in
                       (compute-stobj-flags (lambda-formals tlambda) t wrld)))
                   (value (list tlambda
                                stobjs-in
                                stobjs-out
                                (msg "~@0, which is the lambda expression ~x1,"
                                     description domain)))))))
       ((er &) (ensure-function/lambda-logic-mode$ fn/lambda description t nil))
       ((er &) (ensure-function/lambda-arity$ stobjs-in 1 description t nil))
       ((er &) (ensure-function/lambda/term-number-of-results$ stobjs-out 1
                                                               description
                                                               t nil))
       ((er &) (ensure-function/lambda-no-stobjs$ stobjs-in
                                                  stobjs-out
                                                  description t nil))
       ((er &) (ensure-function/lambda-closed$ fn/lambda description t nil))
       ((er &) (if verify-guards$
                   (ensure-function/lambda-guard-verified-exec-fns$
                    fn/lambda
                    (msg "Since either the :VERIFY-GUARDS input is T, ~
                          or it is (perhaps by default) :AUTO ~
                          and the target function ~x0 is guard-verified, ~@1"
                         old$ (msg-downcase-first description))
                    t nil)
                 (value nil)))
       ((er &) (if (symbolp fn/lambda)
                   (ensure-symbol-different$ fn/lambda
                                             old$
                                             (msg "the target function ~x0"
                                                  old$)
                                             description t nil)
                 (ensure-term-does-not-call$ (lambda-body fn/lambda)
                                             old$
                                             description t nil))))
    (value fn/lambda)))

(define tailrec-process-new-name (new-name
                                  (old$ symbolp)
                                  ctx
                                  state)
  :returns (mv erp
               (new-name$ "A @(tsee symbolp)
                           to use as the name for the new function.")
               state)
  :mode :program
  :short "Process the @(':new-name') input."
  (b* (((er &) (ensure-symbol$ new-name "The :NEW-NAME input" t nil))
       (name (if (eq new-name :auto)
                 (next-numbered-name old$ (w state))
               new-name))
       (description (msg "The name ~x0 of the new function, ~@1,"
                         name
                         (if (eq new-name :auto)
                             "automatically generated ~
                              since the :NEW-NAME input ~
                              is (perhaps by default) :AUTO"
                           "supplied as the :NEW-NAME input")))
       ((er &) (ensure-symbol-new-event-name$ name description t nil)))
    (value name)))

(define tailrec-process-wrapper-name (wrapper-name
                                      (wrapper-name-present booleanp)
                                      (new-name$ symbolp)
                                      (wrapper$ booleanp)
                                      ctx
                                      state)
  :returns (mv erp
               (wrapper-name$ "A @(tsee symbolp)
                               to use as the name for the wrapper function,
                               or @('nil') if no wrapper is generated.")
               state)
  :mode :program
  :short "Process the @(':wrapper-name') input."
  (if wrapper$
      (b* (((er &) (ensure-symbol$ wrapper-name
                                   "The :WRAPPER-NAME input" t nil))
           (name (if (eq wrapper-name :auto)
                     (add-suffix-to-fn new-name$ "-WRAPPER")
                   wrapper-name))
           (description (msg "The name ~x0 of the wrapper function, ~@1,"
                             name
                             (if (eq wrapper-name :auto)
                                 "automatically generated ~
                              since the :WRAPPER-NAME input ~
                              is (perhaps by default) :AUTO"
                               "supplied as the :WRAPPER-NAME input")))
           ((er &) (ensure-symbol-new-event-name$ name description t nil))
           ((er &) (ensure-symbol-different$
                    name new-name$
                    (msg "the name ~x0 of the new function ~
                      (determined by the :NEW-NAME input)." new-name$)
                    description
                    t nil)))
        (value name))
    (if wrapper-name-present
        (er-soft+ ctx t nil
                  "Since the :WRAPPER input is NIL, ~
                   no :WRAPPER-NAME input may be supplied.")
      (value nil))))

(define tailrec-process-wrapper-enable (wrapper-enable
                                        (wrapper-enable-present booleanp)
                                        (wrapper$ booleanp)
                                        ctx
                                        state)
  :returns (mv erp
               (nothing "Always @('nil').")
               state)
  :short "Process the @(':wrapper-enable') input."
  (if wrapper$
      (ensure-boolean$ wrapper-enable "The :WRAPPER-ENABLE input" t nil)
    (if wrapper-enable-present
        (er-soft+ ctx t nil
                  "Since the :WRAPPER input is NIL, ~
                   no :WRAPPER-enable input may be supplied.")
      (value nil))))

(define tailrec-process-thm-name (thm-name
                                  (old$ symbolp)
                                  (new-name$ symbolp)
                                  (wrapper$ booleanp)
                                  (wrapper-name$ symbolp)
                                  ctx
                                  state)
  :returns (mv erp
               (thm-name$ "A @(tsee symbolp)
                           to use for the theorem that
                           relates the old and new or wrapper functions.")
               state)
  :mode :program
  :short "Process the @(':thm-name') input."
  (b* ((new/wrapper-name (if wrapper$ wrapper-name$ new-name$))
       ((er &) (ensure-symbol$ thm-name "The :THM-NAME input" t nil))
       (name (if (eq thm-name :auto)
                 (make-paired-name old$ new/wrapper-name 2 (w state))
               thm-name))
       (description (msg "The name ~x0 of the theorem ~
                          that relates the target function ~x1 ~
                          to the ~s2 function ~x3, ~
                          ~@4,"
                         name
                         old$
                         (if wrapper$ "wrapper" "new")
                         new/wrapper-name
                         (if (eq thm-name :auto)
                             "automatically generated ~
                              since the :THM-NAME input ~
                              is (perhaps by default) :AUTO"
                           "supplied as the :THM-NAME input")))
       ((er &) (ensure-symbol-new-event-name$ name description t nil))
       ((er &) (ensure-symbol-different$
                name new-name$
                (msg "the name ~x0 of the new function ~
                      (determined by the :NEW-NAME input)." new-name$)
                description
                t nil))
       ((when (not wrapper$)) (value name))
       ((er &) (ensure-symbol-different$
                name wrapper-name$
                (msg "the name ~x0 of the wrapper function ~
                      (determined by the :WRAPPER-NAME input)." wrapper-name$)
                description
                t nil)))
    (value name)))

(defval *tailrec-app-cond-names*
  :short "Names of all the applicability conditions."
  '(:domain-of-base
    :domain-of-nonrec
    :domain-of-combine
    :domain-of-combine-uncond
    :combine-associativity
    :combine-associativity-uncond
    :combine-left-identity
    :combine-right-identity
    :domain-guard
    :combine-guard
    :domain-of-nonrec-when-guard)
  ///

  (defruled symbol-listp-of-*tailrec-app-cond-names*
    (symbol-listp *tailrec-app-cond-names*))

  (defruled no-duplicatesp-eq-of-*tailrec-app-cond-names*
    (no-duplicatesp-eq *tailrec-app-cond-names*)))

(define tailrec-app-cond-namep (x)
  :returns (yes/no booleanp)
  :short "Recognize names of the applicability conditions."
  (and (member-eq x *tailrec-app-cond-names*) t))

(std::deflist tailrec-app-cond-name-listp (x)
  (tailrec-app-cond-namep x)
  :short "Recognize true lists of names of the applicability conditions."
  :true-listp t
  :elementp-of-nil nil)

(define tailrec-app-cond-present-p ((name tailrec-app-cond-namep)
                                    (variant$ tailrec-variantp)
                                    (verify-guards$ booleanp))
  :returns (yes/no booleanp :hyp (booleanp verify-guards$))
  :short "Check if the named applicability condition is present."
  (case name
    (:domain-of-base t)
    ((:domain-of-nonrec
      :domain-of-combine
      :combine-associativity) (if (member-eq variant$ '(:monoid :assoc)) t nil))
    ((:domain-of-combine-uncond
      :combine-associativity-uncond) (eq variant$ :monoid-alt))
    ((:combine-left-identity
      :combine-right-identity) (if (member-eq variant$ '(:monoid :monoid-alt))
                                   t nil))
    ((:domain-guard
      :combine-guard) verify-guards$)
    (:domain-of-nonrec-when-guard (and (eq variant$ :monoid-alt)
                                       verify-guards$))
    (t (impossible)))
  :guard-hints (("Goal" :in-theory (enable tailrec-app-cond-namep))))

(define tailrec-app-cond-present-names ((variant$ tailrec-variantp)
                                        (verify-guards$ booleanp))
  :returns (present-names tailrec-app-cond-name-listp)
  :short "Names of the applicability conditions that are present."
  (tailrec-app-cond-present-names-aux *tailrec-app-cond-names*
                                      variant$
                                      verify-guards$)

  :prepwork
  ((define tailrec-app-cond-present-names-aux
     ((names tailrec-app-cond-name-listp)
      (variant$ tailrec-variantp)
      (verify-guards$ booleanp))
     :returns (present-names tailrec-app-cond-name-listp
                             :hyp (tailrec-app-cond-name-listp names))
     :parents nil
     (if (endp names)
         nil
       (if (tailrec-app-cond-present-p (car names)
                                       variant$
                                       verify-guards$)
           (cons (car names)
                 (tailrec-app-cond-present-names-aux (cdr names)
                                                     variant$
                                                     verify-guards$))
         (tailrec-app-cond-present-names-aux (cdr names)
                                             variant$
                                             verify-guards$))))))

(define tailrec-process-inputs (old
                                variant
                                domain
                                new-name
                                new-enable
                                wrapper
                                wrapper-name
                                (wrapper-name-present booleanp)
                                wrapper-enable
                                (wrapper-enable-present booleanp)
                                thm-name
                                thm-enable
                                non-executable
                                verify-guards
                                hints
                                print
                                show-only
                                ctx
                                state)
  :returns (mv erp
               (result "A tuple @('(old$
                                    test<x1,...,xn>
                                    base<x1,...,xn>
                                    nonrec<x1,...,xn>
                                    (... update-xi<x1...,xn> ...)
                                    combine<q,r>
                                    q
                                    r
                                    domain$
                                    new-name$
                                    new-enable$
                                    wrapper-name$
                                    thm-name$
                                    non-executable$
                                    verify-guards$
                                    hints$
                                    app-cond-present-names)')
                        satisfying
                        @('(typed-tuplep symbolp
                                         pseudo-termp
                                         pseudo-termp
                                         pseudo-termp
                                         pseudo-term-listp
                                         pseudo-termp
                                         symbolp
                                         symbolp
                                         pseudo-termfnp
                                         symbolp
                                         booleanp
                                         symbolp
                                         symbolp
                                         booleanp
                                         booleanp
                                         symbol-alistp
                                         symbol-listp
                                         result)'),
                        where the first 8 components are
                        the results of @(tsee tailrec-process-old),
                        @('domain$') is
                        the result of @(tsee tailrec-process-domain),
                        @('new-name$') is
                        the result of @(tsee tailrec-process-new-name),
                        @('new-enable$') indicates whether
                        the new function should be enabled or not,
                        @('wrapper-name$') is
                        the result of @(tsee tailrec-process-wrapper-name),
                        @('thm-name$') is
                        the result of @(tsee tailrec-process-thm-name),
                        @('non-executable') indicates whether
                        the new and wrapper functions should be
                        non-executable or not, and
                        @('verify-guards$') indicates whether the guards of
                        the new and wrapper functions
                        should be verified or not,
                        @('hints$') is
                        the result of @(tsee evmac-process-input-hints), and
                        @('app-cond-present-names') is
                        the result of @(tsee tailrec-app-cond-present-names).")
               state)
  :mode :program
  :short "Process all the inputs."
  :long
  "<p>
   The inputs are processed
   in the order in which they appear in the documentation,
   except that @(':print') is processed just before @('old')
   so that the @('verbose') argument of @(tsee tailrec-process-old)
   can be computed from @(':print'),
   and except that @(':verify-guards') is processed just before @('domain')
   because the result of processing @(':verify-guards')
   is used to process @('domain').
   @('old') is processed before @(':verify-guards')
   because the result of processing @('old')
   is used to process @(':verify-guards').
   @(':verify-guards') is also used to process @('old'),
   but it is only tested for equality with @('t')
   (see @(tsee tailrec-process-old)).
   </p>"
  (b* ((wrld (w state))
       ((er &) (evmac-process-input-print print ctx state))
       (verbose (and (member-eq print '(:info :all)) t))
       ((er (list old$
                  test
                  base
                  nonrec
                  updates
                  combine
                  q
                  r)) (tailrec-process-old old variant verify-guards
                                           verbose ctx state))
       ((er &) (tailrec-process-variant$ variant "The :VARIANT input" t nil))
       ((er verify-guards$) (ensure-boolean-or-auto-and-return-boolean$
                             verify-guards
                             (guard-verified-p old$ wrld)
                             "The :VERIFY-GUARDS input" t nil))
       ((er domain$) (tailrec-process-domain
                      domain old$ combine q r variant verify-guards$
                      verbose ctx state))
       ((er new-name$) (tailrec-process-new-name
                        new-name old$ ctx state))
       ((er new-enable$) (ensure-boolean-or-auto-and-return-boolean$
                          new-enable
                          (fundef-enabledp old state)
                          "The :NEW-ENABLE input" t nil))
       ((er &) (ensure-boolean$ wrapper "The :WRAPPER input" t nil))
       ((er wrapper-name$) (tailrec-process-wrapper-name
                            wrapper-name wrapper-name-present
                            new-name$ wrapper ctx state))
       ((er &) (tailrec-process-wrapper-enable
                wrapper-enable wrapper-enable-present
                wrapper ctx state))
       ((er thm-name$) (tailrec-process-thm-name
                        thm-name
                        old$ new-name$ wrapper wrapper-name$
                        ctx state))
       ((er &) (ensure-boolean$ thm-enable "The :THM-ENABLE input" t nil))
       ((er non-executable$) (ensure-boolean-or-auto-and-return-boolean$
                              non-executable
                              (non-executablep old wrld)
                              "The :NON-EXECUTABLE input" t nil))
       (app-cond-present-names (tailrec-app-cond-present-names
                                variant verify-guards$))
       ((er hints$) (evmac-process-input-hints
                     hints app-cond-present-names ctx state))
       ((er &) (evmac-process-input-show-only show-only ctx state)))
    (value (list old$
                 test
                 base
                 nonrec
                 updates
                 combine
                 q
                 r
                 domain$
                 new-name$
                 new-enable$
                 wrapper-name$
                 thm-name$
                 non-executable$
                 verify-guards$
                 hints$
                 app-cond-present-names))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc+ tailrec-event-generation
  :parents (tailrec-implementation)
  :short "Event generation performed by @(tsee tailrec)."
  :long
  "<p>
   Some events are generated in two slightly different forms:
   a form that is local to the generated @(tsee encapsulate),
   and a form that is exported from the @(tsee encapsulate).
   Proof hints are in the former but not in the latter,
   thus keeping the ACL2 history ``clean''.
   </p>
   <p>
   Other events are generated only locally in the @(tsee encapsulate),
   without any exported counterparts.
   These have automatically generated fresh names:
   the names used so far
   are threaded through the event generation functions below.
   </p>
   <p>
   Other events are only exported from the @(tsee encapsulate),
   without any local counterparts.
   </p>"
  :order-subtopics t
  :default-parent t)

(define tailrec-gen-var-u ((old$ symbolp))
  :returns (u "A @(tsee symbolp).")
  :mode :program
  :short "Generate the variable @('u') to use in the
          @(':domain-of-combine'),
          @(':domain-of-combine-uncond'),
          @(':combine-associativity'), and
          @(':combine-associativity-uncond')
          applicability conditions."
  (genvar old$ "U" nil nil))

(define tailrec-gen-var-v ((old$ symbolp))
  :returns (v "A @(tsee symbolp).")
  :mode :program
  :short "Generate the variable @('u') to use in the
          @(':domain-of-combine'),
          @(':domain-of-combine-uncond'),
          @(':combine-associativity'), and
          @(':combine-associativity-uncond')
          applicability conditions."
  (genvar old$ "V" nil nil))

(define tailrec-gen-var-w ((old$ symbolp))
  :returns (w "A @(tsee symbolp).")
  :mode :program
  :short "Generate the variable @('u') to use in the
          @(':combine-associativity') and
          @(':combine-associativity-uncond')
          applicability conditions."
  (genvar old$ "W" nil nil))

(define tailrec-gen-id-var-u ((old$ symbolp) (wrld plist-worldp))
  :returns (u "A @(tsee symbolp).")
  :mode :program
  :short "Generate the variable @('u') to use in the
          @(':combine-left-identity') and
          @(':combine-right-identity')
          applicability conditions."
  :long
  "<p>
   This must be distinct from the formals of the old function.
   </p>"
  (genvar old$ "U" nil (formals old$ wrld)))

(define tailrec-gen-combine-op ((combine pseudo-termp)
                                (q symbolp)
                                (r symbolp))
  :returns (combine-op pseudo-lambdap
                       :hyp :guard
                       :hints (("Goal" :in-theory (enable pseudo-lambdap))))
  :short "Generate the combination operator."
  :long
  "<p>
   This is obtained by abstracting @('combine<q,r>') over @('q') and @('r').
   </p>"
  (make-lambda (list q r) combine))

(define tailrec-gen-app-cond-formula ((name tailrec-app-cond-namep)
                                      (old$ symbolp)
                                      (test pseudo-termp)
                                      (base pseudo-termp)
                                      (nonrec pseudo-termp)
                                      (combine pseudo-termp)
                                      (q symbolp)
                                      (r symbolp)
                                      (domain$ pseudo-termfnp)
                                      state)
  :returns (formula "An untranslated term.")
  :mode :program
  :short "Generate the formula of the named applicability condition."
  (b* ((wrld (w state))
       (u (tailrec-gen-var-u old$))
       (v (tailrec-gen-var-v old$))
       (w (tailrec-gen-var-w old$))
       (u1 (tailrec-gen-id-var-u old$ wrld))
       (combine-op (tailrec-gen-combine-op combine q r)))
    (case name
      (:domain-of-base
       (untranslate (implicate test
                               (apply-term* domain$ base))
                    t wrld))
      (:domain-of-nonrec
       (untranslate (implicate (dumb-negate-lit test)
                               (apply-term* domain$ nonrec))
                    t wrld))
      (:domain-of-combine
       (untranslate (implicate (conjoin2 (apply-term* domain$ u)
                                         (apply-term* domain$ v))
                               (apply-term* domain$
                                            (apply-term* combine-op u v)))
                    t wrld))
      (:domain-of-combine-uncond
       (untranslate (apply-term* domain$
                                 (apply-term* combine-op u v))
                    t wrld))
      (:combine-associativity
       (untranslate (implicate
                     (conjoin (list (apply-term* domain$ u)
                                    (apply-term* domain$ v)
                                    (apply-term* domain$ w)))
                     `(equal ,(apply-term* combine-op
                                           u
                                           (apply-term* combine-op v w))
                             ,(apply-term* combine-op
                                           (apply-term* combine-op u v)
                                           w)))
                    t wrld))
      (:combine-associativity-uncond
       (untranslate `(equal ,(apply-term* combine-op
                                          u
                                          (apply-term* combine-op v w))
                            ,(apply-term* combine-op
                                          (apply-term* combine-op u v)
                                          w))
                    t wrld))
      (:combine-left-identity
       (untranslate (implicate (conjoin2 test
                                         (apply-term* domain$ u1))
                               `(equal ,(apply-term* combine-op base u1)
                                       ,u1))
                    t wrld))
      (:combine-right-identity
       (untranslate (implicate (conjoin2 test
                                         (apply-term* domain$ u1))
                               `(equal ,(apply-term* combine-op u1 base)
                                       ,u1))
                    t wrld))
      (:domain-guard
       (if (symbolp domain$)
           (untranslate (guard domain$ nil wrld)
                        t wrld)
         (untranslate (term-guard-obligation (lambda-body domain$) state)
                      t wrld)))
      (:combine-guard
       (untranslate (implicate (conjoin2 (apply-term* domain$ q)
                                         (apply-term* domain$ r))
                               (term-guard-obligation combine state))
                    t wrld))
      (:domain-of-nonrec-when-guard
       (untranslate (implicate (conjoin2 (guard old$ nil wrld)
                                         (dumb-negate-lit test))
                               (apply-term* domain$ nonrec))
                    t wrld))
      (t (impossible)))))

(define tailrec-gen-app-cond ((name tailrec-app-cond-namep)
                              (old$ symbolp)
                              (test pseudo-termp)
                              (base pseudo-termp)
                              (nonrec pseudo-termp)
                              (combine pseudo-termp)
                              (q symbolp)
                              (r symbolp)
                              (domain$ pseudo-termfnp)
                              (hints$ symbol-alistp)
                              (print$ evmac-input-print-p)
                              (names-to-avoid symbol-listp)
                              ctx
                              state)
  :returns (mv (event "A @(tsee pseudo-event-formp).")
               (thm-name "A @(tsee symbolp) that is the name of the theorem."))
  :mode :program
  :short "Generate a theorem for the named applicability condition."
  :long
  "<p>
   The theorem has no rule classes, because it is used via @(':use') hints
   in the generated proofs in other events.
   </p>
   <p>
   This is a local event, because it is only used internally by @('tailrec').
   The event is wrapped into a @(tsee try-event)
   in order to provide a terse error message if the proof fails
   (unless @(':print') is @(':all'), in which case everything is printed).
   In addition,
   if @(':print') is @(':info') or @(':all'),
   the event is preceded and followed by events to print progress messages.
   </p>
   <p>
   The name of the theorem is obtained by
   putting the keyword that names the applicability condition
   into the \"APT\" package
   and adding @('$') as needed to avoid name clashes.
   </p>"
  (b* ((wrld (w state))
       (thm-name (fresh-name-in-world-with-$s (intern-in-package-of-symbol
                                               (symbol-name name)
                                               (pkg-witness "APT"))
                                              names-to-avoid
                                              wrld))
       (formula (tailrec-gen-app-cond-formula name
                                              old$
                                              test
                                              base
                                              nonrec
                                              combine
                                              q
                                              r
                                              domain$
                                              state))
       (hints (cdr (assoc-eq name hints$)))
       (defthm `(defthm ,thm-name ,formula :hints ,hints :rule-classes nil))
       (error-msg (msg
                   "The proof of the ~x0 applicability condition fails:~%~x1~|"
                   name formula))
       (try-defthm (try-event defthm ctx t nil error-msg))
       (print-progress-p (member-eq print$ '(:info :all)))
       (progress-start? (and print-progress-p
                             `((cw-event
                                "~%Attempting to prove the ~x0 ~
                                 applicability condition:~%~x1~|"
                                ',name ',formula))))
       (progress-end? (and print-progress-p
                           `((cw-event "Done.~%"))))
       (event `(local (progn ,@progress-start?
                             ,try-defthm
                             ,@progress-end?))))
    (mv event thm-name)))

(define tailrec-gen-app-conds
  ((old$ symbolp)
   (test pseudo-termp)
   (base pseudo-termp)
   (nonrec pseudo-termp)
   (combine pseudo-termp)
   (q symbolp)
   (r symbolp)
   (variant$ tailrec-variantp)
   (domain$ pseudo-termfnp)
   (verify-guards$ booleanp)
   (hints$ symbol-alistp)
   (print$ evmac-input-print-p)
   (app-cond-present-names tailrec-app-cond-name-listp)
   (names-to-avoid symbol-listp)
   ctx
   state)
  :returns (mv (events "A @(tsee pseudo-event-form-listp).")
               (thm-names "A @(tsee symbol-symbol-alistp)
                           from names of applicability conditions
                           to names of the corresponding theorems event."))
  :mode :program
  :short "Generate theorems for the applicability conditions that must hold."
  (tailrec-gen-app-conds-aux app-cond-present-names
                             old$
                             test
                             base
                             nonrec
                             combine
                             q
                             r
                             variant$
                             domain$
                             verify-guards$
                             hints$
                             print$
                             names-to-avoid
                             ctx
                             state)

  :prepwork
  ((define tailrec-gen-app-conds-aux
     ((names tailrec-app-cond-name-listp)
      (old$ symbolp)
      (test pseudo-termp)
      (base pseudo-termp)
      (nonrec pseudo-termp)
      (combine pseudo-termp)
      (q symbolp)
      (r symbolp)
      (variant$ tailrec-variantp)
      (domain$ pseudo-termfnp)
      (verify-guards$ booleanp)
      (hints$ symbol-alistp)
      (print$ evmac-input-print-p)
      (names-to-avoid symbol-listp)
      ctx
      state)
     :returns (mv events ; PSEUDO-EVENT-FORM-LISTP
                  thm-names) ; SYMBOL-SYMBOL-ALISTP
     :mode :program
     :parents nil
     (b* (((when (endp names)) (mv nil nil))
          (name (car names))
          ((mv event thm-name) (tailrec-gen-app-cond name
                                                     old$
                                                     test
                                                     base
                                                     nonrec
                                                     combine
                                                     q
                                                     r
                                                     domain$
                                                     hints$
                                                     print$
                                                     names-to-avoid
                                                     ctx
                                                     state))
          (names-to-avoid (cons thm-name names-to-avoid))
          ((mv events thm-names) (tailrec-gen-app-conds-aux (cdr names)
                                                            old$
                                                            test
                                                            base
                                                            nonrec
                                                            combine
                                                            q
                                                            r
                                                            variant$
                                                            domain$
                                                            verify-guards$
                                                            hints$
                                                            print$
                                                            names-to-avoid
                                                            ctx
                                                            state)))
       (mv (cons event events)
           (acons name thm-name thm-names))))))

(define tailrec-gen-domain-of-old-thm ((old$ symbolp)
                                       (test pseudo-termp)
                                       (nonrec pseudo-termp)
                                       (updates pseudo-term-listp)
                                       (variant$ tailrec-variantp)
                                       (domain$ pseudo-termfnp)
                                       (names-to-avoid symbol-listp)
                                       (app-cond-thm-names symbol-symbol-alistp)
                                       (old-unnorm-name symbolp)
                                       (wrld plist-worldp))
  :returns (mv (event "A @(tsee pseudo-event-formp).")
               (name "A @(tsee symbolp) that names the theorem."))
  :mode :program
  :short "Generate the theorem asserting that
          the old function always yields values in the domain
          (@($D{}f$) in the design notes)."
  :long
  "<p>
   The theorem's formula is @('(domain (old x1 ... xn))').
   This is just @('t') if @('domain') is @('(lambda (x) t)') (e.g. as default).
   </p>
   <p>
   The hints follow the proofs in the design notes.
   </p>
   <p>
   This theorem event is local,
   because it is a lemma used to prove the exported main theorem.
   </p>"
  (b* ((name (fresh-name-in-world-with-$s 'domain-of-old names-to-avoid wrld))
       (formula (untranslate (apply-term* domain$
                                          (apply-term old$
                                                      (formals old$
                                                               wrld)))
                             t wrld))
       (hints
        (case variant$
          ((:monoid :assoc)
           (b* ((domain-of-base-thm
                 (cdr (assoc-eq :domain-of-base app-cond-thm-names)))
                (domain-of-nonrec-thm
                 (cdr (assoc-eq :domain-of-nonrec app-cond-thm-names)))
                (domain-of-combine-thm
                 (cdr (assoc-eq :domain-of-combine app-cond-thm-names)))
                (domain-of-combine-instance
                 `(:instance ,domain-of-combine-thm
                   :extra-bindings-ok
                   (,(tailrec-gen-var-u old$)
                    ,nonrec)
                   (,(tailrec-gen-var-v old$)
                    (,old$ ,@updates)))))
             `(("Goal"
                :in-theory '(,old-unnorm-name
                             (:induction ,old$))
                :induct (,old$ ,@(formals old$ wrld)))
               '(:use (,domain-of-base-thm
                       ,domain-of-nonrec-thm
                       ,domain-of-combine-instance)))))
          (:monoid-alt
           (b* ((domain-of-base-thm
                 (cdr (assoc-eq :domain-of-base app-cond-thm-names)))
                (domain-of-combine-uncond-thm
                 (cdr (assoc-eq :domain-of-combine-uncond app-cond-thm-names)))
                (domain-of-combine-uncond-instance
                 `(:instance ,domain-of-combine-uncond-thm
                   :extra-bindings-ok
                   (,(tailrec-gen-var-u old$)
                    ,nonrec)
                   (,(tailrec-gen-var-v old$)
                    (,old$ ,@updates)))))
             `(("Goal"
                :in-theory '(,old-unnorm-name)
                :cases (,test))
               '(:use (,domain-of-base-thm
                       ,domain-of-combine-uncond-instance)))))
          (t (impossible))))
       (event `(local (defthm ,name
                        ,formula
                        :rule-classes nil
                        :hints ,hints))))
    (mv event name)))

(define tailrec-gen-new-fn ((old$ symbolp)
                            (test pseudo-termp)
                            (base pseudo-termp)
                            (nonrec pseudo-termp)
                            (updates pseudo-term-listp)
                            (combine pseudo-termp)
                            (q symbolp)
                            (r symbolp)
                            (variant$ tailrec-variantp)
                            (domain$ pseudo-termfnp)
                            (new-name$ symbolp)
                            (new-enable$ booleanp)
                            (non-executable$ booleanp)
                            (verify-guards$ booleanp)
                            (app-cond-thm-names symbol-symbol-alistp)
                            (wrld plist-worldp))
  :returns (mv (local-event "A @(tsee pseudo-event-formp).")
               (exported-event "A @(tsee pseudo-event-formp).")
               (formals "A @(tsee symbol-listp)."))
  :mode :program
  :short "Generate the new function definition."
  :long
  "<p>
   The macro used to introduce the new function is determined by
   whether the new function must be
   enabled or not, and non-executable or not.
   </p>
   <p>
   The formals of the new function consist of
   the formals of the old function
   followed by the variable @('r') generated
   during the decomposition of the recursive branch of the old function.
   This variable is distinct from the formals of the old function
   by construction.
   The formals of the new function are return as one of the results.
   </p>
   <p>
   The body of the new function is
   as described in the documentation and design notes.
   The non-recursive branch varies slightly,
   depending on the transformation's variant.
   </p>
   <p>
   The new function's well-founded relation and measure
   are the same as the old function's.
   Following the design notes,
   the termination of the new function is proved
   in the empty theory, using the termination theorem of the old function.
   </p>
   <p>
   The guard of the new function is obtained
   by conjoining the guard of the old function
   with the fact that the additional formal @('r') is in the domain,
   as described in the documentation.
   </p>
   <p>
   The guards of the new function are verified
   following the proof in the design notes.
   The facts used in the proof for the case in which right identity holds
   are a subset of those for the case in which right identity does not hold.
   We use the hints for the latter case also for the former case
   (which will ignore some of the supplied facts).
   </p>"
  (b* ((macro (function-intro-macro new-enable$ non-executable$))
       (formals (rcons r (formals old$ wrld)))
       (body
        (b* ((combine-op (tailrec-gen-combine-op combine q r))
             (nonrec-branch (case variant$
                              ((:monoid :monoid-alt) r)
                              (:assoc (apply-term* combine-op r base))
                              (t (impossible))))
             (rec-branch (subcor-var (cons r (formals old$ wrld))
                                     (cons (apply-term* combine-op r nonrec)
                                           updates)
                                     (apply-term new-name$ formals)))
             (body `(if ,test
                        ,nonrec-branch
                      ,rec-branch)))
          (untranslate body nil wrld)))
       (wfrel (well-founded-relation old$ wrld))
       (measure (untranslate (measure old$ wrld) nil wrld))
       (termination-hints
        `(("Goal" :use (:termination-theorem ,old$) :in-theory nil)))
       (guard (untranslate (conjoin2 (guard old$ nil wrld)
                                     (apply-term* domain$ r))
                           t wrld))
       (guard-hints
        (case variant$
          ((:monoid :assoc)
           (b* ((z (car (if (symbolp domain$)
                            (formals domain$ wrld)
                          (lambda-formals domain$))))
                (domain-of-base-thm
                 (cdr (assoc-eq :domain-of-base app-cond-thm-names)))
                (domain-of-nonrec-thm
                 (cdr (assoc-eq :domain-of-nonrec app-cond-thm-names)))
                (domain-of-combine-thm
                 (cdr (assoc-eq :domain-of-combine app-cond-thm-names)))
                (domain-guard-thm
                 (cdr (assoc-eq :domain-guard app-cond-thm-names)))
                (combine-guard-thm
                 (cdr (assoc-eq :combine-guard app-cond-thm-names)))
                (domain-of-combine-instance
                 `(:instance ,domain-of-combine-thm
                   :extra-bindings-ok
                   (,(tailrec-gen-var-u old$) ,r)
                   (,(tailrec-gen-var-v old$) ,nonrec)))
                (domain-guard-instance
                 `(:instance ,domain-guard-thm
                   :extra-bindings-ok
                   (,z ,r)))
                (combine-guard-instance-base
                 `(:instance ,combine-guard-thm
                   :extra-bindings-ok
                   (,q ,r)
                   (,r ,base)))
                (combine-guard-instance-nonrec
                 `(:instance ,combine-guard-thm
                   :extra-bindings-ok
                   (,q ,r)
                   (,r ,nonrec))))
             `(("Goal"
                :in-theory nil
                :use ((:guard-theorem ,old$)
                      ,domain-guard-instance
                      ,domain-of-base-thm
                      ,domain-of-nonrec-thm
                      ,combine-guard-instance-base
                      ,combine-guard-instance-nonrec
                      ,domain-of-combine-instance)))))
          (:monoid-alt
           (b* ((z (car (if (symbolp domain$)
                            (formals domain$ wrld)
                          (lambda-formals domain$))))
                (domain-of-base-thm
                 (cdr (assoc-eq :domain-of-base app-cond-thm-names)))
                (domain-of-combine-uncond-thm
                 (cdr (assoc-eq :domain-of-combine-uncond app-cond-thm-names)))
                (domain-guard-thm
                 (cdr (assoc-eq :domain-guard app-cond-thm-names)))
                (combine-guard-thm
                 (cdr (assoc-eq :combine-guard app-cond-thm-names)))
                (domain-of-nonrec-when-guard-thm
                 (cdr (assoc-eq :domain-of-nonrec-when-guard
                        app-cond-thm-names)))
                (domain-of-combine-uncond-instance
                 `(:instance ,domain-of-combine-uncond-thm
                   :extra-bindings-ok
                   (,(tailrec-gen-var-u old$) ,r)
                   (,(tailrec-gen-var-v old$) ,nonrec)))
                (domain-guard-instance
                 `(:instance ,domain-guard-thm
                   :extra-bindings-ok
                   (,z ,r)))
                (combine-guard-instance-base
                 `(:instance ,combine-guard-thm
                   :extra-bindings-ok
                   (,q ,r)
                   (,r ,base)))
                (combine-guard-instance-nonrec
                 `(:instance ,combine-guard-thm
                   :extra-bindings-ok
                   (,q ,r)
                   (,r ,nonrec))))
             `(("Goal"
                :in-theory nil
                :use ((:guard-theorem ,old$)
                      ,domain-guard-instance
                      ,domain-of-base-thm
                      ,domain-of-nonrec-when-guard-thm
                      ,combine-guard-instance-base
                      ,combine-guard-instance-nonrec
                      ,domain-of-combine-uncond-instance)))))
          (t (impossible))))
       (local-event
        `(local
          (,macro ,new-name$ (,@formals)
                  (declare (xargs :well-founded-relation ,wfrel
                                  :measure ,measure
                                  :hints ,termination-hints
                                  :guard ,guard
                                  :verify-guards ,verify-guards$
                             ,@(and verify-guards$
                                    (list :guard-hints guard-hints))))
                  ,body)))
       (exported-event
        `(,macro ,new-name$ (,@formals)
                 (declare (xargs :well-founded-relation ,wfrel
                                 :measure ,measure
                                 :guard ,guard
                                 :verify-guards ,verify-guards$))
                 ,body)))
    (mv local-event exported-event formals)))

(define tailrec-gen-new-to-old-thm ((old$ symbolp)
                                    (nonrec pseudo-termp)
                                    (updates pseudo-term-listp)
                                    (combine pseudo-termp)
                                    (q symbolp)
                                    (r symbolp)
                                    (variant$ tailrec-variantp)
                                    (domain$ pseudo-termfnp)
                                    (new-name$ symbolp)
                                    (names-to-avoid symbol-listp)
                                    (app-cond-thm-names symbol-symbol-alistp)
                                    (old-unnorm-name symbolp)
                                    (domain-of-old-name symbolp)
                                    (new-formals symbol-listp)
                                    (new-unnorm-name symbolp)
                                    (wrld plist-worldp))
  :returns (mv (event "A @(tsee pseudo-event-formp).")
               (name "A @(tsee symbolp) that names the theorem."))
  :mode :program
  :short "Generate the theorem equating the new function
          to a combination of the old function with @('r')
          (@($f'{}f$) in the design notes)."
  :long
  "<p>
   The theorem's formula is
   </p>
   @({
     (implies (domain r)
              (equal (new x1 ... xn r)
                     combine<r,(old x1 ... xn)>))
   })
   <p>
   The equality is unconditional
   if @('domain') is @('(lambda (x) t)') (e.g. as default).
   </p>
   <p>
   The hints follow the proofs in the design notes.
   Note that @('combine-right-identity-thm?') is @('nil') iff
   the @(':combine-right-identity') applicability condition is absent,
   which happens exactly when
   the @(':variant') input to the transformation is @(':assoc').
   In this case, no instance of that applicability condition
   is used in the proof.
   </p>
   <p>
   This theorem event is local,
   because it is a lemma used to prove the exported main theorem.
   </p>"
  (b* ((name (fresh-name-in-world-with-$s 'new-to-old names-to-avoid wrld))
       (formula
        (untranslate (implicate
                      (apply-term* domain$ r)
                      `(equal ,(apply-term new-name$ new-formals)
                              ,(apply-term* (tailrec-gen-combine-op combine q r)
                                            r
                                            (apply-term old$
                                                        (formals old$
                                                                 wrld)))))
                     t wrld))
       (hints
        (case variant$
          ((:monoid :assoc)
           (b* ((domain-of-nonrec-thm
                 (cdr (assoc-eq :domain-of-nonrec app-cond-thm-names)))
                (domain-of-combine-thm
                 (cdr (assoc-eq :domain-of-combine app-cond-thm-names)))
                (combine-associativity-thm
                 (cdr (assoc-eq :combine-associativity app-cond-thm-names)))
                (combine-right-identity-thm?
                 (cdr (assoc-eq :combine-right-identity app-cond-thm-names)))
                (domain-of-combine-instance
                 `(:instance ,domain-of-combine-thm
                   :extra-bindings-ok
                   (,(tailrec-gen-var-u old$) ,r)
                   (,(tailrec-gen-var-v old$) ,nonrec)))
                (combine-associativity-instance
                 `(:instance ,combine-associativity-thm
                   :extra-bindings-ok
                   (,(tailrec-gen-var-u old$) ,r)
                   (,(tailrec-gen-var-v old$) ,nonrec)
                   (,(tailrec-gen-var-w old$)
                    ,(apply-term old$ updates))))
                (combine-right-identity-instance?
                 (and combine-right-identity-thm?
                      `(:instance ,combine-right-identity-thm?
                        :extra-bindings-ok
                        (,(tailrec-gen-id-var-u old$ wrld) ,r))))
                (domain-of-old-instance
                 `(:instance ,domain-of-old-name
                   :extra-bindings-ok
                   ,@(alist-to-doublets (pairlis$ (formals old$
                                                           wrld)
                                                  updates)))))
             `(("Goal"
                :in-theory '(,old-unnorm-name
                             ,new-unnorm-name
                             (:induction ,new-name$))
                :induct (,new-name$ ,@new-formals))
               '(:use (,@(and combine-right-identity-thm?
                              (list combine-right-identity-instance?))
                       ,domain-of-nonrec-thm
                       ,domain-of-combine-instance
                       ,domain-of-old-instance
                       ,combine-associativity-instance)))))
          (:monoid-alt
           (b* ((domain-of-combine-uncond-thm
                 (cdr (assoc-eq :domain-of-combine-uncond app-cond-thm-names)))
                (combine-associativity-uncond-thm
                 (cdr (assoc-eq :combine-associativity-uncond
                        app-cond-thm-names)))
                (combine-right-identity-thm
                 (cdr (assoc-eq :combine-right-identity app-cond-thm-names)))
                (domain-of-combine-uncond-instance
                 `(:instance ,domain-of-combine-uncond-thm
                   :extra-bindings-ok
                   (,(tailrec-gen-var-u old$) ,r)
                   (,(tailrec-gen-var-v old$) ,nonrec)))
                (combine-associativity-uncond-instance
                 `(:instance ,combine-associativity-uncond-thm
                   :extra-bindings-ok
                   (,(tailrec-gen-var-u old$) ,r)
                   (,(tailrec-gen-var-v old$) ,nonrec)
                   (,(tailrec-gen-var-w old$)
                    ,(apply-term old$ updates))))
                (combine-right-identity-instance
                 `(:instance ,combine-right-identity-thm
                   :extra-bindings-ok
                   (,(tailrec-gen-id-var-u old$ wrld) ,r))))
             `(("Goal"
                :in-theory '(,old-unnorm-name
                             ,new-unnorm-name
                             (:induction ,new-name$))
                :induct (,new-name$ ,@new-formals))
               '(:use (,combine-right-identity-instance
                       ,domain-of-combine-uncond-instance
                       ,combine-associativity-uncond-instance)))))
          (t (impossible))))
       (event `(local (defthm ,name
                        ,formula
                        :rule-classes nil
                        :hints ,hints))))
    (mv event name)))

(define tailrec-gen-alpha-fn ((old$ symbolp)
                              (test pseudo-termp)
                              (updates pseudo-term-listp)
                              (names-to-avoid symbol-listp)
                              (wrld plist-worldp))
  :returns (mv (event "A @(tsee pseudo-event-formp).")
               (name "A @(tsee symbolp)."))
  :mode :program
  :short "Generate the definition of
          the @($\\alpha$) function of the design notes."
  :long
  "<p>
   This function is generated only locally,
   because its purpose is just to prove local theorems
   (@($a\\alpha$) and @($\\gamma_f\\alpha$) in the design notes).
   Since this function is only used in theorems,
   it has a @('t') guard and its guards are not verified.
   The termination proof follows the design notes:
   measure and well-founded relation are the same as @('old').
   We do not normalize the function, so we can better control the proofs.
   </p>
   <p>
   The name used for @($\\alpha$) is returned, along with the event.
   </p>"
  (b* ((name (fresh-name-in-world-with-$s 'alpha names-to-avoid wrld))
       (formals (formals old$ wrld))
       (body `(if ,test (list ,@formals) (,name ,@updates)))
       (wfrel (well-founded-relation old$ wrld))
       (measure (measure old$ wrld))
       (termination-hints
        `(("Goal" :use (:termination-theorem ,old$) :in-theory nil)))
       (event `(local
                (defun ,name ,formals
                  (declare (xargs :well-founded-relation ,wfrel
                                  :measure ,measure
                                  :hints ,termination-hints
                                  :guard t
                                  :verify-guards nil
                                  :normalize nil))
                  ,body))))
    (mv event name)))

(define tailrec-gen-alpha-component-terms ((alpha-name symbolp)
                                           (old$ symbolp)
                                           (wrld plist-worldp))
  :returns (terms "A @(tsee pseudo-term-listp).")
  :verify-guards nil
  :short "Generate the terms of the components of the result of @($\\alpha$)."
  :long
  "<p>
   These are the terms
   @('(nth 0 (alpha x1 ... xn))'), ... @('(nth n-1 (alpha x1 ... xn))').
   </p>
   <p>
   The recursion constructs the terms in reverse order,
   with @('i') going from @('n') down to 1, exiting when it reaches 0.
   </p>"
  (b* ((formals (formals old$ wrld))
       (n (len formals)))
    (tailrec-gen-alpha-component-terms-aux n alpha-name formals nil))

  :prepwork
  ((define tailrec-gen-alpha-component-terms-aux ((i natp)
                                                  (alpha-name symbolp)
                                                  (formals symbol-listp)
                                                  (terms pseudo-term-listp))
     :returns (final-terms) ; PSEUDO-TERM-LISTP
     :verify-guards nil
     (if (zp i)
         terms
       (b* ((i-1 (1- i))
            (term `(nth ',i-1 (,alpha-name ,@formals))))
         (tailrec-gen-alpha-component-terms-aux i-1
                                                alpha-name
                                                formals
                                                (cons term terms)))))))

(define tailrec-gen-test-of-alpha-thm ((old$ symbolp)
                                       (test pseudo-termp)
                                       (alpha-name symbolp)
                                       (names-to-avoid symbol-listp)
                                       (wrld plist-worldp))
  :returns (mv (event "A @(tsee pseudo-event-formp).")
               (name "A @(tsee symbolp) that names the theorem."))
  :mode :program
  :short "Generate the theorem asserting that
          the recursion exit test succeeds on the result of @($\\alpha$)
          (@($a\\alpha$) in the design notes)."
  :long
  "<p>
   The theorem's formula is @('test<alpha_x1,...,alpha_xn>'),
   where @('alpha_xi') is the @('i')-th result of @($\\alpha$),
   counting from 1.
   </p>
   <p>
   The hints follow the proof in the design notes.
   Since the theorem involves @(tsee nth) applied to @(tsee cons),
   we enable the built-in theorems @('nth-0-cons') and @('nth-add1');
   this is implicit in the design notes.
   </p>
   <p>
   This theorem is local,
   because it is just a lemma used to prove other theorems.
   </p>"
  (b* ((name (fresh-name-in-world-with-$s 'test-of-alpha names-to-avoid wrld))
       (formals (formals old$ wrld))
       (alpha-component-terms (tailrec-gen-alpha-component-terms alpha-name
                                                                 old$
                                                                 wrld))
       (formula (subcor-var formals alpha-component-terms test))
       (hints `(("Goal"
                 :in-theory '(,alpha-name nth-0-cons nth-add1)
                 :induct (,alpha-name ,@formals))))
       (event `(local (defthm ,name
                        ,formula
                        :rule-classes nil
                        :hints ,hints))))
    (mv event name)))

(define tailrec-gen-old-guard-of-alpha-thm ((old$ symbolp)
                                            (alpha-name symbolp)
                                            (names-to-avoid symbol-listp)
                                            (wrld plist-worldp))
  :returns (mv (event "A @(tsee pseudo-event-formp).")
               (name "A @(tsee symbolp) that names the theorem."))
  :mode :program
  :short "Generate the theorem asserting that
          the guard of the old function is preserved by @($\\alpha$)
          (@($\\gamma_f\\alpha$) in the design notes)."
  :long
  "<p>
   The theorem's formula is
   @('(implies old-guard<x1,...,xn> old-guard<alpha_x1,...,alpha_xn>)'),
   where @('alpha_xi') is the @('i')-th result of @($\\alpha$),
   counting from 1.
   </p>
   <p>
   The hints follow the proof in the design notes.
   Since the theorem involves @(tsee nth) applied to @(tsee cons),
   we enable the built-in theorems @('nth-0-cons') and @('nth-add1');
   this is implicit in the design notes.
   </p>
   <p>
   This theorem is local,
   because it is just a lemma used to prove other theorems.
   </p>"
  (b* ((name (fresh-name-in-world-with-$s 'old-guard-of-alpha
                                          names-to-avoid
                                          wrld))
       (formals (formals old$ wrld))
       (alpha-component-terms (tailrec-gen-alpha-component-terms alpha-name
                                                                 old$
                                                                 wrld))
       (old-guard (guard old$ nil wrld))
       (formula (implicate old-guard
                           (subcor-var
                            formals alpha-component-terms old-guard)))
       (hints `(("Goal"
                 :in-theory '(,alpha-name nth-0-cons nth-add1)
                 :induct (,alpha-name ,@formals))
                '(:use (:guard-theorem ,old$))))
       (event `(local (defthm ,name
                        ,formula
                        :rule-classes nil
                        :hints ,hints))))
    (mv event name)))

(define tailrec-gen-domain-of-ground-base-thm
  ((old$ symbolp)
   (base pseudo-termp)
   (domain$ pseudo-termfnp)
   (app-cond-thm-names symbol-symbol-alistp)
   (alpha-name symbolp)
   (test-of-alpha-name symbolp)
   (names-to-avoid symbol-listp)
   (wrld plist-worldp))
  :returns (mv (event "A @(tsee pseudo-event-formp).")
               (name "A @(tsee symbolp) that names the theorem."))
  :mode :program
  :short "Generate the theorem asserting that
          the base value of the recursion is in the domain
          (@($D{}b_0$) in the design notes)."
  :long
  "<p>
   The hints follow the proof in the design notes.
   </p>
   <p>
   This theorem event is local,
   because it is just a lemma used to prove other theorems.
   </p>"
  (b* ((name (fresh-name-in-world-with-$s 'domain-of-ground-base
                                          names-to-avoid
                                          wrld))
       (formula (apply-term* domain$ base))
       (domain-of-base-thm
        (cdr (assoc-eq :domain-of-base app-cond-thm-names)))
       (formals (formals old$ wrld))
       (alpha-comps (tailrec-gen-alpha-component-terms alpha-name
                                                       old$
                                                       wrld))
       (hints `(("Goal"
                 :in-theory nil
                 :use (,test-of-alpha-name
                       (:instance ,domain-of-base-thm
                        :extra-bindings-ok
                        ,@(alist-to-doublets (pairlis$ formals
                                                       alpha-comps)))))))
       (event `(local (defthm ,name
                        ,formula
                        :rule-classes nil
                        :hints ,hints))))
    (mv event name)))

(define tailrec-gen-combine-left-identity-ground-thm
  ((old$ symbolp)
   (base pseudo-termp)
   (combine pseudo-termp)
   (q symbolp)
   (r symbolp)
   (domain$ pseudo-termfnp)
   (app-cond-thm-names symbol-symbol-alistp)
   (alpha-name symbolp)
   (test-of-alpha-name symbolp)
   (names-to-avoid symbol-listp)
   (wrld plist-worldp))
  :returns (mv (event "A @(tsee pseudo-event-formp).")
               (name "A @(tsee symbolp) that names the theorem."))
  :mode :program
  :short "Generate the theorem asserting that
          the base value of the recursion
          is left identity of the combination operator
          (@($L{}I_0$) in the design notes)."
  :long
  "<p>
   The hints follow the proof in the design notes.
   </p>
   <p>
   This theorem is local,
   because it is just a lemma used to prove other theorems.
   </p>"
  (b* ((name (fresh-name-in-world-with-$s 'combine-left-identity-ground
                                          names-to-avoid
                                          wrld))
       (u (tailrec-gen-var-u old$))
       (combine-op (tailrec-gen-combine-op combine q r))
       (formula (implicate (apply-term* domain$ u)
                           `(equal ,(apply-term* combine-op base u)
                                   ,u)))
       (combine-left-identity-thm
        (cdr (assoc-eq :combine-left-identity app-cond-thm-names)))
       (formals (formals old$ wrld))
       (alpha-comps (tailrec-gen-alpha-component-terms alpha-name
                                                       old$
                                                       wrld))
       (hints `(("Goal"
                 :in-theory nil
                 :use (,test-of-alpha-name
                       (:instance ,combine-left-identity-thm
                        :extra-bindings-ok
                        ,@(alist-to-doublets (pairlis$ formals
                                                       alpha-comps)))))))
       (event `(local (defthm ,name
                        ,formula
                        :rule-classes nil
                        :hints ,hints))))
    (mv event name)))

(define tailrec-gen-base-guard-thm ((old$ symbolp)
                                    (base pseudo-termp)
                                    (alpha-name symbolp)
                                    (test-of-alpha-name symbolp)
                                    (old-guard-of-alpha-name symbolp)
                                    (names-to-avoid symbol-listp)
                                    state)
  :returns (mv (event "A @(tsee pseudo-event-formp).")
               (name "A @(tsee symbolp) that names the theorem."))
  :mode :program
  :short "Generate the theorem asserting that
          the guard of the base term is satisfied
          if the guard of the target function is
          (@($G{}b$) in the design notes)."
  :long
  "<p>
   The hints follow the proof in the design notes.
   </p>
   <p>
   This theorem is local,
   because it is just a lemma used to prove other theorems.
   </p>"
  (b* ((wrld (w state))
       (name (fresh-name-in-world-with-$s 'base-guard names-to-avoid wrld))
       (formula (implicate (guard old$ nil wrld)
                           (term-guard-obligation base state)))
       (formals (formals old$ wrld))
       (alpha-comps (tailrec-gen-alpha-component-terms alpha-name
                                                       old$
                                                       wrld))
       (hints `(("Goal"
                 :in-theory nil
                 :use (,old-guard-of-alpha-name
                       ,test-of-alpha-name
                       (:instance (:guard-theorem ,old$)
                        :extra-bindings-ok
                        ,@(alist-to-doublets (pairlis$ formals
                                                       alpha-comps)))))))
       (event `(local (defthm ,name
                        ,formula
                        :rule-classes nil
                        :hints ,hints))))
    (mv event name)))

(define tailrec-gen-old-as-new-term ((old$ symbolp)
                                     (test pseudo-termp)
                                     (base pseudo-termp)
                                     (nonrec pseudo-termp)
                                     (updates pseudo-term-listp)
                                     (r symbolp)
                                     (variant$ tailrec-variantp)
                                     (new-name$ symbolp)
                                     (new-formals symbol-listp)
                                     (wrld plist-worldp))
  :returns (term "An untranslated term.")
  :mode :program
  :short "Generate the term that
          rephrases (a generic call to) the old function
          in terms of the new function."
  :long
  "<p>
   This is the right-hand side of the theorem
   that relates the old function to the new function
   (@($f{}f'$) in the design notes),
   and it is also the body of the wrapper function.
   </p>
   <p>
   This is as described in the documentation and design notes.
   It varies slightly, depending on the transformation's variant.
   As explained in the documentation,
   for now it uses @('base<x1,...,xn>') instead of the @($\\beta$) function.
   </p>"
  (untranslate (case variant$
                 (:assoc
                  `(if ,test
                       ,base
                     ,(subcor-var (cons r (formals old$ wrld))
                                  (cons nonrec updates)
                                  (apply-term new-name$ new-formals))))
                 ((:monoid :monoid-alt)
                  (subst-var base r (apply-term new-name$ new-formals)))
                 (t (impossible)))
               nil wrld))

(define tailrec-gen-old-to-new-thm ((old$ symbolp)
                                    (test pseudo-termp)
                                    (base pseudo-termp)
                                    (nonrec pseudo-termp)
                                    (updates pseudo-term-listp)
                                    (r symbolp)
                                    (variant$ tailrec-variantp)
                                    (new-name$ symbolp)
                                    (wrapper$ booleanp)
                                    (thm-name$ symbolp)
                                    (names-to-avoid symbol-listp)
                                    (app-cond-thm-names symbol-symbol-alistp)
                                    (domain-of-old-name symbolp)
                                    (domain-of-ground-base-name symbolp)
                                    (combine-left-identity-ground-name symbolp)
                                    (new-formals symbol-listp)
                                    (new-to-old-name symbolp)
                                    (wrld plist-worldp))
  :returns (mv (local-event "A @(tsee pseudo-event-formp).")
               (exported-event? "A @(tsee maybe-pseudo-event-formp).")
               (name "A @(tsee symbolp) that names the theorem."))
  :mode :program
  :short "Generate the theorem that relates
          the old function to the new function
          (@($f{}f'$) and @($f{}f'_0$) in the design notes)."
  :long
  "<p>
   The theorem is @($f{}f'$) when the variant is @(':assoc')
   (in this case, left identity does not hold),
   and @($f{}f'_0$) when the variant is @(':monoid') or @(':monoid-alt')
   (in this case, left identity holds,
   and we are in the special case of a ground base term).
   </p>
   <p>
   The hints follow the proof in the design notes,
   for the case in which left identity holds
   when the variant is @(':monoid') or @(':monoid-alt'),
   and for the case in which left identity does not hold
   when the variant is @(':assoc').
   In the first case, the proof is for the special case of a ground base term.
   </p>
   <p>
   For the @(':assoc') variant,
   since the old function is recursive,
   we use an explicit @(':expand') hint
   instead of just enabling the definition of old function.
   </p>
   <p>
   We always generate a local event for this theorem.
   If the @(':wrapper') input is @('nil'),
   we also generate an exported event because in that case
   there is no wrapper an no old-to-wrapper theorem.
   </p>"
  (b* ((name (if wrapper$
                 (fresh-name-in-world-with-$s 'old-to-new names-to-avoid wrld)
               thm-name$))
       (formula `(equal ,(apply-term old$ (formals old$ wrld))
                        ,(tailrec-gen-old-as-new-term
                          old$ test base nonrec updates r variant$
                          new-name$ new-formals wrld)))
       (hints
        (case variant$
          ((:monoid :monoid-alt)
           (b* ((combine-left-identity-ground-instance
                 `(:instance ,combine-left-identity-ground-name
                   :extra-bindings-ok
                   (,(tailrec-gen-id-var-u old$ wrld)
                    ,(apply-term old$ (formals old$
                                               wrld)))))
                (new-to-old-instance
                 `(:instance ,new-to-old-name
                   :extra-bindings-ok
                   (,r ,base))))
             `(("Goal"
                :in-theory nil
                :use (,domain-of-ground-base-name
                      ,domain-of-old-name
                      ,new-to-old-instance
                      ,combine-left-identity-ground-instance)))))
          (:assoc
           (b* ((formals (formals old$ wrld))
                (domain-of-nonrec-thm
                 (cdr (assoc-eq :domain-of-nonrec app-cond-thm-names)))
                (new-to-old-instance
                 `(:instance ,new-to-old-name
                   :extra-bindings-ok
                   (,r ,nonrec)
                   ,@(alist-to-doublets (pairlis$ formals updates)))))
             `(("Goal"
                :in-theory nil
                :expand ((,old$ ,@formals))
                :use (,domain-of-nonrec-thm
                      ,new-to-old-instance)))))
          (t (impossible))))
       (local-event `(local (defthm ,name
                              ,formula
                              :hints ,hints)))
       (exported-event? (and (not wrapper$)
                             `(defthm ,name
                                ,formula))))
    (mv local-event exported-event? name)))

(define tailrec-gen-wrapper-fn ((old$ symbolp)
                                (test pseudo-termp)
                                (base pseudo-termp)
                                (nonrec pseudo-termp)
                                (updates pseudo-term-listp)
                                (r symbolp)
                                (variant$ tailrec-variantp)
                                (new-name$ symbolp)
                                (wrapper-name$ symbolp)
                                (wrapper-enable$ booleanp)
                                (non-executable$ booleanp)
                                (verify-guards$ booleanp)
                                (app-cond-thm-names symbol-symbol-alistp)
                                (domain-of-ground-base-name symbolp)
                                (base-guard-name symbolp)
                                (new-formals symbol-listp)
                                (wrld plist-worldp))
  :returns (mv (local-event "A @(tsee pseudo-event-formp).")
               (exported-event "A @(tsee pseudo-event-formp)."))
  :mode :program
  :short "Generate the wrapper function definition."
  :long
  "<p>
   The macro used to introduce the new function is determined by
   whether the new function must be
   enabled or not, and non-executable or not.
   </p>
   <p>
   The wrapper function has the same formal arguments as the old function.
   </p>
   <p>
   The body of the wrapper function is
   the rephrasing of the old function in terms of the new function.
   </p>
   <p>
   The guard of the wrapper function is the same as the old function.
   </p>
   <p>
   The guard hints are based on the proofs in the design notes.
   Since the base term is always ground,
   the proof for the case in which left identity holds
   (i.e. when the variant is @(':monoid') or @(':monoid-alt'))
   follows the proof for the special case of a ground base term.
   </p>
   <p>
   This function is called only if the @(':wrapper') input is @('t').
   </p>"
  (b* ((macro (function-intro-macro wrapper-enable$ non-executable$))
       (formals (formals old$ wrld))
       (body (tailrec-gen-old-as-new-term
              old$ test base nonrec updates r variant$
              new-name$ new-formals wrld))
       (guard (untranslate (guard old$ nil wrld) t wrld))
       (guard-hints
        (case variant$
          ((:monoid :monoid-alt)
           `(("Goal"
              :in-theory nil
              :use ((:guard-theorem ,old$)
                    ,domain-of-ground-base-name
                    ,base-guard-name))))
          (:assoc
           (b* ((domain-of-nonrec-thm
                 (cdr (assoc-eq :domain-of-nonrec app-cond-thm-names))))
             `(("Goal"
                :in-theory nil
                :use ((:guard-theorem ,old$)
                      ,domain-of-nonrec-thm)))))
          (t (impossible))))
       (local-event
        `(local
          (,macro ,wrapper-name$ (,@formals)
                  (declare (xargs :guard ,guard
                                  :verify-guards ,verify-guards$
                             ,@(and verify-guards$
                                    (list :guard-hints guard-hints))))
                  ,body)))
       (exported-event
        `(,macro ,wrapper-name$ (,@formals)
                 (declare (xargs :guard ,guard
                                 :verify-guards ,verify-guards$))
                 ,body)))
    (mv local-event exported-event)))

(define tailrec-gen-old-to-wrapper-thm ((old$ symbolp)
                                        (wrapper-name$ symbolp)
                                        (thm-name$ symbolp)
                                        (thm-enable$ booleanp)
                                        (old-to-new-name symbolp)
                                        (wrapper-unnorm-name symbolp)
                                        (wrld plist-worldp))
  :returns (mv (local-event "A @(tsee pseudo-event-formp).")
               (exported-event "A @(tsee pseudo-event-formp)."))
  :mode :program
  :short "Generate the theorem
          that relates the old function to the wrapper function
          (@($f{}\\tilde{f}$) in the design notes)."
  :long
  "<p>
   The macro used to introduce the theorem is determined by
   whether the theorem must be enabled or not.
   </p>
   <p>
   The theorem's formula
   has the form @('(equal (old x1 ... xn) (wrapper x1 ... xn))').
   </p>
   <p>
   The theorem is proved by
   expanding the (non-normalized) definition of the wrapper function
   and using the theorem that relates the old function to the new function.
   </p>
   <p>
   This function is called only if the @(':wrapper') input is @('t').
   </p>"
  (b* ((macro (theorem-intro-macro thm-enable$))
       (formals (formals old$ wrld))
       (formula (untranslate `(equal ,(apply-term old$ formals)
                                     ,(apply-term wrapper-name$ formals))
                             t wrld))
       (hints `(("Goal"
                 :in-theory '(,wrapper-unnorm-name)
                 :use ,old-to-new-name)))
       (local-event `(local (,macro ,thm-name$
                                    ,formula
                                    :hints ,hints)))
       (exported-event `(,macro ,thm-name$
                                ,formula)))
    (mv local-event exported-event)))

(define tailrec-gen-everything
  ((old$ symbolp)
   (test pseudo-termp)
   (base pseudo-termp)
   (nonrec pseudo-termp)
   (updates pseudo-term-listp)
   (combine pseudo-termp)
   (q symbolp)
   (r symbolp)
   (variant$ tailrec-variantp)
   (domain$ pseudo-termfnp)
   (new-name$ symbolp)
   (new-enable$ booleanp)
   (wrapper$ booleanp)
   (wrapper-name$ symbolp)
   (wrapper-enable$ booleanp)
   (thm-name$ symbolp)
   (thm-enable$ booleanp)
   (non-executable$ booleanp)
   (verify-guards$ booleanp)
   (hints$ symbol-alistp)
   (print$ evmac-input-print-p)
   (show-only$ booleanp)
   (app-cond-present-names tailrec-app-cond-name-listp)
   (call pseudo-event-formp)
   ctx
   state)
  :returns (event "A @(tsee pseudo-event-formp).")
  :mode :program
  :short "Generate the top-level event."
  :long
  "<p>
   This is a @(tsee progn) that consists of
   the expansion of @(tsee tailrec) (the @(tsee encapsulate)),
   followed by an event to extend the transformation table,
   optionally followed by events to print the exported events
   (if specified by the @(':print') input).
   The @(tsee progn) ends with @(':invisible') to avoid printing a return value.
   </p>
   <p>
   The @(tsee encapsulate) starts with some implicitly local events to
   ensure logic mode and
   avoid errors due to ignored or irrelevant formals in the generated functions.
   Other implicitly local event forms remove any default and override hints,
   to prevent such hints from sabotaging the generated proofs;
   this removal is done after proving the applicability conditions,
   in case their proofs rely on the default or override hints.
   </p>
   <p>
   The @(tsee encapsulate) also includes events
   to locally install the non-normalized definitions
   of the old, new, and (if generated) wrapper functions,
   because the generated proofs are based on the unnormalized bodies.
   </p>
   <p>
   The @(tsee encapsulate) is stored into the transformation table,
   associated to the call to the transformation.
   Thus, the table event and (if present) the screen output events
   (which are in the @(tsee progn) but not in the @(tsee encapsulate))
   are not stored into the transformation table,
   because they carry no additional information,
   and because otherwise the table event would have to contain itself.
   </p>
   <p>
   If @(':print') is @(':all'),
   the @(tsee encapsulate) is wrapped to show ACL2's output
   in response to the submitted events.
   If @(':print') is @(':result') or @(':info') or @(':all'),
   the @(tsee progn) includes events to print
   the exported events on the screen without hints;
   these are the same event forms
   that are introduced non-locally and redundantly in the @(tsee encapsulate).
   If @(':print') is @(':info') or @(':all'),
   a blank line is printed just before the result, for visual separation;
   if @(':print') is @(':result'),
   the blank line is not printed.
   </p>
   <p>
   If @(':show-only') is @('t'),
   the @(tsee encapsulate) is just printed on the screen
   and not returned as part of the event to submit,
   which in this case is just an @(':invisible') form.
   In this case, if @(':print') is @(':info') or @(':all'),
   a blank line is printed just before the @(tsee encapsulate),
   for visual separation.
   </p>"
  (b* ((wrld (w state))
       (names-to-avoid (if wrapper$
                           (list new-name$
                                 wrapper-name$
                                 thm-name$)
                         (list new-name$
                               thm-name$)))
       ((mv app-cond-thm-events
            app-cond-thm-names) (tailrec-gen-app-conds old$
                                                       test
                                                       base
                                                       nonrec
                                                       combine
                                                       q
                                                       r
                                                       variant$
                                                       domain$
                                                       verify-guards$
                                                       hints$
                                                       print$
                                                       app-cond-present-names
                                                       names-to-avoid
                                                       ctx
                                                       state))
       (names-to-avoid (append names-to-avoid
                               (strip-cdrs app-cond-thm-names)))
       ((mv old-unnorm-event
            old-unnorm-name) (install-not-norm-event old$
                                                     t
                                                     names-to-avoid
                                                     wrld))
       (names-to-avoid (cons old-unnorm-name names-to-avoid))
       ((mv domain-of-old-event
            domain-of-old-name) (tailrec-gen-domain-of-old-thm
                                 old$ test nonrec updates
                                 variant$ domain$
                                 names-to-avoid
                                 app-cond-thm-names
                                 old-unnorm-name
                                 wrld))
       (names-to-avoid (cons domain-of-old-name names-to-avoid))
       ((mv new-fn-local-event
            new-fn-exported-event
            new-formals) (tailrec-gen-new-fn
                          old$
                          test base nonrec updates combine q r
                          variant$ domain$
                          new-name$ new-enable$
                          non-executable$ verify-guards$
                          app-cond-thm-names
                          wrld))
       ((mv new-unnorm-event
            new-unnorm-name) (install-not-norm-event new-name$
                                                     t
                                                     names-to-avoid
                                                     wrld))
       (names-to-avoid (cons new-unnorm-name names-to-avoid))
       ((mv new-to-old-event
            new-to-old-name) (tailrec-gen-new-to-old-thm
                              old$ nonrec updates combine q r
                              variant$ domain$
                              new-name$
                              names-to-avoid
                              app-cond-thm-names
                              old-unnorm-name
                              domain-of-old-name
                              new-formals
                              new-unnorm-name
                              wrld))
       (names-to-avoid (cons new-to-old-name names-to-avoid))
       (gen-alpha (member-eq variant$ '(:monoid :monoid-alt)))
       ((mv alpha-event?
            alpha-name?) (if gen-alpha
                             (tailrec-gen-alpha-fn
                              old$ test updates
                              names-to-avoid wrld)
                           (mv nil nil)))
       (names-to-avoid (if gen-alpha
                           (cons alpha-name? names-to-avoid)
                         names-to-avoid))
       ((mv test-of-alpha-event?
            test-of-alpha-name?) (if gen-alpha
                                     (tailrec-gen-test-of-alpha-thm
                                      old$ test
                                      alpha-name?
                                      names-to-avoid wrld)
                                   (mv nil nil)))
       (names-to-avoid (if gen-alpha
                           (cons test-of-alpha-name? names-to-avoid)
                         names-to-avoid))
       ((mv old-guard-of-alpha-event?
            old-guard-of-alpha-name?)
        (if (and gen-alpha
                 verify-guards$)
            (tailrec-gen-old-guard-of-alpha-thm
             old$ alpha-name? names-to-avoid wrld)
          (mv nil nil)))
       (names-to-avoid (if (and gen-alpha
                                verify-guards$)
                           (cons old-guard-of-alpha-name? names-to-avoid)
                         names-to-avoid))
       ((mv domain-of-ground-base-event?
            domain-of-ground-base-name?)
        (if gen-alpha
            (tailrec-gen-domain-of-ground-base-thm
             old$ base domain$ app-cond-thm-names
             alpha-name? test-of-alpha-name?
             names-to-avoid wrld)
          (mv nil nil)))
       (names-to-avoid (if gen-alpha
                           (cons domain-of-ground-base-name?
                                 names-to-avoid)
                         names-to-avoid))
       ((mv combine-left-identity-ground-event?
            combine-left-identity-ground-name?)
        (if gen-alpha
            (tailrec-gen-combine-left-identity-ground-thm
             old$ base combine q r domain$ app-cond-thm-names
             alpha-name? test-of-alpha-name?
             names-to-avoid wrld)
          (mv nil nil)))
       (names-to-avoid (if gen-alpha
                           (cons combine-left-identity-ground-name?
                                 names-to-avoid)
                         names-to-avoid))
       ((mv base-guard-event?
            base-guard-name?) (if (and gen-alpha
                                       verify-guards$)
                                  (tailrec-gen-base-guard-thm
                                   old$ base
                                   alpha-name? test-of-alpha-name?
                                   old-guard-of-alpha-name?
                                   names-to-avoid state)
                                (mv nil nil)))
       (names-to-avoid (if (and gen-alpha
                                verify-guards$)
                           (cons base-guard-name? names-to-avoid)
                         names-to-avoid))
       ((mv old-to-new-thm-local-event
            old-to-new-thm-exported-event?
            old-to-new-name) (tailrec-gen-old-to-new-thm
                              old$ test base nonrec updates r
                              variant$
                              new-name$
                              wrapper$
                              thm-name$
                              names-to-avoid
                              app-cond-thm-names
                              domain-of-old-name
                              domain-of-ground-base-name?
                              combine-left-identity-ground-name?
                              new-formals
                              new-to-old-name
                              wrld))
       (names-to-avoid (cons old-to-new-name names-to-avoid))
       ((mv wrapper-fn-local-event?
            wrapper-fn-exported-event?) (if wrapper$
                                            (tailrec-gen-wrapper-fn
                                             old$
                                             test base nonrec updates r
                                             variant$
                                             new-name$
                                             wrapper-name$ wrapper-enable$
                                             non-executable$ verify-guards$
                                             app-cond-thm-names
                                             domain-of-ground-base-name?
                                             base-guard-name?
                                             new-formals
                                             wrld)
                                          (mv nil nil)))
       ((mv wrapper-unnorm-event?
            wrapper-unnorm-name?) (if wrapper$
                                      (install-not-norm-event wrapper-name$
                                                              t
                                                              names-to-avoid
                                                              wrld)
                                    (mv nil nil)))
       ((mv
         old-to-wrapper-thm-local-event?
         old-to-wrapper-thm-exported-event?) (if wrapper$
                                                 (tailrec-gen-old-to-wrapper-thm
                                                  old$
                                                  wrapper-name$
                                                  thm-name$
                                                  thm-enable$
                                                  old-to-new-name
                                                  wrapper-unnorm-name?
                                                  wrld)
                                               (mv nil nil)))
       (new-fn-numbered-name-event `(add-numbered-name-in-use
                                     ,new-name$))
       (wrapper-fn-numbered-name-event? (if wrapper$
                                            `(add-numbered-name-in-use
                                              ,wrapper-name$)
                                          nil))
       (encapsulate-events
        `((logic)
          (set-ignore-ok t)
          (set-irrelevant-formals-ok t)
          ,@app-cond-thm-events
          (set-default-hints nil)
          (set-override-hints nil)
          ,old-unnorm-event
          ,domain-of-old-event
          ,new-fn-local-event
          ,new-unnorm-event
          ,new-to-old-event
          ,@(and gen-alpha
                 (list alpha-event?))
          ,@(and gen-alpha
                 (list test-of-alpha-event?))
          ,@(and gen-alpha
                 verify-guards$
                 (list old-guard-of-alpha-event?))
          ,@(and gen-alpha
                 (list domain-of-ground-base-event?))
          ,@(and gen-alpha
                 (list combine-left-identity-ground-event?))
          ,@(and gen-alpha
                 verify-guards$
                 (list base-guard-event?))
          ,old-to-new-thm-local-event
          ,@(and wrapper$ (list wrapper-fn-local-event?))
          ,@(and wrapper$ (list wrapper-unnorm-event?))
          ,@(and wrapper$ (list old-to-wrapper-thm-local-event?))
          ,new-fn-exported-event
          ,@(and wrapper$ (list wrapper-fn-exported-event?))
          ,(if wrapper$
               old-to-wrapper-thm-exported-event?
             old-to-new-thm-exported-event?)
          ,new-fn-numbered-name-event
          ,@(and wrapper$ (list wrapper-fn-numbered-name-event?))))
       (encapsulate `(encapsulate () ,@encapsulate-events))
       ((when show-only$)
        (if (member-eq print$ '(:info :all))
            (cw "~%~x0~|" encapsulate)
          (cw "~x0~|" encapsulate))
        '(value-triple :invisible))
       (encapsulate+ (restore-output? (eq print$ :all) encapsulate))
       (transformation-table-event (record-transformation-call-event
                                    call encapsulate wrld))
       (print-result (and
                      (member-eq print$ '(:result :info :all))
                      `(,@(and (member-eq print$ '(:info :all))
                               '((cw-event "~%")))
                        (cw-event "~x0~|" ',new-fn-exported-event)
                        ,@(and wrapper$
                               (list `(cw-event "~x0~|"
                                                ',wrapper-fn-exported-event?)))
                        ,(if wrapper$
                             `(cw-event "~x0~|"
                                        ',old-to-wrapper-thm-exported-event?)
                           `(cw-event "~x0~|"
                                      ',old-to-new-thm-exported-event?))))))
    `(progn
       ,encapsulate+
       ,transformation-table-event
       ,@print-result
       (value-triple :invisible))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define tailrec-fn (old
                    variant
                    domain
                    new-name
                    new-enable
                    wrapper
                    wrapper-name
                    (wrapper-name-present booleanp)
                    wrapper-enable
                    (wrapper-enable-present booleanp)
                    thm-name
                    thm-enable
                    non-executable
                    verify-guards
                    hints
                    print
                    show-only
                    (call pseudo-event-formp)
                    ctx
                    state)
  :returns (mv erp
               (event "A @(tsee pseudo-event-formp).")
               state)
  :mode :program
  :parents (tailrec-implementation)
  :short "Check redundancy,
          process the inputs, and
          generate the event to submit."
  :long
  "<p>
   If this call to the transformation is redundant,
   a message to that effect is printed on the screen.
   If the transformation is redundant and @(':show-only') is @('t'),
   the @(tsee encapsulate), retrieved from the table, is shown on the screen.
   </p>"
  (b* ((encapsulate? (previous-transformation-expansion call (w state)))
       ((when encapsulate?)
        (b* (((run-when show-only) (cw "~x0~|" encapsulate?)))
          (cw "~%The transformation ~x0 is redundant.~%" call)
          (value '(value-triple :invisible))))
       ((er (list old$
                  test
                  base
                  nonrec
                  updates
                  combine
                  q
                  r
                  domain$
                  new-name$
                  new-enable$
                  wrapper-name$
                  thm-name$
                  non-executable$
                  verify-guards$
                  hints$
                  app-cond-present-names)) (tailrec-process-inputs
                                            old
                                            variant
                                            domain
                                            new-name
                                            new-enable
                                            wrapper
                                            wrapper-name
                                            wrapper-name-present
                                            wrapper-enable
                                            wrapper-enable-present
                                            thm-name
                                            thm-enable
                                            non-executable
                                            verify-guards
                                            hints
                                            print
                                            show-only
                                            ctx state))
       (event (tailrec-gen-everything old$
                                      test
                                      base
                                      nonrec
                                      updates
                                      combine
                                      q
                                      r
                                      variant
                                      domain$
                                      new-name$
                                      new-enable$
                                      wrapper
                                      wrapper-name$
                                      wrapper-enable
                                      thm-name$
                                      thm-enable
                                      non-executable$
                                      verify-guards$
                                      hints$
                                      print
                                      show-only
                                      app-cond-present-names
                                      call
                                      ctx
                                      state)))
    (value event)))

(defsection tailrec-macro-definition
  :parents (tailrec-implementation)
  :short "Definition of the @(tsee tailrec) macro."
  :long
  "<p>
   Submit the event form generated by @(tsee tailrec-fn).
   </p>
   @(def tailrec)"
  (defmacro tailrec (&whole
                     call
                     ;; mandatory inputs:
                     old
                     ;; optional inputs:
                     &key
                     (variant ':monoid)
                     (domain ':auto)
                     (new-name ':auto)
                     (new-enable ':auto)
                     (wrapper 't)
                     (wrapper-name ':auto wrapper-name-present)
                     (wrapper-enable 't wrapper-enable-present)
                     (thm-name ':auto)
                     (thm-enable 't)
                     (non-executable ':auto)
                     (verify-guards ':auto)
                     (hints 'nil)
                     (print ':result)
                     (show-only 'nil))
    `(make-event-terse (tailrec-fn ',old
                                   ',variant
                                   ',domain
                                   ',new-name
                                   ',new-enable
                                   ',wrapper
                                   ',wrapper-name
                                   ',wrapper-name-present
                                   ',wrapper-enable
                                   ',wrapper-enable-present
                                   ',thm-name
                                   ',thm-enable
                                   ',non-executable
                                   ',verify-guards
                                   ',hints
                                   ',print
                                   ',show-only
                                   ',call
                                   (cons 'tailrec ',old)
                                   state)
                       :suppress-errors ,(not print))))
