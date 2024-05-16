import subprocess
import os
from nipype.interfaces.afni import Deconvolve, TCatSubBrick, Calc, TStat
import nibabel as nib
import numpy as np


def bold_load_average_trials_3ddeconvolve(in_files,condition_stim_file_1,condition_stim_file_2,stim_label_1,stim_label_2,trial_duration,out_files_basename,polort=5,onset_shift=0,cwd=None,force=None):
    if cwd==None:
        cwd=os.path.dirname(os.path.normpath(in_files[0]))
    n_files = len(in_files)
    # returns estimated impules response components and baseline
    # set parameters
    tr = nib.load(in_files[0]).header.get_zooms()[3]
    
    n = 17
    a = 0
    b = 32
    # prepare stim times and model
    condition_stim_files = [condition_stim_file_1, condition_stim_file_2]   
    n_conditions = len(condition_stim_files)

    stim_label=[(1,stim_label_1), (2,stim_label_2)]

    trialavg_files=[]
    for i in range(n_conditions):
        condition = stim_label[i][1]
        trialavg_files.append(os.path.join(cwd,out_files_basename + f"_response_condition_{condition}.nii"))
    baseline_file = os.path.join(cwd,out_files_basename + '_baseline.nii')
    fstat_file = os.path.join(cwd,out_files_basename + '_fstat.nii')

    stim_times=[]
    i_condition = 0
    for stim_file in condition_stim_files:
        i_condition = i_condition + 1
        stim_times.append((i_condition,stim_file,f'TENTzero({a},{b},{n})'))

    deconvolve = Deconvolve()
    deconvolve.inputs.in_files = in_files
    deconvolve.inputs.stim_times = stim_times
    deconvolve.inputs.stim_label = stim_label
    deconvolve.inputs.polort = polort
    deconvolve.inputs.local_times = True
    deconvolve.inputs.fout = True
    deconvolve.inputs.cbucket = os.path.join(cwd,out_files_basename + '_cbucket.nii.gz')
    deconvolve.inputs.args ='-overwrite'
    deconvolve.inputs.stim_times_subtract = onset_shift
    result = deconvolve.run(cwd=cwd)
    # extract fstat
    result_fstat = TCatSubBrick(in_files=[(result.outputs.out_file,f"'[0]'")],
                                out_file = os.path.join(cwd,out_files_basename + '_fstat.nii'),
                                args='-overwrite').run()    
    # add back baseline  
    baseline_idcs = 0+(polort+1)*np.arange(n_files)
    baseline_idcs_str = ','.join([str(i) for i in baseline_idcs])
    result_baseline_vols = TCatSubBrick(in_files=[(result.outputs.cbucket,
                                              f"'[{baseline_idcs_str}]'")],
                                        out_file=os.path.join(cwd,out_files_basename + '_baseline_runs.nii'),
                                        args='-overwrite').run()
    result_baseline = TStat(in_file=os.path.join(cwd,out_files_basename + '_baseline_runs.nii'),
                            args='-mean -overwrite',
                            out_file=os.path.join(cwd,out_files_basename + '_baseline.nii')).run()
    for i in range(n_conditions):
        condition = stim_label[i][1]
        result_condition_diffresponse_timecourse = TCatSubBrick(
            in_files=[(result.outputs.cbucket,
                       f"'[{int((polort+1)*n_files+i*n-(2*i))}..{int((polort+1)*n_files+(i+1)*n-1-(2*(i+1)))}]'")],
            
            out_file=os.path.join(cwd,out_files_basename + f"_diffresponse_condition_{condition}.nii"),
            args='-overwrite').run()
        result_condition_response_timecourse = Calc(
            in_file_a=os.path.join(cwd,out_files_basename + f"_diffresponse_condition_{condition}.nii"),
            in_file_b=os.path.join(cwd,out_files_basename + '_baseline.nii'),
            out_file=os.path.join(cwd,out_files_basename + f"_response_condition_{condition}.nii"),
            expr='a+b',
            args='-overwrite').run()
        
    baseline_file = os.path.join(cwd,out_files_basename + '_baseline.nii')
    fstat_file = os.path.join(cwd,out_files_basename + '_fstat.nii')

    return trialavg_files, baseline_file, fstat_file


def calc_percent_change_trialavg(trialavg_files,baseline_file,inv_change=False,force=False):    
    if inv_change:
        expr='100-(100*a/b)'
    else:
        expr='100*a/b-100'
    prc_change = []
    for trialavg_file in trialavg_files:
        trialavg_file_split = os.path.splitext(trialavg_file)
        out_file = trialavg_file_split[0] + '_prcchg'+trialavg_file_split[1]
        if not os.path.isfile(out_file) or force==True:
            result_prcchg = Calc(
                in_file_a=trialavg_file,
                in_file_b=baseline_file,
                out_file=out_file,
                expr=expr,
                args='-overwrite').run()            
            prc_change.append(result_prcchg.outputs.out_file)
        else:
            prc_change.append(out_file)
    return prc_change


