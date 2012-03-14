hasqap
======

This project is a loose vala-implementation of the HAS-QAP algorithm as presented in the following paper:

ftp://ftp.idsia.ch/pub/luca/papers/tr-idsia-4-97.pdf

It's intended use was to optimize keyboard layouts as this is a problem which can (more or less) been formulated as a quadratic assignment problem..


License
-------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


Building
--------

This project is build with [tup](http://gittup.org/tup/). Install all necessary vala-packages and development-files (valac, libgee, …).

If you have checked out for the first time run:

`tup init`

To build the project simply run:

`tup upd`


Usage
-----

Either use the library from your application or use the executable generated in the build process like this:

`./solver 100 < problem.dat`

where "100" is the number of iterations to perform and "problem.dat" is a [qaplib-formatted problem](http://www.opt.math.tu-graz.ac.at/qaplib/inst.html).

It should generate output similar to the following (run performed on the nug30-problem):

`
 16  23  12  24  27   4   0  11   5   6  20   1  25   9   8   7  18  28  17  21  22  15   2  19  14  26  10  29   3  13  (6272)
 23  11   5  12  24  27   0  21   7   6  18  20  25  17   9   8  28  19  16  22  10   2  29  13  14   4  26  15   1   3  (6232)
 23  11   5  12  24  27   0  21   7   6  18  20  25  17   9   8   2  19  16  22  10  15  29  13  14   4  26   1  28   3  (6206)
 23  11   5  12   1   4  25   0   6   9   8  20  22  17  21  26   2  19  16   7  18  29  28  13  14  24  10  15   3  27  (6202)
  4  27  24   5  11  23   1  20  12   8   9  25  28   2  18   6  21   0  19  29  15   7  17  16  13   3  26  10  22  14  (6166)
 11   5  24  12  27   4  23  25   9   8  20   1   0  21   6  18   2  28  16  17  10  29  15   3  14  22   7  26  19  13  (6160)
`

The output consists of the best permutations found so far and their cost. Note that these permutations are zero-indexed (in opposition to the solutions in qaplib).



`


