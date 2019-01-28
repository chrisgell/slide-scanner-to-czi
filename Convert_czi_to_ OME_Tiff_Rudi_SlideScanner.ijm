//Macro to convert a folder of .czi in Zeiss's pyrimidal slide scanner format to max projections of the individual channels. Assumes only 2 channels.
//Chris Gell January 2019

#@ String(label="What file format are you working with?",choices={".czi",".lsm",".ne2",".lif",".dv"}) fileFormat
//#@ boolean (label = "Max. Proj?" , value = true) doMaxProj;


path = getDirectory("Choose input directory"); 
outputFolder = getDirectory("Choose or create a directory to save results.");
filelist = getFileList(path); //load array of all files inside input directory

setBatchMode(true);
 

//parse through all files in folder 
for (i=0; i< filelist.length; i++) {
     
   
    //check to see if they are .cszi   
    if (endsWith(filelist[i], fileFormat)) {

    	//running bioformats to try to work out hjow many scenes there are in this file.
		run("Bio-Formats Macro Extensions"); 
		Ext.setId(path+filelist[i]);
		Ext.getSeriesCount(seriesCount); 
		//print("SeriesCOunt"+seriesCount);

		//this should be the number of scenes on the slide, display a message for the user to see, no overide at the moment.
		numScenes = (seriesCount - 2)/5;
		waitForUser("There appeas to be " + numScenes + " scenes on this slide, if this is not correct then the czi format \n has been modfied. The macro will need to be changed.");

		//parse throught he scences, assuming there are 5 copies of eack scene.
		for (p=1; p<= seriesCount; p++) {

			
			//print("p"+p);
		
			//uncomment this for testing, it will only read the first 2 z-slices for each file.	
			 //run("Bio-Formats Importer", "open=["+path+filelist[i]+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+p+" c_begin_"+p+"=1 c_end_"+p+"=2 c_step_"+p+"=1 z_begin_"+p+"=1 z_end_"+p+"=2 z_step_"+p+"=1");
			
			//run bio-formats importer
			run("Bio-Formats Importer", "open=["+path+filelist[i]+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+p);
	
			loadedImageID = getImageID();
			selectImage(loadedImageID);
			loadedImageName=getTitle();
			print(loadedImageName);
			run("Z Project...", "projection=[Max Intensity]");
			 run("Split Channels");
			selectWindow("C1-MAX_"+loadedImageName);
			saveAs("Tiff", outputFolder+"C1-MAX_"+loadedImageName);
			selectWindow("C2-MAX_"+loadedImageName);
			saveAs("Tiff", outputFolder+"C2-MAX_"+loadedImageName);
			run("Close All");
			p=p+4;
		

		 
		 

			
		}

	

     
 	}
}


setBatchMode(false);
//close();


//run("Bio-Formats Importer", "open=[C:/Users/mbzcg1/Desktop/Philippine/b-ham stack czi/2.czi] autoscale color_mode=Composite rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT series_1 c_begin_1=1 c_end_1=2 c_step_1=1 z_begin_1=1 z_end_1=2 z_step_1=1");