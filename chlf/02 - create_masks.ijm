//define function
function action(input, output, filename) {
	open(input + filename);
	setThreshold(66.8612, 1000000000000000000000000000000.0000);
	run("Convert to Mask");
	saveAs("Tiff", output + filename);
	close();
}

//pahts
input = "yourpath/chlf/fo_round_1/";
output = "yourpath/chlf/masks/";

//Process
setBatchMode(true); 
list = getFileList(input);
for (i = 0; i < list.length; i++)
        action(input, output, list[i]);
setBatchMode(false);
