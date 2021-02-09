'''
Custom grains for rnode
'''
import os.path
import subprocess as sub
import logging 
log = logging.getLogger(__name__) 


def __virtual__():
    '''
    Only if installed rnode
    '''
    if os.path.exists('/ton-node/tools/tonos-cli'):
        return True
    return False

def _cmd(c):
    ps = sub.Popen(
       c,
       shell=True,
       stdout=sub.PIPE,
      )
    stdout = ps.communicate()[0].rstrip('\n')
    return stdout
      
def cli_commit_id():
    return _cmd("/ton-node/tools/tonos-cli --version|sed -En '/^COMMIT_ID/{s/^COMMIT_ID:\s//;p}'")   


def rnode():
    '''
    Justatest
    '''
    #new_dict = {k: v for k, v in zip(keys, values)}
    res={}
    res['cli_commit']=cli_commit_id()
#    return {
#        'rnode_curver': running_ver()
#    }
    return res
