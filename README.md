# High_Throughput_Component_Labeling_Engine

## Overview
   This is the final project of Computer-aided VLSI System Design. I designed a Component Labeling Engine (CLE), which can detect object segmentation from the binary image, and give the same ID number to the same object. My design ranked 4th out of 53 graduate student teams. The performance is evaluated with $$Area x Time^2.$$

   ![](./figure/introduction.PNG)

## Statement of the problem

### Block diagram
   The block diagram is shown below. The design is connected with a 128x8 ROM and a 1024x8 SRAM. The ROM stores the input 32x32 image. CLE writes all the labels for the 32x32 image to the 1024x8 SRAM after done processing.

   ![](./figure/block_diagram.PNG)

### Specifications
   1. Top module name: CLE.
   2. Input/output description:

   ![](./figure/specifications.PNG)

###
   1. The input image is a 32x32 binary image as shown in Fig. 1.

   | ![](./figure/binary_image.PNG) |
   |:--:|
   | *image_caption* |

   2. For the binary signal, 0 represents the background, and 1 represents the object for each pixel. We have to check if those pixels with value 1 are connected or not. The connected pixels represent to the same object. Those pixels are given with the same label ID from the same object. The number of label ID can be created by ourselves.
   3. The image is already stored in the 128x8 ROM. The storing order is shown in Fig.3. For example, if the address value is “0”, the corresponding 8-bit binary data represents the pixels [X=00, Y=00-07] in Fig.2. The MSB is related to [X=00, Y=00], and the LSB is related to [X=00, Y=07]. The number of times to read data from ROM is not constrained, and the signal CEN from ROM is always set to 0.