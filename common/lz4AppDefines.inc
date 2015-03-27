(*
  LZ4DElphi
  Copyright (C) 2015, Jose Pascoa (atelierwebgm@gmail.com)
  BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

  *************************************************************************
  LZ4 - Fast LZ compression algorithm
  xxHash - Fast Hash algorithm
  LZ4 source repository : http://code.google.com/p/lz4/
  xxHash source repository : http://code.google.com/p/xxhash/
  Copyright (c) 2011-2014, Yann Collet
  BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

  LZ4StreamingTest
  A modification of on lz4-delphi - Delphi - bindings for [lz4]
  Project repository: https://github.com/Hugie/lz4-delphi
  Copyright (c) 2014, Hanno Hugenberg
  BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)


  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above
  copyright notice, this list of conditions and the following disclaimer
  in the documentation and/or other materials provided with the
  distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 ******************************************************************************
*)


(*
{***************WILDCOPY_ASM**********************************}
Experimental in the pure Delphi variation (i.e, when USE_EXTERNAL_OBJ_LIBS are not defined).
But does not appear to improve (because asm can not be inlined ?!);
*)
{.$DEFINE WILDCOPY_ASM}

(*
{****************USE_EXTERNAL_OBJ_LIBS***********************}
$Define to use compiled VS 2012 .obj files, otherwise use pure Delphi.
Some functions of the LZ4Externals unit, like __chkstk and __allmul,
have only been tested to work with VS 2012
*)
{$DEFINE USE_EXTERNAL_OBJ_LIBS}
{$IFDEF USE_EXTERNAL_OBJ_LIBS}
{$DEFINE VS_LIB}   // VS 2012
{$ENDIF}
