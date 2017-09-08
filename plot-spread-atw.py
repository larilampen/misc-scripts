# This script creates a plot of a share price in USD
# and another plot of the same share price expressed
# as proportion of another share's price, such as
# that of the acquirer in a merger (in other words,
# a plot of deal spread) based on csv files such as
# those downloadable from Yahoo finance.

# This specific example applies to the shares of Atwood
# Oceanics Inc. and Ensco Plc. This script can be used
# to recreate the charts included in my article at
# https://seekingalpha.com/article/4088555-profit-enscos-overpriced-acquisition-atwood

# You need to download the price history files from
# Yahoo and save them in the current directory before
# running the script.

# Note that this script is inefficient. For example,
# it reads the entire input into memory.

# You must have matplotlib to use this script.

# Lari Lampen / 2017

import numpy as np
import matplotlib.pyplot as plt

atw = []
atwe = []
with open("ATW.csv") as f1, open("ESV.csv") as f2:
    inputs = zip(f1, f2)
    del inputs[:1]
    for x, y in inputs:
        price1 = float(x.rstrip().split(',')[4])
        price2 = float(y.rstrip().split(',')[4])
        atw.append(price1)
        atwe.append(price1/price2)

plt.figure(figsize=(12,6))
plt.plot(atw)
plt.xticks([117, 369, 621, 873, 1125], ['2013-01-02', '2014-01-02', '2015-01-02', '2016-01-04', '2017-01-03'])
plt.ylabel('USD per ATW share')
plt.title('5-year chart for ATW in USD')
plt.xlim(0, len(atw)-1)
plt.show()

plt.figure(figsize=(12,6))
plt.plot(atwe)
plt.title('5-year chart for ATW, priced in ESV shares')
plt.ylabel('ESV shares per ATW share')
plt.xticks([117, 369, 621, 873, 1125], ['2013-01-02', '2014-01-02', '2015-01-02', '2016-01-04', '2017-01-03'])
plt.xlim(0, len(atwe)-1)
plt.axhline(y=1.6, xmin=0, xmax=1, hold=None, c='r')
plt.show()
