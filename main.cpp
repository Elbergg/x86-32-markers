#include <iostream>
#include <stdexcept>
#include <fstream>
#include <string>

#include <stdio.h>
#include <string.h>
#define fname "source.bmp"
#define HEIGHT 240
#define WIDTH 320
#define BYTES_PER_ROW 960
#define HEADER_SIZE 54
extern "C" int markers(char *bmp, unsigned int *x_pos, unsigned int *y_pos);
int main(int argc, char *argv[])
{
    std::ifstream fileHandler;
    fileHandler.open(fname, std::ios::binary);
    if (fileHandler.good())
        std::cout << "File opened succesfully\n";
    else
    {
        std::cout << "Error when opening file\n";
        return -2;
    }
    char header[HEADER_SIZE];
    fileHandler.read(header, HEADER_SIZE);
    uint32_t numOfPix = HEIGHT * WIDTH;
    auto dataOffset = *reinterpret_cast<uint32_t *>(&header[10]);
    fileHandler.seekg(dataOffset);
    char bitmap[3 * numOfPix];
    fileHandler.read(bitmap, 3 * numOfPix);
    unsigned int x_pos[200] = {0};
    unsigned int y_pos[200] = {0};
    int numOfMarkers = markers(bitmap, x_pos, y_pos);
    if (numOfMarkers != 0)
    {
        for (size_t i = 0; x_pos != '\0'; ++i)
        {
            std::cout << "Marker found!: ";
            std::cout << '(' << (x_pos[i]) << ',';
            std::cout << (y_pos[i]) << ')' << std::endl;
        }
        std::cout << "Number of markers: " << numOfMarkers << std::endl;
    }
    return 0;
}
