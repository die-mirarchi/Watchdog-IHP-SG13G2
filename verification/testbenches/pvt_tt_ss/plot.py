import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import os
TCOL={-40:'#2a78d6',27:'#1baf7a',85:'#eb6834'}
VLS={1.08:(0,(5,2.5)),1.2:'-',1.32:(0,(1.2,1.6))}
SURF='#fcfcfb'; INK='#0b0b0b'; INK2='#52514e'; GRID='#e4e3df'
plt.rcParams.update({'figure.facecolor':SURF,'axes.facecolor':SURF,'savefig.facecolor':SURF,
 'axes.edgecolor':'#b9b8b2','axes.labelcolor':INK2,'xtick.color':INK2,'ytick.color':INK2,
 'axes.grid':True,'grid.color':GRID,'grid.linewidth':0.6,'axes.spines.top':False,'axes.spines.right':False,
 'font.size':9.5,'axes.titlesize':10.5,'axes.titleweight':'bold','axes.titlecolor':INK,'legend.frameon':False,
 'lines.linewidth':1.6})
def style(t,v): return dict(color=TCOL[t],linestyle=VLS[v],linewidth=1.6)
def legend(ax_or_fig,loc='best',fig=False,ncol=1,**kw):
    h=[Line2D([],[],color=TCOL[t],lw=2,label=f'{t} °C') for t in (-40,27,85)]
    h+=[Line2D([],[],color=INK2,lw=1.6,linestyle=VLS[v],label=f'{v:.2f} V') for v in (1.08,1.2,1.32)]
    if fig: return ax_or_fig.legend(handles=h,loc=loc,ncol=ncol,fontsize=8.5,**kw)
    return ax_or_fig.legend(handles=h,loc=loc,ncol=ncol,fontsize=8.5,**kw)
def save(fig,path):
    os.makedirs(os.path.dirname(path),exist_ok=True)
    fig.savefig(path,dpi=160,bbox_inches='tight'); plt.close(fig)
def subtitle(fig,txt):
    fig.text(0.01,-0.02,txt,ha='left',va='top',fontsize=8.3,color=INK2,transform=fig.transFigure)
