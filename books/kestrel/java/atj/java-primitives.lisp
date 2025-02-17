; Java Library
;
; Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "JAVA")

(include-book "types")

(include-book "../language/primitive-conversions")

(include-book "kestrel/std/system/function-name-listp" :dir :system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc+ atj-java-primitives
  :parents (atj-implementation)
  :short "Representation of Java primitive types and operations for ATJ."
  :long
  (xdoc::topstring
   (xdoc::p
    "In order to have ATJ generate Java code
     that manipulates Java primitive values,
     we use ACL2 functions that correspond to
     the Java primitive values and operations:
     when ATJ encounters these specific ACL2 functions,
     it translate them to corresponding Java constructs
     that operate on primitive types;
     this happens only when @(':deep') is @('nil') and @(':guards') is @('t').")
   (xdoc::p
    "When deriving a Java implementation from a specification,
     where ATJ is used as the last step of the derivation,
     the steps just before the last one can refine the ACL2 code
     to use the aforementioned ACL2 functions,
     ideally using " (xdoc::seetopic "apt::apt" "APT") " transformations,
     so that ATJ can produce Java code
     that operates on primitive values where needed.
     Such refinement steps could perhaps be somewhat automated,
     and incorporated into a code generation step that actually encompasses
     some APT transformation steps
     before the final ATJ code generation step.")
   (xdoc::p
    "The natural place for the aforementioned ACL2 functions
     that correspond to Java primitive values and operations is the "
    (xdoc::seetopic "language" "language formalization")
    " that is being developed.
     So ATJ recognizes those functions from the language formalization,
     and translates them to Java code that manipulates Java primitive values.")
   (xdoc::p
    "Needless to say, here `primitive' refers to
     Java primitive types, values, and operations.
     It has nothing to do with the ACL2 primitive functions."))
  :order-subtopics t
  :default-parent t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defsection atj-java-primitive-values-representation-check
  :short "Checking the representation of Java primitive values."
  :long
  (xdoc::topstring
   (xdoc::p
    "The fixtypes for the Java primitive types (e.g. @(tsee int-value))
     provide the representation of Java primitive types in ACL2,
     which ATJ maps to Java primitive values.
     While values of those ACL2 fixtypes can be treated abstractly,
     nothing prevents the use of ACL2 operations on them
     that expose their internal structure, e.g. taking the @(tsee car).
     Thus, Java code generated by ATJ must, if needed,
     convert Java primitive values to
     the Java representation of their ACL2 representation.")
   (xdoc::p
    "The following theorems ensure that the aforementioned fixtypes
     have the representation assumed by ATJ."))

  (defrule atj-java-boolean-value-representation-check
    (equal (boolean-value-p x)
           (and (tuplep 2 x)
                (eq (first x) :boolean)
                (booleanp (second x))))
    :rule-classes nil
    :enable boolean-value-p)

  (defrule atj-java-char-value-representation-check
    (equal (char-value-p x)
           (and (tuplep 2 x)
                (eq (first x) :char)
                (ubyte16p (second x))))
    :rule-classes nil
    :enable char-value-p)

  (defrule atj-java-byte-value-representation-check
    (equal (byte-value-p x)
           (and (tuplep 2 x)
                (eq (first x) :byte)
                (sbyte8p (second x))))
    :rule-classes nil
    :enable byte-value-p)

  (defrule atj-java-short-value-representation-check
    (equal (short-value-p x)
           (and (tuplep 2 x)
                (eq (first x) :short)
                (sbyte16p (second x))))
    :rule-classes nil
    :enable short-value-p)

  (defrule atj-java-int-value-representation-check
    (equal (int-value-p x)
           (and (tuplep 2 x)
                (eq (first x) :int)
                (sbyte32p (second x))))
    :rule-classes nil
    :enable int-value-p)

  (defrule atj-java-long-value-representation-check
    (equal (long-value-p x)
           (and (tuplep 2 x)
                (eq (first x) :long)
                (sbyte64p (second x))))
    :rule-classes nil
    :enable long-value-p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defval *atj-java-primitive-constructors*
  :short "List of (the names of) the ACL2 functions that model
          the construction of Java primitive types."
  :long
  (xdoc::topstring
   (xdoc::p
    "The list only consists of the constructors for the Java primitive types
     that ATJ currently supports,
     namely all the primitive types except @('float') and @('double')."))
  '(boolean-value
    char-value
    byte-value
    short-value
    int-value
    long-value))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defval *atj-java-primitive-unops*
  :short "List of (the names of) the ACL2 functions that model
          Java primitive unary operations."
  :long
  (xdoc::topstring
   (xdoc::p
    "These are all the unary boolean and integer operations,
     and all the conversions between primitive types.
     Only unary operations involving floating-point values are not here."))
  '(;; unary boolean operations:
    boolean-not
    ;; unary integer operations:
    int-plus
    long-plus
    int-minus
    long-minus
    int-not
    long-not
    ;; widening conversions:
    byte-to-short
    byte-to-int
    byte-to-long
    short-to-int
    short-to-long
    int-to-long
    char-to-int
    char-to-long
    ;; narrowing conversions:
    short-to-byte
    int-to-byte
    long-to-byte
    char-to-byte
    int-to-short
    long-to-short
    char-to-short
    long-to-int
    short-to-char
    int-to-char
    long-to-char
    ;; widening and narrowing conversions:
    byte-to-char))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defval *atj-java-primitive-binops*
  :short "List of (the names of) the ACL2 functions that model
          Java primitive binary operations."
  :long
  (xdoc::topstring
   (xdoc::p
    "These are all the binary boolean and integer operations.
     Only binary operations involving floating-point values are not here."))
  '(;; binary boolean operations:
    boolean-and
    boolean-xor
    boolean-ior
    boolean-eq
    boolean-neq
    ;; binary integer operations:
    int-add
    long-add
    int-sub
    long-sub
    int-mul
    long-mul
    int-div
    long-div
    int-rem
    long-rem
    int-and
    long-and
    int-xor
    long-xor
    int-ior
    long-ior
    int-eq
    long-eq
    int-neq
    long-neq
    int-less
    long-less
    int-lesseq
    long-lesseq
    int-great
    long-great
    int-greateq
    long-greateq
    int-int-shiftl
    long-long-shiftl
    long-int-shiftl
    int-long-shiftl
    int-int-shiftr
    long-long-shiftr
    long-int-shiftr
    int-long-shiftr
    int-int-ushiftr
    long-long-ushiftr
    long-int-ushiftr
    int-long-ushiftr))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defval *atj-java-primitive-fns*
  :short "List of (the names of) the ACL2 functions that model
          Java primitive value constructions and operations."
  (append *atj-java-primitive-constructors*
          *atj-java-primitive-unops*
          *atj-java-primitive-binops*)
  ///
  (assert-event (function-name-listp *atj-java-primitive-fns* (w state)))
  (assert-event (no-duplicatesp-eq *atj-java-primitive-fns*)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defsection atj-types-for-java-primitives
  :short "ATJ types for the Java primitive constructors and operations."

  ;; primitive constructors:

  (def-atj-main-function-type boolean-value (:asymbol) :jboolean)

  (def-atj-main-function-type char-value (:ainteger) :jchar)

  (def-atj-main-function-type byte-value (:ainteger) :jbyte)

  (def-atj-main-function-type short-value (:ainteger) :jshort)

  (def-atj-main-function-type int-value (:ainteger) :jint)

  (def-atj-main-function-type long-value (:ainteger) :jlong)

  ;; boolean operations:

  (def-atj-main-function-type boolean-not (:jboolean) :jboolean)

  (def-atj-main-function-type boolean-and (:jboolean :jboolean) :jboolean)

  (def-atj-main-function-type boolean-xor (:jboolean :jboolean) :jboolean)

  (def-atj-main-function-type boolean-ior (:jboolean :jboolean) :jboolean)

  (def-atj-main-function-type boolean-eq (:jboolean :jboolean) :jboolean)

  (def-atj-main-function-type boolean-neq (:jboolean :jboolean) :jboolean)

  ;; integer operations:

  (def-atj-main-function-type int-plus (:jint) :jint)

  (def-atj-main-function-type long-plus (:jlong) :jlong)

  (def-atj-main-function-type int-minus (:jint) :jint)

  (def-atj-main-function-type long-minus (:jlong) :jlong)

  (def-atj-main-function-type int-add (:jint :jint) :jint)

  (def-atj-main-function-type long-add (:jlong :jlong) :jlong)

  (def-atj-main-function-type int-sub (:jint :jint) :jint)

  (def-atj-main-function-type long-sub (:jlong :jlong) :jlong)

  (def-atj-main-function-type int-mul (:jint :jint) :jint)

  (def-atj-main-function-type long-mul (:jlong :jlong) :jlong)

  (def-atj-main-function-type int-div (:jint :jint) :jint)

  (def-atj-main-function-type long-div (:jlong :jlong) :jlong)

  (def-atj-main-function-type int-rem (:jint :jint) :jint)

  (def-atj-main-function-type long-rem (:jlong :jlong) :jlong)

  (def-atj-main-function-type int-not (:jint) :jint)

  (def-atj-main-function-type long-not (:jlong) :jlong)

  (def-atj-main-function-type int-and (:jint :jint) :jint)

  (def-atj-main-function-type long-and (:jlong :jlong) :jlong)

  (def-atj-main-function-type int-xor (:jint :jint) :jint)

  (def-atj-main-function-type long-xor (:jlong :jlong) :jlong)

  (def-atj-main-function-type int-ior (:jint :jint) :jint)

  (def-atj-main-function-type long-ior (:jlong :jlong) :jlong)

  (def-atj-main-function-type int-eq (:jint :jint) :jboolean)

  (def-atj-main-function-type long-eq (:jlong :jlong) :jboolean)

  (def-atj-main-function-type int-neq (:jint :jint) :jboolean)

  (def-atj-main-function-type long-neq (:jlong :jlong) :jboolean)

  (def-atj-main-function-type int-less (:jint :jint) :jboolean)

  (def-atj-main-function-type long-less (:jlong :jlong) :jboolean)

  (def-atj-main-function-type int-lesseq (:jint :jint) :jboolean)

  (def-atj-main-function-type long-lesseq (:jlong :jlong) :jboolean)

  (def-atj-main-function-type int-great (:jint :jint) :jboolean)

  (def-atj-main-function-type long-great (:jlong :jlong) :jboolean)

  (def-atj-main-function-type int-greateq (:jint :jint) :jboolean)

  (def-atj-main-function-type long-greateq (:jlong :jlong) :jboolean)

  (def-atj-main-function-type int-int-shiftl (:jint :jint) :jint)

  (def-atj-main-function-type long-long-shiftl (:jlong :jlong) :jlong)

  (def-atj-main-function-type long-int-shiftl (:jlong :jint) :jlong)

  (def-atj-main-function-type int-long-shiftl (:jint :jlong) :jint)

  (def-atj-main-function-type int-int-shiftr (:jint :jint) :jint)

  (def-atj-main-function-type long-long-shiftr (:jlong :jlong) :jlong)

  (def-atj-main-function-type long-int-shiftr (:jlong :jint) :jlong)

  (def-atj-main-function-type int-long-shiftr (:jint :jlong) :jint)

  (def-atj-main-function-type int-int-ushiftr (:jint :jint) :jint)

  (def-atj-main-function-type long-long-ushiftr (:jlong :jlong) :jlong)

  (def-atj-main-function-type long-int-ushiftr (:jlong :jint) :jlong)

  (def-atj-main-function-type int-long-ushiftr (:jint :jlong) :jint)

  ;; widening conversions:

  (def-atj-main-function-type byte-to-short (:jbyte) :jshort)

  (def-atj-main-function-type byte-to-int (:jbyte) :jint)

  (def-atj-main-function-type byte-to-long (:jbyte) :jlong)

  (def-atj-main-function-type short-to-int (:jshort) :jint)

  (def-atj-main-function-type short-to-long (:jshort) :jlong)

  (def-atj-main-function-type int-to-long (:jint) :jlong)

  (def-atj-main-function-type char-to-int (:jchar) :jint)

  (def-atj-main-function-type char-to-long (:jchar) :jlong)

  ;; narrowing conversions:

  (def-atj-main-function-type short-to-byte (:jshort) :jbyte)

  (def-atj-main-function-type int-to-byte (:jint) :jbyte)

  (def-atj-main-function-type long-to-byte (:jlong) :jbyte)

  (def-atj-main-function-type char-to-byte (:jchar) :jbyte)

  (def-atj-main-function-type int-to-short (:jint) :jshort)

  (def-atj-main-function-type long-to-short (:jlong) :jshort)

  (def-atj-main-function-type char-to-short (:jchar) :jshort)

  (def-atj-main-function-type long-to-int (:jlong) :jint)

  (def-atj-main-function-type short-to-char (:jshort) :jchar)

  (def-atj-main-function-type int-to-char (:jint) :jchar)

  (def-atj-main-function-type long-to-char (:jlong) :jchar)

  ;; widening and narrowing conversions:

  (def-atj-main-function-type byte-to-char (:jbyte) :jchar))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defsection atj-types-for-boolean-value-destructor
  :short "ATJ types for the Java boolean destructor."
  :long
  (xdoc::topstring
   (xdoc::p
    "The ACL2 destructor of Java boolean values @(tsee boolean-value->bool)
     plays a special role in the translation of ACL2 to Java.
     An ACL2 @(tsee if) test of the form @('(boolean-value->bool b)'),
     where @('b') is an ACL2 term that returns a @(tsee boolean-value)
     (i.e. a Java boolean value in our model),
     is compiled to Java @('if') test that consists of just
     the Java expression derived from @('b'):
     for instance, if @('b') is @('(java::int-less x y)'),
     the generated Java test is @('(jx < jy)'),
     where @('jx') and @('jy') are the Java equivalents of @('x') and @('y).")
   (xdoc::p
    "To make this work, we do not want the generated Java code
     to convert @('b') to the Java representation of the ACL2 representation
     of the Java boolean value;
     instead, we want @('b') to remain a Java boolean value.
     By assigning to @(tsee boolean-value->bool)
     the argument type @(':jboolean') and the result type @(':asymbol'),
     the conversion of @('b') will be avoided.")
   (xdoc::p
    "Since the @(tsee boolean-value->bool) destructor is inlined,
     we need to specify @('boolean-value->bool$inline')
     to @(tsee def-atj-main-function-type)."))

  (def-atj-main-function-type boolean-value->bool$inline (:jboolean) :asymbol))
