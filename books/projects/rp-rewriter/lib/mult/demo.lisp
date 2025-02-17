
; MULTIPLIER RULES

; Note: The license below is based on the template at:
; http://opensource.org/licenses/BSD-3-Clause

; Copyright (C) 2019, Regents of the University of Texas
; All rights reserved.

; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are
; met:

; o Redistributions of source code must retain the above copyright
;   notice, this list of conditions and the following disclaimer.

; o Redistributions in binary form must reproduce the above copyright
;   notice, this list of conditions and the following disclaimer in the
;   documentation and/or other materials provided with the distribution.

; o Neither the name of the copyright holders nor the names of its
;   contributors may be used to endorse or promote products derived
;   from this software without specific prior written permission.

; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
; HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

; Original Author(s):
; Mertcan Temel         <mert@utexas.edu>

;; Definitions for binary functions to be used by multiplier rules

(in-package "RP")


;; To load the verilog designs:
(include-book "centaur/sv/top" :dir :system)
(include-book "centaur/vl/loader/top" :dir :system)
(include-book "oslib/ls" :dir :system)
(include-book "centaur/svl/top" :dir :system)

;; for correctness proof
(include-book "projects/rp-rewriter/lib/mult/svl-top" :dir :system)

;; load VL design
(acl2::defconsts
 (*vl-design* state)
 (b* (((mv loadresult state)
       (vl::vl-load (vl::make-vl-loadconfig
                     :start-files '("DT_SB4_HC_64_64_multgen.sv")))))
   (mv (vl::vl-loadresult->design loadresult) state)))

;; Load SV design
(acl2::defconsts
 (*sv-design*
  *simplified-good*
  *simplified-bad*)
 (b* (((mv errmsg sv-design good bad)
       (vl::vl-design->sv-design "DT_SB4_HC_64_64"
                                 *vl-design* (vl::make-vl-simpconfig))))
   (and errmsg
        (acl2::raise "~@0~%" errmsg))
   (mv sv-design good bad)))

;; Load SVL design
(acl2::defconsts (*svl-design* rp::rp-state)
 (svl::svl-flatten-design *sv-design*
                          *vl-design*
                          :dont-flatten :all))
 

;; Spec function for Full/half adder modules
(progn
  (define list-m2-f2 ((sum integerp))
    (list  (m2 sum)
           (f2 sum))
    ///
    (def-rp-rule list-m2-f2-def
      (implies (quarternaryp sum)
               (equal (list-m2-f2 sum)
                      (list (m2-new sum)
                            (f2-new sum))))
      :hints (("Goal"
               :in-theory (e/d (f2-new
                                m2-new) ()))))
    ;; RP side condition, returned values are bitp
    (defthmd list-m2-f2-def-side-cond
      (implies (quarternaryp sum)
               (and (bitp (m2-new sum))
                    (bitp (f2-new sum)))))
    (rp::rp-attach-sc list-m2-f2-def
                      list-m2-f2-def-side-cond)))

(make-event
 `(progn
    ;; This creates a rewrite rule that throws an error if the below rw rules fail
    (def-rw-opener-error
      svl-run-phase-of-FullAdder_opener-error
      (svl::svl-run-phase-wog "fa"
                              ins
                              delayed-env
                              svl-design)
      :vars-to-avoid (svl-design delayed-env))

    ;; value lemma
    (def-rp-rule svl-run-phase-of-FullAdder-tem
      (implies (and (bitp x)
                    (bitp y)
                    (bitp z)
                    (force (equal (assoc-equal "fa" svl-design)
                                  ',(assoc-equal "fa" *svl-design*))))
               (equal (svl::svl-run-phase-wog "fa"
                                              (list x y z)
                                              '(nil nil)
                                              svl-design)
                      (mv (list-m2-f2 (merge-sum x y z))
                          '(nil nil))))
      :hints (("Goal"
               :do-not-induct t
               :expand ((:free (module-name delayed-env inputs svl-modules)
                               (svl::svl-run-phase-wog module-name inputs delayed-env svl-modules)))
               :in-theory (e/d ((:e rp::pp)
                                bitp
                                svl::SVL-WELL-RANKED-MODULE$
                                svl::SVL-GET-MODULE-RANK$
                                svl::SVL-GET-MAX-OCC-RANK$)
                               ()))))

    ;; returned sum is quarternaryp
    (defthmd svl-run-phase-of-FullAdder-tem-side-cond
      (implies (and (bitp x)
                    (bitp y)
                    (bitp z))
               (and (quarternaryp (merge-sum x y z))))
      :hints (("Goal"
               :in-theory '(bitp eq eql (:e m2)
                                 (:e rp::m2-f2-[0-3]) (:e quarternaryp)
                                 (:e f2) (:e merge-b+)))))

    (rp-attach-sc svl-run-phase-of-FullAdder-tem
                  svl-run-phase-of-FullAdder-tem-side-cond)))

(make-event
 `(progn
    ;; This creates a rewrite rule that throws an error if the below rw rules fail
    (def-rw-opener-error
      svl-run-phase-of-HalfAdder_opener-error
      (svl::svl-run-phase-wog "ha"
                              ins
                              delayed-env
                              svl-design)
      :vars-to-avoid (svl-design delayed-env))

    ;; value lemma
    (def-rp-rule svl-run-phase-of-HalfAdder-tem
      (implies (and (bitp x)
                    (bitp y)
                    (force (equal (assoc-equal "ha" svl-design)
                                  ',(assoc-equal "ha" *svl-design*))))
               (equal (svl::svl-run-phase-wog "ha"
                                              (list x y)
                                              '(nil nil)
                                              svl-design)
                      (mv (list-m2-f2 (merge-sum x y))
                          '(nil nil))))
      :hints (("Goal"
               :do-not-induct t
               :expand ((:free (module-name delayed-env inputs svl-modules)
                               (svl::svl-run-phase-wog module-name inputs delayed-env svl-modules)))
               :in-theory (e/d ((:e rp::pp)
                                bitp
                                svl::SVL-WELL-RANKED-MODULE$
                                svl::SVL-GET-MODULE-RANK$
                                svl::SVL-GET-MAX-OCC-RANK$)
                               ()))))

    (defthmd svl-run-phase-of-HalfAdder-tem-side-cond
      (implies (and (bitp x)
                    (bitp y))
               (and (quarternaryp (merge-sum x y))))
      :hints (("Goal"
               :in-theory '(bitp eq eql (:e m2)
                                 (:e rp::m2-f2-[0-3]) (:e quarternaryp)
                                 (:e f2) (:e merge-b+)))))

    (rp-attach-sc svl-run-phase-of-HalfAdder-tem
                  svl-run-phase-of-HalfAdder-tem-side-cond)))

;; Lemma for final stage adder.
(defthmrp final-stage-adder-correct
  (implies (and (integerp in1)
                (integerp in2))
           (equal (svl::svl-run-phase-wog "HC_128"
                                          (list in1 in2)
                                          '(nil nil)
                                          *svl-design*)
                  (list (list (rp::4vec-adder (svl::bits in1 0 128)
                                              (svl::bits in2 0 128 )
                                              0 129))
                        (svl::make-svl-env))))
  :disable-meta-rules (resolve-pp-sum-order-main)
  :enable-rules rp::*adder-rules*
  :disable-rules rp::*pp-rules*)


(progn
  (defconst *input-bindings*
    '(("IN1" a)
      ("IN2" b)))

  (defconst *out-bindings*
    '(("result" out)))

  ;; A way to state correctness proof for the multiplier.
  ;; Similar to SVTV-run
  (defthmrp multiplier-correct-v1
    (implies (and (integerp in1)
                  (integerp in2))
             (equal (svl::svl-run "DT_SB4_HC_64_64"
                                  (make-fast-alist `((a . ,in1)
                                                     (b . ,in2)))
                                  *input-bindings*
                                  *out-bindings*
                                  *svl-design*)
                    `((out . ,(loghead 128 (* (sign-ext in1 64)
                                              (sign-ext in2 64)))))))))


;; Another Way to state the final correctness theorem.  Less user-friendly but
;; if you want to use this proof hierarchically, this is better.
(defthmrp multiplier-correct-v2
  (implies (and (integerp in1)
                (integerp in2))
           (equal (svl::svl-run-phase-wog "DT_SB4_HC_64_64"
                                          (list in1 in2)
                                          '(nil nil)
                                          *svl-design*)
                  (list  (list (loghead 128 (* (sign-ext in1 64)
                                               (sign-ext in2 64))))
                         (svl::make-svl-env)))))

