import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm

plt.close('all') #close any open plots

def plotData(x1,t1,t2=None,t3=None,t4=None,t5=None,t6=None,legend=[], algorithm='gossip'):

    #add title, legend and axes labels

    plt.ylabel(algorithm + ' convergence time') #label x and y axes
    plt.xlabel('numNodes')

    
    p1 = plt.plot(x1, t1, 'g')
    if(t2 is not None):
        p2 = plt.plot(x1, t2, 'b')
    if(t3 is not None):
        p3 = plt.plot(x1, t3, 'r')
    if(t4 is not None):
        p4 = plt.plot(x1, t4, 'y')
    if(t5 is not None):
        p5 = plt.plot(x1, t5, 'k')
    if(t6 is not None):
        p6 = plt.plot(x1, t6, 'm')
    plt.xlim((0, 1000))
    # plt.ylim((-2, 2))
    if(t2 is None):
        plt.legend(zip([p1[0]]),legend)
    elif(t3 is None):
        plt.legend(zip([p1[0],p2[0]]),legend)
    elif(t4 is None):
        plt.legend(zip([p1[0],p2[0],p3[0]]),legend)
    elif(t5 is None):
        plt.legend(zip([p1[0],p2[0],p3[0],p4[0]]),legend)
    elif(t6 is None):
        plt.legend(zip([p1[0],p2[0],p3[0],p4[0],p5[0]]),legend)
    else:
        plt.legend(zip([p1[0],p2[0],p3[0],p4[0],p5[0],p6[0]]),legend)
    


x = [50, 100, 200, 500, 1000]
xGossip_rand2D = [500, 1000]
# full, line, rand2D, 3Dtorus, honeycomb and randhoneycomb
yGossip_full = [2515, 2734, 2844, 2953, 3281]

yGossip_line = [5031, 9735, 16078, 41891, 86734]

# yGossip_rand2D = [0 ,0, 0, 2844, 3172] #孤立点处理
yGossip_rand2D = [2844, 3172] #孤立点处理

yGossip_3Dtorus = [2079, 2188, 2406, 2734, 2843]

yGossip_honeycomb = [2078, 2516, 3180, 4922, 6234]

yGossip_randhoneycomb = []



yPushSum_full = [1484, 1656, 1703, 2141, 2250]

yPushSum_line = [15266, 43156, 146266, 0, 0] #时间太长

yPushSum_rand2D = [0, 0, 0, 69140, 53953] #孤立点

yPushSum_3Dtorus = [2797, 3937, 5141, 8578, 12703]

yPushSum_honeycomb = [15828, 40063, 56766, 152032, 256953]

yPushSum_randhoneycomb = []


plt.figure()
# plotData(x,yGossip_full,yGossip_line,yGossip_rand2D,yGossip_3Dtorus,yGossip_honeycomb, yGossip_randhoneycomb, legend=['full', 'line', 'rand2D', '3Dtorus', 'honeycomb', 'randhoneycomb'])
plotData(x,yGossip_full,legend=['full'], algorithm='gossip')
plt.figure()
plotData(x,yGossip_line,legend=['line'], algorithm='gossip')
plt.figure()
plotData(xGossip_rand2D,yGossip_rand2D,legend=['rand2D'], algorithm='gossip')
plt.figure()
plotData(x,yGossip_3Dtorus,legend=['3Dtorus'], algorithm='gossip')
plt.figure()
plotData(x,yGossip_honeycomb,legend=['honeycomb'], algorithm='gossip')


plt.show()


