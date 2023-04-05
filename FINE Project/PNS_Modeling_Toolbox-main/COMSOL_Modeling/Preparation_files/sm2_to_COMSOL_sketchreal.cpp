// sm2_to_COMSOL_sketchreal.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

// these are just to make other functions function
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <vector>
using namespace std;

// A struct to better organize each inserted object
struct neuralTissue {
    string name;
    vector<double> xPos = {};
    vector<double> yPos = {};

};


// If you're from the future and want to make sense of this, look at an sm2 file next to this while going through line by line
// currentlyRead is basically a cursor and the program just looks at a single word at a time
int main(int argc, char* argv[]) {


    // the single element that is being read by the program at a given time
    string currentlyRead;

    // names for the file being read and the file being wrote to 
    ifstream sm2In;
    fstream COMSOLSketch;

    string filename;
    filename = argv[1];
    string path;
    path = argv[2];
    //batch file takes care of it, make sure the exe is somewhere in C:\\ so that weird network comps don't ruin stuff
    string fullPath = "C:\\";  //This is overwritten, don't worry about it

    // "\\" is used to be a single \ just because c++ doesn't want a single \ in a string, this lets it be part of the string
    fullPath = path;
    fullPath.append("\\");
    // here the name of the .sm2 file goes
    fullPath.append(filename);

    sm2In.open(fullPath);

    // can't open it, just give up now
    if (!sm2In) {
        cout << "Unable to open file";
        exit(1); // terminate with error
    }

    // we do one file with all neural tissue 2 lines for some reason
    // Maybe change to mphtxt or txt
    string fileOut = path.append("\\sketch_for_COMSOL_neural_tissues.mphtxt");

    COMSOLSketch.open(fileOut);

    COMSOLSketch.clear();

    // initializing the vector that holds every individual outline
    vector<neuralTissue> tissues;



    while (sm2In >> currentlyRead) {

        // we're detecting an Object is coming up by this text, how nice ( == 0 meand it's the same)
        if (currentlyRead.compare("B_OBJECT") == 0) {
            // initialize an object and move forward
            tissues.push_back(neuralTissue());
            sm2In >> currentlyRead;
            sm2In >> currentlyRead;

            // naming the struct element according to the sm2 file
            tissues.back().name = currentlyRead;

            // this is done until we see Vert
            while (currentlyRead.compare("Vert") != 0) {
                sm2In >> currentlyRead;
            }
            // now we're doing the core loop for a single object now as we're in the verticies portion
            while (currentlyRead.compare("E_VERTS") != 0) {
                // 3 values about object numbers, who cares
                sm2In >> currentlyRead;
                sm2In >> currentlyRead;
                sm2In >> currentlyRead;

                // 2 values we care about
                sm2In >> currentlyRead;
                tissues.back().xPos.push_back(stod(currentlyRead));
                sm2In >> currentlyRead;
                tissues.back().yPos.push_back(stod(currentlyRead));

                // now we are either on "vert" like before, or we are on "E_VERTS" which also means we're done
                sm2In >> currentlyRead;
            }
        }
        // we saw B_Object and we're done with it, eiher we see another object or we finish, I think this is it  
    }

    // because the first and last points in all of the things are the same, COMSOL doesn't like that, the shapes don't close if there're repeats
    for (int i = 0; i < tissues.size(); i++) {
        while ((tissues[i].xPos[0]==tissues[i].xPos.back()) && (tissues[i].yPos[0] == tissues[i].yPos.back())) {
            tissues[i].xPos.pop_back();
            tissues[i].yPos.pop_back();
        }
    }
    cout << "yay, that's done";

    // Done with the ipnut sm2, now we're just making the mphtxt

    //______________________________________________________________________Part Deux___________________________________________________

    // go through each tissue and create a mphtxt that has it all. Object 1 to whatever the last one is. A lot of these parameters are basically the same for each
    
    // The header that COMSOL wants is done below
    COMSOLSketch << "# Created by Vlad \n \n#Major and minor version \n0 1 \n" + to_string(tissues.size()) + " # number of tags \n# Types \n";

    for (int i = 0; i < tissues.size(); i++) {
        COMSOLSketch << "4 poll\n";
    }
    COMSOLSketch << to_string(tissues.size()) + " # number of types\n#Types\n";
    for (int i = 0; i < tissues.size(); i++) {
        COMSOLSketch << "3 obj\n";
    }

    // MAIN LOOP for this portion
    // Largely a brainless copying of the current format. It only transfers the sketches
    for (int i = 0; i < tissues.size(); i++) {
        COMSOLSketch << "# -------------- Object "+ to_string(i) + " " + tissues[i].name + " -------------- \n\n";
        COMSOLSketch << "0 0 1\n";
        // a header which, for sketches, will always be the same
        COMSOLSketch << "5 Geom2 # class\n2 # version\n2 # type\n1 # voidsLabeled\n1e-10 # gto1\n0.0001 # resTol\n" + to_string(tissues[i].xPos.size()) + " # number of verticies\n# Verticies\n# X Y dom tol\n";
       
        // putting all of the VERTICIES in, each object i has arrays with size j
        for (int j = 0; j < tissues[i].xPos.size(); j++) {
            COMSOLSketch << to_string(tissues[i].xPos[j]) + " " + to_string(tissues[i].yPos[j]) + " -1 1.4142135623730951e-10\n";
        }
        COMSOLSketch << "\n" + to_string(tissues[i].xPos.size()) + " # number of edges\n# Edges\n# vtx1 vtx2 s1 s2 up down mfd tol\n";
        //putting all of the EDGES in now (SIZE - 1) for the last element
        for (int j = 0; j < tissues[i].xPos.size()-1; j++) {
            COMSOLSketch << to_string(j+1)+" "+to_string(j+2)+" 0 1 0 1 "+to_string(j+1)+" NAN\n";
        }
        // last line so that the vertex numbers wrap around 
        COMSOLSketch << to_string(tissues[i].xPos.size()) + " " + "1" + " 0 1 0 1 " + to_string(tissues[i].xPos.size()) + " NAN\n";
        
        // MANIFOLD part now
        COMSOLSketch << to_string(tissues[i].xPos.size()) + " # number of manifolds\n# Manifolds\n\n";
        // Still the size-1 thing, need to do the last 2 points 
        for (int j = 0; j < tissues[i].xPos.size()-1; j++) {
            COMSOLSketch << "# Manifold #" + to_string(j) + "\n\n11 BezierCurve #class\n0 0 #version\n2 #sdim\n0 2 1 # transformation\n1 0 #degrees\n2 # number of control points\n#control point coords and weights\n";
            //the two points where using a brain is happening, weights are 1 though
            COMSOLSketch << to_string(tissues[i].xPos[j]) + " " + to_string(tissues[i].yPos[j]) + " 1\n";
            COMSOLSketch << to_string(tissues[i].xPos[j + 1]) + " " + to_string(tissues[i].yPos[j + 1]) + " 1\n\n";           
        }
        // just the last one
        COMSOLSketch << "# Manifold #" + to_string(tissues[i].xPos.size()-1) + "\n\n11 BezierCurve #class\n0 0 #version\n2 #sdim\n0 2 1 # transformation\n1 0 #degrees\n2 # number of control points\n#control point coords and weights\n";
        COMSOLSketch << to_string(tissues[i].xPos[tissues[i].xPos.size()-1]) + " " + to_string(tissues[i].yPos[tissues[i].yPos.size() - 1]) + " 1\n";
        COMSOLSketch << to_string(tissues[i].xPos[0]) + " " + to_string(tissues[i].yPos[0]) + " 1\n\n";

        // just what happens at the end
        COMSOLSketch << "# Attributes\n0 # nof attributes\n\n";
    }

    // this prevents weirdness from happening
    sm2In.close();
    COMSOLSketch.close();

}
