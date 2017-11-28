import py_compile
import sys
import csv
import os.path as _p
import pathlib

if len(sys.argv) == 2:
    # directory mode
    dir = sys.argv[1]
    with open(_p.join(dir, '.py_compile')) as fin, open(_p.join(dir,'.py_compile.done'), 'w') as fout:
        wrt = csv.writer(fout, doublequote=False, escapechar='\\')
        for in_path, out_path in csv.reader(fin, doublequote=False, escapechar='\\'):
            dout_path = _p.join(dir, out_path)
            subdir = _p.dirname(dout_path)
            pathlib.Path(subdir).mkdir(parents=True, exist_ok=True)
            py_compile.compile(in_path, dout_path)
            wrt.writerow((out_path,))
elif len(sys.argv) == 3:
    # file compile mode
    dir = _p.dirname(sys.argv[2])
    pathlib.Path(dir).mkdir(parents=True, exist_ok=True)
    py_compile.compile(sys.argv[1], sys.argv[2])