# GapDetection

## Description

This Gap in Noise test has for objective to measure the understanding of a gap in noise.

We did a stimulation with a white noise during 800ms, then we put a random gap in this white noise, the gap duration is also random in the psychometric part but is between 1ms and 60ms.
We start with a rough threshold to determine the array of the gap duration that we will test on the participant to print a psychometric function of the understanding gap in function of the gap duration.
For example, a normal hearing person will heard a gap with a duration of 4 ms, more or less, and a person with hearing disorders will not perform well under 20ms gap duration.

We also measure the reaction time to answer after a trial to see how it is obvious or difficult for someone in functon of the gap duration, like for how long do you need to contrate and take more time to say if they heard a gap or not.

We chose to put 30 as number of trials for the FindThreshold and 100 for the number of trials in the PlotPsychometric.

Every parameters can be easily modified in a GUI so you can change every variables as you wish just depend of what you want to test or highlights by doing gap detection test.

At the begin and at the end of the stimulation we put a ramp with a duration of 20ms and same for the gap we put a ramp at the begin and the end but the duration is 2ms. The importance of putting a ramp is for avoid sudden abrupt change from sound to silence, which may lead to a click effect.

To make sure that the gap will not be at beginning or at the end of the stimulation we created a parameter called "protected area" that allows us to create a safe space between the beginning and the end of stimulation or of a gap presentation this ensures that the correct duration of the gap is heard and that it can be clearly perceived by the participant.

In our case, we use this gap detection test for people who suffers of auditory neuropathy spectrum disorders

## How it works

1- You enter the name of the subject

2- First part : You start with a "rough Threshold" test in adaptative procedure. Default parameters is limited to 30 trials but there are 4 exit conditions (if the gap heard is more then 100ms, if the 30 trials have been done, if the gap equals to 0ms, and when we compare every new minimum and this minimum gap heard has already been heard twice). With the decrease and increase gap we can measure the level of understanding then we plot a curve at the end of the test to see the rough threshold.

3- Second part : After determine the rough threshold you will test the particpant with randomized gaps duration who were find thank to the first part of the test to make it adaptive to the subject hearing. This part is the one with the 100 trials and it s the same method of the first part with the two possibles answers but in this one the gaps are randomized so that don't depend of your previous answer. Each gap duration is repeat randomly 10 times.
At the end you have the pyschometric curve that appears. 

All the data are saved in an excel file and each part of the test had it own file (for example: firt part is "year-month-day_hour-min-sec_name_threshold.csv" and for the second part is "year-month-day_hour-min-sec_name_psycho.csv").


## Visuals

The picture attachs behind is the curve of the firts part, the gap threshold, we see the gap duration in ms in function of the number of the trial. We have at the end this graph that demonstrates the average of the comprehension of the gap in noise.

![Gap_Threshold_OutPut](/uploads/56ef655779b5808158c0925aab0d1cfb/Gap_Threshold_OutPut.png)

This second picture is the output of the second part of the test, we have the psychometric function of the tested person, it is the number of 'yes' replied in percentage in function of the gap duration in ms.

![Gap_Psychometry_OutPut](/uploads/2a18f2e6abfb96820b61791cb6931d73/Gap_Psychometry_OutPut.png)


## Usage

Open Matlab and run guiGap
Developpment has been made under Matlab version R2023a. Other Matlab version are not tested but could be surpported.

## Support

gregory.gerenton@pasteur.fr

## Authors and acknowledgment
Marta Campi

Grégory Gérenton

Eva Thurot

## License
This program is free software.  
You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version