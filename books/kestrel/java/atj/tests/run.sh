#!/bin/bash

################################################################################

# Java Library
#
# Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
#
# License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
#
# Author: Alessandro Coglio (coglio@kestrel.edu)

################################################################################

# This file runs the tests for the Java code generated by ATJ,
# collecting and printing time measurements for some of them.

# The -Xss1G option to the JVM sets the stack size to 1GB.
# This is generally needed to avoid a stack overflow,
# because AIJ's recursive evaluation uses much more stack space
# than typical Java programs.

# This file assumes that OpenJDK Java 12 is in the path,
# but it may well work with other Java versions or implementations.

################################################################################

# stop on error:
set -e

# test the factorial function:
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G FactorialDeepUnguardedTests 1
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G FactorialDeepGuardedTests 1
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G FactorialShallowUnguardedTests 1
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G FactorialShallowGuardedTests 1

# test the Fibonacci function:
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G FibonacciDeepUnguardedTests 1
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G FibonacciDeepGuardedTests 1
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G FibonacciShallowUnguardedTests 1
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G FibonacciShallowGuardedTests 1

# test the ABNF parser:
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G ABNFDeepUnguardedTests 1
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G ABNFDeepGuardedTests 1
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G ABNFShallowUnguardedTests 1
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G ABNFShallowGuardedTests 1

# test AIJ's native implementations of ACL2 functions
# (without timings because they are very fast, all print as 0.000):
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G NativesDeepUnguardedTests
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G NativesDeepGuardedTests
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G NativesShallowUnguardedTests
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G NativesShallowGuardedTests

# test the Java code that manipulates Java primitive values
# (without timings because they are very fast, all print as 0.000):
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G PrimitivesShallowGuardedTests

# test the Java code that manipulates Java primitive arrays
# (without timings because they are very fast, all print as 0.000):
java -cp ../../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G PrimarraysShallowGuardedTests

# printed only if all the tests succeed:
echo "" # blank line
echo "All the ATJ tests have succeeded."
echo "" # blank line
