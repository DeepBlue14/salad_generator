#include <vector>
#include <iostream>

#include <unistd.h>

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

using std::vector;
using std::cout;
using std::endl;

typedef struct Node
{
    //Node* parent;
    int x, y;
    float f, g, h;
    
    Node()
    {
        x = 0;
        y = 0;
        f = 0.0;
        g = 0.0;
        h = 0.0;
        //parent = nullptr;
    }
    
    Node(int tmpX, int tmpY)
    {
        x = tmpX;
        y = tmpY;
        f = 0.0;
        g = 0.0;
        h = 0.0;
        //parent = nullptr;
    }
    
    Node(const Node& node)
    {
        //parent = node.parent;
        x = node.x;
        y = node.y;
        f = node.f;
        g = node.g;
        h = node.h;
    }
    
} Node;


int minF(vector<Node> lst)
{
    int currMinIdx = 0;
    float currMinF = 9999.;

    for(size_t i = 0; i < lst.size(); i++)
    {
        if(lst.at(i).f < currMinF)
        {
            currMinF = lst.at(i).f;
            currMinIdx = i;
        }
    }
    
    //Node node(lst.at(currMinIdx) );
    //lst.erase(lst.begin() + (currMinIdx-1) );
    
    return currMinIdx;
}


float calcRawDistance(Node node1, Node node2)
{
    float dx = abs(node1.x - node2.x);
    float dy = abs(node1.y - node2.y);
    
    return (dx + dy);
}



float calcManhattenDistance(Node node1, Node node2)
{
    float dx = abs(node1.x - node2.x);
    float dy = abs(node1.y - node2.y);
    
    // http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html
    return (4 * (dx + dy) );
    
    /*
    float dx = abs(node1.x - node2.x);
    float dy = abs(node1.y - node2.y);
    return 4 * (dx * dx + dy + dy);
    */
}


vector<Node> getSuccessors(Node node, cv::Mat allNodes)
{
    vector<Node> successors;
    if(node.x < (allNodes.cols-1) && node.y < (allNodes.rows-1) )
    {
        successors.push_back(Node(node.x + 1, node.y) );
        successors.push_back(Node(node.x - 1, node.y) );
        successors.push_back(Node(node.x, node.y + 1) );
        successors.push_back(Node(node.x, node.y - 1) );
        
        successors.push_back(Node(node.x + 1, node.y + 1) );
        successors.push_back(Node(node.x - 1, node.y - 1) );
        successors.push_back(Node(node.x + 1, node.y + 1) );
        successors.push_back(Node(node.x - 1, node.y - 1) );
    }
    
    return successors;
}


void display(vector<Node> openLst, vector<Node> closedLst, Node start, Node goal)
{
    //cv::Mat image = cv::Mat::ones(640, 400, CV_8UC3);
    cv::Mat image = cv::imread("blank.png", CV_LOAD_IMAGE_COLOR);
    
    for(size_t i = 0; i < openLst.size(); i++)
    {
        image.at<cv::Vec3b>(openLst.at(i).x, openLst.at(i).y)[0] = 0;
        image.at<cv::Vec3b>(openLst.at(i).x, openLst.at(i).y)[1] = 0;
        image.at<cv::Vec3b>(openLst.at(i).x, openLst.at(i).y)[2] = 200;
    }
    
    for(size_t i = 0; i < closedLst.size(); i++)
    {
        image.at<cv::Vec3b>(closedLst.at(i).x, closedLst.at(i).y)[0] = 200;
        image.at<cv::Vec3b>(closedLst.at(i).x, closedLst.at(i).y)[1] = 0;
        image.at<cv::Vec3b>(closedLst.at(i).x, closedLst.at(i).y)[2] = 0;
    }
    
    image.at<cv::Vec3b>(start.x, start.y)[0] = 0;
    image.at<cv::Vec3b>(start.x, start.y)[1] = 250;
    image.at<cv::Vec3b>(start.x, start.y)[2] = 0;
    
    image.at<cv::Vec3b>(goal.x, goal.y)[0] = 0;
    image.at<cv::Vec3b>(goal.x, goal.y)[1] = 250;
    image.at<cv::Vec3b>(goal.x, goal.y)[2] = 0;
    
    cv::imshow("Costmap", image);
    //cv::resizeWindow("Costmap", 800, 800);
    cv::waitKey(0);
}


