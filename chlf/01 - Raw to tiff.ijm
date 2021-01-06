//define function
function action(input, output, filename) {
	run("Raw...", "open=["+input + filename+"]"+" image=[32-bit Real] width=720 height=560 offset=8 little-endian");
	saveAs("Tiff", output + filename);
	close();
}

//pahts
input = "yourpath/chlf/fimg/";
output = "yourpath/chlf/tiff/";

//Process
setBatchMode(true); 
list = getFileList(input);
for (i = 0; i < list.length; i++)
        action(input, output, list[i]);
setBatchMode(false);
