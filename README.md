PIVlab_batch v. 1.0.1.

This software was developed to automatically process long series of images of the particle-seeded convection. The idea behind it was to observe the evolution of processes. The program allows to easily obtain the time dependence of such integral characteristics as the maximum and volume-average velocity and streamfunction. The full data on velocity fields is exported in CSV files.

The version 1.0.1 works with PIVlab 2.02.

PIVlab_batch was used in the experimental research published in Experiments in Fluids [Mosheva E., Kozlov N. Study of chemoconvection by PIV at neutralization reaction under normal and modulated gravity // Experiments in Fluids. 2021. Vol. 62. Article 10. – DOI: 10.1007/s00348-020-03097-0].

Prerequisites:
- MATLAB,
- Image Processing Toolbox,
- PIVlab v. 2.02.

Installation:
Unpack PIVlab_batch in any folder you have access to.

To quickly start using PIVlab_batch follow these steps:
1) locate your particle images and prepare the pairs of images;
2) copy the config file "PIVlab_conf*" there and configure it appropriately (you may need to run PIVlab to get the values for some settings);
3) launch the program "PIVlab_batch" and follow the instructions of the wizard.

#_Procedure in detail_#

_Image pairs

The program expects to find in a user-specified folder the pairs of images organized in a sequence of the type "image_1a, image_1b, image_2a, image_2b, ...".
The following file types are supported: *.bmp, *.tif, *.jpg, *.tiff, *.jpeg.


_Config file
The file "PIVlab_conf*" is a matlab script that, when called from the main program, is executed in the same namespace.
It contains the following parameters:

Main batch parameters
1) f_f -- the framerate of video recording = 1/{time elapsed} between image_1a and image_2a (fps);
2) dt1 -- the time step within a pair = time elapsed between image_1a and image_1b (seconds);
3) dt2 -- the quasi-steady time interval = time elapsed between image_1a and image_Na during which the flow structure and velocity may be considered constant (seconds);
4) N2 -- the appropriate number of frames;
5) scalefact -- the scale factor for length (mm/pix);
6) scaleuv -- the scale factor for velocity (mm/(pix*s));
7) dt4 -- the time interval for averaging: to calculate the running average (seconds);
8) N4 -- the appropriate number of frames;
9) border -- coordinates of the border used to render the velocity fields in the format [x x+width y y+height]: if unsure, adjust it to ROI or image limits;
10) roi_init -- the region of interest of the first pair; this parameter is used to set "s{5,2}" from section "Standard PIV Settings" by W. Thielicke;
11) dynamicroi -- if dynamicroi==true the program will execute a special section at the end of file and try to execute the subprogram "adjustroi", which should be copied under name "adjustroi.m" to the same directorty as the config file "PIVlab_conf*.m";
12) intens_min -- the minimun threshold intensity: sets "p{9,2}" from "Standard image preprocessing settings" by W. Thielicke;
13) intens_max -- the maximum threshold intensity: sets "p{10,2}" from "Standard image preprocessing settings" by W. Thielicke;
14) usetimestep -- a logical switch: if true, the program will seek for a timestep file, which contains a table with the descriprion of image pairs;
15) timestepfile -- the name of the timestep file (OPTIONAL): this feature allows to control the stability of images recording rate; PIVlab_batch reads from it the column entitled 'badpair', which should contain in the order of following of the image pairs the values 0 or 1; the former stands for good pairs where dt1 is respected, the latter -- for bad pairs that deviate from dt1;

Misc. parameters
16) showfields -- a logical switch to select whether to show the velocity vector fields during the calculation;
17) computestreamfnc -- a logical switch: compute or not the stream function from the obtained velocity vector fields;
18) scanpasses -- number of passes (forth and back): 2 is normal mode, 1 is for debugging;
19) leftBC, bottomBC, rightBC, topBC -- the boundary conditions for the streamfunction: possible values are scalar, 1D vector of the approrpiate length, NaN;
20) exec_control -- a logical switch that selects whether or not to have some extra ouput from the program.

21) Standard PIV Settings, Standard Image Preprocessing Settings and PIV Postprocessing Settings are the same as in the PIVlab and documented there.

22) Section to provide user-defined initial parameters of the dynamic region of interest (ROI): 
if dynamicroi==true
%     Write here any parameters related to you dynamic ROI UDF.
end


_Finding the parameters values

First run PIVlab_GUI and load a sample of your image series. You may use the PIVlab interface to figure out what ROI suits your needs, as well as the image pre-processing parametres and PIV settings. Do tests and find what is optimal for your case.
When done, copy the parameters determined to the config file "PIVlab_conf*".


_Running PIVlab_batch

First, the program will ask if it should clean the variables. The default is "no", so during the first run the user should just press Enter.
Then the user will be asked to specify 1) the directory containing the images to be analyzed, 2) the one containing the configuration file (this directory should also contain the timestepfile if used and will be used to save some automatically generated configuration files), 3) and the one to save the results to.

During the calculation the program will display the progress counter and some graphs when the calculation will be finished.

At the end the data is automatically exported to CSV-files.


_Evaluating the data obtained

The data is automatically saved in csv-files and may be easily used for further work.
Besides, three commands are bundled with PIVlab_batch, which allow to view and export the graphical representation of results.
Each of them launches with a wizard. During the first run, the default values of parameters are suggested and may be adjusted.
At the end of each run, the actual parameters are saved in an appropriate config file, they are loaded upon the next run and may be adjusted.

1) plot_fields -- it plots simple vector fields overlaying the original images.
The parameters are the following:
- directory to export figures;
- exportpng, exporteps, dispfig -- boolean that stand for the export of png files, eps files, and displaying figures;
- "Each n's x(y)-vector" -- step (increment) of plotting vectors: 1 is for each vector, 2 -- each second, etc.

The user is also invited to input the numbers of velocity fields to be displayed. They may be given in the form of a scalar, a vector, a range, or a combination of those.
The selected images are displayed consecutively in the same window if dispfig==true and saved to the specified export directory if exportpng==true | exporteps==true.

2) plot_cfields -- it plots the velocity vector fields overlaying the color maps of velocity magnitude.
The same parameters as plot_fileds plus one new:
whereistop -- it is a string parameter allowing user to select the desired orientation of the finally rendered images; the accepted values are: 'top', 'right', 'bottom', 'left'.

When a series of images is polotted, the colormap range is calculated for the whole series and plotted only in the last image.

3) plot_streamf -- it plots the contour maps of the streamfunction.
If there are no data for the streamfunction (e.g. computestreamfnc==false), plot_streamf terminates.
The same parameters as above are present.
Additional parameters are:
- "Title of your figure";
- vectors -- if true, vector fields are plotted overlaying the contour maps;
- scaleset -- if true, the scale is selected from the limits of the set of plotted images only, otherwise the scale is measured from all the data processed;
- labels -- if true, the labels for the isolines are plotted;
- noaxis -- if true, the axes are not drawn, otherwise, the border is plotted according to the "border" parameter;
- fillcont -- if true, the contours are filled;
- graymap -- if true, colormap(gray) is applied.
