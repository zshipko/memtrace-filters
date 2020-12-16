import sys
import pandas as pd
import matplotlib.pyplot as plt

from util import args, lines

def init(parser):
    parser.add_argument('--total', default=False, type=bool, help='plot total memory allocations also')

args = args("Plot comparison between irmin and index allocations", init=init)

data = {}
for line in lines(args.input):
    keys = line.split(' ')
    for key in keys:
        k = key.split('=')
        if k[0] not in data:
            data[k[0]] = []
        if k[1][-1] == 'G':
            data[k[0]].append(float(k[1][:-1]))
        else:
            data[k[0]].append(float(k[1]))

df = pd.DataFrame(data)
y = ["irmin", "index"]
if args.total:
    y.append("total")
plot = df.plot(x='timestamp', y=y, kind='line')
plot.set(xlabel='Timestamp', ylabel='Memory (GB)')

if args.logs is not None:
    ymin, ymax = plot.get_ylim()
    xmin, xmax = plot.get_xlim()
    for line in lines(args.logs):
        if 'Freeze begin' in line:
            s = line.split(' ')
            t = float(s[-1])
            plot.axvline(x=t, color='m', label="freeze")


if args.output == '-':
    plt.show()
    sys.exit(0)

fig = plot.get_figure()
fig.savefig(args.output)
