# Memtrace filters

Requires:
- Python
  * Pandas
  * Matplotlib
- OCaml
  * Memtrace

## irmin_index_memory.ml

Compares allocations from `Index` and `Irmin`

### Usage

Running `irmin-pack` benchmark with memtrace (in the irmin repo):

```shell
$ MEMTRACE=trace.ctf dune exec bench/irmin-pack/layers.exe
```

Now in the `memtrace-filters` repo:

Save image and data file:
```shell
$ dune exec ./filters/irmin_index_memory.exe ../irmin/trace.ctf > data
$ python3 plot/irmin_index.py -i data -o output.png
```

Save image to file (using pipe):
```shell
$ dune exec ./filters/irmin_index_memory.exe ../irmin/trace.ctf | python3 plot/irmin_index.py -o output.png
```

Display in window:
```shell
$ dune exec ./filters/irmin_index_memory.exe ../irmin/trace.ctf | python3 plot/irmin_index.py
```

