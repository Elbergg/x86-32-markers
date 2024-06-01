#include <iostream>
#include <stdexcept>
#include <fstream>
#include <string>

#include <stdio.h>
#include <string.h>
#define fname "source.bmp"
// #define HEIGHT 240
// #define WIDTH 320
// #define BYTES_PER_ROW 960
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
    if (header[0] != 0x42 || header[1] != 0x4D)
    {
        std::cout << "File should be a bnp\n";
        return -3;
    }
    auto fileSize = *reinterpret_cast<uint32_t *>(&header[2]);
    auto dataOffset = *reinterpret_cast<uint32_t *>(&header[10]);
    auto width = *reinterpret_cast<uint32_t *>(&header[18]);
    std::cout << "Width: " << width << std::endl;
    auto height = *reinterpret_cast<uint32_t *>(&header[22]);
    std::cout << "Height: " << height << std::endl;
    char bitmap[fileSize];
    std::ifstream fileHandle2;
    fileHandle2.open(fname, std::ios::binary);
    fileHandle2.read(bitmap, fileSize);
    unsigned int x_pos[200] = {0};
    unsigned int y_pos[200] = {0};
    int numOfMarkers = markers(bitmap, x_pos, y_pos);
    if (numOfMarkers != 0)
    {
        for (size_t i = 0; x_pos[i] != '\0'; ++i)
        {
            std::cout << "Marker found!: ";
            std::cout << '(' << (x_pos[i]) << ',';
            std::cout << (y_pos[i]) << ')' << std::endl;
        }
        std::cout << "Number of markers: " << numOfMarkers << std::endl;
    }
    return 0;
}
