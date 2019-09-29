import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm

plt.close('all') #close any open plots

def plotData(x1,t1,x2=None,t2=None,x3=None,t3=None,legend=[], type=1):
    '''plotData(x1,t1,x2,t2,x3=None,t3=None,legend=[]): Generate a plot of the 
       training data, the true function, and the estimated function'''

    #add title, legend and axes labels

    if (type == 1):
        plt.ylabel('t') #label x and y axes
        plt.xlabel('x')
        p1 = plt.plot(x1, t1, 'bo') #plot training data
        if(x2 is not None):
            p2 = plt.plot(x2, t2, 'g') #plot true value
        if(x3 is not None):
            p3 = plt.plot(x3, t3, 'r') #plot training data

        plt.xlim((-4.5, 4.5))
        plt.ylim((-2, 2))
        
        if(x2 is None):
            plt.legend(zip([p1[0]]),legend)
        if(x3 is None):
            plt.legend(zip([p1[0],p2[0]]),legend)
        else:
            plt.legend(zip([p1[0],p2[0],p3[0]]),legend)
    
    elif (type == 2):
        plt.ylabel('error') #label x and y axes
        plt.xlabel('m')
        p1 = plt.plot(x1, t1, 'g')
        p2 = plt.plot(x2, t2, 'r')
        plt.legend(zip([p1[0],p2[0]]),legend)

    else:
        plt.ylabel('error') #label x and y axes
        plt.xlabel('k')
        p1 = plt.plot(x1, t1, 'g')
        plt.legend(zip([p1[0]]),legend)


x = [50, 100, 200, 500, 1000]

# full, line, rand2D, 3Dtorus, honeycomb and randhoneycomb
yGossip_full = [2515, 2734, 2844, 2953, 3281]

yGossip_line = [5031, 9735, 16078, 41891, 86734]

yGossip_rand2D = [0 ,0, 0, 2844, 3172] #孤立点处理

yGossip_3Dtorus = [2079, 2188, 2406, 2734, 2843]

yGossip_honeycomb = [2078, 2516, 3180, 4922, 6234]

yGossip_randhoneycomb = []



yPushSum_full = [3297, 3468, 3687, 3812, 3969]

yPushSum_line = [220484, ] #会卡住

yPushSum_rand2D = [0, 0, 0, 152453, 160704] #孤立点处理

yPushSum_3Dtorus = [6094, 8782, 11937, 20594, 30906]

yPushSum_honeycomb = [36532, 103203, 149860, 396484, 658765]

yPushSum_randhoneycomb = []

plt.figure()
plotData(x1,t1,x2,t2,x3,t3,legend=['Training Data', 'LS', 'IRLS'],type=1)
