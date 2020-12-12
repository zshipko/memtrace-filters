import sys
import pandas as pd
import matplotlib.pyplot as plt

if len(sys.argv) < 2 or sys.argv[1] == '-':
    lines = sys.stdin.readlines()
else:
    lines = open(sys.argv[1]).readlines()

data = {}
for line in lines:
    keys = [x.replace('\n', '') for x in line.split(' ')]
    for key in keys:
        k = key.split('=')
        if k[0] not in data:
            data[k[0]] = []
        if k[1][-1] == 'G':
            data[k[0]].append(float(k[1][:-1]))
        else:
            data[k[0]].append(float(k[1]))

df = pd.DataFrame(data)
plot = df.plot(x='timestamp', y=["irmin", "index"], kind='line')
plot.set(xlabel='Timestamp', ylabel='Memory (GB)')
if len(sys.argv) < 3 or sys.argv[2] == '-':
    plt.show()
    sys.exit(0)

fig = plot.get_figure()
fig.savefig(sys.argv[2])
