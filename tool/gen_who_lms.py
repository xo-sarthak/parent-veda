"""Regenerate lib/screens/post_pregnancy/pp_who_growth_lms.dart's tables.

Source: the WHO's own anthro repository, daily LMS values.
  curl -O https://raw.githubusercontent.com/WorldHealthOrganization/anthro/master/data-raw/growthstandards/{weianthro,lenanthro,hcanthro}.txt
Run from the directory holding the three files; prints the six Dart lists
(month m = day floor(m * 30.4375 + 0.5)) to paste over the generated block.
"""
import math

for f, name in [('weianthro.txt', 'Weight'), ('lenanthro.txt', 'Length'), ('hcanthro.txt', 'Head')]:
    rows = {}
    for line in open(f).read().strip().split('\n')[1:]:
        p = line.split('\t')
        rows[(int(p[0]), int(p[1]))] = (float(p[2]), float(p[3]), float(p[4]))
    for sex, sx in [(1, 'Boys'), (2, 'Girls')]:
        print(f'const List<WhoLms> kWho{name}{sx} = [')
        for m in range(61):
            l, mm, s = rows[(sex, math.floor(m * 30.4375 + 0.5))]
            print(f'  ({l}, {mm}, {s}), // {m}')
        print('];\n')
