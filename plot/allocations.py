import sys
import pandas as pd
import matplotlib.pyplot as plt
import datetime

from util import args, lines

args = args("Plot allocations")

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
y = ["total"]
plot = df.plot(title=args.title.expandtabs(), x='timestamp', y=y, kind='line')
plot.set(xlabel='Timestamp', ylabel='Memory (GB)')

if args.output == '-':
    plt.show()
    sys.exit(0)

fig = plot.get_figure()
fig.savefig(args.output)
