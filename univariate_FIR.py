import layer_analysis as analysis
import glob
import sys
import os

session= sys.argv[1]

cwd = os.getcwd()
parent = os.path.abspath(os.path.join(cwd, os.pardir))   


session_dir=os.path.join(parent,'data',session)
print(session_dir)

func_dir = os.path.join(session_dir,'func')

force = True
trial_duration=32
    
load_o='01'
load_t='02'
motor_o='01'
motor_t='02'

###Load
body_load = 'load_run'
end_load = '_mc.nii'


in_files = [glob.glob(os.path.join(func_dir,'*_'+body_load+'-'+load_o+end_load))[0],glob.glob(os.path.join(func_dir,'*_'+body_load+'-'+load_t+end_load))[0]]

print(in_files)

condition_stim_file_1 = os.path.join(session_dir,'beh/derivates/event_file_AFNI_loadHigh.txt')
condition_stim_file_2 = os.path.join(session_dir,'beh/derivates/event_file_AFNI_loadLow.txt')

stim_label_1 = 'High'
stim_label_2 = 'Low'

runtype = 'Load_long_TENTzero'

trialavg_bold_load, baseline_file_bold_load, fstat_file_bold_load = analysis.bold_load_average_trials_3ddeconvolve(in_files,condition_stim_file_1,condition_stim_file_2,stim_label_1,stim_label_2, trial_duration,runtype,force=False)

trialavg_bold_prcchg_load = analysis.calc_percent_change_trialavg(trialavg_bold_load,
                                                            baseline_file_bold_load,
                                                            inv_change=False,force=True)

del in_files, condition_stim_file_1, condition_stim_file_2, stim_label_1, stim_label_2, runtype

### Motor
body_motor = 'motor_run'
in_files = [glob.glob(os.path.join(func_dir,'*_'+body_motor+'-'+motor_o+end_load))[0],glob.glob(os.path.join(func_dir,'*_'+body_motor+'-'+motor_t+end_load))[0]]

                                
condition_stim_file_1 = os.path.join(session_dir,'beh/derivates/event_file_AFNI_motorGo.txt')
condition_stim_file_2 = os.path.join(session_dir,'beh/derivates/event_file_AFNI_motorNoGo.txt')

stim_label_1 = 'Press'
stim_label_2 = 'NoPress'

runtype = 'Motor_long_TENTzero'

trialavg_bold_motor, baseline_file_bold_motor, fstat_file_bold_motor = analysis.bold_load_average_trials_3ddeconvolve(in_files,condition_stim_file_1,condition_stim_file_2,stim_label_1,stim_label_2, trial_duration,runtype,force=False)

trialavg_bold_prcchg_motor = analysis.calc_percent_change_trialavg(trialavg_bold_motor,
                                                   baseline_file_bold_motor,
                                                   inv_change=False,force=True)
