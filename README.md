# Memtrace filters

## irmin_index_memory.ml

Compares allocations from `Index` and `Irmin`

### Usage

Save output to file:
```shell
$ dune exec ./filters/irmin_index_memory.exe ../irmin/trace.ctf > data
$ python3 plot/irmin_index.py data output.png
```

Save output to file (using pipe):
```shell
$ dune exec ./filters/irmin_index_memory.exe ../irmin/trace.ctf | python3 plot/irmin_index.py - output.png
```

Display in window:
```shell
$ dune exec ./filters/irmin_index_memory.exe ../irmin/trace.ctf | python3 plot/irmin_index.py
```
