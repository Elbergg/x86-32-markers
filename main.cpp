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
extern "C" int markers(char *bmp, unsigned int *output);
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
    auto fileSize = *reinterpret_cast<uint32_t *>(&header[2]);
    auto dataOffset = *reinterpret_cast<uint32_t *>(&header[10]);
    auto width = *reinterpret_cast<uint32_t *>(&header[18]);
    auto height = *reinterpret_cast<uint32_t *>(&header[22]);
    fileHandler.seekg(dataOffset);
    char image[3 * numOfPix];
    fileHandler.read(image, 3 * numOfPix);
    unsigned int output[400] = {0};
    int numOfMarkers = markers(image, output);
    if (numOfMarkers != 0)
    {
        for (size_t i = 0; output[i] != '\0'; ++i)
        {
            std::cout << "Marker found!: ";
            std::cout << '(' << (output[i]) << ',';
            ++i;
            std::cout << (output[i]) << ')' << std::endl;
        }
        std::cout << "Number of markers: " << numOfMarkers << std::endl;
    }
    return 0;
}
