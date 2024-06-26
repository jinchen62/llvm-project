//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// ADDITIONAL_COMPILE_FLAGS: -D_LIBCPP_DISABLE_DEPRECATION_WARNINGS -D_LIBCPP_ENABLE_CXX26_REMOVED_STRSTREAM

// <strstream>

// class istrstream

// explicit istrstream(char* s);

#include <strstream>
#include <cassert>
#include <string>

#include "test_macros.h"

int main(int, char**)
{
    {
        char buf[] = "123 4.5 dog";
        std::istrstream in(buf);
        int i;
        in >> i;
        assert(i == 123);
        double d;
        in >> d;
        assert(d == 4.5);
        std::string s;
        in >> s;
        assert(s == "dog");
        assert(in.eof());
        assert(!in.fail());
        in.clear();
        in.putback('g');
        assert(!in.fail());
        in.putback('g');
        assert(!in.fail());
        assert(buf[9] == 'g');
        assert(buf[10] == 'g');
    }

  return 0;
}