int main(int argc, char** argv)
{
    cv::Mat image = cv::imread("costmap.png", CV_LOAD_IMAGE_COLOR);
    if(!image.data)                              // Check for invalid input
    {
        cout <<  "Could not open or find the image -- Bye!" << endl;
        return -1;
    }

    Node startingNode(100, 100); // FIXME: set member vars
    //Node goal(150, 150); // FIXME: set member vars
    Node goal(50, 50); // FIXME: set member vars
    //Node goal(110, 150);

    // A*
    vector<Node> openLst;
    vector<Node> closedLst;
    openLst.push_back(startingNode);

    while(openLst.empty() == false)
    {
        display(openLst, closedLst, startingNode, goal);
    
        cout << "-     -     -     -     -     -     -     -     -" << endl;
    
        int idx = minF(openLst);
        Node q = openLst.at(idx);
        openLst.erase(openLst.begin() + idx);
        vector<Node> successorLst = getSuccessors(q, image);
        cout << "q idx: " << idx << endl;
        cout << "q: (" << q.x << "," << q.y << ")" << endl;
        cout << "successor list: " << successorLst.size() << endl;
        //for(size_t x = 0; x < successorLst.size(); x++)
        //    cout << "\t(" << successorLst.at(x).x << "," << successorLst.at(x).y << ")" << endl;
        cout << "open list: " << openLst.size() << endl;
        //for(size_t x = 0; x < openLst.size(); x++)
        //    cout << "\t(" << openLst.at(x).x << "," << openLst.at(x).y << ")" << endl;
        cout << "closed list: " << closedLst.size() << endl;
        
        for(size_t i = 0; i < successorLst.size(); i++)
        {
            if(successorLst.at(i).x == goal.x && successorLst.at(i).y == goal.y)
            {
                cout << "Found goal -- Bye!" << endl;
                exit(0);
            }
            
            successorLst.at(i).g = q.g + calcRawDistance(successorLst.at(i), q);
            successorLst.at(i).h = calcManhattenDistance(successorLst.at(i), goal); //the smaller this is, the better
            successorLst.at(i).f = successorLst.at(i).g + successorLst.at(i).h;
            //cout << "g=" << successorLst.at(i).g << endl;
            //cout << "h=" << successorLst.at(i).h << endl;
            cout << "f=" << successorLst.at(i).f << endl;

            bool foundMatch = false;
            int openIdx = -1;
            int closedIdx = -1;
            for(size_t j = 0; j < openLst.size(); j++)
            {
                if(openLst.at(j).x == successorLst.at(i).x && openLst.at(j).y == successorLst.at(i).y && openLst.at(j).f < successorLst.at(i).f)
                {
                    cout << "found match (1)" << endl;
                    foundMatch = true;
                    openIdx = j;
                    //break;
                }
            }
            for(size_t j = 0; j < closedLst.size(); j++)
            {
                if(closedLst.at(j).x == successorLst.at(i).x && closedLst.at(j).y == successorLst.at(i).y && closedLst.at(j).f < successorLst.at(i).f)
                {
                    cout << "found match (2)" << endl;
                    foundMatch = true;
                    closedIdx = j;
                    //break;
                }
            }
            
            if(foundMatch != true)
            {
                //cout << "adding to openLst" << endl;
                openLst.push_back(successorLst.at(i) );
                cout << i << endl;
            }
            else
            {
                ;//break;
            }
            
            
        }
        
        closedLst.push_back(q);
        cout << "ending outer loop: " << openLst.size() << endl;
    }

    return 0;
}
