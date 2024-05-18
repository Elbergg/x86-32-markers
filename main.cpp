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
extern "C" int markers(char *bmp, char *output);
int main(int argc, char *argv[])
{
    std::ifstream fileHandler;
    fileHandler.open(fname, std::ios::binary);
    if (fileHandler.good())
        std::cout << "Otwarto plik...\n";
    else
    {
        std::cout << "Unable to open file\n";
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
    char output[250] = {0};
    int numOfMarkers = markers(image, output);
    for (size_t i = 0; output[i] != '\0'; ++i)
    {
        std::string result;
        result += '(';
        result += std::to_string(output[i]);
        result += ',';

        ++i;
        result += std::to_string(output[i]);
        result += ')';
        std::cout << result << std::endl;
    }
    return 0;
}
